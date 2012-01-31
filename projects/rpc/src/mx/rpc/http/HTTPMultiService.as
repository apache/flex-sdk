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
import mx.messaging.ChannelSet;
import mx.messaging.channels.DirectHTTPChannel;
import mx.messaging.config.LoaderConfig;
import mx.messaging.messages.HTTPRequestMessage;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;
import mx.rpc.AbstractService;
import mx.rpc.events.FaultEvent;
import mx.utils.URLUtil;

use namespace mx_internal;

/**
 *  Dispatched when an HTTPMultiService call returns successfully.
 * @eventType mx.rpc.events.ResultEvent.RESULT 
 */
[Event(name="result", type="mx.rpc.events.ResultEvent")]

/**
 *  Dispatched when an HTTPMultiService call fails.
 * @eventType mx.rpc.events.FaultEvent.FAULT 
 */
[Event(name="fault", type="mx.rpc.events.FaultEvent")]

/**
 *  The invoke event is fired when an HTTPMultiService call is invoked so long as
 *  an Error is not thrown before the Channel attempts to send the message.
 * @eventType mx.rpc.events.InvokeEvent.INVOKE 
 */
[Event(name="invoke", type="mx.rpc.events.InvokeEvent")]

[ResourceBundle("rpc")]

/**
 *  You use the <code>&lt;mx:HTTPMultiService&gt;</code> tag to represent a
 *  collection of http operations.  Each one has a URL, method, parameters and
 *  return type.  You can set attributes such as the URL, method etc. on the
 *  HTTPMultiService tag to act as defaults for values set on each individual
 *  operation tag.  The URL of the HTTPMultiService serves as the base url (i.e. the prefix)
 *  for any relative urls set on the http operation tags.
 *  Each http operation has a <code>send()</code> method, which makes an HTTP request to the
 *  specified URL, and an HTTP response is returned. You can pass
 *  parameters to the specified URL which are used to put data into the HTTP request. 
 *  The contentType property specifies a mime-type which is used to determine the over-the-wire
 *  data format (i.e. HTTP forms, XML).  You can also use a serialization filter to
 *  implement a custom resultFormat such as JSON.   
 *  When you do not go through the server-based
 *  proxy service, you can use only HTTP GET or POST methods. However, when you set
 *  the useProxy  property to true and you use the server-based proxy service, you
 *  can also use the HTTP HEAD, OPTIONS, TRACE, and DELETE methods.
 *
 *  <p><b>Note:</b> Due to a software limitation, like HTTPService, the HTTPMultiService does 
 *  not generate user-friendly error messages when using GET and not using a proxy.</p>
 *  @see mx.rpc.http.mxml.HTTPMultiService, mx.rpc.http.HTTPService, mx.rpc.http.HTTPOperation
 */
