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
 *  This is an event sent between SWFs via the sharedEvents
 *  dispatcher that exists between two SWFs
 *  The event describes a request for the listener in the other SWF
 *  to perform some action on objects in its SWF and potentially
 *  return some data back to the dispatching SWF.
 *  Unlike typical events, SWFBridgeRequests are an exception to the
 *  event model because properties of the event are modified in order
 *  to return data back to the dispatching SWF.
 *
 *  @see flash.display.LoaderInfo#sharedEvents
 */
public class SWFBridgeRequest extends Event
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

	/**
     *  Request sent from a child systemManager to the top-level systemManager
	 *  via the bridge to request that a child application's pop up be activated.  
	 *  The data property contains an identifier for the pop up.  It is not
	 *  always an actual reference to the pop up.  No data is
	 *  returned.
	 */
    public static const ACTIVATE_POP_UP_REQUEST:String = "activatePopUpRequest";

	/**
	 *  Test if a given pop up can be activated.
     *  If a pop up is not visible or is not enabled,
     *  then it cannot be activated.
     *  This message is always sent from the top-level system manager via the bridge to
	 *  the systemManager that owns the pop up.  The data property
	 *  is an identifier for the pop up.  It is not
	 *  always an actual reference to the pop up.  The receiving
	 *  systemManager sets the request's data property to true if
	 *  the pop up can be activated. 
	 */
	public static const CAN_ACTIVATE_POP_UP_REQUEST:String = "canActivateRequestPopUpRequest";
	 
    /**
     *  Request sent from a child systemManager to the top-level systemManager
	 *  via the bridge to request that a child application's pop up be deactivated.  
	 *  The data property contains an identifier for the pop up.  It is not
	 *  always an actual reference to the pop up.  No data is
	 *  returned.
     */
    public static const DEACTIVATE_POP_UP_REQUEST:String = "deactivatePopUpRequest";

    /**
     *  Request sent to a parent systemManager via the bridge
	 *  to calculate the visible portion
     *  of the requesting SWF based on any display objects that
     *  may be clipping the requesting SWF. The results are returned
     *  in the <code>data</code> property which is a <code>Rectangle</code>
     *  in global coordinates.
     * 
     */  
    public static const GET_VISIBLE_RECT_REQUEST:String = "getVisibleRectRequest";
    
	/**
	 *  Test if a given display object is a child of a SWF
     *  or one of its child SWFs.  This request is sent from a systemManager
	 *  to one or more of its children's systemManagers via their bridges.  
	 *  The data property
	 *  is a reference to the display object.  The receiving
	 *  systemManager sets the request's data property to true if
	 *  the display object is a child of the SWF or one of its child SWFs. 
	 */
	public static const IS_BRIDGE_CHILD_REQUEST:String = "isBridgeChildRequest";

	/**
	 *  Request the loader of the current application to invalidate its 
	 *  properties, size, or display list.  This request is sent from
	 *  a systemManager to its parent systemManager.  The data property
	 *  is a combination of InvalidationRequestData flags.  No data is
	 *  returned.
	 */  
	public static const INVALIDATE_REQUEST:String = "invalidateRequest";
	
    /**
     *  Request that the mouse cursor should be hidden
	 *  when over this application.  Sent to the bridge shared with
	 *  the parent application and propagated up to the top-level root.
	 *  The data property is not used
     */  
    public static const HIDE_MOUSE_CURSOR_REQUEST:String = "hideMouseCursorRequest";

    /**
     *  Ask the top-level root if the mouse cursor should be hidden given its
	 *  current location.  Sent to the bridge shared with
	 *  the parent application and propagated up to the top-level root.
     *  The data is set to true if the mouse cursor should be shown at this location
     */  
    public static const SHOW_MOUSE_CURSOR_REQUEST:String = "showMouseCursorRequest";

    /**
     *  Request that the show/hide mouse cursor logic be reset for a new mouse
	 *  event so the various applications can request whether the mouse cursor
	 *  should be shown or hidden. Sent to the bridge shared with
	 *  the parent application and propagated up to the top-level root.
	 *  The data property is not used
     */  
    public static const RESET_MOUSE_CURSOR_REQUEST:String = "resetMouseCursorRequest";

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Marshal a SWFBridgeRequest from a remote ApplicationDomain into the current
     *  ApplicationDomain.
     * 
     *  @param event A SWFBridgeRequest which may have been created in a different ApplicationDomain.
     * 
     *  @return A SWFBridgeRequest created in the caller's ApplicationDomain.
     */
    public static function marshal(event:Event):SWFBridgeRequest
    {
        var eventObj:Object = event;
        return new SWFBridgeRequest(eventObj.type,
                                        eventObj.bubbles,
                                        eventObj.cancelable,
                                        eventObj.requestor, 
                                        eventObj.data);
    }

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */ 
	public function SWFBridgeRequest(type:String, bubbles:Boolean = false,
                                         cancelable:Boolean = false,
										 requestor:IEventDispatcher = null, 
										 data:Object = null)
	{
		super(type, bubbles, cancelable);
        	
		this.requestor = requestor;
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
	 *  Related data.  See each event type documentation for how this property
	 *  is used.
	 */
	public var data:Object;
	
	//----------------------------------
	//  requestor
	//----------------------------------

	/**
	 *  Bridge that sent the message.
     *  This in used by the receiving SWF to track which SWFLoader 
	 *  holds the requesting SWF
	 */
	public var requestor:IEventDispatcher;
	
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
		return new SWFBridgeRequest(type, bubbles, cancelable,
										requestor, data);
	}
}

}
