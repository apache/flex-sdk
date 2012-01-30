package spark.effects
{
import flash.display.BitmapData;
import flash.display.Sprite;

import mx.core.IVisualElementContainer;
import mx.core.UIComponent;
import mx.effects.IEffect;
import mx.effects.Parallel;
import mx.events.EffectEvent;

import spark.components.ActionBar;
import spark.components.ButtonBar;
import spark.components.Group;
import spark.components.Image;
import spark.components.supportClasses.OverlayDepth;
import spark.effects.Fade;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;
import spark.effects.easing.Sine;


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
    
    // TODO (chiedozi): Only support left and right slides
    public static const SLIDE_LEFT:int = 0;
    public static const SLIDE_RIGHT:int = 1;
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    public function SlideViewTransition(duration:Number = 300, direction:int = SLIDE_LEFT)
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
    
    private var actionBar:ActionBar;
    private var doInternalActionBarAnimation:Boolean;
    private var actionBarWasVisible:Boolean;
    private var contentGroupY:Number;
    
    private var tabBar:ButtonBar;
    private var tabBarWasVisible:Boolean;
    
    private var cachedActionBar:Image;
    private var cachedActionGroup:Image;
    private var cachedTitleGroup:Image;
    private var cachedNavigationGroup:Image;
    private var cachedTabBar:Image;
    
    /**
     * The following properties keep track of the include in layout
     * settings of the individual navigator components
     */
    private var tabBarExplicitIncludeInLayout:Boolean;
    private var actionBarExplicitIncludeInLayout:Boolean;
    private var contentGroupExplicitIncludeInLayout:Boolean;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    public var direction:int = SLIDE_LEFT;
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     * 
     */
    // TODO (chiedozi): ViewNavigator was changed to always create a dummy view
    // if the instance was null for some reason.  In theory, the nextView and
    // currentView properties should never be null.  Can remove the null checks.
    override public function prepare():void
    {
        actionBar = navigator.actionBar;
        tabBar = navigator.tabBar;
        contentGroupY = navigator.contentGroup.y;
        
        if (currentView)
            currentView.cacheAsBitmap = true;
        
        if (nextView)
            nextView.cacheAsBitmap = true;
        
        actionBarWasVisible = componentIsVisible(actionBar);
        if (actionBar && actionBarWasVisible)
        {
            // Always generate titleContent and actionBar caches
            cachedActionBar = generateBitmap(actionBar);
            
            if (actionBar.titleGroup)
            {
                cachedTitleGroup = generateBitmap(actionBar.titleGroup);
            
                if (cachedTitleGroup)
                    cachedTitleGroup.cacheAsBitmap = true;
            }
            
            // If the actionContent or navigationContent will change,
            // prepare a bitmap image of the group
            if (currentView.actionContent != nextView.actionContent)
            {
                cachedActionGroup = generateBitmap(actionBar.actionGroup);
                
                if (cachedActionGroup)
                    cachedActionGroup.cacheAsBitmap = true;
            }
            
            if (currentView.navigationContent != nextView.navigationContent)
            {
                cachedNavigationGroup = generateBitmap(actionBar.navigationGroup);
                
                if (cachedNavigationGroup)
                    cachedNavigationGroup.cacheAsBitmap = true;
            }
        }
        
        if (tabBar)
        {
            tabBarWasVisible = componentIsVisible(tabBar);
            if (tabBarWasVisible != nextView.tabBarVisible ||
                nextView.overlayControls != currentView.overlayControls)
            {
                cachedTabBar = generateBitmap(tabBar);
            }
        }
    }
    
    /**
     * 
     */
    override public function play():void
    {
        var targets:Array = new Array();
        
        if (currentView)
        {
            currentView.includeInLayout = false;
            
            if (contentGroupY != navigator.contentGroup.y)
                currentView.y = contentGroupY - navigator.contentGroup.y;
                    
            targets.push(currentView);
        }
        
        if (nextView)
        {
            nextView.includeInLayout = false;
            targets.push(nextView);
        }
        
        effect = new Parallel();
        
        // Determine if we are doing an internal actionbar transition
        // or sliding in a new one
        if (actionBar)
        {
            if (actionBarWasVisible && componentIsVisible(actionBar) && cachedActionBar &&
                actionBar.height == cachedActionBar.height &&
                actionBar.width == cachedActionBar.width &&
                currentView.overlayControls == nextView.overlayControls)
            {
                doInternalActionBarAnimation = true;
                appendActionBarAnimations(Parallel(effect));
            }
            else
            {
                doInternalActionBarAnimation = false;
                
                if (cachedActionBar)
                {
                    cachedActionBar.includeInLayout = false;
                    cachedActionBar.cacheAsBitmap = true;
                    
                    if (navigator.skin is IVisualElementContainer)
                    {
                        cachedActionBar.depth = IVisualElementContainer(navigator.skin).numElements - 1;
                        IVisualElementContainer(navigator.skin).addElementAt(cachedActionBar, IVisualElementContainer(navigator.skin).numElements - 1);
                    }
                    else
                        navigator.skin.addChild(cachedActionBar);
                    
                    targets.push(cachedActionBar);
                }
                
                if (componentIsVisible(actionBar))
                    targets.push(actionBar);
            }
            
            actionBarExplicitIncludeInLayout = navigator.actionBar.includeInLayout;
            navigator.actionBar.includeInLayout = false;
        }
        
        if (navigator.contentGroup)
        {
            contentGroupExplicitIncludeInLayout = navigator.contentGroup.includeInLayout;
            navigator.contentGroup.includeInLayout = false;
        }
		
        if (tabBar)
        {
            tabBarExplicitIncludeInLayout = tabBar.includeInLayout;
            tabBar.includeInLayout = false;
            
            if (cachedTabBar)
            {
                if (navigator.skin is IVisualElementContainer)
                {
                    cachedTabBar.depth = IVisualElementContainer(navigator.skin).numElements - 1;
                    IVisualElementContainer(navigator.skin).addElementAt(cachedTabBar, IVisualElementContainer(navigator.skin).numElements - 1);
                }
                else
                    navigator.skin.addChild(cachedTabBar);
                
                targets.push(cachedTabBar);
                tabBar.x = (direction == SLIDE_LEFT) ? navigator.width : -navigator.width;
                targets.push(tabBar);
            }
            else if (tabBarWasVisible != tabBar.visible)
            {
                tabBar.x = (direction == SLIDE_LEFT) ? navigator.width : -navigator.width;
                targets.push(tabBar);
            }
        }
		
		// Create view animations
		Parallel(effect).addChild(createViewAnimations(targets));
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
     */
    override public function transitionComplete(event:EffectEvent=null):void
    {
        event.target.removeEventListener(EffectEvent.EFFECT_END, transitionComplete);
        
        if (currentView)
        {
            currentView.includeInLayout = true;
            currentView.cacheAsBitmap = false;
        }
        
        if (nextView)
        {
            nextView.includeInLayout = true;
            nextView.cacheAsBitmap = false;
        }
        
        if (doInternalActionBarAnimation)
        {
            if (actionBar.titleGroup)
                actionBar.titleGroup.cacheAsBitmap = false;
            
            if (cachedTitleGroup)
            {
                if (actionBar.skin is IVisualElementContainer)
                    IVisualElementContainer(actionBar.skin).removeElement(cachedTitleGroup);
                else
                    actionBar.skin.removeChild(cachedTitleGroup);
                
                cachedTitleGroup = null;
            }
            
            if (cachedNavigationGroup)
            {
                if (actionBar.skin is IVisualElementContainer)
                    IVisualElementContainer(actionBar.skin).removeElement(cachedNavigationGroup);
                else
                    actionBar.skin.removeChild(cachedNavigationGroup);
                
                actionBar.navigationGroup.cacheAsBitmap = false;
                cachedNavigationGroup = null;
            }
            
            if (cachedActionGroup)
            {
                if (actionBar.skin is IVisualElementContainer)
                    IVisualElementContainer(actionBar.skin).removeElement(cachedActionGroup);
                else
                    actionBar.skin.removeChild(cachedActionGroup);
                
                actionBar.actionGroup.cacheAsBitmap = false;
                cachedActionGroup = null;
            }
        }
        else
        {
            if (cachedActionBar)
            {
                if (navigator.skin is IVisualElementContainer)
                    IVisualElementContainer(navigator.skin).removeElement(cachedActionBar)
                else
                    navigator.skin.removeChild(cachedActionBar);
                
                cachedActionBar = null;
            }
        }
        
        if (cachedTabBar)
        {
            if (navigator.skin is IVisualElementContainer)
                IVisualElementContainer(navigator.skin).removeElement(cachedTabBar);
            else
                navigator.skin.removeChild(cachedTabBar);
            
            cachedTabBar = null;
        }
        
        // Remove items from layout
        navigator.contentGroup.includeInLayout = contentGroupExplicitIncludeInLayout;
        
        if (actionBar)
            navigator.actionBar.includeInLayout = actionBarExplicitIncludeInLayout;
        
        if (tabBar)
            tabBar.includeInLayout = tabBarExplicitIncludeInLayout;

        // TODO (chiedozi): Comment why clean up happens before transitionComplete
        super.transitionComplete(event);
        effect = null;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     * @private
     * 
     * Creates the animations used to animate the content of the
     * action bar.  This method is only called if the slide transition
     * isn't doing a full action bar transition.
     * 
     * This method should add any effects it would like to play to
     * the effect object.
     * 
     * @param effect The parallel effect that will be played by the
     * slide animation
     */ 
    protected function appendActionBarAnimations(effect:Parallel):void
    {
        var childIndex:Number;
        var slideDistance:Number;
        var animatedProperty:String;
        
        var actionBarSkin:UIComponent = actionBar.skin;
        var titleGroup:Group = actionBar.titleGroup;
        
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
            if (actionBarSkin is IVisualElementContainer)
                IVisualElementContainer(actionBarSkin).addElementAt(cachedTitleGroup, actionBarSkin.getChildIndex(titleGroup) - 1);
            else
                actionBarSkin.addChildAt(cachedTitleGroup, actionBarSkin.getChildIndex(titleGroup) - 1);
        }
        
        // If a cache of the navigation group exists, that means the content
        // changed.  In this case the old and new display objects need to
        // be added to an effect. 
        if (cachedNavigationGroup)
        {
            childIndex = actionBarSkin.getChildIndex(actionBar.navigationGroup) - 1;
            actionBarSkin.addChildAt(cachedNavigationGroup, childIndex);
            
            fadeOutTargets.push(cachedNavigationGroup);
            
            actionBar.navigationGroup[animatedProperty] += slideDistance;
            actionBar.navigationGroup.cacheAsBitmap = true;
            actionBar.navigationGroup.alpha = 0;
            
            fadeInTargets.push(actionBar.navigationGroup);
        }
        
        if (cachedActionGroup)
        {
            childIndex = actionBarSkin.getChildIndex(actionBar.actionGroup) - 1;
            actionBarSkin.addChildAt(cachedActionGroup, childIndex);
            
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
     * 
     * Creates the animation used to transition the previous and new view.
     */
    private function createViewAnimations(targets:Array):IEffect
    {
        var slideDistance:Number;
        var effect:Move = new Move();
        
        effect.targets = targets;
        effect.duration = duration;
        
        switch(direction)
        {
            case SLIDE_LEFT:
                effect.xBy = -navigator.width;
                nextView.x = navigator.width;
                
                if (!doInternalActionBarAnimation && componentIsVisible(actionBar))
                    actionBar.x = navigator.width;
                break;
            
            case SLIDE_RIGHT:
                effect.xBy = navigator.width;
                nextView.x = -navigator.width;
                
                if (!doInternalActionBarAnimation && componentIsVisible(actionBar))
                    actionBar.x = -navigator.width;
                break;
        }
        
        return effect;
    }
    
    /**
     * @private
     * 
     * Convenience method for generating a bitmap of a component.
     * Returns a spark image.
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
     */
    private function componentIsVisible(component:UIComponent):Boolean
    {
        return component.visible && component.width > 0 && component.height > 0;
    }
}
}