////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.core
{

import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.system.LoaderContext;

import mx.core.mx_internal;

import spark.events.LoaderInvalidationEvent;
use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when content loading is complete.
 *
 *  @eventType flash.events.Event.COMPLETE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="complete", type="flash.events.Event")]

/**
 *  Dispatched when a network request is made over HTTP 
 *  and Flash Player or AIR can detect the HTTP status code.
 * 
 *  @eventType flash.events.HTTPStatusEvent.HTTP_STATUS
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="httpStatus", type="flash.events.HTTPStatusEvent")]

/**
 *  Dispatched when an input/output error occurs.
 *  @see flash.events.IOErrorEvent
 *
 *  @eventType flash.events.IOErrorEvent.IO_ERROR
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="ioError", type="flash.events.IOErrorEvent")]

/**
 *  Dispatched when content is loading.
 *
 *  <p><strong>Note:</strong> 
 *  The <code>progress</code> event is not guaranteed to be dispatched.
 *  The <code>complete</code> event may be received, without any
 *  <code>progress</code> events being dispatched.
 *  This can happen when the loaded content is a local file.</p>
 *
 *  @eventType flash.events.ProgressEvent.PROGRESS
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="progress", type="flash.events.ProgressEvent")]

/**
 *  Dispatched when a security error occurs.
 *  @see flash.events.SecurityErrorEvent
 *
 *  @eventType flash.events.SecurityErrorEvent.SECURITY_ERROR
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="securityError", type="flash.events.SecurityErrorEvent")]

/**
 *  Represents an IContentLoader content request instance returned from
 *  IContentLoader's <code>load()</code> method.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4.5
 */
public class ContentRequest extends EventDispatcher
{   
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor. 
     *
     *  @param contentLoader The IContentLoader object.
     *
     *  @param content A reference to contained content.
     *
     *  @param shared <code>true</code> indicates that this request is currently 
     *  being shared by other previous requests 
     *
     *  @param complete <code>true</code> indicates that someone has called load on a cache, 
     *  and the cache has returned immediately with a fully loaded result 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function ContentRequest(contentLoader:IContentLoader, content:*, 
                                   shared:Boolean=false, complete:Boolean=false)
    {
        super();
        this.content = content;
        _shared = shared;
        _complete = complete;
        contentLoader.addEventListener("invalidateLoader", contentLoader_invalidateLoaderHandler, false, 0, true);
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    private var _shared:Boolean;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  content
    //----------------------------------
    
    /**
     * @private
     */  
    protected var _content:Object;
    
    /**
     *  A reference to contained content. This
     *  can be (among many things), a LoaderInfo instance, BitmapData,
     *  or any other generic content.  When the complete event has fired
     *  and/or complete() returns true, the content is considered valid.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */   
    public function get content():Object
    {
        return _content;
    }
    
    /**
     * @private
     */   
    public function set content(value:Object):void
    {
        removeLoaderListeners();
        _content = value;
        addLoaderListeners();
    }
    
    //----------------------------------
    //  complete
    //----------------------------------
    
    private var _complete:Boolean;
    
    /**
     *  Contains <code>true</code> if content is 
     *  considered fully loaded and accessible.
     * 
     *  @default false
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */  
    public function get complete():Boolean
    {
        if (_content && _content is LoaderInfo)
            return _complete;
        else
            return (_content != null);
    }
        
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     * @private
     */  
    private function addLoaderListeners():void
    {
        if (_content && _content is LoaderInfo)
        {
            var _contentLoaderInfo:LoaderInfo = LoaderInfo(_content);
            
            _contentLoaderInfo.addEventListener(Event.COMPLETE, content_completeHandler, false, 0, true);
            _contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, content_ioErrorHandler, false, 0, true);
            _contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, dispatchEvent, false, 0, true);
            _contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, dispatchEvent, false, 0, true);
            _contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, dispatchEvent, false, 0, true);
        }
    }
    
    /**
     * @private
     */  
    private function removeLoaderListeners():void
    {
        if (_content && _content is LoaderInfo)
        {
            var _contentLoaderInfo:LoaderInfo = LoaderInfo(_content);
            
            _contentLoaderInfo.removeEventListener(Event.COMPLETE, content_completeHandler);
            _contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, content_ioErrorHandler);
            _contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, dispatchEvent);
            _contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, dispatchEvent);
            _contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, dispatchEvent);
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     * @private
     */ 
    mx_internal function content_completeHandler(e:Event):void
    {
        if (e.target == _content)
        {
            _complete = true;
            dispatchEvent(e);
            removeLoaderListeners();
        }
    }
    
    /**
     * @private
     */ 
    mx_internal function content_ioErrorHandler(e:Event):void
    {
        if (e.target == _content)
        {
            if (hasEventListener(IOErrorEvent.IO_ERROR))
                dispatchEvent(e);
        }
    }
    
    /**
     * @private
     * Invoked when a shared LoaderInfo has been revoked from being shared.
     * We must now load our content ourselves. 
     */ 
    mx_internal function contentLoader_invalidateLoaderHandler(e:LoaderInvalidationEvent):void
    {
        if (_shared)
        {
            if (_content == e.content)
            {
                // TODO(crl): We should defer to the owner of this
                // content request to decide how to recover, for now
                // we simply re-request automatically. 
                _shared = false;
                var loader:Loader = new Loader();
                var loaderContext:LoaderContext = new LoaderContext();
                var url:String = _content.url;
                var loaderInfo:LoaderInfo = loader.contentLoaderInfo;
                loaderContext.checkPolicyFile = true;
                loader.load(new URLRequest(url), loaderContext);
            }
        }
    }
    
}
}
