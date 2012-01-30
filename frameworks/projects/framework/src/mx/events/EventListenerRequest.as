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

package mx.events
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	public class EventListenerRequest extends SandboxBridgeRequest
	{
	   /**
	    * Request an application in another sandbox or compiled with a different
	    * version of Flex to add a listener to a specified event on your behalf. 
	    * When the requestee is notified the event has occurred
	    * in its domain, the message is sent to the requestor over the
	    * <code>requestor</code> bridge passed in the original request.
	    * 
	    * @sendTo parent and/or children
	    * @reply  none
	    */
		public static const ADD:String = "mx.managers.SystemManager.addEventListener";
		public static const REMOVE:String = "mx.managers.SystemManager.removeEventListener";

		private var _type:String;
		private var _useCapture:Boolean;
		private var _priority:int;
		private var _useWeakReference:Boolean;
        private var _useStage:Boolean;
		
		/**
		 * Create a new addEventListener request.
		 * 
		 * @param userType type of message your would normally pass to
		 * 		  addEventListener.
		 * @param useCapture, as in addEventListener.
		 * @param priority, as in addEventListener.
		 * @param useWeakReference, as in addEventListener.
		 * @param useStage true if a stage listener listener should be added
		 *        if this request is sent to a top-level system manager.
		 * @param requestor the bridge of the application who sent this request.
		 * @param data optional parameter, not used
		 */ 
		public function EventListenerRequest(requestType:String,
									userType:String,
									useCapture:Boolean = false,
									priority:int = 0, 
									useWeakReference:Boolean = false)

		{
			super(requestType, false, false);
			_type = userType;
			_useCapture = useCapture;
			_priority = priority;
			_useWeakReference = useWeakReference;
		}

		public function get userType():String
		{
			return _type;
		}
		
		public function get useCapture():Boolean
		{
			return _useCapture;
		}

		
		public function get priority():int
		{
			return _priority;
		}
		
		public function get useWeakReference():Boolean
		{
			return _useWeakReference;
		}

		
		override public function clone():Event
		{
			return new EventListenerRequest(type, userType, useCapture, priority,
								useWeakReference); 
		}

		public static function marshal(event:Event):Event
		{
			var eventObj:Object = event;
			return new EventListenerRequest(eventObj.type, eventObj.userType, eventObj.useCapture, 
								eventObj.priority, eventObj.useWeakReference); 
		}
	}
}