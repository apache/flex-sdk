////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components.supportClasses
{
    
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.ui.Keyboard;
import flash.utils.Timer;

import mx.core.IVisualElement;
import mx.core.InteractionMode;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.SandboxMouseEvent;
import mx.events.TouchInteractionEvent;
import mx.managers.IFocusManagerComponent;

import spark.core.IDisplayText;
import spark.primitives.BitmapImage;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

include "../../styles/metadata/BasicInheritingTextStyles.as"

/**
 *  The radius of the corners of this component.
 *
 *  @default 4
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="cornerRadius", type="Number", format="Length", inherit="no", theme="spark", minValue="0.0")]

/**
 *  The alpha of the focus ring for this component.
 *
 *  @default 0.5
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="focusAlpha", type="Number", inherit="no", theme="spark, mobile", minValue="0.0", maxValue="1.0")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:focusColor
 *   
 *  @default 0x70B2EE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="focusColor", type="uint", format="Color", inherit="yes", theme="spark, mobile")]

/**
 *  Class or instance to use as the default icon.
 *  The icon can render from various graphical sources, including the following:  
 *  <ul>
 *   <li>A Bitmap or BitmapData instance.</li>
 *   <li>A class representing a subclass of DisplayObject. The BitmapFill 
 *       instantiates the class and creates a bitmap rendering of it.</li>
 *   <li>An instance of a DisplayObject. The BitmapFill copies it into a 
 *       Bitmap for filling.</li>
 *   <li>The name of an external image file. </li>
 *  </ul>
 * 
 *  @default null 
 * 
 *  @see spark.primitives.BitmapImage.source
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="icon", type="Object", inherit="no")]

/**
 *  Orientation of the icon in relation to the label.
 *  Valid MXML values are <code>right</code>, <code>left</code>,
 *  <code>bottom</code>, and <code>top</code>.
 *
 *  <p>In ActionScript, you can use the following constants
 *  to set this property:
 *  <code>IconPlacement.RIGHT</code>,
 *  <code>IconPlacement.LEFT</code>,
 *  <code>IconPlacement.BOTTOM</code>, and
 *  <code>IconPlacement.TOP</code>.</p>
 *
 *  @default IconPlacement.LEFT
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="iconPlacement", type="String", enumeration="top,bottom,right,left", inherit="no", theme="spark, mobile")]

/**
 *  Number of milliseconds to wait after the first <code>buttonDown</code>
 *  event before repeating <code>buttonDown</code> events at each 
 *  <code>repeatInterval</code>.
 * 
 *  @default 500
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="repeatDelay", type="Number", format="Time", inherit="no", minValue="0.0")]

/**
 *  Number of milliseconds between <code>buttonDown</code> events
 *  if the user presses and holds the mouse on a button.
 *  
 *  @default 35
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="repeatInterval", type="Number", format="Time", inherit="no", minValueExclusive="0.0")]

/**
 *  When in touch interaction mode, the number of milliseconds to wait after the user 
 *  interaction has occured before showing the component in a visually down state.
 * 
 *  <p>The reason for this delay is because when a user initiates a scroll gesture, we don't want 
 *  components to flicker as they touch the screen.  By having a reasonable delay, we make 
 *  sure that the user still gets feedback when they press down on a component, but that the 
 *  feedback doesn't come too quickly that it gets displayed during a scroll gesture 
 *  operation.</p>
 *  
 *  <p>If the mobile theme is applied, the default value for this style is 100 ms for 
 *  components inside of a Scroller and 0 ms for components outside of a Scroller.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="touchDelay", type="Number", format="Time", inherit="yes", minValue="0.0")]

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the user presses the ButtonBase control.
 *  If the <code>autoRepeat</code> property is <code>true</code>,
 *  this event is dispatched repeatedly as long as the button stays down.
 *
 *  @eventType mx.events.FlexEvent.BUTTON_DOWN
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="buttonDown", type="mx.events.FlexEvent")]

//--------------------------------------
//  Skin states
//--------------------------------------

/**
 *  Up State of the Button
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("up")]

/**
 *  Over State of the Button
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("over")]

/**
 *  Down State of the Button
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("down")]

/**
 *  Disabled State of the Button
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("disabled")]
 
//--------------------------------------
//  Other metadata
//--------------------------------------

[AccessibilityClass(implementation="spark.accessibility.ButtonBaseAccImpl")]

[DefaultTriggerEvent("click")]

[DefaultProperty("label")]

/**
 *  The ButtonBase class is the base class for the all Spark button components.
 *  The Button and ToggleButtonBase classes are subclasses of ButtonBase.
 *  ToggleButton. 
 *  The CheckBox and RadioButton classes are subclasses of ToggleButtonBase.
 * 
 *  @mxml
 *
 *  <p>The <code>&lt;s:ButtonBase&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:ButtonBase
 *    <strong>Properties</strong>
 *    autoRepeat="false"
 *    content="null"
 *    label=""
 *    stickyHighlighting="false"
 *  
 *    <strong>Events</strong>
 *    buttonDown="<i>No default</i>"
 *
 *    <strong>Styles</strong>
 *    alignmentBaseline="USE_DOMINANT_BASELINE"
 *    cffHinting="HORIZONTAL_STEM"
 *    color="0"
 *    cornerRadius="4"
 *    digitCase="DEFAULT"
 *    digitWidth="DEFAULT"
 *    direction="LTR"
 *    dominantBaseline="AUTO"
 *    focusAlpha="0.5"
 *    focusColor="0x70B2EE"
 *    fontFamily="Arial"
 *    fontLookup="DEVICE"
 *    fontSize="12"
 *    fontStyle="NORMAL"
 *    fontWeight="NORMAL"
 *    justificationRule="AUTO"
 *    justificationStyle="AUTO"
 *    kerning="AUTO"
 *    ligatureLevel="COMMON"
 *    lineHeight="120%"
 *    lineThrough="false"
 *    locale="en"
 *    renderingMode="CFF"
 *    repeatDelay="500"
 *    repeatInterval="35"
 *    textAlign="START"
 *    textAlignLast="START"
 *    textAlpha="1"
 *    textDecoration="NONE"
 *    textJustify="INTER_WORD"
 *    trackingLeft="0"
 *    trackingRight="0"
 *    typographicCase="DEFAULT"
 *    wordSpacing="100%"
 *  /&gt;
 *  </pre>
 *
 *  @see spark.components.Button
 *  @see spark.components.supportClasses.ToggleButtonBase
 *  @see spark.components.ToggleButton
 *  @see spark.components.CheckBox
 *  @see spark.components.RadioButton
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ButtonBase extends SkinnableComponent implements IFocusManagerComponent
{
    include "../../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class mixins
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Placeholder for mixin by ButtonAccImpl.
     */
    mx_internal static var createAccessibilityImplementation:Function;

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
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */    
    public function ButtonBase()
    {
        super();

        // DisplayObjectContainer properties.
        // Setting mouseChildren to false ensures that mouse events
        // are dispatched from the Button itself,
        // not from its skins, icons, or TextField.
        // One reason for doing this is that if you press the mouse button
        // while over the TextField and release the mouse button while over
        // a skin or icon, we want the player to dispatch a "click" event.
        // Another is that if mouseChildren were true and someone uses
        // Sprites rather than Shapes for the skins or icons,
        // then we we wouldn't get a click because the current skin or icon
        // changes between the mouseDown and the mouseUp.
        // (This doesn't happen even when mouseChildren is true if the skins
        // and icons are Shapes, because Shapes never dispatch mouse events;
        // they are dispatched from the Button in this case.)
        mouseChildren = false;
        
        // add event listeners to the button
        addHandlers();
    }   
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Remember whether we have fired an event already,
     *  so that we don't fire a second time.
     */
    private var _downEventFired:Boolean = false;
    
    /**
     *  @private
     *  <code>true</code> when we need to check whether to dispatch
     *  a button down event
     */
    private var checkForButtonDownConditions:Boolean = false;

    /**
     *  @private
     *  Timer for doing auto-repeat.
     */
    private var autoRepeatTimer:Timer;
    
    /**
     *  @private
     *  Timer for putting the button in the down state on a delay
     *  timer because of touch input.
     */
    private var mouseDownSelectTimer:Timer;
    
    /**
     *  @private
     *  Timer for putting the button in the up state.  This makes sure 
     *  even when we have a delay to select an item and someone mouses up
     *  before that delay, the user still gets some visual feedback that 
     *  the button was actually selected.
     */
    private var mouseUpDeselectTimer:Timer;
	
	/**
	 *  @private
	 *  When faking a mouseDown after a mouse up has occurred, if we get a rollOut
	 *  event, we don't want to immediately set hovered = false so we can maintain 
	 *  the down state until the mouseUpDeselectTimer is finished.  So we keep track
	 *  that a rollOut event occurred and honor it later.
	 */
	private var rollOutWhileFakingDownState:Boolean = false;
	
	/**
	 *  @private
	 *  When there is a touchDelay and the touch interaction is complete (user mouseUp) before 
	 *  the touchDelay is over, usually the component goes in to the down state for a period 
	 *  of time to ensure the user gets visual feedback on this operation. 
	 *  This behavior is for quick taps that occur on a component and ensures
	 *  that the user receives reasonable feedback for their button click operation.
	 *  
	 *  <p>This property can disable that behavior.  If set to <code>false</code>,
	 *  which is the default, then on a quick tap, the Button will go in to the down state 
	 *  for touchDelay milli-seconds.  If set to <code>true</code>, 
	 *  on a quick tap, the Button does not go in to the down state at all.  This 
	 *  is useful in toggle buttons, where there's no need to go in to the down state 
	 *  to give the user feedback--going in to the selected state is good enough.</p>
	 */
	mx_internal var disableMinimumDownStateTime:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Skin parts
    //
    //--------------------------------------------------------------------------

    [SkinPart(required="false")]
    
    /**
     *  A skin part that defines an optional icon for the button. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public var iconDisplay:BitmapImage;
    
    [SkinPart(required="false")]

    /**
     *  A skin part that defines the label of the button. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var labelDisplay:IDisplayText;

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  baselinePosition
    //----------------------------------
    
    /**
     *  @private
     */
    override public function get baselinePosition():Number
    {
        return getBaselinePositionForPart(labelDisplay as IVisualElement);
    }

    //----------------------------------
    //  toolTip
    //----------------------------------
    
    /**
     *  @private
     */
    private var _explicitToolTip:Boolean = false;
    
    [Inspectable(category="General", defaultValue="null")]

    /**
     *  @private
     */
    override public function set toolTip(value:String):void
    {
        super.toolTip = value;

        _explicitToolTip = value != null;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  autoRepeat
    //----------------------------------

    /**
     *  @private
     */
    private var _autoRepeat:Boolean;

    [Inspectable(defaultValue="false")]

    /**
     *  Specifies whether to dispatch repeated <code>buttonDown</code>
     *  events if the user holds down the mouse button.
     *
     *  @default false
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get autoRepeat():Boolean
    {
        return _autoRepeat;
    }
    
    /**
     *  @private
     */
    public function set autoRepeat(value:Boolean):void
    {
        if (value == _autoRepeat)
            return;
         
        _autoRepeat = value;
        checkAutoRepeatTimerConditions(isDown());
    }

    //----------------------------------
    //  content
    //----------------------------------

    /**
     *  @private
     *  Storage for the content property.
     */
    private var _content:*;
    
    [Bindable("contentChange")]

    /**
     *  The <code>content</code> property lets you pass an arbitrary object
     *  to be used in a custom skin of the button.
     * 
     *  When a skin defines the optional part <code>labelDisplay</code> then
     *  a string representation of <code>content</code> will be pushed down to
     *  that part's <code>text</code> property.
     *
     *  The default skin uses this mechanism to render the <code>content</code>
     *  as the button label.  
     * 
     *  <p>The <code>label</code> property is a <code>String</code> typed
     *  facade of this property.  This property is bindable and it shares
     *  the "contentChange" event with the <code>label</code> property.</p>
     * 
     *  @default null
     *  @eventType contentChange
     *  @see #label
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get content():Object
    {
        return _content;
    }

    /**
     *  @private
     */
    public function set content(value:Object):void
    {
        _content = value;

        // Push to the optional labelDisplay skin part
        if (labelDisplay)
            labelDisplay.text = label;
        dispatchEvent(new Event("contentChange"));
    }

    //----------------------------------
    //  hovered
    //----------------------------------

    /**
     *  @private
     *  Storage for the hovered property 
     */
    private var _hovered:Boolean = false;    

    /**
     *  Indicates whether the mouse pointer is over the button.
     *  Used to determine the skin state.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    protected function get hovered():Boolean
    {
        return _hovered;
    }
    
    /**
     *  @private
     */ 
    protected function set hovered(value:Boolean):void
    {
        if (value == _hovered)
            return;

        _hovered = value;
        invalidateButtonState();
    }

    //----------------------------------
    //  keepDown
    //----------------------------------
    
    /**
     *  @private
     */
    private var _keepDown:Boolean = false;
    
    /**
     *  @private
     *  If true, forces the button to be in the down state
     *  Set fireEvent to false if you want to supress the ButtonDown event. 
     *  This is useful if you have programmatically set keepDown but the 
     *  mouse is not over the button. 
     */
    mx_internal function keepDown(down:Boolean, fireEvent:Boolean = true):void
    {
        if (_keepDown == down)
            return;
        
        _keepDown = down;
        
        if (!fireEvent) // Don't let the ButtonDown event get fired
            _downEventFired = true;
          
        if (_keepDown)
            invalidateSkinState();
        else
            invalidateButtonState();
    }

    //----------------------------------
    //  keyboardPressed
    //----------------------------------

    /**
     *  @private
     *  Storage for the keyboardPressed property 
     */
    private var _keyboardPressed:Boolean = false;    

    /**
     *  Indicates whether a keyboard key is pressed while the button is in focus.
     *  Used to determine the skin state.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    protected function get keyboardPressed():Boolean
    {
        return _keyboardPressed;
    }
    
    /**
     *  @private
     */
    protected function set keyboardPressed(value:Boolean):void
    {
        if (value == _keyboardPressed)
            return;

        _keyboardPressed = value;
        invalidateButtonState();
    }
    
    //----------------------------------
    //  label
    //----------------------------------

    [Bindable("contentChange")]
    [Inspectable(category="General", defaultValue="")]

    /**
     *  Text to appear on the ButtonBase control.
     * 
     *  <p>If the label is wider than the ButtonBase control,
     *  the label is truncated and terminated by an ellipsis (...).
     *  The full label displays as a tooltip
     *  when the user moves the mouse over the control.
     *  If you have also set a tooltip by using the <code>tooltip</code>
     *  property, the tooltip is displayed rather than the label text.</p>
     *
     *  <p>This is the default ButtonBase property.</p>
     *
     *  <p>This property is a <code>String</code> typed facade to the
     *  <code>content</code> property.  This property is bindable and it shares
     *  dispatching the "contentChange" event with the <code>content</code>
     *  property.</p> 
     *  
     *  @default ""
     *  @see #content
     *  @eventType contentChange
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function set label(value:String):void
    {
        // label property is just a proxy to the content.
        // The content setter will dispatch the event.
        content = value;
    }

    /**
     *  @private
     */
    public function get label():String          
    {
        return (content != null) ? content.toString() : "";
    }
    
    //----------------------------------
    //  mouseCaptured
    //----------------------------------

    /**
     *  @private
     *  Storage for the mouseCaptured property 
     */
    private var _mouseCaptured:Boolean = false;    

    /**
     *  Indicates whether the mouse is down and the mouse pointer was
     *  over the button when <code>MouseEvent.MOUSE_DOWN</code> was first dispatched.
     *  Used to determine the skin state.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */    
    protected function get mouseCaptured():Boolean
    {
        return _mouseCaptured;
    }
    
    /**
     *  @private
     */
    protected function set mouseCaptured(value:Boolean):void
    {
        if (value == _mouseCaptured)
            return;

        _mouseCaptured = value;        
        invalidateButtonState();

        // System mouse handlers are not needed when the button is not mouse captured
        if (!value)
            removeSystemMouseHandlers();
    }
    
    //----------------------------------
    //  stickyHighlighting
    //----------------------------------

    /**
     *  @private
     *  Storage for the stickyHighlighting property 
     */
    private var _stickyHighlighting:Boolean = false;    

    /**
     *  If <code>false</code>, the button displays its down skin
     *  when the user presses it but changes to its over skin when
     *  the user drags the mouse off of it.
     *  If <code>true</code>, the button displays its down skin
     *  when the user presses it, and continues to display this skin
     *  when the user drags the mouse off of it.
     *
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get stickyHighlighting():Boolean
    {
        return _stickyHighlighting
    }

    /**
     *  @private
     */
    public function set stickyHighlighting(value:Boolean):void
    {
        if (value == _stickyHighlighting)
            return;

        _stickyHighlighting = value;
        invalidateButtonState();
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function initializeAccessibility():void
    {
        if (ButtonBase.createAccessibilityImplementation != null)
            ButtonBase.createAccessibilityImplementation(this);
    }
    
    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (checkForButtonDownConditions)
        {
            dispatchButtonEvents();
            
            checkForButtonDownConditions = false;
        }
    }

    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == labelDisplay)
        {
            labelDisplay.addEventListener("isTruncatedChanged",
                                          labelDisplay_isTruncatedChangedHandler);
            
            // Push down to the part only if the label was explicitly set
            if (_content !== undefined)
                labelDisplay.text = label;
        }
        else if (instance == iconDisplay)
        {
            iconDisplay.source = getStyle("icon");
        }
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        
        if (instance == labelDisplay)
        {
            labelDisplay.removeEventListener("isTruncatedChanged",
                                             labelDisplay_isTruncatedChangedHandler);
        }
    }

    /**
     *  @private
     */
    override protected function getCurrentSkinState():String
    {
        if (!enabled)
            return "disabled";
        
        if (isDown() || _keepDown)
            return "down";
        
        // if interactionMode == InteractionMode.TOUCH, then we have no over state
        // if interactionMode == InteractionMode.MOUSE, then only go in to the over state if 
        // we are currently hovered or if someone pressed down on us 
        // and then rolled away (and stickyHighlighting is off--otherwise 
        // isDown() would have returned true)
        if (getStyle("interactionMode") == InteractionMode.MOUSE && (hovered || mouseCaptured))
            return "over";
        
        return "up";
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private 
     */ 
    override public function styleChanged(styleProp:String):void 
    {    
        if (!styleProp ||
            styleProp == "styleName" ||
            styleProp == "icon")
        {
            if (iconDisplay)
                iconDisplay.source = getStyle("icon");
        }

        super.styleChanged(styleProp);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    protected function addHandlers():void
    {
        addEventListener(MouseEvent.ROLL_OVER, mouseEventHandler);
        addEventListener(MouseEvent.ROLL_OUT, mouseEventHandler);
        addEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler);
        addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler);
        addEventListener(MouseEvent.CLICK, mouseEventHandler);
        addEventListener(TouchInteractionEvent.TOUCH_INTERACTION_START, touchInteractionStartHandler);
    }
    
    /**
     *  @private
     *  This method adds the systemManager_mouseUpHandler as an event listener to
     *  the stage and the systemManager so that it gets called even if mouse events
     *  are dispatched outside of the button. This is needed for example when the
     *  user presses the button, drags out and releases the button.
     */
    private function addSystemMouseHandlers():void
    {
        systemManager.getSandboxRoot().addEventListener(
            MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true /* useCapture */);

        systemManager.getSandboxRoot().addEventListener(
            SandboxMouseEvent.MOUSE_UP_SOMEWHERE, systemManager_mouseUpHandler);
    }

    /**
     *  @private
     *  This method removes the systemManager_mouseUpHandler as an event
     *  listener from the stage and the systemManager.
     */
    private function removeSystemMouseHandlers():void
    {
        systemManager.getSandboxRoot().removeEventListener(
            MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true /* useCapture */);

        systemManager.getSandboxRoot().removeEventListener(
            SandboxMouseEvent.MOUSE_UP_SOMEWHERE, systemManager_mouseUpHandler);
    }
    
    /**
     *  @private
     */
    private function isDown():Boolean
    {
        if (!enabled)
            return false;

        if (keyboardPressed)
            return true;
        
        if (mouseCaptured && (hovered || stickyHighlighting))
            return true;

        return false;
    }

    /**
     *  @private
     *  Marks the button state invalid, so that the button skin's state
     *  can be set properly and "buttonDown" events can be dispatched where
     *  appropriate.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    private function invalidateButtonState():void
    {
        checkForButtonDownConditions = true;
        invalidateProperties();
        invalidateSkinState();
    }

    /**
     *  @private
     */
    private function checkAutoRepeatTimerConditions(buttonDown:Boolean):void
    {
        var needsTimer:Boolean = autoRepeat && buttonDown;
        var hasTimer:Boolean = autoRepeatTimer != null;
        
        if (needsTimer == hasTimer)
            return;

        if (needsTimer)
            startAutoRepeatTimer();
        else
            stopAutoRepeatTimer();
    }

    /**
     *  @private
     */
    private function startAutoRepeatTimer():void
    {
        autoRepeatTimer = new Timer(1);
        autoRepeatTimer.delay = getStyle("repeatDelay");
        autoRepeatTimer.addEventListener(TimerEvent.TIMER, autoRepeat_timerDelayHandler);
        autoRepeatTimer.start();
    }

    /**
     *  @private
     */
    private function stopAutoRepeatTimer():void
    {
        autoRepeatTimer.stop();
        autoRepeatTimer = null;
    }
    
    /**
     *  @private
     *  Starts timer to select the button
     */
    private function startSelectButtonAfterDelayTimer():void
    {
        var touchDelay:Number = getStyle("touchDelay");
        
        if (touchDelay > 0)
        {
            mouseDownSelectTimer = new Timer(touchDelay, 1);
            mouseDownSelectTimer.addEventListener(TimerEvent.TIMER_COMPLETE, mouseDownSelectTimer_timerCompleteHandler);
            mouseDownSelectTimer.start();
        }
        else
        {
            mouseDownSelectTimer_timerCompleteHandler();
        }
    }
    
    /**
     *  @private
     */
    private function stopSelectButtonAfterDelayTimer():void
    {
        if (mouseDownSelectTimer)
        {
            mouseDownSelectTimer.stop();
            mouseDownSelectTimer = null;
        }
    }
    
    /**
     *  @private
     *  Starts timer to deselect the button if the mouseup happened too quickly 
     *  after the mousedown so that no mousedown state was entered in to.
     */
    private function startDeselectButtonAfterDelayTimer():void
    {
        var minimumDownStateTime:Number = (disableMinimumDownStateTime ? 0 : getStyle("touchDelay"));
        
        if (minimumDownStateTime > 0)
        {
            mouseUpDeselectTimer = new Timer(minimumDownStateTime, 1);
            mouseUpDeselectTimer.addEventListener(TimerEvent.TIMER_COMPLETE, mouseUpDeselectTimer_timerCompleteHandler);
            mouseUpDeselectTimer.start();
        }
        else
        {
            // if we're not waiting then commitProperties won't have a chance to run
            // before we flip flags back; at least dispatch any relevant button events
            // even if the UI isn't going to reflect the click
            dispatchButtonEvents();
            mouseUpDeselectTimer_timerCompleteHandler();
        }
    }
    
    /**
     *  @private
     */
    private function stopDeselectButtonAfterDelayTimer():void
    {
        if (mouseUpDeselectTimer)
        {
            mouseUpDeselectTimer.stop();
            mouseUpDeselectTimer = null;
        }
    }
    
    /**
     *  @private
     */
    private function dispatchButtonEvents():void
    {
        var isCurrentlyDown:Boolean = isDown();
        
        // Only if down state has changed, do we need to do something
        if (_downEventFired != isCurrentlyDown)
        {
            if (isCurrentlyDown && hasEventListener(FlexEvent.BUTTON_DOWN))
                dispatchEvent(new FlexEvent(FlexEvent.BUTTON_DOWN));
            
            _downEventFired = isCurrentlyDown;
            checkAutoRepeatTimerConditions(isCurrentlyDown);
        }
    }
    
    /**
     *  This method is called when handling a <code>MouseEvent.MOUSE_UP</code> event
     *  when the user clicks on the button. It is only called when the button
     *  is the target and when <code>mouseCaptured</code> is <code>true</code>. 
     *  It allows subclasses to update the properties of the button right as it is clicked to
     *  avoid the button being in transitional states between the mouse up
     *  and click events.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function buttonReleased():void
    {
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden event handlers: UIComponent
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function focusOutHandler(event:FocusEvent):void
    {
        // Most of the time the system sends a rollout, but there are
        // situations where the mouse is over something else
        // that you don't get one so we force one on FOCUS_OUT.
        super.focusOutHandler(event);

		// If faking down state, let's not interrupt it because of a focusOut
		if (!(mouseUpDeselectTimer && mouseUpDeselectTimer.running))
			mouseCaptured = false;
		
        keyboardPressed = false;
    }

    /**
     *  @private
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {
        if (event.keyCode != Keyboard.SPACE && 
            !(getStyle("interactionMode") == InteractionMode.TOUCH && event.keyCode == Keyboard.ENTER))
            return;
        
        keyboardPressed = true;
        event.updateAfterEvent();
    }

    /**
     *  @private
     */
    override protected function keyUpHandler(event:KeyboardEvent):void
    {
        if (event.keyCode != Keyboard.SPACE && 
            !(getStyle("interactionMode") == InteractionMode.TOUCH && event.keyCode == Keyboard.ENTER))
            return;
        
        if (enabled && keyboardPressed)
        {
            // Mimic mouse click on the button.
            buttonReleased();
            keyboardPressed = false;
            dispatchEvent(new MouseEvent(MouseEvent.CLICK));
        }
        event.updateAfterEvent();
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function touchInteractionStartHandler(event:TouchInteractionEvent):void
    {
        // if we have a timer going on, let's stop it to make sure we don't
        // select the button later
        stopSelectButtonAfterDelayTimer();
        
        // cancel the rollover/clickdown on and go back to a normal state
        hovered = false;
        mouseCaptured = false;
        
        // no need to call buttonReleased() as that's only called for a 
        // successfull down and up user gesture
    }
    
    /**
     *  This method handles the mouse events, calls the <code>clickHandler</code> method 
     *  where appropriate and updates the <code>hovered</code> and
     *  <code>mouseCaptured</code> properties.
     *
     *  <p>This method gets called to handle <code>MouseEvent.ROLL_OVER</code>, 
     *  <code>MouseEvent.ROLL_OUT</code>, <code>MouseEvent.MOUSE_DOWN</code>, 
     *  <code>MouseEvent.MOUSE_UP</code>, and <code>MouseEvent.CLICK</code> events.</p>
     *
     *  @param event The Event object associated with the event.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function mouseEventHandler(event:Event):void
    {
        var mouseEvent:MouseEvent = event as MouseEvent;
        switch (event.type)
        {
            case MouseEvent.ROLL_OVER:
            {
                // if the user rolls over while holding the mouse button
                if (mouseEvent.buttonDown && !mouseCaptured)
                    return;
                hovered = true;
				rollOutWhileFakingDownState = false;
                break;
            }

            case MouseEvent.ROLL_OUT:
            {
				if (mouseUpDeselectTimer && mouseUpDeselectTimer.running)
				{
					// We're trying to flash the down state for longer, 
					// so let's not leave the hovered state just yet
					rollOutWhileFakingDownState = true;
				}
				else
				{
					hovered = false;
				}
                break;
            }
            
            case MouseEvent.MOUSE_DOWN:
            {
                // since mouseDowns are cancellable, let's check to see 
                // if anyone's handled it already
                if (event.isDefaultPrevented())
                    break;

                // if we were going to unhighlight ourselves, don't do it as we 
                // are just going to highlight again
                stopDeselectButtonAfterDelayTimer();
                
                // When the button is down we need to listen for mouse events outside the button so that
                // we update the state appropriately on mouse up.  Whenever mouseCaptured changes to false,
                // it will take care to remove those handlers.
                addSystemMouseHandlers();
                
                // if we're in touchMode, let's delay our selection until later
                // otherwise, when touch scrolling, the button might flicker
                if (getStyle("interactionMode") == InteractionMode.TOUCH)
                {
                    startSelectButtonAfterDelayTimer();
                }
                else
                {
                    mouseCaptured = true;
                }
                
                break;
            }

            case MouseEvent.MOUSE_UP:
            {
                // Call buttonReleased() if we mouse up on the button and if the mouse
                // was captured before.
                if (event.target == this)
                {
                    hovered = true;
                    
                    if (mouseDownSelectTimer && mouseDownSelectTimer.running)
                    {
                        // We never even flashed the down state for this click operation.
                        // There are two possibilities for being here:
                        //    1) mouseCaptured wasn't set to true (meaning this is the first click)
                        //    2) mouseCaptured was true (meaning a click operation hadn't finished 
                        //       and we find ourselves in here again--perhaps it was a doublet tap).
                        // In either case, let's make sure that down state shows up for a little bit
                        // before going back to the up state.
                        
                        // stop the original timer, put it in mouse down state, then start a new 
                        // timer to undo the mouse down state
                        stopSelectButtonAfterDelayTimer();
                        mouseCaptured = true;
                        startDeselectButtonAfterDelayTimer();
                    }
					else if (mouseCaptured)
					{
						buttonReleased();
						mouseCaptured = false;
					}
                }
                break;
            }

            // Prevent the propagation of click from a disabled Button.
            // This is conceptually a higher-level event and
            // developers will expect their click handlers not to fire
            // if the Button is disabled.
            case MouseEvent.CLICK:
            {
                if (!enabled)
                    event.stopImmediatePropagation();
                else
                    clickHandler(MouseEvent(event));
                return;
            }
        }
        if (mouseEvent)
            mouseEvent.updateAfterEvent();
    }
    
    /**
     *  Override this method in subclasses to handle the <code>click</code> event rather than
     *  adding a separate handler. 
     *  This method is not called if the button is disabled. 
     *
     *  @param event The Event object associated with the event.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function clickHandler(event:MouseEvent):void
    {
    }

    /**
     *  @private
     */
    private function systemManager_mouseUpHandler(event:Event):void
    {
        // If the target is the button, do nothing because the
        // mouseEventHandler will be handle it.
        if (event.target == this)
            return;
        
		// If faking down state, let's not interrupt it because of a mouseUp somewhere 
		// else on the screen
		if (!(mouseUpDeselectTimer && mouseUpDeselectTimer.running))
       		mouseCaptured = false;
        
        // If the mouseDownSelectTimer is still running, 
        // we don't want to ever go in to the down state in this case, so stop it
        if (mouseDownSelectTimer && mouseDownSelectTimer.running)
            stopSelectButtonAfterDelayTimer();
    }
    
    /**
     *  @private
     */
    private function autoRepeat_timerDelayHandler(event:TimerEvent):void
    {
        autoRepeatTimer.reset();
        autoRepeatTimer.removeEventListener( TimerEvent.TIMER, autoRepeat_timerDelayHandler);

        autoRepeatTimer.delay = getStyle("repeatInterval");
        autoRepeatTimer.addEventListener( TimerEvent.TIMER, autoRepeat_timerHandler);
        autoRepeatTimer.start();
    }

    /**
     *  @private
     */
    private function autoRepeat_timerHandler(event:TimerEvent):void
    {
        dispatchEvent(new FlexEvent(FlexEvent.BUTTON_DOWN));
    }
    
    /**
     *  @private
     */
    private function mouseDownSelectTimer_timerCompleteHandler(event:TimerEvent = null):void
    {
        mouseCaptured = true;
    }
    
    /**
     *  @private
     */
    private function mouseUpDeselectTimer_timerCompleteHandler(event:TimerEvent = null):void
    {
        buttonReleased();
		
		mouseCaptured = false;
		
		// if we got a rollout, we should honor it now
		if (rollOutWhileFakingDownState)
		{
			rollOutWhileFakingDownState = false;
			hovered = false;
		}
    }
    
    /**
     *  @private
     */
    private function labelDisplay_isTruncatedChangedHandler(event:Event):void
    {
        if (_explicitToolTip)
            return;
        
        var isTruncated:Boolean = labelDisplay.isTruncated;
        
        // If the label is truncated, show the whole label string as a tooltip.
        // We set super.toolTip to avoid setting our own _explicitToolTip.
        super.toolTip = isTruncated ? labelDisplay.text : null;
    }
}

}
