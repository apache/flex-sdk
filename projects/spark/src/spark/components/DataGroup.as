package mx.components
{
import flash.display.DisplayObject;
import flash.utils.Dictionary;

import mx.collections.IList;
import mx.components.baseClasses.GroupBase;
import mx.core.IDataRenderer;
import mx.core.IFactory;
import mx.core.IInvalidating;
import mx.core.ILayoutElement;
import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.core.UIComponent;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.RendererExistenceEvent;
import mx.layout.LayoutBase;
import mx.layout.LayoutElementFactory;



/**
 *  Dispatched when a renderer is added to the content holder.
 * <code>event.renderer</code> is the renderer that was added.
 *
 *  @eventType mx.events.RendererExistenceEvent.RENDERER_ADD
 */
[Event(name="rendererAdd", type="mx.events.RendererExistenceEvent")]

/**
 *  Dispatched when a renderer is removed from the content holder.
 * <code>event.renderer</code> is the renderer that was removed.
 *
 *  @eventType mx.events.RendererExistenceEvent.ITEM_REMOVE
 */
[Event(name="rendererRemove", type="mx.events.RendererExistenceEvent")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[ResourceBundle("components")]

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
     *  Restriction: if the typicalItem is an IVisualItem, it must not 
     *  also be a member of the dataProvider IList.
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
    
    private function setTypicalLayoutElement(obj:DisplayObject):void
    {
        var elt:ILayoutElement = (obj) ? LayoutElementFactory.getLayoutElementFor(obj) : null;
        typicalLayoutElement = elt;
        if (layout)
            layout.typicalLayoutElement = elt;
    }

    private function initializeTypicalItem():void
    {
        if (!_typicalItem)
        {
            setTypicalLayoutElement(null);
            return;
        }
                
        var obj:DisplayObject = DisplayObject(createRendererForItem(_typicalItem, false));
        if (!obj)
        {
            setTypicalLayoutElement(null);
            return;
        }

        super.addChild(obj)            
        if (obj is IInvalidating)
            IInvalidating(obj).validateNow();
        setTypicalLayoutElement(obj);
        super.removeChild(obj);
    }    
    
    /**
     *  @private
     *  Called before measure/updateDisplayList() if layout is virtual to guarantee that
     *  the typicalLayoutElement has been defined.  If it hasn't, typicalItem is 
     *  initialized to dataProvider[0] and layout.typicalLayoutElement is set.
     */
    private function ensureTypicalLayoutElement():void
    {
        if (layout.typicalLayoutElement == null)
        {
            var list:IList = dataProvider;
            if (list && (list.length > 0))
            {
                _typicalItem = list.getItemAt(0);
                initializeTypicalItem();
            }
        }
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
        {
            // If typicalLayoutElement was specified for this DataGroup, then use
            // it, otherwise use the layout's typicalLayoutElement, if any.
            if (typicalLayoutElement)
                value.typicalLayoutElement = typicalLayoutElement;
            else
                typicalLayoutElement = value.typicalLayoutElement;
        }
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
        typicalItemChanged = true;
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
     *  Function that returns an item renderer IFactory for a 
     *  specific item.  The signature of the function is:
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
        typicalItemChanged = true;
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
        if (_dataProvider == value)
            return;

        // if there's an old dataProvider, and we've created the item renderer for 
        // that dataProvider, then we need to clear out all those item renderers
        if (!dataProviderChanged && _dataProvider)
        {
            var vLayout:Boolean = layout && layout.useVirtualLayout;
            var startIndex:int = vLayout ? virtualLayoutStartIndex : 0;
            var endIndex:int = vLayout ? virtualLayoutEndIndex : dataProvider.length - 1; 
            for (var index:int = endIndex; index >= startIndex; index--)
            {
                mx_internal::itemRemoved(_dataProvider.getItemAt(index), index);
            }
            
            if (vLayout)
            {
                virtualLayoutStartIndex = virtualLayoutEndIndex = -1;
                oldVirtualLayoutStartIndex = oldVirtualLayoutEndIndex = -1;
                
                for (var i:int = freeRenderers.length - 1; i >= 0; i--)
                {
                    var myItemRenderer:IVisualElement = freeRenderers.pop() as IVisualElement;
                    super.removeChild(myItemRenderer as DisplayObject);
                }
            }
        }
        
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
        var vLayout:Boolean = layout && layout.useVirtualLayout;

        // Create all item renderers eagerly
        if (_dataProvider && !vLayout)
        {
            for (var i:int = 0; i < _dataProvider.length; i++)
                mx_internal::itemAdded(_dataProvider.getItemAt(i), i);
        }
        
        // The display list will be created lazily, at updateDisplayList() time
        if (vLayout)
        {
            invalidateSize();
            invalidateDisplayList();
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
    private function createRendererForItem(item:Object, failRTE:Boolean=true):IVisualElement
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
            myItemRenderer = itemRenderer.newInstance();
        
        // 3. if item is an IVisualElement and a DisplayObject, use it directly
        if (!myItemRenderer && item is IVisualElement && item is DisplayObject)
            myItemRenderer = IVisualElement(item);

        // Set the renderer's data to the item, but only if the item and renderer are different
        if ((myItemRenderer is IDataRenderer) && (myItemRenderer != item))
            IDataRenderer(myItemRenderer).data = item;   
                    
        // Couldn't find item renderer.  Throw an RTE.
        if (!myItemRenderer && failRTE)
        {
        	var err:String;
            if (item is IVisualElement || item is DisplayObject)
                err = resourceManager.getString("components", "cannotDisplayVisualElement");
            else
                err = resourceManager.getString("components", "unableToCreateRenderer", [item]);
            throw new Error(err);
        }

        return myItemRenderer;
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
        
        var len:int = numElements;
        for (var i:int = 0; i < len; i++)
        {  
            var myItemRenderer:IVisualElement = getElementAt(i);
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
    override public function get numElements():int
    {
        return dataProvider ? dataProvider.length : 0;
    }

    private var indexToRenderer:Array = []; 

    /**
     *  @private 
     *  The first and last layout element indices requested via 
     *  getLayoutElementAt().   Used by finishVirtualLayout()
     *  to distinguish IRs that can be recycled or discarded.
     */     
    private var virtualLayoutStartIndex:int = -1;
    private var virtualLayoutEndIndex:int = -1;
    private var oldVirtualLayoutStartIndex:int = -1;
    private var oldVirtualLayoutEndIndex:int = -1;

    /**
     *  @private 
     *  During a virtual layout, virtualLayoutUnderway is true.  This flag is used 
     *  to defeat calls to invalidateSize(), which occur when IRs are lazily validated.   
     *  See invalidateSize() and updateDisplayList().
     */
    private var virtualLayoutUnderway:Boolean = false;

    /**
     *  @private
     *  freeRenderers - IRs that were created by getLayoutElementAt() but
     *  are no longer in view.   They'll be reused by getLayoutElementAt().
     *  The list is updated by finishVirtualLayout().  
     */
    private var freeRenderers:Array = new Array();
         
    /**
     *  @private
     *  Discard the ItemRenderers that aren't needed anymore, i.e. the ones
     *  outside the logical range startIndex to endIndex.
     *  
     *  IRs can be recycled if they're IDataRenderers and they're
     *  not equal to the item they represent, i.e. if 
     *  renderersInView[item] != item.   More about item recycling
     *  in the getElementAt() doc.
     */
    private function finishVirtualLayout():void
    {
        // At this point, we have renderers for the current rendering cycle at 
        // [virtualLayoutStartIndex. virtualLayoutEndIndex], but we may also have old 
        // ones that need to be removed at [oldVirtualLayoutStartIndex, oldVirtualLayoutEndIndex]
        if (oldVirtualLayoutStartIndex == -1 || oldVirtualLayoutEndIndex == -1)
            return;
        
        // We want to remove item renderers at 
        // at [oldVirtualLayoutStartIndex, oldVirtualLayoutEndIndex]
        // but excluding [virtualLayoutStartIndex. virtualLayoutEndIndex].
        // Most of the time's we'll be removing one contiguous block 
        // before or after our on-screen item renderers, but sometimes 
        // we may be removing them before and after (in the case of 
        // the list changing heights)

        for (var index:int = oldVirtualLayoutStartIndex; index <= oldVirtualLayoutEndIndex; index++)
        {
            // if we encounter an IR in our current list of item renderers, 
            // let's smart-skip to the end.
            if (index >= virtualLayoutStartIndex && index <= virtualLayoutEndIndex)
            {
                index = virtualLayoutEndIndex;
                continue;
            }
            
            var elt:IVisualElement = indexToRenderer[index] as IVisualElement;

            // Remove previously "in view" IRs from the item=>IR table
            delete indexToRenderer[index];
            
            var item:Object = dataProvider.getItemAt(index);
            // Free or remove the IR.
            if ((item != elt) && (elt is IDataRenderer))
            {
                IDataRenderer(elt).data = null;  // reduce probability of leaks
                elt.visible = false;
                if (elt is UIComponent) 
                    UIComponent(elt).includeInLayout = false;
                freeRenderers.push(elt);
            }
            else
            {
                dispatchEvent(new RendererExistenceEvent(RendererExistenceEvent.RENDERER_REMOVE, 
                                false, false, elt, index, item));
                super.removeChild(DisplayObject(elt));
            }
        }
    }
    
    /**
     *  @private
     *  During virtual layout getLayoutElementAt() eagerly validates lazily
     *  created (or recycled) IRs.   We don't want changes to those IRs to
     *  invalidate the size of this UIComponent.
     */
    override public function invalidateSize():void
    {
        if (!virtualLayoutUnderway)
            super.invalidateSize();
    }

    /**
     *  @private 
     *  Make sure there's a typicalLayoutElement for virtual layout.
     */
    override protected function measure():void
    {
        if (layout && layout.useVirtualLayout)
            ensureTypicalLayoutElement();
        super.measure();
    }

    /**
     *  @private
     *  Manages the state required by virtual layout. 
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        if (layout && layout.useVirtualLayout)
        {
            virtualLayoutUnderway = true;
            oldVirtualLayoutStartIndex = virtualLayoutStartIndex;
            oldVirtualLayoutEndIndex = virtualLayoutEndIndex;
            virtualLayoutStartIndex = -1;
            ensureTypicalLayoutElement();
        }
        
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        if (virtualLayoutUnderway)
        {
            finishVirtualLayout();
            virtualLayoutUnderway = false;
        }
    }
    
    /**
     *  @inheritDoc
     * 
     *  For a DataGroup, <code>getElementAt()</code> returns the ItemRenderer 
     *  being used for the dataProvider item at the specified index.
     * 
     *  If the index is invalid, or if a dataProvider was not specified, then
     *  null is returned.
     * 
     *  If the layout is virtual and the specified item isn't "in view", then
     *  null will be returned.
     *
     *  Note that if the layout is virtual, ItemRenderers that are scrolled
     *  out of view may be reused.
     */
    override public function getElementAt(index:int):IVisualElement
    {
        if ((index < 0) || (dataProvider == null) || (index >= dataProvider.length))
            return null;
        
        var elt:IVisualElement = indexToRenderer[index];
        
        if (virtualLayoutUnderway)
        {
            /* - Recycling - 
             * 
             *  Currently, item renderers ("IRs") can only be recycled if they're all
             *  of the same type, they implement IDataRenderer, and they're all
             *  produced - by the itemRenderer factory - with the same initial
             *  configuration.  We can't ever really guarantee this however the case
             *  for which we're assuming that it's true is when just the itemRenderer
             *  is specified.  Even in this case, for recycling to work the
             *  itemRenderer (factory) must be essentially stateless, the IRs
             *  appearance must be based exclusively on its data.  For this reason
             *  we're also defeating recycling of IRs that don't implement
             *  IDataRenderer, see endVirtualLayout().  Although one could recycle
             *  these IRs, doing so would imply that either all of the IRs were
             *  the same, or that some did implement IDataRenderer and others
             *  did not.   We can't handle the latter, and a DataGroup where
             *  all items are the same wouldn't be worth the trouble.
             */
            if (virtualLayoutStartIndex == -1)  // initialized in updateDisplayList()
            {
                virtualLayoutStartIndex = index;
                virtualLayoutEndIndex = index;
            }
            else
            {
                virtualLayoutStartIndex = Math.min(index, virtualLayoutStartIndex); 
                virtualLayoutEndIndex = Math.max(index, virtualLayoutEndIndex);
            }
                      
            var createdIR:Boolean = false;
            var recycledIR:Boolean = false;
            
            if (!elt)
            {
                var item:Object = dataProvider.getItemAt(index);
                var recyclingOK:Boolean = (itemRendererFunction == null) && (itemRenderer != null);
                
                if (recyclingOK && (freeRenderers.length > 0))
                {
                    elt = freeRenderers.pop();
                    elt.visible = true;
                    if (elt is UIComponent)
                        UIComponent(elt).includeInLayout = true;
                    if (elt is IDataRenderer)
                        IDataRenderer(elt).data = item;
                    recycledIR = true;
                }
                else 
                {
                    elt = createRendererForItem(item);
                    createdIR = true;
                }
                
                indexToRenderer[index] = elt;
            }

            addItemRendererToDisplayList(DisplayObject(elt), index - virtualLayoutStartIndex);
            
            if ((createdIR || recycledIR) && (elt is IInvalidating))
                IInvalidating(elt).validateNow();
            if (createdIR)
                dispatchEvent(new RendererExistenceEvent(RendererExistenceEvent.RENDERER_ADD, 
                                    false, false, elt, index, item));
        }

        return elt;
    }

    /**
     *  @inheritDoc
     * 
     *  For a datagroup, this returns the index of the dataProvider 
     *  item that the specified ItemRenderer
     *  is being used for, or -1 if there is no such item. 
     * 
     *  If renderer is null, or if a dataProvider was not specified, then -1
     *  is returned.
     * 
     *  Note that if the layout is virtual, ItemRenderers that are scrolled
     *  out of view may be reused.
     */
    override public function getElementIndex(element:IVisualElement):int
    {
        if ((dataProvider == null) || (element == null))
            return -1;
            
        return indexToRenderer.indexOf(element);
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
     *  Adds the itemRenderer for the specified dataProvider item to this DataGroup.
     * 
     *  This method is called as needed by the DataGroup implementation,
     *  it should not be called directly.
     *
     *  @param item The item that was added, the value of dataProvider[index].
     *  @param index The index where the dataProvider item was added.
     */
    mx_internal function itemAdded(item:Object, index:int):void
    {
        if (layout && layout.useVirtualLayout)
        {
            if (index < virtualLayoutStartIndex)
            {
                invalidateSize();
                invalidateDisplayList();
                return;
            }
            else if (index > virtualLayoutEndIndex)
            {
                invalidateSize();
                return;
            }
            // otherwise, we'll add it to the display list
        }
        
        var myItemRenderer:IVisualElement = createRendererForItem(item);
        indexToRenderer.splice(index, 0, myItemRenderer);

        addItemRendererToDisplayList(myItemRenderer as DisplayObject, index);
        dispatchEvent(new RendererExistenceEvent(
                      RendererExistenceEvent.RENDERER_ADD, false, false, 
                      myItemRenderer, index, item));
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    /**
     *  Removes the itemRenderer for the specified dataProvider item from this DataGroup.
     * 
     *  This method is called as needed by the DataGroup implementation,
     *  it should not be called directly.
     *
     *  @param item The item that is being removed.
     * 
     *  @param index The index of the item that is being removed.
     */
    mx_internal function itemRemoved(item:Object, index:int):void
    {
        if (layout && layout.useVirtualLayout)
        {
            if (index < virtualLayoutStartIndex)
            {
                invalidateSize();
                invalidateDisplayList();
                return;
            }
            else if (index > virtualLayoutEndIndex)
            {
                invalidateSize();
                return;
            }
            // otherwise, we'll add it to the display list
        }
        
        var myItemRenderer:IVisualElement = indexToRenderer[index];
        indexToRenderer.splice(index, 1);
        
        dispatchEvent(new RendererExistenceEvent(
                      RendererExistenceEvent.RENDERER_REMOVE, false, false, 
                      myItemRenderer, index, item));
        
        // If the item and renderer are different objects, set the renderer data to 
        // null here to clear it out. Otherwise, the renderer keeps a reference to the item,
        // which can cause problems later.
        if (myItemRenderer is IDataRenderer && myItemRenderer != item)
            IDataRenderer(myItemRenderer).data = null;
        
        super.removeChild(myItemRenderer as DisplayObject);
        
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
        // If this child is already an element of the display list, ensure
        // that it's at the specified index
        if (child.parent && child.parent == this)
        {
            var insertIndex:int;
            if (index == -1)
                insertIndex = super.numChildren - 1;
            else if (index == 0)
                insertIndex = 0;
            else
                insertIndex = index;
                
            // Quietly ignore invalid indices since they're typically caused
            // by duplicate data items and Halo quietly ignore those
            if ((insertIndex >= 0) && (insertIndex < super.numChildren)) 
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
        if (dataProviderChanged || itemRendererChanged)
            return;
        
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
        var length:int = items.length;
        for (var i:int = length-1; i >= 0; i--)
        {
            mx_internal::itemRemoved(items[i].oldValue, location + i);               
        }
        
        for (i = length-1; i >= 0; i--)
        {
            mx_internal::itemAdded(items[i].newValue, location);
        }
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
     *  @inheritDoc
     * 
     *  DataGroup manages its own display objects, 
     *  and you should not call <code>addChild()</code> directly.
     *  If you want to add, remove, or swap items around, modify the 
     *  <code>dataProvider</code>.
     */
    override public function addChild(child:DisplayObject):DisplayObject
    {
        throw(new Error(resourceManager.getString("components", "methodUnavailable")));
    }
    
    /**
     *  @inheritDoc
     * 
     *  DataGroup manages its own display objects, 
     *  and you should not call <code>addChildAt()</code> directly.
     *  If you want to add, remove, or swap items around, modify the 
     *  <code>dataProvider</code>.
     */
    override public function addChildAt(child:DisplayObject, index:int):DisplayObject
    {
        throw(new Error(resourceManager.getString("components", "methodUnavailable")));
    }
    
    /**
     *  @inheritDoc
     * 
     *  DataGroup manages its own display objects, 
     *  and you should not call <code>removeChild()</code> directly.
     *  If you want to add, remove, or swap items around, modify the 
     *  <code>dataProvider</code>.
     */
    override public function removeChild(child:DisplayObject):DisplayObject
    {
        throw(new Error(resourceManager.getString("components", "methodUnavailable")));
    }
    
    /**
     *  @inheritDoc
     * 
     *  DataGroup manages its own display objects, 
     *  and you should not call <code>removeChildAt()</code> directly.
     *  If you want to add, remove, or swap items around, modify the 
     *  <code>dataProvider</code>.
     */
    override public function removeChildAt(index:int):DisplayObject
    {
        throw(new Error(resourceManager.getString("components", "methodUnavailable")));
    }
    
    /**
     *  @inheritDoc
     * 
     *  DataGroup manages its own display objects, 
     *  and you should not call <code>setChildIndex()</code> directly.
     *  If you want to add, remove, or swap items around, modify the 
     *  <code>dataProvider</code>.
     */
    override public function setChildIndex(child:DisplayObject, index:int):void
    {
        throw(new Error(resourceManager.getString("components", "methodUnavailable")));
    }
    
    /**
     *  @inheritDoc
     * 
     *  DataGroup manages its own display objects, 
     *  and you should not call <code>swapChildren()</code> directly.
     *  If you want to add, remove, or swap items around, modify the 
     *  <code>dataProvider</code>.
     */
    override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void
    {
        throw(new Error(resourceManager.getString("components", "methodUnavailable")));
    }
    
    /**
     *  @inheritDoc
     * 
     *  DataGroup manages its own display objects, 
     *  and you should not call <code>swapChildrenAt()</code> directly.
     *  If you want to add, remove, or swap items around, modify the 
     *  <code>dataProvider</code>.
     */
    override public function swapChildrenAt(index1:int, index2:int):void
    {
        throw(new Error(resourceManager.getString("components", "methodUnavailable")));
    }
}
}
