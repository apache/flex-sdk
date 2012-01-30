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

package mx.collections
{
import flash.events.Event;
import flash.utils.getQualifiedClassName;

import mx.collections.errors.ItemPendingError;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.utils.OnDemandEventDispatcher;

use namespace mx_internal;  // for mx_internal functions pendingItemSucceeded,Failed()

/**
 *  Dispatched when the list's length has changed or when a list
 *  element is replaced.
 *
 *  @eventType mx.events.CollectionEvent.COLLECTION_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="collectionChange", type="mx.events.CollectionEvent")]

/**
 *  A "wrapper" for IList implementations that handles ItemPendingErrors
 *  thrown by <code>getItemAt()</code>.
 * 
 *  <p>The getItemAt() method handles ItemPendingErrors by returning a provisional 
 *  "pending" item until the underlying request succeeds or fails.  The provisional
 *  item is produced by calling <code>createPendingItemFunction</code>.  If the request
 *  succeeds, the actual item replaces the provisional one, and if it fails 
 *  the provisional item is replaced by with the item returned by calling
 *  <code>createFailedItemFunction</code>.</p>
 * 
 *  <p>This class delegates the IList methods and properties to its <code>list</code>.
 *  If a list isn't specified, methods that mutate the collection are no-ops, 
 *  and methods that query the collection return an "empty" value like null or zero
 *  as appropriate.</p>
 * 
 *  <p>This class is intended to be used with Spark components based on DataGroup,
 *  like List and ComboBox, which don't provide intrinsic support for 
 *  ItemPendingError handling.</p>
 * 
 * 
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class AsyncListView extends OnDemandEventDispatcher implements IList
{
    /**
     *  AsyncListView constructor.
     *
     *  @param list Initial value of the list property, the IList we're delegating to.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function AsyncListView(list:IList = null)
    {
        super();
        this.list = list;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  list
    //----------------------------------
    
    private var _list:IList;
    
    [Inspectable(category="General")]
    [Bindable("listChanged")]
    
    /**
     *  The IList that this collection view "wraps", i.e. the object to which all of 
     *  the IList metods are delegated.
     * 
     *  <p>If this property is null, the IList mutation methods, like <code>setItemAt()</code>,
     *  are no-ops and the IList query methods, like <code>getItemAt()</code> return, null
     *  or zero (-1 for <code>getItemIndex()</code>), as appropriate.</p>
     * 
     *  @default null  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get list():IList
    {
        return _list;
    }
    
    /**
     *  @private
     */
    public function set list(value:IList):void
    {
        if (_list == value)
            return;

        deleteAllPendingResponders();
        if (_list)
            _list.removeEventListener(CollectionEvent.COLLECTION_CHANGE, handleCollectionChangeEvent);
        _list = value;
        if (_list)
            _list.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleCollectionChangeEvent);

        dispatchEvent(new Event("listChanged"));
        dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.RESET));
    }

    /**
     *  @private
     */
    private function deleteAllPendingResponders():void
    {
        for each (var responder:ListItemResponder in pendingResponders)
            responder.index = -1;
        pendingResponders.length = 0;
    }

    /**
     *  @private
     *  Fixup the pendingResponders array after a change to the list.  Generally speaking,
     *  if a list[index] item changes, the pending responder for that index is no longer needed.
     *  
     *  All "collectionChange" events are redispatched to the AsyncListView listeners.
     */
    private function handleCollectionChangeEvent(e:Event):void
    {
        const ce:CollectionEvent = CollectionEvent(e);
        switch (ce.kind)
        {
            case CollectionEventKind.REPLACE:
            case CollectionEventKind.UPDATE:
                deletePendingResponders(ce);
                break;
                
            case CollectionEventKind.MOVE:
                movePendingResponders(ce);
                break;
                
            case CollectionEventKind.ADD:
                shiftPendingRespondersRight(ce);
                break;

            case CollectionEventKind.REMOVE:
                shiftPendingRespondersLeft(ce);
                break;
                
            case CollectionEventKind.RESET:
            case CollectionEventKind.REFRESH:
                deleteAllPendingResponders();
                break;
        }
        
        dispatchEvent(e);  // redispatch to CollectionEvent listeners on this
    }


    /**
     *  @private
     *  Delete the ListItemResponder at the specified index, if any.
     *  If a pending responder exists, return its item.
     *   
     *  This method assumes that the responder hasn't run yet, it sets
     *  the ListItemResponder index to -1 to prevent it from updating
     *  this AsyncListView later.
     */
    private function deletePendingResponder(index:int):Object
    {
        if ((index < 0) || (index >= pendingResponders.length))
            return null;

        const pendingResponder:ListItemResponder = pendingResponders[index];
        if (pendingResponder)
        {
            delete pendingResponders[index];
            ListItemResponder(pendingResponder).index = -1; 
            return pendingResponder.item;
        }
        
        return null;
    }

    /**
     *  @private
     *  Handler for a CollectionEventKind.UPDATE or REPLACE event. In either
     *  case a contiguous block of items (ce.items) beginning with index=ce.location
     *  has been changed.  If there are any pending requests for these indices, we
     *  assume they're no longer valid, i.e. we assume that getItemAt() should no longer
     *  return the pending item.
     * 
     *  Note that when a pending request succeeds, a REPLACE event is dispatched by 
     *  the underlying list.   When a pending request fails, we set the corresponding 
     *  list item, which also causes a REPLACE even to be dispatched.
     */
    private function deletePendingResponders(ce:CollectionEvent):void
    {
        var index:int = ce.location;
        for each (var item:Object in ce.items)
            deletePendingResponder(index++);
    }

    /**
     *  @private
     *  Handler for a CollectionEventKind.MOVE event.  The event indicates that a 
     *  contiguous block of items (ce.items), beginning with index=ce.oldLocation,
     *  has been moved to ce.location.  If pendingRequests already exist at ce.location,
     *  they're deleted first.
     */
    private function movePendingResponders(ce:CollectionEvent):void
    {
        var fromIndex:int = ce.oldLocation;
        var toIndex:int = ce.location;
        for each (var item:Object in ce.items)
        {
            const pendingResponder:ListItemResponder = pendingResponders[fromIndex];
            if (pendingResponder)
            {
                delete pendingResponders[fromIndex];
                ListItemResponder(pendingResponder).index = toIndex; 
                deletePendingResponder(toIndex); // in case we're copying over a pending request
                pendingResponders[toIndex] = pendingResponder;
            }
            fromIndex += 1;
            toIndex += 1;
        }
    }

    /**
     *  @private
     *  Handler for a CollectionEventKind.ADD.  The event indicates 
     *  that a block of ce.items.length items starting at ce.location was inserted,
     *  which implies that all of the pendingResponders whose index is greater than or
     *  equal to ce.location, must be shifted right by ce.items.length.
     */
    private function shiftPendingRespondersRight(ce:CollectionEvent):void
    {
        const delta:int = ce.items.length;
        const startIndex:int = ce.location;

        const pendingRespondersCopy:Array = sparseCopy(pendingResponders);
        pendingResponders.length = 0;
        for each (var responder:ListItemResponder in pendingRespondersCopy)
        {
            if (responder.index >= startIndex)
                responder.index += delta;
            pendingResponders[responder.index] = responder;
        } 
    }

    /**
     *  @private
     *  Handler for a CollectionEventKind.REMOVE.  The event indicates 
     *  that a block of ce.items.length items starting at ce.location was removed,
     *  which implies that all of the pendingResponders whose index is greater than or
     *  equal to ce.location, must be shifted left by ce.items.length.
     */
    private function shiftPendingRespondersLeft(ce:CollectionEvent):void
    {
        const delta:int = ce.items.length;
        const startIndex:int = ce.location + delta;
        
        const pendingRespondersCopy:Array = sparseCopy(pendingResponders);
        pendingResponders.length = 0;
        for each (var responder:ListItemResponder in pendingRespondersCopy)
        {
            if (responder.index >= startIndex)
                responder.index -= delta;
            pendingResponders[responder.index] = responder;
        } 
    }
    
    /**
     *  Applying concat() to a sparse array produces a new array that's
     *  not sparse, nulls replace items that were undefined.  Although the 
     *  result of this method is not sparse, it only includes items that 
     *  were in the original array.
     */
    private function sparseCopy(a:Array):Array
    {
        const r:Array = new Array();
        var index:int = 0;
        for each (var item:* in a)
            r[index++] = item;
        return r;
    }
    
    //----------------------------------
    //  createPendingItemFunction
    //----------------------------------
    
    private var _createPendingItemFunction:Function = defaultCreatePendingItemFunction;
    
    /**
     *  @private
     */
    private function defaultCreatePendingItemFunction(index:int, ipe:ItemPendingError):Object
    {
        return null;        
    }
    
    /**
     *   A function that's used to create a provisional item when
     *   the initial request causes an <code>ItemPendingError</code> to be thrown.
     *   If the request eventually succeeds, the provisional item is automatically
     *   replaced by the actual item.  If the request fails, then the item is replaced
     *   with one created with the <code>createFailedItemFunction</code>.
     *  
     *   <p>The value of this property must be a function with two parameters, the index
     *   of the requested dataProvider item, and the ItemPendingError itself.  In most
     *   cases second parameter can be ignored, e.g.: 
     *   <pre>
     * function createPendingItem(index:int, ipe:ItemPendingError):Object
     * {
     *     return "[" + index + "request is pending...]";        
     * }
     *   </pre>
     *   </p>
     * 
     *  <p>Setting this property does not affect provisional pending items that were already
     *  created.  Setting this property to null will prevent provisional pending items 
     *  from being created.</p>
     * 
     *  @default A function that unconditionally returns null. 
     *  @see #getItemAt
     *  @see createFailedItemFunction
     *  @see mx.collections.errors.ItemPendingError
     */
    public function get createPendingItemFunction():Function
    {
        return _createPendingItemFunction;
    }
    
    /**
     *  @private
     */
    public function set createPendingItemFunction(value:Function):void
    {
        _createPendingItemFunction = value;
    }
    
    
    //----------------------------------
    //  createFailedItemFunction
    //----------------------------------
    
    private var _createFailedItemFunction:Function = defaultCreateFailedItemFunction;
    
    /**
     *  @private
     */
    private function defaultCreateFailedItemFunction(index:int, info:Object):Object
    {
        return null;        
    }
    
    /**
     *  A function that's used to create a substitute item when
     *  a request which had caused an <code>ItemPendingError</code> to be thrown, 
     *  subsequently fails.  The existing item, typically a pending item created
     *  with the value of <code>createPendingItemFunction()</code>, is replaced
     *  with the failed item.
     *  
     *  <p>The value of this property must be a function with two parameters, the index
     *  of the requested item, and the failure "info" object, which is
     *  passed along from the IResponder fault() method.  In most cases second parameter 
     *  can be ignored, e.g.:</p> 
     *  <pre>
     * function createFailedItem(index:int, info:Object):Object
     * {
     *     return "[" + index + "request failed]";        
     * }
     *   </pre>
     *  
     * 
     *  <p>Setting this property does not affect failed items that were already
     *  created.  Setting this property to null will prevent failed items from being created.
     *  </p>
     * 
     *  @default A function that unconditionally returns null. 
     *  @see #getItemAt
     *  @see createPendingItemFunction
     *  @see mx.rpc.IResponder#fault
     */
    public function get createFailedItemFunction():Function
    {
        return _createFailedItemFunction;
    }
    
    /**
     *  @private
     */
    public function set createFailedItemFunction(value:Function):void
    {
        _createFailedItemFunction = value;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    private const pendingResponders:Array = new Array();
    
    /**
     *  @private
     *  Called by the ListItemProvider/result() method when a pending request
     *  completes successfully.
     * 
     *  @param index The item's index.
     *  @param info The informational object passed to IResponder/result().
     *  @see mx.rpc.IResponder#result
     */
    mx_internal function pendingRequestSucceeded(index:int, info:Object):void
    {
        delete pendingResponders[index];
    }

    /**
     *  @private
     *  Called by the ListItemProvider/fault() method when a pending request
     *  fails.
     * 
     *  @param index The item's index.
     *  @param info The informational object passed to IResponder/fault().
     *  @see mx.rpc.IResponder#fault
     */
    mx_internal function pendingRequestFailed(index:int, info:Object):void
    {
        delete pendingResponders[index];

        var item:Object = null;
        if (createFailedItemFunction !== null)
        {
            item = createFailedItemFunction(index, info);
            list.setItemAt(item, index); 
        }
    }
            
    
    //--------------------------------------------------------------------------
    //
    //  IList Implementation
    //
    //--------------------------------------------------------------------------

    [Bindable("collectionChange")]
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get length():int
    {
        return (list) ? list.length : 0;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function addItem(item:Object):void
    {
        if (list)
            list.addItem(item);
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function addItemAt(item:Object, index:int):void
    {
        if (list)
            list.addItemAt(item, index);
    }
    
    /**
     *  Returns the value of <code>list.getItemAt(index)</code>.
     * 
     *  <p>This method catches ItemPendingErrors (IPEs) generated as a consequence of 
     *  calling getItemAt().  If an IPE is thrown, an <code>IResponder</code> is added to
     *  the IPE and a provisional "pending" item, created with the 
     *  <code>createPendingItemFunction</code> is returned.   If the underlying request
     *  eventually succeeds, the pending item is replaced with the real item.  If it fails,
     *  the pending item is replaced with a value produced by calling
     *  <code>createFailedItemFunction</code>.</p>
     * 
     *  @param index The list index from which to retrieve the item.
     *  @param prefetch An <code>int</code> indicating both the direction
     *    and number of items to fetch during the request if the item is not local.
     *  @throws RangeError if <code>index &lt; 0</code> or <code>index >= length</code>.
     *  @return The list item at the specified index.
     *  @see createPendingItemFunction
     *  @see createFailedItemFunction
     *  @see mx.collections.errors.ItemPendingError
     *  @see mx.rpc.IResponder 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function getItemAt(index:int, prefetch:int=0):Object
    {
        if (!list)
            return null;

        const pendingResponder:ListItemResponder = pendingResponders[index];
        if (pendingResponder)
            return pendingResponder.item;

        var item:Object = null;
        try
        {
            return list.getItemAt(index, prefetch);
        }
        catch (ipe:ItemPendingError)
        {
            const createPendingItem:Function = createPendingItemFunction;
            if (createPendingItem !== null)
                item = createPendingItem(index, ipe);
            var responder:ListItemResponder = new ListItemResponder(this, index, item);
            pendingResponders[index] = responder;
            ipe.addResponder(responder);
        }
        return item;
    }  
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function getItemIndex(item:Object):int
    {
        for each (var responder:ListItemResponder in pendingResponders)
            if (responder.item === item)
                return responder.index;
        return (list) ? list.getItemIndex(item) : -1;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function itemUpdated(item:Object, property:Object=null, oldValue:Object=null, newValue:Object=null):void
    {
        if (list)
            itemUpdated(item, property, oldValue, newValue);
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function removeAll():void
    {
        if (list)
            list.removeAll();
    }
    
    /**
     *  Removes the actual or pending item at the specified index and returns it.
     *  All items whose index is greater than the specified index are shifted 
     *  to the left.
     * 
     *  <p>If there isn't an actual or pending item at the specified index, for
     *  example because a call to getItemAt(index) hasn't caused the data to be 
     *  paged in, then the underlying <code>list</code> may throw an IPE.  The 
     *  implementation ignores the IPE and returns null.</p>
     *
     *  @param index The list index from which to retrieve the item.
     *  @throws RangeError if <code>index &lt; 0</code> or <code>index >= length</code>.
     *  @return The item that was removed or null.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function removeItemAt(index:int):Object
    {
        if (!list)
            return null;
        
        var item:Object = deletePendingResponder(index);
        try
        {
            return list.removeItemAt(index);
        }
        catch (ipe:ItemPendingError)
        {
            // If list[index] doesn't exist yet, an IPE will be thrown.  There's nothing 
            // we can do about that, so ignore it.
        }
        return item; 
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function setItemAt(item:Object, index:int):Object
    {
        if (!list)
            return null;
        
        const pendingResponder:ListItemResponder = pendingResponders[index];
        const setItemValue:Object = list.setItemAt(item, index);
        return (pendingResponder) ? pendingResponder.item : setItemValue;
    }
    
    /**
     *  Returns an array with the same elements as this AsyncListView.  The array is initialized
     *  by retrieving each item with getItemAt(), so pending items will be substituted where actual
     *  values aren't available yet.   The array will not be updated when the ASyncList replaces
     *  the pending items with actual (or failed) values.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function toArray():Array
    {
        if (!list)
            return [];
        
        const a:Array = new Array(list.length);
        for(var i:int = 0; i < a.length; i++)
            a[i] = getItemAt(i);
        return a;
    }
    
 
    /**
     *  Prints the contents of this view to a string and returns it.
     * 
     *  @return The contents of this view, in string form.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function toString():String
    {
        if (list && Object(list).toString)
            return Object(list).toString();
        else
            return getQualifiedClassName(this);
    }

}
}

import mx.rpc.IResponder;
import mx.collections.AsyncListView;
import mx.core.mx_internal;

use namespace mx_internal;  // for mx_internal functions pendingItemSucceeded,Failed()

class ListItemResponder implements IResponder
{
    private var asyncListView:AsyncListView;
    public var index:int = -1;
    public var item:Object = null;
    
    public function ListItemResponder(asyncListView:AsyncListView, index:int, item:Object)
    {
        super();
        this.asyncListView = asyncListView;
        this.index = index;
        this.item = item;
    }
    
    public function result(info:Object):void
    {
        if (index != -1)
            asyncListView.pendingRequestSucceeded(index, info);
    }
    
    public function fault(info:Object):void
    {
        if (index != -1)
            asyncListView.pendingRequestFailed(index, info);
    }
}