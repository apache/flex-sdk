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
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.geom.Point;

import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.effects.Fade;
import mx.effects.IEffect;
import mx.effects.Parallel;

import spark.components.Group;
import spark.effects.Scale;
import spark.primitives.BitmapImage;

use namespace mx_internal;

/**
 *  The ZoomViewTransition class performs a zoom in or out transition for views.
 *  It performs its transition by zooming out the existing view to reveal
 *  the new view, or by zooming in the new view to cover the existing view. 
 * 
 *  <p>The default duration of a ZoomViewTransition is 350ms.  
 *  Also, by default it transitions the control bar and view content
 *  as one as if <code>transitionControlsWithContent</code> is  <code>true</code>. </p>
 *
 *  <p><strong>Note:</strong>Create and configure view transitions in ActionScript;
 *  you cannot create them in MXML.</p>
 *
 *  @see ZoomViewTransitionMode
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Deprecated(since="4.6")] 
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
    private var startViewProps:Object;
    
    /**
     *  @private
     *  Property bag used to save any end view properties that 
     *  are then restored after the transition is complete.
     */
    private var endViewProps:Object;
    
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
    private var scaleEffect:Scale;
    
    /**
     *  @private
     */
    private var targetSnapshot:BitmapImage;
    
    /**
     *  @private
     *  Stores the location of the cached navigator in the global coordinate space
     *  so that the transition can properly position it when added to the display list.
     */ 
    private var targetSnapshotGlobalPosition:Point = new Point();
    
    /**
     *  @private
     */
    private var cachedNavigatorGroup:Group;
    
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
    
    private var _mode:String = "out"; // avoid deprecation warning for ZoomViewTransitionMode.OUT;
    
    [Inspectable(category="General", enumeration="in,out", defaultValue="out")]
    /**
     *  Specifies the type of zoom transition to perform.
     *
     *  @default ZoomTransitionMode.OUT
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
        // Suppress the default action bar transition, not really 
        // appropriate for the zoom.
        actionBarTransitionMode = ViewTransitionBase.ACTION_BAR_MODE_NONE;
        
        super.captureStartValues();
        
        var oldVisibility:Boolean = endView.visible;
        endView.visible = false;
        cachedNavigator = getSnapshot(targetNavigator, 0, cachedNavigatorGlobalPosition);
        endView.visible = oldVisibility;
    }
    
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override public function captureEndValues():void
    {       
        super.captureEndValues();
        
        // Set targetSnapshot to the snapshot that we will be
        // transitioning in or out.
        if (consolidatedTransition)
        {
            if (mode == "out") // avoid deprecation warning for ZoomViewTransitionMode.OUT
            {
                targetSnapshot = cachedNavigator;
                targetSnapshotGlobalPosition = cachedNavigationGroupGlobalPosition.clone();
            }
            else
            {
                targetSnapshot = getSnapshot(targetNavigator.skin, 0, targetSnapshotGlobalPosition);
            }
        }
        else
        {
            if (mode == "out") // avoid deprecation warning for ZoomViewTransitionMode.OUT
            {
                targetSnapshot = getSnapshot(startView, 0, targetSnapshotGlobalPosition);
            }
            else
            {
                targetSnapshot = getSnapshot(endView, 0, targetSnapshotGlobalPosition);
            }
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
        // Add a group to contain targetSnapshot.
        transitionGroup = new Group();
        transitionGroup.includeInLayout = false;
        addComponentToContainer(transitionGroup, DisplayObjectContainer(navigator) as UIComponent);
        
        // Disable layout and visibility of our start view as necessary
        if (startView)
        {
            startViewProps = {includeInLayout:startView.includeInLayout, 
                visible:startView.visible};
            startView.includeInLayout = false;
            
            if (mode == "out") // avoid deprecation warning for ZoomViewTransitionMode.OUT
                startView.visible = false;
        }
        
        // Disable layout and visibility of our start end as necessary
        if (endView)
        {
            endViewProps = {includeInLayout:endView.includeInLayout,
                visible:endView.visible};
            endView.includeInLayout = false;
            
            if (mode == "in") // avoid deprecation warning for ZoomViewTransitionMode.IN
                endView.visible = false;
        }
        
        if (targetSnapshot)
            addCachedElementToGroup(transitionGroup, targetSnapshot, targetSnapshotGlobalPosition);
        
        transitionGroup.validateNow();
 
        // Initialize our target's transform center.
        transitionGroup.transformX = endView.width / 2;
        transitionGroup.transformY = endView.height / 2;
        
        // Ensure our alpha is initialized to 0 prior to the start
        // of our transition so that the view isn't displayed briefly
        // after validation.
        if (mode == "in") // avoid deprecation warning for ZoomViewTransitionMode.IN
            transitionGroup.alpha = 0;
        
        // Set our blendMode to 'normal' for performance reasons.
        transitionGroup.blendMode = BlendMode.NORMAL;
        
        return createZoomEffect(transitionGroup);
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
        // If we have no cachedNavigator then there is not much we can do.
        if (!cachedNavigator && mode == "out") // avoid deprecation warning for ZoomViewTransitionMode.OUT
            return null;
        
        // Add a group to contain our snapshot view of the original navigator.
        cachedNavigatorGroup = new Group();
        cachedNavigatorGroup.includeInLayout = false;

        // On zoom out, place the cachedNavigator above the targetNavigator 
        var index:int = getComponentChildIndex(targetNavigator, targetNavigator.parent as UIComponent);
        if (mode == "out") // avoid deprecation warning for ZoomViewTransitionMode.OUT
            index++;
        addComponentToContainerAt(cachedNavigatorGroup, DisplayObjectContainer(targetNavigator).parent as UIComponent, index);

        cachedNavigator.includeInLayout = false;
        addCachedElementToGroup(cachedNavigatorGroup, cachedNavigator, cachedNavigatorGlobalPosition);

        // Add our temporary transition group to our target navigator's parent
        // so we can make it and the original navigator siblings.
        if (mode == "out") // avoid deprecation warning for ZoomViewTransitionMode.OUT
        {
            // We'll be zooming out our cachedNavigatorGroup.
            transitionGroup = cachedNavigatorGroup;
        }
        else
        {
            transitionGroup = new Group();
            transitionGroup.includeInLayout = false;
            
            // We'll be zooming in our snapshot of the new navigator. Host our 
            // snapshot and make sure it's rendered.
            cachedNavigatorGroup.addElement(transitionGroup);
            addCachedElementToGroup(transitionGroup, targetSnapshot, targetSnapshotGlobalPosition);
            cachedNavigatorGroup.validateNow();
            
            // Hide our real navigator.
            endViewProps = {visible:targetNavigator.skin.visible}
            targetNavigator.skin.visible = false;
        }

        transitionGroup.validateNow();

        // Initialize our target's transform center.
        transitionGroup.transformX = cachedNavigator.getLayoutBoundsWidth(true) / 2 + targetNavigator.getLayoutBoundsX(true);
        transitionGroup.transformY = cachedNavigator.getLayoutBoundsHeight(true) / 2 + targetNavigator.getLayoutBoundsY(true);
        
        // Ensure our alpha is initialized to 0 prior to the start
        // of our transition so that the view isn't displayed briefly
        // after validation.
        if (mode == "in") // avoid deprecation warning for ZoomViewTransitionMode.IN
            transitionGroup.alpha = 0;
        
        // Set our blendMode to 'normal' for performance reasons.
        transitionGroup.blendMode = BlendMode.NORMAL;
        
        return createZoomEffect(transitionGroup);
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
        if (!consolidatedTransition)
        {
            if (startView)
            {
                startView.includeInLayout = startViewProps.includeInLayout;
                startView.visible = startViewProps.visible;
            }
            
            if (endView)
            {
                endView.includeInLayout = endViewProps.includeInLayout;
                endView.visible = endViewProps.visible;;
            }
            
            if (transitionGroup)
                removeComponentFromContainer(transitionGroup, UIComponent(DisplayObjectContainer(navigator))); 
        }
        else
        {
            if (cachedNavigatorGroup)
                removeComponentFromContainer(cachedNavigatorGroup, UIComponent(DisplayObjectContainer(targetNavigator).parent));
            
            if (endViewProps)
                targetNavigator.skin.visible = endViewProps.visible;
        }
        
        transitionGroup = null;
        cachedNavigator = null;
        cachedNavigatorGroup = null;
        endViewProps = null;
        startViewProps = null;
        
        scaleEffect.removeEventListener("effectUpdate", scaleEffectUpdateHandler);
        scaleEffect = null;
        
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
        fadeEffect.duration = (mode == "in") ? // avoid deprecation warning for ZoomViewTransitionMode.IN
            duration * .4 : duration * .6;
        if (mode == "out") // avoid deprecation warning for ZoomViewTransitionMode.OUT
            fadeEffect.startDelay = duration * .4;
        fadeEffect.alphaTo = (mode == "out") ? // avoid deprecation warning for ZoomViewTransitionMode.OUT
            0 : 1;
        fadeEffect.alphaFrom = (mode == "out") ? // avoid deprecation warning forZoomViewTransitionMode.OUT 
            1 : 0;
        
        // Create scale effect to zoom in/our our target from or to our 
        // specified minimum scale.
        scaleEffect = new Scale();
        scaleEffect.duration = duration;
        scaleEffect.easer = easer;
        scaleEffect.scaleXFrom = scaleEffect.scaleYFrom = 
            (mode == "out") ? // avoid deprecation warning for ZoomViewTransitionMode.OUT
            1 : minimumScale;
        scaleEffect.scaleXTo = scaleEffect.scaleYTo = 
            (mode == "out") ? // avoid deprecation warning for ZoomViewTransitionMode.OUT
            minimumScale : 1;
        scaleEffect.addEventListener("effectUpdate", scaleEffectUpdateHandler);
        
        parallel.addChild(fadeEffect);
        parallel.addChild(scaleEffect);
        
        return parallel;    
    }
    
    /**
     *  @private
     *  Ensures transform matrix is updated even if layout is disabled.
     */ 
    private function scaleEffectUpdateHandler(e:Event):void
    {
        transitionGroup.validateDisplayList();
    }
    
}
}
