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
    
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.effects.Fade;
import mx.effects.IEffect;
import mx.effects.Parallel;

import spark.components.Group;
import spark.effects.Scale;

use namespace mx_internal;

/**
 *  The ZoomViewTransition class serves as a zoom in/out transition 
 *  for views.  It performs its transition by zooming out the startView to reveal
 *  the endView, or by zooming in the new endView to cover the startView. 
 * 
 *  The default duration of a ZoomViewTransition is 350ms.  In addition, the 
 *  zoom transition by default transitions the control bar and view content
 *  as one (transitionControlsWithContent = true). There is no default action bar
 *  transition for the ZoomViewTransition.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class ZoomViewTransition extends ViewTransitionBase
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
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function ZoomViewTransition()
    {
        super();
        
        // Default duration of 350 yields a smoother result.
        duration = 350;
        
        // Default to transitioning control bars with our views.
        transitionControlsWithContent = true;
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
    private var startViewProps:Object = {};
    
    /**
     *  @private
     *  Property bag used to save any end view properties that 
     *  are then restored after the transition is complete.
     */
    private var endViewProps:Object = {};
    
    /**
     *  @private
     */
    private var transitionGroup:Group;
    
    /**
     *  @private
     */
    private var savedCacheAsBitmap:Boolean;
    
    /**
     *  @private
     */
    private var zoomTarget:UIComponent;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //---------------------------------
    // minimumScale
    //---------------------------------
    
    private var _minimumScale:Number = .25;
    
    /**
     *  Specifies the minimum scale of the zoomed view (represents when the 
     *  view is first visible when zooming in or last visible when zooming
     *  out).
     *
     *  @default .25
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get minimumScale():Number
    {
        return _minimumScale;
    }
    
    /**
     *  @private
     */ 
    public function set minimumScale(value:Number):void
    {
        _minimumScale = value;
    }
    
    //---------------------------------
    // mode
    //---------------------------------
    
    private var _mode:String = ZoomViewTransitionMode.OUT;
    
    /**
     *  Specifies the type of zoom transition to perform.
     *
     *  @default ZoomTransitionMode.OUT
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
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
     *  @inheritDoc
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override public function captureStartValues():void
    {       
        // Suppress the default action bar transition, not really 
        // appropriate for the zoom.
        actionBarTransitionMode = ViewTransitionBase.ACTION_BAR_MODE_NONE;
        
        super.captureStartValues();
        
        var oldVisibility:Boolean = endView.visible;
        endView.visible = false;
        cachedNavigator = getSnapshot(targetNavigator, 0);
        endView.visible = oldVisibility;
    }
    
    /**
     *  @inheritDoc
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override protected function createViewEffect():IEffect
    {
        // Disable layout for our start view.
        if (startView)
        {
            startViewProps = {includeInLayout:startView.includeInLayout};
            startView.includeInLayout = false;
        }
        
        // Disable layout for our end view, and ensure z-order of the views
        // is appropriate for our transition mode.
        if (endView)
        {
            endViewProps = {includeInLayout:endView.includeInLayout};
            endView.includeInLayout = false;
            
            if (mode == ZoomViewTransitionMode.OUT)
                setComponentChildIndex(endView, navigator, 0); 
        }
        
        zoomTarget = (mode == ZoomViewTransitionMode.OUT) ? startView : endView;
        
        // Initialize our target's transform center.
        zoomTarget.transformX = endView.width / 2;
        zoomTarget.transformY = endView.height / 2;
        
        // Ensure our alpha is initialized to 0 prior to the start
        // of our transition so that the view isn't displayed briefly
        // after validation.
        if (mode == ZoomViewTransitionMode.IN)
            zoomTarget.alpha = 0;
        
        // Set our blendMode to 'normal' for performance reasons.
        startViewProps.zoomTargetBlendMode = zoomTarget.blendMode;
        zoomTarget.blendMode = BlendMode.NORMAL;
        
        return createZoomEffect(zoomTarget);
    }
    
    /**
     *  @inheritDoc
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override protected function createConsolidatedEffect():IEffect
    {        
        // If we have no cachedNavigator then there is not much we can do.
        if (!cachedNavigator)
            return null;
        
        // Add a group to contain our snapshot view of the navigator while
        // we animate.
        transitionGroup = new Group();
        transitionGroup.includeInLayout = false;
        
        // Add our temporary transition group to our target navigator's parent
        // so we can make it and the original navigator siblings.
        if (mode == ZoomViewTransitionMode.OUT)
            addComponentToContainer(transitionGroup, DisplayObjectContainer(targetNavigator).parent as UIComponent);
        else
            addComponentToContainerAt(transitionGroup, DisplayObjectContainer(targetNavigator).parent as UIComponent,0);
        
        // Position our snapshot above endView.
        cachedNavigator.includeInLayout = false;
        transitionGroup.addElement(cachedNavigator);
    
        // Ensure that appropriate surfaces are cached and snapshots rendered.
        transitionGroup.validateNow();
        transitionGroup.x = transitionGroup.y = 0;
            
        zoomTarget = (mode == ZoomViewTransitionMode.OUT) ? transitionGroup : targetNavigator.skin;
        
        // Initialize our target's transform center.
        zoomTarget.transformX = cachedNavigator.width / 2;
        zoomTarget.transformY = cachedNavigator.height / 2;
        
        // Ensure our alpha is initialized to 0 prior to the start
        // of our transition so that the view isn't displayed briefly
        // after validation.
        if (mode == ZoomViewTransitionMode.IN)
            zoomTarget.alpha = 0;
                
        // Save view properties for restoration later.
        startViewProps = { targetNavigatorIncludeInLayout:targetNavigator.includeInLayout,
            zoomTargetBlendMode:zoomTarget.blendMode};
        
        // Disable layout for our target navigator.
        targetNavigator.includeInLayout = false;
        
        // Set our blendMode to 'normal' for performance reasons.
        zoomTarget.blendMode = BlendMode.NORMAL;
        
        return createZoomEffect(zoomTarget);
    }
    
    /**
     *  @inheritDoc
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override protected function cleanUp():void
    {
        if (!consolidatedTransition)
        {
            if (startView)
                startView.includeInLayout = startViewProps.includeInLayout;
                    
            if (endView)
                endView.includeInLayout = endViewProps.includeInLayout;
        }
        else
        {
            if (transitionGroup)
                removeComponentFromContainer(transitionGroup, UIComponent(DisplayObjectContainer(targetNavigator).parent));
            
            targetNavigator.includeInLayout = startViewProps.targetNavigatorIncludeInLayout;
        }
        
        if (zoomTarget)
        {
            zoomTarget.transformX = 0;
            zoomTarget.transformY = 0;
            zoomTarget.blendMode = startViewProps.zoomTargetBlendMode;
        }

        transitionGroup = null;
        cachedNavigator = null;

        super.cleanUp();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Shared helper routine which serves as our effect factory for both standard
     *  and consolidated transitions.
     */  
    protected function createZoomEffect(zoomTarget:Object):IEffect
    {
        // This will be a composite control, initialized with the appropriate target
        // depending on the transition mode (in/out).
        var parallel:Parallel = new Parallel;
        parallel.target = zoomTarget;

        // Create fade effect to gradually fade our zoom target, we don't fade for the
        // duration of the effect as this degrades overall transition performance, we
        // simply fade near the point of first appearance or disappearance.
        var fadeEffect:Fade = new Fade();
        fadeEffect.duration = (mode == ZoomViewTransitionMode.IN) ?  
            duration * .4 : duration * .6;
        if (mode == ZoomViewTransitionMode.OUT)
            fadeEffect.startDelay = duration * .4;
        fadeEffect.alphaTo = (mode == ZoomViewTransitionMode.OUT) ? 0 : 1;
        fadeEffect.alphaFrom = (mode == ZoomViewTransitionMode.OUT) ? 1 : 0;
            
        // Create scale effect to zoom in/our our target from or to our 
        // specified minimum scale.
        var scaleEffect:Scale = new Scale();
        scaleEffect.duration = duration;
        scaleEffect.easer = easer;
        scaleEffect.scaleXFrom = scaleEffect.scaleYFrom = 
            (mode == ZoomViewTransitionMode.OUT) ? 1 : minimumScale;
        scaleEffect.scaleXTo = scaleEffect.scaleYTo = 
            (mode == ZoomViewTransitionMode.OUT) ? minimumScale : 1;
        
        parallel.addChild(scaleEffect);
        parallel.addChild(fadeEffect);
        
        return parallel;    
    }
    
}
}
