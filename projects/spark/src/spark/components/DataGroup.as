////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components
{
import flash.display.DisplayObject;
import flash.events.Event;

import mx.collections.IList;
import mx.core.IDataRenderer;
import mx.core.IFactory;
import mx.core.IInvalidating;
import mx.core.ILayoutElement;
import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.PropertyChangeEvent;

import spark.components.supportClasses.GroupBase;
import spark.events.RendererExistenceEvent;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;  // for mx_internal property contentChangeDelta


/**
 *  Dispatched when a renderer is added to this dataGroup.
 * <code>event.renderer</code> is the renderer that was added.
 *
 *  @eventType spark.events.RendererExistenceEvent.RENDERER_ADD
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="rendererAdd", type="spark.events.RendererExistenceEvent")]

/**
 *  Dispatched when a renderer is removed from this dataGroup.
 * <code>event.renderer</code> is the renderer that was removed.
 *
 *  @eventType spark.events.RendererExistenceEvent.RENDERER_REMOVE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="rendererRemove", type="spark.events.RendererExistenceEvent")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="addChild", kind="method")]
[Exclude(name="addChildAt", kind="method")]
[Exclude(name="removeChild", kind="method")]
[Exclude(name="removeChildAt", kind="method")]
[Exclude(name="setChildIndex", kind="method")]
[Exclude(name="swapChildren", kind="method")]
[Exclude(name="swapChildrenAt", kind="method")]
[Exclude(name="numChildren", kind="property")]
[Exclude(name="getChildAt", kind="method")]
[Exclude(name="getChildIndex", kind="method")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[ResourceBundle("components")]

[DefaultProperty("dataProvider")] 

[IconFile("DataGroup.png")]

/**
 *  The DataGroup class is the base container class for data items.
 *  The DataGroup class converts data items to visual elements for display.
 *  While this container can hold visual elements, it is often used only 
 *  to hold data items as children.
 *
 *  <p>The DataGroup class takes as children data items or visual elements 
 *  that implement the IVisualElement interface and are DisplayObjects.  
 *  Data items can be simple data items such String and Number objects, 
 *  and more complicated data items such as Object and XMLNode objects. 
 *  While these containers can hold visual elements, 
 *  they are often used only to hold data items as children.</p>
 *
 *  <p>An item renderer defines the visual representation of the 
 *  data item in the container. 
 *  The item renderer converts the data item into a format that can 
 *  be displayed by the container. 
 *  You must pass an item renderer to a DataGroup container to render 
 *  data items appropriately.</p>
 *
 *  <p>To improve performance and minimize application size, 
 *  the DataGroup container cannot be skinned. 
 *  If you want to apply a skin, use the SkinnableDataContainer instead. </p>
 * 
 *  @mxml
 *
 *  <p>The <code>&lt;s:DataGroup&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:DataGroup
 *    <strong>Properties</strong>
 *    dataProvider="null"
 *    itemRenderer="null"
 *    itemRendererFunction="null"
 *    typicalItem="null"
 *  
 *    <strong>Events</strong>
 *    rendererAdd="<i>No default</i>"
 *    rendererRemove="<i>No default</i>"
 *  /&gt;
 *  </pre>
 *
 *  @see spark.components.SkinnableDataContainer
 *  @see spark.components.Group
 *  @see spark.skins.spark.DefaultItemRenderer
 *  @see spark.skins.spark.DefaultComplexItemRenderer
 *  @includeExample examples/DataGroupExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class DataGroup extends GroupBase 
{
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    private var explicitTypicalItem:Object = null;
    private var typicalItemChanged:Boolean = false;
    private var typicalLayoutElement:ILayoutElement = null;

    /**
     *  Layouts use the preferred size of the <code>typicalItem</code>
     *  when fixed row or column sizes are required, but a specific 
     *  <code>rowHeight</code> or <code>columnWidth</code> value is not set.
     *  Similarly virtual layouts use this item to define the size 
     *  of layout elements that have not been scrolled into view.
     *
     *  <p>The container  uses the typical data item, and the associated item renderer, 
     *  to determine the default size of the container children. 
     *  By defining the typical item, the container does not have to size each child 
     *  as it is drawn on the screen.</p>
     *
     *  <p>Setting this property sets the <code>typicalLayoutElement</code> property
     *  of the layout.</p>
     * 
     *  <p>Restriction: if the <code>typicalItem</code> is an IVisualItem, it must not 
     *  also be a member of the data Provider.</p>
     * 
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        if (_typicalItem === value)
            return;
        _typicalItem = explicitTypicalItem = value;
        typicalItemChanged = true;
        invalidateProperties();
    }
    
    private function setTypicalLayoutElement(element:ILayoutElement):void
    {
        typicalLayoutElement = element;
        if (layout)
            layout.typicalLayoutElement = element;
    }

    private function initializeTypicalItem():void
    {
        if (_typicalItem === null)
        {
            setTypicalLayoutElement(null);
            return;
        }
                
        var renderer:IVisualElement = createRendererForItem(_typicalItem, false);
        var obj:DisplayObject = DisplayObject(renderer);
        if (!obj)
        {
            setTypicalLayoutElement(null);
            return;
        }

        super.addChild(obj);
        updateRenderer(renderer, _typicalItem);
        if (obj is IInvalidating)
            IInvalidating(obj).validateNow();
        setTypicalLayoutElement(renderer);
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

    private var useVirtualLayoutChanged:Boolean = false;
    
    /**
     *  @private
     *  Sync the typicalLayoutElement var with this group's layout.
     */    
    override public function set layout(value:LayoutBase):void
    {
        var oldLayout:LayoutBase = layout;
        if (value == oldLayout)
            return; 

        if (oldLayout)
        {
            oldLayout.typicalLayoutElement = null;
            oldLayout.removeEventListener("useVirtualLayoutChanged", layout_useVirtualLayoutChangedHandler);
        }
        // Changing the layout may implicitly change layout.useVirtualLayout
        if (oldLayout && value && (oldLayout.useVirtualLayout != value.useVirtualLayout))
            changeUseVirtualLayout();
        super.layout = value;    
        if (value)
        {
            // If typicalLayoutElement was specified for this DataGroup, then use
            // it, otherwise use the layout's typicalLayoutElement, if any.
            if (typicalLayoutElement)
                value.typicalLayoutElement = typicalLayoutElement;
            else
                typicalLayoutElement = value.typicalLayoutElement;
            value.addEventListener("useVirtualLayoutChanged", layout_useVirtualLayoutChangedHandler);
        }
    }
    
    /**
     *  @private
     *  If layout.useVirtualLayout changes, recreate the ItemRenderers.  This can happen
     *  if the layout's useVirtualLayout property is changed directly, or if the DataGroup's
     *  layout is changed. 
     */    
    private function changeUseVirtualLayout():void
    {
        cleanUpDataProvider();
        invalidateProperties();
        useVirtualLayoutChanged = true;
    }
    
    private function layout_useVirtualLayoutChangedHandler(event:Event):void
    {
        changeUseVirtualLayout();
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
     *  The item renderer to use for data items. 
     *  The class must implement the IDataRenderer interface.
     *  If defined, the <code>itemRendererFunction</code> property
     *  takes precedence over this property.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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

        cleanUpDataProvider();
        invalidateProperties();
        
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
     *  specific item.  You should define an item renderer function 
     *  similar to this sample function:
     *  
     *  <pre>
     *    function myItemRendererFunction(item:Object):IFactory</pre>
     * 
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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

        cleanUpDataProvider();
        invalidateProperties();
        
        itemRendererChanged = true;
        typicalItemChanged = true;
    }
 
    //----------------------------------
    //  rendererUpdateDelegate
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the rendererUpdateDelegate property.
     */
    private var _rendererUpdateDelegate:IItemRendererOwner;
    
    /**
     *  @private
     *  The rendererUpdateDelgate is used to delegate item renderer
     *  updates to another component, usually the owner of the
     *  DataGroup within the context of data centric component such
     *  as List. 
     *  
     *  The registered delegate must implement the IItemRendererOwner interface.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    mx_internal function get rendererUpdateDelegate():IItemRendererOwner
    {
        return _rendererUpdateDelegate;
    }
    
    /**
     *  @private
     */
    mx_internal function set rendererUpdateDelegate(value:IItemRendererOwner):void
    {
        _rendererUpdateDelegate = value;
    }
    
    //----------------------------------
    //  dataProvider
    //----------------------------------
    
    private var _dataProvider:IList;
    private var dataProviderChanged:Boolean;
    
    [Bindable("dataProviderChanged")]
    /**
     *  The data provider for this DataGroup. 
     *  It must be an IList.
     * 
     *  <p>There are several IList implementations included in the 
     *  Flex framework, including ArrayCollection, ArrayList, and
     *  XMLListCollection.</p>
     *
     *  @default null
     *
     *  @see #itemRenderer
     *  @see #itemRendererFunction
     *  @see mx.collections.IList
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        
        cleanUpDataProvider();
        
        _dataProvider = value;
        dataProviderChanged = true;
        invalidateProperties();
    }
    
    /**
     *  @private
     *  Cleans up all the old item renderers.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    protected function cleanUpDataProvider():void
    {
        if (_dataProvider)
            _dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, dataProvider_collectionChangeHandler);
        
        var index:int;
        var vLayout:Boolean = layout && layout.useVirtualLayout;
        
        // if there's an old dataProvider, and we've created the item renderer for 
        // that dataProvider, then we need to clear out all those item renderers
        if (indexToRenderer.length > 0)
        {
            var renderer:IVisualElement = indexToRenderer[index] as IVisualElement;
            var item:Object;
            
            if (!vLayout)
            {
                for (index = indexToRenderer.length - 1; index >= 0; index--)
                {
                    // FIXME (rfrishbe): we can't key off of the oldDataProvider for 
                    // the item because it might not be there anymore (for instance, 
                    // in a dataProvider reset where the new data is loaded into 
                    // the dataProvider--the dataProvider doesn't actually change, 
                    // but we still need to clean up).
                    // Because of this, we are assuming the item is either:
                    //   1.  The data property if the item implements IDataRenderer 
                    //       and there is an itemRenderer or itemRendererFunction
                    //   2.  The item itself
                    
                    renderer = indexToRenderer[index] as IVisualElement;
                    if (renderer is IDataRenderer && (itemRenderer != null || itemRendererFunction != null))
                        item = IDataRenderer(renderer).data;
                    else
                        item = renderer;
                    itemRemoved(item, index);
                }
                indexToRenderer = [];
            }
            else
            {
                var endIndex:int = virtualLayoutEndIndex;     // itemRemoved decrements virtualLayoutEndIndex
                var startIndex:int = virtualLayoutStartIndex; // itemRemoved decrements virtualLayoutStartIndex
                for (index = endIndex; (index >= 0) && (index >= startIndex); index--)
                {
                    // FIXME (rfrishbe): same as above
                    
                    renderer = indexToRenderer[index] as IVisualElement;
                    if (renderer is IDataRenderer && (itemRenderer != null || itemRendererFunction != null))
                        item = IDataRenderer(renderer).data;
                    else
                        item = renderer;
                    itemRemoved(item, index);
                }
                indexToRenderer = [];
                
                virtualLayoutStartIndex = virtualLayoutEndIndex = -1;
                oldVirtualLayoutStartIndex = oldVirtualLayoutEndIndex = -1;
                
                for (var i:int = freeRenderers.length - 1; i >= 0; i--)
                {
                    var myItemRenderer:IVisualElement = freeRenderers.pop() as IVisualElement;
                    super.removeChild(myItemRenderer as DisplayObject);
                }
            }
        }
    }
    
    /**
     *  @private
     *  Adds the elements of the data provider to the DataGroup.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    private function initializeDataProvider():void
    {
        var index:int;
        var vLayout:Boolean = layout && layout.useVirtualLayout;
        
        if (_dataProvider)
        {
            _dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, dataProvider_collectionChangeHandler, false, 0, true);
            
            // Create all item renderers eagerly
            if (!vLayout)
            {
                for (index = 0; index < _dataProvider.length; index++)
                    itemAdded(_dataProvider.getItemAt(index), index);
            }
            else
            {
                // The display list will be created lazily, at updateDisplayList() time
                invalidateSize();
                invalidateDisplayList();
            }
        }
    }
    
    /**
     *  @private 
     *  Given a data item, return the toString() representation 
     *  of the data item for an item renderer to display. Null 
     *  data items return the empty string. 
     *
     */
    private function itemToLabel(item:Object):String
    {
        if (item !== null)
            return item.toString();
        return " ";
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
     *  @return The renderer that represents the data element.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
            
            // if the function returned a factory, use that.
            // otherwise, if it returned null, try using the item directly
            if (rendererFactory)
                myItemRenderer = rendererFactory.newInstance();
            else if (item is IVisualElement && item is DisplayObject)
                myItemRenderer = IVisualElement(item);
        }
        
        // 2. if itemRenderer is defined, instantiate one
        if (!myItemRenderer && itemRenderer)
            myItemRenderer = itemRenderer.newInstance();
        
        // 3. if item is an IVisualElement and a DisplayObject, use it directly
        if (!myItemRenderer && item is IVisualElement && item is DisplayObject)
            myItemRenderer = IVisualElement(item);

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
        if (dataProviderChanged || itemRendererChanged || useVirtualLayoutChanged)
        {
            itemRendererChanged = false;
            useVirtualLayoutChanged = false;

            if (layout)
                layout.clearVirtualLayoutCache();
                
            // If an explicit value for typicalItem was never set, then clear
            // the layout's typicalLayoutElement, which will force it to be
            // recomputed by the next measured/updateDisplayList() call.
            if (!explicitTypicalItem)
                setTypicalLayoutElement(null);
                
            initializeDataProvider();
            
            // Don't reset the scroll positions until the new ItemRenderers are created
            // with initializeDataProvider, see bug https://bugs.adobe.com/jira/browse/SDK-23175
            if (dataProviderChanged)
            {
                dataProviderChanged = false;
                verticalScrollPosition = horizontalScrollPosition = 0;
            }

            maskChanged = true;
        }
        
        // Need to initializeDataProvider before calling super.commitProperties
        // initializeDataProvider removes all of the display list children.
        // GroupBase's commitProperties reattaches the mask
        super.commitProperties();

        if(_layeringFlags & LAYERING_DIRTY)
        {
            if (layout && layout.useVirtualLayout)
                invalidateDisplayList();
            else
                manageDisplayObjectLayers();
        }
        
        if (typicalItemChanged)
        {
            typicalItemChanged = false;
            initializeTypicalItem();
        }
    }
    
    /**
     *  @private
     *  True if we are updating a renderer currently. 
     *  We keep track of this so we can ignore any dataProvider collectionChange
     *  UPDATE events while we are updating a renderer just in case we try to update 
     *  the rendererInfo of the same renderer twice.  This can happen if setting the 
     *  data in an item renderer causes the data to mutate and issue a propertyChange
     *  event, which causes an collectionChange.UPDATE event in the dataProvider.  This 
     *  can happen for components which are being treated as data because the first time 
     *  they get set on the renderer, they get added to the display list, which may 
     *  cause a propertyChange event (if there's a child with an ID in it, that causes 
     *  a propertyChange event) or the data to morph in some way.
     */
    private var renderersBeingUpdated:Boolean = false;
    
    /**
     *  @private 
     *  Sets the renderer's data, owner and label properties. 
     *  Then, gives the "true" owner a chance to call update the 
     *  renderer if this DataGroup is not the owner. "True" owners 
     *  would use their impl of updateRenderer to clear out stale 
     *  properties for when the renderer is being recycled, and set
     *  new properties like owner, label, selected, etc. 
     * 
     */
    private function updateRenderer(renderer:IVisualElement, data:Object):void
    {
        if (!renderer)
           return;

        // keep track of whether we are actively updating an renderers 
        // so we can ignore any collectionChange.UPDATE events
        renderersBeingUpdated = true;
        
        // Set the data    
        if ((renderer is IDataRenderer) && (renderer !== data))
            IDataRenderer(renderer).data = data;
        
        // Newly created renderer with no owner, set owner to this     
        if (!renderer.owner)
            renderer.owner = this; 
        
        // If a delegate is specified defer to the rendererUpdateDelegate
        // to update the renderer.
        if (_rendererUpdateDelegate)
            _rendererUpdateDelegate.updateRenderer(renderer);

        // Else if we're the owner, set the label to the toString()
        // of the data 
        else if (renderer.owner == this && renderer is IItemRenderer)
            IItemRenderer(renderer).label = itemToLabel(data); 
        
        // technically if this got called "recursively", this renderersBeingUpdated flag
        // would be prematurely set to false, but in most cases, this check should be 
        // good enough.
        renderersBeingUpdated = false;
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
        var startIndex:int = 0;
        var endIndex:int = numElements - 1;
        
        if (layout && layout.useVirtualLayout && (virtualLayoutStartIndex != -1))
        {
            startIndex = virtualLayoutStartIndex;
            endIndex = virtualLayoutEndIndex;
        }
        
        for (var i:int = startIndex; i <= endIndex; i++)
        {  
            var myItemRenderer:IVisualElement = getElementAt(i);
            var layer:Number = myItemRenderer.depth;
            
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
            GroupBase.sortOnLayer(topLayerItems);
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

            GroupBase.sortOnLayer(bottomLayerItems);
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
     *  outside the range virtualLayoutStartIndex to virtualLayoutEndIndex.
     *  Discarded IRs may be added to the freeRenderers list per the rules
     *  defined in getVirtualElementAt().  If any visible renderer has a non-zero
     *  depth we resort DisplayObject - manageDisplayObjectLayers() - as well. 
     */
    private function finishVirtualLayout():void
    {
        if (oldVirtualLayoutStartIndex < 0 || oldVirtualLayoutEndIndex < 0)
            return;
        
        // Remove the old ItemRenderers that aren't new ItemRenderers.  In other
        // words remove the ItemRenderers from oldVirtualLayoutStartIndex to 
        // oldVirtualLayoutEndIndex, but skip the ones in the range
        // virtualLayoutStartIndex to virtualLayoutEndIndex.

        for (var index:int = oldVirtualLayoutStartIndex; index <= oldVirtualLayoutEndIndex; index++)
        {
            // Skip the inView renderers.  If vitrualLayoutStartIndex is -1, there aren't any. 
            if (virtualLayoutStartIndex != -1 && index >= virtualLayoutStartIndex && index <= virtualLayoutEndIndex)
            {
                index = virtualLayoutEndIndex;
                continue;
            }
            
            // Remove previously "in view" IR from the item=>IR table
            var elt:IVisualElement = indexToRenderer[index] as IVisualElement;
            delete indexToRenderer[index];

            // Free or remove the IR.
            var item:Object = dataProvider.getItemAt(index);
            if ((item != elt) && (elt is IDataRenderer))
            {
                // IDataRenderer(elt).data = null;  see https://bugs.adobe.com/jira/browse/SDK-20962
                elt.includeInLayout = false;
                elt.visible = false;
                
                // Reset back to (0,0), otherwise when the element is reused
                // it will be validated at its last layout size which causes
                // problems with text reflow.
                elt.setLayoutBoundsSize(0, 0, false);
                
                freeRenderers.push(elt);
            }
            else if (elt)
            {
                dispatchEvent(new RendererExistenceEvent(RendererExistenceEvent.RENDERER_REMOVE, false, false, elt, index, item));
                super.removeChild(DisplayObject(elt));
            }
        }

        // If there are any visible renderers whose depth property is non-zero
        // then use manageDisplayObjectLayers to resort the children list.  Note:
        // we're assuming that the layout has set the bounds of any elements that
        // were allocated but aren't actually visible to 0x0.
        
        if (virtualLayoutStartIndex < 0 || virtualLayoutEndIndex < 0)
            return;
        
        var depthSortRequired:Boolean = false;
        for(index = virtualLayoutStartIndex; index < virtualLayoutEndIndex; index++)
        {
            elt = indexToRenderer[index] as IVisualElement;
            if (!elt || !elt.visible || !elt.includeInLayout)
                continue;
            if ((elt.width == 0) || (elt.height == 0))
                continue;
            if (elt.depth != 0)
            {
                depthSortRequired = true;
                break;
            }
        }
        if (depthSortRequired)
            manageDisplayObjectLayers();
    }
    
    /**
     *  @private
     *  This function exists for applications that need to control their footprint by
     *  allowing currently unused IRs to be garbage collected.   It is not used by the SDK.
     */
    mx_internal function clearFreeRenderers():void
    {
        var n:int = freeRenderers.length;
        for (var i:int = 0; i < n; i++)
            freeRenderers[i] = null;
        freeRenderers.length = 0;
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
        renderFillForMouseOpaque();

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
     *  @private
     *  
     *  Returns the ItemRenderer being used for the data provider item at the specified index.
     *  Note that if the layout is virtual, ItemRenderers that are scrolled
     *  out of view may be reused.
     * 
     *  @param index The index of the data provider item.
     *
     *  @return The ItemRenderer being used for the data provider item 
     *  If the index is invalid, or if a data provider was not specified, then
     *  return <code>null</code>.
     *  If the layout is virtual and the specified item is not in view, then
     *  return <code>null</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function getElementAt(index:int):IVisualElement
    {
        if ((index < 0) || (dataProvider == null) || (index >= dataProvider.length))
            return null;
        
        return indexToRenderer[index];
    }
    
    /**
     *  @private
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function getVirtualElementAt(index:int, eltWidth:Number=NaN, eltHeight:Number=NaN):IVisualElement
    {
        if ((index < 0) || (dataProvider == null) || (index >= dataProvider.length))
            return null;
            
        var elt:IVisualElement = indexToRenderer[index];
        
        if (virtualLayoutUnderway)
        {
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
                    elt.includeInLayout = true;
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
            
            if (createdIR || recycledIR) 
            {
                updateRenderer(elt, item);
                if (!isNaN(eltWidth) || !isNaN(eltHeight))
                {
                    // If we're going to set the width or height of this
                    // layout element, first force it to initialize its
                    // measuredWidth,Height.    
                    if (elt is IInvalidating) 
                        IInvalidating(elt).validateNow();
                    elt.setLayoutBoundsSize(eltWidth, eltHeight);
                }
                if (elt is IInvalidating)
                    IInvalidating(elt).validateNow();
            }
            if (createdIR)
                dispatchEvent(new RendererExistenceEvent(RendererExistenceEvent.RENDERER_ADD, false, false, elt, index, item));
        }

        return elt;
     }

    /**
     *  @private
     *  
     *  Returns the index of the data provider item
     *  that the specified item renderer
     *  is being used for, or -1 if there is no such item. 
     *  Note that if the layout is virtual, ItemRenderers that are scrolled
     *  out of view may be reused.
     * 
     *  @param element The item renderer.
     *
     *  @return The index of the data provider item. 
     *  If <code>renderer</code> is <code>null</code>, or if the <code>dataProvider</code>
     *  property was not specified, then return -1.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    mx_internal function itemAdded(item:Object, index:int):void
    {
        if (layout)
            layout.elementAdded(index);
        
        if (layout && layout.useVirtualLayout)
        {
            // The next time updateDisplayList() runs, virtualLayoutStart,EndIndex
            // will become oldVirtualLayoutStart,End index.  The changes 
            // to virtualLayoutStart,EndIndex only affect finishVirtualLayout().
            if (index <= virtualLayoutEndIndex)
            {
                if (index <= virtualLayoutStartIndex)
                    virtualLayoutStartIndex += 1;
                virtualLayoutEndIndex += 1;
                indexToRenderer.splice(index, 0, null);                
            }

            invalidateSize();
            invalidateDisplayList();
            return;
        }
        
        var myItemRenderer:IVisualElement = createRendererForItem(item);
        indexToRenderer.splice(index, 0, myItemRenderer);
        addItemRendererToDisplayList(myItemRenderer as DisplayObject, index);
        updateRenderer(myItemRenderer, item);
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    mx_internal function itemRemoved(item:Object, index:int):void
    {
        if (layout)
            layout.elementRemoved(index);
        
        var myItemRenderer:IVisualElement = indexToRenderer[index];
        if (layout && layout.useVirtualLayout)
        {
            // The next time updateDisplayList() runs, virtualLayoutStart,EndIndex
            // will become oldVirtualLayoutStart,End index.  The changes 
            // to virtualLayoutStart,EndIndex only affect finishVirtualLayout().
            if (index <= virtualLayoutEndIndex)
            {
                if (index <= virtualLayoutStartIndex)
                    virtualLayoutStartIndex -= 1;
                virtualLayoutEndIndex -= 1;
                indexToRenderer.splice(index, 1);
            }            
        }
        else 
            indexToRenderer.splice(index, 1);
            
        dispatchEvent(new RendererExistenceEvent(
                      RendererExistenceEvent.RENDERER_REMOVE, false, false, 
                      myItemRenderer, index, item));
        
        if (myItemRenderer is IDataRenderer && myItemRenderer !== item)
            IDataRenderer(myItemRenderer).data = null;
        
        var child:DisplayObject = myItemRenderer as DisplayObject;
        if (child)
            super.removeChild(child);
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    /**
     *  @private
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    private function addItemRendererToDisplayList(child:DisplayObject, index:int):void
    { 
        // If this child is already an element of the display list, ensure
        // that it's at the specified index
        var childParent:Object = child.parent;
        if (childParent == this)
        {
            super.setChildIndex(child, index);
            return;
        }
        else if (childParent is DataGroup)
        {
            DataGroup(childParent)._removeChild(child);
        }

        if ((_layeringFlags & LAYERING_ENABLED) || 
            (child is IVisualElement && (child as IVisualElement).depth != 0))
            invalidateLayering();
            
        super.addChildAt(child, index);
    }
    
    /**
     *  @private
     *  Called when contents within the dataProvider changes.  We will catch certain 
     *  events and update our children based on that.
     *
     *  @param event The collection change event
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    mx_internal function dataProvider_collectionChangeHandler(event:CollectionEvent):void
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
                cleanUpDataProvider();
                dataProviderChanged = true;
                invalidateProperties();
                break;
            }
            
            case CollectionEventKind.RESET:
            {
                // reset everything
                cleanUpDataProvider();
                dataProviderChanged = true;
                invalidateProperties();
                break;
            }
            
            case CollectionEventKind.UPDATE:
            {
                // if a renderer is currently being updated, let's 
                // just ignore any UPDATE events.
                if (renderersBeingUpdated)
                    break;
                
                //update the renderer's data and data-dependant
                //properties. 
                for (var i:int = 0; i < event.items.length; i++)
                {
                    var pe:PropertyChangeEvent = event.items[i]; 
                    if (pe)
                    {
                        var renderer:IVisualElement = indexToRenderer[dataProvider.getItemIndex(pe.source)];
                        updateRenderer(renderer, pe.source); 
                    }
                }
                break;
            }
        }
    }
    
    /**
     *  @private
     */
    private function adjustAfterAdd(items:Array, location:int):void
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
    private function adjustAfterRemove(items:Array, location:int):void
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
    private function adjustAfterMove(item:Object, location:int, oldLocation:int):void
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
    private function adjustAfterReplace(items:Array, location:int):void
    {
        var length:int = items.length;
        for (var i:int = length-1; i >= 0; i--)
        {
            itemRemoved(items[i].oldValue, location + i);               
        }
        
        for (i = length-1; i >= 0; i--)
        {
            itemAdded(items[i].newValue, location);
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods: Access to overridden methods of base classes
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     * 
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
        throw(new Error(resourceManager.getString("components", "addChildDataGroupError")));
    }
    
    /**
     *  @private
     */
    override public function addChildAt(child:DisplayObject, index:int):DisplayObject
    {
        throw(new Error(resourceManager.getString("components", "addChildAtDataGroupError")));
    }
    
    /**
     *  @private
     */
    override public function removeChild(child:DisplayObject):DisplayObject
    {
        throw(new Error(resourceManager.getString("components", "removeChildDataGroupError")));
    }
    
    /**
     *  @private
     */
    override public function removeChildAt(index:int):DisplayObject
    {
        throw(new Error(resourceManager.getString("components", "removeChildAtDataGroupError")));
    }
    
    /**
     *  @private
     */
    override public function setChildIndex(child:DisplayObject, index:int):void
    {
        throw(new Error(resourceManager.getString("components", "setChildIndexDataGroupError")));
    }
    
    /**
     *  @private
     */
    override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void
    {
        throw(new Error(resourceManager.getString("components", "swapChildrenDataGroupError")));
    }
    
    /**
     *  @private
     */
    override public function swapChildrenAt(index1:int, index2:int):void
    {
        throw(new Error(resourceManager.getString("components", "swapChildrenAtDataGroupError")));
    }
}
}
