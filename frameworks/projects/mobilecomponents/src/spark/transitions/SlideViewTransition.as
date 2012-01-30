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
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
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
        
        // Snapshot the entire navigator.
        var oldVisibility:Boolean = endView.visible;
        endView.visible = false;
        cachedNavigator = getSnapshot(targetNavigator, 0);
        endView.visible = oldVisibility;
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
            
            if (!(mode == SlideViewTransitionMode.COVER))
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
                
            if (!(mode == SlideViewTransitionMode.UNCOVER))
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
        if (!(mode == SlideViewTransitionMode.UNCOVER))
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
        
        if (!(mode == SlideViewTransitionMode.COVER))
            slideTargets.push(cachedNavigator);
        
        if (!(mode == SlideViewTransitionMode.UNCOVER))
            slideTargets.push(targetNavigator.contentGroup);

        navigatorProps.contentGroupIncludeInLayout = targetNavigator.contentGroup.includeInLayout;
        targetNavigator.contentGroup.includeInLayout = false;
        
        transitionGroup = new Group();
        transitionGroup.includeInLayout=false;
        
        // Ensure the views are in the right stacking order based on our
        // transition mode (cover vs. uncover for instance).
        if (mode == SlideViewTransitionMode.COVER)
        {
            var childIndex:uint = targetNavigator.skin.getChildIndex(targetNavigator.contentGroup);
            addComponentToContainerAt(transitionGroup, targetNavigator.skin, childIndex);
        }
        else
            addComponentToContainer(transitionGroup, targetNavigator.skin);
        
        if (targetNavigator is TabbedViewNavigator)
        {
            var tabBar:ButtonBarBase = TabbedViewNavigator(targetNavigator).tabBar;
            
            if (tabBar)
            {
                if (!(mode == SlideViewTransitionMode.UNCOVER))
                    slideTargets.push(tabBar);
                navigatorProps.tabBarIncludeInLayout = tabBar.includeInLayout;
                tabBar.includeInLayout = false;
            }
        }
        else if (targetNavigator is ViewNavigator)
        {
            if (actionBar)
            {
                if (!(mode == SlideViewTransitionMode.UNCOVER))
                    slideTargets.push(actionBar);
                
                navigatorProps.actionBarIncludeInLayout = actionBar.includeInLayout;
                actionBar.includeInLayout = false;
                
                navigatorProps.actionBarCacheAsBitmap = actionBar.cacheAsBitmap;
                actionBar.cacheAsBitmap = true;
            }
        }
        
        if (endView.contentGroup)
        {
            navigatorProps.endViewIncludeInLayout = endView.contentGroup.includeInLayout;
            endView.contentGroup.includeInLayout = false;
            
            navigatorProps.endViewCacheAsBitmap = endView.contentGroup.cacheAsBitmap;
            endView.contentGroup.cacheAsBitmap = true;
        }
        
        if (cachedNavigator)
        {
            cachedNavigator.includeInLayout = false;
            transitionGroup.addElement(cachedNavigator);
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
                        
        // Position the control bars prior to our transition.
        
        if (targetNavigator == parentNavigator)
        {
            if (targetNavigator is TabbedViewNavigator)
            {
                tabBar = TabbedViewNavigator(targetNavigator).tabBar;
                
                if (tabBar && !(mode == SlideViewTransitionMode.UNCOVER))
                    tabBar[animatedProperty] = -slideDistance;
            }
        }
        else
        {
            if (targetNavigator is ViewNavigator && actionBar && (!(mode == SlideViewTransitionMode.UNCOVER)))
                actionBar[animatedProperty] = -slideDistance;
        }
        
        if (!(mode == SlideViewTransitionMode.UNCOVER))
           targetNavigator.contentGroup[animatedProperty] = -slideDistance + targetNavigator.contentGroup[animatedProperty];
                
        // Validate to ensure our snapshots are rendered.
        transitionGroup.validateNow();
        
        // Construct animation sequence.
        var animation:Move = new Move();
        if (verticalTransition)
            animation.yBy = slideDistance;
        else
            animation.xBy = slideDistance;
        animation.targets = slideTargets;
        animation.easer = easer;
        animation.duration = duration;
        return animation;
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
            if (targetNavigator is TabbedViewNavigator)
            {
                var tabBar:ButtonBarBase = TabbedViewNavigator(targetNavigator).tabBar;
                
                if (tabBar)
                    tabBar.includeInLayout = navigatorProps.tabBarIncludeInLayout;
            }
            else if (targetNavigator is ViewNavigator)
            {
                if (actionBar)
                {
                    actionBar.includeInLayout = navigatorProps.actionBarIncludeInLayout;
                    actionBar.cacheAsBitmap = navigatorProps.actionBarCacheAsBitmap;
                }
            }
            
            if (endView.contentGroup)
            {
                endView.contentGroup.includeInLayout = navigatorProps.endViewIncludeInLayout;
                endView.contentGroup.cacheAsBitmap = navigatorProps.endViewCacheAsBitmap;
            }
            
            if (transitionGroup)
                removeComponentFromContainer(transitionGroup, targetNavigator.skin);
        
            targetNavigator.contentGroup.includeInLayout = navigatorProps.contentGroupIncludeInLayout;
        }

        transitionGroup = null;
        cachedNavigator = null;
        
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
    
}
}
