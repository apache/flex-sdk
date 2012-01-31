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

package mx.rpc.http.mxml
{

import flash.events.ErrorEvent;
import flash.events.ErrorEvent;

import mx.core.mx_internal;
import mx.core.IMXMLObject;
import mx.managers.CursorManager;
import mx.messaging.events.MessageEvent;
import mx.messaging.messages.IMessage;
import mx.messaging.messages.AsyncMessage;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;
import mx.rpc.AsyncToken;
import mx.rpc.AsyncDispatcher;
import mx.rpc.Fault;
import mx.rpc.http.HTTPService;
import mx.rpc.events.AbstractEvent;
import mx.rpc.events.FaultEvent;
import mx.rpc.mxml.Concurrency;
import mx.rpc.mxml.IMXMLSupport;
import mx.validators.Validator;

use namespace mx_internal;

[ResourceBundle("rpc")]

/**
 * You use the <code>&lt;mx:HTTPMultiService&gt;</code> tag to represent an
 * HTTPMultiService object in an MXML file.  The HTTPMultiService is like the
 * HTTPService but supports more than one operation for each individual tag.
 *
 * <p><b>Note:</b> Due to a software limitation, HTTPService does not generate
 * user-friendly error messages when using GET.
 * </p>
 *
 * @see mx.rpc.http.HTTPMultiService
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public dynamic class HTTPMultiService extends mx.rpc.http.HTTPMultiService implements IMXMLSupport, IMXMLObject
{
    //--------------------------------------------------------------------------
    //
    // Constructor
    // 
    //--------------------------------------------------------------------------

    /**
     * Creates a new HTTPMultiService. This constructor is usually called by the generated code of an MXML document.
     * You usually use the mx.rpc.http.HTTPService class to create an HTTPService in ActionScript.
     *
     * @param rootURL The URL the HTTPService should use when computing relative URLS.
     *
     * @param destination An HTTPService destination name in the service-config.xml file.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function HTTPMultiService(rootURL:String = null, destination:String = null)
    {
        super(rootURL, destination);
    }

    //--------------------------------------------------------------------------
    //
    // Variables
    // 
    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    //
    // Properties
    // 
    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    //
    // Public Methods
    // 
    //--------------------------------------------------------------------------

    /**
     * Called after the implementing object has been created and all
     * component properties specified on the MXML tag have been
     * initialized. 
     *
     * If you create this class in ActionScript and want it to function with validation, you must
     * call this method and pass in the MXML document and the
     * HTTPService's <code>id</code>.
     *
     * @param document The MXML document that created this object.
     *
     * @param id The identifier used by <code>document</code> to refer
     * to this object. If the object is a deep property on document,
     * <code>id</code> is null. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function initialized(document:Object, id:String):void
    {
        this.id = id;
        this.document = document;

        initialize();
    }
    
	private var document:Object; //keep the document for validation
    
	private var id:String; //need to know our own id for validation
}

}
