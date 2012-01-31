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

import mx.utils.Flags32;
import mx.components.baseClasses.FxComponent;
import mx.graphics.TextBox;

import mx.events.FlexEvent;
import mx.managers.IFocusManagerComponent;

/**
 *  Dispatched when the user presses the Button control.
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

/**
 *  Documentation is not currently available.
 */
public class FxButton extends FxComponent implements IFocusManagerComponent
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
    public var labelField:TextBox;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
	[Bindable("labelChanged")]
	public function set label(value:String):void
	{
		content = value;
		dispatchEvent(new Event("labelChanged"));
		
		if (labelField)
			labelField.text = label;
	}
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
	 *  @return Returns true when the mouse cursor is over the button. 
	 */	
	public function get isHoveredOver():Boolean
	{
		return flags.isSet(isHoveredOverFlag);
	}
	
	/**
	 *  Sets the flag indicating whether the mouse cursor
	 *  is over the button.
	 */	
	protected function setHoveredOver(value:Boolean):void
	{
		if (!flags.update(isHoveredOverFlag, value))
			return;

		invalidateSkinState();
	}

	/**
	 *  @return Returns true when the mouse button is down and it was pressed 
	 *  while cursor was over the button.
	 */    
	public function get isMouseCaptured():Boolean
	{
		return flags.isSet(isMouseCapturedFlag);
	}
	
	/**
	 *  Sets the flag indicating whether the mouse has been pressed
	 *  while cursor was over the button.
	 */	
	protected function setMouseCaptured(value:Boolean):void
	{
		if (!flags.update(isMouseCapturedFlag, value))
			return;

		invalidateSkinState();

		// System mouse handlers are not needed when the button is not mouse captured
		if (!value)
			removeSystemMouseHandlers();
	}
	
	/**
	 *  @return Returns true when the button is enabled. 
	 */	
	public function get isEnabled():Boolean { return enabled; }

    /**
     *  @inheritDoc
     */
	override public function set enabled(value:Boolean):void
	{
		if (isEnabled == value)
			return;
		super.enabled = value;
		invalidateSkinState();
	}
	
	/**
	 *  @return Returns true when key has been pressed
	 *  while button is in focus.
	 */	
	public function get isKeyboardPressed():Boolean
	{
		return flags.isSet(isKeyboardPressedFlag);
	}
	
	/**
	 *  Sets the flag indicating whether key has been pressed while 
	 *  button is in focus.
	 */	
	protected function setKeyboardPressed(value:Boolean):void
	{
		if (!flags.update(isKeyboardPressedFlag, value))
			return;
		invalidateSkinState();
	}
	
    /**
     *  If <code>false</code>, the Button displays its down skin
     *  when the user presses it but changes to its over skin when
     *  the user drags the mouse off of it.
     *  If <code>true</code>, the Button displays its down skin
     *  when the user presses it, and continues to display this skin
     *  when the user drags the mouse off of it.
     *
     *  <p>Button subclasses, such as the SliderThumb and ScrollThumb classes
     *  or the up and down arrows of a ScrollBar, set 
     *  this property to <code>true</code>.</p>
     *
     *  @default false
     */
    public function get stickyHighlighting():Boolean
    {
    	return flags.isSet(stickyHighlightingFlag);
    }
    public function set stickyHighlighting(value:Boolean):void
    {
    	if (!flags.update(stickyHighlightingFlag, value))
    		return;

    	invalidateSkinState();
    }

	protected static const isHoveredOverFlag:uint 		= 1 << 0;
	protected static const isMouseCapturedFlag:uint 	= 1 << 1;
	protected static const isKeyboardPressedFlag:uint	= 1 << 2;
	protected static const autoRepeatFlag:uint			= 1 << 3;
	protected static const stickyHighlightingFlag:uint	= 1 << 4;
	protected static const downEventFiredFlag:uint		= 1 << 5;
	protected static const lastFlag:uint				= 1 << 5;

	protected var flags:Flags32 = new Flags32();
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    override protected function partAdded(partName:String, instance:Object):void
    {
    	super.partAdded(partName, instance);
    	
    	if (instance == labelField)
    	{
    		labelField.text = label;
    	}
    }

	//--------------------------------------------------------------------------
	//
	//  States
	//
	//--------------------------------------------------------------------------

	private function isDown():Boolean
	{
		if (!isEnabled)
			return false;

		if (isKeyboardPressed)
			return true;
		
		if (isMouseCaptured && (isHoveredOver || stickyHighlighting))
			return true;
		return false;
	}

	// GetState returns a string representation of the component's state as
	// a combination of some of its public properties	
	protected override function getUpdatedSkinState():String
	{
		if (!isEnabled)
			return "disabled";

		if (isDown())
			return "down";
			
		if (isHoveredOver || isMouseCaptured )
			return "over";
			
		return "up";
	}
	
	override protected function commitSkinState(newState:String):void
	{
		super.commitSkinState(newState);
		
		// Our state has changed, see whether we need to start/stop dispatching buttonDown
		checkDownEventConditions();
	} 

	private function checkDownEventConditions():void
	{
		var isCurrentlyDown:Boolean = isDown();

		// If down state hasn't changed, simply return
		if (!flags.update(downEventFiredFlag, isCurrentlyDown))
			return;

		if( isCurrentlyDown )
			dispatchEvent(new FlexEvent(FlexEvent.BUTTON_DOWN));
		
		checkAutoRepeatTimerConditions( isCurrentlyDown );
	}

	//--------------------------------------------------------------------------
	//
	//  Event handling
	//
	//--------------------------------------------------------------------------

	protected function addHandlers():void
	{
		addEventListener(MouseEvent.ROLL_OVER, mouseEventHandler);
		addEventListener(MouseEvent.ROLL_OUT, mouseEventHandler);
		addEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler);
		addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler);
		// TODO EGeorgie: should revisit, we are handling the CLICK during capture phase,
		// since instance handlers are registered before base class handlers.
		addEventListener(MouseEvent.CLICK, mouseEventHandler, true /*useCapture*/);
		addEventListener("enabledChanged", enableChangedHandler);
	}
	
	private function addSystemMouseHandlers():void
	{
		systemManager.addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler, true /*useCapture*/);
		systemManager.stage.addEventListener(Event.MOUSE_LEAVE, mouseEventHandler);				
	}

	private function removeSystemMouseHandlers():void
	{
		systemManager.removeEventListener(MouseEvent.MOUSE_UP, mouseEventHandler, true /*useCapture*/);
		systemManager.stage.removeEventListener(Event.MOUSE_LEAVE, mouseEventHandler);
	}
	
	protected function enableChangedHandler(event:Event):void
	{
		// Since enabled is part of our state, we need to invalidate it on changes.
		invalidateSkinState();
	}
	
	protected function mouseEventHandler(event:Event):void
	{
		var mouseEvent:MouseEvent = event as MouseEvent;
		switch (event.type)
		{
			case MouseEvent.ROLL_OVER:
			{
				// if the user rolls over while holding the mouse button
				if (mouseEvent.buttonDown && !isMouseCaptured)
					return;
					setHoveredOver(true);
				break;
			}

			case MouseEvent.ROLL_OUT:
			{
				setHoveredOver(false);
				break;
			}
			
			case MouseEvent.MOUSE_DOWN:
			{
				// When the button is down we need to listen for mouse events outsied the button so that
				// we update the state appropriately on mouse up.  Whenever isMouseCaptured changes to false,
				// it will take care to remove those handlers.
				addSystemMouseHandlers();
				setMouseCaptured(true);
				break;
			}

			case MouseEvent.MOUSE_UP:
			{
				if (event.currentTarget == this)
					setHoveredOver(true);
			} //fallthrough:
			case Event.MOUSE_LEAVE:
			{
				setMouseCaptured(false);
				break;
			}

			// Prevent the propagation of click from a disabled Button.
			// This is conceptually a higher-level event and
			// developers will expect their click handlers not to fire
			// if the Button is disabled.
			case MouseEvent.CLICK:
			{
				if(!isEnabled )
					event.stopImmediatePropagation();
				return;
			}
		}
		if (mouseEvent)
            mouseEvent.updateAfterEvent();
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden event handlers: UIComponent
	//
	//--------------------------------------------------------------------------

	override protected function focusOutHandler(event:FocusEvent):void
	{
		// Most of the time the system sends a rollout, but there are
		// situations where the mouse is over something else
		// that you don't get one so we force one on FOCUS_OUT.
		super.focusOutHandler(event);

		setMouseCaptured(false);
		setKeyboardPressed(false);
	}

	override protected function keyDownHandler(event:KeyboardEvent):void
	{
		if( event.keyCode != Keyboard.SPACE )
			return;
		setKeyboardPressed(true);
		event.updateAfterEvent();
	}

	override protected function keyUpHandler(event:KeyboardEvent):void
	{
		if( event.keyCode != Keyboard.SPACE )
			return;
		setKeyboardPressed(false);
		
		if( isEnabled )
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
        return flags.isSet(autoRepeatFlag);
    }
    public function set autoRepeat(value:Boolean):void
    {
    	if (!flags.update(autoRepeatFlag, value))
    		return;

    	checkAutoRepeatTimerConditions( isDown() );
    }

	private function checkAutoRepeatTimerConditions(isButtonDown:Boolean):void
	{
		var needsTimer:Boolean = autoRepeat && isButtonDown;
		var hasTimer:Boolean = autoRepeatTimer != null;
		
		if (needsTimer == hasTimer)
			return;

		if (needsTimer)
			startTimer();
		else
			stopTimer();
	}

	private function startTimer():void
	{
		autoRepeatTimer = new Timer(1);
		autoRepeatTimer.delay = getStyle("repeatDelay");
		autoRepeatTimer.addEventListener(TimerEvent.TIMER, autoRepeat_timerDelayHandler);
		autoRepeatTimer.start();
	}

	private function stopTimer():void
	{
		autoRepeatTimer.stop();
		autoRepeatTimer = null;
	}

	private function autoRepeat_timerDelayHandler(event:TimerEvent):void
	{
        autoRepeatTimer.reset();
	    autoRepeatTimer.removeEventListener( TimerEvent.TIMER, autoRepeat_timerDelayHandler);

	    autoRepeatTimer.delay = getStyle("repeatInterval");
	    autoRepeatTimer.addEventListener( TimerEvent.TIMER, autoRepeat_timerHandler);
	    autoRepeatTimer.start();
	}

	private function autoRepeat_timerHandler(event:TimerEvent):void
	{
		dispatchEvent(new FlexEvent(FlexEvent.BUTTON_DOWN));
	}
}

}
