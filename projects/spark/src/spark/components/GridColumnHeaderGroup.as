////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components
{ 
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

import mx.collections.IList;
import mx.core.ClassFactory;
import mx.core.IFactory;
import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.managers.IFocusManagerComponent;

import spark.components.supportClasses.DefaultColumnHeaderRenderer;
import spark.components.supportClasses.GridColumn;
import spark.events.RendererExistenceEvent;
import spark.utils.LabelUtil;

use namespace mx_internal;

[IconFile("ColumnHeaderBar.png")]

/**
 * Questions:
 *  - Should you be able to tab to the ColumnHeaderBar?
 *  - How about to each item within the bar?
 *  - Should you be able to move between the items using the keyboard?
 *  - Contract between Grid and ColumnHeaderBar?
 *  - how is the column width determined?
 *  - how does the ColumnHeaderBar find out about column changes? 
 *  - do column headers support word-wrap thru skinning?
 *  - If we allow developers to provide custom item renderers that either extend 
 *      ItemRenderer or implement IItemRenderer directly, we'll be inheriting 
 *      ItemRenderer's 7 states (see ItemRenderer/getCurrentRendererState()).  
 *      That means that developers will not be able to configure the renderer 
 *      based on its column's sort-direction.  That's probably not going to 
 *      work, which means that we'll need a ColumnHeaderRenderer subclass of 
 *      ItemRenderer that adds extra states.
 */

/**
 *  The ColumnHeaderBar control defines
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
public class ColumnHeaderBar extends SkinnableDataContainer implements IFocusManagerComponent 
{
    include "../core/Version.as";

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
     *  @productversion Flex 4
     */
    public function ColumnHeaderBar()
    {
        super();
        
        itemRendererFunction = defaultColumnHeaderBarItemRendererFunction;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  columns
    //----------------------------------    
    
    /**
     *  @private
     */
    public function set columns(value:IList):void
    {
        super.dataProvider = value;        
        invalidateDisplayList();
    }

    //----------------------------------
    //  firstItemRenderer
    //----------------------------------
    
    private var _firstItemRenderer:IFactory = null;
    
    [Bindable("firstItemRendererChanged")]
    
    /**
     *  A factory for IItemRenderers used to render the header for the first
     *  grid columns.  If not specified, the column header bar's 
     *  <code>headerItemRenderer</code> is return.
     *  
     *  @default The value of the firstItemRenderer, or the headerItemRenderer,
     *  if this has not been set.
     *
     *  @see #dataField 
     *  @see GridItemRenderer
     */
    public function get firstItemRenderer():IFactory
    {
        return (_firstItemRenderer) ? _firstItemRenderer : itemRenderer;
    }
    
    /**
     *  @private
     */
    public function set firstItemRenderer(value:IFactory):void
    {
        if (_firstItemRenderer == value)
            return;
        
        _firstItemRenderer = value;
        dispatchChangeEvent("firstItemRendererChanged");
        
        invalidateDisplayList();
    }
    
    //----------------------------------
    //  grid
    //----------------------------------    
    
    private var _grid:Grid;
    
    /**
     *  @private
     */
    public function set grid(value:Grid):void
    {
        if (_grid == value)
            return;
        
        _grid = value;        
        invalidateDisplayList();
    }
    
    //----------------------------------
    //  horizontalScrollPosition
    //----------------------------------

    private var _horizontalScrollPosition:int;

    public function get horizontalScrollPosition():Number 
    {
        return dataGroup ? 
               dataGroup.horizontalScrollPosition : _horizontalScrollPosition;
    }
    
    /**
     *  @private
     */
    public function set horizontalScrollPosition(value:Number):void 
    {
        // If there is no layout, dataGroup caches this.
        if (dataGroup)
            dataGroup.horizontalScrollPosition = value;
        else
            _horizontalScrollPosition = value;
    }
    
    //----------------------------------
    //  labelField
    //----------------------------------
    
    /**
     *  @private
     */
    private var _labelField:String = "headerText";
    
    /**
     *  @private
     */
    private var labelFieldOrFunctionChanged:Boolean; 
    
    /**
     *  The name of the field in the data provider items to display 
     *  as the header label. 
     *  The <code>labelFunction</code> property overrides this property.
     *
     *  @default "headerText" 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2
     *  @productversion Flex 4.5
     */
    public function get labelField():String
    {
        return _labelField;
    }
    
    /**
     *  @private
     */
    public function set labelField(value:String):void
    {
        if (value == _labelField)
            return 
            
            _labelField = value;
        labelFieldOrFunctionChanged = true;
        invalidateProperties();
    }
    
    //----------------------------------
    //  labelFunction
    //----------------------------------
    
    /**
     *  @private
     */
    private var _labelFunction:Function; 
    
    /**
     *  A user-supplied function to run on each item to determine its label.  
     *  The <code>labelFunction</code> property overrides 
     *  the <code>labelField</code> property.
     *
     *  <p>You can supply a <code>labelFunction</code> that finds the 
     *  appropriate fields and returns a displayable string. The 
     *  <code>labelFunction</code> is also good for handling formatting and 
     *  localization. </p>
     *
     *  <p>The label function takes a single argument which is the item in 
     *  the data provider and returns a String.</p>
     *  <pre>
     *  myLabelFunction(item:Object):String</pre>
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2
     *  @productversion Flex 4.5
     */
    public function get labelFunction():Function
    {
        return _labelFunction;
    }
    
    /**
     *  @private
     */
    public function set labelFunction(value:Function):void
    {
        if (value == _labelFunction)
            return 
            
            _labelFunction = value;
        labelFieldOrFunctionChanged = true;
        invalidateProperties(); 
    }
    
    //----------------------------------
    //  lastItemRenderer
    //----------------------------------
    
    private var _lastItemRenderer:IFactory = null;
    
    [Bindable("lastItemRendererChanged")]
    
    /**
     *  A factory for IItemRenderers used to render the header for the last
     *  grid columns.  If not specified, the column header bar's 
     *  <code>itemRenderer</code> is return.
     *  
     *  @default The value of the lastItemRenderer, or the itemRenderer,
     *  if this has not been set.
     *
     *  @see #dataField 
     *  @see GridItemRenderer
     */
    public function get lastItemRenderer():IFactory
    {
        return (_lastItemRenderer) ? _lastItemRenderer : itemRenderer;
    }
    
    /**
     *  @private
     */
    public function set lastItemRenderer(value:IFactory):void
    {
        if (_lastItemRenderer == value)
            return;
        
        _lastItemRenderer = value;
        dispatchChangeEvent("lastItemRendererChanged");
        
        invalidateDisplayList();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  dataProvider
    //----------------------------------
    
    /**
     *  TBD: this is for the column headers
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function set dataProvider(value:IList):void
    {
        if (dataProvider)
            dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, dataProvider_collectionChangeHandler);
                
        // ensure that our listener is added before the dataGroup which adds a listener during
        // the base class setter if the dataGroup already exists.  If the dataGroup isn't
        // created yet, then we still be first.
        if (value)
            value.addEventListener(CollectionEvent.COLLECTION_CHANGE, dataProvider_collectionChangeHandler);
        
        super.dataProvider = value;
    }
    
    //----------------------------------
    //  itemRenderer
    //----------------------------------
    
    private var _itemRenderer:IFactory = null;
    
    [Bindable("itemRendererChanged")]
    
    /**
     *  A factory for IItemRenderers used to render the header for the
     *  grid columns.  If not specified, the 
     *  <code>DefaultColumnHeaderRenderer</code> is returned.
     * 
     *  <p>The default item renderer just displays the value of its 
     *  <code>label</code> property, which is based on the dataProvider item for 
     *  the column, and on the column's headerText property.  Custom item 
     *  renderers that derive more values from the column item and include 
     *  more complex visuals are easily created by subclassing 
     *  <code>ItemRenderer</code>.</p>
     * 
     *  @default The value of the headerItemRenderer.
     *
     *  @see DefaultColumnHeaderRenderer
     */
    override public function get itemRenderer():IFactory
    {
        if (!_itemRenderer)
            _itemRenderer = new ClassFactory(DefaultColumnHeaderRenderer);
        
        return _itemRenderer;
    }
    
    /**
     *  @private
     */
    override public function set itemRenderer(value:IFactory):void
    {
        if (_itemRenderer == value)
            return;
        
        _itemRenderer = value;
        invalidateDisplayList();

        dispatchChangeEvent("itemRendererChanged");
    }
            
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == dataGroup)
        { 
            dataGroup.horizontalScrollPosition = _horizontalScrollPosition;
            dataGroup.addEventListener(RendererExistenceEvent.RENDERER_ADD, dataGroup_rendererAddHandler);
            dataGroup.addEventListener(RendererExistenceEvent.RENDERER_REMOVE, dataGroup_rendererRemoveHandler);
        }
    }
    
    /**
     * @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        if (instance == dataGroup)
        {
            dataGroup.removeEventListener(RendererExistenceEvent.RENDERER_ADD, dataGroup_rendererAddHandler);
            dataGroup.removeEventListener(RendererExistenceEvent.RENDERER_REMOVE, dataGroup_rendererRemoveHandler);
        }

        super.partRemoved(partName, instance);
    }
        
    /**
     *  @private
     */
    override public function invalidateDisplayList():void
    {
        super.invalidateDisplayList();
        if (dataGroup)
            dataGroup.invalidateDisplayList();
    }
    
    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        if (labelFieldOrFunctionChanged)
        {
            // Cycle through all instantiated renderers to push the correct text 
            // in to the renderer by setting its label property
            if (dataGroup)
            {
                var itemIndex:int;
                
                // if virtual layout, only loop through the indices in view
                // otherwise, loop through all of the item renderers
                if (layout && layout.useVirtualLayout)
                {
                    for each (itemIndex in dataGroup.getItemIndicesInView())
                    {
                        updateRendererLabelProperty(itemIndex);
                    }
                }
                else
                {
                    var n:int = dataGroup.numElements;
                    for (itemIndex = 0; itemIndex < n; itemIndex++)
                    {
                        updateRendererLabelProperty(itemIndex);
                    }
                }
            }
            
            labelFieldOrFunctionChanged = false; 
        }
    }

    /**
     * @private
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        // ToDo: where/when should this be done?
        
        // Size the renderers to match the column widths.
        if (dataGroup && _grid)
        {
            const indicesInView:Vector.<int> = dataGroup.getItemIndicesInView();
            for each (var itemIndex:int in indicesInView)
            {
                var renderer:IVisualElement = 
                    dataGroup.getElementAt(itemIndex) as IVisualElement;
                if (renderer)
                {
                    // The width includes the columnGap.
                    var r:Rectangle = _grid.getCellBounds(0, itemIndex);
                    if (r)
                        renderer.width = r.width;
                }
            }
       }     
    }
    
    /**
     *  Given a data item, return the correct text a renderer
     *  should display while taking the <code>labelField</code> 
     *  and <code>labelFunction</code> properties into account. 
     *
     *  @param item A data item 
     *  
     *  @return String representing the text to display for the 
     *  data item in the  renderer. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function itemToLabel(item:Object):String
    {
        return LabelUtil.itemToLabel(item, labelField, labelFunction);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------
        
    private function dispatchChangeEvent(type:String):void
    {
        if (hasEventListener(type))
            dispatchEvent(new Event(type));
    }
    
    /**
     *  @private
     */
    private function updateRendererLabelProperty(itemIndex:int):void
    {
        // grab the renderer at that index and re-compute it's label property
        var renderer:IItemRenderer = dataGroup.getElementAt(itemIndex) as IItemRenderer; 
        if (renderer)
            renderer.label = itemToLabel(renderer.data); 
    }
    
    /**
     *  @private
     *  If the first column use the firstItemRenderer, if the last column use 
     *  the lastItemRenderer, otherwise use the itemRenderer.
     */
    private function defaultColumnHeaderBarItemRendererFunction(data:Object):IFactory
    {
        var column:GridColumn = GridColumn(data);
        
        var columnIndex:int = column.columnIndex;
        
        if (columnIndex == 0)
            return firstItemRenderer;
        
        if (columnIndex == dataProvider.length - 1)
            return lastItemRenderer;

        return itemRenderer;
    }
    
    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Called when the mouse is clicked. 
     */
    private function item_clickHandler(event:MouseEvent):void
    {
        var newIndex:int;
        if (event.currentTarget is IItemRenderer)
            newIndex = IItemRenderer(event.currentTarget).itemIndex;
        else
            newIndex = dataGroup.getElementIndex(event.currentTarget as IVisualElement);        
    }

    /**
     *  @private
     *  Called when contents within the dataProvider changes.  
     *
     *  @param event The collection change event
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function dataProvider_collectionChangeHandler(event:Event):void
    {
        // ToDo: what should be done if columns change?
        
        if (event is CollectionEvent)
        {
            var ce:CollectionEvent = CollectionEvent(event);
            
            if (ce.kind == CollectionEventKind.ADD)
            {
            }
            else if (ce.kind == CollectionEventKind.REMOVE)
            {
            }
            else if (ce.kind == CollectionEventKind.RESET)
            {
            }
            else if (ce.kind == CollectionEventKind.REFRESH)
            {
            }
            else if (ce.kind == CollectionEventKind.REPLACE ||
                    ce.kind == CollectionEventKind.MOVE)
            {
                //These cases are handled by the DataGroup skinpart  
            }
        }       
    }
    
    /**
     *  @private
     */
    private function dataGroup_rendererAddHandler(event:RendererExistenceEvent):void
    {
        const renderer:IItemRenderer = event.renderer as IItemRenderer; 
        if (renderer)
        {
            renderer.addEventListener(MouseEvent.CLICK, item_clickHandler);
            
            // ToDo: should the width of the renderer be set here or somewhere
            // else?
            if (_grid)
            {
                var r:Rectangle = _grid.getCellBounds(0, renderer.itemIndex);
                if (r)
                    renderer.width = r.width;
                else
                    invalidateDisplayList();
            }     

            // ToDo: deal with focus issues
            //if (renderer is IFocusManagerComponent)
            //    IFocusManagerComponent(renderer).focusEnabled = false;
        }
    }
    
    /**
     *  @private
     */
    private function dataGroup_rendererRemoveHandler(event:RendererExistenceEvent):void
    {        
        const renderer:IVisualElement = event.renderer;
        if (renderer)
            renderer.removeEventListener(MouseEvent.CLICK, item_clickHandler);
    }
}

}

