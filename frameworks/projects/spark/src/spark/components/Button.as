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

package mx.components
{
    
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.ui.Keyboard;
import flash.utils.Timer;

import mx.components.baseClasses.FxComponent;
import mx.core.IButton;
import mx.core.IDataRenderer;
import mx.events.FlexEvent;
import mx.events.SandboxMouseEvent;
import mx.graphics.baseClasses.TextGraphicElement;
import mx.managers.IFocusManagerComponent;
import mx.utils.StringUtil;

include "../styles/metadata/BasicTextLayoutFormatStyles.as"

/**
 *  @copy mx.components.baseClasses.GroupBase#focusColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="focusColor", type="uint", format="Color", inherit="yes")]

/**
 *  Dispatched when the user presses the FxButton control.
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
[Style(name="repeatDelay", type="Number", format="Time", inherit="no")]

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
[Style(name="repeatInterval", type="Number", format="Time", inherit="no")]

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

[DefaultTriggerEvent("click")]

[DefaultProperty("label")]

[IconFile("FxButton.png")]

/**
 *  The FxButton component is a commonly used rectangular button.
 *  The FxButton component looks like it can be pressed.
 *  It can have a text label, an icon, or both on its face.
 *
 *  <p>Buttons typically use event listeners to perform an action 
 *  when the user selects the control. When a user clicks the mouse 
 *  on a FxButton control, and the FxButton control is enabled, 
 *  it dispatches a <code>click</code> event and a <code>buttonDown</code> event. 
 *  A button always dispatches events such as the <code>mouseMove</code>, 
 *  <code>mouseOver</code>, <code>mouseOut</code>, <code>rollOver</code>, 
 *  <code>rollOut</code>, <code>mouseDown</code>, and 
 *  <code>mouseUp</code> events whether enabled or disabled.</p>
 *
 *  @includeExample examples/FxButtonExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class FxButton extends FxComponent implements IFocusManagerComponent, IButton
{
    include "../core/Version.as";

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
    public function FxButton()
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
    //  Skin Parts
    //
    //--------------------------------------------------------------------------

    [SkinPart(required="false")]

    /**
     *  A skin part that defines the  label of the button. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var labelElement:TextGraphicElement;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  content
    //----------------------------------

    /**
     *  @private
     *  Storage for the content property.
     */
    private var _content:Object;
    
    [Bindable("contentChange")]

    /**
     *  The <code>content</code> property lets you pass an arbitrary object
     *  to be used in a custom skin of the button.
     * 
     *  When a skin defines the optional part <code>labelElement</code> then
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

        // Push to the optional labelElement skin part
        if (labelElement)
            labelElement.text = label;
        dispatchEvent(new Event("contentChange"));
    }

    //----------------------------------
    //  label
    //----------------------------------

    [Bindable("contentChange")]

    /**
     *  Text to appear on the FxButton control.
     * 
     *  <p>If the label is wider than the FxButton control,
     *  the label is truncated and terminated by an ellipsis (...).
     *  The full label displays as a tooltip
     *  when the user moves the mouse over the control.
     *  If you have also set a tooltip by using the <code>tooltip</code>
     *  property, the tooltip is displayed rather than the label text.</p>
     *
     *  <p>This is the default FxButton property.</p>
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
    //  mouseCaptured
    //----------------------------------

    /**
     *  @private
     *  Storage for the mouseCaptured property 
     */
    private var _mouseCaptured:Boolean = false;    

    /**
     *  Indicates whether the mouse is down and the mouse pointer was
     *  over the button when MouseEvent.MOUSE_DOWN was first dispatched.
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
    
    /**
     *  @private
     */
    override public function set enabled(value:Boolean):void
    {
        if (enabled == value)
            return;

        super.enabled = value;
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

    //----------------------------------
    //  emphasized
    //----------------------------------

    /**
     *  @private
     *  Storage for the emphasized property.
     */
    private var _emphasized:Boolean = false;

    [Inspectable(category="General", defaultValue="false")]

    /**
     *  Reflect the default/emphasized as potentially requested by the
     *  focus manager.
     *
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get emphasized():Boolean 
    { 
        return _emphasized;
    }
    
    /**
     *  @private
     */
    public function set emphasized(value:Boolean):void 
    {
        if (value == _emphasized)
            return;
            
        _emphasized = value;
        var style:String = styleName is String ? styleName as String : "";
        
        if (!styleName || styleName is String)
        {
            if (_emphasized)
                styleName = style + " emphasized";
            else 
                styleName = style.split(" emphasized").join("");
        }   
    }
    
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
    //  toolTip
    //----------------------------------

    [Inspectable(category="General", defaultValue="null")]
    
    private var _explicitToolTip:Boolean = false;

    /**
     *  @private
     */
    override public function set toolTip(value:String):void
    {
        super.toolTip = value;
        
        // If explicit tooltip is cleared, we need to make sure our
        // updateDisplayList is called, so that we add automatic tooltip
        // in case the label is truncated.
        if (_explicitToolTip && !value)
            invalidateDisplayList();

        _explicitToolTip = value != null;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent
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
        return getBaselinePositionForPart(labelElement);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == labelElement)
        {
            labelElement.text = label;
            
            // Temporary ...
            labelElement.setStyle("verticalAlign", getStyle("verticalAlign"));
        }
    }
    
    /**
     *  @private
     *  Remember whether we have fired an event already,
     *  so that we don't fire a second time.
     */
    private var _downEventFired:Boolean = false;
    
    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (checkForButtonDownConditions)
        {
            var isCurrentlyDown:Boolean = isDown();

            // Only if down state has changed, do we need to do something
            if (_downEventFired != isCurrentlyDown)
            {
                if (isCurrentlyDown)
                    dispatchEvent(new FlexEvent(FlexEvent.BUTTON_DOWN));

                _downEventFired = isCurrentlyDown;
                checkAutoRepeatTimerConditions(isCurrentlyDown);
            }
            
            checkForButtonDownConditions = false;
        }
    }

    //--------------------------------------------------------------------------
    //
    //  States
    //
    //--------------------------------------------------------------------------

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
    override protected function getCurrentSkinState():String
    {
        if (!enabled)
            return "disabled";

        if (isDown())
            return "down";
            
        if (hovered || mouseCaptured)
            return "over";
            
        return "up";
    }

    //--------------------------------------------------------------------------
    //
    //  Event handling
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
    }
    
    /**
     *  @private
     *  This method adds the mouseEventHandler as an event listener to
     *  the stage and the systemManager so that it gets called even if mouse events
     *  are dispatched outside of the button. This is needed for example when the
     *  user presses the button, drags out and releases the button.
     */
    private function addSystemMouseHandlers():void
    {
        systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler, true /*useCapture*/);
        systemManager.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseEventHandler);             
    }

    /**
     *  @private
     *  This method removes the mouseEventHandler as an event listener from
     *  the stage and the systemManager.
     */
    private function removeSystemMouseHandlers():void
    {
        systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_UP, mouseEventHandler, true /*useCapture*/);
        systemManager.getSandboxRoot().removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseEventHandler);
    }
    
    /**
     *  This method handles the mouse events, calls the <code>clickHandler</code> method 
     *  where appropriate and updates the <code>hovered</code> and
     *  <code>mouseCaptured</code> properties.
     *  <p>This method gets called to handle MouseEvent.ROLL_OVER, MouseEvent.ROLL_OUT,
     *  MouseEvent.MOUSE_DOWN, MouseEvent.MOUSE_UP, MouseEvent.CLICK and 
     *  SandboxMouseEvent.MOUSE_UP_SOMEWHERE.</p>
     *  <p>For MouseEvent.MOUSE_UP and SandboxMouseEvent.MOUSE_UP_SOMEWHERE, the event 
     *  target can be other than the FxButton - for example when the user presses the 
     *  FxButton, we listen for MOUSE_UP and MOUSE_UP_SOMEWHERE to handle cases where the user drags
     *  outside the FxButton and releases the mouse.</p>
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
                break;
            }

            case MouseEvent.ROLL_OUT:
            {
                hovered = false;
                break;
            }
            
            case MouseEvent.MOUSE_DOWN:
            {
                // When the button is down we need to listen for mouse events outsied the button so that
                // we update the state appropriately on mouse up.  Whenever mouseCaptured changes to false,
                // it will take care to remove those handlers.
                addSystemMouseHandlers();
                mouseCaptured = true;
                break;
            }

            case MouseEvent.MOUSE_UP:
            {
                if (event.currentTarget == this)
                    hovered = true;
            } //fallthrough:
            case SandboxMouseEvent.MOUSE_UP_SOMEWHERE:
            {
                mouseCaptured = false;
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
     *  Override in subclasses to handle the click event rather than
     *  adding a separate handler. clickHandler will not get called if the
     *  button is disabled. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function clickHandler(event:MouseEvent):void
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

        mouseCaptured = false;
        keyboardPressed = false;
    }

    /**
     *  @private
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {
        if (event.keyCode != Keyboard.SPACE)
            return;
        keyboardPressed = true;
        event.updateAfterEvent();
    }

    /**
     *  @private
     */
    override protected function keyUpHandler(event:KeyboardEvent):void
    {
        if (event.keyCode != Keyboard.SPACE)
            return;
        keyboardPressed = false;
        
        if (enabled)
            dispatchEvent(new MouseEvent(MouseEvent.CLICK));
        event.updateAfterEvent();
    }

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
     */
    private function checkAutoRepeatTimerConditions(buttonDown:Boolean):void
    {
        var needsTimer:Boolean = autoRepeat && buttonDown;
        var hasTimer:Boolean = autoRepeatTimer != null;
        
        if (needsTimer == hasTimer)
            return;

        if (needsTimer)
            startTimer();
        else
            stopTimer();
    }

    /**
     *  @private
     */
    private function startTimer():void
    {
        autoRepeatTimer = new Timer(1);
        autoRepeatTimer.delay = getStyle("repeatDelay");
        autoRepeatTimer.addEventListener(TimerEvent.TIMER, autoRepeat_timerDelayHandler);
        autoRepeatTimer.start();
    }

    /**
     *  @private
     */
    private function stopTimer():void
    {
        autoRepeatTimer.stop();
        autoRepeatTimer = null;
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
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        // Bail out if we don't have a label or the tooltip is explicitly set.
        if (!labelElement || _explicitToolTip)
            return;

        // Check if the label text is truncated
        // TODO EGeorgie: use TextGraphicElement API to check for truncated text.
        labelElement.validateNow();
        var truncated:Boolean = labelElement.getLayoutBoundsWidth() < labelElement.getPreferredBoundsWidth() ||
                                labelElement.getLayoutBoundsHeight() < labelElement.getPreferredBoundsHeight();
        
        // If the label is truncated, show the whole label string as a tooltip
        super.toolTip = truncated ? labelElement.text : null;
    } 
}

}
