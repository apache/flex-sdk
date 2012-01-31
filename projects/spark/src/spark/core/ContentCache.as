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

package spark.core.contentLoader
{

import mx.core.mx_internal;
import mx.utils.LinkedList;
import mx.utils.LinkedListNode;

import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.Dictionary;

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
 *  @eventType spark.core.contentLoader.LoaderInvalidationEvent
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="invalidateLoader", type="spark.core.contentLoader.LoaderInvalidationEvent")]

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
    private var _enableQueuing:Boolean;
    
    /**
     *  Enables queuing behavior and functionality.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get enableQueuing():Boolean 
    {
        return _enableQueuing; 
    }
    
    /**
     *  @private
     */
    public function set enableQueuing(value:Boolean):void
    {
        if (value != _enableQueuing)
            _enableQueuing = value;
    }
      
    //----------------------------------
    //  numEntries
    //----------------------------------
    
    /**
     *  Count of active/in-use cache entries.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get numEntries():Number 
    {
        return cacheEntries.length; 
    }
    
    //----------------------------------
    //  maxActiveRequests
    //----------------------------------
    
    /**
     *  @private
     */
    private var _maxActiveRequests:Number = 2;
    
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
    public function get maxActiveRequests():Number 
    {
        return _maxActiveRequests; 
    }
    
    /**
     *  @private
     */
    public function set maxActiveRequests(value:Number):void
    {
        if (value != _maxActiveRequests)
            _maxActiveRequests = value;
    }
    
    //----------------------------------
    //  maximumEntries
    //----------------------------------
    
    /**
     *  @private
     */
    private var _maxEntries:Number = 100;
    
    /**
     *  Maximum size of MRU based cache.  When numEntries exceeds
     *  maxEntries the least recently used are pruned to fit.
     * 
     *  @default 100
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get maxEntries():Number 
    {
        return _maxEntries; 
    }
    
    /**
     *  @private
     */
    public function set maxEntries(value:Number):void
    {
        if (value != _maxEntries)
        {
            _maxEntries = value;
            enforceMaximumEntries();
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
              
    /**
     *  @copy spark.core.contentLoader.IContentLoader#load
     */
    public function load(source:Object, contentGrouping:String=null):ContentRequest
    {   
        var cacheEntry:CacheEntryNode = cachedData[source];
        var contentRequest:ContentRequest;
               
        if (!cacheEntry || cacheEntry.value == UNTRUSTED)
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
			
            loader.load(new URLRequest(source as String), loaderContext);
            contentRequest = new ContentRequest(this, loader.contentLoaderInfo);
            
            // Now cache our new loader info.
            if (!cacheEntry) 
                addEntry(source, loader.contentLoaderInfo);
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
     *  @private
     *  Invalidation method to invalidate entire cache.
     */
    mx_internal function invalidateAll():void
    {
        removeAll();
    }
    
    /**
     *  Invalidation method to invalidate single cache entry.
     *  @private
     */
	mx_internal function invalidateEntry(source:Object):void
    {
        removeEntry(source);
    }
    
    /**
     *  Obtain an entry for the given key if one exists.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function getEntry(source:Object):*
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
    public function removeAll():void
    {
        cachedData = new Dictionary();
        cacheEntries = new LinkedList();
    }
    
    /**
     *  Remove specific entry from cache.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5 
     */
    public function removeEntry(source:Object):void
    {
        var node:CacheEntryNode = cachedData[source];
        if (node)
        {
            cacheEntries.remove(node);
            delete cachedData[source];
        }
    }
    
    /**
     *  Adds new entry to cache (or replaces existing entry).
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5    
     */
    public function addEntry(source:Object, value:*):void
    {
        var node:CacheEntryNode = cachedData[source];
		
        if (node)
            cacheEntries.remove(node);
        
        node = new CacheEntryNode(source, value);
        cachedData[source] = node;
        cacheEntries.unshift(node);
        enforceMaximumEntries();
    }
    
    /**
     *  Promotes a content grouping to the head of the loading queue.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function prioritizeContentGrouping(contentGrouping:String):void
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
        if (_maxEntries <= 0 || cacheEntries.length <= _maxEntries)
            return;
    
        while (cacheEntries.length > _maxEntries)
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
            addEntry(loaderInfo.url, UNTRUSTED);
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
    public function CacheEntryNode(source:Object, value:*):void
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
