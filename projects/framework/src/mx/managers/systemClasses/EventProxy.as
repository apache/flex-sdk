////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.managers.systemClasses
{

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.Event;
import flash.events.MouseEvent;
import mx.events.MarshalMouseEvent;
import mx.utils.EventUtil;
import mx.managers.ISystemManager;

[ExcludeClass]

/**
 * An object that marshals events to other sandboxes
 */
public class EventProxy extends EventDispatcher
{
	private var systemManager:ISystemManager;

	public function EventProxy(systemManager:ISystemManager)
	{
		this.systemManager = systemManager;
	}

	public function marshalListener(event:Event):void
	{
		if (event is MouseEvent)
		{
			var me:MouseEvent = event as MouseEvent;;
			var mme:MarshalMouseEvent = new MarshalMouseEvent(EventUtil.mouseEventMap[event.type],
				false, false, me.ctrlKey, me.altKey, me.shiftKey, me.buttonDown);
			// trace(">>marshalListener", systemManager, mme.type);
			systemManager.dispatchEventFromSWFBridges(mme, null, true);
			// trace("<<marshalListener", systemManager);
		}
	}

}

}
