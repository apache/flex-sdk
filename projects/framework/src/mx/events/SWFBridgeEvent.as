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
 *  This is an event that is sent between applications that are in different security sandboxes.
 *  The event lets objects in other sandboxes know what is going on in this sandbox.
 *  The events are informational in nature as opposed to a SWFBridgeRequest,
 *  which request an object do something on its behalf.
 */
public class SWFBridgeEvent extends Event
{
	include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

	/**
	 *	Dispatched to a parent bridge or sandbox root to notify it that
	 *  another application has been activated.
	 */
    public static const BRIDGE_APPLICATION_ACTIVATE:String =
        "bridgeApplicationActivate";

    /**
     *  Sent through a bridge to a child application's SystemManager to notify it
	 *  that the SWF is about to be unloaded. The SystemManager marshals and
	 *  re-dispatches the event so that application code can remove references
	 *  that would prevent the SWF file from unloading.
     */  
    public static const BRIDGE_APPLICATION_UNLOADING:String = "bridgeApplicationUnloading";

	/**
	 *  Dispatched through bridges to all other FocusManagers to notify them
	 *  that another FocusManager is now active.
	 */
	public static const BRIDGE_FOCUS_MANAGER_ACTIVATE:String =
        "bridgeFocusManagerActivate";

	/**
	 *  Dispatched through a parent bridge to its SWFLoader to notify it
	 *  that a new SystemManager has been initialized. 
	 */
	public static const BRIDGE_NEW_APPLICATION:String =
        "bridgeNewApplication";

	/**
	 *	Dispatched to a parent bridge or sandbox root to notify it that
	 *  a window was activated.
	 * 
	 *  For a compatible application, the <code>data</code> property 
	 *  is an object with two properties, <code>window</code>
	 *  and <code>notifier</code>. The <code>data.window</code> property
     *  is the SystemManager proxy that was activated. 
	 *  For an untrusted application, the <code>data.window</code> property
     *  is a string id of the window. The
     *  <code>data.notifier</code> property is the bridge of the
     *  application dispatching the event. The event might be dispatched
     *  directly to a sandbox root instead of over a bridge, so <code>event.target</code>
     *  might not be the bridge of the application dispatching the event.
	 */
    public static const BRIDGE_WINDOW_ACTIVATE:String = "bridgeWindowActivate";

	/**
	 *	Dispatched to a parent bridge or sandbox root to notify it that
	 *	the proxy SystemManager was deactivated.
	 * 
     *  For a compatible application, the <code>data</code> property 
     *  is an object with two properties, <code>window</code>
     *  and <code>notifier</code>. The <code>data.window</code> property
     *  is the SystemManager proxy that was activated. 
     *  For an untrusted application, the <code>data.window</code> property
     *  is a string id of the window. The
     *  <code>data.notifier</code> property is the bridge of the
     *  application dispatching the event. The event might be dispatched
     *  directly to a sandbox root instead of over a bridge, so <code>event.target</code>
     *  might not be the bridge of the application dispatching the event.
	 */
    public static const BRIDGE_WINDOW_DEACTIVATE:String = "brdigeWindowDeactivate";

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Marshal a SWFBridgeRequest from a remote ApplicationDomain into the current
     *  ApplicationDomain.
     * 
     *  @param event A SWFBridgeRequest which might have been created in a different ApplicationDomain.
     * 
     *  @return A SWFBridgeEvent that was created in the caller's ApplicationDomain.
     */
    public static function marshal(event:Event):SWFBridgeEvent
    {
        var eventObj:Object = event;
        return new SWFBridgeEvent(eventObj.type,
                                  eventObj.bubbles,
                                  eventObj.cancelable,
                                  eventObj.data);
    }

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 * 
     	 *  @param type The event type; indicates the action that caused the event.
     	 *
     	 *  @param bubbles Specifies whether the event can bubble up the display list hierarchy.
     	 *
     	 *  @param cancelable Specifies whether the behavior associated with the event can be prevented.
	 *  
	 *  @param data An object that is null by default, but can contain information about the event, depending on the 
	 *  type of event. 
	 *  
	 */
	public function SWFBridgeEvent(type:String, bubbles:Boolean = false,
                                       cancelable:Boolean = false, 
                                       data:Object = null)
	{
		super(type, bubbles, cancelable);

		this.data = data;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  data
	//----------------------------------

	/**
	 *  Information about the event.
	 */
	public var data:Object;
	

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
		return new SWFBridgeEvent(type, bubbles, cancelable, data);
	} 
}

}
