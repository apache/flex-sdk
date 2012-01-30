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
 *  This is an event that is expects its data property to be set by
 *  a responding listener
 */
public class Request extends Event
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

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
	 */
	public function Request(type:String, bubbles:Boolean = false,
                                 cancelable:Boolean = false, 
							     value:Object = null)
	{
		super(type, bubbles, cancelable);

		this.value = value;
	}

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  value
    //----------------------------------

    /**
     *  Value of property, or array of parameters for method.		
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
		var cloneEvent:Request = new Request(type, bubbles, cancelable, 
                                                 value);

		return cloneEvent;
	}

}

}
