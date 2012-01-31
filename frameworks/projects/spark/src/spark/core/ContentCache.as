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
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.Dictionary;

import mx.core.mx_internal;
import mx.utils.LinkedList;
import mx.utils.LinkedListNode;

import spark.events.LoaderInvalidationEvent;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when a cache entry is invalidated, generally this
 *  occurs when the entry is determined to be untrusted while one or
 *  more outstanding load requests are active for a given cache entry.
 *  This mechanism allows any outstanding content requests to be reset
 *  due to the fact that the cache entry has been deemed 'unshareable'. 
 *  Each content request notified then attempts instead re-requests the
 *  asset.
 *
 *  @eventType spark.events.LoaderInvalidationEvent
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="invalidateLoader", type="spark.events.LoaderInvalidationEvent")]

/**
 *  Provides a caching and queuing image content loader suitable for using
 *  a shared image cache for the BitmapImage and spark Image components.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4.5
 */
public class ContentCache extends EventDispatcher implements IContentLoader
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function ContentCache():void
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Value used to mark cached URLs that are detected as being from an
     *  untrusted source (meaning they will no longer be shareable).
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4.5
     */
    protected static const UNTRUSTED:String = "untrusted";
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Map of source to CacheEntryNode.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    protected var cachedData:Dictionary = new Dictionary();
    
    /**
     *  Ordered (MRU) list of CacheEntryNode instances.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    protected var cacheEntries:LinkedList = new LinkedList();
    
    /**
     *  List of queued CacheEntryNode instances.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    protected var requestQueue:LinkedList = new LinkedList();
    
    /**
     *  List of queued CacheEntryNode instances currently executing.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    protected var activeRequests:LinkedList = new LinkedList();
    
    /**
     *  Identifier of the currently prioritized content grouping.
     *  @default "_DEFAULT_"
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    protected var priorityGroup:String = "_DEFAULT_";
        
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  enableQueuing
    //----------------------------------
    
    /**
     *  @private
     */
    private var _enableCaching:Boolean = true;
    
    /**
     *  Enables caching behavior and functionality. Applies only to new
     *  load() requests.
     * 
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get enableCaching():Boolean 
    {
        return _enableCaching; 
    }
    
    /**
     *  @private
     */
    public function set enableCaching(value:Boolean):void
    {
        if (value != _enableCaching)
            _enableCaching = value;
    }
    
    //----------------------------------
    //  enableQueuing
    //----------------------------------
    
    /**
     *  @private
     */
    private var _enableQueueing:Boolean = false;
    
    /**
     *  Enables queuing behavior and functionality. Applies only to new
     *  load() requests.
     * 
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get enableQueueing():Boolean 
    {
        return _enableQueueing; 
    }
    
    /**
     *  @private
     */
    public function set enableQueueing(value:Boolean):void
    {
        if (value != _enableQueueing)
            _enableQueueing = value;
    }
      
    //----------------------------------
    //  numCacheEntries
    //----------------------------------
    
    /**
     *  Count of active/in-use cache entries.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get numCacheEntries():int 
    {
        return cacheEntries.length; 
    }
    
    //----------------------------------
    //  maxActiveRequests
    //----------------------------------
    
    /**
     *  @private
     */
    private var _maxActiveRequests:int = 2;
    
    /**
     *  Maximum simultaneous active requests when queuing is
     *  enabled.
     * 
     *  @default 2 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get maxActiveRequests():int 
    {
        return _maxActiveRequests; 
    }
    
    /**
     *  @private
     */
    public function set maxActiveRequests(value:int):void
    {
        if (value != _maxActiveRequests)
            _maxActiveRequests = value;
    }
    
    //----------------------------------
    //  maxCacheEntries
    //----------------------------------
    
    /**
     *  @private
     */
    private var _maxCacheEntries:int = 100;
    
    /**
     *  Maximum size of MRU based cache.  When numCacheEntries exceeds
     *  maxCacheEntries the least recently used are pruned to fit.
     * 
     *  @default 100
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get maxCacheEntries():int 
    {
        return _maxCacheEntries; 
    }
    
    /**
     *  @private
     */
    public function set maxCacheEntries(value:int):void
    {
        if (value != _maxCacheEntries)
        {
            _maxCacheEntries = value;
            enforceMaximumCacheEntries();
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
              
    /**
     *  @copy spark.core.IContentLoader#load()
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function load(source:Object, contentLoaderGrouping:String=null):ContentRequest
    {   
        var key:Object = source is URLRequest ? URLRequest(source).url : source;
        var cacheEntry:CacheEntryNode = cachedData[key];
        var contentRequest:ContentRequest;
               
        if (!cacheEntry || cacheEntry.value == UNTRUSTED || !enableCaching)
        {             
            // No previously cached entry or the entry is marked as
            // unshareable (untrusted), we must execute a Loader request
            // for the data.
            var loader:Loader = new Loader();
            
            // Listen for completion so we can manage our cache entry upon
            // failure or if the loaded data is deemed unshareable.
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, 
                loader_completeHandler, false, 0, true);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, 
                loader_completeHandler, false, 0, true);
            loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, 
                loader_completeHandler, false, 0, true);
            
            var urlRequest:URLRequest = source is URLRequest ? 
                source as URLRequest : new URLRequest(source as String);
            
            // Cache our new LoaderInfo if applicable.
            if (!cacheEntry && enableCaching) 
            {
                addCacheEntry(key, loader.contentLoaderInfo);
                
                // Mark entry as complete, we'll mark complete later 
                // once fully loaded.
                var entry:CacheEntryNode = cachedData[key];
                if (entry)
                    entry.complete = false;
            }
            
            // Create ContentRequest instance to return to caller.
            contentRequest = new ContentRequest(this, loader.contentLoaderInfo);
            
            if (enableQueueing)
            {
                // Queue load request.
                queueRequest(urlRequest, loader, contentLoaderGrouping);
            }
            else
            {
                // Execute Loader
                var loaderContext:LoaderContext = new LoaderContext();
                loaderContext.checkPolicyFile = true;
                loader.load(urlRequest, loaderContext);
            }
        }
        else
        {
            // Found a valid cache entry. Create a ContentRequest instance.
            contentRequest = new ContentRequest(this, cacheEntry.value as LoaderInfo, 
                true, cacheEntry.complete);
            
            // Promote in our MRU list.
            var node:LinkedListNode = cacheEntries.remove(cacheEntry);
            cacheEntries.unshift(node);
        }
        
        return contentRequest;
    }
            
    /**
     *  Obtain an entry for the given key if one exists.
     * 
     *  @param source Unique key used to represent the requested content resource.
     * 
     *  @return A value being stored by the cache for the provided key. Returns 
     *  null if not found or in the likely case the value was stored as null.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function getCacheEntry(source:Object):Object
    {
        var key:Object = source is URLRequest ? URLRequest(source).url : source;
        var cacheEntry:CacheEntryNode = cachedData[key];
        return cacheEntry ? cacheEntry.value : null;
    }
    
    /**
     *  Resets our cache content to initial empty state.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function removeAllCacheEntries():void
    {
        cachedData = new Dictionary();
        cacheEntries = new LinkedList();
    }
    
    /**
     *  Remove specific entry from cache.
     * 
     *  @param source Unique key for value to remove from cache.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5 
     */
    public function removeCacheEntry(source:Object):void
    {
        var key:Object = source is URLRequest ? URLRequest(source).url : source;
        var node:CacheEntryNode = cachedData[key];
        if (node)
        {
            cacheEntries.remove(node);
            delete cachedData[key];
        }
    }
    
    /**
     *  Adds new entry to cache (or replaces existing entry).
     * 
     *  @param source Unique key to associate provided value with in cache.
     *  @param value Value to cache for given key.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5    
     */
    public function addCacheEntry(source:Object, value:Object):void
    {
        var key:Object = source is URLRequest ? URLRequest(source).url : source;
        var node:CacheEntryNode = cachedData[key];
        
        if (node)
            cacheEntries.remove(node);
        
        node = new CacheEntryNode(key, value);
        cachedData[source] = node;
        cacheEntries.unshift(node);
        enforceMaximumCacheEntries();
    }
    
    /**
     *  If size of our cache exceeds our maximum, we release the least
     *  recently used entries necessary to meet our limit.
     * 
     *  @private
     */
    mx_internal function enforceMaximumCacheEntries():void
    {
        if (_maxCacheEntries <= 0)
            return;
        
        while (cacheEntries.length > _maxCacheEntries)
        {
            var node:CacheEntryNode = cacheEntries.pop() as CacheEntryNode;
            var key:Object = (node.source is URLRequest) ? 
                URLRequest(node.source).url : node.source;
            delete cachedData[key];
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Queueing Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Promotes a content grouping to the head of the loading queue.
     * 
     *  @param contentLoaderGrouping Name of content grouping to promote
     *  in the loading queue. All queued requests with matching 
     *  contentLoaderGroup will be shifted to the head of the queue.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function prioritize(contentLoaderGrouping:String):void
    {
        priorityGroup = contentLoaderGrouping;
        shiftPriority();
        processQueue();
    }
         
    /**
     *  Process the request queue and execute any pending requests until we
     *  reach our maxActiveRequests limit.
     * 
     *  @private
     */
    mx_internal function queueRequest(source:URLRequest, loader:Loader, queueGroup:String):void
    {
        var node:QueueEntryNode = new QueueEntryNode(source, loader, queueGroup);
        
        if (queueGroup == priorityGroup)
        {
            // Our new request matches the current priority group, so insert
            // after all currently queued instances of the same priority group.
            
            var current:QueueEntryNode = requestQueue.head as QueueEntryNode;
            
            while (current && current.next && current.queueGroup == priorityGroup)
                current = current.next as QueueEntryNode;
            
            if (current)
            {
                if (current.queueGroup == priorityGroup)
                    requestQueue.insertAfter(node, current);
                else
                    requestQueue.insertBefore(node, current);
            }
            else
                requestQueue.push(node);              
        }    
        else
        {
            // No active priority group, just push to request queue.
            requestQueue.push(node);
        }
        
        processQueue();
    }
    
    /**
     *  Process the request queue and execute any pending requests until we
     *  reach our maxActiveRequests limit.
     * 
     *  @private
     */
    mx_internal function processQueue():void
    {
        if (activeRequests.length < maxActiveRequests && requestQueue.length > 0)
        {
            var node:QueueEntryNode = requestQueue.shift() as QueueEntryNode;
            if (node)
            {
                // Execute load request.
                var loaderContext:LoaderContext = new LoaderContext();
                loaderContext.checkPolicyFile = true;
                var loader:Loader = node.value;
                loader.load(node.urlRequest, loaderContext);

                // Promote to active list.
                activeRequests.push(node);
            }
        }
    }
    
    /**
     *  Resets the queue to initial empty state.  All requests, both active
     *  and queued, are cancelled. All cache entries associated with canceled
     *  requests are invalidated.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function removeAllQueueEntries():void
    {
        // Cancel any active requests and return to queue.
        requeueActive(true);
        
        // Walk queue and invalidate any associated cache entries.
        if (enableCaching)
        {   
            var current:QueueEntryNode = requestQueue.head as QueueEntryNode;
            while (current)
            {
                removeCacheEntry(current.urlRequest.url);
                current = current.next as QueueEntryNode;
            }
        }
        
        // Clear request queue.
        requestQueue = new LinkedList();
    }
    
    /**
     *  Reorder our request queue giving priorityGroup preference.
     *  @private
     */
    mx_internal function shiftPriority():void
    {
        var current:QueueEntryNode = requestQueue.tail as QueueEntryNode;
        var prioritizedNodes:LinkedList = new LinkedList();
        
        // Requeue
        requeueActive();
        
        // Remove all nodes matching current priority queue.
        while (current) 
        {
            var candidate:QueueEntryNode = current;
            current = current.prev as QueueEntryNode;
            if (candidate.queueGroup == priorityGroup)
            {
                requestQueue.remove(candidate);
                prioritizedNodes.push(candidate);
            }
        }   

        // Reinsert to head of list in original queued order.
        while (prioritizedNodes.length)
        {
            current = prioritizedNodes.shift() as QueueEntryNode;
            requestQueue.unshift(current);
        }
    }
    
    /**
     *  Requeues active requests.
     * 
     *  @param requeueAll Cancel all active requests if true,
     *  otherwise cancel and requeue any requests not in the
     *  active priority group.
     * 
     *  @private
     */
    mx_internal function requeueActive(requeueAll:Boolean=false):void
    {
        var current:QueueEntryNode = activeRequests.head as QueueEntryNode;
        while (current)
        {
            var activeNode:QueueEntryNode = current;
            current = current.next as QueueEntryNode;
            if (activeNode.queueGroup != priorityGroup || requeueAll)
            {
                // Remove from active list and invoke close() on the Loader.
                // We'll reinvoke load() again once the queued request is 
                // serviced.
                activeRequests.remove(activeNode);

                try 
                {
                    Loader(activeNode.value).close();
                }
                catch (e:Error) {}
                finally
                {
                    requestQueue.unshift(activeNode);
                }
            }
        }
    }
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Invoked when a request is complete.  We detect if our content is
     *  considered "trusted" and if not, we mark our cache entry to that
     *  effect so that future requests of the same source don't attempt to 
     *  use a cached value.
     * 
     *  @private
     */
    private function loader_completeHandler(e:Event):void
    {
        var loaderInfo:LoaderInfo = e.target as LoaderInfo;
        
        // Lookup our cache entry for this loader. We can't lookup by key since 
        // loaderInfo.url may have been sanitized/modified by the player (or for 
        // example converted to a fully qualified form since our initial request).
        var cachedRequest:CacheEntryNode = cacheEntries.find(loaderInfo) as CacheEntryNode;
        
        if (e.type == Event.COMPLETE && loaderInfo)
        {
            // Mark cache entry as complete. 
            if (cachedRequest)
            {
                cachedRequest.complete = true;
            
                // Detected that our loader cannot be shared or cached. Mark 
                // as such and notify and possibly active content requests.
                if (!loaderInfo.childAllowsParent)
                {
                    addCacheEntry(cachedRequest.source, UNTRUSTED);
                    dispatchEvent(new LoaderInvalidationEvent(LoaderInvalidationEvent.INVALIDATE_LOADER, loaderInfo));
                }
            }
        }
        else if (e.type == IOErrorEvent.IO_ERROR || e.type == SecurityErrorEvent.SECURITY_ERROR)
        {
            // Not suitable for caching.  Lookup our loader info in our cache since
            // the ioError event does not provide us the original url.
            if (cachedRequest)
                removeCacheEntry(cachedRequest.source);
        }
        
        // Remove the related loader from our activeRequests list if applicable.
        if (activeRequests.length > 0 || requestQueue.length > 0)
        {
            var node:LinkedListNode = activeRequests.remove(loaderInfo.loader);
            processQueue();
        }
        
        // Remove our listeners.
        loaderInfo.removeEventListener(Event.COMPLETE, loader_completeHandler);
        loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loader_completeHandler); 
        loaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loader_completeHandler); 
    }
}
}

