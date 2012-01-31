package mx.components
{
import flash.display.DisplayObject;

import mx.collections.IList;
import mx.components.baseClasses.GroupBase;
import mx.core.IDataRenderer;
import mx.core.IFactory;
import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.core.IInvalidating;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.ItemExistenceChangedEvent;
import mx.core.ILayoutElement;
import mx.layout.LayoutBase;
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
    
    /**
     *  @private
     *  flag to indicate whether a child in the item renderer has a non-zero layer, requiring child re-ordering.
     */
    private var _layeringFlags:uint = 0;
    
    private static const LAYERING_ENABLED:uint =    0x1;
    private static const LAYERING_DIRTY:uint =      0x2;
    
    private var itemRendererRegistry:Array = [];
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  typicalItem
    //----------------------------------

    private var _typicalItem:Object = null;
    private var typicalItemChanged:Boolean = false;
    private var typicalLayoutElement:ILayoutElement = null;

    /**
     *  Layouts use the preferred size of the corresponding ILayoutElement 
     *  when fixed row/column sizes are requested but a specific 
     *  rowHeight or columnWidth isn't provided.
     * 
     *  Similarly virtual layouts use this item to define the size 
     *  of layout elements that have not been scrolled into view.
     *
     *  Setting this property sets the typicalLayoutElement property
     *  of the layout.
     * 
     *  @default null
     */
    public function get typicalItem():Object
    {
        return _typicalItem;
    }

    /**
     *  @private
     */
    public function set typicalItem(value:Object):void
    {
        if (_typicalItem == value)
            return;
        _typicalItem = value;
        typicalItemChanged = true;
        invalidateProperties();
    }
    
    private function initializeTypicalItem():void
    {
        var itemRenderer:DisplayObject = DisplayObject(createRendererForItem(_typicalItem));     
        super.addChild(itemRenderer)            
        if (itemRenderer is IInvalidating)
            IInvalidating(itemRenderer).validateNow();
        typicalLayoutElement = LayoutElementFactory.getLayoutElementFor(itemRenderer);
        if (layout)
            layout.typicalLayoutElement = typicalLayoutElement;    
        super.removeChild(itemRenderer);
    }    

    //----------------------------------
    //  layout
    //----------------------------------

    /**
     *  @private
     *  Sync the typicalLayoutElement var with this group's layout.
     */    
    override public function set layout(value:LayoutBase):void
    {
        var oldLayout:LayoutBase = layout;
        if (value == oldLayout)
            return; 

        super.layout = value;    
        if (oldLayout)
            oldLayout.typicalLayoutElement = null;
        if (value)
            value.typicalLayoutElement = typicalLayoutElement;
    } 
    
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
    }
    
    private var _dataProvider:IList;
    private var dataProviderChanged:Boolean = false;
    
    [Bindable("dataProviderChanged")]
    /**
     *  DataProvider for this DataGroup.  It must be an IList.
     * 
     *  <p>There are several IList implementations included in the 
     *  Flex framework, including ArrayCollection, ArrayList, and
     *  XMLListCollection.</p>
     *
     *  @default null
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
            _dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, dataProvider_collectionChangeHandler);
        
        _dataProvider = value;
        
        if (_dataProvider)
            _dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, dataProvider_collectionChangeHandler, false, 0, true);
            
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
        
        if (_dataProvider && (!layout || !layout.virtualLayout))
        {
            for (var i:int = 0; i < _dataProvider.length; i++)
            {
                mx_internal::itemAdded(_dataProvider.getItemAt(i), i);
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Item -> Renderer mapping
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Create the item renderer for the item, if needed.
     * 
     *  <p>The rules to create a visual item are:</p>
     *  <ol><li>if itemRendererFunction is defined, call 
     *  it to get the renderer factory and instantiate it</li>
     *  <li>if itemRenderer is defined, instantiate one</li>
     *  <li>if item is an IVisualElement and a DisplayObject, use 
     *  it directly</li></ol>
     * 
     *  @param item The data element.
     *
     *  @return The renderer that represents the data elelement.
     */
    private function createRendererForItem(item:Object):IVisualElement
    {
        var myItemRenderer:IVisualElement;
        
        // Rules for lookup:
        // 1. if itemRendererFunction is defined, call it to get the renderer factory and instantiate it
        // 2. if itemRenderer is defined, instantiate one
        // 3. if item is an IVisualElement and a DisplayObject, use it directly
        
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
        
        // 3. if item is an IVisualElement and a DisplayObject, use it directly
        if (!myItemRenderer && item is IVisualElement && item is DisplayObject)
        {
            myItemRenderer = IVisualElement(item);
        }

        // Set the renderer's data to the item, but only if the item and renderer are different
        if ((myItemRenderer is IDataRenderer) && (myItemRenderer != item))
            IDataRenderer(myItemRenderer).data = item;   
                    
        // Couldn't find item renderer.  Throw an RTE.
        if (!myItemRenderer)
        {
            if (item is IVisualElement || item is DisplayObject)
                throw new Error("DataGroup cannot display visual elements directly unless the elements " + 
                        "are display objects and implement IVisualElement");
            else
                throw new Error("Could not create an item renderer for " + item);
        }

        return myItemRenderer;
    }
    
    /**
     *  Called to associate an item with a particular renderer.
     *  This is called automatically when an item renderer is created.
     *
     *  @param index The item index to associate the renderer with
     *  @param myItemRenderer The item renderer
     */    
    private function registerRenderer(index:int, myItemRenderer:IVisualElement):void
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
    private function unregisterRenderer(index:int, myItemRenderer:IVisualElement):void
    {
        itemRendererRegistry.splice(index, 1);
    }
    
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
    mx_internal function getRendererForItemAt(index:int):IVisualElement
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
    mx_internal function getItemIndexForRenderer(renderer:IVisualElement):int
    {
        return itemRendererRegistry.indexOf(renderer);
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

        if(_layeringFlags & LAYERING_DIRTY)
        {
        	manageDisplayObjectLayers();
        }
        
        if (typicalItemChanged)
        {
            typicalItemChanged = false;
            initializeTypicalItem();
        }        
    }
    
    private function manageDisplayObjectLayers():void
    {
        // itemRenderers should be both DisplayObjects and IVisualElements
        var topLayerItems:Vector.<IVisualElement>;
        var bottomLayerItems:Vector.<IVisualElement>;        
        var keepLayeringEnabled:Boolean = false;
        
        var insertIndex:uint = 0;

		_layeringFlags &= ~LAYERING_DIRTY;
		
        // Iterate through all of the items
        var len:int = itemRendererRegistry.length; 
        
        for (var i:int = 0; i < len; i++)
        {  
            var myItemRenderer:IVisualElement = itemRendererRegistry[i];
            
            var layer:Number = myItemRenderer.layer;
            
            if (layer != 0)
            {               
                if (layer > 0)
                {
                    if (topLayerItems == null) topLayerItems = new Vector.<IVisualElement>();
                    topLayerItems.push(myItemRenderer);
                    continue;                   
                }
                else
                {
                    if (bottomLayerItems == null) bottomLayerItems = new Vector.<IVisualElement>();
                    bottomLayerItems.push(myItemRenderer);
                    continue;                   
                }
            }
            
            super.setChildIndex(myItemRenderer as DisplayObject, insertIndex++);
        }
        
        if (topLayerItems != null)
        {
            keepLayeringEnabled = true;
            GroupBase.mx_internal::sortOnLayer(topLayerItems);
            len = topLayerItems.length;
            for (i=0;i<len;i++)
            {
            	myItemRenderer = topLayerItems[i];
	            super.setChildIndex(myItemRenderer as DisplayObject, insertIndex++);
            }
        }
        
        if (bottomLayerItems != null)
        {
            keepLayeringEnabled = true;
            insertIndex=0;

            GroupBase.mx_internal::sortOnLayer(bottomLayerItems);
            len = bottomLayerItems.length;

            for (i=0;i<len;i++)
            {
            	myItemRenderer = bottomLayerItems[i];
	            super.setChildIndex(myItemRenderer as DisplayObject, insertIndex++);
            }
        }
        
        if (keepLayeringEnabled == false)
        {
            _layeringFlags &= ~LAYERING_ENABLED;
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

    private var virtualLayoutOffset:int = 0;
    private var virtualLayoutUnderway:Boolean = false;
     
    /**
     *  @private
     *  Update virtualLayoutOffset and clear the virtualLayoutUnderway flag.
     */
    override public function beginVirtualLayout(startIndex:int):void
    {
        virtualLayoutOffset = startIndex;
        virtualLayoutUnderway = true;
    }
    
    /**
     *  @private
     *  Discard the ItemRenderers that aren't needed anymore, i.e. the ones
     *  outside the logical range startIndex to endIndex.
     * 
     *  Clear the virtualLayoutUnderway flag.
     */
    override public function endVirtualLayout(startIndex:int, endIndex:int):void
    {
        // At this point, insertion of new IRs has pushed all of the unneeded IRs
        // past endIndex-startIndex.  Remove them without invalidating this DataGroup's
        // size or display list.
        for(var i:int = super.numChildren - 1; i > (endIndex - startIndex); i--)
        {
            var itemRenderer:DisplayObject = super.getChildAt(i);
            unregisterRenderer(i, IVisualElement(itemRenderer));
            super.removeChildAt(i);
        }        
        virtualLayoutUnderway = false;
    }
    
    /**
     *  @private
     */
    override public function invalidateSize():void
    {
        if (!virtualLayoutUnderway)
            super.invalidateSize();
    }
    
    /**
     *  @private
     */
    override public function getLayoutElementAt(index:int):ILayoutElement
    {
        var itemRendererIndex:int = index - virtualLayoutOffset;
        var itemRenderer:Object = mx_internal::getRendererForItemAt(itemRendererIndex);

        if (layout && layout.virtualLayout)
        {
            // Note: the code below does most of the same work as itemAdded()
            var item:Object = dataProvider.getItemAt(index);
            var createdIR:Boolean = false;
            
            if (!itemRenderer)
            {
                itemRenderer = createRendererForItem(item);
                createdIR = true;
            }

            if (itemRenderer.parent != this)
                addItemRendererToDisplayList(DisplayObject(itemRenderer), itemRendererIndex);
            else
                super.setChildIndex(DisplayObject(itemRenderer), itemRendererIndex);
            
            if (createdIR)
            {
                if (itemRenderer is IInvalidating)
                    IInvalidating(itemRenderer).validateNow();
                // TBD sync with itemAdded
                dispatchEvent(new ItemExistenceChangedEvent(ItemExistenceChangedEvent.ITEM_ADD, false, false, item));
            }
        }

        return LayoutElementFactory.getLayoutElementFor(itemRenderer);
    }

    /**
     *  @private
     */
    override public function invalidateLayering():void
    {
    	_layeringFlags |= (LAYERING_ENABLED | LAYERING_DIRTY);
        invalidateProperties();
    }

    /**
     *  Adds an item to this DataGroup.
     *  Flex calls this method automatically; you do not call it directly.
     *
     *  @param item The item that was added.
     *
     *  @param index The index where the item was added.
     */
    mx_internal function itemAdded(item:Object, index:int):void
    {
        var myItemRenderer:IVisualElement = createRendererForItem(item);

        registerRenderer(index, myItemRenderer);
        
        addItemRendererToDisplayList(myItemRenderer as DisplayObject, index);
        // TBD: sync with virtualization code in getLayoutElementAt
        dispatchEvent(new ItemExistenceChangedEvent(
                      ItemExistenceChangedEvent.ITEM_ADD, false, false, 
                      item, index, myItemRenderer));
        
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
    mx_internal function itemRemoved(item:Object, index:int):void
    {       
        var myItemRenderer:IVisualElement = mx_internal::getRendererForItemAt(index);
        
        dispatchEvent(new ItemExistenceChangedEvent(
                      ItemExistenceChangedEvent.ITEM_REMOVE, false, false, 
                      item, index, myItemRenderer));
        
        // If the item and renderer are different objects, set the renderer data to 
        // null here to clear it out. Otherwise, the renderer keeps a reference to the item,
        // which can cause problems later.
        if (myItemRenderer is IDataRenderer && myItemRenderer != item)
            IDataRenderer(myItemRenderer).data = null;
        
        super.removeChild(myItemRenderer as DisplayObject);
        
        unregisterRenderer(index, myItemRenderer);
        
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
    protected function addItemRendererToDisplayList(child:DisplayObject, index:int = -1):DisplayObject
    { 
        // TODO: do we need this case (parented by me previously)?
        if (child.parent && child.parent == this)
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
        else if (child.parent && child.parent is DataGroup)
        {
            DataGroup(child.parent)._removeChild(child);
        }

        if ((_layeringFlags & LAYERING_ENABLED) || 
        	(child is IVisualElement && (child as IVisualElement).layer != 0))
        	invalidateLayering();
            
        return super.addChildAt(child, index != -1 ? index : super.numChildren);
    }
    
    /**
     *  Called when contents within the dataProvider changes.  We will catch certain 
     *  events and update our children based on that.
     *
     *  @param event The collection change event
     */
    protected function dataProvider_collectionChangeHandler(event:CollectionEvent):void
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
            mx_internal::itemAdded(items[i], location + i);
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
            mx_internal::itemRemoved(items[i], location + i);
        }
    }
    
    /**
     *  @private
     */
    protected function adjustAfterMove(item:Object, location:int, oldLocation:int):void
    {
        mx_internal::itemRemoved(item, oldLocation);
        
        // if item is removed before the newly added item
        // then change index to account for this
        if (location > oldLocation)
            mx_internal::itemAdded(item, location-1);
        else
            mx_internal::itemAdded(item, location);
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
    //  Methods: Access to overridden methods of base classes
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  This method allows access to the base class's implementation
     *  of removeChild() (UIComponent's version), which can be useful since components
     *  can override removeChild() and thereby hide the native implementation.  For 
     *  instance, we override removeChild() here to throw an RTE to discourage people
     *  from using this method.  We need this method so we can remove children
     *  that were previously attached to another DataGroup (see addItemToDisplayList).
     */
    private function _removeChild(child:DisplayObject):DisplayObject
    {
        return super.removeChild(child);
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
