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
     */
    public function ConfigMap(item:Object=null)
    {
        super(item);
    }
}

}