import mx.utils.LinkedListNode;
import flash.display.Loader;
import flash.net.URLRequest;

/**
 *  Represents a single cache entry.
 *  @private
 */
class CacheEntryNode extends LinkedListNode
{
    public function CacheEntryNode(source:Object, value:Object, queueGroup:String=null):void
    {
        super(value);
        this.source = source;
    }   
    
    //----------------------------------
    //  source
    //----------------------------------
    
    /**
     *  Key into cachedData map for this cache entry.
     *  @private
     */
    public var source:Object;
    
    //----------------------------------
    //  complete
    //----------------------------------
    
    /**
     *  For loaded content denotes that entry is finished loading.
     *  @private
     */
    public var complete:Boolean = true;
}

/**
 *  Represents a single queue entry.
 *  @private
 */
class QueueEntryNode extends LinkedListNode
{
    public function QueueEntryNode(urlRequest:URLRequest, loader:Loader, queueGroup:String):void
    {
        super(loader);
        this.urlRequest = urlRequest;
        this.queueGroup = queueGroup;
    }   
    
    //----------------------------------
    //  source
    //----------------------------------
    
    /**
     *  Key into cachedData map for this cache entry.
     *  @private
     */
    public var urlRequest:URLRequest;
    
    //----------------------------------
    //  queueGroup
    //----------------------------------
    
    /**
     *  Queue group name used for prioritizing queued cached entry requests.
     *  @private
     */
    public var queueGroup:String;
}
