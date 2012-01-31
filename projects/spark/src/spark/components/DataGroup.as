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
import flex.intf.ILayout;
import flex.intf.ILayoutItem;
import flex.layout.BasicLayout;
import flex.layout.LayoutItemFactory;

import mx.collections.ICollectionView;
import mx.collections.IList;
import mx.collections.ListCollectionView;
import mx.controls.Label;
import mx.core.IDataRenderer;
import mx.core.IDeferredInstance;
import mx.core.IFactory;
import mx.core.UIComponent;
import mx.events.CollectionEvent;
import mx.events.PropertyChangeEvent;
import mx.events.PropertyChangeEventKind;
import mx.collections.ArrayCollection;
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
public class DataGroup extends GroupBase 
{
    public function DataGroup()
    {
        super();
        
        // TODO (rfrishbe): work on initialization of dataProvider
        _dataProvider = new ArrayCollection();
        _dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler, false, 0, true);
    }
    
    private var skinRegistry:Dictionary;
    
    // item renderer
    public var itemRenderer:IFactory;   
    public var itemRendererFunction:Function; // signature: itemRendererFunction(item:*):IFactory
    
    // TODO (rfrishbe): be smarter about initialization
    private var _dataProvider:IList;
    private var dataProviderChanged:Boolean = false;
    private var needsDisplayObjectAssignment:Boolean = false;
    
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
    
    public function get dataProvider():IList
    {
        return _dataProvider;
    }
    
    protected function initializeChildrenArray():void
    {   
        dispatchEvent(new FlexEvent(FlexEvent.CONTENT_CHANGING));  
          
        // Get rid of existing display object children.
        // !!!!! This should probably be done through change notification
        // TODO!! This should be removing the last child b/c we want to 
        // send an event for each content child. This logic will send
        // remove event for the 0th content child x times. 
        for (var idx:int = numChildren; idx > 0; idx--)
            //itemRemoved(0);
            super.removeChildAt(0);
        
        if (_dataProvider !== null)
        {
            for (var i:int = 0; i < _dataProvider.length; i++)
            {
                itemAdded(_dataProvider.getItemAt(i), i);
            }
        }
        
        assignDisplayObjects();
        needsDisplayObjectAssignment = false;
        
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
        
        dispatchEvent(new FlexEvent(FlexEvent.CONTENT_CHANGED)); 
    }
    
    protected function createVisualForItem(item:*):DisplayObject
    {
        var itemSkin:DisplayObject;
        
        if (item === undefined || item === null)
            throw new Error("DataGroup content can not contain null or undefined items.");
        
        // Rules for skin lookup:
        // 0. if the item is a deferred instance, instantiate it and fall through to the other item(s)
        // 1. if the item is a display object, use it directly
        // 2. if itemRendererFunction is defined, call it to get the renderer factory and instantiate it
        // 3. if itemRenderer is defined, instantiate one
        // 4. create a Label component and call toString() on the item
            
        // 0. if the item is a deferred instance, instantiate it and fall through to the other item(s)
        if (item is IDeferredInstance)
            item = IDeferredInstance(item).getInstance();
        // TODO (rfrishbe): do deferred instantiation in DataGroup?
        
        // 1. if the item is a display object, use it directly unless the alwaysUseItemRenderer
        // flag is set.
        if (item is DisplayObject && itemRendererFunction == null)
            itemSkin = item;
            
        // 2. if itemRendererFunction is defined, call it to get the renderer factory and instantiate it
        if (!itemSkin && itemRendererFunction != null)
        {
            var rendererFactory:IFactory = itemRendererFunction(item);
            
            if (rendererFactory)
                itemSkin = rendererFactory.newInstance();
            else if (item is DisplayObject)
                itemSkin = item;
        }
        
        // 3. if itemRenderer is defined, instantiate one
        if (!itemSkin && itemRenderer != null)
            itemSkin = itemRenderer.newInstance();
                    
        // 4. create a Label component and call toString() on the item
        if (!itemSkin)
        {
            // No custom skin, use a Label
            itemSkin = new Label();
            Label(itemSkin).condenseWhite = true;
            Label(itemSkin).htmlText = item.toString();
        }
        
        // Set the skin data to the item, but only if the item and skin are different
        if (itemSkin is IDataRenderer && itemSkin != item)
            IDataRenderer(itemSkin).data = item;
    
        registerSkin(item, itemSkin);

        return itemSkin;
    }
    
    protected function registerSkin(item:*, itemSkin:DisplayObject):void
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
            initializeChildrenArray();
            
            // maskChanged = true; TODO (rfrishbe): need this maskChanged?
        }

        // Check whether we manage the elements, or are they managed by an ItemRenderer
        // TODO EGeorgie: we need to optimize this, iterating through all the elements is slow.
        // Validate element properties
        var length:int = dataProvider.length;
        for (var i:int = 0; i < length; i++)
        {
            var element:GraphicElement = dataProvider.getItemAt(i) as GraphicElement;
            if (element)
                element.validateProperties();
        }
        
        if (needsDisplayObjectAssignment)
        {
            needsDisplayObjectAssignment = false;
            assignDisplayObjects();
        }
    }
    
    override public function validateSize(recursive:Boolean = false):void
    {
        // Since GraphicElement is not ILayoutManagerClient, we need to make sure we
        // validate sizes of the elements, even in cases where recursive==false.
        
        // Check whether we manage the elements, or are they managed by an ItemRenderer
        // TODO EGeorgie: we need to optimize this, iterating through all the elements is slow.
        // Validate element size
        var length:int = dataProvider.length;
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
        var length:int = dataProvider.length;
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
        return dataProvider.length;
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

        if (!(item is IGraphicElement))
            item = getItemSkin(item);

        return LayoutItemFactory.getLayoutItemFor(item);
    }
    
    protected function itemAdded(item:*, index:int):void
    {
        var child:DisplayObject;
                
        if (item is GraphicElement) 
        {
            item.elementHost = this;
        
            // If a styleable GraphicElement is being added,
            // build its protochain for use by getStyle().
            if (item is IStyleClient)
                IStyleClient(item).regenerateStyleCache(true);
        }   
        else
        {     
            // This always adds the child to the end of the display list. Any 
            // ordering discrepancies will be fixed up in assignDisplayObjects().
            child = addItemToDisplayList(createVisualForItem(item), item);
        }
        
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
    
    // Returns true if the Group's display object can be shared with graphic elements
    // inside the group
    private function get canShareDisplayObject():Boolean
    {
    	return blendMode == "normal";
    }
    
    // This function assumes that the only displayObjects are either items in the content array
    // or created directly for an item in the content array. 
    private function assignDisplayObjects(startIndex:int = 0):void
    {
        var currentAssignableDO:DisplayObject = canShareDisplayObject ? this : null;
        var lastDisplayObject:DisplayObject = this;
        
        // Iterate through all of the items
        var len:int = _dataProvider.length; 
        for (var i:int = startIndex; i < len; i++)
        {  
            var item:* = _dataProvider.getItemAt(i);
            var insertIndex:int;
            
            if (!(item is GraphicElement)) 
                item = getItemSkin(item);
            
        	if (lastDisplayObject == this)
        		insertIndex = 0;
        	else
        		insertIndex = super.getChildIndex(lastDisplayObject) + 1;
        		
            if (item is DisplayObject)
            {
            	super.setChildIndex(item as DisplayObject, insertIndex);
            	
                lastDisplayObject = item as DisplayObject;
                // Null this out so that we are forced to create one for the next item
                currentAssignableDO = null; 
            }           
            else if (item is GraphicElement)
            {
                var element:GraphicElement = item as GraphicElement;
                
                if (currentAssignableDO == null || element.needsDisplayObject)
                {
                    var newChild:DisplayObject = element.displayObject;
                    
                    if (newChild == null)
                    {
                        newChild = element.createDisplayObject();
                        element.displayObject = newChild; // TODO!! Handle this in createDisplayObject?                 
                    }
                    
                    addItemToDisplayList(newChild, item, insertIndex); 
                    // If the element is transformed, the next item needs its own DO        
                    currentAssignableDO = element.nextSiblingNeedsDisplayObject ? null : newChild;
                    lastDisplayObject = newChild;
                }
                else
                {
                    // Item should be assigned the currentAssignableDO
                    // If it already has a DO, we need to remove it
                    if (element.displayObject)
                    {
                        if (element.displayObject.parent == this)
                            super.removeChild(element.displayObject);
                        element.destroyDisplayObject();
                    }
                    
                    element.sharedDisplayObject = currentAssignableDO;
                    if (element.nextSiblingNeedsDisplayObject)
                        currentAssignableDO = null;
                }
            }
        }
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
    
    override public function elementLayerChanged(e:IGraphicElement):void
    {
        super.elementLayerChanged(e);
        
        // One of our children have told us they might need a displayObject     
        assignDisplayObjects();
    }
    
    
    protected function collectionChangeHandler(event:Event):void
    {
        if (event is CollectionEvent)
        {
            var ce:CollectionEvent = CollectionEvent(event);

            /* if (ce.kind == CollectionEventKind.ADD)
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
                
            } */
            
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
    
    public function getItemSkin(item:*):DisplayObject
    {
        var result:DisplayObject = null;
                    
        if (skinRegistry)
            result = skinRegistry[item];
        
        if (!result && item is DisplayObject)
            result = item;
                
        return result;
    }
    
    public function getSkinItem(skin:DisplayObject):*
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
        throw(new Error("addChild is not available in Group. Use addItem instead."));
    }
    
    override public function addChildAt(child:DisplayObject, index:int):DisplayObject
    {
        throw(new Error("addChildAt is not available in Group. Use addItemAt instead."));
    }
    
    override public function removeChild(child:DisplayObject):DisplayObject
    {
        throw(new Error("removeChild is not available in Group. Use removeItem instead."));
    }
    
    override public function removeChildAt(index:int):DisplayObject
    {
        throw(new Error("removeChildAt is not available in Group. Use removeItemAt instead."));
    }
    
    override public function setChildIndex(child:DisplayObject, index:int):void
    {
        throw(new Error("setChildIndex is not available in Group. Use setItemIndex instead."));
    }
    
    override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void
    {
        throw(new Error("swapChildren is not available in Group. Use swapItems instead."));
    }
    
    override public function swapChildrenAt(index1:int, index2:int):void
    {
        throw(new Error("swapChildrenAt is not available in Group. Use swapItemsAt instead."));
    }
}
}