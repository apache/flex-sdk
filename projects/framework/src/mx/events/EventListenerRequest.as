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

/**
 *  Request an application in another sandbox or compiled with a different
 *  version of Flex to add a listener to a specified event on your behalf. 
 *  When the requestee is notified the event has occurred
 *  in its domain, the message is sent to the requestor over the
 *  <code>requestor</code> bridge passed in the original request.
 * 
 *  @sendTo parent and/or children
 *  @reply  none
 */
public class EventListenerRequest extends SandboxBridgeRequest
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

	/**
	 *  Request to add an event listener.
	 */
	public static const ADD:String = "mx.managers.SystemManager.addEventListener";

	/**
	 *  Request to remove an event listener.
	 */
	public static const REMOVE:String = "mx.managers.SystemManager.removeEventListener";

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Create a new request to add or remove an event listener.
	 * 
	 *  @param userType type of message your would normally pass to
	 * 		  addEventListener.
	 *  @param useCapture, as in addEventListener.
	 *  @param priority, as in addEventListener.
	 *  @param useWeakReference, as in addEventListener.
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

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  userType
	//----------------------------------

	private var _type:String;
	
	/**
	 *  the type of the event to listen to.
	 *  @see flash.events.Event#type
	 */
	public function get userType():String
	{
		return _type;
	}
	
	//----------------------------------
	//  useCapture
	//----------------------------------

	private var _useCapture:Boolean;

	/**
	 *  the useCapture parameter to addEventListener.
	 *  @see flash.events.IEventDispatcher#addEventListener
	 */
	public function get useCapture():Boolean
	{
		return _useCapture;
	}

	//----------------------------------
	//  priority
	//----------------------------------

	private var _priority:int;
	
	/**
	 *  the priority parameter to addEventListener.
	 *  @see flash.events.IEventDispatcher#addEventListener
	 */
	public function get priority():int
	{
		return _priority;
	}
	
	//----------------------------------
	//  useWeakReference
	//----------------------------------

	private var _useWeakReference:Boolean;

	/**
	 *  the useWeakReference parameter to addEventListener.
	 *  @see flash.events.IEventDispatcher#addEventListener
	 */
	public function get useWeakReference():Boolean
	{
		return _useWeakReference;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: Event
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override public function clone():Event
	{
		return new EventListenerRequest(type, userType, useCapture, priority,
							useWeakReference); 
	}

	/**
	 *  Marshal an event by copying the relevant parameters from the event into a new event
	 */
	public static function marshal(event:Event):Event
	{
		var eventObj:Object = event;
		return new EventListenerRequest(eventObj.type, eventObj.userType, eventObj.useCapture, 
							eventObj.priority, eventObj.useWeakReference); 
	}
}

}