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
     *  @private
     *  Map of source to CacheEntryNode.
     */  
    protected var cachedData:Dictionary = new Dictionary();
    
    /**
     *  @private
     *  Ordered (MRU) list of CacheEntryNode instances.
     */
    protected var cacheEntries:LinkedList = new LinkedList();
        
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
     *  Enables caching behavior and functionality.
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
     *  Enables queuing behavior and functionality.
     * 
     *  @default false;
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
            enforceMaximumEntries();
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
              
    /**
     *  @copy spark.core.IContentLoader#load()
     */
    public function load(source:Object, contentLoaderGrouping:String=null):ContentRequest
    {   
        var key:Object = source is URLRequest ? URLRequest(source).url : source;
        var cacheEntry:CacheEntryNode = cachedData[key];
        var contentRequest:ContentRequest;
               
        if (!cacheEntry || cacheEntry.value == UNTRUSTED || !enableCaching)
        {             
            // No previously cached entry or the entry is marked as
            // unshareable (untrusted).
            var loader:Loader = new Loader();
            var loaderContext:LoaderContext = new LoaderContext();
            loaderContext.checkPolicyFile = true;
			
			// Listen for completion so we can manage our cache entry upon
			// failure or if the loaded data is deemed unshareable.
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_completeHandler, 
				false, 0, true);
			
            var urlRequest:URLRequest = source is URLRequest ? 
                source as URLRequest : new URLRequest(source as String);
            
            loader.load(urlRequest, loaderContext);
            contentRequest = new ContentRequest(this, loader.contentLoaderInfo);
            
            // Now cache our new loader info.
            if (!cacheEntry && enableCaching) 
                addCacheEntry(source, loader.contentLoaderInfo);
        }
        else
        {
            // Found a valid cache entry. Return a content request proxy and
            // promote in our MRU list.
            contentRequest = new ContentRequest(this, cacheEntry.value as LoaderInfo, true);
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
        var cacheEntry:CacheEntryNode = cachedData[source];
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
        enforceMaximumEntries();
    }
    
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
        // TODO (crl)
    }
        
    /**
     *  If size of our cache exceeds our maximum, we release the least
     *  recently used entries necessary to meet our limit.
     * 
     *  @private
     */
    mx_internal function enforceMaximumEntries():void
    {
        if (_maxCacheEntries <= 0 || cacheEntries.length <= _maxCacheEntries)
            return;
    
        while (cacheEntries.length > _maxCacheEntries)
        {
            var node:CacheEntryNode = cacheEntries.pop() as CacheEntryNode;
            delete cachedData[node.source];
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
        if (loaderInfo && !loaderInfo.childAllowsParent)
        {
            // Detected that our loader cannot be shared or cached. Mark 
            // as such and notify and possibly active content requests.
            addCacheEntry(loaderInfo.url, UNTRUSTED);
            dispatchEvent(new LoaderInvalidationEvent(LoaderInvalidationEvent.INVALIDATE_LOADER, loaderInfo));
        }
        loaderInfo.removeEventListener(Event.COMPLETE, loader_completeHandler);
    }
}
}

import mx.utils.LinkedListNode;

/**
 *  Represents a single cache entry.
 *  @private
 */
class CacheEntryNode extends LinkedListNode
{
    public function CacheEntryNode(source:Object, value:Object):void
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
}
