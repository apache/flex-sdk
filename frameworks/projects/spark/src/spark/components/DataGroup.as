package mx.components
{
import flash.display.DisplayObject;
import flash.events.Event;

import mx.collections.IList;
import mx.components.baseClasses.GroupBase;
import mx.core.IDataRenderer;
import mx.core.IFactory;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.ItemExistenceChangedEvent;
import mx.graphics.graphicsClasses.GraphicElement;
import mx.layout.ILayoutElement;
import mx.layout.LayoutElementFactory;
import mx.styles.IStyleClient;

/**
 *  Dispatched when an item is added to the content holder.
 *  event.
 *
 *  @eventType mx.events.ItemExistenceChangedEvent.ITEM_ADD
 */
[Event(name="itemAdd", type="mx.events.ItemExistenceChangedEvent")]

/**
 *  Dispatched when an item is removed from the content holder.
 *  event.
 *
 *  @eventType mx.events.ItemExistenceChangedEvent.ITEM_REMOVE
 */
[Event(name="itemRemove", type="mx.events.ItemExistenceChangedEvent")]

[DefaultProperty("dataProvider")] 

[IconFile("DataGroup.png")]

/**
 *  The DataGroup class is the base container class for data elements.
 *  The DataGroup class converts data elements to visual elements for display.
 *
 *  @see mx.components.Group
 *  @includeExample examples/DataGroupExample.mxml
 *
 */
public class DataGroup extends GroupBase 
{
    /**
     *  Constructor.
     */
    public function DataGroup()
    {
        super();
    }
    
    private var itemRendererRegistry:Array = [];
    
    //----------------------------------
    //  itemRenderer
    //----------------------------------

    /**
     *  @private
     *  Storage for the itemRenderer property.
     */
    private var _itemRenderer:IFactory;
    
    private var itemRendererChanged:Boolean;

    [Inspectable(category="Data")]

    /**
     *  Renderer to use for data items. The class must
     *  implement the IDataRenderer interface.
     *  If defined, the <code>itemRendererFunction</code> property
     *  takes precedence over this property.
     *
     *  @default null
     */
    public function get itemRenderer():IFactory
    {
        return _itemRenderer;
    }

    /**
     *  @private
     */
    public function set itemRenderer(value:IFactory):void
    {
        _itemRenderer = value;

        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
        
        itemRendererChanged = true;

        dispatchEvent(new Event("itemRendererChanged"));
    }
    
    //----------------------------------
    //  itemRendererFunction
    //----------------------------------

    /**
     *  @private
     *  Storage for the itemRendererFunction property.
     */
    private var _itemRendererFunction:Function;

    [Inspectable(category="Data")]

    /**
     *  Function that returns an item renderer for a specific item.
     *  The signature of the function is:
     *  
     *  <pre>
     *    function itemRendererFunction(item:Object):IFactory</pre>
     *
     *  @default null
     */
    public function get itemRendererFunction():Function
    {
        return _itemRendererFunction;
    }

    /**
     *  @private
     */
    public function set itemRendererFunction(value:Function):void
    {
        _itemRendererFunction = value;

        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
        
        itemRendererChanged = true;

        dispatchEvent(new Event("itemRendererChanged"));
    }
    
    private var _dataProvider:IList;
    private var dataProviderChanged:Boolean = false;
    
    [Bindable("dataProviderChanged")]
    /**
     *  DataProvider for this DataGroup.  It must be an IList.
     *
     *  @default undefined
     *
     *  @see #itemRenderer
     *  @see #itemRendererFunction
     */
    public function get dataProvider():IList
    {
        return _dataProvider;
    }
        
    /**
     *  @private
     */
    public function set dataProvider(value:IList):void
    {
        if (_dataProvider)
        {
            _dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler);
        }
        
        _dataProvider = value;
        
        // Need to convert null to undefined here, since subsequent content checks test for undefined
        if (_dataProvider === null)
            _dataProvider = undefined;
            
        if (_dataProvider is IList)
        {
            _dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler, false, 0, true);
        }
            
        dataProviderChanged = true;
        invalidateProperties();
    }
    
    /**
     *  Adds the elements fo the dataProvider to the DataGroup.
     */ 
    protected function initializeDataProvider():void
    {
        // Get rid of existing display object children.
        // !!!!! This should probably be done through change notification
        for (var idx:int = numChildren; idx > 0; idx--)
            super.removeChildAt(0);
        
        // TODO: get rid of this code
        // An item renderer who's rendering a graphic may not be used anymore and is
        // removed above.  However, the graphic item's display object is still 
        // attached to that item renderer.  We need to clear out these display objects.
        // For now, this is a cheap way to do it.
        // This might orphan the old display object in its previous container.
        if (dataProvider != null)
        {
            for (var j:int = 0; j < dataProvider.length; j++)
            {
                var item:GraphicElement = dataProvider.getItemAt(j) as GraphicElement;
                if (item)
                    item.displayObject = item.sharedDisplayObject = null;
            }
        }
        
        if (_dataProvider != null)
        {
            for (var i:int = 0; i < _dataProvider.length; i++)
            {
                itemAdded(_dataProvider.getItemAt(i), i);
            }
        }
    }
    
    /**
     *  Create the item renderer for the item, if needed.
     * 
     *  <p>The rules to create a visual item are:</p>
     *  <ol><li>if itemRendererFunction is defined, call 
     *  it to get the renderer factory and instantiate it</li>
     *  <li>if itemRenderer is defined, instantiate one</li>
     *  <li>if item is a GraphicElement, create the display 
     *  object for it</li>
     *  <li>if item is a DisplayObject, use it directly</li></ol>
     * 
     *  @param item The data element.
     *
     *  @return The renderer that represents the data elelement.
     */
    protected function createRendererForItem(item:Object, index:int):Object
    {
        var myItemRenderer:Object;
        
        if (item === null)
            throw new Error("DataGroup content can not contain null items.");
        
        // Rules for lookup:
        // 1. if itemRendererFunction is defined, call it to get the renderer factory and instantiate it
        // 2. if itemRenderer is defined, instantiate one
        // 3. if item is a GraphicElement, create the display object for it
        // 4. if item is a DisplayObject, use it directly
        
        // 1. if itemRendererFunction is defined, call it to get the renderer factory and instantiate it    
        if (itemRendererFunction != null)
        {
            var rendererFactory:IFactory = itemRendererFunction(item);
            
            if (rendererFactory)
                myItemRenderer = rendererFactory.newInstance();
        }
        
        // 2. if itemRenderer is defined, instantiate one
        if (!myItemRenderer && itemRenderer)
        {
            myItemRenderer = itemRenderer.newInstance();
        }
        
        // 3. if item is a GraphicElement, create the display object for it
        if (!myItemRenderer && item is GraphicElement)
        {
            var graphicItem:GraphicElement = GraphicElement(item);
            graphicItem.parent = this;
                            
            if (!graphicItem.displayObject)
                graphicItem.displayObject = graphicItem.createDisplayObject();
            
            myItemRenderer = graphicItem;
        }
        
        // 4. if item is a DisplayObject, use it directly
        if (!myItemRenderer && item is DisplayObject)
        {
            myItemRenderer = DisplayObject(item);
        }
        
        // Set the renderer's data to the item, but only if the item and renderer are different
        if (myItemRenderer is IDataRenderer && myItemRenderer != item)
            IDataRenderer(myItemRenderer).data = item;

        return myItemRenderer;
    }
    
    /**
     *  Called to associate an item with a particular renderer.
     *  This is called automatically when an item renderer is created.
     *
     *  @param index The item index to associate the renderer with
     *  @param myItemRenderer The item renderer
     */    
    protected function registerRenderer(index:int, myItemRenderer:Object):void
    {        
        itemRendererRegistry.splice(index, 0, myItemRenderer);
    }
    
    /**
     *  Called to dis-associate an item with a particular rendering display object.
     *  This will be called when virtualization support is added to datagroup.
     *
     *  @param index The item index to dis-associate the renderer with
     *  @param myItemRenderer The item renderer
     */
    protected function unregisterRenderer(index:int, myItemRenderer:Object):void
    {
        itemRendererRegistry.splice(index, 1);
    }
    
    /**
     *  @private
     */
    override protected function commitProperties():void
    { 
        if (dataProviderChanged || itemRendererChanged)
        {
            dataProviderChanged = false;
            itemRendererChanged = false;
            initializeDataProvider();
            
            mx_internal::maskChanged = true;
        }
        
        // Need to initializeDataProvider before calling super.commitProperties
        // initializeDataProvider removes all of the display list children.
        // GroupBase's commitProperties reattaches the mask
        super.commitProperties();

        // Check whether we manage the elements, or are they managed by an ItemRenderer
        // TODO EGeorgie: we need to optimize this, iterating through all the elements is slow.
        // Validate element properties
        var length:int = dataProvider ? dataProvider.length : 0;
        for (var i:int = 0; i < length; i++)
        {
            var element:GraphicElement = dataProvider.getItemAt(i) as GraphicElement;
            if (element)
                element.validateProperties();
        }
    }
    
    /**
     *  @private
     */
    override public function validateSize(recursive:Boolean = false):void
    {
        // Since GraphicElement is not ILayoutManagerClient, we need to make sure we
        // validate sizes of the elements, even in cases where recursive==false.
        
        // Check whether we manage the elements, or are they managed by an ItemRenderer
        // TODO EGeorgie: we need to optimize this, iterating through all the elements is slow.
        // Validate element size
        var length:int = dataProvider ? dataProvider.length : 0;
        for (var i:int = 0; i < length; i++)
        {
            var element:GraphicElement = dataProvider.getItemAt(i) as GraphicElement;
            if (element)
                element.validateSize();
        }

        super.validateSize(recursive);
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        // TODO EGeorgie: we need to optimize this, iterating through all the elements is slow.
        // Iterate through the graphic elements, clear their graphics and draw them
        var length:int = dataProvider ? dataProvider.length : 0;
        for (var i:int = 0; i < length; i++)
        {
            var element:GraphicElement = dataProvider.getItemAt(i) as GraphicElement;
            if (element)
                element.validateDisplayList();
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Layout item iteration
    //
    //  Iterators used by Layout objects. For visual items, the layout item
    //  is the item itself. For data items, the layout item is the item renderer
    //  instance that is associated with the item.
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override public function get numLayoutElements():int
    {
        return dataProvider ? dataProvider.length : 0;
    }
    
    /**
     *  @private
     */
    override public function getLayoutElementAt(index:int):ILayoutElement
    {
        var myItemRenderer:Object = getItemRenderer(index);

        return LayoutElementFactory.getLayoutElementFor(myItemRenderer);
    }
    
    /**
     *  Adds an item to this DataGroup.
     *  Flex calls this method automatically; you do not call it directly.
     *
     *  @param item The item that was added.
     *
     *  @param index The index where the item was added.
     */
    protected function itemAdded(item:Object, index:int):void
    {
        var childDO:DisplayObject;
        var myItemRenderer:Object;
                
        if (item is GraphicElement) 
        {
            var graphicItem:GraphicElement = GraphicElement(item);
        
            // If a styleable GraphicElement is being added,
            // build its protochain for use by getStyle().
            if (item is IStyleClient)
                IStyleClient(item).regenerateStyleCache(true);
                
            myItemRenderer = createRendererForItem(graphicItem, index);
        }   
        else
        {
            myItemRenderer = createRendererForItem(item, index);
        }
        
        registerRenderer(index, myItemRenderer);
        
        if (myItemRenderer is GraphicElement)
            childDO = GraphicElement(myItemRenderer).displayObject;
        else
            childDO = DisplayObject(myItemRenderer);
        
        addItemToDisplayList(childDO, item, index);
        
        dispatchEvent(new ItemExistenceChangedEvent(
                      ItemExistenceChangedEvent.ITEM_ADD, false, false, 
                      item, index, getItemRenderer(index)));
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    /**
     *  Removes an item from this DataGroup.
     *  Flex calls this method automatically; you do not call it directly.
     *
     *  @param item The item that is being removed.
     * 
     *  @param index The index of the item that is being removed.
     */
    protected function itemRemoved(item:Object, index:int):void
    {       
        var renderer:Object = getItemRenderer(index);
        var childDO:DisplayObject = item as DisplayObject;
        
        dispatchEvent(new ItemExistenceChangedEvent(
                      ItemExistenceChangedEvent.ITEM_REMOVE, false, false, 
                      item, index, renderer));
        
        // if either the item or the renderer is a GraphicElement,
        // release the display objects
        if (item && (item is GraphicElement))
        {
            item.parent = null;
            item.sharedDisplayObject = null;
        }
        
        // determine who the child display object is
        if (renderer && (renderer is GraphicElement))
        {
            childDO = GraphicElement(renderer).displayObject;
        }
        else if (renderer && (renderer is DisplayObject))
        {
            childDO = renderer as DisplayObject;
        }
        
        // If the item and renderer are different objects, set the renderer data to 
        // null here to clear it out. Otherwise, the renderer keeps a reference to the item,
        // which can cause problems later.
        if (item && renderer && item != renderer)
            renderer.data = null;
                
        if (childDO)
            super.removeChild(childDO);
        
        unregisterRenderer(index, renderer);
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    /**
     *  Removes an item from another DataGroup or display list
     *  before adding it to this display list.
     * 
     *  @param child DisplayObject to add to the display list.
     * 
     *  @param item Item associated with the display object to be added.  If 
     *  the item itself is a display object, it will be the same as the child parameter.
     * 
     *  @param index Index position where the display object will be added.
     * 
     *  @return DisplayObject that was added.
     */ 
    protected function addItemToDisplayList(child:DisplayObject, item:Object, index:int = -1):DisplayObject
    { 
        var host:DisplayObject;
        
        // TODO (rfrishbe): need to check for DisplayObject?
        if (item is IVisualElement)
            host = IVisualElement(item).parent; 
        else if (item is DisplayObject)
            host = DisplayObject(item).parent;
        
        // Remove the item from the group if that group isn't this group
        if (host && host is IVisualElementContainer && host != this)
            IVisualElementContainer(host).removeElement(item);
        else if (host && host is DataGroup && host != this)
        {
            var dp:IList = DataGroup(host).dataProvider;
            var index:int = dp.getItemIndex(item);
            dp.removeItemAt(index);
        }
        
        // Calling removeItem should have already removed the child. This
        // should handle the case when we don't call removeItem
        if (child.parent)
        {
            if (child.parent == this)
            {
                var insertIndex:int;
                if (index == -1)
                    insertIndex = super.numChildren - 1;
                else if (index == 0)
                    insertIndex = 0;
                else
                    insertIndex = index;
                    
                super.setChildIndex(child, insertIndex);
                return child;
            }
            else        
                child.parent.removeChild(child);
        
        }
            
        return super.addChildAt(child, index != -1 ? index : super.numChildren);
    }
    
    /**
     *  Called when contents within the dataProvider changes.  We will catch certain 
     *  events and update our children based on that.
     *
     *  @param event The collection change event
     */
    protected function collectionChangeHandler(event:CollectionEvent):void
    {
        switch (event.kind)
        {
            case CollectionEventKind.ADD:
            {
                // items are added
                // figure out what items were added and where
                // for virtualization also figure out if items are now in view
                adjustAfterAdd(event.items, event.location);
                break;
            }
        
            case CollectionEventKind.REPLACE:
            {
                // items are replaced
                adjustAfterReplace(event.items, event.location);
                break;
            }
        
            case CollectionEventKind.REMOVE:
            {
                // items are added
                // figure out what items were removed
                // for virtualization also figure out what items are now in view
                adjustAfterRemove(event.items, event.location);
                break;
            }
            
            case CollectionEventKind.MOVE:
            {
                // one item is moved
                adjustAfterMove(event.items[0], event.location, event.oldLocation);
                break;
            }
        
            case CollectionEventKind.REFRESH:
            {
                // from a filter or sort...let's just reset everything          
                dataProviderChanged = true;
                invalidateProperties();
                break;
            }
            
            case CollectionEventKind.RESET:
            {
                // reset everything          
                dataProviderChanged = true;
                invalidateProperties();
                break;
            }
            
            case CollectionEventKind.UPDATE:
            {
                // update event, do nothing
                // TODO: maybe we need to do something here, like recreate renderer?
                break;
            }
        }
    }
    
    /**
     *  @private
     */
    protected function adjustAfterAdd(items:Array, location:int):void
    {
        var length:int = items.length;
        for (var i:int = 0; i < length; i++)
        {
            itemAdded(items[i], location + i);
        }
    }
    
    /**
     *  @private
     */
    protected function adjustAfterRemove(items:Array, location:int):void
    {
        var length:int = items.length;
        for (var i:int = length-1; i >= 0; i--)
        {
            itemRemoved(items[i], location + i);
        }
    }
    
    /**
     *  @private
     */
    protected function adjustAfterMove(item:Object, location:int, oldLocation:int):void
    {
        itemRemoved(item, oldLocation);
        
        // if item is removed before the newly added item
        // then change index to account for this
        if (location > oldLocation)
            itemAdded(item, location-1);
        else
            itemAdded(item, location);
    }
    
    /**
     *  @private
     */
    protected function adjustAfterReplace(items:Array, location:int):void
    {
        // TODO (rfrishbe): we don't handle this case gracefully
        // The reason is so swapping items works like it did in Halo.
        // I can grab item1, item2, setItemAt(item1, item2index), and 
        // setItemAt(item2, item1index).  For a temporary bit, we are 
        // in a bad state, so to handle this, let's just redo everything.
        // see SDK-16956.
        dataProviderChanged = true;
        invalidateProperties();
        
        /*var length:int = items.length;
        for (var i:int = length-1; i >= 0; i--)
        {
            itemRemoved(items[i].oldValue, location + i);               
        }
        
        for (i = length-1; i >= 0; i--)
        {
            itemAdded(items[i].newValue, location);
        }*/
    }
    
    //--------------------------------------------------------------------------
    //
    //  Item -> Renderer mapping
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Returns the instance of the renderer at the specified index. If the item 
     *  at that index is a visual element and uses no renderer, then the visual  
     *  element will be returned.
     *
     *  @param index The item index whose renderer is to be returned.
     *
     *  @return The renderer instance for the specified item. If the item
     *          is a visual element and has no item renderer, 
     *          the visual element itself is returned.
     */
    public function getItemRenderer(index:int):Object
    {
        return itemRendererRegistry[index];
    }
    
    /**
     *  Returns the item index associated with the specified renderer.
     *
     *  @param renderer The renderer whose item you want to retrieve.
     *
     *  @return The item index associated with the specified renderer, 
     *          or -1 if there is no item associated with the passed in 
     *          renderer.
     */
    public function getRendererItem(renderer:Object):int
    {
        return itemRendererRegistry.indexOf(renderer);
    }
    
    /**
     *  @private
     */
    override public function addChild(child:DisplayObject):DisplayObject
    {
        throw(new Error("addChild is not available in DataGroup. " + 
                "Use methods defined on the dataProvider instead"));
    }
    
    /**
     *  @private
     */
    override public function addChildAt(child:DisplayObject, index:int):DisplayObject
    {
        throw(new Error("addChildAt is not available in DataGroup. " + 
                "Use methods defined on the dataProvider instead"));
    }
    
    /**
     *  @private
     */
    override public function removeChild(child:DisplayObject):DisplayObject
    {
        throw(new Error("removeChild is not available in DataGroup. " + 
                "Use methods defined on the dataProvider instead"));
    }
    
    /**
     *  @private
     */
    override public function removeChildAt(index:int):DisplayObject
    {
        throw(new Error("removeChildAt is not available in DataGroup. " + 
                "Use methods defined on the dataProvider instead"));
    }
    
    /**
     *  @private
     */
    override public function setChildIndex(child:DisplayObject, index:int):void
    {
        throw(new Error("setChildIndex is not available in DataGroup. " + 
                "Use methods defined on the dataProvider instead"));
    }
    
    /**
     *  @private
     */
    override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void
    {
        throw(new Error("swapChildren is not available in DataGroup. " + 
                "Use methods defined on the dataProvider instead"));
    }
    
    /**
     *  @private
     */
    override public function swapChildrenAt(index1:int, index2:int):void
    {
        throw(new Error("swapChildrenAt is not available in DataGroup. " + 
                "Use methods defined on the dataProvider instead"));
    }
}
}