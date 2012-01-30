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

/**
 *  Request sent from one SystemManager to a SystemManager in another 
 *  application through their bridge to add or remove a listener to a specified event 
 *  on your behalf. The <code>data</code> property is not used. Only certain events
 *  can be requested. When the event is triggered in the other application, that
 *  event is re-dispatched through the bridge where the requesting
 *  SystemManager picks up the event and redispatches it from itself.
 *  In general, this request is generated because some other code called
 *  the <code>addEventListener()</code> method for one of the approved events on its SystemManager.
 */
public class EventListenerRequest extends SWFBridgeRequest
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

	/**
	 *  Request to add an event listener.
	 */
	public static const ADD_EVENT_LISTENER_REQUEST:String = "addEventListenerRequest";

	/**
	 *  Request to remove an event listener.
	 */
	public static const REMOVE_EVENT_LISTENER_REQUEST:String = "removeEventListenerRequest";


	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  Marshals an event by copying the relevant parameters
     *  from the event into a new event.
     	*  
     	*  @param event The event to marshal.
     	*  
     	*  @return An EventListenerRequest that defines the new event.
	 */
	public static function marshal(event:Event):EventListenerRequest
	{
		var eventObj:Object = event;

		return new EventListenerRequest(eventObj.type, eventObj.bubbles,
										eventObj.cancelable, eventObj.eventType,
                                        eventObj.useCapture, eventObj.priority,
                                        eventObj.useWeakReference); 
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Creates a new request to add or remove an event listener.
	 * 
	 *  @param type The event type; indicates the action that caused the event. Either <code>EventListenerRequest.ADD</code>
	 *  or <code>EventListenerRequest.REMOVE</code>.
         *
         *  @param bubbles Specifies whether the event can bubble up the display list hierarchy.
         *
         *  @param cancelable Specifies whether the behavior associated with the event can be prevented.
         *
	 *  @param eventType The type of message you would normally pass to the <code>addEventListener()</code> method.
         *
	 *  @param useCapture Determines whether the listener works in the capture phase or the target and bubbling phases.
         *
	 *  @param priority The priority level of the event listener. Priorities are designated by a 32-bit integer.
         *
	 *  @param useWeakReference Determines whether the reference to the listener is strong or weak.
	 * 
	 *  @see flash.events.IEventDispatcher#addEventListener
	 */ 
	public function EventListenerRequest(type:String, bubbles:Boolean = false, 
										 cancelable:Boolean = true,
								         eventType:String = null,
								         useCapture:Boolean = false,
								         priority:int = 0, 
								         useWeakReference:Boolean = false)

	{
		super(type, false, false);

		_eventType = eventType;
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
	//  priority
	//----------------------------------

	/**
     *  @private
     */
	private var _priority:int;
	
	/**
	 *  The <code>priority</code> parameter
     *  to <code>addEventListener()</code>.
     *
	 *  @see flash.events.IEventDispatcher#addEventListener
	 */
	public function get priority():int
	{
		return _priority;
	}
	
	//----------------------------------
	//  useCapture
	//----------------------------------

	/**
     *  @private
     */
	private var _useCapture:Boolean;

	/**
	 *  The <code>useCapture</code> parameter
     *  to <code>addEventListener()</code>.
     *
	 *  @see flash.events.IEventDispatcher#addEventListener
	 */
	public function get useCapture():Boolean
	{
		return _useCapture;
	}

	//----------------------------------
	//  eventType
	//----------------------------------

	/**
     *  @private
     */
    private var _eventType:String;
	
	/**
	 *  The type of the event to listen to.
     *
	 *  @see flash.events.Event#type
	 */
	public function get eventType():String
	{
		return _eventType;
	}
	
	//----------------------------------
	//  useWeakReference
	//----------------------------------

	/**
     *  @private
     */
	private var _useWeakReference:Boolean;

	/**
	 *  The <code>useWeakReference</code> parameter
     *  to <code>addEventListener()</code>.
     *
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
		return new EventListenerRequest(type, bubbles, cancelable,
										eventType, useCapture,
                                        priority, useWeakReference); 
	}
}

}
