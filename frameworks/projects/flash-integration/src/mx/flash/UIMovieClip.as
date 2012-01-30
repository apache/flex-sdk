////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.flash
{

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.PerspectiveProjection;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.system.ApplicationDomain;
import flash.ui.Keyboard;

import mx.automation.IAutomationObject;
import mx.core.AdvancedLayoutFeatures;
import mx.core.DesignLayer;
import mx.core.IConstraintClient;
import mx.core.IDeferredInstantiationUIComponent;
import mx.core.IFlexDisplayObject;
import mx.core.IInvalidating;
import mx.core.ILayoutElement;
import mx.core.IStateClient;
import mx.core.IUIComponent;
import mx.core.IVisualElement;
import mx.core.LayoutElementUIComponentUtils;
import mx.core.UIComponentDescriptor;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.MoveEvent;
import mx.events.PropertyChangeEvent;
import mx.events.ResizeEvent;
import mx.events.StateChangeEvent;
import mx.geom.TransformOffsets;
import mx.managers.IFocusManagerComponent;
import mx.managers.ISystemManager;
import mx.managers.IToolTipManagerClient;
import mx.utils.MatrixUtil;

use namespace mx_internal;

//--------------------------------------
//  Lifecycle events
//--------------------------------------

/**
 *  Dispatched when the component is added to a container as a content child
 *  by using the <code>addChild()</code> or <code>addChildAt()</code> method. 
 *  If the component is added to the container as a noncontent child by 
 *  using the <code>rawChildren.addChild()</code> or 
 *  <code>rawChildren.addChildAt()</code> method, the event is not dispatched.
 * 
 *  @eventType mx.events.FlexEvent.ADD
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="add", type="mx.events.FlexEvent")]

/**
 *  Dispatched when the component has finished its construction.
 *  For Flash-based components, this is the same time as the
 *  <code>initialize</code> event.
 *
 *  @eventType mx.events.FlexEvent.CREATION_COMPLETE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="creationComplete", type="mx.events.FlexEvent")]

/**
 *  Dispatched when an object's state changes from visible to invisible.
 *
 *  @eventType mx.events.FlexEvent.HIDE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="hide", type="mx.events.FlexEvent")]

/**
 *  Dispatched when the component has finished its construction
 *  and has all initialization properties set.
 *
 *  @eventType mx.events.FlexEvent.INITIALIZE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="initialize", type="mx.events.FlexEvent")]

/**
 *  Dispatched when the object has moved.
 *
 *  <p>You can move the component by setting the <code>x</code>
 *  or <code>y</code> properties, by calling the <code>move()</code>
 *  method, by setting one 
 *  of the following properties either on the component or on other
 *  components such that the LayoutManager needs to change the
 *  <code>x</code> or <code>y</code> properties of the component:</p>
 *
 *  <ul>
 *    <li><code>minWidth</code></li>
 *    <li><code>minHeight</code></li>
 *    <li><code>maxWidth</code></li>
 *    <li><code>maxHeight</code></li>
 *    <li><code>explicitWidth</code></li>
 *    <li><code>explicitHeight</code></li>
 *  </ul>
 *
 *  <p>When you call the <code>move()</code> method, the <code>move</code>
 *  event is dispatched before the method returns.
 *  In all other situations, the <code>move</code> event is not dispatched
 *  until after the property changes.</p>
 *
 *  @eventType mx.events.MoveEvent.MOVE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="move", type="mx.events.MoveEvent")]

/**
 *  Dispatched at the beginning of the component initialization sequence. 
 *  The component is in a very raw state when this event is dispatched. 
 *  Many components, such as the Button control, create internal child 
 *  components to implement functionality; for example, the Button control 
 *  creates an internal UITextField component to represent its label text. 
 *  When Flex dispatches the <code>preinitialize</code> event, 
 *  the children, including the internal children, of a component 
 *  have not yet been created.
 *
 *  @eventType mx.events.FlexEvent.PREINITIALIZE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="preinitialize", type="mx.events.FlexEvent")]

/**
 *  Dispatched when the component is removed from a container as a content child
 *  by using the <code>removeChild()</code> or <code>removeChildAt()</code> method. 
 *  If the component is removed from the container as a noncontent child by 
 *  using the <code>rawChildren.removeChild()</code> or 
 *  <code>rawChildren.removeChildAt()</code> method, the event is not dispatched.
 *
 *  @eventType mx.events.FlexEvent.REMOVE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="remove", type="mx.events.FlexEvent")]

/**
 *  Dispatched when the component is resized.
 *
 *  <p>You can resize the component by setting the <code>width</code> or
 *  <code>height</code> property, by calling the <code>setActualSize()</code>
 *  method, or by setting one of
 *  the following properties either on the component or on other components
 *  such that the LayoutManager needs to change the <code>width</code> or
 *  <code>height</code> properties of the component:</p>
 *
 *  <ul>
 *    <li><code>minWidth</code></li>
 *    <li><code>minHeight</code></li>
 *    <li><code>maxWidth</code></li>
 *    <li><code>maxHeight</code></li>
 *    <li><code>explicitWidth</code></li>
 *    <li><code>explicitHeight</code></li>
 *  </ul>
 *
 *  <p>The <code>resize</code> event is not 
 *  dispatched until after the property changes.</p>
 *
 *  @eventType mx.events.ResizeEvent.RESIZE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="resize", type="mx.events.ResizeEvent")]

/**
 *  Dispatched when an object's state changes from invisible to visible.
 *
 *  @eventType mx.events.FlexEvent.SHOW
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="show", type="mx.events.FlexEvent")]

//--------------------------------------
//  Mouse events
//--------------------------------------

/**
 *  Dispatched from a component opened using the PopUpManager 
 *  when the user clicks outside it.
 *
 *  @eventType mx.events.FlexMouseEvent.MOUSE_DOWN_OUTSIDE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="mouseDownOutside", type="mx.events.FlexMouseEvent")]

/**
 *  Dispatched from a component opened using the PopUpManager 
 *  when the user scrolls the mouse wheel outside it.
 *
 *  @eventType mx.events.FlexMouseEvent.MOUSE_WHEEL_OUTSIDE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="mouseWheelOutside", type="mx.events.FlexMouseEvent")]

//--------------------------------------
//  Drag-and-drop events
//--------------------------------------

/**
 *  Dispatched by a component when the user moves the mouse over the component
 *  during a drag operation.
 *
 *  <p>In order to be a valid drop target, you must define a handler
 *  for this event.
 *  In the handler, you can change the appearance of the drop target
 *  to provide visual feedback to the user that the component can accept
 *  the drag.
 *  For example, you could draw a border around the drop target,
 *  or give focus to the drop target.</p>
 *
 *  <p>If you want to accept the drag, you must call the 
 *  <code>DragManager.acceptDragDrop()</code> method. If you don't
 *  call <code>acceptDragDrop()</code>, you will not get any of the
 *  other drag events.</p>
 *
 *  <p>The value of the <code>action</code> property is always
 *  <code>DragManager.MOVE</code>, even if you are doing a copy. 
 *  This is because the <code>dragEnter</code> event occurs before 
 *  the control recognizes that the Control key is pressed to signal a copy.
 *  The <code>action</code> property of the event object for the 
 *  <code>dragOver</code> event does contain a value that signifies the type of 
 *  drag operation.</p>
 * 
 *  <p>You may change the type of drag action by calling the
 *  <code>DragManager.showFeedback()</code> method.</p>
 *
 *  @see mx.managers.DragManager
 *
 *  @eventType mx.events.DragEvent.DRAG_ENTER
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="dragEnter", type="mx.events.DragEvent")]

/**
 *  Dispatched by a component when the user moves the mouse while over the component
 *  during a drag operation.
 *
 *  <p>In the handler, you can change the appearance of the drop target
 *  to provide visual feedback to the user that the component can accept
 *  the drag.
 *  For example, you could draw a border around the drop target,
 *  or give focus to the drop target.</p>
 *
 *  <p>You should handle this event to perform additional logic
 *  before allowing the drop, such as dropping data to various locations
 *  in the drop target, reading keyboard input to determine if the
 *  drag-and-drop action is a move or copy of the drag data, or providing
 *  different types of visual feedback based on the type of drag-and-drop
 *  action.</p>
 *
 *  <p>You may also change the type of drag action by changing the
 *  <code>DragManager.showFeedback()</code> method.
 *  The default value of the <code>action</code> property is
 *  <code>DragManager.MOVE</code>.</p>
 *
 *  @see mx.managers.DragManager
 *
 *  @eventType mx.events.DragEvent.DRAG_OVER
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="dragOver", type="mx.events.DragEvent")]

/**
 *  Dispatched by the component when the user drags outside the component,
 *  but does not drop the data onto the target.
 *
 *  <p>You use this event to restore the drop target to its normal appearance
 *  if you modified its appearance as part of handling the
 *  <code>dragEnter</code> or <code>dragOver</code> event.</p>
 *
 *  @eventType mx.events.DragEvent.DRAG_EXIT
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="dragExit", type="mx.events.DragEvent")]

/**
 *  Dispatched by the drop target when the user releases the mouse over it.
 *
 *  <p>You use this event handler to add the drag data to the drop target.</p>
 *
 *  <p>If you call <code>Event.preventDefault()</code> in the event handler 
 *  for the <code>dragDrop</code> event for 
 *  a Tree control when dragging data from one Tree control to another, 
 *  it prevents the drop.</p>
 *
 *  @eventType mx.events.DragEvent.DRAG_DROP
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="dragDrop", type="mx.events.DragEvent")]

/**
 *  Dispatched by the drag initiator (the component that is the source
 *  of the data being dragged) when the drag operation completes,
 *  either when you drop the dragged data onto a drop target or when you end
 *  the drag-and-drop operation without performing a drop.
 *
 *  <p>You can use this event to perform any final cleanup
 *  of the drag-and-drop operation.
 *  For example, if you drag a List control item from one list to another,
 *  you can delete the List control item from the source if you no longer
 *  need it.</p>
 *
 *  <p>If you call <code>Event.preventDefault()</code> in the event handler 
 *  for the <code>dragComplete</code> event for 
 *  a Tree control when dragging data from one Tree control to another, 
 *  it prevents the drop.</p>
 *
 *  @eventType mx.events.DragEvent.DRAG_COMPLETE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="dragComplete", type="mx.events.DragEvent")]

//--------------------------------------
//  State events
//--------------------------------------

/**
 *  Dispatched after the <code>currentState</code> property changes,
 *  but before the view state changes.
 *
 *  @eventType mx.events.StateChangeEvent.CURRENT_STATE_CHANGING
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="currentStateChanging", type="mx.events.StateChangeEvent")]

/**
 *  Dispatched after the view state has changed.
 *
 *  @eventType mx.events.StateChangeEvent.CURRENT_STATE_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="currentStateChange", type="mx.events.StateChangeEvent")]

//--------------------------------------
//  Tooltip events
//--------------------------------------

/**
 *  Dispatched by the component when it is time to create a ToolTip.
 *
 *  <p>If you create your own IToolTip object and place a reference
 *  to it in the <code>toolTip</code> property of the event object
 *  that is passed to your <code>toolTipCreate</code> handler,
 *  the ToolTipManager displays your custom ToolTip.
 *  Otherwise, the ToolTipManager creates an instance of
 *  <code>ToolTipManager.toolTipClass</code> to display.</p>
 *
 *  <p>The sequence of ToolTip events is <code>toolTipStart</code>,
 *  <code>toolTipCreate</code>, <code>toolTipShow</code>,
 *  <code>toolTipShown</code>, <code>toolTipHide</code>,
 *  and <code>toolTipEnd</code>.</p>
 *
 *  @eventType mx.events.ToolTipEvent.TOOL_TIP_CREATE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="toolTipCreate", type="mx.events.ToolTipEvent")]

/**
 *  Dispatched by the component when its ToolTip has been hidden
 *  and will be discarded soon.
 *
 *  <p>If you specify an effect using the 
 *  <code>ToolTipManager.hideEffect</code> property, 
 *  this event is dispatched after the effect stops playing.</p>
 *
 *  <p>The sequence of ToolTip events is <code>toolTipStart</code>,
 *  <code>toolTipCreate</code>, <code>toolTipShow</code>,
 *  <code>toolTipShown</code>, <code>toolTipHide</code>,
 *  and <code>toolTipEnd</code>.</p>
 *
 *  @eventType mx.events.ToolTipEvent.TOOL_TIP_END
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="toolTipEnd", type="mx.events.ToolTipEvent")]

/**
 *  Dispatched by the component when its ToolTip is about to be hidden.
 *
 *  <p>If you specify an effect using the 
 *  <code>ToolTipManager.hideEffect</code> property, 
 *  this event is dispatched before the effect starts playing.</p>
 *
 *  <p>The sequence of ToolTip events is <code>toolTipStart</code>,
 *  <code>toolTipCreate</code>, <code>toolTipShow</code>,
 *  <code>toolTipShown</code>, <code>toolTipHide</code>,
 *  and <code>toolTipEnd</code>.</p>
 *
 *  @eventType mx.events.ToolTipEvent.TOOL_TIP_HIDE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="toolTipHide", type="mx.events.ToolTipEvent")]

/**
 *  Dispatched by the component when its ToolTip is about to be shown.
 *
 *  <p>If you specify an effect using the 
 *  <code>ToolTipManager.showEffect</code> property, 
 *  this event is dispatched before the effect starts playing.
 *  You can use this event to modify the ToolTip before it appears.</p>
 *
 *  <p>The sequence of ToolTip events is <code>toolTipStart</code>,
 *  <code>toolTipCreate</code>, <code>toolTipShow</code>,
 *  <code>toolTipShown</code>, <code>toolTipHide</code>,
 *  and <code>toolTipEnd</code>.</p>
 *
 *  @eventType mx.events.ToolTipEvent.TOOL_TIP_SHOW
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="toolTipShow", type="mx.events.ToolTipEvent")]

/**
 *  Dispatched by the component when its ToolTip has been shown.
 *
 *  <p>If you specify an effect using the 
 *  <code>ToolTipManager.showEffect</code> property, 
 *  this event is dispatched after the effect stops playing.</p>
 *
 *  <p>The sequence of ToolTip events is <code>toolTipStart</code>,
 *  <code>toolTipCreate</code>, <code>toolTipShow</code>,
 *  <code>toolTipShown</code>, <code>toolTipHide</code>,
 *  and <code>toolTipEnd</code>.</p>
 *
 *  @eventType mx.events.ToolTipEvent.TOOL_TIP_SHOWN
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="toolTipShown", type="mx.events.ToolTipEvent")]

/**
 *  Dispatched by a component whose <code>toolTip</code> property is set,
 *  as soon as the user moves the mouse over it.
 *
 *  <p>The sequence of ToolTip events is <code>toolTipStart</code>,
 *  <code>toolTipCreate</code>, <code>toolTipShow</code>,
 *  <code>toolTipShown</code>, <code>toolTipHide</code>,
 *  and <code>toolTipEnd</code>.</p>
 *
 *  @eventType mx.events.ToolTipEvent.TOOL_TIP_START
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="toolTipStart", type="mx.events.ToolTipEvent")]

    
/**
 *  Components created in Adobe Flash Professional for use in Flex 
 *  are subclasses of the mx.flash.UIMovieClip class. 
 *  The UIMovieClip class implements the interfaces necessary for a Flash component 
 *  to be used like a normal Flex component. Therefore, a subclass of UIMovieClip 
 *  can be used as a child of a Flex container or as a skin, 
 *  and it can respond to events, define view states and transitions, 
 *  and work with effects in the same way as can any Flex component.
 *
 *  <p>The following procedure describes the basic process for creating 
 *  a Flex component in Flash Professional:</p>
 *
 *  <ol>
 *    <li>Install the Adobe Flash Component Kit for Flex.</li> 
 *    <li>Create symbols for your dynamic assets in the FLA file.</li>
 *    <li>Run Commands &gt; Make Flex Component to convert your symbol 
 *      to a subclass of the UIMovieClip class, and to configure 
 *      the Flash Professional publishing settings for use with Flex.</li> 
 *    <li>Publish your FLA file as a SWC file.</li> 
 *    <li>Reference the class name of your symbols in your Flex application 
 *      as you would any class.</li> 
 *    <li>Include the SWC file in your <code>library-path</code> when you compile 
 *      your Flex application.</li>
 *  </ol>
 *
 *  <p>For more information, see the documentation that ships with the 
 *  Flex/Flash Integration Kit at 
 *  <a href="http://www.adobe.com/go/flex3_cs3_swfkit">http://www.adobe.com/go/flex3_cs3_swfkit</a>.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public dynamic class UIMovieClip extends MovieClip 
    implements IDeferredInstantiationUIComponent, IToolTipManagerClient, 
    IStateClient, IFocusManagerComponent, IConstraintClient, IAutomationObject, 
    IVisualElement, ILayoutElement
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function UIMovieClip()
    {
        super();
        
        // Add a focus in event handler so we can catch mouse focus within our
        // content.
        addEventListener(FocusEvent.FOCUS_IN, focusInHandler, false, 0, true);

        // Add a creationComplete handler so we can attach an event handler
        // to the stage
        addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
        
        if (currentLabel && currentLabel.indexOf(":") < 0 && currentLabel != _currentState)
            _currentState = currentLabel;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Internal variables
    //
    //--------------------------------------------------------------------------
    
    /**
     * @copy mx.core.UIComponent#initialized
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected var initialized:Boolean = false;
    
    private var validateMeasuredSizeFlag:Boolean = true;
    
    private var _parent:DisplayObjectContainer;
    
    private var stateMap:Object;
    
    // Focus vars
    private var focusableObjects:Array = [];
    
    private var reverseDirectionFocus:Boolean = false;
    
    private var focusListenersAdded:Boolean = false;
     
    // Transition playhead vars
    private var transitionStartFrame:Number;
    
    private var transitionEndFrame:Number;
    
    private var transitionDirection:Number = 0;
    
    private var transitionEndState:String;
    
    // Location change detection vars
    private var oldX:Number;
    
    private var oldY:Number;
    
    private var oldWidth:Number;
    
    private var oldHeight:Number;
    
    private var explicitSizeChanged:Boolean = false;
    
    private var explicitTabEnabledChanged:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Public variables
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  alpha
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the alpha property.
     */
    private var _alpha:Number = 1.0;
    
    /**
     *  @private
     */
    override public function get alpha():Number
    {
        // Here we roundtrip alpha in the same manner as the 
        // player (purposely introducing a rounding error).
        return int(_alpha * 256.0) / 256.0;
    }
    
    /**
     *  @private
     */
    override public function set alpha(value:Number):void
    { 
        if (_alpha != value)
        {
            _alpha = value;
            
            if (designLayer)
                value = value * designLayer.effectiveAlpha; 
            
            super.alpha = value;
        }
    }
        
    //----------------------------------
    //  autoUpdateMeasuredSize
    //----------------------------------

    /**
     * @private
     */
    private var _autoUpdateMeasuredSize:Boolean = false;

    [Inspectable(category="General")]

    /**
     *  Whether we should actively watch changes to the size of the flash object.  
     *  If this is set to <code>true</code>, then every frame, the size of the flash 
     *  object will be determined.  If the size has changed, then the flash object 
     *  will scale appropriately to fit its explicit bounds (or it will resize and 
     *  notify its parent if there is no explicit sizing).
     * 
     *  <p>Note: Setting this property to <code>true</code> may be expensive because 
     *  we now are asking the flash object its current size every single frame.</p>
     * 
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
    public function get autoUpdateMeasuredSize():Boolean
    {
        return _autoUpdateMeasuredSize;
    }

    /**
     *  @private
     */
    public function set autoUpdateMeasuredSize(value:Boolean):void
    {
        if (_autoUpdateMeasuredSize == value)
            return;

        _autoUpdateMeasuredSize = value;

        if (_autoUpdateMeasuredSize)
        {
            addEventListener(Event.ENTER_FRAME, autoUpdateMeasuredSizeEnterFrameHandler, false, 0, true);
        }
        else
        {
            removeEventListener(Event.ENTER_FRAME, autoUpdateMeasuredSizeEnterFrameHandler);
        }
    }
    
    //----------------------------------
    //  autoUpdateCurrentState
    //----------------------------------

    /**
     * @private
     */
    private var _autoUpdateCurrentState:Boolean = false;

    [Inspectable(category="General")]

    /**
     *  Whether we should actively watch changes to the label of the flash object.  
     *  The Flex <code>currentState</code> property depends on this flash label.  
     *  If this is set to <code>true</code>, then every frame, the label of the flash
     *  obejct will be quieried.  If the label has changed, that will become the new 
     *  <code>currentState</code> for the Flex object.
     * 
     *  <p>Note: Setting this property to <code>true</code> may be expensive because 
     *  we now are asking the flash object for is current label every single frame.</p>
     * 
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
    public function get autoUpdateCurrentState():Boolean
    {
        return _autoUpdateCurrentState;
    }

    /**
     *  @private
     */
    public function set autoUpdateCurrentState(value:Boolean):void
    {
        if (_autoUpdateCurrentState == value)
            return;

        _autoUpdateCurrentState = value;

        if (_autoUpdateCurrentState)
        {
            addEventListener(Event.ENTER_FRAME, autoUpdateCurrentStateEnterFrameHandler, false, 0, true);
        }
        else
        {
            removeEventListener(Event.ENTER_FRAME, autoUpdateCurrentStateEnterFrameHandler);
        }
    }
    
    //----------------------------------
    //  x
    //----------------------------------

    [Inspectable(category="General")]

    /**
     *  Number that specifies the component's horizontal position,
     *  in pixels, within its parent container.
     *
     *  <p>Setting this property directly or calling <code>move()</code>
     *  will have no effect -- or only a temporary effect -- if the
     *  component is parented by a layout container such as HBox, Grid,
     *  or Form, because the layout calculations of those containers
     *  set the <code>x</code> position to the results of the calculation.
     *  However, the <code>x</code> property must almost always be set
     *  when the parent is a Canvas or other absolute-positioning
     *  container because the default value is 0.</p>
     *
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function get x():Number
    {
        return (_layoutFeatures == null) ? super.x : _layoutFeatures.layoutX;
    }

    /**
     *  @private
     */
    override public function set x(value:Number):void
    {
        if (x == value)
            return;

        if (_layoutFeatures == null)
        {
            super.x  = value;
        }
        else
        {
            _layoutFeatures.layoutX = value;
            invalidateTransform();
        }
        //invalidateProperties();
        addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
        invalidateParentSizeAndDisplayList();
    }
    
    //----------------------------------
    //  y
    //----------------------------------

    [Inspectable(category="General")]

    /**
     *  Number that specifies the component's vertical position,
     *  in pixels, within its parent container.
     *
     *  <p>Setting this property directly or calling <code>move()</code>
     *  will have no effect -- or only a temporary effect -- if the
     *  component is parented by a layout container such as HBox, Grid,
     *  or Form, because the layout calculations of those containers
     *  set the <code>x</code> position to the results of the calculation.
     *  However, the <code>x</code> property must almost always be set
     *  when the parent is a Canvas or other absolute-positioning
     *  container because the default value is 0.</p>
     *
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function get y():Number
    {
        return (_layoutFeatures == null) ? super.y : _layoutFeatures.layoutY;
    }

    /**
     *  @private
     */
    override public function set y(value:Number):void
    {
        if (y == value)
            return;

        if (_layoutFeatures == null)
        {
            super.y  = value;
        }
        else
        {
            _layoutFeatures.layoutY = value;
            invalidateTransform();
        }
        //invalidateProperties();
        addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
        invalidateParentSizeAndDisplayList();
    }
    
	//----------------------------------
	//  z
	//----------------------------------

	[Bindable("zChanged")]

	/**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 3
     */
    override public function get z():Number
    {
        return (_layoutFeatures == null) ? super.z : _layoutFeatures.layoutZ;
    }

    /**
     *  @private
     */
    override public function set z(value:Number):void
    {
        if (z == value)
            return;

		if (_layoutFeatures == null)
            initAdvancedLayoutFeatures();

		hasDeltaIdentityTransform = false;
		_layoutFeatures.layoutZ = value;
        invalidateTransform();
        //invalidateProperties();
        invalidateParentSizeAndDisplayList();
    }
    
	//----------------------------------
	//  boundingBoxName
	//----------------------------------

	[Inspectable]

	/**
     *  Name of the object to use as the bounding box.
     *
     *  <p>The bounding box is an object that is used by Flex to determine
     *  the size of the component. The actual content can be larger or
     *  smaller than the bounding box, but Flex uses the size of the
     *  bounding box when laying out the component. This object is optional.
     *  If omitted, the actual content size of the component is used instead.</p>
     *
     *  @default "boundingBox"
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var boundingBoxName:String = "boundingBox";
    
    //----------------------------------
    //  Layout Constraints
    //----------------------------------
    
    private var _baseline:*;
    
    [Inspectable]
    [Bindable]
    /**
     *  The vertical distance in pixels from the top edge of the content area 
     *  to the component's baseline position. 
     *  If this property is set, the baseline of the component is anchored 
     *  to the top edge of its content area; 
     *  when its container is resized, the two edges maintain their separation.
     *
     *  <p>This property only has an effect when used on a component in a Canvas container, 
     *  or when used on a component in a Panel or Application container 
     *  that has the layout property set to <code>absolute</code>.</p>
     *
     *  <p>The default value is <code>undefined</code>, which means it is not set.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get baseline():Object
    {
        return _baseline;
    }
    
    /**
     *  @private
     */
    public function set baseline(value:Object):void
    {
        if (value != _baseline)
        {
            _baseline = value;
            invalidateParentSizeAndDisplayList();
        }
    }
    
    private var _bottom:*;
    
    [Inspectable]
    [Bindable]
    /**
     *  The vertical distance, in pixels, from the lower edge of the component 
     *  to the lower edge of its content area. 
     *  If this property is set, the lower edge of the component is anchored 
     *  to the bottom edge of its content area; 
     *  when its container is resized, the two edges maintain their separation.
     *
     *  <p>This property only has an effect when used on a component in a Canvas container, 
     *  or when used on a component in a Panel or Application container 
     *  that has the layout property set to <code>absolute</code>.</p>
     *
     *  <p>The default value is <code>undefined</code>, which means it is not set.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get bottom():Object
    {
        return _bottom;
    }
    
    /**
     *  @private
     */
    public function set bottom(value:Object):void
    {
        if (value != _bottom)
        {
            _bottom = value;
            invalidateParentSizeAndDisplayList();
        }
    }
    
    private var _horizontalCenter:*;
    
    [Inspectable]
    [Bindable]
    /**
     *  The horizontal distance in pixels from the center of the 
     *  component's content area to the center of the component. 
     *  If this property is set, the center of the component 
     *  will be anchored to the center of its content area; 
     *  when its container is resized, the two centers maintain their horizontal separation.
     *
     *  <p>This property only has an effect when used on a component in a Canvas container, 
     *  or when used on a component in a Panel or Application container 
     *  that has the layout property set to <code>absolute</code>.</p>
     *
     *  <p>The default value is <code>undefined</code>, which means it is not set.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get horizontalCenter():Object
    {
        return _horizontalCenter;
    }
    
    /**
     *  @private
     */
    public function set horizontalCenter(value:Object):void
    {
        if (value != _horizontalCenter)
        {
            _horizontalCenter = value;
            invalidateParentSizeAndDisplayList();
        }
    }
    
    private var _left:*;
    
    [Inspectable]
    [Bindable]
    /**
     *  The horizontal distance, in pixels, from the left edge of the component's 
     *  content area to the left edge of the component. 
     *  If this property is set, the left edge of the component is anchored 
     *  to the left edge of its content area; 
     *  when its container is resized, the two edges maintain their separation.
     *
     *  <p>This property only has an effect when used on a component in a Canvas container, 
     *  or when used on a component in a Panel or Application container 
     *  that has the layout property set to <code>absolute</code>.</p>
     *
     *  <p>The default value is <code>undefined</code>, which means it is not set.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get left():Object
    {
        return _left;
    }
    
    /**
     *  @private
     */
    public function set left(value:Object):void
    {
        if (value != _left)
        {
            _left = value;
            invalidateParentSizeAndDisplayList();
        }
    }
    
    private var _right:*;
    
    [Inspectable]
    [Bindable]
    /**
     *  The horizontal distance, in pixels, from the right edge of the component 
     *  to the right edge of its content area. 
     *  If this property is set, the right edge of the component is anchored 
     *  to the right edge of its content area; 
     *  when its container is resized, the two edges maintain their separation.
     *
     *  <p>This property only has an effect when used on a component in a Canvas container, 
     *  or when used on a component in a Panel or Application container 
     *  that has the layout property set to <code>absolute</code>.</p>
     *
     *  <p>The default value is <code>undefined</code>, which means it is not set.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get right():Object
    {
        return _right;
    }
    
    /**
     *  @private
     */
    public function set right(value:Object):void
    {
        if (value != _right)
        {
            _right = value;
            invalidateParentSizeAndDisplayList();
        }
    }
    
    private var _top:*;
    
    [Inspectable]
    [Bindable]
    /**
     *  The vertical distance, in pixels, from the top edge of the control's content area 
     *  to the top edge of the component. 
     *  If this property is set, the top edge of the component is anchored 
     *  to the top edge of its content area; 
     *  when its container is resized, the two edges maintain their separation.
     *
     *  <p>This property only has an effect when used on a component in a Canvas container, 
     *  or when used on a component in a Panel or Application container 
     *  that has the layout property set to <code>absolute</code>.</p>
     *
     *  <p>The default value is <code>undefined</code>, which means it is not set.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get top():Object
    {
        return _top;
    }
    
    /**
     *  @private
     */
    public function set top(value:Object):void
    {
        if (value != _top)
        {
            _top = value;
            invalidateParentSizeAndDisplayList();
        }
    }
    
    private var _verticalCenter:*;
    
    [Inspectable]
    [Bindable]
    /**
     *  The vertical distance in pixels from the center of the component's content area 
     *  to the center of the component. 
     *  If this property is set, the center of the component is anchored 
     *  to the center of its content area; 
     *  when its container is resized, the two centers maintain their vertical separation.
     *
     *  <p>This property only has an effect when used on a component in a Canvas container, 
     *  or when used on a component in a Panel or Application container 
     *  that has the layout property set to <code>absolute</code>.</p>
     *
     *  <p>The default value is <code>undefined</code>, which means it is not set.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get verticalCenter():Object
    {
        return _verticalCenter;
    }
    
    /**
     *  @private
     */
    public function set verticalCenter(value:Object):void
    {
        if (value != _verticalCenter)
        {
            _verticalCenter = value;
            invalidateParentSizeAndDisplayList();
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  IDeferredInstantiationUIComponent properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  cacheHeuristic
    //----------------------------------
    
    /**
     *  Used by Flex to suggest bitmap caching for the object.
     *  If <code>cachePolicy</code> is <code>UIComponentCachePolicy.AUTO</code>, 
     *  then <code>cacheHeuristic</code>
     *  is used to control the object's <code>cacheAsBitmap</code> property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function set cacheHeuristic(value:Boolean):void
    {
        // ignored
    }

    //----------------------------------
    //  cachePolicy
    //----------------------------------

    /**
     *  Specifies the bitmap caching policy for this object.
     *  Possible values in MXML are <code>"on"</code>,
     *  <code>"off"</code> and
     *  <code>"auto"</code> (default).
     * 
     *  <p>Possible values in ActionScript are <code>UIComponentCachePolicy.ON</code>,
     *  <code>UIComponentCachePolicy.OFF</code> and
     *  <code>UIComponentCachePolicy.AUTO</code> (default).</p>
     *
     *  <p><ul>
     *    <li>A value of <code>UIComponentCachePolicy.ON</code> means that 
     *      the object is always cached as a bitmap.</li>
     *    <li>A value of <code>UIComponentCachePolicy.OFF</code> means that 
     *      the object is never cached as a bitmap.</li>
     *    <li>A value of <code>UIComponentCachePolicy.AUTO</code> means that 
     *      the framework uses heuristics to decide whether the object should 
     *      be cached as a bitmap.</li>
     *  </ul></p>
     *
     *  @default UIComponentCachePolicy.AUTO
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get cachePolicy():String
    {
        return "";
    }

    //----------------------------------
    //  descriptor
    //----------------------------------

    private var _descriptor:UIComponentDescriptor;
    
    /**
     *  Reference to the UIComponentDescriptor, if any, that was used
     *  by the <code>createComponentFromDescriptor()</code> method to create this
     *  UIComponent instance. If this UIComponent instance 
     *  was not created from a descriptor, this property is null.
     *
     *  @see mx.core.UIComponentDescriptor
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get descriptor():UIComponentDescriptor
    {
        return _descriptor;
    }
    
    /**
     *  @private
     */
    public function set descriptor(value:UIComponentDescriptor):void
    {
        _descriptor = value;
    }

    //----------------------------------
    //  id
    //----------------------------------

    private var _id:String;
    
    /**
     *  ID of the component. This value becomes the instance name of the object
     *  and should not contain any white space or special characters. Each component
     *  throughout an application should have a unique id.
     *
     *  <p>If your application is going to be tested by third party tools, give each component
     *  a meaningful id. Testing tools use ids to represent the control in their scripts and
     *  having a meaningful name can make scripts more readable. For example, set the
     *  value of a button to submit_button rather than b1 or button1.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get id():String
    {
        return _id;
    }
    
    /**
     *  @private
     */
    public function set id(value:String):void
    {
        _id = value;
    }

    //--------------------------------------------------------------------------
    //
    //  IDeferredInstantiationUIComponent methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Creates an <code>id</code> reference to this IUIComponent object
     *  on its parent document object.
     *  This function can create multidimensional references
     *  such as b[2][4] for objects inside one or more repeaters.
     *  If the indices are null, it creates a simple non-Array reference.
     *
     *  @param parentDocument The parent of this IUIComponent object. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function createReferenceOnParentDocument(
                        parentDocument:IFlexDisplayObject):void
    {
        if (id && id != "")
        {
            parentDocument[id] = this;
        }
    }
    
    /**
     *  Deletes the <code>id</code> reference to this IUIComponent object
     *  on its parent document object.
     *  This function can delete from multidimensional references
     *  such as b[2][4] for objects inside one or more Repeaters.
     *  If the indices are null, it deletes the simple non-Array reference.
     *
     *  @param parentDocument The parent of this IUIComponent object. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function deleteReferenceOnParentDocument(
                                parentDocument:IFlexDisplayObject):void
    {
        if (id && id != "")
        {
            parentDocument[id] = null;
        }
    }

    /**
     *  Executes the data bindings into this UIComponent object.
     *
     *  @param recurse Recursively execute bindings for children of this component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function executeBindings(recurse:Boolean = false):void
    {
        var bindingsHost:Object = descriptor && descriptor.document ? descriptor.document : parentDocument;
        var mgr:* = ApplicationDomain.currentDomain.getDefinition("mx.binding.BindingManager");
        if (mgr != null)             
            mgr.executeBindings(bindingsHost, id, this);
    }

    /**
     *  For each effect event, register the EffectManager
     *  as one of the event listeners.
     *
     *  @param effects An Array of strings of effect names.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function registerEffects(effects:Array /* of String*/):void
    {
        // ignored
    }

    //--------------------------------------------------------------------------
    //
    //  IUIComponent properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  baselinePosition
    //----------------------------------

    /**
     *  The y-coordinate of the baseline
     *  of the first line of text of the component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get baselinePosition():Number
    {
        return 0;
    }
    
    //----------------------------------
    //  document
    //----------------------------------

    private var _document:Object;
    
    /**
     *  @copy mx.core.IUIComponent#document
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get document():Object
    {
        return _document;
    }

    /**
     *  @private
     */
    public function set document(value:Object):void
    {
        _document = value;
    }

    //----------------------------------
    //  explicitHeight
    //----------------------------------

    private var _explicitHeight:Number;
    
    /**
     *  The explicitly specified height for the component, 
     *  in pixels, as the component's coordinates.
     *  If no height is explicitly specified, the value is <code>NaN</code>.
     *
     *  @see mx.core.UIComponent#explicitHeight
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get explicitHeight():Number
    {
        return _explicitHeight;
    }

    /**
     *  @private
     */
    public function set explicitHeight(value:Number):void
    {
        _explicitHeight = value;
        explicitSizeChanged = true;
        
        invalidateParentSizeAndDisplayList();
        addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
    }

    //----------------------------------
    //  explicitMaxHeight
    //----------------------------------

    private var _explicitMaxHeight:Number;
    
    /**
     *  Number that specifies the maximum height of the component, 
     *  in pixels, as the component's coordinates. 
     *
     *  @see mx.core.UIComponent#explicitMaxHeight
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get explicitMaxHeight():Number
    {
        return _explicitMaxHeight;
    }
    
    public function set explicitMaxHeight(value:Number):void
    {
        _explicitMaxHeight = value;
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  explicitMaxWidth
    //----------------------------------

    private var _explicitMaxWidth:Number;
    
    /**
     *  Number that specifies the maximum width of the component, 
     *  in pixels, as the component's coordinates. 
     *
     *  @see mx.core.UIComponent#explicitMaxWidth
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get explicitMaxWidth():Number
    {
        return _explicitMaxWidth;
    }
    
    public function set explicitMaxWidth(value:Number):void
    {
        _explicitMaxWidth = value;
        
        // FIXME (rfrishbe): invalidate size
    }

    //----------------------------------
    //  explicitMinHeight
    //----------------------------------

    private var _explicitMinHeight:Number;
    
    /**
     *  Number that specifies the minimum height of the component, 
     *  in pixels, as the component's coordinates. 
     *
     *  @see mx.core.UIComponent#explicitMinHeight
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get explicitMinHeight():Number
    {
        return _explicitMinHeight;
    }
    
    public function set explicitMinHeight(value:Number):void
    {
        _explicitMinHeight = value;
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  explicitMinWidth
    //----------------------------------

    private var _explicitMinWidth:Number;
    
    /**
     *  Number that specifies the minimum width of the component, 
     *  in pixels, as the component's coordinates. 
     *
     *  @see mx.core.UIComponent#explicitMinWidth
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get explicitMinWidth():Number
    {
        return _explicitMinWidth;
    }
    
    public function set explicitMinWidth(value:Number):void
    {
        _explicitMinWidth = value;
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  explicitWidth
    //----------------------------------

    private var _explicitWidth:Number;

    /**
     *  The explicitly specified width for the component, 
     *  in pixels, as the component's coordinates.
     *  If no width is explicitly specified, the value is <code>NaN</code>.
     *
     *  @see mx.core.UIComponent#explicitWidth
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get explicitWidth():Number
    {
        return _explicitWidth;
    }
    
    public function set explicitWidth(value:Number):void
    {
        _explicitWidth = value;
        explicitSizeChanged = true;
        
        invalidateParentSizeAndDisplayList();
        addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
    }
    
    //----------------------------------
    //  focusPane
    //----------------------------------

    private var _focusPane:Sprite;
    
    /**
     *  A single Sprite object that is shared among components
     *  and used as an overlay for drawing focus.
     *  Components share this object if their parent is a focused component,
     *  not if the component implements the IFocusManagerComponent interface.
     *
     *  @see mx.core.UIComponent#focusPane
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get focusPane():Sprite
    {
        return _focusPane;
    }

    /**
     *  @private
     */
    public function set focusPane(value:Sprite):void
    {
        _focusPane = value;
    }

    //----------------------------------
    //  includeInLayout
    //----------------------------------

    private var _includeInLayout:Boolean = true;
    
    /**
     *  Specifies whether this component is included in the layout of the
     *  parent container.
     *  If <code>true</code>, the object is included in its parent container's
     *  layout.  If <code>false</code>, the object is positioned by its parent
     *  container as per its layout rules, but it is ignored for the purpose of
     *  computing the position of the next child.
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get includeInLayout():Boolean
    {
        return _includeInLayout;
    }

    /**
     *  @private
     */
    public function set includeInLayout(value:Boolean):void
    {
        _includeInLayout = value;
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  isPopUp
    //----------------------------------

    private var _isPopUp:Boolean = false;
    
    /**
     *  Set to <code>true</code> by the PopUpManager to indicate
     *  that component has been popped up.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get isPopUp():Boolean
    {
        return _isPopUp;
    }

    /**
     *  @private
     */
    public function set isPopUp(value:Boolean):void
    {
        _isPopUp = value;
    }

    //----------------------------------
    //  layer
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the layer property.
     */
    private var _designLayer:DesignLayer;
   
    [Inspectable (environment='none')]
 
    /**
     *  @copy mx.core.IVisualElement#designLayer
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get designLayer():DesignLayer
    {
        return _designLayer;
    }
    
    /**
     *  @private
     */
    public function set designLayer(value:DesignLayer):void
    {
        if (_designLayer)
            _designLayer.removeEventListener("layerPropertyChange", layer_PropertyChange, false);
        
        _designLayer = value;
        
        if (_designLayer)
            _designLayer.addEventListener("layerPropertyChange", layer_PropertyChange, false, 0, true);
        
        super.alpha = _designLayer ? _alpha * _designLayer.effectiveAlpha : _alpha;
        super.visible = _designLayer ? _visible && _designLayer.effectiveVisibility : _visible;
    }

    //----------------------------------
    //  maxHeight
    //----------------------------------
    
    /**
     *  Number that specifies the maximum height of the component, 
     *  in pixels, as the component's coordinates.
     *
     *  @see mx.core.UIComponent#maxHeight
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get maxHeight():Number
    {
        return isNaN(explicitMaxHeight) ? 10000 : explicitMaxHeight;
    }
    
    public function set maxHeight(value:Number):void
    {
        explicitMaxHeight = value;
    }

    //----------------------------------
    //  maxWidth
    //----------------------------------
    
    /**
     *  Number that specifies the maximum width of the component, 
     *  in pixels, as the component's coordinates.
     *
     *  @see mx.core.UIComponent#maxWidth
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get maxWidth():Number
    {
        return isNaN(explicitMaxWidth) ? 10000 : explicitMaxWidth;
    }
    
    public function set maxWidth(value:Number):void
    {
        explicitMaxWidth = value;
    }

    //----------------------------------
    //  measuredMinHeight
    //----------------------------------

    private var _measuredMinHeight:Number = 0;
    
    /**
     *  The default minimum height of the component, in pixels.
     *  This value is set by the <code>measure()</code> method.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get measuredMinHeight():Number
    {
        return _measuredMinHeight;
    }
    
    /**
     *  @private
     */
    public function set measuredMinHeight(value:Number):void
    {
        _measuredMinHeight = value;
    }

    //----------------------------------
    //  measuredMinWidth
    //----------------------------------

    private var _measuredMinWidth:Number = 0;
    
    /**
     *  The default minimum width of the component, in pixels.
     *  This value is set by the <code>measure()</code> method.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get measuredMinWidth():Number
    {
        return _measuredMinWidth;
    }
    
    /**
     *  @private
     */
    public function set measuredMinWidth(value:Number):void
    {
        _measuredMinWidth = value;
    }

    //----------------------------------
    //  minHeight
    //----------------------------------

    /**
     *  Number that specifies the minimum height of the component, 
     *  in pixels, as the component's coordinates. 
     *
     *  @see mx.core.UIComponent#minHeight
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get minHeight():Number
    {
        if (!isNaN(explicitMinHeight))
            return explicitMinHeight;
        
        return measuredMinHeight;
    }
    
    public function set minHeight(value:Number):void
    {
        explicitMinHeight = value;
    }

    //----------------------------------
    //  minWidth
    //----------------------------------

    /**
     *  Number that specifies the minimum width of the component, 
     *  in pixels, as the component's coordinates. 
     *
     *  @see mx.core.UIComponent#minWidth
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get minWidth():Number
    {
        if (!isNaN(explicitMinWidth))
            return explicitMinWidth;
        
        return measuredMinWidth;
    }
    
    public function set minWidth(value:Number):void
    {
        explicitMinWidth = value;
    }

    //----------------------------------
    //  owner
    //----------------------------------

    private var _owner:DisplayObjectContainer;
    
    /**
     *  Typically the parent container of this component. 
     *  However, if this is a popup component, the owner is 
     *  the component that popped it up.  
     *  For example, the owner of a dropdown list of a ComboBox control
     *  is the ComboBox control itself.
     *  This property is not managed by Flex, but 
     *  by each component. 
     *  Therefore, if you popup a component,
     *  you should set this property accordingly.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get owner():DisplayObjectContainer
    {
        return _owner ? _owner : parent;
    }

    /**
     *  @private
     */
    public function set owner(value:DisplayObjectContainer):void
    {
        _owner = value;
    }

    //----------------------------------
    //  percentHeight
    //----------------------------------

    private var _percentHeight:Number;
    
    /**
     *  Number that specifies the height of a component as a 
     *  percentage of its parent's size.
     *  Allowed values are 0 to 100.     
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get percentHeight():Number
    {
        return _percentHeight;
    }
    
    public function set percentHeight(value:Number):void
    {
        _percentHeight = value;
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  percentWidth
    //----------------------------------

    private var _percentWidth:Number;
    
    /**
     *  Number that specifies the width of a component as a 
     *  percentage of its parent's size.
     *  Allowed values are 0 to 100.     
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get percentWidth():Number
    {
        return _percentWidth;
    }
    
    public function set percentWidth(value:Number):void
    {
        _percentWidth = value;
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  systemManager
    //----------------------------------

    private var _systemManager:ISystemManager;
    
    /**
     *  A reference to the SystemManager object for this component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get systemManager():ISystemManager
    {
        if (!_systemManager)
        {
            var r:DisplayObject = root;
            if (r && !(r is Stage))
            {
                // If this object is attached to the display list, then
                // the root property holds its SystemManager.
                _systemManager = (r as ISystemManager);
            }
            else if (r)
            {
                // if the root is the Stage, then we are in a second AIR window
                _systemManager = Stage(r).getChildAt(0) as ISystemManager;
            }
            else
            {
                // If this object isn't attached to the display list, then
                // we need to walk up the parent chain ourselves.
                var o:DisplayObjectContainer = parent;
                while (o)
                {
                    var ui:IUIComponent = o as IUIComponent;
                    if (ui)
                    {
                        _systemManager = ui.systemManager;
                        break;
                    }
                    else if (o is ISystemManager)
                    {
                        _systemManager = o as ISystemManager;
                        break;
                    }
                    o = o.parent;
                }
            }
        }

        return _systemManager;
    }

    /**
     *  @private
     */
    public function set systemManager(value:ISystemManager):void
    {
        _systemManager = value;
    }

    //----------------------------------
    //  tweeningProperties
    //----------------------------------

    private var _tweeningProperties:Array;
    
    /**
     *  Used by EffectManager.
     *  Returns non-null if a component
     *  is not using the EffectManager to execute a Tween.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get tweeningProperties():Array
    {
        return _tweeningProperties;
    }

    /**
     *  @private
     */
    public function set tweeningProperties(value:Array):void
    {
        _tweeningProperties = value;
    }

    //----------------------------------
    //  visible
    //----------------------------------

    /**
     *  @private
     *  Storage for the visible property.
     */
    private var _visible:Boolean = true;

    /**
     *  @inheritDoc
     */    
    override public function get visible():Boolean
    {
        return _visible;
    }
    
    /**
     *  @private
     */
    override public function set visible(value:Boolean):void
    {
        setVisible(value);
    }
    
    //--------------------------------------------------------------------------
    //
    //  IFlexDisplayObject properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  height
    //----------------------------------

    /**
     *  @private
     */
    protected var _height:Number;
    
    /**
     *  The height of this object, in pixels.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    [PercentProxy("percentHeight")]
    override public function get height():Number
    {
        if (!isNaN(_height))
            return _height;
        
        return super.height;
    }
    
    /**
     *  @private
     */
    override public function set height(value:Number):void
    {
        explicitHeight = value;
    }

    //----------------------------------
    //  measuredHeight
    //----------------------------------
    
    private var _measuredHeight:Number;
    
    /**
     *  The measured height of this object.
     *
     *  <p>This is typically hard-coded for graphical skins
     *  because this number is simply the number of pixels in the graphic.
     *  For code skins, it can also be hard-coded
     *  if you expect to be drawn at a certain size.
     *  If your size can change based on properties, you may want
     *  to also be an ILayoutManagerClient so a <code>measure()</code>
     *  method will be called at an appropriate time,
     *  giving you an opportunity to compute a <code>measuredHeight</code>.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get measuredHeight():Number
    {
        validateMeasuredSize();
        return _measuredHeight;
    }

    //----------------------------------
    //  measuredWidth
    //----------------------------------

    private var _measuredWidth:Number;
    
    /**
     *  The measured width of this object.
     *
     *  <p>This is typically hard-coded for graphical skins
     *  because this number is simply the number of pixels in the graphic.
     *  For code skins, it can also be hard-coded
     *  if you expect to be drawn at a certain size.
     *  If your size can change based on properties, you may want
     *  to also be an ILayoutManagerClient so a <code>measure()</code>
     *  method will be called at an appropriate time,
     *  giving you an opportunity to compute a <code>measuredHeight</code>.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get measuredWidth():Number
    {
        validateMeasuredSize();
        return _measuredWidth;
    }

    //----------------------------------
    //  width
    //----------------------------------

    /**
     *  @private
     */
    protected var _width:Number;
    
    /**
     *  The width of this object, in pixels.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    [PercentProxy("percentWidth")]
    override public function get width():Number
    {
        if (!isNaN(_width))
            return _width;
            
        return super.width;
    }
    
    /**
     *  @private
     */
    override public function set width(value:Number):void
    {
        explicitWidth = value;
    }
    
    //----------------------------------
    //  scaleX
    //----------------------------------

    [Inspectable(category="Size", defaultValue="1.0")]

    /**
     *  Number that specifies the horizontal scaling factor.
     *
     *  <p>The default value is 1.0, which means that the object
     *  is not scaled.
     *  A <code>scaleX</code> of 2.0 means the object has been
     *  magnified by a factor of 2, and a <code>scaleX</code> of 0.5
     *  means the object has been reduced by a factor of 2.</p>
     *
     *  <p>A value of 0.0 is an invalid value.
     *  Rather than setting it to 0.0, set it to a small value, or set
     *  the <code>visible</code> property to <code>false</code> to hide the component.</p>
     *
     *  @default 1.0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function get scaleX():Number
    {
        // if it's been set, layoutFeatures won't be null.  Otherwise, return 1 as
        // super.scaleX might be some other value since we change the width/height 
        // through scaling
        return (_layoutFeatures == null) ? 1 : _layoutFeatures.layoutScaleX;
    }
    
    override public function set scaleX(value:Number):void
    {
        if (value == scaleX)
            return;
        
        if (_layoutFeatures == null)
			initAdvancedLayoutFeatures();

        hasDeltaIdentityTransform = false;

        _layoutFeatures.layoutScaleX = value;
        invalidateTransform();
        //invalidateProperties();

        // If we're not compatible with Flex3 (measuredWidth is pre-scale always)
        // and scaleX is changing we need to invalidate parent size and display list
        // since we are not going to detect a change in measured sizes during measure.
        invalidateParentSizeAndDisplayList();
    }
    
    /**
     *  The actual scaleX of the component.  Because scaling is used
     *  to resize the component, this is considerred an internal 
     *  implementation detail, whereas scaleX is the user-set scale
     *  of the component.
     *
     *  @private
     */
    mx_internal function get $scaleX():Number
    {
        return super.scaleX;
    }
    
    /**
     *  @private
     */
    mx_internal function set $scaleX(value:Number):void
    {
        super.scaleX = value;
    }
    
    /**
     *  @private
     */
    private var _scaleXDueToSizing:Number = 1;
    
    /**
     *  The scaleX of the component due to resizing.
     *
     *  @private
     */
    mx_internal function get scaleXDueToSizing():Number
    {
        return _scaleXDueToSizing;
    }
    
    /**
     *  @private
     */
    mx_internal function set scaleXDueToSizing(value:Number):void
    {
        _scaleXDueToSizing = value;
    }

    //----------------------------------
    //  scaleY
    //----------------------------------

    [Inspectable(category="Size", defaultValue="1.0")]

    /**
     *  Number that specifies the vertical scaling factor.
     *
     *  <p>The default value is 1.0, which means that the object
     *  is not scaled.
     *  A <code>scaleY</code> of 2.0 means the object has been
     *  magnified by a factor of 2, and a <code>scaleY</code> of 0.5
     *  means the object has been reduced by a factor of 2.</p>
     *
     *  <p>A value of 0.0 is an invalid value.
     *  Rather than setting it to 0.0, set it to a small value, or set
     *  the <code>visible</code> property to <code>false</code> to hide the component.</p>
     *
     *  @default 1.0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function get scaleY():Number
    {
        // if it's been set, layoutFeatures won't be null.  Otherwise, return 1 as
        // super.scaleX might be some other value since we change the width/height 
        // through scaling
        return (_layoutFeatures == null) ? 1 : _layoutFeatures.layoutScaleY;
    }
    
    override public function set scaleY(value:Number):void
    {
        if (value == scaleY)
            return;
        
        if (_layoutFeatures == null)
			initAdvancedLayoutFeatures();
            
        hasDeltaIdentityTransform = false;

        _layoutFeatures.layoutScaleY = value;
        invalidateTransform();
        //invalidateProperties();

        // If we're not compatible with Flex3 (measuredWidth is pre-scale always)
        // and scaleY is changing we need to invalidate parent size and display list
        // since we are not going to detect a change in measured sizes during measure.
        invalidateParentSizeAndDisplayList();
    }
    
    /**
     *  The actual scaleY of the component.  Because scaling is used
     *  to resize the component, this is considerred an internal 
     *  implementation detail, whereas scaleY is the user-set scale
     *  of the component.
     *
     *  @private
     */
    mx_internal function get $scaleY():Number
    {
        return super.scaleY;
    }
    
    /**
     *  @private
     */
    mx_internal function set $scaleY(value:Number):void
    {
        super.scaleY = value;
    }
    
    /**
     *  @private
     */
    private var _scaleYDueToSizing:Number = 1;
    
    /**
     *  The scaleX of the component due to resizing.
     *
     *  @private
     */
    mx_internal function get scaleYDueToSizing():Number
    {
        return _scaleYDueToSizing;
    }
    
    /**
     *  @private
     */
    mx_internal function set scaleYDueToSizing(value:Number):void
    {
        _scaleYDueToSizing = value;
    }

    //----------------------------------
    //  scaleZ
    //----------------------------------

    [Inspectable(category="Size", defaultValue="1.0")]
    /**
     *  Number that specifies the scaling factor along the z axis.
     *
     *  <p>A scaling along the z axis will not affect a typical component, which lies flat
     *  in the z=0 plane.  components with children that have 3D transforms applied, or 
     *  components with a non-zero transformZ, will be affected.</p>
     *  
     *  <p>The default value is 1.0, which means that the object
     *  is not scaled.</p>
     * 
     *  <p>This property is ignored during calculation by any of Flex's 2D layouts. </p>
     *
     *  @default 1.0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function get scaleZ():Number
    {
        return (_layoutFeatures == null) ? super.scaleZ : _layoutFeatures.layoutScaleZ;
    }

    /**
     * @private
     */
    override public function set scaleZ(value:Number):void
    {
        if (scaleZ == value)
            return;
        if (_layoutFeatures == null)
			initAdvancedLayoutFeatures();
		
		hasDeltaIdentityTransform = false;
		_layoutFeatures.layoutScaleZ = value;
        invalidateTransform();
        //invalidateProperties();
		invalidateParentSizeAndDisplayList();
    }
    
    //--------------------------------------------------------------------------
    //
    //  IToolTipManagerClient properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  toolTip
    //----------------------------------

    private var _toolTip:String;
    
    /**
     *  Text to display in the ToolTip.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get toolTip():String
    {
        return _toolTip;
    }
    
    /**
     *  @private
     */
    public function set toolTip(value:String):void
    {
        var toolTipManager:* = ApplicationDomain.currentDomain.getDefinition(
            "mx.managers.ToolTipManager");
        
        var oldValue:String = _toolTip;
        _toolTip = value;

        if (toolTipManager)
            toolTipManager.registerToolTip(this, oldValue, value);
    }
    
    //--------------------------------------------------------------------------
    //
    //  IFocusManagerComponent properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  focusEnabled
    //----------------------------------

    private var _focusEnabled:Boolean = true;
    
    /**
     *  A flag that indicates whether the component can receive focus when selected.
     * 
     *  <p>As an optimization, if a child component in your component 
     *  implements the IFocusManagerComponent interface, and you
     *  never want it to receive focus,
     *  you can set <code>focusEnabled</code>
     *  to <code>false</code> before calling <code>addChild()</code>
     *  on the child component.</p>
     * 
     *  <p>This will cause the FocusManager to ignore this component
     *  and not monitor it for changes to the <code>tabFocusEnabled</code>,
     *  <code>tabChildren</code>, and <code>mouseFocusEnabled</code> properties.
     *  This also means you cannot change this value after
     *  <code>addChild()</code> and expect the FocusManager to notice.</p>
     *
     *  <p>Note: It does not mean that you cannot give this object focus
     *  programmatically in your <code>setFocus()</code> method;
     *  it just tells the FocusManager to ignore this IFocusManagerComponent
     *  component in the Tab and mouse searches.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get focusEnabled():Boolean
    {
        return _focusEnabled && focusableObjects.length > 0;
    }
    
    /**
     *  @private
     */
    public function set focusEnabled(value:Boolean):void
    {
        _focusEnabled = value;
    }

    //----------------------------------
    //  hasFocusableChildren
    //----------------------------------

    /**
     *  @private
     *  Storage for the hasFocusableChildren property.
     */
    private var _hasFocusableChildren:Boolean = true;

    [Bindable("hasFocusableChildrenChange")]
    [Inspectable(defaultValue="true")]

    /**
     *  A flag that indicates whether child objects can receive focus
     * 
     *  <p>This is similar to the <code>tabChildren</code> property
     *  used by the Flash Player.</p>
     * 
     *  <p>This is usually <code>false</code> because most components
     *  either receive focus themselves or delegate focus to a single
     *  internal sub-component and appear as if the component has
     *  received focus.  For example, a TextInput contains a focusable
     *  child RichEditableText control, but while the RichEditableText
     *  sub-component actually receives focus, it appears as if the
     *  TextInput has focus.  TextInput sets <code>hasFocusableChildren</code>
     *  to <code>false</code> because TextInput is considered the
     *  component that has focus.  Its internal structure is an
     *  abstraction.</p>
     *
     *  <p>Usually only navigator components like TabNavigator and
     *  Accordion have this flag set to <code>true</code> because they
     *  receive focus on Tab but focus goes to components in the child
     *  containers on further Tabs</p>
     *  
     *  @default true
     *  
     *  @langversion 4.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get hasFocusableChildren():Boolean
    {
        return _hasFocusableChildren;
    }

    /**
     *  @private
     */
    public function set hasFocusableChildren(value:Boolean):void
    {
        if (value != _hasFocusableChildren)
        {
            _hasFocusableChildren = value;
            dispatchEvent(new Event("hasFocusableChildrenChange"));
        }
    }

    //----------------------------------
    //  mouseFocusEnabled
    //----------------------------------

    /**
     *  A flag that indicates whether the component can receive focus 
     *  when selected with the mouse.
     *  If <code>false</code>, focus will be transferred to
     *  the first parent that is <code>mouseFocusEnabled</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get mouseFocusEnabled():Boolean
    {
        return false;
    }

    //----------------------------------
    //  tabFocusEnabled
    //----------------------------------

    /**
     *  @private
     *  Storage for the tabFocusEnabled property.
     */
    private var _tabFocusEnabled:Boolean = true;

    [Bindable("tabFocusEnabledChange")]
    [Inspectable(defaultValue="true")]

    /**
     *  A flag that indicates whether child objects can receive focus
     * 
     *  <p>This is similar to the <code>tabEnabled</code> property
     *  used by the Flash Player.</p>
     * 
     *  <p>This is usually <code>true</code> for components that
     *  handle keyboard input, but some components in controlbars
     *  have them set to <code>false</code> because they should not steal
     *  focus from another component like an editor.
     *  </p>
     *
     *  @default true
     *  
     *  @langversion 4.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get tabFocusEnabled():Boolean
    {
        return _tabFocusEnabled;
    }

    /**
     *  @private
     */
    public function set tabFocusEnabled(value:Boolean):void
    {
        if (value != _tabFocusEnabled)
        {
            _tabFocusEnabled = value;
            dispatchEvent(new Event("tabFocusEnabledChange"));
        }
    }

    //--------------------------------------------------------------------------
    //
    //  IConstraintClient methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @copy mx.core.IConstraintClient#getConstraintValue()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function getConstraintValue(constraintName:String):*
    {
        return this["_"+constraintName];
    }

    /**
     *  @copy mx.core.IConstraintClient#setConstraintValue()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function setConstraintValue(constraintName:String, value:*):void
    {
        // set it using the setter first
        this[constraintName] = value;
        
        // this is so we can have the value typed as *
        this["_"+constraintName] = value;
    }
    
    /**
     *  @inheritDoc
     *    
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get depth():Number
    {
        return (_layoutFeatures == null) ? 0 : _layoutFeatures.depth;
    }

    /**
     * @private
     */
    public function set depth(value:Number):void
    {
        if (value == depth)
            return;
		if (_layoutFeatures == null)
			initAdvancedLayoutFeatures();
		
        _layoutFeatures.depth = value;      
        if (parent != null && "invalidateLayering" in parent && parent["invalidateLayering"] is Function)
            parent["invalidateLayering"]();
        // FIXME (rfrishbe): should be in some interface...
    }
    
    /**
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get transformX():Number
    {
        return (_layoutFeatures == null) ? 0 : _layoutFeatures.transformX;
    }
    /**
     *  @private
     */
    public function set transformX(value:Number):void
    {
        if (transformX == value)
            return;
		if (_layoutFeatures == null)
			initAdvancedLayoutFeatures();
		
        _layoutFeatures.transformX = value;
        invalidateTransform();
        //invalidateProperties();
        invalidateParentSizeAndDisplayList();
    }

    /**
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get transformY():Number
    {
        return (_layoutFeatures == null) ? 0 : _layoutFeatures.transformY;
    }
    /**
     *  @private
     */
    public function set transformY(value:Number):void
    {
        if (transformY == value)
            return;
		if (_layoutFeatures == null)
			initAdvancedLayoutFeatures();

        _layoutFeatures.transformY = value;
        invalidateTransform();
        //invalidateProperties();
        invalidateParentSizeAndDisplayList();
    }
    
    /**
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get transformZ():Number
    {
        return (_layoutFeatures == null) ? 0 : _layoutFeatures.transformZ;
    }
    /**
     *  @private
     */
    public function set transformZ(value:Number):void
    {
        if (transformZ == value)
            return;
		if (_layoutFeatures == null)
			initAdvancedLayoutFeatures();

        _layoutFeatures.transformZ = value;
        invalidateTransform();
        //invalidateProperties();
        invalidateParentSizeAndDisplayList();
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function get rotation():Number
    {
        return (_layoutFeatures == null) ? super.rotation : _layoutFeatures.layoutRotationZ;
    }

    /**
     * @private
     */
    override public function set rotation(value:Number):void
    {
        if (rotation == value)
            return;

        hasDeltaIdentityTransform = false;
        if (_layoutFeatures == null)
            super.rotation = MatrixUtil.clampRotation(value);
        else
            _layoutFeatures.layoutRotationZ = value;

        invalidateTransform();
        //invalidateProperties();
        invalidateParentSizeAndDisplayList();
    }

	/**
	 *  Indicates the x-axis rotation of the DisplayObject instance, in degrees,
	 *  from its original orientation relative to the 3D parent container.
	 *  Values from 0 to 180 represent clockwise rotation; values from 0 to -180
	 *  represent counterclockwise rotation. Values outside this range are added
	 *  to or subtracted from 360 to obtain a value within the range.
	 * 
	 *  This property is ignored during calculation by any of Flex's 2D layouts. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 3
	 */
    override public function get rotationX():Number
    {
        return (_layoutFeatures == null) ? super.rotationX : _layoutFeatures.layoutRotationX;
    }

    /**
     *  @private
     */
    override public function set rotationX(value:Number):void
    {
        if (rotationX == value)
            return;

        if (_layoutFeatures == null)
			initAdvancedLayoutFeatures();
        _layoutFeatures.layoutRotationX = value;
        invalidateTransform();
        //invalidateProperties();
        invalidateParentSizeAndDisplayList();
    }

    /**
	 *  Indicates the y-axis rotation of the DisplayObject instance, in degrees,
	 *  from its original orientation relative to the 3D parent container.
	 *  Values from 0 to 180 represent clockwise rotation; values from 0 to -180
	 *  represent counterclockwise rotation. Values outside this range are added
	 *  to or subtracted from 360 to obtain a value within the range.
     * 
     * This property is ignored during calculation by any of Flex's 2D layouts. 
     *  
     *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
     *  @productversion Flex 3
     */
    override public function get rotationY():Number
    {
        return (_layoutFeatures == null) ? super.rotationY : _layoutFeatures.layoutRotationY;
    }

    /**
     *  @private
     */
    override public function set rotationY(value:Number):void
    {
        if (rotationY == value)
            return;

        if (_layoutFeatures == null)
			initAdvancedLayoutFeatures();
        _layoutFeatures.layoutRotationY = value;
        invalidateTransform();
        //invalidateProperties();
        invalidateParentSizeAndDisplayList();
    }
    
	/**
	 *  @inheritDoc
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 3
	 */
	override public function get rotationZ():Number
	{
		return rotation;
	}

	/**
	 *  @private
	 */
	override public function set rotationZ(value:Number):void
	{
		rotation = value;
	}
	
    /**
     *  Defines a set of adjustments that can be applied to the component's transform in a way that is 
     *  invisible to the component's parent's layout. For example, if you want a layout to adjust 
     *  for a component that will be rotated 90 degrees, you set the component's <code>rotation</code> property. 
     *  If you want the layout to <i>not</i> adjust for the component being rotated, you set its <code>postLayoutTransformOffsets.rotationZ</code> 
     *  property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function set postLayoutTransformOffsets(value:TransformOffsets):void
    {
		if (_layoutFeatures == null)
			initAdvancedLayoutFeatures();

        
        if (_layoutFeatures.postLayoutTransformOffsets != null)
            _layoutFeatures.postLayoutTransformOffsets.removeEventListener(Event.CHANGE,transformOffsetsChangedHandler);
        _layoutFeatures.postLayoutTransformOffsets = value;
        if (_layoutFeatures.postLayoutTransformOffsets != null)
            _layoutFeatures.postLayoutTransformOffsets.addEventListener(Event.CHANGE,transformOffsetsChangedHandler);
        invalidateTransform();
    }

    /**
     * @private
     */
    public function get postLayoutTransformOffsets():TransformOffsets
    {
        return (_layoutFeatures != null)? _layoutFeatures.postLayoutTransformOffsets:null;
    }
    
    private function transformOffsetsChangedHandler(e:Event):void
    {
        invalidateTransform();
    }
    
    /**
     * @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function get transform():flash.geom.Transform
    {
        if (_transform == null)
        {
            setTransform(new mx.geom.Transform(this));
        }
        return _transform;
    }

    /**
     * @private
     */
    override public function set transform(value:flash.geom.Transform):void
    {
        var m:Matrix = value.matrix;
        var m3:Matrix3D =  value.matrix3D;
        var ct:ColorTransform = value.colorTransform;
        var pp:PerspectiveProjection = value.perspectiveProjection;
        
        var mxTransform:mx.geom.Transform = value as mx.geom.Transform;
        if (mxTransform)
        {
            if (!mxTransform.applyMatrix)
                m = null;
            
            if (!mxTransform.applyMatrix3D)
                m3 = null;
        }
        
        setTransform(value);
        
        if (m != null)
            setLayoutMatrix(m.clone(), true /*triggerLayoutPass*/);
        else if (m3 != null)
            setLayoutMatrix3D(m3.clone(), true /*triggerLayoutPass*/);

        super.transform.colorTransform = ct;
        super.transform.perspectiveProjection = pp;
        if (maintainProjectionCenter)
            applyPerspectiveProjection(); 
    }
    
    /**
     * Documentation is not currently available
     */
    mx_internal function get $transform():flash.geom.Transform
    {
        return super.transform;
    }
    
    /**
     * @private
     */
    private var _maintainProjectionCenter:Boolean = false;
    
    /**
     *  When true, the component will keep its projection matrix centered on the
     *  middle of its bounding box.  If no projection matrix is defined on the
     *  component, one will be added automatically.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function set maintainProjectionCenter(value:Boolean):void
    {
        _maintainProjectionCenter = value;
        if (value && super.transform.perspectiveProjection == null)
        {
            super.transform.perspectiveProjection = new PerspectiveProjection();
        }
        applyPerspectiveProjection();
    }
    /**
     * @private
     */
    public function get maintainProjectionCenter():Boolean
    {
        return _maintainProjectionCenter;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getLayoutMatrix():Matrix
    {
        if (_layoutFeatures != null || super.transform.matrix == null)
        {
            // TODO: this is a workaround for a situation in which the
            // object is in 2D, but used to be in 3D and the player has not
            // yet cleaned up the matrices. So the matrix property is null, but
            // the matrix3D property is non-null. layoutFeatures can deal with
            // that situation, so we allocate it here and let it handle it for
            // us. The downside is that we have now allocated layoutFeatures
            // forever and will continue to use it for future situations that
            // might not have required it. Eventually, we should recognize
            // situations when we can de-allocate layoutFeatures and back off
            // to letting the player handle transforms for us.
            if (_layoutFeatures == null)
                initAdvancedLayoutFeatures();

            // esg: _layoutFeatures keeps a single internal copy of the layoutMatrix.
            // since this is an internal class, we don't need to worry about developers
            // accidentally messing with this matrix, _unless_ we hand it out. Instead,
            // we hand out a clone.
            return _layoutFeatures.layoutMatrix.clone();            
        }
        else
        {
            // flash also returns copies.
            return super.transform.matrix;
        }
    }

    /**
     *  @inheritDoc 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function setLayoutMatrix(value:Matrix, invalidateLayout:Boolean):void
    {
        hasDeltaIdentityTransform = false;
        if (_layoutFeatures == null)
        {
            // flash will make a copy of this on assignment.
            super.transform.matrix = value;
        }
        else
        {
            // layout features will internally make a copy of this matrix rather than
            // holding onto a reference to it.
            _layoutFeatures.layoutMatrix = value;
            invalidateTransform();
        }
        
        //invalidateProperties();

        if (invalidateLayout)
            invalidateParentSizeAndDisplayList();
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getLayoutMatrix3D():Matrix3D
    {
        if (_layoutFeatures == null)
            initAdvancedLayoutFeatures();
        // esg: _layoutFeatures keeps a single internal copy of the layoutMatrix.
        // since this is an internal class, we don't need to worry about developers
        // accidentally messing with this matrix, _unless_ we hand it out. Instead,
        // we hand out a clone.
        return _layoutFeatures.layoutMatrix3D.clone();          
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get hasLayoutMatrix3D():Boolean
    {
        return _layoutFeatures ? _layoutFeatures.layoutIs3D : false;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get is3D():Boolean
    {
        return _layoutFeatures ? _layoutFeatures.is3D : false;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function setLayoutMatrix3D(value:Matrix3D, invalidateLayout:Boolean):void
    {
        if (_layoutFeatures == null)
            initAdvancedLayoutFeatures();
        // layout features will internally make a copy of this matrix rather than
        // holding onto a reference to it.
        _layoutFeatures.layoutMatrix3D = value;
        invalidateTransform();
        
        //invalidateProperties();

        if (invalidateLayout)
            invalidateParentSizeAndDisplayList();
    }
    
    private function setTransform(value:flash.geom.Transform):void
    {
        // Clean up the old transform
        var oldTransform:mx.geom.Transform = _transform as mx.geom.Transform;
        if (oldTransform)
            oldTransform.target = null;

        var newTransform:mx.geom.Transform = value as mx.geom.Transform;

        if (newTransform)
            newTransform.target = this;

        _transform = value;
    }
    
    private static var xformPt:Point;

    /**
     * A utility method to update the rotation, scale, and translation of the 
     * transform while keeping a particular point, specified in the component's 
     * own coordinate space, fixed in the parent's coordinate space.  
     * This function will assign the rotation, scale, and translation values 
     * provided, then update the x/y/z properties as necessary to keep 
     * the transform center fixed.
     * @param scale the new values for the scale of the transform
     * @param rotation the new values for the rotation of the transform
     * @param translation the new values for the translation of the transform
     * @param transformCenter the point, in the component's own coordinates, to keep fixed relative to its parent.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function transformAround(transformCenter:Vector3D,
                                    scale:Vector3D = null,
                                    rotation:Vector3D = null,
                                    translation:Vector3D = null,
                                    postLayoutScale:Vector3D = null,
                                    postLayoutRotation:Vector3D = null,
                                    postLayoutTranslation:Vector3D = null):void
    {
        if (_layoutFeatures == null)
        {
            // TODO (chaase): should provide a way to return to having no
            // layoutFeatures if we call this later with a more trivial
            // situation
            var needAdvancedLayout:Boolean = 
                (scale != null && ((!isNaN(scale.x) && scale.x != 1) || 
                    (!isNaN(scale.y) && scale.y != 1) ||
                    (!isNaN(scale.z) && scale.z != 1))) || 
                (rotation != null && ((!isNaN(rotation.x) && rotation.x != 0) || 
                    (!isNaN(rotation.y) && rotation.y != 0) ||
                    (!isNaN(rotation.z) && rotation.z != 0))) || 
                (translation != null && translation.z != 0 && !isNaN(translation.z)) ||
                postLayoutScale != null ||
                postLayoutRotation != null ||
                postLayoutTranslation != null;
            if (needAdvancedLayout)
                initAdvancedLayoutFeatures();
        }
        if (_layoutFeatures != null)
        {
            _layoutFeatures.transformAround(transformCenter, scale, rotation,
                translation, postLayoutScale, postLayoutRotation,
                postLayoutTranslation);
            invalidateTransform();      
            invalidateParentSizeAndDisplayList();
        }
        else
        {
            if (rotation != null && !isNaN(rotation.z))
                this.rotation = rotation.z;
            if (scale != null)
            {
                scaleX = scale.x;
                scaleY = scale.y;
            }            
            if (transformCenter == null)
            {
                if (translation != null)
                {
                    x = translation.x;
                    y = translation.y;
                }
            }
            else
            {
                if (xformPt == null)
                    xformPt = new Point();
                xformPt.x = transformCenter.x;
                xformPt.y = transformCenter.y;                
                var postXFormPoint:Point = 
                    transform.matrix.transformPoint(xformPt);
                if (translation != null)
                {
                    x += translation.x - postXFormPoint.x;
                    y += translation.y - postXFormPoint.y;
                }
                else
                {
                    var xformedPt:Point = 
                        transform.matrix.transformPoint(xformPt);
                    x += xformedPt.x - postXFormPoint.x;
                    y += xformedPt.y - postXFormPoint.y;                                   
                }
            }
        }
    }
    
    /**
     * A utility method to transform a point specified in the local
     * coordinates of this object to its location in the object's parent's 
     * coordinates. The pre-layout and post-layout result will be set on 
     * the <code>position</code> and <code>postLayoutPosition</code>
     * parameters, if they are non-null.
     * 
     * @param localPosition The point to be transformed, specified in the
     * local coordinates of the object.
     * @position A Vector3D point that will hold the pre-layout
     * result. If null, the parameter is ignored.
     * @postLayoutPosition A Vector3D point that will hold the post-layout
     * result. If null, the parameter is ignored.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function transformPointToParent(localPosition:Vector3D,
                                           position:Vector3D, 
                                           postLayoutPosition:Vector3D):void
    {
        if (_layoutFeatures != null)
        {
            _layoutFeatures.transformPointToParent(true, localPosition,
                position, postLayoutPosition);
        }
        else
        {
            if (xformPt == null)
                xformPt = new Point();
            if (localPosition)
            {
                xformPt.x = localPosition.x;
                xformPt.y = localPosition.y;
            }
            var tmp:Point = transform.matrix.transformPoint(xformPt);
            if (position != null)
            {            
                position.x = tmp.x;
                position.y = tmp.y;
                position.z = 0;
            }
            if (postLayoutPosition != null)
            {
                postLayoutPosition.x = tmp.x;
                postLayoutPosition.y = tmp.y;
                postLayoutPosition.z = 0;
            }
        }
    }

    /**
     *  Helper method to invalidate parent size and display list if
     *  this object affects its layout (includeInLayout is true).
     */
    protected function invalidateParentSizeAndDisplayList():void
    {
        if (!includeInLayout)
            return;

        var p:IInvalidating = parent as IInvalidating;
        if (!p)
            return;

        p.invalidateSize();
        p.invalidateDisplayList();
    }
    
    /**
     * @private
     *
     * storage for advanced layout and transform properties.
     */
    private var _layoutFeatures:AdvancedLayoutFeatures;
    
	/**
	 *  @private
	 *  When true, the transform on this component consists only of translation.
	 *  Otherwise, it may be arbitrarily complex.
	 */
    protected var hasDeltaIdentityTransform:Boolean = true;
    
	/**
	 *  @private
	 *  Storage for the modified Transform object that can dispatch
	 *  change events correctly.
	 */
    private var _transform:flash.geom.Transform;
    
	/**
	 *  @private
	 *  Initializes the implementation and storage of some of the less
	 *  frequently used advanced layout features of a component.
	 *  Call this function before attempting to use any of the
	 *  features implemented by the AdvancedLayoutFeatures object.
	 * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
	 */
    private function initAdvancedLayoutFeatures():void
    {
        var features:AdvancedLayoutFeatures = new AdvancedLayoutFeatures();

        hasDeltaIdentityTransform = false;

        features.layoutScaleX = scaleX;
        features.layoutScaleY = scaleY;
        features.layoutScaleZ = scaleZ;
        features.layoutRotationX = rotationX;
        features.layoutRotationY = rotationY;
        features.layoutRotationZ = rotation;
        features.layoutX = x;
        features.layoutY = y;
        features.layoutZ = z;
		
		// Initialize the internal variable last,
		// since the transform getters depend on it.
        _layoutFeatures = features;

		invalidateTransform();
    }
    
    private function invalidateTransform():void
    {
        if (_layoutFeatures && _layoutFeatures.updatePending == false)
        {
            _layoutFeatures.updatePending = true; 
            applyComputedMatrix();
        }
    }
    
    /**
     * Commits the computed matrix built from the combination of the layout matrix and the transform offsets to the flash displayObject's transform.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    private function applyComputedMatrix():void
    {
        _layoutFeatures.updatePending = false;
        
        // need to set the scale to the "real scale" (the user-set 
        // scale + the scale needed for sizing) to get a real matrix.
        // Afterwards, we'll reset it to the "user-set" scale.
        var oldScaleX:Number = _layoutFeatures.layoutScaleX;
        var oldScaleY:Number = _layoutFeatures.layoutScaleY;
        _layoutFeatures.layoutScaleX = _layoutFeatures.layoutScaleX * scaleXDueToSizing;
        _layoutFeatures.layoutScaleY = _layoutFeatures.layoutScaleY * scaleYDueToSizing;
        
        if (_layoutFeatures.is3D)
        {
            super.transform.matrix3D = _layoutFeatures.computedMatrix3D;
        }
        else
        {
            super.transform.matrix = _layoutFeatures.computedMatrix;
        }
        
        _layoutFeatures.layoutScaleX = oldScaleX;
        _layoutFeatures.layoutScaleY = oldScaleY;
    }
    
    private function applyPerspectiveProjection():void
    {
        var pmatrix:PerspectiveProjection = super.transform.perspectiveProjection;
        if (pmatrix != null)
        {
            // width, height instead of unscaledWidth, unscaledHeight
            pmatrix.projectionCenter = new Point(width/2,height/2);
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------


    //--------------------------------------------------------------------------
    //
    //  ILayoutElement
    //
    //--------------------------------------------------------------------------


    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getPreferredBoundsWidth(postLayoutTransform:Boolean = true):Number
    {
        return LayoutElementUIComponentUtils.getPreferredBoundsWidth(this,postLayoutTransform? nonDeltaLayoutMatrix():null);
    }

    public function getPreferredBoundsHeight(postLayoutTransform:Boolean = true):Number
    {
        return LayoutElementUIComponentUtils.getPreferredBoundsHeight(this,postLayoutTransform? nonDeltaLayoutMatrix():null);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getMinBoundsWidth(postLayoutTransform:Boolean = true):Number
    {
        return LayoutElementUIComponentUtils.getMinBoundsWidth(this,postLayoutTransform? nonDeltaLayoutMatrix():null);
    }

    public function getMinBoundsHeight(postLayoutTransform:Boolean = true):Number
    {
        return LayoutElementUIComponentUtils.getMinBoundsHeight(this,postLayoutTransform? nonDeltaLayoutMatrix():null);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getMaxBoundsWidth(postLayoutTransform:Boolean = true):Number
    {
        return LayoutElementUIComponentUtils.getMaxBoundsWidth(this,postLayoutTransform? nonDeltaLayoutMatrix():null);
    }

    public function getMaxBoundsHeight(postLayoutTransform:Boolean = true):Number
    {
        return LayoutElementUIComponentUtils.getMaxBoundsHeight(this,postLayoutTransform? nonDeltaLayoutMatrix():null);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getBoundsXAtSize(width:Number, height:Number, postLayoutTransform:Boolean = true):Number
    {
        return LayoutElementUIComponentUtils.getBoundsXAtSize(this, width, height,
                                                              postLayoutTransform ? nonDeltaLayoutMatrix() : null);
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getBoundsYAtSize(width:Number, height:Number, postLayoutTransform:Boolean = true):Number
    {
        return LayoutElementUIComponentUtils.getBoundsYAtSize(this, width, height,
                                                              postLayoutTransform ? nonDeltaLayoutMatrix() : null);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getLayoutBoundsWidth(postLayoutTransform:Boolean = true):Number
    {
        return LayoutElementUIComponentUtils.getLayoutBoundsWidth(this,postLayoutTransform? nonDeltaLayoutMatrix():null);
    }

    public function getLayoutBoundsHeight(postLayoutTransform:Boolean = true):Number
    {
        return LayoutElementUIComponentUtils.getLayoutBoundsHeight(this,postLayoutTransform? nonDeltaLayoutMatrix():null);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getLayoutBoundsX(postLayoutTransform:Boolean = true):Number
    {
        return LayoutElementUIComponentUtils.getLayoutBoundsX(this,postLayoutTransform? nonDeltaLayoutMatrix():null);
    }

    public function getLayoutBoundsY(postLayoutTransform:Boolean = true):Number
    {
        return LayoutElementUIComponentUtils.getLayoutBoundsY(this,postLayoutTransform? nonDeltaLayoutMatrix():null);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function setLayoutBoundsPosition(x:Number, y:Number, postLayoutTransform:Boolean = true):void
    {
        LayoutElementUIComponentUtils.setLayoutBoundsPosition(this,x,y,postLayoutTransform? nonDeltaLayoutMatrix():null);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function setLayoutBoundsSize(width:Number,
                                        height:Number,
                                        postLayoutTransform:Boolean = true):void
    {
        LayoutElementUIComponentUtils.setLayoutBoundsSize(this,width,height,postLayoutTransform? nonDeltaLayoutMatrix():null);
    }
    
	/**
	 *  @private
	 *  Returns the layout matrix, or null if it only consists of translations.
	 */
    private function nonDeltaLayoutMatrix():Matrix
    {
        if (hasDeltaIdentityTransform)
            return null; 
        if (_layoutFeatures != null)
        {
            return _layoutFeatures.layoutMatrix;            
        }
        else
        {
            // Lose scale
            // if scale is actually set (and it's not just our "secret scale"), then 
            // layoutFeatures wont' be null and we won't be down here
            return MatrixUtil.composeMatrix(x, y, 1, 1, rotation,
                        					transformX, transformY);
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  bounds
    //----------------------------------

    /**
     *  The unscaled bounds of the content.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function get bounds():Rectangle
    {
        if (boundingBoxName && boundingBoxName != "" 
            && boundingBoxName in this && this[boundingBoxName])
        {
            return this[boundingBoxName].getBounds(this);
        }
        
        return getBounds(this);
    }
    
    //----------------------------------
    //  parent
    //----------------------------------

    /**
     *  @private
     *  Override the parent getter to skip non-UIComponent parents.
     */
    override public function get parent():DisplayObjectContainer
    {
        return _parent ? _parent : super.parent;
    }
    
    //----------------------------------
    //  parentDocument
    //----------------------------------

    /**
     *  The document containing this component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get parentDocument():Object
    {
        if (document == this)
        {
            var p:IUIComponent = parent as IUIComponent;
            if (p)
                return p.document;

            var sm:ISystemManager = parent as ISystemManager;
            if (sm)
                return sm.document;

            return null;            
        }
        else
        {
            return document;
        }
    }

    //----------------------------------
    //  currentState
    //----------------------------------

    private var _currentState:String;
    
    /**
     *  The current state of this component. For UIMovieClip, the value of the 
     *  <code>currentState</code> property is the current frame label.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get currentState():String
    {
        return _currentState;
    }
    
    public function set currentState(value:String):void
    {
        if (value == _currentState)
            return;
        
        if (!stateMap)
            buildStateMap();
            
        if (stateMap[value])
        {
            // See if we have a transition. The first place to looks is for a specific
            // transition between the old and new states.
            var frameName:String = _currentState + "-" + value + ":start";
            var startFrame:Number;
            var endFrame:Number;
            
            if (stateMap[frameName])
            {
                startFrame = stateMap[frameName].frame;
                endFrame = stateMap[_currentState + "-" + value + ":end"].frame;
            }
            
            if (isNaN(startFrame))
            {
                // Next, look for new-old to play backwards
                frameName = value + "-" + _currentState + ":end";
                if (stateMap[frameName])
                {
                    startFrame = stateMap[frameName].frame;
                    endFrame = stateMap[value + "-" + _currentState  + ":start"].frame;
                }
            }
        
            if (isNaN(startFrame))
            {
                // Next, look for *-new
                frameName = "*-" + value + ":start";
                if (stateMap[frameName])
                {
                    startFrame = stateMap[frameName].frame;
                    endFrame = stateMap["*-" + value + ":end"].frame;
                }   
            }
            
            if (isNaN(startFrame))
            {
                // Next, look for new-* to play backwards
                frameName = value + "-*:end";
                if (stateMap[frameName])
                {
                    startFrame = stateMap[frameName].frame;
                    endFrame = stateMap[value + "-*:start"].frame;
                }
            }
            
            if (isNaN(startFrame))
            {
                // Next, look for old-*
                frameName = _currentState + "-*:start";
                if (stateMap[frameName])
                {
                    startFrame = stateMap[frameName].frame;
                    endFrame = stateMap[_currentState + "-*:end"].frame;
                }
            }
            
            if (isNaN(startFrame))
            {
                // Next, look for *-old to play backwards
                frameName = "*-" + _currentState + ":end";
                if (stateMap[frameName])
                {
                    startFrame = stateMap[frameName].frame;
                    endFrame = stateMap["*-" + _currentState + ":start"].frame;
                }
            }
            
            if (isNaN(startFrame))
            {
                // Next, look for *-*
                frameName = "*-*:start";
                if (stateMap[frameName])
                {
                    startFrame = stateMap[frameName].frame;
                    endFrame = stateMap["*-*:end"].frame;
                }
            }
            
            // Finally, just look for the frame of the new state. 
            if (isNaN(startFrame) && (value in stateMap))
            {
                startFrame = stateMap[value].frame;
            }

            // If, after all that searching, we still haven't found a frame to go to, let's
            // get outta here.          
            if (isNaN(startFrame))
                return;
            
            var event:StateChangeEvent = new StateChangeEvent(StateChangeEvent.CURRENT_STATE_CHANGING);
            event.oldState = _currentState;
            event.newState = value;
            dispatchEvent(event);
            
            if (isNaN(endFrame))
            {
                // No transtion - go immediately to the state
                gotoAndStop(startFrame);
                transitionDirection = 0;
            }
            else
            {
                addEventListener(Event.ENTER_FRAME, transitionEnterFrameHandler, false, 0, true);
                
                // If the new transition is starting inside the current transition, start from
                // the current frame location.
                if (currentFrame < Math.min(startFrame, endFrame) || currentFrame > Math.max(startFrame, endFrame))
                    gotoAndStop(startFrame);
                else
                    startFrame = currentFrame;
                    
                transitionStartFrame = startFrame;
                transitionEndFrame = endFrame;
                transitionDirection = (endFrame > startFrame) ? 1 : -1;
                transitionEndState = value;
            }
            
            event = new StateChangeEvent(StateChangeEvent.CURRENT_STATE_CHANGE);
            event.oldState = _currentState;
            event.newState = value;
            dispatchEvent(event);

            _currentState = value;
        }
    }

    /**
     *  @private
     */
    override public function get tabEnabled():Boolean
    {
        return super.tabEnabled;
    }
    
    /**
     *  @private
     */
    override public function set tabEnabled(value:Boolean):void
    {
        super.tabEnabled = value;
        explicitTabEnabledChanged = true;
    }
    
    //--------------------------------------------------------------------------
    //
    //  IUIComponent methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Initialize the object.
     *
     *  @see mx.core.UIComponent#initialize()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function initialize():void
    {
        initialized = true;
        
        dispatchEvent(new FlexEvent(FlexEvent.PREINITIALIZE));
        
        // Hide the bounding box, if present
        if (boundingBoxName && boundingBoxName != "" 
            && boundingBoxName in this && this[boundingBoxName])
        {
            this[boundingBoxName].visible = false;
        }
        
        // get the size before we add children or anything else
        validateMeasuredSize();
        
        // Location check.
        if (isNaN(oldX))
            oldX = x;
        
        if (isNaN(oldY))
            oldY = y;

        if (isNaN(oldWidth))
            oldWidth = _width = measuredWidth;
    
        if (isNaN(oldHeight))
            oldHeight = _height = measuredHeight;
        
        // Set initial explicit size, if needed
        if (explicitSizeChanged)
        {
            explicitSizeChanged = false;
            setActualSize(getExplicitOrMeasuredWidth(), getExplicitOrMeasuredHeight());
        }
        
        // Look for focus candidates
        findFocusCandidates(this);
        
        // Call initialize() on any IUIComponent children
        for (var i:int = 0; i < numChildren; i++)
        {
            var child:IUIComponent = getChildAt(i) as IUIComponent;
            
            if (child)
                child.initialize();
        }
        
        dispatchEvent(new FlexEvent(FlexEvent.INITIALIZE));
        dispatchEvent(new FlexEvent(FlexEvent.CREATION_COMPLETE));
    }
    
    /**
     *  Called by Flex when a UIComponent object is added to or removed from a parent.
     *  Developers typically never need to call this method.
     *
     *  @param p The parent of this UIComponent object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function parentChanged(p:DisplayObjectContainer):void
    {
        if (!p)
        {
            _parent = null;
        }
        else if (p is IUIComponent || p is ISystemManager)
        {
            _parent = p;
        }
        else
        {
            _parent = p.parent;
        }
    }
    
    /**
     *  A convenience method for determining whether to use the
     *  explicit or measured width
     *
     *  @return A Number which is explicitWidth if defined
     *  or measuredWidth if not.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function getExplicitOrMeasuredWidth():Number
    {
        if (isNaN(explicitWidth))
        {
            var mWidth:Number = measuredWidth;
            
            if (!isNaN(explicitMinWidth) && mWidth < explicitMinWidth)
                mWidth = explicitMinWidth;
            
            if (!isNaN(explicitMaxWidth) && mWidth > explicitMaxWidth)
                mWidth = explicitMaxWidth;
            
            return mWidth;
        }

        return explicitWidth;
    }

    /**
     *  A convenience method for determining whether to use the
     *  explicit or measured height
     *
     *  @return A Number which is explicitHeight if defined
     *  or measuredHeight if not.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function getExplicitOrMeasuredHeight():Number
    {
        if (isNaN(explicitHeight))
        {
            var mHeight:Number = measuredHeight;
            
            if (!isNaN(explicitMinHeight) && mHeight < explicitMinHeight)
                mHeight = explicitMinHeight;
            
            if (!isNaN(explicitMaxHeight) && mHeight > explicitMaxHeight)
                mHeight = explicitMaxHeight;
            
            return mHeight;
        }

        return explicitHeight;
    }
    
    /**
     *  Called when the <code>visible</code> property changes.
     *  You should set the <code>visible</code> property to show or hide
     *  a component instead of calling this method directly.
     *
     *  @param value The new value of the <code>visible</code> property. 
     *  Specify <code>true</code> to show the component, and <code>false</code> to hide it. 
     *
     *  @param noEvent If <code>true</code>, do not dispatch an event. 
     *  If <code>false</code>, dispatch a <code>show</code> event when 
     *  the component becomes visible, and a <code>hide</code> event when 
     *  the component becomes invisible.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function setVisible(value:Boolean, noEvent:Boolean = false):void
    {
        _visible = value;

        if (designLayer && !designLayer.effectiveVisibility)
            value = false; 
        
        if (super.visible == value)
            return;

        super.visible = value;
        
        if (!noEvent)
            dispatchEvent(new FlexEvent(value ? FlexEvent.SHOW : FlexEvent.HIDE));
    }

    /**
     *  Returns <code>true</code> if the chain of <code>owner</code> properties 
     *  points from <code>child</code> to this UIComponent.
     *
     *  @param child A UIComponent.
     *
     *  @return <code>true</code> if the child is parented or owned by this UIComponent.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function owns(displayObject:DisplayObject):Boolean
    {
        while (displayObject && displayObject != this)
        {
            // do a parent walk
            if (displayObject is IUIComponent)
                displayObject = IUIComponent(displayObject).owner;
            else
                displayObject = displayObject.parent;
        }
        
        return displayObject == this;
    }

    //--------------------------------------------------------------------------
    //
    //  IFlexDisplayObject methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Moves this object to the specified x and y coordinates.
     * 
     *  @param x The new x-position for this object.
     * 
     *  @param y The new y-position for this object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function move(x:Number, y:Number):void
    {       
        var changed:Boolean = false;

        if (x != this.x)
        {
            if (_layoutFeatures == null)
                super.x  = x;
            else
                _layoutFeatures.layoutX = x;
            
            dispatchEvent(new Event("xChanged"));
            changed = true;
        }

        if (y != this.y)
        {
            if (_layoutFeatures == null)
                super.y  = y;
            else
                _layoutFeatures.layoutY = y;
            
            dispatchEvent(new Event("yChanged"));
            changed = true;
        }

        if (changed)
        {
            invalidateTransform();
            dispatchMoveEvent();
        }
    }

    /**
     *  Sets the actual size of this object.
     *
     *  <p>This method is mainly for use in implementing the
     *  <code>updateDisplayList()</code> method, which is where
     *  you compute this object's actual size based on
     *  its explicit size, parent-relative (percent) size,
     *  and measured size.
     *  You then apply this actual size to the object
     *  by calling <code>setActualSize()</code>.</p>
     *
     *  <p>In other situations, you should be setting properties
     *  such as <code>width</code>, <code>height</code>,
     *  <code>percentWidth</code>, or <code>percentHeight</code>
     *  rather than calling this method.</p>
     * 
     *  @param newWidth The new width for this object.
     * 
     *  @param newHeight The new height for this object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function setActualSize(newWidth:Number, newHeight:Number):void
    {
        // Remember our new actual size so we can report it later in the
        // width/height getters.
        _width = newWidth;
        _height = newHeight;
        
        // Use scaleX/scaleY to change our size since the new size is based
        // on our measured size, which can be different than our actual size.
        scaleXDueToSizing = (newWidth / measuredWidth);
        scaleYDueToSizing = (newHeight / measuredHeight);
        $scaleX = scaleX*scaleXDueToSizing;
        $scaleY = scaleY*scaleYDueToSizing;
        
        // need to apply this scale if using layout offsets
        invalidateTransform();
        
        if (sizeChanged(width, oldWidth) || sizeChanged(height, oldHeight))
            dispatchResizeEvent();
    }

    //--------------------------------------------------------------------------
    //
    //  IFocusManagerComponent methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Called by the FocusManager when the component receives focus.
     *  The component may in turn set focus to an internal component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function setFocus():void
    {
        stage.focus = focusableObjects[reverseDirectionFocus ? focusableObjects.length - 1 : 0];
        addFocusEventListeners();
    }

    /**
     *  Called by the FocusManager when the component receives focus.
     *  The component should draw or hide a graphic 
     *  that indicates that the component has focus.
     *
     *  @param isFocused If <code>true</code>, draw the focus indicator,
     *  otherwise hide it.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function drawFocus(isFocused:Boolean):void
    {
        
    }

    //--------------------------------------------------------------------------
    //
    //  Layout methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Validate the measuredWidth and measuredHeight properties to match the 
     *  current size of the content.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private function validateMeasuredSize():void
    {
        if (validateMeasuredSizeFlag)
        {
            validateMeasuredSizeFlag = false;
            
            _measuredWidth = bounds.width;
            _measuredHeight = bounds.height;
        }
    }
    
    /**
     *  Notify our parent that our size has changed.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function notifySizeChanged():void
    {
        invalidateParentSizeAndDisplayList();
    }
    
    /**
     *  @private
     */
    private function dispatchMoveEvent():void
    {
        var moveEvent:MoveEvent = new MoveEvent(MoveEvent.MOVE);
        
        moveEvent.oldX = oldX;
        moveEvent.oldY = oldY;
        dispatchEvent(moveEvent);
        
        oldX = x;
        oldY = y;
    }

    /**
     *  @private
     */
    protected function dispatchResizeEvent():void
    {
        var resizeEvent:ResizeEvent = new ResizeEvent(ResizeEvent.RESIZE);
        
        resizeEvent.oldWidth = oldWidth;
        resizeEvent.oldHeight = oldHeight;
        dispatchEvent(resizeEvent);
        
        oldWidth = width;
        oldHeight = height;
    }
    
    /**
     *  @private
     */
    protected function sizeChanged(oldValue:Number, newValue:Number):Boolean
    {
        // Only detect size changes that are greater than 1 pixel. Flex rounds sizes to the nearest
        // pixel, which causes infinite resizing if we have a fractional pixel width and are 
        // detecting changes that are smaller than 1 pixel.
        return Math.abs(oldValue - newValue) > 1;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Focus methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Recursively finds all children that have tabEnabled=true and adds them
     *  to the focusableObjects array.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function findFocusCandidates(obj:DisplayObjectContainer):void
    {
        for (var i:int = 0; i < obj.numChildren; i++)
        {
            var child:InteractiveObject = obj.getChildAt(i) as InteractiveObject;
            
            if (child && child.tabEnabled)
            {
                focusableObjects.push(child);
                if (!explicitTabEnabledChanged)
                {
                    tabEnabled = true;
                    tabFocusEnabled = true;
                }
            }
                
            if (child is DisplayObjectContainer)
                findFocusCandidates(DisplayObjectContainer(child));
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  State/Transition methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Build a map of state name to labels.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private function buildStateMap():void
    {
        var labels:Array = currentLabels;
        
        stateMap = {};
        
        for (var i:int = 0; i < labels.length; i++) 
        {
            stateMap[labels[i].name] = labels[i];
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  This enter frame handler is used when our width, height, x, or y 
     *  value changes.  This is so the change can be delayed so that setting 
     *  x and y at the same time only results in one change event.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function enterFrameHandler(event:Event):void
    {
        // explicit size change check.
        if (explicitSizeChanged)
        {
            explicitSizeChanged = false;
            setActualSize(getExplicitOrMeasuredWidth(), getExplicitOrMeasuredHeight());
        }
        
        if (x != oldX || y != oldY)
            dispatchMoveEvent();
        
        removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
    }
    
    /**
     *  This enter frame handler watches the flash object's size to see if
     *  it has changed.  If it's chagned, we will notify our flex parent of 
     *  the change.  This size change may also cause the flash component 
     *  to rescale if it's been explicitly sized so it fits within the 
     *  correct bounds.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
    protected function autoUpdateMeasuredSizeEnterFrameHandler(event:Event):void
    {
        // Size check.
        var currentBounds:Rectangle = bounds;
        
        // take secret scale into account as it's our real width/height
        currentBounds.width *= scaleXDueToSizing;
        currentBounds.height *= scaleYDueToSizing;
        
        if (sizeChanged(currentBounds.width, oldWidth) || sizeChanged(currentBounds.height, oldHeight))
        {
            _width = currentBounds.width;
            _height = currentBounds.height;
            validateMeasuredSizeFlag = true;
            notifySizeChanged(); 
            dispatchResizeEvent();
        }
        else if (sizeChanged(width, oldWidth) || sizeChanged(height, oldHeight))
        {
            dispatchResizeEvent();
        }
    }
    
    /**
     *  This enter frame handler watches our currentLabel for changes so that it 
     *  can be reflected in the currentState.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
    protected function autoUpdateCurrentStateEnterFrameHandler(event:Event):void
    {
        // Check for the current state.  This is really only checked for if 
        // trackStateChanged == true.  This is so that if we magically land 
        // on a "foo" labelled frame, we return "foo" as the currentState.
        if (currentLabel && currentLabel.indexOf(":") < 0 && currentLabel != _currentState)
            _currentState = currentLabel;
    }
    
    /**
     *  This enter frame handler progresses through transitions
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
    protected function transitionEnterFrameHandler(event:Event):void
    {       
        // Play the next frame of the transition, if needed.
        var newFrame:Number = currentFrame + transitionDirection;

        if ((transitionDirection > 0 && newFrame >= transitionEndFrame) || 
            (transitionDirection < 0 && newFrame <= transitionEndFrame))
        {
            gotoAndStop(stateMap[transitionEndState].frame);
            transitionDirection = 0;
            removeEventListener(Event.ENTER_FRAME, transitionEnterFrameHandler);
        }
        else
        {
            gotoAndStop(newFrame);
        }
    }
    
    /**
     *  Add the focus event listeners.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private function addFocusEventListeners():void
    {
        stage.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler, false, 1, true);
        stage.addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler, false, 0, true);
        focusListenersAdded = true;
    }
    
    /**
     *  Remove our focus event listeners.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private function removeFocusEventListeners():void
    {
        stage.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler);
        stage.removeEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);
        focusListenersAdded = false;
    }
    
    /**
     *  Called when the focus is changed by keyboard navigation (TAB or Shift+TAB).
     *  If we are currently managing the focus, stop the event propagation to
     *  "steal" the event from the Flex focus manager.
     *  If we are at the end of our focusable items (first item for Shift+TAB, or
     *  last item for TAB), remove our event handlers to give control back
     *  to the Flex focus manager.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private function keyFocusChangeHandler(event:FocusEvent):void
    {
        if (event.keyCode == Keyboard.TAB)
        {
            if (stage.focus == focusableObjects[event.shiftKey ? 0 : focusableObjects.length - 1])
                removeFocusEventListeners();
            else
                event.stopImmediatePropagation();
        }
    }
    
    /**
     *  Called when focus is entering any of our children. Make sure our
     *  focus event handlers are called so we can take control from the
     *  Flex focus manager.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function focusInHandler(event:FocusEvent):void
    {
        if (!focusListenersAdded)
            addFocusEventListeners();
    }
    
    /**
     *  Called when focus is leaving an object. We check to see if the new
     *  focus item is in our focusableObjects list, and if not we remove
     *  our event listeners to give control back to the Flex focus manager.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private function focusOutHandler(event:FocusEvent):void
    {
        if (focusableObjects.indexOf(event.relatedObject) == -1)
            removeFocusEventListeners();
    }
    
    /**
     *  Called during event capture phase when keyboard navigation is changing
     *  focus. All we do here is set a flag so we know which direction the
     *  focus is changing - TAB = forward; Shift+TAB = reverse.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private function keyFocusChangeCaptureHandler(event:FocusEvent):void
    {
        reverseDirectionFocus = event.shiftKey;
    }

    private function creationCompleteHandler(event:Event):void
    {
        removeEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
              
        // Add a key focus change handler at the capture phase. We use this to 
        // determine focus direction in the setFocus() call.
        if (systemManager)
            systemManager.stage.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeCaptureHandler,
                                                 true, 0, true);
        else if (parentDocument && parentDocument.systemManager)
            parentDocument.systemManager.stage.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeCaptureHandler,
                                                 true, 0, true);
    }
    
    /**
     *  @private
     */
    protected function layer_PropertyChange(event:PropertyChangeEvent):void
    {
        switch (event.property)
        {
            case "effectiveVisibility":
            {
                var newValue:Boolean = (event.newValue && _visible);            
                if (newValue != super.visible)
                    super.visible = newValue;
                break;
            }
            case "effectiveAlpha":
            {
                var newAlpha:Number = Number(event.newValue) * _alpha;
                if (newAlpha != super.alpha)
                    super.alpha = newAlpha;
                break;
            }
        }
    }
    
   // IAutomationObject Interface defenitions   
   private var _automationDelegate:IAutomationObject;

    /**
     *  The delegate object that handles the automation-related functionality.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get automationDelegate():Object
    {
        return _automationDelegate;
    }

    /**
     *  @private
     */
    public function set automationDelegate(value:Object):void
    {
        _automationDelegate = value as IAutomationObject;
    }

    //----------------------------------
    //  automationName
    //----------------------------------

    /**
     *  @private
     *  Storage for the <code>automationName</code> property.
     */
    private var _automationName:String = null;

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get automationName():String
    {
        if (_automationName)
            return _automationName; 
        if (automationDelegate)
           return automationDelegate.automationName;
        
        return "";
    }

    /**
     *  @private
     */
    public function set automationName(value:String):void
    {
        _automationName = value;
    }

    /**
     *  @copy mx.automation.IAutomationObject#automationValue
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get automationValue():Array
    {
        if (automationDelegate)
           return automationDelegate.automationValue;
        
        return [];
    }
    
    //----------------------------------
    //  automationOwner
    //----------------------------------
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
    public function get automationOwner():DisplayObjectContainer
    {
        return owner;
    }
    
    //----------------------------------
    //  automationParent
    //----------------------------------
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
    public function get automationParent():DisplayObjectContainer
    {
        return parent;
    }
    
    //----------------------------------
    //  automationEnabled
    //----------------------------------
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
    public function get automationEnabled():Boolean
    {
        return enabled;
    }
    
    //----------------------------------
    //  automationVisible
    //----------------------------------
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
    public function get automationVisible():Boolean
    {
        return visible;
    }

    //----------------------------------
    //  showInAutomationHierarchy
    //----------------------------------

    /**
     *  @private
     *  Storage for the <code>showInAutomationHierarchy</code> property.
     */
    private var _showInAutomationHierarchy:Boolean = true;
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get showInAutomationHierarchy():Boolean
    {
        return _showInAutomationHierarchy;
    }
    
    /**
     *  @private
     */
    public function set showInAutomationHierarchy(value:Boolean):void
    {
        _showInAutomationHierarchy = value;
    }


    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function createAutomationIDPart(child:IAutomationObject):Object
    {
        if (automationDelegate)
            return automationDelegate.createAutomationIDPart(child);
        return null;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function createAutomationIDPartWithRequiredProperties(child:IAutomationObject, 
                                                                 properties:Array):Object
    {
        if (automationDelegate)
            return automationDelegate.createAutomationIDPartWithRequiredProperties(child, properties);
        return null;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function resolveAutomationIDPart(criteria:Object):Array
    {
        if (automationDelegate)
            return automationDelegate.resolveAutomationIDPart(criteria);
        return [];
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function getAutomationChildAt(index:int):IAutomationObject
    {
        if (automationDelegate)
            return automationDelegate.getAutomationChildAt(index);
        return null;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getAutomationChildren():Array
    {
        if (automationDelegate)
            return automationDelegate.getAutomationChildren();
        return null;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get numAutomationChildren():int
    {
        if (automationDelegate)
            return automationDelegate.numAutomationChildren;
        return 0;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get automationTabularData():Object
    {
        if (automationDelegate)
            return automationDelegate.automationTabularData;
        return null;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function replayAutomatableEvent(event:Event):Boolean
    {
        if (automationDelegate)
            return automationDelegate.replayAutomatableEvent(event);
        return false;
    }
}
}
