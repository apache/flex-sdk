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
public class RemoteListView extends OnDemandEventDispatcher implements IList
{
    /**
     *  RemoteListView constructor.
     *
     *  @param list Initial value of the list property, the IList we're delegating to.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function RemoteListView(list:IList = null)
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

        pendingItems.length = 0;

        if (_list)
            _list.removeEventListener(CollectionEvent.COLLECTION_CHANGE, dispatchEvent);
        
        _list = value;

        if (_list)
            _list.addEventListener(CollectionEvent.COLLECTION_CHANGE, dispatchEvent);

        dispatchEvent(new Event("listChanged"));
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
     *  </p>
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

    private const pendingItems:Array = new Array();
    
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
        delete pendingItems[index];  
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
        delete pendingItems[index];
        // TBD if the dataProvider has changed or if it's null, then ignore this item
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
     *  <code>createFailedItemFunction</code>.
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

        var pendingItem:* = pendingItems[index];
        if (pendingItem !== undefined)
            return pendingItem;

        var item:Object = null;
        try
        {
            return list.getItemAt(index);
        }
        catch (ipe:ItemPendingError)
        {
            var createPendingItem:Function = createPendingItemFunction;
            if (createPendingItem !== null)
                item = createPendingItem(index, ipe);
            ipe.addResponder(new ListItemResponder(this, index));
        }
        pendingItems[index] = item;
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
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	public function removeItemAt(index:int):Object
	{
        return (list) ? list.removeItemAt(index) : null;
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
        return (list) ? list.setItemAt(item, index) : null;
	}
	
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	public function toArray():Array
	{
        return (list) ? list.toArray() : [];
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
import mx.collections.RemoteListView;
import mx.core.mx_internal;

use namespace mx_internal;  // for mx_internal functions pendingItemSucceeded,Failed()

class ListItemResponder implements IResponder
{
    private var remoteListView:RemoteListView;
    public var index:int = -1;
    
    public function ListItemResponder(remoteListView:RemoteListView, index:int)
    {
        super();
        this.remoteListView = remoteListView;
        this.index = index;
    }
    
    public function result(info:Object):void
    {
        remoteListView.pendingRequestSucceeded(index, info);
    }
    
    public function fault(info:Object):void
    {
        remoteListView.pendingRequestFailed(index, info);
    }
}
