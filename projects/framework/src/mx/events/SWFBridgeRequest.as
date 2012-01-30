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

	/**
	 *	Sent from the top-level focus manager to a subordinate focus managers
	 *  so all the focus managers participating in a tab loop get activated
	 */ 
	public static const ACTIVATE_FOCUS_REQUEST:String = "activateFocusRequest";

	/**
	 *	Sent from the top-level focus manager to a subordinate focus managers
	 *  so all the focus managers participating in a tab loop get deactivated
	 */ 
	public static const DEACTIVATE_FOCUS_REQUEST:String = "deactivateFocusRequest";

	/**
	 *  Request to move control over focus to another FocusManager.and have
	 *  that FocusManager give focus to a control under its management based
	 *  on the direction propert in the event.
	 * 
     *  When focus is moved back to the parent SWFs FocusManager, the direction
	 *  property is set to FocusDirection.FORWARD or FocusDirection.BACKWARD.
     *  When focus is moved to a child SWFs FocusManager, the direction
	 *  property is set to FocusDirection.TOP or FocusDirection.BOTTOM.
	 */ 
	public static const MOVE_FOCUS_REQUEST:String = "moveFocusRequest";
	
    /**
     *  Create a modal window.
     * 
     *  The <code>show</code> property can be used to show the modal window 
     *  after creating it. A value of <code>true</code> shows the modal window.
     *  A value of <code>false</code> allows the modal window to remain hidden 
     *  until a <code>ModalWindowRequest.SHOW</code> request is dispatched.
     * 
     *  The <code>data</code> property may have a <code>Rectangle</code> that 
     *  describes the area to exclude from the modal window. The coordinates
     *  of the rectangle are in global coordinates. The parameter will only be present when 
     *  the requestor trusts the recipient of the request.
     */
    public static const CREATE_MODAL_WINDOW_REQUEST:String = "createModalWindowRequest";
    
    /**
     *  Show a modal window.
     *
     *  The <code>skip</code> property is used with this request. A value of <code>true</code>
     *  indicates that the recipient should just forward the request up the parent chain 
     *  without processing the
     *  request.
     *   
     *  The <code>data</code> property may have a <code>Rectangle</code> that 
     *  describes the area to exclude based on the current parent. The coordinates
     *  are in screen coordinates. The parameter will only be present when 
     *  the requestor trusts the recipient of the message.
     */
    public static const SHOW_MODAL_WINDOW_REQUEST:String = "showModalWindowRequest";
    
    /**
     *  Hide a modal window.
     * 
     *  The <code>remove</code> property determines if the modal window is
     *  removed from the display lists as well as hidden. A value of <code>true</code>
     *  removes the modals window. A value of <code>false</code> only hides the 
     *  modal window. 
     */
    public static const HIDE_MODAL_WINDOW_REQUEST:String = "hideModalWindowRequest";

	/**
	 *  Add a popup on the targeted application.
     *  The request is not honored by the targeted application unless there
     *  is mutual trust between the dispatching and receiving applications.
	 *  
	 */
	public static const ADD_POP_UP_REQUEST:String = "addPopUpRequest";
	
	/**
	 *  Remove a popup from the sandboxRoot's system manager.
	 */
	public static const REMOVE_POP_UP_REQUEST:String = "removePopUpRequest";
	
	/**
	 *  Add a placeholder for a pop up window hosted by a child SystemManager.
	 *  The pop up window is untrusted so must remain hosted
     *  by a child that trusts it.
	 *  A placeholder is sent to the top-level root SystemManager
     *  so activation and deactivation of all the pop ups can be managed there.
	 */
	public static const ADD_POP_UP_PLACE_HOLDER_REQUEST:String = 
				"addPopUpPlaceHolderRequest";

	/**
	 *  Remove a placeholder.
	 */
	public static const REMOVE_POP_UP_PLACE_HOLDER_REQUEST:String = 
				"removePopUpPlaceHolderRequest";

	/**
	 *  Get the size of the child systemManager.
	 *  Dispatched by SWFLoader to the child systemManager
	 *  to get the size of its content.  The child systemManager
	 *  updates the width and height properties in the event object
	 */
	public static const GET_SIZE_REQUEST:String = "getSizeRequest";
	
	/**
	 *  Set the size of the child.systemManager
	 *  Dispatched by SWFLoader to the child systemManager.  The child
	 *  systemManager should update the size of its children accordingly
	 *  based on the width and height properties in the event object
	 */
	public static const SET_ACTUAL_SIZE_REQUEST:String = "setActualSizeRequest";

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
