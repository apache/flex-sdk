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
 *  This is an event that is sent between ApplicationDomains
 *  to notify trusted listeners about activity in a particular manager.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
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
     *  Communication between CursorManagers use this request type.
	 *  The <code>name</code> property is the name of some CursorManager property.
	 *  The <code>value</code> property is the value of that property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const CURSOR_MANAGER_REQUEST:String = "cursorManagerRequest";

    /**
     *  Communication between DragManagers use this request type.
	 *  The <code>name</code> property is the name of some DragManager property.
	 *  The <code>value</code> property is the value of that property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const DRAG_MANAGER_REQUEST:String = "dragManagerRequest";

    /**
     *  Ask the other ApplicationDomain to instantiate a manager in
	 *  that ApplicationDomain (if it is not already instantiated)
	 *  so it is available to listen to subsequent
	 *  InterManagerRequests.
	 *  The <code>name</code> property is the name of the manager to instantiate.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const INIT_MANAGER_REQUEST:String = "initManagerRequest";

    /**
     *  Request the SystemManager to perform some action.
	 *  The <code>name</code> property is the name of action to perform.
	 *  The <code>value</code> property is the value needed to perform that action.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const SYSTEM_MANAGER_REQUEST:String = "systemManagerRequest";

    /**
     *  Communication between ToolTipManagers use this request type.
	 *  The <code>name</code> property is the name of some ToolTipManager property.
	 *  The <code>value</code> property is the value of that property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const TOOLTIP_MANAGER_REQUEST:String = "tooltipManagerRequest";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

	/**
	 *  Constructor. Does not return anything, but the <code>value</code> property can be modified
     	 *  to represent a return value of a method.
	 *
	 *  @param type The event type; indicates the action that caused the event.
	 *
	 *  @param bubbles Specifies whether the event can bubble up the display list hierarchy.
	 *
	 *  @param cancelable Specifies whether the behavior associated with the event can be prevented.
	 *
	 *  @param name Name of a property or method or name of a manager to instantiate.
     	 *
	 *  @param value Value of a property, or an array of parameters
     	 *  for a method (if not null).
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
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
     *  Name of property or method or manager to instantiate.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	public var name:String;

    //----------------------------------
    //  value
    //----------------------------------

    /**
     *  Value of property, or array of parameters for method.		
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	public var value:Object;

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
		var cloneEvent:InterManagerRequest = new InterManagerRequest(type, bubbles, cancelable, 
                                                 name, value);

		return cloneEvent;
	}

}

}
