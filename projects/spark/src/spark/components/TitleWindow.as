////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components
{

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.mx_internal;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.events.SandboxMouseEvent;
import mx.utils.BitFlagUtil;

import spark.events.TitleWindowBoundsEvent;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the user selects the close button.
 *
 *  @eventType mx.events.CloseEvent.CLOSE
 *  @helpid 3985
 *  @tiptext close event
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="close", type="mx.events.CloseEvent")]

/**
 *  Dispatched when the user presses the moveArea.
 *
 *  @eventType spark.events.TitleWindowBoundsEvent.WINDOW_MOVE_START
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="windowMoveStart", type="spark.events.TitleWindowBoundsEvent")]

/**
 *  Dispatched when the user tries to drag the window.
 *
 *  @eventType spark.events.TitleWindowBoundsEvent.WINDOW_MOVING
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="windowMoving", type="spark.events.TitleWindowBoundsEvent")]

/**
 *  Dispatched when the user moves the window successfully.
 *
 *  @eventType spark.events.TitleWindowBoundsEvent.WINDOW_MOVE
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="windowMove", type="spark.events.TitleWindowBoundsEvent")]

/**
 *  Dispatched when the user releases the moveArea.
 *
 *  @eventType spark.events.TitleWindowBoundsEvent.WINDOW_MOVE_END
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="windowMoveEnd", type="spark.events.TitleWindowBoundsEvent")]

//--------------------------------------
//  SkinStates
//--------------------------------------

/**
 *  Active State which is used when the TitleWindow
 *  or any of its children are focused.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("active")]

/**
 *  Active State with control bar present.
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("activeWithControlBar")]

[IconFile("TitleWindow.png")]

/**
 *  The TitleWindow Class extends Panel to include
 *  a close button and drag area. TitleWindow is 
 *  designed as a floating or pop-up window.
 *  
 *  @mxml
 *  
 *  <p>The <code>&lt;s:TitleWindow&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *  
 *  <pre>
 *  &lt;s:TitleWindow&gt;
 *    <strong>Events</strong>
 *    close="<i>No default</i>"
 *    windowMoveStart="<i>No default</i>"
 *    windowMoving="<i>No default</i>"
 *    windowMove="<i>No default</i>"
 *    windowMoveEnd="<i>No default</i>"
 *  &lt;/s:TitleWindow&gt;
 *  </pre>
 *  
 *  @includeExample examples/SimpleTitleWindowExample.mxml -noswf
 *  @includeExample examples/TitleWindowApp.mxml
 *  
 *  @see Panel
 *  @see spark.skins.spark.TitleWindowSkin
 *  @see mx.managers.PopUpManager
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class TitleWindow extends Panel
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
    public function TitleWindow()
    {
        super();
    }
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	private var addedHandlers:Boolean = false;
	private var active:Boolean = false;
	
	/**
	 *  @private
	 *  Horizontal location where the user pressed the mouse button
	 *  on the moveArea to start dragging, relative to the original
	 *  horizontal location of the TitleWindow.
	 */
	private var offsetX:Number;
	
	/**
	 *  @private
	 *  Vertical location where the user pressed the mouse button
	 *  on the moveArea to start dragging, relative to the original
	 *  vertical location of the TitleWindow.
	 */
	private var offsetY:Number;
	
	/**
	 *  @private
	 *  The starting bounds of the TitleWindow before a user
	 *  moves or resizes it.
	 */
	private var startBounds:Rectangle;
	
	//--------------------------------------------------------------------------
	//
	//  Properties 
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  closeButton
	//---------------------------------- 
	
	[SkinPart(required="false")]
	
	/**
	 *  The Button that when clicked dispatches a "close" event.
	 *  Focus is disabled for this button.
	 */
	public var closeButton:Button;
	
	//----------------------------------
	//  moveArea
	//---------------------------------- 
	
	[SkinPart(required="false")]
	
	/**
	 *  The area where the user may click and drag to move the window.
	 */
	public var moveArea:InteractiveObject;
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods: UIComponent, SkinnableComponent
	//
	//--------------------------------------------------------------------------
    
	/**
	 *  @private
	 */
	override public function parentChanged(p:DisplayObjectContainer):void
	{
		if (focusManager)
		{
			focusManager.removeEventListener(FlexEvent.FLEX_WINDOW_ACTIVATE, 
											 activateHandler);
			focusManager.removeEventListener(FlexEvent.FLEX_WINDOW_DEACTIVATE, 
											 deactivateHandler);
		}
		
		super.parentChanged(p);
		
		if (focusManager)
		{
			addActivateHandlers();
		}
		else
		{
			// if no focusmanager yet, add capture phase to detect when it
			// gets added
			if (systemManager)
			{
				systemManager.getSandboxRoot().addEventListener(
					FlexEvent.ADD_FOCUS_MANAGER, addFocusManagerHandler, true, 0, true);
			}
			else
			{
				// no systemManager yet?  Check again when added to stage
				addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			}
		}
	}
	
	/**
	 *  @private
	 */
    override protected function partAdded(partName:String, instance:Object) : void
    {
        super.partAdded(partName, instance);
        
        if (instance == moveArea)
		{
			moveArea.addEventListener(MouseEvent.MOUSE_DOWN, moveArea_mouseDownHandler);
		}
		else if (instance == closeButton)
		{
			closeButton.focusEnabled = false;
			closeButton.addEventListener(MouseEvent.CLICK, closeButton_clickHandler);	
		}
    }
    
	/**
	 *  @private
	 */
    override protected function partRemoved(partName:String, instance:Object):void
    {
		super.partRemoved(partName, instance);
												
        if (instance == moveArea)
			moveArea.removeEventListener(MouseEvent.MOUSE_DOWN, moveArea_mouseDownHandler);
		else if (instance == closeButton)
            closeButton.removeEventListener(MouseEvent.CLICK, closeButton_clickHandler);
    }
	
	/**
	 *  @inheritDoc
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	override protected function getCurrentSkinState():String
	{
		// In focus window is the active window.
		if (enabled && isPopUp && active)
		{
			var state:String = "active";
			
			if (controlBarGroup)
			{
				if (BitFlagUtil.isSet(controlBarGroupProperties as uint, CONTROLBAR_PROPERTY_FLAG) &&
					BitFlagUtil.isSet(controlBarGroupProperties as uint, VISIBLE_PROPERTY_FLAG))
					state += "WithControlBar";
			}
			else
			{
				if (controlBarGroupProperties.controlBarContent &&
					controlBarGroupProperties.visible)
					state += "WithControlBar";
			}
			
			return state;
		}
		
		return super.getCurrentSkinState();
	}
	
	/**
	 *  @private
	 */
	override public function move(x:Number, y:Number) : void
	{
		var beforeBounds:Rectangle = new Rectangle(this.x, this.y, width, height);
		
		super.move(x, y);
		
		// Dispatch "windowMove" event when TitleWindow is moved.
		var afterBounds:Rectangle = new Rectangle(this.x, this.y, width, height);
		var e2:TitleWindowBoundsEvent =
			new TitleWindowBoundsEvent(TitleWindowBoundsEvent.WINDOW_MOVE,
									   false, false, beforeBounds, afterBounds);
		
		dispatchEvent(e2);
	}
	
	//--------------------------------------------------------------------------
	// 
	// Event Handlers
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  moveArea Handlers
	//---------------------------------- 
	
    /**
     *  @private
	 *  Handle mouseDown events on the moveArea
     */
    protected function moveArea_mouseDownHandler(event:MouseEvent):void
    {
		// Only allow dragging of pop-upped windows
        if (enabled && isPopUp)
		{
			// Dispatch cancelable "windowMoveStart" event
			startBounds = new Rectangle(x, y, width, height);
			var startEvent:TitleWindowBoundsEvent =
				new TitleWindowBoundsEvent(TitleWindowBoundsEvent.WINDOW_MOVE_START,
										   false, true, startBounds, null);
			dispatchEvent(startEvent);
			
			// Start dragging if the move isn't canceled
			if(!(startEvent.isDefaultPrevented()))
			{
				// Calculate the mouse's offset in the window
				// TODO (klin): Investigate globalToLocal method
				offsetX = event.stageX - x;
				offsetY = event.stageY - y;
				
				var sbRoot:DisplayObject = systemManager.getSandboxRoot();
				
				sbRoot.addEventListener(
					MouseEvent.MOUSE_MOVE, moveArea_mouseMoveHandler, true);
				sbRoot.addEventListener(
					MouseEvent.MOUSE_UP, moveArea_mouseUpHandler, true);
				sbRoot.addEventListener(
					SandboxMouseEvent.MOUSE_UP_SOMEWHERE, moveArea_mouseUpHandler);
				
				// add the mouse shield so we can drag over untrusted applications.
				systemManager.deployMouseShields(true);
			}
			else
			{
				startBounds = null;
			}
		}
    }
	
	/**
	 *  @private
	 */
	protected function moveArea_mouseMoveHandler(event:MouseEvent):void
	{
		// Dispatch cancelable "windowMoving" event with before and after bounds.
		var beforeBounds:Rectangle = new Rectangle(x, y, width, height);
		var afterBounds:Rectangle = 
			new Rectangle(Math.round(event.stageX - offsetX),
						  Math.round(event.stageY - offsetY),
						  width, height);
		
		var e1:TitleWindowBoundsEvent =
			new TitleWindowBoundsEvent(TitleWindowBoundsEvent.WINDOW_MOVING,
									   false, true, beforeBounds, afterBounds);
		dispatchEvent(e1);
		
		// Move only if not canceled.
		if (!(e1.isDefaultPrevented()))
			move(afterBounds.x, afterBounds.y);

		event.updateAfterEvent();
	}
	
	/**
	 *  @private
	 */
	protected function moveArea_mouseUpHandler(event:Event):void
	{
		var sbRoot:DisplayObject = systemManager.getSandboxRoot();
		
		sbRoot.removeEventListener(
			MouseEvent.MOUSE_MOVE, moveArea_mouseMoveHandler, true);
		sbRoot.removeEventListener(
			MouseEvent.MOUSE_UP, moveArea_mouseUpHandler, true);
		sbRoot.removeEventListener(
			SandboxMouseEvent.MOUSE_UP_SOMEWHERE, moveArea_mouseUpHandler);
		
		systemManager.deployMouseShields(false);
		
		// Dispatch "windowMoveEnd" event with the starting bounds and current bounds.
		var endEvent:TitleWindowBoundsEvent =
			new TitleWindowBoundsEvent(TitleWindowBoundsEvent.WINDOW_MOVE_END,
									   false, false, startBounds,
									   new Rectangle(x, y, width, height));
		dispatchEvent(endEvent);
		
		offsetX = NaN;
		offsetY = NaN;
		startBounds = null;
	}

	//----------------------------------
	//  closeButton Handler
	//---------------------------------- 
	
    /**
     *  @private
	 *  Dispatches the "close" event when the closeButton
	 *  is clicked.
     */
    protected function closeButton_clickHandler(event:MouseEvent):void
    {
        dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
    }
    
	//----------------------------------
	//  Active Window Handlers and helper methods
	//---------------------------------- 
	
	/**
	 *  @private
	 */
    private function activateHandler(event:Event):void
    {
        active = true;
        invalidateSkinState();
    }
	
	/**
	 *  @private
	 */
    private function deactivateHandler(event:Event):void
    {
        active = false;
        invalidateSkinState();
    }
	
	/**
	 *  @private
	 *  add listeners to focusManager
	 */
	private function addActivateHandlers():void
	{
		focusManager.addEventListener(FlexEvent.FLEX_WINDOW_ACTIVATE, 
			activateHandler, false, 0, true);
		focusManager.addEventListener(FlexEvent.FLEX_WINDOW_DEACTIVATE, 
			deactivateHandler, false, 0, true);
	}
	
	/**
	 *  @private
	 *  find the right time to listen to the focusmanager
	 */
	private function addedToStageHandler(event:Event):void
	{
		if (event.target == this)
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			callLater(addActivateHandlers);
		}    
	}
	
	/**
	 *  @private
	 *  Called when a FocusManager is added to an IFocusManagerContainer.
	 *  We need to check that it belongs to us before listening to it.
	 *  Because we listen to sandboxroot, you cannot assume the type of
	 *  the event.
	 */
	private function addFocusManagerHandler(event:Event):void
	{
		if (focusManager == event.target["focusManager"])
		{
			systemManager.getSandboxRoot().removeEventListener(FlexEvent.ADD_FOCUS_MANAGER, 
				addFocusManagerHandler, true);
			addActivateHandlers();
		}
	}
}
}