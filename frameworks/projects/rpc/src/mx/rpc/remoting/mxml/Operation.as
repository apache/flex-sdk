////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.rpc.remoting.mxml
{

import mx.core.mx_internal;
import mx.rpc.AsyncToken;
import mx.rpc.AsyncDispatcher;
import mx.rpc.mxml.Concurrency;
import mx.rpc.mxml.IMXMLSupport;
import mx.rpc.remoting.RemoteObject;
import mx.rpc.remoting.Operation;
import mx.rpc.remoting.mxml.RemoteObject;
import mx.validators.Validator;

use namespace mx_internal;

[ResourceBundle("rpc")]

/**
 * The Operation used for RemoteObject when created in an MXML document.
 */
public class Operation extends mx.rpc.remoting.Operation implements IMXMLSupport
{
    //--------------------------------------------------------------------------
    //
    // Constructor
    // 
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    public function Operation(remoteObject:mx.rpc.remoting.RemoteObject = null, name:String = null)
    {
        super(remoteObject, name);

    }


    //--------------------------------------------------------------------------
    //
    // Properties
    // 
    //--------------------------------------------------------------------------


    //--------------------------------------------------------------------------
    //
    // Methods
    // 
    //--------------------------------------------------------------------------


    //--------------------------------------------------------------------------
    //
    // Internal Methods
    // 
    //--------------------------------------------------------------------------
    
    /**
     * @private
     * Return the id for the NetworkMonitor
     */
    override mx_internal function getNetmonId():String
    {
        return remoteObject.id;
    }
    

}

}
