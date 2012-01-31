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
import mx.events.FlexEvent;
import mx.core.IDataRenderer;
import mx.graphics.graphicsClasses.TextGraphicElement;
import mx.managers.IFocusManagerComponent;
import mx.utils.BitFlagUtil;

/**
 *  Dispatched when the user presses the FxButton control.
 *  If the <code>autoRepeat</code> property is <code>true</code>,
 *  this event is dispatched repeatedly as long as the button stays down.
 *
 *  @eventType mx.events.FlexEvent.BUTTON_DOWN
 */
[Event(name="buttonDown", type="mx.events.FlexEvent")]

/**
 *  Number of milliseconds to wait after the first <code>buttonDown</code>
 *  event before repeating <code>buttonDown</code> events at each 
 *  <code>repeatInterval</code>.
 * 
 *  @default 500
 */
[Style(name="repeatDelay", type="Number", format="Time", inherit="no")]

/**
 *  Number of milliseconds between <code>buttonDown</code> events
 *  if the user presses and holds the mouse on a button.
 *  
 *  @default 35
 */
[Style(name="repeatInterval", type="Number", format="Time", inherit="no")]

/**
 *  The built-in set of states for the Button component.
 */
[SkinStates("up", "over", "down", "disabled")]
 
//--------------------------------------
//  Other metadata
//--------------------------------------

[DefaultTriggerEvent("click")]

[DefaultProperty("content")]

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
 */
