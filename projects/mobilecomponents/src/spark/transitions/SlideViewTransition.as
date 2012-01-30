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

package spark.transitions
{
    
import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.effects.IEffect;

import spark.components.ActionBar;
import spark.components.Group;
import spark.components.TabbedViewNavigator;
import spark.components.ViewNavigator;
import spark.components.supportClasses.ButtonBarBase;
import spark.components.supportClasses.ViewNavigatorBase;
import spark.effects.Animate;
import spark.effects.Move;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;
import spark.primitives.BitmapImage;

use namespace mx_internal;
    
/**
 *  The SlideViewTransition class performs a simple slide transition for views.
 *  The existing view slides out as the new view slides in.
 *  The slide transition supports several modes (push, cover, and
 *  uncover) as well as an optional direction (up, down, left, or right).
 *
 *  <p><strong>Note:</strong>Create and configure view transitions in ActionScript;
 *  you cannot create them in MXML.</p>
 *
 *  @see SlideViewTransitionMode
 *  @see ViewTransitionDirection
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class SlideViewTransition extends ViewTransitionBase
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function SlideViewTransition()
    {
        super();
        
        // Defaut duration of 300 yields a smooth result.
        duration = 300;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Flag used to indicate whether the tab bar should animate in or out.
     */ 
    private var animateTabBar:Boolean = false;
    
    /**
     *  @private
     *  Bitmap image of the action bar before it is updated with the properties
     *  of the new view.  This snapshot is leveraged by this transition when
     *  doing a full screen animation.
     */
    private var cachedActionBar:BitmapImage;
    
    /**
     *  @private
     *  Stores the location of the action bar in the global coordinate space
     *  so that the transition can properly position the cached actionbar
     *  when added to the display list.
     */ 
    private var cachedActionBarGlobalPosition:Point = new Point();
    
    /**
     *  @private
     *  Variable used to store the startView's initial global position to
     *  determine how much it needs to be shifted before a consolidated
     *  transition runs.
     */ 
    private var cachedStartViewGlobalPosition:Point;
    
    /**
     *  @private
     *  Bitmap image of the tab bar before it is updated with the properties
     *  of the new view.  This snapshot is leveraged by this transition when
     *  doing a full screen animation.
     */
    private var cachedTabBar:BitmapImage;
    
    /**
     *  @private 
     *  Stores the location of the action bar in the global coordinate space
     *  so that the transition can properly position the cached actionbar
     *  when added to the display list.
     */
    private var cachedTabBarGlobalPosition:Point = new Point();
    
    /**
     *  @private
     *  Property bag used to save any start view properties that 
     *  are then restored after the transition is complete.
     */
    private var startViewProps:Object;
    
    /**
     *  @private
     *  Property bag used to save any end view properties that 
     *  are then restored after the transition is complete.
     */
    private var endViewProps:Object;
    
    /**
     *  @private
     *  Property bag used to save any navigator centric properties that 
     *  are then restored after the transition is complete.
     */
    private var navigatorProps:Object;
    
    /**
     *  @private
     */
    private var transitionGroup:Group;
    
    /**
     *  @private
     *  Indicates whether the end view needs explicit validations during the 
     *  transition, which will be the case when the view is in advanced 
     *  layout mode.
     */ 
    private var endViewNeedsValidations:Boolean;
    
    /**
     *  @private
     *  Indicates whether the start view needs explicit validations during the 
     *  transition, which will be the case when the view is in advanced 
     *  layout mode.
     */ 
    private var startViewNeedsValidations:Boolean;
    
    /**
     *  @private
     */ 
    private var moveEffect:Move;
    
    /**
     *  @private
     */ 
    private var consolidatedEffect:Animate;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //---------------------------------
    // direction
    //---------------------------------
    
    private var _direction:String = ViewTransitionDirection.LEFT;
    
    [Inspectable(category="General", enumeration="left,right,up,down", defaultValue="left")]
    /**
     *  Specifies the direction of slide transition.
     *
     *  @default ViewTransitionDirection.LEFT
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get direction():String
    {
        return _direction;
    }
    
    /**
     *  @private
     */ 
    public function set direction(value:String):void
    {
        _direction = value;
    }
    
    //---------------------------------
    // mode
    //---------------------------------
    
    private var _mode:String = SlideViewTransitionMode.PUSH;
    
    [Inspectable(category="General", enumeration="push,cover,uncover", defaultValue="push")]
    /**
     *  Specifies the type of slide transition to perform.
     *
     *  @default SlideViewTransitionMode.PUSH
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get mode():String
    {
        return _mode;
    }
    
    /**
     *  @private
     */ 
    public function set mode(value:String):void
    {
        _mode = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    override mx_internal function preInit():void
    {
        if (mode == SlideViewTransitionMode.UNCOVER)
            setComponentChildIndex(endView, navigator, 0);
    }

    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override public function captureStartValues():void
    {
        var p:Point;
        
        super.captureStartValues();
        
        // Initialize the property bag used to save some of our
        // properties that are then restored after the transition is over.
        navigatorProps = new Object(); 
        navigatorProps.initialHeight = navigator.height;
        
        // Determine if we will be animating the tabBar as part of the
        // transition
        animateTabBar = false;
        
        if (tabBar && startView)
        {
            // Animate the tabBar if its overlayControls or visible property is toggled.
            animateTabBar = startView.overlayControls != endView.overlayControls ||
                            startView.tabBarVisible != endView.tabBarVisible;
        }
        
        // Generate initial bitmaps for the transition.  If the transition will be
        // a push type, we only need to cache the actionBar as we will animate the
        // views in manually.  If its cover or uncover, an entire image of the navigator
        // is needed.
        if (mode != SlideViewTransitionMode.PUSH)
        {
            var oldVisibility:Boolean = endView.visible;
            endView.visible = false;
            
            if (tabBar && !animateTabBar)
                cachedNavigator = getSnapshot(targetNavigator.contentGroup, 0, cachedNavigatorGlobalPosition);
            else                
                cachedNavigator = getSnapshot(targetNavigator, 0, cachedNavigatorGlobalPosition);
                
            endView.visible = oldVisibility;
        }
        else
        {
            cachedActionBar = getSnapshot(navigator.actionBar, 4, cachedActionBarGlobalPosition);
        }
        
        // If the tabBar exists, a bitmap image of it is created
        if (tabBar)
        {
            cachedTabBar = getSnapshot(TabbedViewNavigator(parentNavigator).tabBar, 4, cachedTabBarGlobalPosition);
            navigatorProps.tabBarIncludeInLayout = tabBar.includeInLayout;
            navigatorProps.tabBarCacheAsBitmap = tabBar.cacheAsBitmap;
        }
        
        if (startView)
        {
            startViewProps = {  includeInLayout: startView.includeInLayout,
                                visible: startView.visible,
                                cacheAsBitmap: startView.cacheAsBitmap,
                                opaqueBackground: startView.opaqueBackground };
            
            // Remove the startView from layout so that it doesn't resize as the 
            // contentGroups of each navigator is resized
            startView.includeInLayout = false;
            cachedStartViewGlobalPosition = getTargetNavigatorCoordinates(startView);
        }
    }
    
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override protected function createViewEffect():IEffect
    {   
        // Prepare our start and end views by positioning them prior to 
        // the start of our transition, ensuring that they are cached as 
        // surfaces, and adjust z-order if necessary.

        var slideTargets:Array = new Array();
        
        endViewNeedsValidations = false;
        startViewNeedsValidations = false;
        
        if (startView)
        {
            // Store the original x and y position of the view so that we can restore
            // it after the animation
            startViewProps.x = startView.x,
            startViewProps.y = startView.y;
            
            startView.cacheAsBitmap = true;
            
            // If the startView has an opaque background color, set that as the 
            // opaqueBackground property to improve performance.
            if (startView.getStyle("backgroundAlpha") >= 1)
                startView.opaqueBackground = startView.getStyle("backgroundColor");
            
            if (startView.contentGroup)
            {
                startViewProps.cgIncludeInLayout = startView.contentGroup.includeInLayout;
                startView.contentGroup.includeInLayout = false;
            }
            
            if (mode != SlideViewTransitionMode.COVER)
            {
                if (startView.transformRequiresValidations())
                    startViewNeedsValidations = true;
                slideTargets.push(startView);
            }
        }
        
        if (endView)
        {
            endViewProps = { cacheAsBitmap:endView.cacheAsBitmap,
                             opaqueBackground:endView.opaqueBackground};
            
            endView.cacheAsBitmap = true;

            // If the endView has an opaque background color, set that as the 
            // opaqueBackground property to improve performance.
            if (endView.getStyle("backgroundAlpha") >= 1)
                endView.opaqueBackground = endView.getStyle("backgroundColor");
            
            if (endView.contentGroup)
            {
                endViewProps.cgIncludeInLayout = endView.contentGroup.includeInLayout;
                endView.contentGroup.includeInLayout = false;
            }
                
            if (mode != SlideViewTransitionMode.UNCOVER)
            {
                if (endView.transformRequiresValidations())
                    endViewNeedsValidations = true;
                slideTargets.push(endView);
            }
            
//            if (mode == SlideViewTransitionMode.UNCOVER)
//                setComponentChildIndex(endView, navigator, 0);
        }
        
        var slideDistance:Number;
        var slideOffset:Number = 0;
        var animatedProperty:String;
        var verticalTransition:Boolean;
        
        // Predetermine slide direction and distance.
        switch (direction)
        {                       
            case ViewTransitionDirection.DOWN:
                animatedProperty = "$y";
                slideDistance = navigator.height;
                slideOffset = -navigator.contentGroup[animatedProperty];
                verticalTransition = true;
                break;
            
            case ViewTransitionDirection.UP:
                animatedProperty = "$y";
                slideDistance = -navigator.height;
                slideOffset = navigator.contentGroup[animatedProperty];
                verticalTransition = true;
                break;
            
            case ViewTransitionDirection.RIGHT:
                animatedProperty = "$x";
                slideDistance = navigator.width;
                break;
            
            case ViewTransitionDirection.LEFT:
            default:
                animatedProperty = "$x";
                slideDistance = -navigator.width;
                break;
        }
        
        // Position the end view prior to start of transition.
        if (mode != SlideViewTransitionMode.UNCOVER)
            endView[animatedProperty] = -slideDistance - slideOffset;
        
        // Construction animation sequence.
        var animation:Move = new Move();
        animation.targets = slideTargets;
        animation.duration = duration;
        animation.easer = easer;
        if (verticalTransition)
            animation.yBy = slideDistance + slideOffset;
        else
            animation.xBy = slideDistance + slideOffset;
        if (startViewNeedsValidations || endViewNeedsValidations)
            animation.addEventListener("effectUpdate", effectUpdateHandler);
        moveEffect = animation;
        return animation;
    }
        
    private function effectUpdateHandler(e:Event):void
    {
        // Note that the calls to validateDisplayList here should
        // really only result in validateMatrix, which is fairly
        // lightweight.
        if (startViewNeedsValidations)
            startView.validateDisplayList();
        if (endViewNeedsValidations)
            endView.validateDisplayList();
    }
    
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override protected function createConsolidatedEffect():IEffect
    {        
        // Prepare our start and end view elements by positioning them prior to 
        // the start of our transition, ensuring that they are cached as 
        // surfaces, and adjust z-order if necessary.
        var slideTargets:Array = new Array();
        
        endViewNeedsValidations = false;
        startViewNeedsValidations = false;
        
        // Remove the navigator's contentGroup from layout
        navigatorProps.navigatorContentGroupIncludeInLayout = navigator.contentGroup.includeInLayout;
        navigator.contentGroup.includeInLayout = false;
        
        // Check if the navigator is a child of TabbedViewNavigator, if so
        // remove the contentGroup from layout.
        if (tabBar)
        {
            navigatorProps.topNavigatorContentGroupIncludeInLayout = targetNavigator.contentGroup.includeInLayout;
            targetNavigator.contentGroup.includeInLayout = false;
        }
        
        transitionGroup = new Group();
        transitionGroup.includeInLayout = false;
        
        // Add the necessary views to the slide targets array.  When in PUSH mode,
        // both start and end views are added.
        if (startView && mode == SlideViewTransitionMode.PUSH)
        {
            if (startView.transformRequiresValidations())
                startViewNeedsValidations = true;
            slideTargets.push(startView);
        }
        
        if (mode != SlideViewTransitionMode.UNCOVER)
        {
            if (endView.transformRequiresValidations())
                endViewNeedsValidations = true;
            slideTargets.push(endView);
        }
        
        // Ensure the views are in the right stacking order based on our
        // transition mode (cover vs. uncover for instance).
        if (mode == SlideViewTransitionMode.COVER)
        {
            // When doing a cover animation, the transition group is added to the bottom
            // of the main navigator's skin with a bitmap image of the previous state.  The
            // end view and ui controls will then animate on top of this image to create
            // the cover effect.
            addComponentToContainerAt(transitionGroup, targetNavigator.skin, 0);
            addCachedElementToGroup(transitionGroup, cachedNavigator, cachedNavigatorGlobalPosition);
        }
        else if (mode == SlideViewTransitionMode.UNCOVER)
        {
            // When doing an uncover transition, we want the real tabBar to be under the cached
            // bitmap of the original navigator when the tabBar visibility or overlayControls
            // mode changes.  When the tabBar isn't animating, we want the image to animate
            // underneath the real tabBar.
            if (animateTabBar)
                addComponentToContainer(transitionGroup, targetNavigator.skin);
            else
                addComponentToContainer(transitionGroup, navigator.skin);
            
            startView.visible = false;
        }
        else
        {
            // Add the transition group to the top of the skin
            addComponentToContainer(transitionGroup, targetNavigator.skin);
        }

        if (actionBar)
        {
            if (mode != SlideViewTransitionMode.UNCOVER)
                slideTargets.push(actionBar);
            
            navigatorProps.actionBarIncludeInLayout = actionBar.includeInLayout;
            actionBar.includeInLayout = false;
            
            navigatorProps.actionBarCacheAsBitmap = actionBar.cacheAsBitmap;
            actionBar.cacheAsBitmap = true;
        }
        
        if (mode == SlideViewTransitionMode.COVER)
        {
            // Hide the start view since we have a cached image of the initial
            // navigator state.
            startViewProps = {visible: startView.visible};
            startView.visible = false;
        }
        else if (startView)
        {
            // Store the position of the startView
            navigatorProps.startViewX = startView.x;
            navigatorProps.startViewY = startView.y;
            
            var globalPoint:Point = getTargetNavigatorCoordinates(startView);
            
            var delta:int = globalPoint.x - cachedStartViewGlobalPosition.x;
            if (delta != 0)
                startView.x -= delta;
            
            delta = globalPoint.y - cachedStartViewGlobalPosition.y;
            if (delta != 0)
                startView.y -= delta;
            
            navigatorProps.startViewCacheAsBitmap = startView.contentGroup.cacheAsBitmap;
            startView.contentGroup.cacheAsBitmap = true;
        }

        if (endView)
        {
            navigatorProps.endViewCacheAsBitmap = endView.contentGroup.cacheAsBitmap;
            endView.contentGroup.cacheAsBitmap = true;
        }
        
        if (cachedActionBar)
        {
            cachedActionBar.includeInLayout = false;
            addCachedElementToGroup(transitionGroup, cachedActionBar, cachedActionBarGlobalPosition);
        }
        
        if (tabBar)
        {
            // Cache the tabBar as bitmap for performance
            navigatorProps.tabBarCacheAsBitmap = tabBar.cacheAsBitmap;
            tabBar.cacheAsBitmap = true;
            
            if (animateTabBar)
            {
                navigatorProps.tabBarIncludeInLayout = tabBar.includeInLayout;
                tabBar.includeInLayout = false;
                
                if (mode != SlideViewTransitionMode.UNCOVER)
                {
                    slideTargets.push(tabBar);
                
                    // When Uncovering, the cachedTabBar is not needed because the transition
                    // animates a cachedBitamp
                    if (cachedTabBar)
                    {
                        cachedTabBar.includeInLayout = false;
                        addCachedElementToGroup(transitionGroup, cachedTabBar, cachedTabBarGlobalPosition);
                    }
                }
            }
        }
        
        var slideDistance:Number;
        var animatedProperty:String;
        var verticalTransition:Boolean;
        
        // Predetermine slide direction and distance.
        switch (direction)
        {           
            case ViewTransitionDirection.RIGHT:
                animatedProperty = "x";
                slideDistance = targetNavigator.width;
                break;
            
            case ViewTransitionDirection.DOWN:
                animatedProperty = "y";
                slideDistance = targetNavigator.height;
                verticalTransition = true;
                break;
            
            case ViewTransitionDirection.UP:
                animatedProperty = "y";
                slideDistance = -targetNavigator.height;
                verticalTransition = true;
                break;
            
            case ViewTransitionDirection.LEFT:
            default:
                animatedProperty = "x";
                slideDistance = -targetNavigator.width;
                break;
        }
        
        // Position the elements of the animation
        if (mode != SlideViewTransitionMode.UNCOVER)
        {
            endView[animatedProperty] = -slideDistance + endView[animatedProperty];
            
            if (actionBar)
                actionBar[animatedProperty] = -slideDistance + actionBar[animatedProperty];
            
            if (animateTabBar)
                tabBar[animatedProperty] = -slideDistance + tabBar[animatedProperty];
        }
        else
        {
            if (cachedNavigator)
            {
                cachedNavigator.includeInLayout = false;
                addCachedElementToGroup(transitionGroup, cachedNavigator, cachedNavigatorGlobalPosition);
            }
        }
        
        // Validate to ensure our snapshots are rendered.
        transitionGroup.validateNow();
        
        // Add the cached images to the display list.  This has to occur after the validation
        // so that the displayObjects for the bitmaps are created.  Otherwise the displayObject
        // property will be null.
        if (cachedActionBar && mode != SlideViewTransitionMode.COVER)
            slideTargets.push(cachedActionBar.displayObject);
        
        if (cachedTabBar && mode == SlideViewTransitionMode.PUSH)
            slideTargets.push(cachedTabBar.displayObject);
        
        if (cachedNavigator && mode == SlideViewTransitionMode.UNCOVER)
            slideTargets.push(cachedNavigator.displayObject);
        
        // Construct animation sequence.
        var animate:Animate = new Animate();
        var vector:Vector.<MotionPath> = new Vector.<MotionPath>();
        vector.push(new SimpleMotionPath(animatedProperty, null, null, slideDistance));
        animate.motionPaths = vector;
        animate.duration = duration;
        animate.easer = easer;
        animate.targets = slideTargets;
        if (startViewNeedsValidations || endViewNeedsValidations)
            animate.addEventListener("effectUpdate", effectUpdateHandler);
        consolidatedEffect = animate;
        return animate;
    }
    
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override protected function cleanUp():void
    {
        // Clear the scrollRect that the transition applied to the navigator
        if (navigatorProps.scrollRectSet)
            navigator.scrollRect = null;
            
        if (startView)
        {
            startView.includeInLayout = startViewProps.includeInLayout;
            startView.visible = startViewProps.visible;
            startView.cacheAsBitmap = startViewProps.cacheAsBitmap;
            startView.opaqueBackground = startViewProps.opaqueBackground;
        }

        // Restore original saved properties for includeInLayout and cacheAsBitmap.
        if (!consolidatedTransition)
        {
            if (startView)
            {
                startView.x = startViewProps.x;
                startView.y = startViewProps.y;
                
                if (startView.contentGroup)
                    startView.contentGroup.includeInLayout = startViewProps.cgIncludeInLayout;
            }
            
            if (endView)
            {
                endView.cacheAsBitmap = endViewProps.cacheAsBitmap;
                endView.opaqueBackground = endViewProps.opaqueBackground;
                
                if (endView.contentGroup)
                    endView.contentGroup.includeInLayout = endViewProps.cgIncludeInLayout;
                
                endViewProps = null;
            }
            
            if (moveEffect)
                moveEffect.removeEventListener("effectUpdate", effectUpdateHandler);
            moveEffect = null;
        }
        else
        {
            if (tabBar)
            {
                tabBar.includeInLayout = navigatorProps.tabBarIncludeInLayout;
                tabBar.cacheAsBitmap = navigatorProps.tabBarCacheAsBitmap;
                targetNavigator.contentGroup.includeInLayout = navigatorProps.topNavigatorContentGroupIncludeInLayout;
            }

            if (actionBar)
            {
                actionBar.includeInLayout = navigatorProps.actionBarIncludeInLayout;
                actionBar.cacheAsBitmap = navigatorProps.actionBarCacheAsBitmap;
            }
            
            if (startView)
            {
                startView.contentGroup.cacheAsBitmap = navigatorProps.startViewCacheAsBitmap;
                startView.setLayoutBoundsPosition(navigatorProps.startViewX, navigatorProps.startViewY);
                startView.visible = true;
            }
            
            if (endView)
            {
                endView.contentGroup.cacheAsBitmap = navigatorProps.endViewCacheAsBitmap;
            }
            
            navigator.contentGroup.includeInLayout = navigatorProps.navigatorContentGroupIncludeInLayout;
            
            if (transitionGroup)
            {
                if (mode == SlideViewTransitionMode.UNCOVER)
                {
                    if (animateTabBar)
                        removeComponentFromContainer(transitionGroup, targetNavigator.skin);
                    else
                        removeComponentFromContainer(transitionGroup, navigator.skin);
                        
                }
                else
                {
                    removeComponentFromContainer(transitionGroup, targetNavigator.skin);
                }
            }
            consolidatedEffect.removeEventListener("effectUpdate", effectUpdateHandler);
            consolidatedEffect = null;
        }

        transitionGroup = null;
        cachedNavigator = null;
        cachedActionBar = null;
        cachedTabBar = null;
        startViewProps = null;
        
        super.cleanUp();
    }
    
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override public function prepareForPlay():void
    {
        actionBarTransitionDirection = direction;
        applyScrollRect();
        
        super.prepareForPlay();
    }
    
    /**
     *  @private
     *  Utility function that converts a components position to the coordinate space
     *  of the targetNavigator.  This method doesn't use stage coordinates because
     *  that would return inaccurate results when dpi scaling is enabled.
     */
    private function getTargetNavigatorCoordinates(component:IVisualElement):Point
    {
        var stagePoint:Point = DisplayObject(component).localToGlobal(new Point());
        return targetNavigator.globalToLocal(stagePoint);
    }
    
    /**
     *  @private
     *  This method sets the scrollRect of the navigator that is being animated.
     *  An mx_internal method was created to avoid any issues that may arise by
     *  adding this functionality in the Flex 4.5.1 dot release.  Developers
     *  can override this method to do nothing to revert to previous implementations.
     *  This method was added to support clipping of Views during a view transition.
     */
    // TODO (chiedozi): Eventually get rid of this method
    mx_internal function applyScrollRect():void
    {
        // When the initial view of the animation has tabBarVisible set to false,
        // and the end view has it set to true, the height of the navigator
        // will be altered to fit the actionBar.  Since the startView is not included in
        // layout, its height will actually be larger than the navigator's.  To prevent
        // the start view from being incorrectly clipped, the scrollRect's height
        // is set to the maximum of the navigator's initial and current height.
        if (!navigator.scrollRect)
        {
            navigatorProps.scrollRectSet = true;
            navigator.scrollRect = new Rectangle(0, 0, navigator.width, Math.max(navigator.height, navigatorProps.initialHeight));
        }
    }
}
}
