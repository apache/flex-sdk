package flex.core
{
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.geom.Transform;
import flash.utils.Dictionary;

import flex.events.FlexEvent;
import flex.events.ItemExistenceChangedEvent;
import flex.geom.Transform;
import flex.graphics.Graphic;
import flex.graphics.IGraphicElement;
import flex.graphics.IGraphicElementHost;
import flex.graphics.MaskType;
import flex.graphics.TransformUtil;
import flex.graphics.graphicsClasses.GraphicElement;
import flex.intf.ILayoutItem;
import flex.layout.BasicLayout;
import flex.layout.LayoutItemFactory;

import mx.collections.ICollectionView;
import mx.collections.IList;
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
 *  Dispatched prior to the dataProvider being changed.
 */
[Event(name="dataProviderChanging", type="flex.events.FlexEvent")]

/**
 *  Dispatched after the dataProvider has changed.
 */
[Event(name="dataProviderChanged", type="flex.events.FlexEvent")]

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
    
    protected function initializeDataProvider():void
    {   
        dispatchEvent(new FlexEvent(FlexEvent.DATA_PROVIDER_CHANGING));  
          
        // Get rid of existing display object children.
        // !!!!! This should probably be done through change notification
        for (var idx:int = numChildren; idx > 0; idx--)
            super.removeChildAt(0);
        
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
        
        dispatchEvent(new FlexEvent(FlexEvent.DATA_PROVIDER_CHANGED)); 
    }
    
    protected function createVisualForItem(item:Object):DisplayObject
    {
        var itemSkin:Object;
        var itemDisplayObject:DisplayObject;
        
        if (item === null)
            throw new Error("DataGroup content can not contain null items.");
            
        // Rules for skin lookup:
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
    
    protected function registerSkin(item:*, itemSkin:Object):void
    {
        if (!skinRegistry)
            skinRegistry = new Dictionary(true);
        
        skinRegistry[item] = itemSkin;
    }
    
    protected function unregisterSkin(item:*, itemSkin:DisplayObject):void
    {
        if (!skinRegistry)
            return;
        
        delete skinRegistry[item];
    }
    
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (dataProviderChanged)
        {
            dataProviderChanged = false;
            initializeDataProvider();
            
            // maskChanged = true; TODO (rfrishbe): need this maskChanged?
        }
        
        if (itemRendererChanged)
        {
            itemRendererChanged = false;
            initializeDataProvider();
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
     *  The number of layout items in this Group. Typically this is the same
     *  as the number of items in the Group.
     */
    override public function get numLayoutItems():int
    {
        return dataProvider ? dataProvider.length : 0;
    }
    
    /**
     *  Gets the <i>n</i>th layout item in the Group. For visual items, the 
     *  layout item is the item itself. For data items, the layout item is the 
     *  item renderer instance that is associated with the item.
     *
     *  @param index The index of the item to retrieve.
     *
     *  @return The layout item at the specified index.
     */
    override public function getLayoutItemAt(index:int):ILayoutItem
    {
        var item:* = dataProvider.getItemAt(index);

        var itemSkin:Object = getItemSkin(item);

        return LayoutItemFactory.getLayoutItemFor(itemSkin);
    }
    
    protected function itemAdded(item:Object, index:int):void
    {
        var childDO:DisplayObject;
                
        if (item is GraphicElement) 
        {
            var graphicItem:GraphicElement = GraphicElement(item);
            graphicItem.elementHost = this;
        
            // If a styleable GraphicElement is being added,
            // build its protochain for use by getStyle().
            if (item is IStyleClient)
                IStyleClient(item).regenerateStyleCache(true);
                
            childDO = createVisualForItem(graphicItem);
        }   
        else
        {     
            // This always adds the child to the end of the display list. Any 
            // ordering discrepancies will be fixed up in assignDisplayObjects().
            childDO = createVisualForItem(item);
        }
        
        addItemToDisplayList(childDO, item);
        
        dispatchEvent(new ItemExistenceChangedEvent(
                      ItemExistenceChangedEvent.ITEM_ADD, false, false, item));
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    protected function itemRemoved(index:int):void
    {       
        var item:* = _dataProvider.getItemAt(index);
        var skin:* = getItemSkin(item);
        var childDO:DisplayObject = item as DisplayObject;
        
        dispatchEvent(new ItemExistenceChangedEvent(
                      ItemExistenceChangedEvent.ITEM_REMOVE, false, false, item));        
        if (item && (item is GraphicElement))
        {
            item.elementHost = null;
            item.sharedDisplayObject = null;
            childDO = GraphicElement(item).displayObject;
        } 
        else if (skin && skin is DisplayObject)
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
    
    // Helper function to remove child from other Group or display list before 
    // adding to the display list. 
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
    
    protected function collectionChangeHandler(event:Event):void
    {
        if (event is CollectionEvent)
        {
            var ce:CollectionEvent = CollectionEvent(event);

            if (ce.kind == CollectionEventKind.ADD)
            {
                
            }
            else if (ce.kind == CollectionEventKind.REPLACE)
            {
                
            }
            else if (ce.kind == CollectionEventKind.REMOVE)
            {
                
            }
            else if (ce.kind == CollectionEventKind.MOVE)
            {
                
            }
            else if (ce.kind == CollectionEventKind.REFRESH)
            {
                
            }
            else if (ce.kind == CollectionEventKind.RESET)
            {
            }
            else if (ce.kind == CollectionEventKind.UPDATE)
            {
                return;
            }
            
            // TODO!! Fow now, always reapply the content. This needs to
            // be optimized in the future            
           dataProviderChanged = true;
           invalidateProperties();
        }
            
    }
    
    //--------------------------------------------------------------------------
    //
    //  Item -> Renderer mapping
    //
    //--------------------------------------------------------------------------
    
    public function getItemSkin(item:*):Object
    {
        var result:Object = null;
                    
        if (skinRegistry)
            result = skinRegistry[item];
        
        if (!result && item is DisplayObject)
            result = item;
                
        return result;
    }
    
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
    
    override public function addChildAt(child:DisplayObject, index:int):DisplayObject
    {
        throw(new Error("addChildAt is not available in DataGroup. " + 
                "Use methods defined on the dataProvider instead"));
    }
    
    override public function removeChild(child:DisplayObject):DisplayObject
    {
        throw(new Error("removeChild is not available in DataGroup. " + 
                "Use methods defined on the dataProvider instead"));
    }
    
    override public function removeChildAt(index:int):DisplayObject
    {
        throw(new Error("removeChildAt is not available in DataGroup. " + 
                "Use methods defined on the dataProvider instead"));
    }
    
    override public function setChildIndex(child:DisplayObject, index:int):void
    {
        throw(new Error("setChildIndex is not available in DataGroup. " + 
                "Use methods defined on the dataProvider instead"));
    }
    
    override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void
    {
        throw(new Error("swapChildren is not available in DataGroup. " + 
                "Use methods defined on the dataProvider instead"));
    }
    
    override public function swapChildrenAt(index1:int, index2:int):void
    {
        throw(new Error("swapChildrenAt is not available in DataGroup. " + 
                "Use methods defined on the dataProvider instead"));
    }
}
}