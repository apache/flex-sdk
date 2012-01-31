////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2006-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.rpc.events
{

import flash.events.Event;
import mx.rpc.wsdl.WSDL;

[ExcludeClass]

/**
 * This event is dispatched when a WSDL XML document has loaded sucessfully.
 * @private
 */
public class WSDLLoadEvent extends XMLLoadEvent
{
    /**
     * Creates a new SchemaLoadEvent.
     */
    public function WSDLLoadEvent(type:String, bubbles:Boolean = false, 
        cancelable:Boolean = true, wsdl:WSDL = null, location:String = null)
    {
        super(type == null ? LOAD : type,
            bubbles,
            cancelable,
            wsdl == null ? null : wsdl.xml,
            location);

        this.wsdl = wsdl;
    }

    /**
     * The full WSDL document.
     */
    public var wsdl:WSDL

    /**
     * Returns a copy of this WSDLLoadEvent.
     */
    override public function clone():Event
    {
        return new WSDLLoadEvent(type, bubbles, cancelable, wsdl, location);
    }

    /**
     * Returns a String representation of this WSDLLoadEvent.
     */
    override public function toString():String
    {
        return formatToString("WSDLLoadEvent", "location", "type", "bubbles",
            "cancelable", "eventPhase");
    }

    /**
     * A helper method to create a new WSDLLoadEvent.
     * @private
     */
    public static function createEvent(wsdl:WSDL, location:String = null):WSDLLoadEvent
    {
        return new WSDLLoadEvent(LOAD, false, true, wsdl, location);
    }

    public static const LOAD:String = "wsdlLoad";
}

}