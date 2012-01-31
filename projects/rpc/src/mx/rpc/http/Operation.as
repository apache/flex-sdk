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

package mx.rpc.http
{

import mx.core.mx_internal;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.rpc.AbstractService;
import mx.rpc.AsyncRequest;
import mx.rpc.AsyncToken;

use namespace mx_internal;

/**
 * An Operation used specifically by an HTTPMultiService.  An Operation is an 
 * individual operation on a service usually corresponding to a single operation on the server
 * side.  An Operation can be called either by invoking the
 * function of the same name on the service or by accessing the Operation as a property on the service and
 * calling the <code>send(param1, param2)</code> method.  HTTP services also support a sendBody
 * method which allows you to directly specify the body of the HTTP response.  If you use the
 * send(param1, param2) method, the body is typically formed by combining the argumentNames
 * property of the operation with the parameters sent.  An Object is created which uses the
 * argumentNames[i] as the key and the corresponding parameter as the value.
 * 
 * <p>The exact way in which the HTTP operation arguments is put into the HTTP body is determined
 * by the serializationFilter used.</p>
 */
public class Operation extends AbstractOperation
{
    //---------------------------------
    // Constructor
    //---------------------------------

    /**
     * Creates a new Operation. 
     */
    public function Operation(service:HTTPMultiService = null, name:String = null)
    {
        super(service, name);

        _multiService = service;

        _log = Log.getLogger("mx.rpc.http.HTTPMultiService");
    }
    
    /**
     * Stores the parent service which controls this operation.
     */
    private var _multiService:HTTPMultiService;

    /**
     * Keep track of whether or not this has been set explicitly on the
     * operation.  If not, we'll inherit this value from the service level.
     */
    private var _makeObjectsBindableSet:Boolean;

    [Inspectable(defaultValue="true", category="General")]
    /**
     * When this value is true, anonymous objects returned are forced to bindable objects.
     */
    override public function get makeObjectsBindable():Boolean
    {
        if (_makeObjectsBindableSet)
            return _makeObjectsBindable;
        return _multiService.makeObjectsBindable;    
    }

    override public function set makeObjectsBindable(b:Boolean):void
    {
        _makeObjectsBindable = b;
        _makeObjectsBindableSet = true;
    }

    private var _methodSet:Boolean = false;
    private var _method:String;

    override public function get method():String
    {
        if (_methodSet)
            return _method;

        return _multiService.method;
    }
    override public function set method(m:String):void
    {
        _method = m;
        _methodSet = m != null;
    }

    override mx_internal function setService(s:AbstractService):void
    {
        super.setService(s);
        if (s is HTTPMultiService)
            _multiService = s as HTTPMultiService;

    }

    /**
     * If the rootURL property is not set on the operation, it is inherited from
     * the service level.
     */
    override public function get rootURL():String
    {
        if (_rootURL == null)
        {
            if (_multiService.baseURL != null)
            {
                if (_multiService.baseURL.charAt(_multiService.baseURL.length - 1) != '/')
                    return _multiService.baseURL + "/";
                return _multiService.baseURL;
            }
            else
                return super.rootURL; // defaults to SWF's URL
        }
        return _rootURL;
    }

    private var _useProxySet:Boolean = false;

    override public function get useProxy():Boolean
    {
        if (_useProxySet)
            return super.useProxy;
        return _multiService.useProxy;
    }

    override public function set useProxy(value:Boolean):void
    {
        _useProxySet = true;
        super.useProxy = value;
    }

    //---------------------------------
    // Methods
    //---------------------------------

    /**
     * Executes the http operation. Any arguments passed in are passed along as part of
     * the operation call. If there are no arguments passed, the arguments property of
     * class is used as the source of parameters.  HTTP operations commonly take named
     * parameters, not positional parameters.  To supply the names for these parameters,
     * you can also set the argumentNames property to an array of the property names.
     *
     * @param args Optional arguments passed in as part of the method call. If there
     * are no arguments passed, the arguments object is used as the source of 
     * parameters.
     *
     * @return AsyncToken Call using the asynchronous completion token pattern.
     * The same object is available in the <code>result</code> and
     * <code>fault</code> events from the <code>token</code> property.
     */
    override public function send(... args:Array):AsyncToken
    {
        if (_multiService != null)
            _multiService.initialize();

        if (operationManager != null)
            return operationManager(args);

        var params:Object; 

        var filter:SerializationFilter = getSerializationFilter();
        if (filter != null)
            params = filter.serializeParameters(this, args);
        else
        {
            params = args;
            if (!params || (params.length == 0 && this.request))
                params = this.request;

            if (params is Array && argumentNames != null)
            {
                args = params as Array;
                if (args.length != argumentNames.length)
                    throw new ArgumentError("HTTPMultiService operation called with " + argumentNames.length + " argumentNames and " + args.length + " number of parameters.  When argumentNames is specified, it must match the number of arguments passed to the invocation");
                else
                {
                    for (var i:int = 0; i < argumentNames.length; i++)
                        params[argumentNames[i]] = args[i];
                }
            }
        }
        return sendBody(params);
    }

    override public function get resultFormat():String
    {
        var rf:String = super.resultFormat;
        if (rf == null)
            return _multiService.resultFormat;
        return rf;
    }

    override protected function getSerializationFilter():SerializationFilter
    {
        var sf:SerializationFilter = serializationFilter;
        if (sf == null)
            return _multiService.serializationFilter;
        return sf;
    }

    override protected function getHeaders():Object
    {
        // TODO: support combining the headers maps if both are specified
        if (headers != null)
            return headers;
        else 
            return _multiService.headers;
    }

    /**
     * Use the asyncRequest from the parent service
     */
    override mx_internal function get asyncRequest():AsyncRequest
    {
        // TODO: is this safe?  should we do this in RemoteObject etc. Minimally we
        // need to propagate the multiService.destination to the AsyncRequest if we
        // go with the default implementation of per-operation asyncRequest instances.
        return _multiService.asyncRequest;
    }
}

}
