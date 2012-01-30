////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.managers.marshalClasses
{

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;
import flash.ui.Mouse;

import mx.core.FlexSprite;
import mx.core.IFlexModuleFactory;
import mx.events.Request;
import mx.events.InterManagerRequest;
import mx.events.SandboxMouseEvent;
import mx.events.SWFBridgeRequest;
import mx.managers.CursorManagerImpl;
import mx.managers.IMarshalSystemManager;
import mx.managers.ISystemManager;
import mx.core.EventPriority;
import mx.core.mx_internal;

use namespace mx_internal;

[ExcludeClass]

[Mixin]

/**
 *  @private
 *  A SystemManager has various types of children,
 *  such as the Application, popups, 
 *  tooltips, and custom cursors.
 *  You can access the just the custom cursors through
 *  the <code>cursors</code> property,
 *  the tooltips via <code>toolTips</code>, and
 *  the popups via <code>popUpChildren</code>.  Each one returns
 *  a SystemChildrenList which implements IChildList.  The SystemManager's
 *  IChildList methods return the set of children that aren't popups, tooltips
 *  or cursors.  To get the list of all children regardless of type, you
 *  use the rawChildrenList property which returns this SystemRawChildrenList.
 */
public class CursorManagerMarshalMixin
{
    include "../../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class Method
	//
	//--------------------------------------------------------------------------
	
	public static function init(fbs:IFlexModuleFactory):void
	{
		if (!CursorManagerImpl.mixins)
			CursorManagerImpl.mixins = [];
        if (CursorManagerImpl.mixins.indexOf(CursorManagerMarshalMixin) == -1)
    		CursorManagerImpl.mixins.push(CursorManagerMarshalMixin);
	}

    //--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function CursorManagerMarshalMixin(owner:CursorManagerImpl = null)
	{
		super();
        
        if (!owner)
            return;

		cursorManager = owner;
		
        mp = IMarshalSystemManager(systemManager.getImplementation("mx.managers::IMarshalSystemManager"));

		sandboxRoot.addEventListener(InterManagerRequest.CURSOR_MANAGER_REQUEST, marshalCursorManagerHandler, false, 0, true);
		
        var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.CURSOR_MANAGER_REQUEST);
		me.name = "update";
		// trace("--->update request for CursorManagerImpl", sm);
		sandboxRoot.dispatchEvent(me);
		// trace("<---update request for CursorManagerImpl", sm);

        cursorManager.addEventListener("currentCursorID", currentCursorIDHandler);
        cursorManager.addEventListener("currentCursorXOffset", currentCursorXOffsetHandler);
        cursorManager.addEventListener("currentCursorYOffset", currentCursorYOffsetHandler);
        cursorManager.addEventListener("showCursor", showCursorHandler);
        cursorManager.addEventListener("hideCursor", hideCursorHandler);
        cursorManager.addEventListener("setCursor", setCursorHandler);
        cursorManager.addEventListener("removeCursor", removeCursorHandler);
        cursorManager.addEventListener("removeAllCursors", removeAllCursorsHandler);
        cursorManager.addEventListener("setBusyCursor", setBusyCursorHandler);
        cursorManager.addEventListener("removeBusyCursor", removeBusyCursorHandler);
        cursorManager.addEventListener("initialize", initializeHandler);
        cursorManager.addEventListener("addMouseMoveListener", addMouseMoveListenerHandler);
        cursorManager.addEventListener("addMouseOutListener", addMouseOutListenerHandler);
        cursorManager.addEventListener("removeMouseMoveListener", removeMouseMoveListenerHandler);
        cursorManager.addEventListener("removeMouseOutListener", removeMouseOutListenerHandler);
        cursorManager.addEventListener("registerToUseBusyCursor", registerToUseBusyCursorHandler);
        cursorManager.addEventListener("unRegisterToUseBusyCursor", unRegisterToUseBusyCursorHandler);
        cursorManager.addEventListener("showCustomCursor", showCustomCursorHandler);
	}

	//--------------------------------------------------------------------------
	//
	//  Shortcuts to save typing
	//
	//--------------------------------------------------------------------------

	private var cursorManager:CursorManagerImpl;

	private	var mp:IMarshalSystemManager;

	private function get initialized():Boolean
	{
		return cursorManager.initialized;
	}

	private function get sandboxRoot():DisplayObject
	{
		return cursorManager.systemManager.getSandboxRoot();
	}

	private function get systemManager():ISystemManager
	{
		return cursorManager.systemManager;
	}

	private function get cursorHolder():Sprite
	{
		return cursorManager.cursorHolder;
	}

	private function set cursorHolder(value:Sprite):void
	{
		cursorManager.cursorHolder = value;
	}


	//--------------------------------------------------------------------------
	//
	//  Event Handlers
	//
	//--------------------------------------------------------------------------

	public function initializeHandler(event:Event):void
	{
        // The first time a cursor is requested of the CursorManager,
        // create a Sprite to hold the cursor symbol
        cursorHolder = new FlexSprite();
        cursorHolder.name = "cursorHolder";
        cursorHolder.mouseEnabled = false;
        cursorHolder.mouseChildren = false;
        mp.addChildToSandboxRoot("cursorChildren", cursorHolder);

		var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.CURSOR_MANAGER_REQUEST);
		me.name = "initialized";
		// trace("-->dispatched removeBusyCursor for CursorManagerImpl", sm);
		sandboxRoot.dispatchEvent(me);
		// trace("<--dispatched removeBusyCursor for CursorManagerImpl", sm);

		event.preventDefault();
	}

	public function currentCursorIDHandler(event:Event):void
	{
		if (!cursorHolder)
		{
			var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.CURSOR_MANAGER_REQUEST);
			me.name = "currentCursorID";
			me.value = cursorManager.currentCursorID;
			// trace("-->dispatched currentCursorID for CursorManagerImpl", sm, currentCursorID);
			sandboxRoot.dispatchEvent(me);
			// trace("<--dispatched currentCursorID for CursorManagerImpl", sm, currentCursorID);
		}
	}

	public function currentCursorXOffsetHandler(event:Event):void
	{
		if (!cursorHolder)
		{
			var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.CURSOR_MANAGER_REQUEST);
			me.name = "currentCursorXOffset";
			me.value = cursorManager.currentCursorXOffset;
			// trace("-->dispatched currentCursorXOffset for CursorManagerImpl", sm, currentCursorXOffset);
			sandboxRoot.dispatchEvent(me);
			// trace("<--dispatched currentCursorXOffset for CursorManagerImpl", sm, currentCursorXOffset);
		}
	}

	public function currentCursorYOffsetHandler(event:Event):void
	{
		if (!cursorHolder)
		{
			var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.CURSOR_MANAGER_REQUEST);
			me.name = "currentCursorYOffset";
			me.value = cursorManager.currentCursorYOffset;
			// trace("-->dispatched currentCursorYOffset for CursorManagerImpl", sm, currentCursorYOffset);
			sandboxRoot.dispatchEvent(me);
			// trace("<--dispatched currentCursorYOffset for CursorManagerImpl", sm, currentCursorYOffset);
		}
	}

	public function showCursorHandler(event:Event):void
	{
		if (!cursorHolder)
		{
			var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.CURSOR_MANAGER_REQUEST);
			me.name = "showCursor";
			// trace("-->dispatched showCursor for CursorManagerImpl", sm);
			sandboxRoot.dispatchEvent(me);
			// trace("<--dispatched showCursor for CursorManagerImpl", sm);
		}
	}

	public function hideCursorHandler(event:Event):void
	{
		if (!cursorHolder)
		{
			var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.CURSOR_MANAGER_REQUEST);
			me.name = "hideCursor";
			// trace("-->dispatched hideCursor for CursorManagerImpl", sm);
			sandboxRoot.dispatchEvent(me);
			// trace("<--dispatched hideCursor for CursorManagerImpl", sm);
		}
	}

	public function setCursorHandler(event:Request):void
	{
        if (initialized && !cursorHolder)
		{
			var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.CURSOR_MANAGER_REQUEST);
			me.name = "setCursor";
			me.value = event.value
			// trace("-->dispatched setCursor for CursorManagerImpl", sm, me.value);
			sandboxRoot.dispatchEvent(me);
			// trace("<--dispatched setCursor for CursorManagerImpl", sm, me.value);
			event.value = me.value;
			event.preventDefault();
		}
	}

	public function removeCursorHandler(event:Request):void
	{
        if (initialized && !cursorHolder)
		{
			var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.CURSOR_MANAGER_REQUEST);
			me.name = "removeCursor";
			me.value = event.value;
			// trace("-->dispatched removeCursor for CursorManagerImpl", sm, me.value);
			sandboxRoot.dispatchEvent(me);
			// trace("<--dispatched removeCursor for CursorManagerImpl", sm, me.value);
			event.preventDefault();
		}
	}

	public function removeAllCursorsHandler(event:Event):void
	{
        if (initialized && !cursorHolder)
		{
			var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.CURSOR_MANAGER_REQUEST);
			me.name = "removeAllCursors";
			// trace("-->dispatched removeAllCursors for CursorManagerImpl", sm);
			sandboxRoot.dispatchEvent(me);
			// trace("<--dispatched removeAllCursors for CursorManagerImpl", sm);
			event.preventDefault();
		}
	}

	public function setBusyCursorHandler(event:Event):void
	{
        if (initialized && !cursorHolder)
		{
			var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.CURSOR_MANAGER_REQUEST);
			me.name = "setBusyCursor";
			// trace("-->dispatched setBusyCursor for CursorManagerImpl", sm);
			sandboxRoot.dispatchEvent(me);
			// trace("<--dispatched setBusyCursor for CursorManagerImpl", sm);
			event.preventDefault();
		}
	}

	public function removeBusyCursorHandler(event:Event):void
	{
        if (initialized && !cursorHolder)
		{
			var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.CURSOR_MANAGER_REQUEST);
			me.name = "removeBusyCursor";
			// trace("-->dispatched removeBusyCursor for CursorManagerImpl", sm);
			sandboxRoot.dispatchEvent(me);
			// trace("<--dispatched removeBusyCursor for CursorManagerImpl", sm);
			event.preventDefault();
		}
	}

	public function registerToUseBusyCursorHandler(event:Request):void
	{
        if (initialized && !cursorHolder)
		{
			var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.CURSOR_MANAGER_REQUEST);
			me.name = "registerToUseBusyCursor";
			me.value = event.value;
			// trace("-->dispatched registerToUseBusyCursor for CursorManagerImpl", sm, me.value);
			sandboxRoot.dispatchEvent(me);
			// trace("<--dispatched registerToUseBusyCursor for CursorManagerImpl", sm, me.value);
			event.preventDefault();
		}
	}

	public function unRegisterToUseBusyCursorHandler(event:Request):void
	{
        if (initialized && !cursorHolder)
		{
			var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.CURSOR_MANAGER_REQUEST);
			me.name = "unRegisterToUseBusyCursor";
			me.value = event.value;
			// trace("-->dispatched unRegisterToUseBusyCursor for CursorManagerImpl", sm, me.value);
			sandboxRoot.dispatchEvent(me);
			// trace("<--dispatched unRegisterToUseBusyCursor for CursorManagerImpl", sm, me.value);
			event.preventDefault();
		}
	}

	public function addMouseOutListenerHandler(event:Event):void
	{
        if (mp.useSWFBridge())
        {
			sandboxRoot.addEventListener(MouseEvent.MOUSE_OUT,
                                       cursorManager.mouseOutHandler,true,EventPriority.CURSOR_MANAGEMENT);
            event.preventDefault();
        }
    }

	public function addMouseMoveListenerHandler(event:Event):void
	{

        if (mp.useSWFBridge())
        {
			sandboxRoot.addEventListener(MouseEvent.MOUSE_MOVE,
                                       cursorManager.mouseMoveHandler,true,EventPriority.CURSOR_MANAGEMENT);
            sandboxRoot.addEventListener(SandboxMouseEvent.MOUSE_MOVE_SOMEWHERE,
                                       marshalMouseMoveHandler,false,EventPriority.CURSOR_MANAGEMENT);
            event.preventDefault();
        }
	}

	public function removeMouseMoveListenerHandler(event:Event):void
	{                
        if (mp.useSWFBridge())
        {
	        sandboxRoot.removeEventListener(MouseEvent.MOUSE_MOVE,
                                          cursorManager.mouseMoveHandler,true);
            sandboxRoot.removeEventListener(SandboxMouseEvent.MOUSE_MOVE_SOMEWHERE,
                                          marshalMouseMoveHandler,false);
            event.preventDefault();
        }
	}

	public function removeMouseOutListenerHandler(event:Event):void
	{
        if (mp.useSWFBridge())
        {
			sandboxRoot.removeEventListener(MouseEvent.MOUSE_OUT,
                                       cursorManager.mouseOutHandler,true);
            event.preventDefault();
        }
    }
    
    /**
     *  @private
     */
    private function marshalMouseMoveHandler(event:Event):void
    {
		if (cursorHolder.visible)
		{
			// mouse is outside our sandbox, restore it.
			cursorHolder.visible = false;
			var cursorRequest:SWFBridgeRequest = new SWFBridgeRequest(SWFBridgeRequest.SHOW_MOUSE_CURSOR_REQUEST);
			var bridge:IEventDispatcher; 
           	if (mp.useSWFBridge())
			{
				bridge = mp.swfBridgeGroup.parentBridge;; 
			}
			else
				bridge = systemManager;
			cursorRequest.requestor = bridge;
			bridge.dispatchEvent(cursorRequest);
			if (cursorRequest.data)
				Mouse.show();
		}

    }
    

    private function showCustomCursorHandler(event:Event):void
	{
		var cursorRequest:SWFBridgeRequest = new SWFBridgeRequest(SWFBridgeRequest.HIDE_MOUSE_CURSOR_REQUEST);
		var bridge:IEventDispatcher;
        if (mp.useSWFBridge())
		{
			bridge = mp.swfBridgeGroup.parentBridge;; 
		}
		else
			bridge = systemManager;
		cursorRequest.requestor = bridge;
		bridge.dispatchEvent(cursorRequest);
    }

	/**
	 *  Marshal cursorManager
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	private function marshalCursorManagerHandler(event:Event):void
	{
		if (event is InterManagerRequest)
			return;

		var marshalEvent:Object = event;
		switch (marshalEvent.name)
		{
		case "initialized":
			// trace("--marshaled initialized for CursorManagerImpl", sm, marshalEvent.value);
			cursorManager.initialized = marshalEvent.value;
			break;
		case "currentCursorID":
			// trace("--marshaled currentCursorID for CursorManagerImpl", sm, marshalEvent.value);
			cursorManager._currentCursorID = marshalEvent.value;
			break;
		case "currentCursorXOffset":
			// trace("--marshaled currentCursorXOffset for CursorManagerImpl", sm, marshalEvent.value);
			cursorManager._currentCursorXOffset = marshalEvent.value;
			break;
		case "currentCursorYOffset":
			// trace("--marshaled currentCursorYOffset for CursorManagerImpl", sm, marshalEvent.value);
			cursorManager._currentCursorYOffset = marshalEvent.value;
			break;
		case "showCursor":
			if (cursorHolder)
			{
				// trace("--marshaled showCursor for CursorManagerImpl", sm);
				cursorHolder.visible = true;
;			}
			break;
		case "hideCursor":
			if (cursorHolder)
			{
				// trace("--marshaled hideCursor for CursorManagerImpl", sm);
				cursorHolder.visible = false;
;			}
			break;
		case "setCursor":
			// trace("--marshaled setCursor for CursorManagerImpl", sm, marshalEvent.value);
			if (cursorHolder)
			{
				marshalEvent.value = cursorManager.setCursor.apply(cursorManager, marshalEvent.value);
			}
			break;
		case "removeCursor":
			if (cursorHolder)	// it is our drag
			{
				cursorManager.removeCursor.apply(cursorManager, [ marshalEvent.value ]);
				// trace("--marshaled removeCursor for CursorManagerImpl", sm, marshalEvent.value);
			}
			break;
		case "removeAllCursors":
			// trace("--marshaled removeAllCursors for CursorManagerImpl", sm);
			if (cursorHolder)
				cursorManager.removeAllCursors();
			break;
		case "setBusyCursor":
			// trace("--marshaled setBusyCursor for CursorManagerImpl", sm);
			if (cursorHolder)
				cursorManager.setBusyCursor();
			break;
		case "removeBusyCursor":
			// trace("--marshaled removeBusyCursor for CursorManagerImpl", sm);
			if (cursorHolder)
				cursorManager.removeBusyCursor();
			break;
		case "registerToUseBusyCursor":
			// trace("--marshaled registerToUseBusyCursor for CursorManagerImpl", sm, marshalEvent.value);
			if (cursorHolder)
				cursorManager.registerToUseBusyCursor.apply(this, marshalEvent.value);
			break;
		case "unRegisterToUseBusyCursor":
			// trace("--marshaled unRegisterToUseBusyCursor for CursorManagerImpl", sm, marshalEvent.value);
			if (cursorHolder)
				cursorManager.unRegisterToUseBusyCursor.apply(this, marshalEvent.value);
			break;
		case "update":
			// if we own the cursorHolder, then we're first CursorManager
			// so update the others
			if (cursorHolder)
			{
				// trace("-->marshaled update for CursorManagerImpl", sm);
				var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.CURSOR_MANAGER_REQUEST);
				me.name = "initialized";
				me.value = true;
				// trace("-->dispatched initialized for CursorManagerImpl", sm, true);
				sandboxRoot.dispatchEvent(me);
				// trace("<--dispatched initialized for CursorManagerImpl", sm, true);
				me = new InterManagerRequest(InterManagerRequest.CURSOR_MANAGER_REQUEST);
				me.name = "currentCursorID";
				me.value = cursorManager.currentCursorID;
				// trace("-->dispatched currentCursorID for CursorManagerImpl", sm, true);
				sandboxRoot.dispatchEvent(me);
				// trace("<--dispatched currentCursorID for CursorManagerImpl", sm, true);
				me = new InterManagerRequest(InterManagerRequest.CURSOR_MANAGER_REQUEST);
				me.name = "currentCursorXOffset";
				me.value = cursorManager.currentCursorXOffset;
				// trace("-->dispatched currentCursorXOffset for CursorManagerImpl", sm, true);
				sandboxRoot.dispatchEvent(me);
				// trace("<--dispatched currentCursorXOffset for CursorManagerImpl", sm, true);
				me = new InterManagerRequest(InterManagerRequest.CURSOR_MANAGER_REQUEST);
				me.name = "currentCursorYOffset";
				me.value = cursorManager.currentCursorYOffset;
				// trace("-->dispatched currentCursorYOffset for CursorManagerImpl", sm, true);
				sandboxRoot.dispatchEvent(me);
				// trace("<--dispatched currentCursorYOffset for CursorManagerImpl", sm, true);
				// trace("<--marshaled update for CursorManagerImpl", sm);
			}
		}
	}
}

}
