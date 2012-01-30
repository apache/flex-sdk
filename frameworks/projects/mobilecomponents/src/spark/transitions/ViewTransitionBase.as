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
import flash.display.DisplayObjectContainer;
import flash.display.Stage;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.FlexGlobals;
import mx.core.IVisualElementContainer;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.effects.IEffect;
import mx.effects.Parallel;
import mx.events.EffectEvent;
import mx.events.FlexEvent;
import mx.geom.TransformOffsets;
import mx.managers.SystemManager;

import spark.components.ActionBar;
import spark.components.Group;
import spark.components.TabbedViewNavigator;
import spark.components.View;
import spark.components.ViewNavigator;
import spark.components.supportClasses.ButtonBarBase;
import spark.components.supportClasses.ViewNavigatorBase;
import spark.effects.Animate;
import spark.effects.Fade;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;
import spark.effects.easing.IEaser;
import spark.effects.easing.Sine;
import spark.primitives.BitmapImage;
import spark.utils.BitmapUtil;

use namespace mx_internal;

/**
 *  Dispatched when the transition starts.
 * 
 *  @eventType mx.events.FlexEvent.TRANSITION_START
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="transitionStart", type="mx.events.FlexEvent")]

/**
 *  Dispatched when the transition completes.
 * 
 *  @eventType mx.events.FlexEvent.TRANSITION_START
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="transitionEnd", type="mx.events.FlexEvent")]


/**
 *  The ViewTransitionBase class is the base class for all view transitions.  
 *  It is not intended to be used as a transition on its own.
 *  In addition to providing common convenience and helper methods used by 
 *  view transitions, this class provides a default action bar transition 
 *  sequence.
 * 
 *  <p>When a view transition is initialized, the owning view navigator 
 *  sets the <code>startView</code> and <code>endView</code> properties 
 *  to the views the transition animates. 
 *  The <code>navigator</code> property is 
 *  set to the view navigator.</p>
 * 
 *  <p>The lifecycle of a transition is as follows:</p>
 *    <ul>
 *      <li>The transition starts with 
 *        the <code>captureStartValues()</code> method.  
 *        When this method is called, the navigator is currently in the 
 *        start state.  
 *        At this time, the transition should capture any start values 
 *        or bitmaps that it requires. </li>
 *      <li>A validation pass is performed on the pending 
 *        view, and the <code>captureEndValues()</code> method is called. 
 *        At this time, the transition captures any properties or 
 *        bitmaps representations from the pending view.</li    >
 *      <li>The <code>prepareForPlay()</code> method is then called, 
 *        which allows the transition to perform any further preparations,
 *        such as preparing a Spark effects sequence, 
 *        or positioning transient elements on the display list.</li>
 *      <li>After a final validation pass, if necessary, 
 *        the <code>play()</code> method is called by the navigator 
 *        to perform the actual transition.</li>
 *      <li>Prior to any animation starting, the <code>start</code> 
 *        event is dispatched.</li>
 *      <li>When a transition completes, it dispatches an 
 *        <code>end</code> event.</li>
 *    </ul>
 *
 *  <p><strong>Note:</strong>Create and configure view transitions in ActionScript;
 *  you cannot create them in MXML.</p>
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class ViewTransitionBase extends EventDispatcher 
{
    
    //--------------------------------------------------------------------------
    //
    //  Constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constant used in tandem with the actionBarTransitionMode property to 
     *  hint the default action bar transition behavior.
     */
    mx_internal static const ACTION_BAR_MODE_FADE:String = "fade";
    
    /**
     *  Constant used in tandem with the actionBarTransitionMode property to 
     *  hint the default action bar transition behavior.
     */
    mx_internal static const ACTION_BAR_MODE_FADE_AND_SLIDE:String = "fadeAndSlide";
    
    /**
     *  Constant used in tandem with the actionBarTransitionMode property to 
     *  hint the default action bar transition behavior.
     */
    mx_internal static const ACTION_BAR_MODE_NONE:String = "none";
    
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
    public function ViewTransitionBase()
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
     *  Flag set when we've determined that we need to transition the navigator
     *  in its entirety and cannot transition the control bars independently.
     */
    protected var consolidatedTransition:Boolean = false;
    
    /**
     *  @private
     *  startView's action bar height.
     */ 
    private var cachedActionBarHeight:Number;
    
    /**
     *  @private
     *  startView's action bar width.
     */ 
    private var cachedActionBarWidth:Number;
    
    /**
     *  @private
     *  Transient display object used to hold temporary bitmap snapshots
     *  during transition.
     */ 
    private var transitionGroup:Group;
    
    /**
     *  @private
     *  Flag to assist with cleanup of any constructs used only for vertical
     *  transitions (e.g. clipping masks).
     */ 
    private var verticalTransition:Boolean;
    
    /**
     *  @private
     *  Flag used to determine whether the transition should wait a frame when
     *  it receives the EFFECT_END event.  This is true by default.  It is only
     *  set to false when the endTransitions() method is called.
     */ 
    private static var renderLastFrame:Boolean = true;
    
    /**
     *  @private
     *  Private vector that stores all the active transitions.
     */ 
    private static var activeTransitions:Vector.<ViewTransitionBase> = new Vector.<ViewTransitionBase>();

    /**
     *  @private
     *  Ends all currently active view transitions.
     */ 
    mx_internal static function endTransitions():void
    {
        // Prevent the transitions from waiting a frame when they receive the
        // EFFECT_END event.  See effectComplete().
        renderLastFrame = false;
        
        // End all active transitions.  They will be removed from the vector
        // in transitionComplete().
        for (var i:int = 0; i < activeTransitions.length; i++)
            activeTransitions[i].effect.end();
        
        // Restore render flag
        renderLastFrame = true;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  duration
    //----------------------------------
    
    private var _duration:Number = 250;
    
    /**
     *  Duration of the transition, in milliseconds. 
     *  The default may vary depending on the transition
     *  but is defined in ViewTransitionBase as 250 ms.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get duration():Number
    {
        return _duration;
    }
    
    /**
     *  @private
     */
    public function set duration(value:Number):void
    {
        _duration = value;
    }
    
    //----------------------------------
    //  easer
    //----------------------------------
    
    private var _easer:IEaser = new Sine(.5);
    
    /**
     *  The easing behavior for this transition. The IEaser object is
     *  generally propagated to the IEffect instance managing the actual
     *  transition animation.
     * 
     *  @default Sine(.5);
     *
     *  @see spark.effects.easing
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get easer():IEaser
    {
        return _easer;
    }
    
    /**
     *  @private
     */
    public function set easer(value:IEaser):void
    {
        _easer = value;
    }
    
    //----------------------------------
    //  effect
    //----------------------------------
    
    private var _effect:IEffect;
    
    /**
     *  Provides access to the underlying IEffect instance which the 
     *  transition is using to perform the transition (if any).  This property 
     *  is only valid after the FlexEvent.TRANSITION_START event even has been 
     *  dispatched.
     *
     *  If a transition does not make use of IEffect to perform the transition
     *  this can be null.
     * 
     *  @default null
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    mx_internal function get effect():IEffect
    {
        return _effect;
    }
    
    mx_internal function set effect(value:IEffect):void
    {
        _effect = value;
    }
    
    //----------------------------------
    //  endView
    //----------------------------------
    
    private var _endView:View;
    
    /**
     *  The view that the navigator is transitioning
     *  to, as set by the owning ViewNavigator object.  
     *  This property can be null.
     *
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get endView():View
    {
        return _endView;
    }
    
    /**
     *  @private
     */ 
    public function set endView(value:View):void
    {
        _endView = value;
    }
        
    //----------------------------------
    //  navigator
    //----------------------------------
    
    private var _navigator:ViewNavigator;
    
    /**
     *  Reference to the owning ViewNavigator instance set by the owning
     *  ViewNavigator.
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get navigator():ViewNavigator
    {
        return _navigator;
    }
    
    /**
     *  @private
     */
    public function set navigator(value:ViewNavigator):void
    {
        _navigator = value;
    }
    
    //----------------------------------
    //  startView
    //----------------------------------
    
    private var _startView:View;
    
    /**
     *  The currently active view of the view navigator, 
     *  as set by the owning view navigator. 
     *  This property can be null.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get startView():View
    {
        return _startView;
    }
    
    /**
     *  @private
     */
    public function set startView(value:View):void
    {
        _startView = value;
    }
    
    //----------------------------------
    //  suspendBackgroundProcessing
    //----------------------------------
    
    private var _suspendBackgroundProcessing:Boolean = true;
    
    /**
     *  When set to <code>true</code>, the <code>UIComponent.suspendBackgroundProcessing()</code>
     *  method is invoked prior to the transition playing. 
     *  This disables Flex's layout manager and improving performance. 
     *  Upon completion of the transition,
     *  the layout manager function is restored by a call to the 
     *  <code>UIComponent.resumeBackgroundProcessing()</code> method. 
     *
     *  @default false
     *
     *  @see mx.core.UIComponent#suspendBackgroundProcessing()
     *  @see mx.core.UIComponent#resumeBackgroundProcessing()
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get suspendBackgroundProcessing():Boolean
    {
        return _suspendBackgroundProcessing;
    }
    
    /**
     *  @private
     */ 
    public function set suspendBackgroundProcessing(value:Boolean):void
    {
        _suspendBackgroundProcessing = value;
    }
    
    //----------------------------------
    //  transitionControlsWithContent
    //----------------------------------
    
    private var _transitionControlsWithContent:Boolean;
    
    /**
     *  When set to <code>true</code>, the primary view transition
     *  is used to transition the view navigator in its entirety, 
     *  including the action bar.
     *  Specific transitions for the action bar are not performed.
     *  Because the tab bar is associated with the entire application, 
     *  and not a view, view transitions do not affect it.
     *
     *  <p>Note that even when set to <code>false</code>, there are cases
     *  where its not feasible to transition the action bar. 
     *  For example, when the action bar does not exist in one of 
     *  the two views, or if the action bar changes size.</p>
     *
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get transitionControlsWithContent():Boolean
    {
        return _transitionControlsWithContent;
    }
    
    /**
     *  @private
     */ 
    public function set transitionControlsWithContent(value:Boolean):void
    {
        _transitionControlsWithContent = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  actionBarTransitionMode
    //----------------------------------
    
    /**
     *  @private
     *  Convenience property used by ViewTransitionBase overrides to hint the behavior of
     *  the default action bar transition as appropriate for the type and nature
     *  of the specific view transition. Can be one either ViewTransitionBase.ACTION_BAR_MODE_FADE, 
     *  ViewTransitionBase.ACTION_BAR_MODE_FADE_AND_SLIDE, or null. If set to fade 
     *  and slide, the actionBarTransitionDirection property is considered by the 
     *  default createActionBarEffect() implementation.
     *
     *  @default ACTION_BAR_MODE_FADE_AND_SLIDE
     */
    mx_internal var actionBarTransitionMode:String = ACTION_BAR_MODE_FADE_AND_SLIDE;
    
    //----------------------------------
    //  actionBarTransitionDirection
    //----------------------------------
    
    /**
     *  @private
     *  Convenience property used by ViewTransitionBase overrides to hint the direction 
     *  of the default action bar transition when the actionBarTransitionMode is set to 
     *  "fadeAndSlide". Can be or null or set to one of the ViewTransitionDirection
     *  constants.  This property is considered by the default createActionBarEffect() 
     *  implementation. 
     *
     *  @default ViewTransitionDirection.LEFT
     */
    mx_internal var actionBarTransitionDirection:String = ViewTransitionDirection.LEFT;
    
    //----------------------------------
    //  cachedNavigatorSnapshot
    //----------------------------------
    
    /**
     *  @private
     *  Cached image of the cumulative view of the owning navigator
     *  captured by the default captureStartValues() implementation.
     *  This snapshot is generally leveraged by transitions that need to
     *  performing a full screen transition.
     */
    mx_internal var cachedNavigator:BitmapImage;
    
    /**
     *  @private
     *  Stores the location of the cached navigator in the global coordinate space
     *  so that the transition can properly position it when added to the display list.
     */ 
    mx_internal var cachedNavigatorGlobalPosition:Point = new Point();
    
    //----------------------------------
    //  cachedActionGroupSnapshot
    //----------------------------------
    
    /**
     *  @private
     *  Cached image of the action bar's action group. This image is 
     *  only captured by default if action group content exists in the
     *  previous view.
     */
    mx_internal var cachedActionGroup:BitmapImage;
    
    /**
     *  @private
     *  Stores the location of the cached navigator in the global coordinate space
     *  so that the transition can properly position it when added to the display list.
     */ 
    mx_internal var cachedActionGroupGlobalPosition:Point = new Point();
    
    //----------------------------------
    //  cachedTitleGroupSnapshot
    //----------------------------------
    
    /**
     *  @private
     *  Cached image of the action bar's title group. This image is 
     *  only captured by default if title group content exists in the
     *  previous view.
     */
    mx_internal var cachedTitleGroup:BitmapImage;
    
    /**
     *  @private
     *  Stores the location of the cached navigator in the global coordinate space
     *  so that the transition can properly position it when added to the display list.
     */ 
    mx_internal var cachedTitleGroupGlobalPosition:Point = new Point();
    
    //----------------------------------
    //  cachedNavigationGroupSnapshot
    //----------------------------------
    
    /**
     *  @private
     *  Cached image of the action bar's navigation group. This image is 
     *  only captured by default if navigation group content exists in the
     *  previous view.
     */
    mx_internal var cachedNavigationGroup:BitmapImage;
    
    /**
     *  @private
     *  Stores the location of the cached navigator in the global coordinate space
     *  so that the transition can properly position it when added to the display list.
     */ 
    mx_internal var cachedNavigationGroupGlobalPosition:Point = new Point();
    
    //----------------------------------
    //  targetNavigator
    //----------------------------------
    
    /**
     *  @private
     *  Convenience property which caches our primary containing navigator, 
     *  this is usually our owning ViewNavigator but may be an outer TabNavigator
     */
    protected var targetNavigator:ViewNavigatorBase;
    
    //----------------------------------
    //  parentNavigator
    //----------------------------------
    
    /**
     *  @private
     *  Convenience property which caches our primary containing navigator, 
     *  this is usually our owning ViewNavigator but may be an outer TabNavigator
     */
    protected var parentNavigator:ViewNavigatorBase;
    
    //----------------------------------
    //  actionBar
    //----------------------------------
    
    /**
     *  @private
     *  Convenience property which caches our associated action bar. 
     */
    protected var actionBar:ActionBar;
    
    /**
     *  @private
     *  Convenience property which caches our associated tab bar.
     */
    protected var tabBar:ButtonBarBase;
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    mx_internal function preInit():void
    {
        // Override
    }

    /**
     *  Called by the ViewNavigator during the preparation phase of a transition.
     *  It is invoked when the new view has been fully realized and validated and the 
     *  action bar and tab bar content reflect the state of the new view. 
     *  The transition can use this method capture any values it requires from the 
     *  pending view. 
     *  Any bitmaps reflecting the state of the new view, tab bar, 
     *  or action bar should be captured if required for animation.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function captureStartValues():void
    {
        // Remember some common references.
        parentNavigator = navigator.parentNavigator;
        
        if (parentNavigator is TabbedViewNavigator)
        {
           targetNavigator = parentNavigator;
           tabBar = TabbedViewNavigator(parentNavigator).tabBar;
        }
        else
        {
            targetNavigator = navigator;
        }
        
        if (navigator)
            actionBar = navigator.actionBar;
        
        // Determine first if we're able to transition our control bars independently
        // of our view content.  If we are, then capture the necessary action bar
        // bitmap snapshots for use later by our default action bar transition.
        if (!consolidatedTransition)
            consolidatedTransition = !canTransitionControlBarContent();
        
        // Snapshot component parts of action bar in preparation for our 
        // default action bar transition, (if appropriate).
        if (!consolidatedTransition)
        {
            if (componentIsVisible(actionBar))
            {
                // Save bounds of action bar. 
                cachedActionBarWidth = actionBar.width;
                cachedActionBarHeight = actionBar.height;
                
                // Snapshot title content of our startView.
                if (actionBar.titleGroup && actionBar.titleGroup.visible)
                    cachedTitleGroup = getSnapshot(actionBar.titleGroup, 4, cachedTitleGroupGlobalPosition);
                else if (actionBar.titleDisplay
                    && (actionBar.titleDisplay is UIComponent)
                    && UIComponent(actionBar.titleDisplay).visible)
                    cachedTitleGroup = getSnapshot(UIComponent(actionBar.titleDisplay), 4, cachedTitleGroupGlobalPosition);
                
                // Snapshot actionContent if it's changing between our start and end views.
                if (startView.actionContent != endView.actionContent)
                    cachedActionGroup = getSnapshot(actionBar.actionGroup, 4, cachedActionGroupGlobalPosition);
                
                // Snapshot navigationContent if it's changing between our start and end views.
                if (startView.navigationContent != endView.navigationContent)
                    cachedNavigationGroup = getSnapshot(actionBar.navigationGroup, 4, cachedNavigationGroupGlobalPosition);
            }
        }
    }
    
    /**
     *  Called by the ViewNavigator during the preparation phase of a transition.
     *  It is invoked when the new view has been fully realized and validated and the 
     *  action bar and tab bar content reflect the state of the new view. 
     *  It is at this point that the transition can capture any values it requires from the 
     *  pending view. 
     *  In addition any bitmaps reflecting the state of the new view, tab bar, 
     *  or action bar should be captured, if required for animation.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function captureEndValues():void
    {
        // One final check to determine if we will be required to perform a full
        // (consolidated) transition.
        if (!consolidatedTransition)
        {
            consolidatedTransition = 
                ((actionBar.height != cachedActionBarHeight) ||
                    (actionBar.width != cachedActionBarWidth));
        }
    }
    
    /**
     *  Called by the ViewNavigator when the transition 
     *  should begin animating.  
     *  At this time, the transition should dispatch a
     *  <code>start</code> event.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function play():void
    {   
        if (effect)
        {
            activeTransitions.push(this);
            effect.addEventListener(EffectEvent.EFFECT_END, effectComplete);
            
            // Dispatch TRANSITION_START.
            if (hasEventListener(FlexEvent.TRANSITION_START))
                dispatchEvent(new FlexEvent(FlexEvent.TRANSITION_START));
            
            if (navigator && navigator.stage && navigator.stage.hasEventListener(FlexEvent.TRANSITION_START))
                navigator.stage.dispatchEvent(new FlexEvent(FlexEvent.TRANSITION_START));
                    
            effect.play();
        }
        else
            transitionComplete();
    }
    
    /**
     *  Called by the ViewNavigator during the preparation phase 
     *  of a transition.  
     *  This method gives the transition the chance to create and
     *  configure the underlying IEffect instance, or to add any transient
     *  elements to the display list. 
     *  Example transient elements include  bitmap placeholders, temporary
     *  containers required during the transition,  and other elements. 
     *  If required, a final validation pass occurs prior to  the invocation 
     *  of the <code>play()</code> method.
     * 
     *  <p>If it is determined that a standard transition can be initiated, 
     *  meaning one that transitions the control bars separately from the views, 
     *  the default implementation of this method constructs 
     *  a single Parallel effect which wraps the individual effect sequences 
     *  for the view transition, the action bar transition, and the tab bar transition.  
     *  This method uses the  methods, <code>createActionBarEffect()</code>, 
     *  <code>createTabBarEffect()</code>, and <code>createViewEffect()</code>.</p>
     * 
     *  <p>If <code>transitionControlsWithContent</code> is set to <code>true</code>, 
     *  or if it is determined that the control bars cannot be transitioned independently, 
     *  a single effect is created to transition the navigator in its entirety.
     *  In this case, only <code>createConsolidatedEffect()</code> is invoked.</p>
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function prepareForPlay():void
    {
        if (!consolidatedTransition)
        {
            effect = new Parallel();
            
            // Prepare action bar effect
            if (actionBar)
            {
                var actionBarEffect:IEffect = createActionBarEffect();
                if (actionBarEffect)
                    Parallel(effect).addChild(actionBarEffect);
            }
            
            // Prepare tab bar effect
            if (targetNavigator is TabbedViewNavigator)
            {
                if (TabbedViewNavigator(targetNavigator).tabBar)
                {
                    var tabBarEffect:IEffect = createTabBarEffect();
                    if (tabBarEffect)
                        Parallel(effect).addChild(tabBarEffect);
                }
            }
            
            // Prepare view effect
            var viewEffect:IEffect = createViewEffect();
            if (viewEffect)
                Parallel(effect).addChild(viewEffect);
        }
        else
        {
            // Prepare full transition of navigator in its entirety.
            effect = createConsolidatedEffect();
        }
        
        // Disable layout manager if requested.
        if (suspendBackgroundProcessing)
            UIComponent.suspendBackgroundProcessing();
    }
    
    /**
     *  Called by the default <code>prepareForPlay()</code> implementation, 
     *  this method is responsible for creating the Spark effect 
     *  played on the action bar when the transition starts.  
     *  This method should be overridden by subclasses if a custom action bar 
     *  effect is required.  
     *  By default, this method returns a basic action bar effect.
     * 
     *  @return An IEffect instance serving as the action bar effect. 
     *  This effect is played by the default <code>play()</code> method implementation.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function createActionBarEffect():IEffect
    {
        var transformOffsets:TransformOffsets;
        var slideDistance:Number;
        var animatedProperty:String;
        
        var actionBarSkin:UIComponent = actionBar.skin;
        var slideTargets:Array = new Array();
        var fadeOutTargets:Array = new Array();
        var fadeInTargets:Array = new Array();
        
        // Return if we have a noop action bar transition mode.
        if (!actionBar || actionBarTransitionMode == ACTION_BAR_MODE_NONE || 
            !actionBarTransitionMode)
            return null;
        
        transitionGroup = new Group();
        transitionGroup.autoLayout = false;
        transitionGroup.includeInLayout = false;
        transitionGroup.width = actionBar.width;
        transitionGroup.height = actionBar.height;
        addComponentToContainer(transitionGroup, actionBarSkin);
        
        // Construct our parallel effect.
        var actionBarEffect:Parallel = new Parallel();
        
        // Calculate the slide distance based on direction.
        switch (actionBarTransitionDirection)
        {           
            case ViewTransitionDirection.RIGHT:
                animatedProperty = "x";
                slideDistance = -actionBar.width / 2.5;
                break;
            
            case ViewTransitionDirection.DOWN:
                animatedProperty = "y";
                slideDistance = -actionBar.height / 2.5;
                verticalTransition = true;
                break;
            
            case ViewTransitionDirection.UP:
                animatedProperty = "y";
                slideDistance = actionBar.height / 2.5;
                verticalTransition = true;
                break;
            
            case ViewTransitionDirection.LEFT:
            default:
                animatedProperty = "x";
                slideDistance = actionBar.width / 2.5;
                break;
        }
        
        transitionGroup.clipAndEnableScrolling = true;
        
        // Suppress slide if our action bar transition behavior is fade-only.
        if (actionBarTransitionMode == ACTION_BAR_MODE_FADE)
            slideDistance = 0;
        
        // If the skin has title content queue new title content for fade in.
        if (actionBar.titleGroup || actionBar.titleDisplay)
        {
            var titleComponent:UIComponent = actionBar.titleGroup;
            
            if (!titleComponent || !titleComponent.visible)
                titleComponent = actionBar.titleDisplay as UIComponent;
            
            if (titleComponent)
            {
                // Initialize the transformation offests
                transformOffsets = new TransformOffsets();
                transformOffsets[animatedProperty] = slideDistance;
                slideTargets.push(transformOffsets);
                
                // Initialize titleGroup
                titleComponent.cacheAsBitmap = true;
                titleComponent.alpha = 0;
                titleComponent.postLayoutTransformOffsets = transformOffsets;
                fadeInTargets.push(titleComponent);
                
                // We reparent the titleComponent into the transition group so
                // that the items are properly clipped when animating vertically
                if (verticalTransition)
                    transitionGroup.addElementAt(titleComponent, 0);
            }
            
            if (cachedTitleGroup)
                addCachedElementToGroup(transitionGroup, cachedTitleGroup, cachedTitleGroupGlobalPosition);
        }
        
        // If a cache of the navigation group exists, that means the content
        // changed.  In this case the queue cached representation to be faded
        // out.
        if (cachedNavigationGroup)
            addCachedElementToGroup(transitionGroup, cachedNavigationGroup, cachedNavigationGroupGlobalPosition);

        // If a cache of the action group exists, that means the content
        // changed.  In this case the queue cached representation to be faded
        // out.
        if (cachedActionGroup)
            addCachedElementToGroup(transitionGroup, cachedActionGroup, cachedActionGroupGlobalPosition);
        
        // Create fade in animations for navigationContent and actionContent
        // of the next view.
        if (endView)
        {
            if (endView.navigationContent)
            {
                // Initialize the transformation offests
                transformOffsets = new TransformOffsets();
                transformOffsets[animatedProperty] = slideDistance;
                slideTargets.push(transformOffsets);
                
                actionBar.navigationGroup.postLayoutTransformOffsets = transformOffsets;
                actionBar.navigationGroup.cacheAsBitmap = true;
                actionBar.navigationGroup.alpha = 0;
                fadeInTargets.push(actionBar.navigationGroup);
                
                // We reparent the titleComponent into the transition group so
                // that the items are properly clipped when animating vertically
                if (verticalTransition)
                    transitionGroup.addElementAt(actionBar.navigationGroup, 0);
            }
            
            if (endView.actionContent)
            {
                // Initialize the transformation offests
                transformOffsets = new TransformOffsets();
                transformOffsets[animatedProperty] = slideDistance;
                slideTargets.push(transformOffsets);
                
                actionBar.actionGroup.postLayoutTransformOffsets = transformOffsets;
                actionBar.actionGroup.cacheAsBitmap = true;
                actionBar.actionGroup.alpha = 0;
                fadeInTargets.push(actionBar.actionGroup);
                
                // We reparent the titleComponent into the transition group so
                // that the items are properly clipped when animating vertically
                if (verticalTransition)
                    transitionGroup.addElementAt(actionBar.actionGroup, 0);
            }
        }
        
        // Ensure bitmaps are rendered prior to invocation of our effect.
        transitionGroup.validateNow();
        
        
        // Setup fade out targets
        if (cachedTitleGroup)
        {
            // Initialize the transformation offests
            transformOffsets = new TransformOffsets();
            slideTargets.push(transformOffsets);
            
            cachedTitleGroup.postLayoutTransformOffsets = transformOffsets;
            fadeOutTargets.push(cachedTitleGroup.displayObject);
        }
        
        if (cachedNavigationGroup)
        {
            // Initialize the transformation offests
            transformOffsets = new TransformOffsets();
            slideTargets.push(transformOffsets);
            
            cachedNavigationGroup.postLayoutTransformOffsets = transformOffsets;
            fadeOutTargets.push(cachedNavigationGroup.displayObject);
        }
        
        if (cachedActionGroup)
        {
            // Initialize the transformation offests
            transformOffsets = new TransformOffsets();
            slideTargets.push(transformOffsets);
            
            cachedActionGroup.postLayoutTransformOffsets = transformOffsets;
            fadeOutTargets.push(cachedActionGroup.displayObject);
        }
        
        // If no fade effects we aren't animating anything so return null
        if (fadeInTargets.length == 0 && fadeOutTargets.length == 0)
            return null;
        
        // Create fade in effect
        if (fadeInTargets.length > 0)
        {
            var fadeInEffect:Fade = new Fade();
            fadeInEffect.targets = fadeInTargets;
            fadeInEffect.duration = duration;
            fadeInEffect.alphaFrom = 0;
            fadeInEffect.alphaTo = 1;
            actionBarEffect.addChild(fadeInEffect);
        }

        // Create fade out effect
        if (fadeOutTargets.length > 0)
        {
            var fadeOutEffect:Fade = new Fade();
            fadeOutEffect.targets = fadeOutTargets;
            fadeOutEffect.duration = duration;
            fadeOutEffect.alphaFrom = 1;
            fadeOutEffect.alphaTo = 0;
            actionBarEffect.addChild(fadeOutEffect);
        }        
        
        // Create slide in effect
        var vector:Vector.<MotionPath> = new Vector.<MotionPath>();
        vector.push(new SimpleMotionPath(animatedProperty, null, null, -slideDistance));
        
        var moveEffect:Animate = new Animate();
        moveEffect.targets = slideTargets;
        moveEffect.motionPaths = vector;
        moveEffect.easer = new spark.effects.easing.Sine(.7);
        moveEffect.duration = duration;
        moveEffect.addEventListener(EffectEvent.EFFECT_UPDATE, actionBarMoveEffect_effectUpdateHandler);
        moveEffect.addEventListener(EffectEvent.EFFECT_END, actionBarMoveEffect_effectEndedHandler);
        actionBarEffect.addChild(moveEffect);
        
        return actionBarEffect;
    }
    
    /**
     *  Called by the default <code>prepareForPlay()</code> implementation, 
     *  this method is responsible for creating the Spark effect played 
     *  on the tab bar when the transition starts.  
     *  This method should be overridden by subclasses.  
     *  By default, this returns null.
     * 
     *  @return An IEffect instance serving as the tab bar transition. 
     *  This effect is played by the default <code>play()</code> method implementation.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function createTabBarEffect():IEffect
    {
        return null;
    }
    
    /**
     *  Called by the default <code>prepareForPlay()</code> implementation, 
     *  this method is responsible for creating the Spark effect played 
     *  on the current and next view when the transition starts.  
     *  This method should be overridden by subclasses.  
     *  By default, this method returns null.
     * 
     *  @return An IEffect instance serving as the view transition. 
     *  This effect is played by the default <code>play()</code> method implementation.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function createViewEffect():IEffect
    {
        return null;
    }
    
    /**
     *  Called by the default <code>prepareForPlay()</code> implementation, 
     *  this method is responsible for creating the Spark effect played to
     *  transition the entire navigator, inclusive of the control bar content, 
     *  when necessary.  
     *  This method should be overridden by subclasses.  
     *  By default, this method returns null.
     * 
     *  @return An IEffect instance serving as the view transition. 
     *  This effect is played by the default <code>play()</code> method implementation.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function createConsolidatedEffect():IEffect
    {
        return null;
    }
    
    /**
     *  Called by the transition to indicate that the transition
     *  has completed.
     *  This method dispatches the <code>end</code> event.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function transitionComplete():void
    {
        var stage:Stage;
        if (navigator)
            stage = navigator.stage;
        
        cleanUp();
     
        activeTransitions.splice(activeTransitions.indexOf(this), 1);
        
        if (hasEventListener(FlexEvent.TRANSITION_END))
            dispatchEvent(new FlexEvent(FlexEvent.TRANSITION_END));
        
        if (stage && stage.hasEventListener(FlexEvent.TRANSITION_END))
            stage.dispatchEvent(new FlexEvent(FlexEvent.TRANSITION_END));
    }
    
    /**
     *  Called after the transition completes.
     *  This method is responsible for  releasing any references 
     *  and temporary constructs used by the transition.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function cleanUp():void
    {
        if (!consolidatedTransition && transitionGroup)
        {               
            if (cachedTitleGroup)
                transitionGroup.removeElement(cachedTitleGroup);
            
            if (cachedNavigationGroup)
                transitionGroup.removeElement(cachedNavigationGroup);
            
            if (cachedActionGroup)
            {
                transitionGroup.removeElement(cachedActionGroup);
                actionBar.actionGroup.cacheAsBitmap = false;
            }
           
            if (actionBar)
            {
                // Restore title group and title content to their original state.
                if (actionBar.titleGroup && actionBar.titleGroup.visible)
                {
                    actionBar.titleGroup.postLayoutTransformOffsets = null;
                    actionBar.titleGroup.cacheAsBitmap = false;
                }
                
                if (actionBar.titleDisplay 
                    && (actionBar.titleDisplay is DisplayObject)
                    && DisplayObject(actionBar.titleDisplay).visible)
                {
                    (actionBar.titleDisplay as UIComponent).postLayoutTransformOffsets = null;
                    DisplayObject(actionBar.titleDisplay).cacheAsBitmap = false;
                }
                
                // Restore title group and title content to their original home.
                if (verticalTransition)
                {
                    var titleComponent:UIComponent = actionBar.titleGroup;
                    if (!titleComponent || !titleComponent.visible)
                        titleComponent = actionBar.titleDisplay as UIComponent;
                    
                    if (titleComponent)
                    {
                        transitionGroup.removeElement(titleComponent);
                        addComponentToContainer(titleComponent, actionBar.skin);
                    }
                }
                
                // Restore navigation group to their proper home.
                if (endView.navigationContent && verticalTransition)
                {
                    transitionGroup.removeElement(actionBar.navigationGroup);
                    if (actionBar.titleDisplay)
                    {
                        var childIndex:uint = actionBar.skin.getChildIndex(actionBar.titleDisplay as DisplayObject);
                        addComponentToContainerAt(actionBar.navigationGroup, actionBar.skin, childIndex);
                    }
                    else
                        addComponentToContainer(actionBar.navigationGroup, actionBar.skin);
                }
                
                // Restore action group to their proper home.
                if (endView.actionContent && verticalTransition)
                {
                    transitionGroup.removeElement(actionBar.actionGroup);
                    if (actionBar.titleDisplay)
                    {
                        childIndex = actionBar.skin.getChildIndex(actionBar.titleDisplay as DisplayObject);
                        addComponentToContainerAt(actionBar.actionGroup, actionBar.skin, childIndex);
                    }
                    else
                        addComponentToContainer(actionBar.actionGroup, actionBar.skin);
                }
                
                removeComponentFromContainer(transitionGroup, actionBar.skin);
                
                actionBar.skin.scrollRect = null;
                
                // Force actionBar to update content group positions after
                // animating positions. If the width and height change during
                // the transition, we need relayout it's children because 
                // during the transition they are removed from layout and
                // missed during the validation pass. See SDK-30142.
                // TODO (jasonsj): Consider ending transitions when orientation
                // changes
                if ((actionBar.width != cachedActionBarWidth)
                    || (actionBar.height != cachedActionBarHeight))
                {
                    actionBar.skin.invalidateDisplayList();
                }
                
                if (actionBar.actionGroup)
                    actionBar.actionGroup.postLayoutTransformOffsets = null;
                
                if (actionBar.navigationGroup)
                    actionBar.navigationGroup.postLayoutTransformOffsets = null;
            }
            
            verticalTransition = false;
            cachedActionBarHeight = 0;
            cachedActionBarWidth = 0;
            
            transitionGroup = null;
            cachedTitleGroup = null;
            cachedNavigationGroup = null;
            cachedActionGroup = null;
        }
        
        consolidatedTransition = false;
        actionBar = null;
        tabBar = null;
        parentNavigator = null;
        targetNavigator = null;
        navigator = null;
        startView = null;
        endView = null;
        
        // Re-enable layout manager if appropriate.
        if (suspendBackgroundProcessing)
            UIComponent.resumeBackgroundProcessing();
    }
    
    /**
     *  Determine if Flex can perform a transition on 
     *  action bar or tab bar content independently of the views.
     * 
     *  <p>Flex cannot perform a transition on the control bars independently:</p>
     *  <ul>
     *      <li>If the containing view navigator is a TabbedViewNavigator 
     *        and its tab bar's visibility changes between views.</li>
     *      <li>If the value of the view navigator's <code>overlayControls</code>
     *        property changes between views.</li>
     *      <li>If the size or visibility of the action bar changes 
     *        between views.</li>
     *  </ul>
     * 
     *  @return <code>false</code> if Flex determines controls bars between views are 
     *  incompatible in some way.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    protected function canTransitionControlBarContent():Boolean
    {               
        // Short circuit if we've already been asked to not consider
        // control bars during transition.
        if (transitionControlsWithContent)
            return false;
        
        // Test for visibility or size of tab bar changing.
        if (targetNavigator is TabbedViewNavigator)
        {
            var tabBar:ButtonBarBase = TabbedViewNavigator(targetNavigator).tabBar;
            if (componentIsVisible(tabBar) != endView.tabBarVisible)
                return false;
        }
        
        // Test for visibility or size of action bar changing.
        if (navigator is ViewNavigator)
        {
            var actionBar:ActionBar = ViewNavigator(navigator).actionBar;
            if (componentIsVisible(actionBar) != endView.actionBarVisible)
                return false;
        }
        
        // Test for valid views.
        if (!startView || !endView)
            return false;
        
        // Test for value of overlayControls changing.
        if (startView.overlayControls != endView.overlayControls)
            return false;
        
        return true;
    }
    
    /**
     *  Used to render snap shots of screen elements in 
     *  preparation for transitioning.  
     *  The bitmap is returned in the form of a BitmapImage object.
     *   
     *  <p>The BitmapImage is in target's parent coordiantes space - 
     *  it overlaps the target precisely if paranted to the same parent.
     * 
     *  When moving to a different parent, make sure to adjust the 
     *  transformation of the BitmapImage to correctly account for the
     *  change in coordinate spaces.
     * 
     *  The updated value of the <code>globalPosition</code> parameter
     *  can be used for that.</p> 
     * 
     *  @param target Display object to capture.
     *  
     *  @param padding Padding around the object to be included in 
     *  the BitmapImage object.
     * 
     *  @param globalPosition When non-null, <code>globalPosition</code>
     *  will be updated with the origin of the BitmapImage in global 
     *  coordiantes. When moving to a different coordinate space, this
     *  value can be used to adjust the snapshot's position so its
     *  global position on screen doesn't change. 
     * 
     *  @return BitmapImage object representing the target.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    protected function getSnapshot(target:UIComponent, padding:int = 4, globalPosition:Point = null):BitmapImage
    {       
        if (!target || !target.visible || target.width == 0 || target.height == 0)
            return null;

        var snapshot:BitmapImage = new BitmapImage();
        
        // Ensure bitmap leverages its own display object for performance
        // reasons.
        snapshot.alwaysCreateDisplayObject = true;
        
        // Capture image, with consideration for transform and color matrix.
        // Return null if an error is thrown.
        var bounds:Rectangle = new Rectangle();
        try
        {
            snapshot.source = BitmapUtil.getSnapshotWithPadding(target, padding, true, bounds);
        }
        catch (e:SecurityError)
        {
            return null;
        }
        
        // Size and offset snapShot to match our image bounds data.
        snapshot.width = bounds.width;
        snapshot.height = bounds.height;

        var m:Matrix = new Matrix();
        m.translate(bounds.left, bounds.top);

        // Apply target's inverse concatenated matrix:
        var parent:DisplayObjectContainer = target.parent;
        if (parent)
        {
            var inverted:Matrix = parent.transform.concatenatedMatrix.clone();
            inverted.invert();
            m.concat(inverted);
        }
        snapshot.setLayoutMatrix(m, false);

        // Exclude from layout.
        snapshot.includeInLayout = false;
        
        if (globalPosition)
        {
            var pt:Point = parent ? parent.localToGlobal(new Point(snapshot.x, snapshot.y)) : new Point();
            globalPosition.x = pt.x;
            globalPosition.y = pt.y;
        }
        
        return snapshot; 
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Remove listeners
     */ 
    private function actionBarMoveEffect_effectEndedHandler(event:EffectEvent):void
    {
        event.target.removeEventListener(EffectEvent.EFFECT_UPDATE, actionBarMoveEffect_effectUpdateHandler);
        event.target.removeEventListener(EffectEvent.EFFECT_END, actionBarMoveEffect_effectEndedHandler);
    }
    
    /**
     *  @private
     *  Since layout is disabled, we need to force validation on all of the
     *  participating display objects.
     */
    private function actionBarMoveEffect_effectUpdateHandler(event:EffectEvent):void
    {
        if (!actionBar)
            return;
        
        // This code is a temporary performance fix for transitions.  Since layout is
        // disabled during ViewTransitions, in the past this method would call 
        // validateDisplayList() on the animation targets to update their internal position 
        // matrices.  We learned that this was causing a reduction in framerate due to
        // actionScript overhead.  To workaround the issue we are moving the x and y positions
        // of the underlying displayObjects manually.  This is a temporary fix to get
        // our performance numbers back up after checking in a fix for SDK-30839.
        // TODO (chiedozi): Clean up this code and use propery layout methods
        if (verticalTransition)
        {
            if (actionBar.actionGroup  && actionBar.actionGroup.postLayoutTransformOffsets)
                actionBar.actionGroup.$y = actionBar.actionGroup.y + actionBar.actionGroup.postLayoutTransformOffsets.y;
            
            if (actionBar.navigationGroup && actionBar.navigationGroup.postLayoutTransformOffsets)
                actionBar.navigationGroup.$y = actionBar.navigationGroup.y + actionBar.navigationGroup.postLayoutTransformOffsets.y;
            
            if (actionBar.titleDisplay && UIComponent(actionBar.titleDisplay).postLayoutTransformOffsets)
                UIComponent(actionBar.titleDisplay).$y = UIComponent(actionBar.titleDisplay).y + UIComponent(actionBar.titleDisplay).postLayoutTransformOffsets.y;
            
            if (actionBar.titleGroup && actionBar.titleGroup.postLayoutTransformOffsets)
                actionBar.titleGroup.$y = actionBar.titleGroup.y + actionBar.titleGroup.postLayoutTransformOffsets.y;
            
            if (cachedTitleGroup && cachedTitleGroup.displayObject)
                cachedTitleGroup.displayObject.y = cachedTitleGroup.y + cachedTitleGroup.postLayoutTransformOffsets.y;
            
            if (cachedNavigationGroup && cachedNavigationGroup.displayObject)
                cachedNavigationGroup.displayObject.y = cachedNavigationGroup.y + cachedNavigationGroup.postLayoutTransformOffsets.y;
            
            if (cachedActionGroup && cachedActionGroup.displayObject)
                cachedActionGroup.displayObject.y = cachedActionGroup.y + cachedActionGroup.postLayoutTransformOffsets.y;           
        }
        else
        {
            if (actionBar.actionGroup  && actionBar.actionGroup.postLayoutTransformOffsets)
                actionBar.actionGroup.$x = actionBar.actionGroup.x + actionBar.actionGroup.postLayoutTransformOffsets.x;
            
            if (actionBar.navigationGroup && actionBar.navigationGroup.postLayoutTransformOffsets)
                actionBar.navigationGroup.$x = actionBar.navigationGroup.x + actionBar.navigationGroup.postLayoutTransformOffsets.x;
            
            if (actionBar.titleDisplay && UIComponent(actionBar.titleDisplay).postLayoutTransformOffsets)
                UIComponent(actionBar.titleDisplay).$x = UIComponent(actionBar.titleDisplay).x + UIComponent(actionBar.titleDisplay).postLayoutTransformOffsets.x;
            
            if (actionBar.titleGroup && actionBar.titleGroup.postLayoutTransformOffsets)
                actionBar.titleGroup.$x = actionBar.titleGroup.x + actionBar.titleGroup.postLayoutTransformOffsets.x;
            
            if (cachedTitleGroup && cachedTitleGroup.displayObject)
                cachedTitleGroup.displayObject.x = cachedTitleGroup.x + cachedTitleGroup.postLayoutTransformOffsets.x;
            
            if (cachedNavigationGroup && cachedNavigationGroup.displayObject)
                cachedNavigationGroup.displayObject.x = cachedNavigationGroup.x + cachedNavigationGroup.postLayoutTransformOffsets.x;
            
            if (cachedActionGroup && cachedActionGroup.displayObject)
                cachedActionGroup.displayObject.x = cachedActionGroup.x + cachedActionGroup.postLayoutTransformOffsets.x;
        }
    }
    
    /**
     * @private
     */ 
    private function effectComplete(event:EffectEvent):void
    {
        effect.removeEventListener(EffectEvent.EFFECT_END, effectComplete);
        
        // Validate the last frame of the actionBar animation so that it
        // renders properly.  We put this here because layout isn't reenabled
        // until the next frame, meaning this validation won't be applied for
        // two frames.
        if (!consolidatedTransition)
            actionBarMoveEffect_effectUpdateHandler(null);
        
        if (renderLastFrame)
        {
            // We don't call transitionComplete just yet, we want to ensure
            // that the last frame of animation actually gets rendered on screen
            // before we clean up after ourselves.  This prevents a perceived 
            // stutter on the very last frame.
            navigator.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        }
        else
        {
            enterFrameHandler(null);
        }
    }
    
    /**
     * @private
     */ 
    private function enterFrameHandler(event:Event):void
    {
        if (event)
            navigator.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
        
        effect = null;
        transitionComplete();
    }
    
    /**
     * @private
     * Helper method to test whether a component is visible to user.
     */ 
    mx_internal function componentIsVisible(component:UIComponent):Boolean
    {
        return component && component.visible && 
            component.width && component.height && component.alpha;
    }
    
    /**
     *  @private
     *  Helper method to add a UIComponent instance to either an IVisualElementContainer
     *  or DisplayObjectContainer. 
     */ 
    mx_internal function addComponentToContainerAt(component:UIComponent, 
                                                 container:UIComponent, 
                                                 index:int):void
    {
        if (container is IVisualElementContainer)
            IVisualElementContainer(container).addElementAt(component, index);
        else
            container.addChildAt(component, index);
    }
    
    /**
     *  @private
     *  Helper method to add a UIComponent instance to either an IVisualElementContainer
     *  or DisplayObjectContainer.
     */ 
    mx_internal function addComponentToContainer(component:UIComponent, 
                                               container:UIComponent):void
    {
        if (container is IVisualElementContainer)
            IVisualElementContainer(container).addElement(component);
        else
            container.addChild(component);
    }
    
    /**
     *  @private
     *  Helper method to remove a UIComponent instance from either an IVisualElementContainer
     *  or DisplayObjectContainer.
     */ 
    mx_internal function removeComponentFromContainer(component:UIComponent, 
                                                    container:UIComponent):void
    {
        if (container is IVisualElementContainer)
            IVisualElementContainer(container).removeElement(component);
        else
            container.removeChild(component);
    }
    
    /**
     *  @private
     *  Helper method to set the child index of the given component.
     */ 
    mx_internal function setComponentChildIndex(component:UIComponent, 
                                              container:UIComponent, 
                                              index:int):void
    {
        if (container is IVisualElementContainer)
            IVisualElementContainer(container).setElementIndex(component, index);
        else
            container.setChildIndex(component, index);
    }

    /**
     *  @private
     *  Adds the element to the targetGroup and adjusts the position
     *  so that the global position remains the same.
     * 
     *  Note the targetGroup must be already added to the display list and
     *  positioned in order for this method to adjust the cachedElement's position
     *  correctly.
     * 
     *  @param targetGroup  The Group that will parent the cached element.
     *  @param cachedElement  The cached element - the return value of getSnapshot()
     *  @param cachedElementGlobalPosition The global position returned from getSnapshot()
     * 
     *  @see #getSnapshot
     */
    mx_internal function addCachedElementToGroup(targetGroup:Group, 
                                                 cachedElement:BitmapImage, 
                                                 cachedElementGlobalPosition:Point):void
    {
        targetGroup.addElement(cachedElement);

        // We are moving the cachedTitleGroup to the transitionGroup's coordinate space,
        // adjust the position
        var localOrigin:Point = targetGroup.globalToLocal(cachedElementGlobalPosition);
        cachedElement.x = localOrigin.x;
        cachedElement.y = localOrigin.y;
    }

    /**
     *  @private
     *  Helper method that returns index of the given component. 
     */
    mx_internal function getComponentChildIndex(component:UIComponent, container:UIComponent):int
    {
        if (container is IVisualElementContainer)
            return IVisualElementContainer(container).getElementIndex(component);
        else
            return container.getChildIndex(component);
    }
}
}
