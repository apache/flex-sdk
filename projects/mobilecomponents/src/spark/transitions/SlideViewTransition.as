////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.effects
{
import flash.display.BitmapData;
import flash.display.DisplayObject;

import mx.core.IVisualElementContainer;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.effects.IEffect;
import mx.effects.Parallel;
import mx.events.EffectEvent;

import spark.components.ActionBar;
import spark.components.Group;
import spark.components.Image;
import spark.components.TabbedViewNavigator;
import spark.components.ViewNavigator;
import spark.components.supportClasses.ButtonBarBase;
import spark.components.supportClasses.ViewNavigatorBase;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;
import spark.effects.easing.Sine;

use namespace mx_internal;

/**
 * 
 */
public class SlideViewTransition extends ViewTransition
{
    //--------------------------------------------------------------------------
    //
    //  Constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Slide the views to the left.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const SLIDE_LEFT:String = "left";

    /**
     *  Slide the views to the right.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const SLIDE_RIGHT:String = "right";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *  
     *  @param duration The duration of the effect
     *  @param direction The direction of the transition.  Can be "left" or "right".
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function SlideViewTransition(duration:Number = 300, direction:String = SLIDE_LEFT)
    {
        super();
        
        this.duration = duration;
        this.direction = direction;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */ 
    private var parentNavigator:ViewNavigatorBase;
    
    /**
     *  @private
     */
    private var targetNavigator:ViewNavigatorBase;
    
    /**
     *  @private
     */
    private var actionBar:ActionBar;
    
    /**
     *  @private
     */
    private var cachedNavigator:Image;
    
    /**
     *  @private
     */
    private var cachedActionBar:Image;
    
    /**
     *  @private
     */
    private var cachedActionGroup:Image;
    
    /**
     *  @private
     */
    private var cachedTitleGroup:Image;
    
    /**
     *  @private
     */
    private var cachedNavigationGroup:Image;
    
    /**
     *  @private
     */
    private var currentViewProps:Object;
    
    /**
     *  @private
     */
    private var nextViewProps:Object;
    
    /**
     *  @private
     */
    private var explicitContentGroupIncludeInLayout:Boolean;
    
    /**
     *  @private
     */
    private var explicitIncludeInLayout:Boolean;
    
    /**
     *  @private
     */
    private var fullScreenAnimation:Boolean;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    [Inspectable(category="General", enumeration="left, right", defaultValue="left")]
    /**
     *  The direction of the slide animation.  Can be either "left" or "right".
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var direction:String = SLIDE_LEFT;
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override public function prepare():void
    {
        var tabBar:ButtonBarBase;
        parentNavigator = navigator.parentNavigator;
        targetNavigator = parentNavigator ? parentNavigator : navigator;
        
        fullScreenAnimation = false;
        
        // Determine if this will be a full screen slide animation.  A
        // fullScreen animation will occur if the parent navigator is a
        // TabbedViewNavigator and the tabBar visiblity has changed, the 
        // overlayControls property changes between views or the size of
        // the actionBar changes.
        if (parentNavigator is TabbedViewNavigator)
        {
            tabBar = TabbedViewNavigator(parentNavigator).tabBar;
            
            if (tabBar)
                fullScreenAnimation = (componentIsVisible(tabBar) != nextView.tabBarVisible);
        }
        
        // Check for actionBar visiblity and overlayControls property change
        if (!fullScreenAnimation)
        {
            if (nextView.overlayControls != currentView.overlayControls)
            {
                fullScreenAnimation = true;
            }
            else if (navigator is ViewNavigator)
            {
                if (componentIsVisible(ViewNavigator(navigator).actionBar) != nextView.actionBarVisible)
                {
                    fullScreenAnimation = true;
                    targetNavigator = navigator;
                }
            }
        }
        
        // If the transition still can't determine if the animation will be fullscreen, 
        // prepare bitmaps of the actionBar in the case they are needed
        if (!fullScreenAnimation)
        {
            targetNavigator = navigator;
            
            if (navigator is ViewNavigator)
            {
                actionBar = ViewNavigator(navigator).actionBar;
    
                if (componentIsVisible(actionBar))
                {
                    // Always generate full ActionBar caches
                    cachedActionBar = generateBitmap(actionBar);
                    
                    // This transition was designed to always animate the title content
                    if (actionBar.titleGroup && actionBar.titleGroup.visible)
                        cachedTitleGroup = generateBitmap(actionBar.titleGroup);
                    else if (actionBar.titleDisplay
                        && (actionBar.titleDisplay is UIComponent)
                        && UIComponent(actionBar.titleDisplay).visible)
                        cachedTitleGroup = generateBitmap(UIComponent(actionBar.titleDisplay));
                    
                    // If the actionContent will change prepare a bitmap image of the group
                    if (currentView.actionContent != nextView.actionContent)
                        cachedActionGroup = generateBitmap(actionBar.actionGroup);
                    
                    // If the navigationContent will change prepare a bitmap image of the group
                    if (currentView.navigationContent != nextView.navigationContent)
                        cachedNavigationGroup = generateBitmap(actionBar.navigationGroup);
                }
            }
        }

        // Temporarily hide the the next view so that it isn't included in the cached bitmap
        // of the current navigator state
        var oldVisibility:Boolean = nextView.visible;
        nextView.visible = false;
        
        // Always generate a bitmap representation of the navigator because
        // we can't determine if it will be a full screen animation at this point.
        // The acitonBar's dimensions can change between now and play() since a
        // validation pass will run.
        cachedNavigator = generateBitmap(targetNavigator);
        
        // Restore the visibility of the next view
        nextView.visible = oldVisibility;
    }
    
    /**
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override public function play():void
    {
        var targets:Array = new Array();
        
        // Check if the height of the actionBar changed.  If so, perform a
        // fullscreen animation
        if (!fullScreenAnimation)
        {
            fullScreenAnimation = cachedActionBar && 
                                  ((actionBar.height != cachedActionBar.height) ||
                                   (actionBar.width != cachedActionBar.width));
        }
            
        // Create the animation
        if (fullScreenAnimation)
        {
            currentView.visible = false;
            targets.push(cachedNavigator);
            targets.push(targetNavigator.contentGroup);
            
            explicitContentGroupIncludeInLayout = targetNavigator.contentGroup.includeInLayout;
            targetNavigator.contentGroup.includeInLayout = false;
            
            if (targetNavigator is TabbedViewNavigator)
            {
                targets.push(TabbedViewNavigator(targetNavigator).tabBar);
                explicitIncludeInLayout = TabbedViewNavigator(targetNavigator).tabBar.includeInLayout; 
                TabbedViewNavigator(targetNavigator).tabBar.includeInLayout = false;
            }
            else if (targetNavigator is ViewNavigator)
            {
                targets.push(ViewNavigator(targetNavigator).actionBar);
                explicitIncludeInLayout = ViewNavigator(targetNavigator).actionBar.includeInLayout; 
                ViewNavigator(targetNavigator).actionBar.includeInLayout = false;
            }
            
            if (cachedNavigator)
            {
                cachedNavigator.x = cachedNavigator.y = 0;
                cachedNavigator.includeInLayout = false;
                
                addComponentToContainerSkin(cachedNavigator, targetNavigator.skin);
            }
            
            effect = createFullScreenAnimation(targets);
        }
        else
        {
            // If we aren't doing a full screen transition, this transition will
            // slide the child views and the internals of the actionBar only
            if (currentView)
            {
                currentViewProps = { includeInLayout:currentView.includeInLayout,
                                     cacheAsBitmap:currentView.cacheAsBitmap };
                
                currentView.includeInLayout = false;
                currentView.cacheAsBitmap = true;
                targets.push(currentView);
            }
            
            if (nextView)
            {
                nextViewProps = { includeInLayout:nextView.includeInLayout,
                                  cacheAsBitmap:nextView.cacheAsBitmap };
                
                nextView.includeInLayout = false;
                nextView.cacheAsBitmap = true;
                targets.push(nextView);
            }
            
            effect = new Parallel();
            
            // Determine if we are doing an internal actionbar transition
            // or sliding in a new one
            if (actionBar)
                appendActionBarAnimations(Parallel(effect));
            
            Parallel(effect).addChild(createViewAnimation(targets));
        }
        
		// Create view animations
		effect.addEventListener(EffectEvent.EFFECT_END, transitionComplete);
		effect.play();
    }
    
    /**
     * Called when the transition is complete.  Cleans up all temporary
     * bitmaps that were created, and restores any properties on
     * the view and navigator components that were changed.
     * 
     * @param event The effect complete event dispatched by the single
     * parallel effect this transition plays.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override public function transitionComplete(event:EffectEvent=null):void
    {
        event.target.removeEventListener(EffectEvent.EFFECT_END, transitionComplete);
        
        if (fullScreenAnimation)
        {
            // Restore the visibility of the current view
            currentView.visible = true;
            
            if (cachedNavigator)
                removeComponentFromContainerSkin(cachedNavigator, targetNavigator.skin);
            
            targetNavigator.contentGroup.includeInLayout = explicitContentGroupIncludeInLayout;
            
            if (targetNavigator is TabbedViewNavigator)
            {
                TabbedViewNavigator(targetNavigator).tabBar.includeInLayout = 
                    explicitIncludeInLayout;
            }
            else if (targetNavigator is ViewNavigator)
            {
                ViewNavigator(targetNavigator).actionBar.includeInLayout = 
                    explicitIncludeInLayout;
            }
        }
        else
        {
            if (currentView)
            {
                currentView.includeInLayout = currentViewProps.includeInLayout;
                currentView.cacheAsBitmap = currentViewProps.cacheAsBitmap;
                currentViewProps = null;
            }
            
            if (nextView)
            {
                nextView.includeInLayout = nextViewProps.includeInLayout;
                nextView.cacheAsBitmap = nextViewProps.cacheAsBitmap;
                nextViewProps = null;
            }
            
            if (actionBar.titleGroup && actionBar.titleGroup.visible)
                actionBar.titleGroup.cacheAsBitmap = false;
            
            if (actionBar.titleDisplay
                && (actionBar.titleDisplay is DisplayObject)
                && DisplayObject(actionBar.titleDisplay).visible)
                DisplayObject(actionBar.titleDisplay).cacheAsBitmap = false;
            
            if (cachedTitleGroup)
                removeComponentFromContainerSkin(cachedTitleGroup, actionBar.skin);
            
            if (cachedNavigationGroup)
                removeComponentFromContainerSkin(cachedNavigationGroup, actionBar.skin);
            
            if (cachedActionGroup)
            {
                removeComponentFromContainerSkin(cachedActionGroup, actionBar.skin);
                actionBar.actionGroup.cacheAsBitmap = false;
            }
        }
        
        if (cachedTitleGroup)
            cachedTitleGroup = null;
        
        if (cachedNavigationGroup)
            cachedNavigationGroup = null;
        
        if (cachedActionGroup)
            cachedActionGroup = null;
        
        if (cachedNavigator)
            cachedNavigator = null;
        
        effect = null;

        super.transitionComplete(event);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     * @private
     * Creates the animations used to animate the content of the
     * action bar.  This method is only called if the slide transition
     * isn't doing a full action bar transition.
     * 
     * This method should add any effects it would like to play to
     * the effect object.
     * 
     * @param effect The parallel effect that will be played by the
     * slide animation
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    protected function appendActionBarAnimations(effect:Parallel):void
    {
        var childIndex:Number;
        var slideDistance:Number;
        var animatedProperty:String;
        
        var actionBarSkin:UIComponent = actionBar.skin;
        var titleGroup:UIComponent = (actionBar.titleGroup.visible)
            ? actionBar.titleGroup : UIComponent(actionBar.titleDisplay);
        
        var fadeOutTargets:Array = new Array();
        var fadeInTargets:Array = new Array();
        
        // Calculate the slide amount
        switch(direction)
        {
            case SLIDE_LEFT:
                animatedProperty = "x";
                slideDistance = actionBar.width / 2.5;
                break;
            
            case SLIDE_RIGHT:
                animatedProperty = "x";
                slideDistance = -actionBar.width / 2.5;
                break;
        }
        
        // Initialize titleGroup
        titleGroup.cacheAsBitmap = true;
        titleGroup[animatedProperty] += slideDistance;
        fadeInTargets.push(titleGroup);
        
        if (cachedTitleGroup)
        {
            childIndex = actionBarSkin.getChildIndex(titleGroup) - 1;
            addComponentToContainerSkinAt(cachedTitleGroup, actionBarSkin, childIndex);
        }
        
        // If a cache of the navigation group exists, that means the content
        // changed.  In this case the old and new display objects need to
        // be added to an effect. 
        if (cachedNavigationGroup)
        {
            childIndex = actionBarSkin.getChildIndex(actionBar.navigationGroup) - 1;
            addComponentToContainerSkinAt(cachedNavigationGroup, actionBarSkin, childIndex);
            
            fadeOutTargets.push(cachedNavigationGroup);
            
            actionBar.navigationGroup[animatedProperty] += slideDistance;
            actionBar.navigationGroup.cacheAsBitmap = true;
            actionBar.navigationGroup.alpha = 0;
            
            fadeInTargets.push(actionBar.navigationGroup);
        }
        
        if (cachedActionGroup)
        {
            childIndex = actionBarSkin.getChildIndex(actionBar.actionGroup) - 1;
            addComponentToContainerSkinAt(cachedActionGroup, actionBarSkin, childIndex);
            
            fadeOutTargets.push(cachedActionGroup);
            
            actionBar.actionGroup[animatedProperty] += slideDistance;
            actionBar.actionGroup.cacheAsBitmap = true;
            
            fadeInTargets.push(actionBar.actionGroup);
        }
        
        // Fade out action and navigation content
        var fadeOut:Fade = new Fade();
        fadeOut.alphaFrom = 1;
        fadeOut.alphaTo = 0;
		fadeOut.duration = duration * .7;
        fadeOut.targets = fadeOutTargets;
        
        if (cachedTitleGroup)
        {
            // Fade out and slide old title content
            var animation:Animate = new Animate();
            var vector:Vector.<MotionPath> = new Vector.<MotionPath>();
            
            vector.push(new SimpleMotionPath("alpha", 1, 0));
            vector.push(new SimpleMotionPath(animatedProperty, null, null, -slideDistance));
            
            animation.motionPaths = vector;
            animation.easer = new spark.effects.easing.Sine(.7);
            animation.targets = [cachedTitleGroup];
            animation.duration = duration;
            
            effect.addChild(animation);
        }
        
        // Fade and slide in new content
        var animation2:Animate = new Animate();
        vector = new Vector.<MotionPath>();
        
        vector.push(new SimpleMotionPath("alpha", 0, 1));
        vector.push(new SimpleMotionPath(animatedProperty, null, null, -slideDistance));
        
        animation2.motionPaths = vector;
        animation2.easer = new spark.effects.easing.Sine(.7);
        animation2.targets = fadeInTargets;
        animation2.duration = duration;
        
        // Add effects to the parallel effect
        effect.addChild(fadeOut);
        effect.addChild(animation2);
    }
    
    /**
     * @private
     * Creates the animation used to transition the previous and new view.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function createViewAnimation(targets:Array):IEffect
    {
        var slideDistance:Number = direction == SLIDE_LEFT ? -navigator.width : navigator.width;
        var effect:Move = new Move();
        
        effect.targets = targets;
        effect.duration = duration;
        effect.xBy = slideDistance;
        
        nextView.x = -slideDistance;
        
        return effect;
    }
    /**
     * @private
     * Creates the animation when it is a full screen aniamtion.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function createFullScreenAnimation(targets:Array):IEffect
    {
        var slideDistance:Number = (direction == SLIDE_LEFT) ? 
                                      -targetNavigator.width : targetNavigator.width;
        
        if (targetNavigator == parentNavigator)
        {
            if (targetNavigator is TabbedViewNavigator)
                TabbedViewNavigator(targetNavigator).tabBar.x = -slideDistance;
        }
        else
        {
            if (targetNavigator is ViewNavigator)
                ViewNavigator(targetNavigator).actionBar.x = -slideDistance;
        }
        
        targetNavigator.contentGroup.x = -slideDistance;
        
        var effect:Move = new Move();
        effect.xBy = slideDistance;
        effect.targets = targets;
        effect.duration = duration;
        
        return effect;
    }
    
    /**
     * @private
     * 
     * Convenience method for generating a bitmap of a component.
     * Returns a spark image.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    // TODO (chiedozi): We shouldn't use spark image, seems a bit too heavy for this
    private function generateBitmap(component:UIComponent):Image
    {
        var width:Number = component.width;
        var height:Number = component.height;
        
        // Can't draw something that has a width or height of 0
        if (width <= 0 || height <= 0 || component.visible == false)
            return null;
        
        var bitmapData:BitmapData = new BitmapData(width, height, true, 0);
        bitmapData.draw(component);
        
        var image:Image = new Image();
        image.source = bitmapData;
        image.setActualSize(width, height);
        image.includeInLayout = false;
        image.cacheAsBitmap = true;
        
        image.x = component.x;
        image.y = component.y;
        image.alpha = component.alpha;
        
        return image;
    }
    
    /**
     * @private
     * 
     * Convenience property to determine whether the action bar is 
     * visible. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private function componentIsVisible(component:UIComponent):Boolean
    {
        return component && component.visible && component.width > 0 && component.height > 0;
    }
}
}