public class FxButton extends FxComponent implements IFocusManagerComponent, IDataRenderer
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
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
     */
    public var labelField:TextGraphicElement;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    [Bindable]
    public function get data():Object
    {
        return content;
    }
    
    public function set data(value:Object):void
    {
        content = value;
    }

    [Bindable("labelChanged")]
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
     *  @default ""
     */
    public function set label(value:String):void
    {
        content = value;
        dispatchEvent(new Event("labelChanged"));
        
        if (labelField)
            labelField.text = label;
    }
    /**
     *  @private
     */
    public function get label():String          
    {
        return (content != null) ? content.toString():"";
    }
    
    [Bindable]
    public var content:*

    // -----------------------------------------------------------------------
    //
    // Public properties defining the state of the button.
    //
    // -----------------------------------------------------------------------
    
    /**
     *  @private
     *  <code>true</code> when we need to check whether to dispatch
     *  a button down event
     */
     private var checkForButtonDownConditions:Boolean = false; 
    
    /**
     *  Indicates whether the mouse pointer is over the button.
     *  Used to determine the skin state.
     */ 
    protected function get hoveredOver():Boolean
    {
        return BitFlagUtil.isSet(flags, hoveredOverFlag);
    }
    
    /**
     *  @private
     */ 
    protected function set hoveredOver(value:Boolean):void
    {
        if (BitFlagUtil.isSet(flags, hoveredOverFlag) == value)
            return;
         
        flags = BitFlagUtil.update(flags, hoveredOverFlag, value);
        
        invalidateButtonState();
    }

    /**
     *  Indicates whether the mouse is down and the mouse pointer was
     *  over the button when MouseEvent.MOUSE_DOWN was first dispatched.
     *  Used to determine the skin state.
     */    
    protected function get mouseCaptured():Boolean
    {
        return BitFlagUtil.isSet(flags, mouseCapturedFlag);
    }
    
    /**
     *  @private
     */
    protected function set mouseCaptured(value:Boolean):void
    {
        if (BitFlagUtil.isSet(flags, mouseCapturedFlag) == value)
            return;
         
        flags = BitFlagUtil.update(flags, mouseCapturedFlag, value);
        
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
    
    /**
     *  Indicates whether a keyboard key is pressed while the button is in focus.
     *  Used to determine the skin state.
     */ 
    protected function get keyboardPressed():Boolean
    {
        return BitFlagUtil.isSet(flags, keyboardPressedFlag);
    }
    
    /**
     *  @private
     */
    protected function set keyboardPressed(value:Boolean):void
    {
        if (BitFlagUtil.isSet(flags, keyboardPressedFlag) == value)
            return;
         
        flags = BitFlagUtil.update(flags, keyboardPressedFlag, value);
        
        invalidateButtonState();
    }
    
    /**
     *  If <code>false</code>, the button displays its down skin
     *  when the user presses it but changes to its over skin when
     *  the user drags the mouse off of it.
     *  If <code>true</code>, the button displays its down skin
     *  when the user presses it, and continues to display this skin
     *  when the user drags the mouse off of it.
     *
     *  @default false
     */
    public function get stickyHighlighting():Boolean
    {
        return BitFlagUtil.isSet(flags, stickyHighlightingFlag);
    }

    /**
     *  @private
     */
    public function set stickyHighlighting(value:Boolean):void
    {
        if (BitFlagUtil.isSet(flags, stickyHighlightingFlag) == value)
            return;
         
        flags = BitFlagUtil.update(flags, stickyHighlightingFlag, value);
        
        invalidateButtonState();
    }

    /**
     *  @private
     */
    protected static const hoveredOverFlag:uint         = 1 << 0;
    /**
     *  @private
     */
    protected static const mouseCapturedFlag:uint       = 1 << 1;
    /**
     *  @private
     */
    protected static const keyboardPressedFlag:uint     = 1 << 2;
    /**
     *  @private
     */
    protected static const autoRepeatFlag:uint          = 1 << 3;
    /**
     *  @private
     */
    protected static const stickyHighlightingFlag:uint  = 1 << 4;
    /**
     *  @private
     */
    protected static const downEventFiredFlag:uint      = 1 << 5;
    /**
     *  @private
     */
    protected static const explicitToolTip:uint         = 1 << 6;
    /**
     *  @private
     */
    protected static const lastFlag:uint                = 1 << 6;

    /**
     *  A uint to store bitflags (booleans compressed down into one integer).
     */
    protected var flags:uint = 0;

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
        
        if (instance == labelField)
        {
            labelField.text = label;
            
            // TODO: Remove this hard-coded styleName assignment
            // once all global text styles are moved to the global
            // stylesheet. This is a temporary workaround to support
            // inline text styles for Buttons and subclasses.
            labelField.styleName = this;
        }
    }
    
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
            if (BitFlagUtil.isSet(flags, downEventFiredFlag) != isCurrentlyDown)
            {
                flags = BitFlagUtil.update(flags, downEventFiredFlag, isCurrentlyDown);
                if (isCurrentlyDown)
                    dispatchEvent(new FlexEvent(FlexEvent.BUTTON_DOWN));
            
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
        
        if (mouseCaptured && (hoveredOver || stickyHighlighting))
            return true;
        return false;
    }
    
    /**
     *  Marks the button state invalid, so that the button skin's state
     *  can be set properly and "buttonDown" events can be dispatched where
     *  appropriate.
     */
    protected function invalidateButtonState():void
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
            
        if (hoveredOver || mouseCaptured)
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
        systemManager.addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler, true /*useCapture*/);
        systemManager.stage.addEventListener(Event.MOUSE_LEAVE, mouseEventHandler);             
    }

    /**
     *  @private
     *  This method removes the mouseEventHandler as an event listener from
     *  the stage and the systemManager.
     */
    private function removeSystemMouseHandlers():void
    {
        systemManager.removeEventListener(MouseEvent.MOUSE_UP, mouseEventHandler, true /*useCapture*/);
        systemManager.stage.removeEventListener(Event.MOUSE_LEAVE, mouseEventHandler);
    }
    
    /**
     *  This method handles the mouse events, calls the <code>onClick</code> method 
     *  where appropriate and updates the <code>hoveredOver</code> and
     *  <code>mouseCaptured</code> properties.
     *  <p>This method gets called to handle MouseEvent.ROLL_OVER, MouseEvent.ROLL_OUT,
     *  MouseEvent.MOUSE_DOWN, MouseEvent.MOUSE_UP, MouseEvent.CLICK and Event.MOUSE_LEAVE.</p>
     *  <p>For MouseEvent.MOUSE_UP and Event.MOUSE_LEAVE, the event target can be other than the
     *  FxButton - for example when the user presses the FxButton, we listen for MOUSE_UP
     *  on the stage to handle cases where the user drags outside the FxButton and releases
     *  the mouse.</p>
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
                    hoveredOver = true;
                break;
            }

            case MouseEvent.ROLL_OUT:
            {
                hoveredOver = false;
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
                    hoveredOver = true;
            } //fallthrough:
            case Event.MOUSE_LEAVE:
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
                    onClick(MouseEvent(event));
                return;
            }
        }
        if (mouseEvent)
            mouseEvent.updateAfterEvent();
    }
    
    /**
     *  Override in subclasses to handle the click event rather than
     *  adding a separate handler. onClick will not get called if the
     *  button is disabled. 
     */
    protected function onClick(event:MouseEvent):void
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

    //----------------------------------
    //  autoRepeat
    //----------------------------------

    /**
     *  @private
     *  Timer for doing auto-repeat.
     */
    private var autoRepeatTimer:Timer;

    [Inspectable(defaultValue="false")]

    /**
     *  Specifies whether to dispatch repeated <code>buttonDown</code>
     *  events if the user holds down the mouse button.
     *
     *  @default false
     */
    public function get autoRepeat():Boolean
    {
        return BitFlagUtil.isSet(flags, autoRepeatFlag);
    }
    
    /**
     *  @private
     */
    public function set autoRepeat(value:Boolean):void
    {
        if (BitFlagUtil.isSet(flags, autoRepeatFlag) == value)
            return;
         
        flags = BitFlagUtil.update(flags, autoRepeatFlag, value);

        checkAutoRepeatTimerConditions( isDown() );
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
    
    //----------------------------------
    //  toolTip
    //----------------------------------

    [Inspectable(category="General", defaultValue="null")]

    /**
     *  @private
     */
    override public function set toolTip(value:String):void
    {
        super.toolTip = value;

        flags = BitFlagUtil.update(flags, explicitToolTip, value != null);
        
        // If explicit tooltip is cleared, we need to make sure our
        // updateDisplayList is called, so that we add automatic tooltip
        // in case the label is truncated.
        if (!BitFlagUtil.isSet(flags, explicitToolTip))
            invalidateDisplayList();
    }

    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        // Bail out if we don't have a label or the tooltip is not explicitly set.
        if (!labelField || BitFlagUtil.isSet(flags, explicitToolTip))
            return;

        // Check if the label text is truncated
        // TODO EGeorgie: use TextGraphicElement API to check for truncated text.
        labelField.validateNow();
        var truncated:Boolean = labelField.actualSize.x < labelField.preferredSize.x ||
                                labelField.actualSize.y < labelField.preferredSize.y;
        
        // If the label is truncated, show the whole label string as a tooltip
        super.toolTip = truncated ? labelField.text : null;
    } 
}

}
