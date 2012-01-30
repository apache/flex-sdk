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
    
import flash.geom.Point;

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
     *  Padding used to generate the actionbar bitmap.  This is needed so that
     *  drop shadows can be properly captured.
     */ 
    mx_internal var actionBarBitmapPadding:uint = 4;
    
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
    private var cachedActionBarGlobalPosition:Point;
    
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
    private var cachedTabBarGlobalPosition:Point;
    
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
    
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override public function captureStartValues():void
    {
        super.captureStartValues();
        
        // Initialize the property bag used to save some of our
        // properties that are then restored after the transition is over.
        navigatorProps = new Object(); 
        
        animateTabBar = false;
        
        if (tabBar && startView)
        {
            // Animate the tabBar if its overlayControls or visible property is toggled.
            animateTabBar = startView.overlayControls != endView.overlayControls ||
                            startView.tabBarVisible != endView.tabBarVisible;
        }
        
        // Snapshot the entire navigator or actionBar depending on the mode.
        if (mode != SlideViewTransitionMode.PUSH)
        {
            var oldVisibility:Boolean = endView.visible;
            endView.visible = false;
            
            if (targetNavigator is TabbedViewNavigator && !animateTabBar)
            {
                cachedNavigator = getSnapshot(targetNavigator.contentGroup, 0);
                cachedNavigator.x = targetNavigator.contentGroup.x;
                cachedNavigator.y = targetNavigator.contentGroup.y;
            }
            else                
                cachedNavigator = getSnapshot(targetNavigator, 0);
                
            endView.visible = oldVisibility;
        }
        else
        {
            cachedActionBar = getSnapshot(navigator.actionBar);
        }
        
        // Save the position of the action in global coordinates
		if (actionBar)
        	cachedActionBarGlobalPosition = getGlobalCoordinates(actionBar);
        
        // Cache the tab bar bitmap and location
        if (tabBar)
        {
            cachedTabBar = getSnapshot(TabbedViewNavigator(targetNavigator).tabBar);
            cachedTabBarGlobalPosition = getGlobalCoordinates(tabBar);
            navigatorProps.tabBarIncludeInLayout = tabBar.includeInLayout;
            navigatorProps.tabBarCacheAsBitmap = tabBar.cacheAsBitmap;
        }
        
        // Save navigator bounds
        navigatorProps.endViewIncludeInLayout = endView.includeInLayout;
        
        if (startView)
        {
            cachedStartViewGlobalPosition = getGlobalCoordinates(startView);
            navigatorProps.startViewIncludeInLayout = startView.includeInLayout;
            startView.includeInLayout = false;
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
        
        if (startView)
        {
            startViewProps = { includeInLayout:startView.includeInLayout,
                cacheAsBitmap:startView.cacheAsBitmap };
            
            startView.includeInLayout = false;
            startView.cacheAsBitmap = true;
            
            if (startView.contentGroup)
            {
                startViewProps.cgIncludeInLayout = startView.contentGroup.includeInLayout;
                startView.contentGroup.includeInLayout = false;
                
                startViewProps.cgCacheAsBitmap = startView.contentGroup.cacheAsBitmap;
                startView.contentGroup.cacheAsBitmap = true;
            }
            
            if (mode != SlideViewTransitionMode.COVER)
                slideTargets.push(startView);
        }
        
        if (endView)
        {
            endViewProps = { includeInLayout:endView.includeInLayout,
                cacheAsBitmap:endView.cacheAsBitmap };
            
            endView.includeInLayout = false;
            endView.cacheAsBitmap = true;
            
            if (endView.contentGroup)
            {
                endViewProps.cgIncludeInLayout = endView.contentGroup.includeInLayout;
                endView.contentGroup.includeInLayout = false;
                
                endViewProps.cgCacheAsBitmap = endView.contentGroup.cacheAsBitmap;
                endView.contentGroup.cacheAsBitmap = true;
            }
                
            if (mode != SlideViewTransitionMode.UNCOVER)
                slideTargets.push(endView);
            
            if (mode == SlideViewTransitionMode.UNCOVER)
                setComponentChildIndex(endView, navigator, 0);  
        }
        
        var slideDistance:Number;
        var slideOffset:Number = 0;
        var animatedProperty:String;
        var verticalTransition:Boolean;
        
        // Predetermine slide direction and distance.
        switch (direction)
        {                       
            case ViewTransitionDirection.DOWN:
                animatedProperty = "y";
                slideDistance = navigator.height;
                slideOffset = -navigator.contentGroup[animatedProperty];
                verticalTransition = true;
                break;
            
            case ViewTransitionDirection.UP:
                animatedProperty = "y";
                slideDistance = -navigator.height;
                slideOffset = navigator.contentGroup[animatedProperty];
                verticalTransition = true;
                break;
            
            case ViewTransitionDirection.RIGHT:
                animatedProperty = "x";
                slideDistance = navigator.width;
                break;
            
            case ViewTransitionDirection.LEFT:
            default:
                animatedProperty = "x";
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
        return animation;
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
        
        // Remove the navigator's contentGroup from layout
        navigatorProps.navigatorContentGroupIncludeInLayout = navigator.contentGroup.includeInLayout;
        navigator.contentGroup.includeInLayout = false;
        
        // Check if the navigator is a child of TabbedViewNavigator, if so
        // remove the contentGroup from layout.
        if (targetNavigator != navigator)
        {
            navigatorProps.topNavigatorContentGroupIncludeInLayout = targetNavigator.contentGroup.includeInLayout;
            targetNavigator.contentGroup.includeInLayout = false;
        }
        
        transitionGroup = new Group();
        transitionGroup.includeInLayout = false;
        
        // Add the necessary views to the slide targets array.  When in PUSH mode,
        // both start and end views are added.
        if (startView && mode == SlideViewTransitionMode.PUSH)
            slideTargets.push(startView);
        
        if (mode != SlideViewTransitionMode.UNCOVER)
            slideTargets.push(endView);
        
        // Ensure the views are in the right stacking order based on our
        // transition mode (cover vs. uncover for instance).
        if (mode == SlideViewTransitionMode.COVER)
        {
            // When doing a cover animation, the transition group is added to the bottom
            // of the main navigator's skin with a bitmap image of the previous state.  The
            // end view and ui controls will then animate on top of this image to create
            // the cover effect.
            addComponentToContainerAt(transitionGroup, targetNavigator.skin, 0);
            transitionGroup.addElement(cachedNavigator);
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
            
            var globalPoint:Point = getGlobalCoordinates(startView);
            
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
            navigatorProps.endViewIncludeInLayout = endView.includeInLayout;
            endView.includeInLayout = false;
            
            navigatorProps.endViewCacheAsBitmap = endView.contentGroup.cacheAsBitmap;
            endView.contentGroup.cacheAsBitmap = true;
        }
        
        if (cachedActionBar)
        {
            // Reposition the cached actionBar
            var localPos:Point = transitionGroup.globalToLocal(cachedActionBarGlobalPosition);
            
            // FIXME (chiedozi): Need to remove the 4 pixel buffer
            cachedActionBar.x = localPos.x - actionBarBitmapPadding;
            cachedActionBar.y = localPos.y - actionBarBitmapPadding;
            
            cachedActionBar.includeInLayout = false;
            transitionGroup.addElement(cachedActionBar);
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
                        // Need to removed the 4 pixel buffer
                        cachedTabBar.x = tabBar.x - actionBarBitmapPadding;
                        cachedTabBar.y = tabBar.y - actionBarBitmapPadding;
                    
                        cachedTabBar.includeInLayout = false;
                        transitionGroup.addElement(cachedTabBar);
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
                transitionGroup.addElement(cachedNavigator);
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
        // Restore original saved properties for includeInLayout and cacheAsBitmap.
        if (!consolidatedTransition)
        {
            if (startView)
            {
                startView.includeInLayout = startViewProps.includeInLayout;
                startView.cacheAsBitmap = startViewProps.cacheAsBitmap;
                
                if (startView.contentGroup)
                {
                    startView.contentGroup.includeInLayout = startViewProps.cgIncludeInLayout;
                    startView.contentGroup.cacheAsBitmap = startViewProps.cgCacheAsBitmap;
                }
                startViewProps = null;
            }
            
            if (endView)
            {
                endView.includeInLayout = endViewProps.includeInLayout;
                endView.cacheAsBitmap = endViewProps.cacheAsBitmap;
                
                if (endView.contentGroup)
                {
                    endView.contentGroup.includeInLayout = endViewProps.cgIncludeInLayout;
                    endView.contentGroup.cacheAsBitmap = endViewProps.cgCacheAsBitmap;
                }
                endViewProps = null;
            }
        }
        else
        {

            if (startView && mode == SlideViewTransitionMode.COVER)
            {
                startView.visible = startViewProps.visible;
            }
            
            if (tabBar)
            {
                tabBar.includeInLayout = navigatorProps.tabBarIncludeInLayout;
                tabBar.cacheAsBitmap = navigatorProps.tabBarCacheAsBitmap;
            }

            if (actionBar)
            {
                actionBar.includeInLayout = navigatorProps.actionBarIncludeInLayout;
                actionBar.cacheAsBitmap = navigatorProps.actionBarCacheAsBitmap;
            }
            
            if (startView)
            {
                startView.includeInLayout = navigatorProps.startViewIncludeInLayout;
                startView.contentGroup.cacheAsBitmap = navigatorProps.startViewCacheAsBitmap;
                startView.setLayoutBoundsPosition(navigatorProps.startViewX, navigatorProps.startViewY);
            }
            
            if (endView)
            {
                endView.includeInLayout = navigatorProps.endViewIncludeInLayout;
                endView.contentGroup.cacheAsBitmap = navigatorProps.endViewCacheAsBitmap;
            }
            
            if (targetNavigator != navigator)
                targetNavigator.contentGroup.includeInLayout = navigatorProps.topNavigatorContentGroupIncludeInLayout;
            
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
        }

        transitionGroup = null;
        cachedNavigator = null;
        cachedActionBar = null;
        cachedActionBarGlobalPosition = null;
        cachedTabBar = null;
        cachedTabBarGlobalPosition = null;
        
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
        super.prepareForPlay();
    }
    
    /**
     *  @private
     *  Utility function that converts a components position to global coordinates
     *  using its parent.
     */
    private function getGlobalCoordinates(component:IVisualElement):Point
    {
        return component.parent.localToGlobal(new Point(component.x, component.y));
    }
    
}
}
