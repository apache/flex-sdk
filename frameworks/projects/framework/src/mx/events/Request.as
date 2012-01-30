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
 *  a responding listener.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class Request extends Event
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    /**
     *  Dispatched from a sub-application or module to find the module factory of its parent
     *  application or module. The recipient of this request should set the data property to 
     *  their module factory.
     * 
     *  The message is dispatched from the content of a loaded module or application.
     */
    public static const GET_PARENT_FLEX_MODULE_FACTORY_REQUEST:String = "getParentFlexModuleFactoryRequest";
    

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
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