[DefaultProperty("operationList")]
public dynamic class HTTPMultiService extends AbstractService
{
    //--------------------------------------------------------------------------
    //
    // Constructor
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  Creates a new HTTPService. If you expect the service to send using relative URLs you may
     *  wish to specify the <code>rootURL</code> that will be the basis for determining the full URL (one example
     *  would be <code>Application.application.url</code>).
     *
     * @param rootURL The URL the HTTPService should use when computing relative URLS.
     */
    public function HTTPMultiService(rootURL:String = null, destination:String = null)
    {
        super();
        
        makeObjectsBindable = true;

        if (destination == null)
        {
            if (URLUtil.isHttpsURL(LoaderConfig.url))
                asyncRequest.destination = HTTPService.DEFAULT_DESTINATION_HTTPS;
            else
                asyncRequest.destination = HTTPService.DEFAULT_DESTINATION_HTTP;
        }
        else
            asyncRequest.destination = destination;
        
        _log = Log.getLogger("mx.rpc.http.HTTPMultiService");
    }

    //--------------------------------------------------------------------------
    //
    // Variables
    // 
    //--------------------------------------------------------------------------
    
    /** 
     *  @private
     *  A shared direct Http channelset used for service instances that do not use the proxy. 
     */
    private static var _directChannelSet:ChannelSet;
    
    /**
     *  @private
     *  Logger
     */
    private var _log:ILogger;

    /**
     *  @private
     */
    private var resourceManager:IResourceManager = ResourceManager.getInstance();

    //--------------------------------------------------------------------------
    //
    // Properties
    // 
    //--------------------------------------------------------------------------

    //----------------------------------
    //  contentType
    //----------------------------------

    [Inspectable(enumeration="application/x-www-form-urlencoded,application/xml", defaultValue="application/x-www-form-urlencoded", category="General")]
    /**
     *  Type of content for service requests. 
     *  The default is <code>application/x-www-form-urlencoded</code> which sends requests
     *  like a normal HTTP POST with name-value pairs. <code>application/xml</code> send
     *  requests as XML.
     */
    public var contentType:String = AbstractOperation.CONTENT_TYPE_FORM;

    //----------------------------------
    //  headers
    //----------------------------------

    [Inspectable(defaultValue="undefined", category="General")]
    /**
     *  Custom HTTP headers to be sent to the third party endpoint. If multiple headers need to
     *  be sent with the same name the value should be specified as an Array.  These headers are sent
     *  to all operations.  You can also set headers at the operation level.
     */
    public var headers:Object = {};

    //----------------------------------
    //  makeObjectsBindable
    //----------------------------------

    [Inspectable(defaultValue="true", category="General")]
    /**
     *  When true, the objects returned support data binding to UI controls - i.e. they
     *  send PropertyChangeEvents when their property values are being changed.  This is the
     *  default value for any operations whose makeObjectsBindable property is not set explicitly.
     */
    public var makeObjectsBindable:Boolean = true;

    //----------------------------------
    //  method
    //----------------------------------

    [Inspectable(enumeration="GET,get,POST,post,HEAD,head,OPTIONS,options,PUT,put,TRACE,trace,DELETE,delete", defaultValue="GET", category="General")]
    /**
     *  HTTP method for sending the request if a method is not set explicit on the operation. 
     *  Permitted values are <code>GET</code>, <code>POST</code>, <code>HEAD</code>,
     *  <code>OPTIONS</code>, <code>PUT</code>, <code>TRACE</code> and <code>DELETE</code>.
     *  Lowercase letters are converted to uppercase letters. The default value is <code>GET</code>.
     */
    public var method:String = HTTPRequestMessage.GET_METHOD;

    //----------------------------------
    //  resultFormat
    //----------------------------------

    /**
     *  @private
     */
    private var _resultFormat:String = AbstractOperation.RESULT_FORMAT_OBJECT;

    [Inspectable(enumeration="object,array,xml,flashvars,text,e4x", defaultValue="object", category="General")]
    /**
     *  Value that indicates how you want to deserialize the result
     *  returned by the HTTP call. The value for this is based on the following:
     *  <ul>
     *  <li>Whether you are returning XML or name/value pairs.</li>
     *  <li>How you want to access the results; you can access results as an object,
     *    text, or XML.</li>
     *  </ul>
     * 
     *  <p>The default value is <code>object</code>. The following values are permitted:</p>
     *  <ul>
     *  <li><code>object</code> The value returned is XML and is parsed as a tree of ActionScript
     *    objects. This is the default.</li>
     *  <li><code>array</code> The value returned is XML and is parsed as a tree of ActionScript
     *    objects however if the top level object is not an Array, a new Array is created and the result
     *    set as the first item. If makeObjectsBindable is true then the Array 
     *    will be wrapped in an ArrayCollection.</li>
     *  <li><code>xml</code> The value returned is XML and is returned as literal XML in an
     *    ActionScript XMLnode object.</li>
     *  <li><code>flashvars</code> The value returned is text containing 
     *    name=value pairs separated by ampersands, which
     *  is parsed into an ActionScript object.</li>
     *  <li><code>text</code> The value returned is text, and is left raw.</li>
     *  <li><code>e4x</code> The value returned is XML and is returned as literal XML 
     *    in an ActionScript XML object, which can be accessed using ECMAScript for 
     *    XML (E4X) expressions.</li>
     *  </ul>
     */
    public function get resultFormat():String
    {
        return _resultFormat;
    }

    /**
     *  @private
     */
    public function set resultFormat(value:String):void
    {
        switch (value)
        {
            case AbstractOperation.RESULT_FORMAT_OBJECT:
            case AbstractOperation.RESULT_FORMAT_ARRAY:
            case AbstractOperation.RESULT_FORMAT_XML:
            case AbstractOperation.RESULT_FORMAT_E4X:
            case AbstractOperation.RESULT_FORMAT_TEXT:
            case AbstractOperation.RESULT_FORMAT_FLASHVARS:
            {
                break;
            }

            default:
            {
                if (value != null && (serializationFilter = SerializationFilter.filterForResultFormatTable[value]) == null)
                {
                    var message:String = resourceManager.getString(
                        "rpc", "invalidResultFormat",
                        [ value, AbstractOperation.RESULT_FORMAT_OBJECT, AbstractOperation.RESULT_FORMAT_ARRAY,
                          AbstractOperation.RESULT_FORMAT_XML, AbstractOperation.RESULT_FORMAT_E4X,
                          AbstractOperation.RESULT_FORMAT_TEXT, AbstractOperation.RESULT_FORMAT_FLASHVARS ]);
                    throw new ArgumentError(message);
                }
            }
        }
        _resultFormat = value;
    }

    /** Default serializationFilter used by all operations which do not set one explicitly */
    public var serializationFilter:SerializationFilter;

    //----------------------------------
    //  rootURL
    //----------------------------------

    /**
     *  @private
     */
    mx_internal var _rootURL:String;

    /**
     *  The URL that the HTTPService object should use when computing relative URLs.
     *  If not set explicitly <code>rootURL</code> is automatically set to the URL of
     *  mx.messaging.config.LoaderConfig.url.
     */
    public function get rootURL():String
    {
        if (_rootURL == null)
            _rootURL = LoaderConfig.url;
        return _rootURL;
    }

    /**
     *  @private
     */
    public function set rootURL(value:String):void
    {
        _rootURL = value;
    }
    
    /**
     *  @private
     */
    override public function set destination(value:String):void
    {
        useProxy = true;
        super.destination = value;
    }

    /**
     *  @private
     */
    private var _useProxy:Boolean = false;
    
    [Inspectable(defaultValue="false", category="General")]
    /**
     *  Specifies whether to use the Flex proxy service. The default value is <code>false</code>. If you
     *  do not specify <code>true</code> to proxy requests though the Flex server, you must ensure that the player 
     *  can reach the target URL. You also cannot use destinations defined in the services-config.xml file if the
     *  <code>useProxy</code> property is set to <code>false</code>.
     *
     *  @default false    
     */
    public function get useProxy():Boolean
    {
        return _useProxy;
    }

    /**
     *  @private
     */
    public function set useProxy(value:Boolean):void
    {
        if (value != _useProxy)
        {
            _useProxy = value;
            var dcs:ChannelSet = getDirectChannelSet();
            if (!useProxy)
            {
                if (dcs != asyncRequest.channelSet)
                    asyncRequest.channelSet = dcs;
            }
            else
            {
                if (asyncRequest.channelSet == dcs)
                    asyncRequest.channelSet = null;
            }
        }
    }

    /**
     * This serves as the default property for this instance so that we can
     * define a set of operations as direct children of the HTTPMultiService
     * tag in MXML.
     */
    public function set operationList(ol:Array):void
    {
        if (ol == null)
            operations = null;
        else
        {
            var op:AbstractOperation;
            var ops:Object = new Object();
            for (var i:int = 0; i < ol.length; i++)
            {
                op = AbstractOperation(ol[i]);
                var name:String = op.name;
                if (!name)
                    throw new ArgumentError("Operations must have a name property value for HTTPMultiService");
                ops[name] = op;
            }
            operations = ops;
        }
    }

    public function get operationList():Array
    {
        // Note: does not preserve order of the elements
        if (operations == null)
            return null;
        var ol:Array = new Array();
        for (var i:String in operations)
        {
            var op:AbstractOperation = operations[i];
            ol.push(op);
        }
        return ol
    }

    /**
     * Ensures that this method reports an accurate error when an attempt is made to 
     * retrieve a non-existent operation.
     */
    override public function getOperation(name:String):mx.rpc.AbstractOperation
    {
        var op:mx.rpc.AbstractOperation = super.getOperation(name);
        if (op == null)
            throw new ArgumentError("No operation named: " + name + " defined on HTTPMultiService");
        return op;
    }

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

    mx_internal function getDirectChannelSet():ChannelSet
    {
        if (_directChannelSet == null)
        {
            var dcs:ChannelSet = new ChannelSet();
            dcs.addChannel(new DirectHTTPChannel("direct_http_channel"));
            _directChannelSet = dcs;            
        }
        return _directChannelSet;  
    }
}

}
