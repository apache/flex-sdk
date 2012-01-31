////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.messaging.config
{

import mx.utils.OrderedObject;

[RemoteClass(alias="flex.messaging.config.ConfigMap")]

/**
 *  The ConfigMap class provides a mechanism to store the properties returned 
 *  by the server with the ordering of the properties maintained. 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion BlazeDS 4
 *  @productversion LCDS 3 
 */ 
public dynamic class ConfigMap extends OrderedObject
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     * Constructor.
     *
     * @param item An Object containing name/value pairs.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion BlazeDS 4
     *  @productversion LCDS 3 
     */
    public function ConfigMap(item:Object=null)
    {
        super(item);
    }
}

}
