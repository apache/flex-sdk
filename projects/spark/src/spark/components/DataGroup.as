package mx.components
{
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import mx.events.FlexEvent;
import mx.events.ItemExistenceChangedEvent;
import mx.graphics.Graphic;
import mx.graphics.IGraphicElement;
import mx.graphics.IGraphicElementHost;
import mx.graphics.MaskType;
import mx.utils.MatrixUtil;
import mx.graphics.graphicsClasses.GraphicElement;
import mx.layout.ILayoutItem;
import mx.layout.BasicLayout;
import mx.layout.LayoutItemFactory;

import mx.collections.ICollectionView;
import mx.collections.IList;
import mx.components.baseClasses.GroupBase;
import mx.controls.Label;
import mx.core.IDataRenderer;
import mx.core.IDeferredInstance;
import mx.core.IFactory;
import mx.core.UIComponent;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind
import mx.events.PropertyChangeEvent;
import mx.events.PropertyChangeEventKind;
import mx.styles.IStyleClient;

/**
 *  Dispatched when an item is added to the content holder.
 *  event.relatedObject is the visual item that was added.
 */
[Event(name="itemAdd", type="flex.events.ItemExistenceChangedEvent")]

/**
 *  Dispatched when an item is removed from the content holder.
 *  event.relatedObject is the visual item that was removed.
 */
[Event(name="itemRemove", type="flex.events.ItemExistenceChangedEvent")]

[DefaultProperty("dataProvider")] 
/**
 *  Documentation is not currently available. .
 */
public class DataGroup extends GroupBase 
{
    public function DataGroup()
    {
        super();
    }
    
    private var skinRegistry:Dictionary;
    
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
     *  The itemRendererFunction property,
     *  if defined, takes precedence over this property.
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
     *  function itemRendererFunction(item:Object):IFactory
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
     *  Internal DataGroup method used to grab the elements in the dataProvider
     *  and add them to the DataGroup.
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
        
        /* if (maskElements)
        {
            for (var k:Object in maskElements)
            {
                var maskElement:DisplayObject = k as DisplayObject;
                if (maskElement && (!maskElement.parent || maskElement.parent !== this))
                {
                    super.addChild(maskElement);
                    var maskComp:UIComponent = maskElement as UIComponent;
                    if (maskComp)
                    {
                        maskComp.validateNow();
                        maskComp.setActualSize(maskComp.getExplicitOrMeasuredWidth(), 
                                               maskComp.getExplicitOrMeasuredHeight());
                    }
                    
                    var maskTarget:IGraphicElement = maskElements[k] as IGraphicElement;
                    if (maskTarget)
                    {
                        maskTarget.applyMask();
                    }
                }
            }
        } */
    }
    
    /**
     *  Create the visual representation for the item, if needed.
     * 
     *  <p>The rules to create a visual item are:</p>
     *  <ol><li>if itemRendererFunction is defined, call 
     *  it to get the renderer factory and instantiate it</li>
     *  <li>if itemRenderer is defined, instantiate one</li>
     *  <li>if item is a GraphicElement, create the display 
     *  object for it</li>
     *  <li>if item is a DisplayObject, use it directly</li></ol>
     * 
     */
    protected function createVisualForItem(item:Object):DisplayObject
    {
        var itemSkin:Object;
        var itemDisplayObject:DisplayObject;
        
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
                itemSkin = itemDisplayObject = rendererFactory.newInstance();
        }
        
        // 2. if itemRenderer is defined, instantiate one
        if (!itemSkin && itemRenderer)
        {
            itemSkin = itemDisplayObject = itemRenderer.newInstance();
        }
        
        // 3. if item is a GraphicElement, create the display object for it
        if (!itemSkin && item is GraphicElement)
        {
            var graphicItem:GraphicElement = GraphicElement(item);
            graphicItem.elementHost = this;
                            
            if (!graphicItem.displayObject)
                graphicItem.displayObject = graphicItem.createDisplayObject();
                
            itemDisplayObject = graphicItem.displayObject;
            itemSkin = graphicItem;
        }
        
        // 4. if item is a DisplayObject, use it directly
        if (!itemSkin && item is DisplayObject)
        {
            itemSkin = itemDisplayObject = DisplayObject(item);
        }
        
        // Set the skin data to the item, but only if the item and skin are different
        if (itemSkin is IDataRenderer && itemSkin != item)
            IDataRenderer(itemSkin).data = item;
    
        registerSkin(item, itemSkin);

        return itemDisplayObject;
    }
    
    /**
     *  Documentation is not currently available. 
     */
    protected function registerSkin(item:*, itemSkin:Object):void
    {
        if (!skinRegistry)
            skinRegistry = new Dictionary(true);
        
        skinRegistry[item] = itemSkin;
    }
    
    /**
     *  Documentation is not currently available. 
     */
    protected function unregisterSkin(item:*, itemSkin:DisplayObject):void
    {
        if (!skinRegistry)
            return;
        
        delete skinRegistry[item];
    }
    
    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (dataProviderChanged || itemRendererChanged)
        {
            dataProviderChanged = false;
            itemRendererChanged = false;
            initializeDataProvider();
            
            // maskChanged = true; TODO (rfrishbe): need this maskChanged?
        }

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
    override public function get numLayoutItems():int
    {
        return dataProvider ? dataProvider.length : 0;
    }
    
    /**
     *  @private
     */
    override public function getLayoutItemAt(index:int):ILayoutItem
    {
        var item:* = dataProvider.getItemAt(index);

        var itemSkin:Object = getItemSkin(item);

        return LayoutItemFactory.getLayoutItemFor(itemSkin);
    }
    
    /**
     *  Internal DataGroup method called to add an item to this DataGroup.
     *
     *  @param item The item that was added.
     *  @param index The index where the item was added.
     */
    protected function itemAdded(item:Object, index:int):void
    {
        var childDO:DisplayObject;
                
        if (item is GraphicElement) 
        {
            var graphicItem:GraphicElement = GraphicElement(item);
        
            // If a styleable GraphicElement is being added,
            // build its protochain for use by getStyle().
            if (item is IStyleClient)
                IStyleClient(item).regenerateStyleCache(true);
                
            childDO = createVisualForItem(graphicItem);
        }   
        else
        {
            childDO = createVisualForItem(item);
        }
        
        addItemToDisplayList(childDO, item, index);
        
        dispatchEvent(new ItemExistenceChangedEvent(
                      ItemExistenceChangedEvent.ITEM_ADD, false, false, item));
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    /**
     *  Internal DataGroup method called to remove an item from this DataGroup.
     *
     *  @param item The item that is being removed.
     *  @param index The index of the item that is being removed.
     */
    protected function itemRemoved(item:Object, index:int):void
    {       
        var skin:* = getItemSkin(item);
        var childDO:DisplayObject = item as DisplayObject;
        
        dispatchEvent(new ItemExistenceChangedEvent(
                      ItemExistenceChangedEvent.ITEM_REMOVE, false, false, item));        
        
        // if either the item or the skin is a GraphicElement,
        // release the display objects
        if (item && (item is GraphicElement))
        {
            item.elementHost = null;
            item.sharedDisplayObject = null;
        }
        
        // determine who the child display object is
        if (skin && (skin is GraphicElement))
        {
            childDO = GraphicElement(skin).displayObject;
        }
        else if (skin && (skin is DisplayObject))
        {
            childDO = skin as DisplayObject;
        }
        
        // If the item and skin are different objects, set the skin data to 
        // null here to clear it out. Otherwise, the skin keeps a reference to the item,
        // which can cause problems later.
        if (item && skin && item != skin)
            skin.data = null;
                
        if (childDO)
            super.removeChild(childDO);
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    /**
     *  Internal helper method to remove item from another datagroup or display list
     *  before adding it to this display list.
     * 
     *  @param child DisplayObject to add to the display list
     *  @param item Item associated with the display object to be added.  If 
     *  the item itself is a display object, it will be the same as the child parameter.
     *  @param index Index position where the display object will be added
     * 
     *  @return DisplayObject that was added
     */ 
    protected function addItemToDisplayList(child:DisplayObject, item:*, index:int = -1):DisplayObject
    { 
        var host:DisplayObject;
        
        if (item is GraphicElement)
            host = DisplayObject(GraphicElement(item).elementHost); 
        else if (item is DisplayObject)
            host = DisplayObject(item).parent;
        
        // Remove the item from the group if that group isn't this group
        if (host && host is Group && host != this)
            Group(host).removeItem(item);
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
     *  Collection change handler for the dataProvider.
     */ 
    protected function collectionChangeHandler(event:Event):void
    {
        if (event is CollectionEvent)
        {
            var ce:CollectionEvent = CollectionEvent(event);

            switch (ce.kind)
            {
                case CollectionEventKind.ADD:
                {
                    // items are added
                    // figure out what items were added and where
                    // for virtualization also figure out if items are now in view
                    adjustAfterAdd(ce.items, ce.location);
                    break;
                }
            
                case CollectionEventKind.REPLACE:
                {
                    // items are replaced
                    adjustAfterReplace(ce.items, ce.location);
                    break;
                }
            
                case CollectionEventKind.REMOVE:
                {
                    // items are added
                    // figure out what items were removed
                    // for virtualization also figure out what items are now in view
                    adjustAfterRemove(ce.items, ce.location);
                    break;
                }
                
                case ce.kind == CollectionEventKind.MOVE:
                {
                    // one item is moved
                    adjustAfterMove(ce.items[0], ce.location, ce.oldLocation);
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
        var length:int = items.length;
        for (var i:int = length-1; i >= 0; i--)
        {
            itemRemoved(items[i].oldValue, location + i);
        }
        
        for (var k:int = length-1; k >= 0; k--)
        {
            itemAdded(items[k].newValue, location);
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Item -> Renderer mapping
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Documentation is not currently available. 
     */
    public function getItemSkin(item:*):Object
    {
        var result:Object = null;
                    
        if (skinRegistry)
            result = skinRegistry[item];
        
        if (!result && item is DisplayObject)
            result = item;
                
        return result;
    }
    
    /**
     *  Documentation is not currently available. 
     */
    public function getSkinItem(skin:Object):*
    {
        // !! This implementation is really slow... 
        var item:*;
        
        for (var i:int = 0; i < dataProvider.length; i++)
        {
            item = dataProvider.getItemAt(i);
            if (getItemSkin(item) == skin)
                return item;
        }
        
        return null;
    }
    
    protected var maskElements:Dictionary;
    
    /**
     *  @private
     */
    override public function addMaskElement(mask:DisplayObject, target:IGraphicElement):void
    {
        if (!maskElements)
            maskElements = new Dictionary();
            
        maskElements[mask] = target;
        dataProviderChanged = true;
        // TODO!! Remove this once GraphicElements use the LayoutManager. Currently the
        // callLater is necessary because addMaskElement gets called inside of commitProperties
        callLater(invalidateProperties); 
            
    }
    
    /**
     *  @private
     */
    override public function removeMaskElement(mask:DisplayObject, target:IGraphicElement):void
    {
        if (maskElements && mask in maskElements)
        {
            delete maskElements[mask];
            dataProviderChanged = true;
             // TODO!! Remove this once GraphicElements use the LayoutManager. Currently the
            // callLater is necessary because removeMaskElement gets called inside of commitProperties
            callLater(invalidateProperties);
        }
    }
    
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