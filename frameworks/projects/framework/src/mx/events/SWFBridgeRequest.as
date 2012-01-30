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
 *  An event that is sent between applications through the sharedEvents
 *  dispatcher that exists between two application SWFs.
 *  The event describes a request for the listener in the other SWF
 *  to perform some action on objects in its SWF and potentially
 *  return some data back to the dispatching SWF.
 *  Unlike typical events, SWFBridgeRequests are an exception to the
 *  event model because properties of the event are modified in order
 *  to return data back to the dispatching SWF.
 *
 *  @see flash.display.LoaderInfo#sharedEvents
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
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
     *  Requests that a child application's pop up be activated.  
     *  This request is sent from a top-level SystemManager to a child SystemManager
	 *  through the bridge.
	 *  The <code>data</code> property contains an identifier for the pop up. It is not
	 *  always an actual reference to the pop up. No data is
	 *  returned.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
    public static const ACTIVATE_POP_UP_REQUEST:String = "activatePopUpRequest";

	/**
	 *  Tests if a given pop up can be activated.
     *  If a pop up is not visible or is not enabled,
     *  then it cannot be activated.
     *  This message is always sent from the top-level SystemManager through the bridge to
	 *  the SystemManager that owns the pop up. The <code>data</code> property
	 *  is an identifier for the pop up. It is not
	 *  always an actual reference to the pop up. The receiving
	 *  SystemManager sets the request's <code>data</code> property to <code>true</code> if
	 *  the pop up can be activated. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const CAN_ACTIVATE_POP_UP_REQUEST:String = "canActivateRequestPopUpRequest";
	 
    /**
         *  Requests that a child application's pop up be deactivated.
         *  This request is sent from a child SystemManager to the top-level SystemManager
	 *  through the bridge. 
	 *  The data property contains an identifier for the pop up.  It is not
	 *  always an actual reference to the pop up.  No data is
	 *  returned.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const DEACTIVATE_POP_UP_REQUEST:String = "deactivatePopUpRequest";

    /**
     *  Requests that the parent SystemManager calculate the visible portion
     *  of the requesting SWF based on any DisplayObjects that
     *  might be clipping the requesting SWF. 
     *  The requests is sent to a parent SystemManager through the bridge.
     *  The results are returned
     *  in the <code>data</code> property which is a Rectangle
     *  in global coordinates.
     * 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */  
    public static const GET_VISIBLE_RECT_REQUEST:String = "getVisibleRectRequest";
    
	/**
	 *  Tests if a given DisplayObject is a child of a SWF
     *  or one of its child SWFs. This request is sent from a SystemManager
	 *  to one or more of its children's SystemManagers through their bridges.  
	 *  The <code>data</code> property
	 *  is a reference to the DisplayObject. The receiving
	 *  SystemManager sets the request's <code>data</code> property to <code>true</code> if
	 *  the DisplayObject is a child of the SWF or one of its child SWFs. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const IS_BRIDGE_CHILD_REQUEST:String = "isBridgeChildRequest";

	/**
	 *  Requests that the loader of the current application invalidate its 
	 *  properties, size, or display list. This request is sent from
	 *  a SystemManager to its parent SystemManager.  The <code>data</code> property
	 *  is a combination of InvalidationRequestData flags. No data is
	 *  returned.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */  
	public static const INVALIDATE_REQUEST:String = "invalidateRequest";
	
    /**
     *  Requests that the mouse cursor should be hidden
	 *  when over this application. This request is sent to the bridge that is shared with
	 *  the parent application and propagated up to the top-level root.
	 *  The <code>data</code> property is not used
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */  
    public static const HIDE_MOUSE_CURSOR_REQUEST:String = "hideMouseCursorRequest";

    /**
     *  Asks the top-level root if the mouse cursor should be hidden given its
	 *  current location. Sent to the bridge shared with
	 *  the parent application and propagated up to the top-level root.
     *  The data is set to true if the mouse cursor should be shown at this location
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */  
    public static const SHOW_MOUSE_CURSOR_REQUEST:String = "showMouseCursorRequest";

    /**
     *  Requests that the show/hide mouse cursor logic be reset for a new mouse
	 *  event so that the various applications can request whether the mouse cursor
	 *  should be shown or hidden. This request is sent to the bridge shared with
	 *  the parent application and propagated up to the top-level root.
	 *  The data property is not used
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */  
    public static const RESET_MOUSE_CURSOR_REQUEST:String = "resetMouseCursorRequest";

	/**
	 *  Sent from the top-level focus manager to a subordinate focus managers
	 *  so all the focus managers participating in a tab loop get activated.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */ 
	public static const ACTIVATE_FOCUS_REQUEST:String = "activateFocusRequest";

	/**
	 *  Sent from the top-level focus manager to a subordinate focus managers
	 *  so all the focus managers participating in a tab loop get deactivated.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */ 
	public static const DEACTIVATE_FOCUS_REQUEST:String = "deactivateFocusRequest";

	/**
	 *  Request to move control over focus to another FocusManager.and have
	 *  that FocusManager give focus to a control under its management based
	 *  on the <code>direction</code> property in the event.
	 * 
     *  When focus is moved back to the parent SWFs FocusManager, the <code>direction</code>
	 *  property is set to <code>FocusDirection.FORWARD</code> or <code>FocusDirection.BACKWARD</code>.
     *  When focus is moved to a child SWFs FocusManager, the <code>direction</code>
	 *  property is set to <code>FocusDirection.TOP</code> or <code>FocusDirection.BOTTOM</code>.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */ 
	public static const MOVE_FOCUS_REQUEST:String = "moveFocusRequest";
	
    /**
     *  Creates a modal window.
     * 
     *  The <code>show</code> property can be used to show the modal window 
     *  after creating it. A value of <code>true</code> shows the modal window.
     *  A value of <code>false</code> lets the modal window remain hidden 
     *  until a <code>ModalWindowRequest.SHOW</code> request is dispatched.
     * 
     *  The <code>data</code> property might have a Rectangle that 
     *  describes the area to exclude from the modal window. The coordinates
     *  of the Rectangle are in global coordinates. The parameter will only be present when 
     *  the requestor trusts the recipient of the request.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const CREATE_MODAL_WINDOW_REQUEST:String = "createModalWindowRequest";
    
    /**
     *  Shows a modal window.
     *
     *  The <code>skip</code> property is used with this request. A value of <code>true</code>
     *  indicates that the recipient should just forward the request up the parent chain 
     *  without processing the request.
     *   
     *  The <code>data</code> property might have a Rectangle that 
     *  describes the area to exclude based on the current parent. The coordinates
     *  are in screen coordinates. The parameter will only be present when 
     *  the requestor trusts the recipient of the message.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const SHOW_MODAL_WINDOW_REQUEST:String = "showModalWindowRequest";
    
    /**
     *  Hides a modal window.
     * 
     *  The <code>remove</code> property determines if the modal window is
     *  removed from the display lists as well as hidden. A value of <code>true</code>
     *  removes the modal window. A value of <code>false</code> hides only the 
     *  modal window. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const HIDE_MODAL_WINDOW_REQUEST:String = "hideModalWindowRequest";

	/**
	 *  Adds a popup on the targeted application.
     	 *  The request is not honored by the targeted application unless there
     	 *  is mutual trust between the dispatching and receiving applications.
	 *  
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const ADD_POP_UP_REQUEST:String = "addPopUpRequest";
	
	/**
	 *  Removes a popup from the sandboxRoot's SystemManager.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const REMOVE_POP_UP_REQUEST:String = "removePopUpRequest";
	
	/**
	 *  Adds a placeholder for a pop up window hosted by a child SystemManager.
	 *  The pop up window is untrusted so it must remain hosted
         *  by a child that trusts it.
	 *  A placeholder is sent to the top-level root SystemManager
         *  so activation and deactivation of all the pop ups can be managed there.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const ADD_POP_UP_PLACE_HOLDER_REQUEST:String = 
				"addPopUpPlaceHolderRequest";

	/**
	 *  Removes a placeholder.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const REMOVE_POP_UP_PLACE_HOLDER_REQUEST:String = 
				"removePopUpPlaceHolderRequest";

	/**
	 *  Gets the size of the child SystemManager.
	 *  Dispatched by the SWFLoader control to the child SystemManager
	 *  to get the size of its content. The child SystemManager
	 *  updates the <code>width</code> and <code>height</code> properties in the event object
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const GET_SIZE_REQUEST:String = "getSizeRequest";
	
	/**
	 *  Sets the size of the <code>child.systemManager</code>.
	 *  Dispatched by the SWFLoader control to the child SystemManager. The child
	 *  SystemManager should update the size of its children 
	 *  based on the <code>width</code> and <code>height</code> properties in the event object
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const SET_ACTUAL_SIZE_REQUEST:String = "setActualSizeRequest";

    /** 
     *  Set the value of the showFocusIndicator property in every application's
     *  FocusManager. The data property is a Boolean that contains the value
     *  showFocusIndicator property will be set to. This request is initially
     *  sent from the FocusManager that has its showFocusIndicator 
     *  property set. From there the request is relayed to each FocusManager in
     *  the system.  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    public static const SET_SHOW_FOCUS_INDICATOR_REQUEST:String = "setShowFocusIndicatorRequest";
     
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Marshals a SWFBridgeRequest from a remote ApplicationDomain into the current
     *  ApplicationDomain.
     * 
     *  @param event A SWFBridgeRequest which may have been created in a different ApplicationDomain.
     * 
     *  @return A SWFBridgeRequest created in the caller's ApplicationDomain.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
	 *  
	 *  @param type The event type; indicates the action that caused the event.
	 *
	 *  @param bubbles Specifies whether the event can bubble up the display list hierarchy.
	 *
	 *  @param cancelable Specifies whether the behavior associated with the event can be prevented.
	 *
	 *  @param requestor The bridge that sent the message.
	 *  
	 *  @param data Data related to the event.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
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
	 *  Data related to the event. For information on how this object is used, see each event type.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var data:Object;
	
	//----------------------------------
	//  requestor
	//----------------------------------

	/**
	 *  The bridge that sent the message.
         *  This in used by the receiving SWF to track which SWFLoader 
	 *  holds the requesting SWF
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
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
