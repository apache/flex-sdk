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
 *  This is an event sent between application domains
 *  to notify trusted listeners about activity in a particular manager.
 */
public class InterManagerRequest extends Event
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  Communication between CursorManagers use this request type
	 *  The name property is the name of some CursorManager property
	 *  The value property is value of that property
     */
    public static const CURSOR_MANAGER_REQUEST:String = "cursorManagerRequest";

    /**
     *  Communication between DragManagers use this request type
	 *  The name property is the name of some DragManager property
	 *  The value property is value of that property
     */
    public static const DRAG_MANAGER_REQUEST:String = "dragManagerRequest";

    /**
     *  Ask the other ApplicationDomain to instantiate a manager in
	 *  that ApplicationDomain (if it isn't already instantiated)
	 *  so it is available to listen to subsequent
	 *  InterManagerRequests.
	 *  The name property is the name of the manager to instantiate.
     */
    public static const INIT_MANAGER_REQUEST:String = "initManagerRequest";

    /**
     *  Request the SystemManager to perform some action
	 *  The name property is the name of action to perform
	 *  The value property is values needed to perform that action
     */
    public static const SYSTEM_MANAGER_REQUEST:String = "systemManagerRequest";

    /**
     *  Communication between ToolTipManagers use this request type
	 *  The name property is the name of some ToolTipManager property
	 *  The value property is value of that property
     */
    public static const TOOLTIP_MANAGER_REQUEST:String = "tooltipManagerRequest";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 *
	 *  @param name Name of property or method or name of manager to instantiate
     *
	 *  @param value Value of property, or array of parameters
     *  for method (if not-null).
	 *
	 *  @return None, but the value property can be modified
     *  to represent a return value of a method.
	 */
	public function InterManagerRequest(type:String, bubbles:Boolean = false,
                                 cancelable:Boolean = false, 
							     name:String = null, value:Object = null)
	{
		super(type, bubbles, cancelable);

		this.name = name;
		this.value = value;
	}

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  name
    //----------------------------------

    /**
     *  Name of property or method or manager to instantiate
     */
	public var name:String;

    //----------------------------------
    //  value
    //----------------------------------

    /**
     *  Value of property, or array of parameters for method.		
     */
	public var value:Object;
}

}
