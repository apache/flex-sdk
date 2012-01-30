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
 *  This is an event sent between sandboxes.
 *  The event lets objects in other sandboxes know
 *  what is going on in this sandbox.
 *  The events are informational in nature as opposed to SWFBridgeRequests,
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
    public static const NOTIFY_APPLICATION_ACTIVATED:String =
        "notifyApplicationActivate";

    /**
     *  Sent via bridge to a child application's systemManager to notify it
	 *  that the SWF is about to be unloaded.  The systemManager marshals and
	 *  re-dispatches the event so that application code can remove references
	 *  that would prevent the SWF from unloading
     */  
    public static const NOTIFY_BEFORE_UNLOAD:String = "notifyBeforeUnload";

	/**
	 *  Dispatched via bridges to all other FocusManagers to notify them
	 *  that another focus manager is now active.
	 */
	public static const NOTIFY_FOCUS_MANAGER_ACTIVATED:String =
        "notifyFocusManagerActivated";

	/**
	 *  Dispatched via parent bridge to its SWFLoader to notify it
	 *  that a new system manager has been initialized. 
	 */
	public static const NOTIFY_NEW_BRIDGED_APPLICATION:String =
        "notifyNewBridgedApplication";

	/**
	 *	Dispatched to a parent bridge or sandbox root to notify it that
	 *  a window was activated.
	 * 
	 *  For a compatible application, the <code>data</code> property
     *  is set to the system manager proxy that was activated.
	 *  For an untrusted application, the <code>data</code> property
     *  is set to a string id of the window.
	 */
    public static const NOTIFY_WINDOW_ACTIVATED:String = "notifyWindowActivated";

	/**
	 *	Dispatched to a parent bridge or sandbox root to notify it that
	 *	the proxy system manager was deactivated.
	 * 
	 *  For a compatible application, the <code>data</code> property
     *  is set to the system manager proxy that was activated.
	 *  For an untrusted application, the <code>data</code> property
     *  is set to a string id of the window.
     *
	 */
    public static const NOTIFY_WINDOW_DEACTIVATED:String = "notifyWindowDeactivated";

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
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
	 *  Related data.
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
