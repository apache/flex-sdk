////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components.gridClasses
{
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import mx.collections.IList;
import mx.core.IFactory;
import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;

import spark.components.DataGrid;
import spark.components.Grid;
import spark.components.GridColumnHeaderGroup;
import spark.components.Group;
import spark.components.supportClasses.GroupBase;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 *  Virtual horizontal layout for GridColumnHeaderGroup.  This is not a general 
 *  purpose layout class, it's only intended for GridColumnHeaderGroup, a DataGrid 
 *  skin part.
 * 
 *  This layout's measuredWidth is essentially zero because the DataGrid's grid
 *  dictates the overall measured width.  The columnHeaderGroup only contributes
 *  to the DataGrid's measured height. 
 *  
 */
public class GridColumnHeaderGroupLayout extends LayoutBase
{
    /**
     *  Constructor. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    public function GridColumnHeaderGroupLayout()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Internal variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Layers for header renderers and separators.
     */
    private var rendererLayer:Group;
    private var overlayLayer:Group;
    
    /**
     *  @private
     *  Cached header renderer heights maintained by the measure() method, 
     *  and the current content height.
     */
    private const rendererHeights:Array = new Array();
    private var maxRendererHeight:Number = 0;
    
    /**
     *  @private
     *  Bounds of all currently visible header renderers.
     */
    private const visibleRenderersBounds:Rectangle = new Rectangle();
    
    /**
     *  @private
     *  Currently visible header renderers.
     */
    private const visibleHeaderRenderers:Vector.<IGridItemRenderer> = new Vector.<IGridItemRenderer>();
    
    /**
     *  @private
     *  Currently visible header separators.
     */
    private const visibleHeaderSeparators:Vector.<IVisualElement> = new Vector.<IVisualElement>();
    
    /**
     *  @private
     *  The elements available for reuse aka the "free list".   Maps from an IFactory 
     *  to a list of the elements that have been allocated by that factory and then freed.   
     *  The list is represented by a Vector.<IVisualElement>.
     */
    private var freeElementMap:Dictionary = new Dictionary(); 
    
    /**
     *  @private
     *  Records the IFactory used to allocate a Element so that freeVisualElement()
     *  can find it again.
     */
    private var elementToFactoryMap:Dictionary = new Dictionary();
    
    //---------------------------------------------------------------
    //
    //  Overridden methods
    //
    //---------------------------------------------------------------
    
    /**
     *  @private
     */
    override public function set target(value:GroupBase):void
    {
        super.target = value;
        
        const chg:GridColumnHeaderGroup = value as GridColumnHeaderGroup;
        
        if (chg)
        {
            // Create layers
            rendererLayer = new Group();
            rendererLayer.layout = new LayoutBase();
            chg.addElement(rendererLayer);
            
            overlayLayer = new Group();
            overlayLayer.layout = new LayoutBase();
            chg.addElement(overlayLayer);
        }
    }
    
    /**
     *  @private
     */
    override public function get useVirtualLayout():Boolean
    {
        return true;
    }
    
    /**
     *  @private
     */
    override public function set useVirtualLayout(value:Boolean):void
    {
    }
    
    /**
     *  @private
     *  Clear everything.
     */
    override public function clearVirtualLayoutCache():void
    {
        rendererHeights.length = 0;
        visibleHeaderRenderers.length = 0;
        visibleHeaderSeparators.length = 0;
        visibleRenderersBounds.setEmpty();
        elementToFactoryMap = new Dictionary();
        freeElementMap = new Dictionary();
        if (rendererLayer)
            rendererLayer.removeAllElements();
        if (overlayLayer)
            overlayLayer.removeAllElements();
    }     
    
    /**
     *  @private
     */
    override protected function scrollPositionChanged():void
    {
        const columnHeaderGroup:GridColumnHeaderGroup = columnHeaderGroup;
        if (!columnHeaderGroup)
            return;
        
        super.scrollPositionChanged();  // sets columnHeaderGroup.scrollRect
        
        // Only invalidate if we're clipping and scrollR extends outside visibleRenderersBounds
        const scrollR:Rectangle = columnHeaderGroup.scrollRect;
		if (scrollR && !visibleRenderersBounds.containsRect(scrollR))
            columnHeaderGroup.invalidateDisplayList();
    }    
    
    /**
     *  @private
     */
    override public function measure():void
    {
        const columnHeaderGroup:GridColumnHeaderGroup = columnHeaderGroup;
        const grid:Grid = grid;
        
        if (!columnHeaderGroup || !grid)
            return;
        
        updateRendererHeights();
        
        const paddingLeft:Number = columnHeaderGroup.getStyle("paddingLeft");
        const paddingRight:Number = columnHeaderGroup.getStyle("paddingRight");
        const paddingTop:Number = columnHeaderGroup.getStyle("paddingTop");
        const paddingBottom:Number = columnHeaderGroup.getStyle("paddingBottom");
        
        var measuredWidth:Number = Math.ceil(paddingLeft + paddingRight);
        var measuredHeight:Number = Math.ceil(maxRendererHeight + paddingTop + paddingBottom);
        
        columnHeaderGroup.measuredWidth = Math.max(measuredWidth, columnHeaderGroup.minWidth);
        columnHeaderGroup.measuredHeight = Math.max(measuredHeight, columnHeaderGroup.minHeight);
    }

    /**
     *  @private
     */
    override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        const columnHeaderGroup:GridColumnHeaderGroup = columnHeaderGroup;
        const grid:Grid = grid;
        
        if (!columnHeaderGroup || !grid)
            return;

        const visibleColumnIndices:Vector.<int> = grid.getVisibleColumnIndices();
        const oldRenderers:Array = [];
        const rendererLayer:Group = this.rendererLayer;
        const overlayLayer:Group = this.overlayLayer;
        const columnSeparatorFactory:IFactory = columnHeaderGroup.columnSeparator;
        
        var renderer:IGridItemRenderer;
        var separator:IVisualElement;
        var column:GridColumn;
        var columnIndex:int = -1;
        
        // Add all of the renderers whose column is still visible to oldRenderers and free the rest
        
        for each (renderer in visibleHeaderRenderers)
        {
            column = renderer.column;
            columnIndex = (column) ? column.columnIndex : -1;
            
            if ((columnIndex != -1) && (visibleColumnIndices.indexOf(columnIndex) != -1) &&
                (oldRenderers[columnIndex] == null))
            {
                oldRenderers[columnIndex] = renderer;
            }
            else
            {
                freeVisualElement(renderer);
                renderer.discard(true);
            }
        }
        visibleHeaderRenderers.length = 0;
        
        // Add all of the separators to the free-list, since laying them out is cheap.
        
        for each (separator in visibleHeaderSeparators)
        {
            freeVisualElement(separator);
        }
        visibleHeaderSeparators.length = 0;
        
        // Layout the header renderers and update the CHB's content size
        
        const paddingLeft:Number = columnHeaderGroup.getStyle("paddingLeft");
        const paddingRight:Number = columnHeaderGroup.getStyle("paddingRight");
        const paddingTop:Number = columnHeaderGroup.getStyle("paddingTop");
        const paddingBottom:Number = columnHeaderGroup.getStyle("paddingBottom");
        
        const columns:IList = columns;
        const columnsLength:int = (columns) ? columns.length : 0;
        const lastVisibleColumnIndex:int = grid.getPreviousVisibleColumnIndex(columnsLength);
        const rendererY:Number = paddingTop;
        const rendererHeight:Number = unscaledHeight - paddingTop - paddingBottom;
        const maxRendererX:Number = columnHeaderGroup.horizontalScrollPosition + unscaledWidth;
        
        var visibleLeft:Number = 0;
        var visibleRight:Number = 0;
        
        // This isn't quite as simple as: 
        //     for each (var columnIndex:int in visibleColumnIndices)
        // since the GridColumnHeaderGroup may be wider than the grid because it
        // spans the vertical scrollbar.  If it does, we may need to display 
        // additional column headers (usually one).  
        
        for (var index:int = 0; /* termination conditions below */; index++)
        {
            if (index < visibleColumnIndices.length)
                columnIndex = visibleColumnIndices[index];
            else
                columnIndex = grid.getNextVisibleColumnIndex(columnIndex);
           
            if (columnIndex < 0 || columnIndex >= columnsLength)
                break;

            column = columns.getItemAt(columnIndex) as GridColumn;

            // reuse or create a new renderer
            
            renderer = oldRenderers[columnIndex];
            oldRenderers[columnIndex] = null;
            if (!renderer)
            {
                var factory:IFactory = column.headerRenderer;
                if (!factory)
                    factory = columnHeaderGroup.headerRenderer;
                renderer = allocateVisualElement(factory) as IGridItemRenderer;
            }
            visibleHeaderRenderers.push(renderer);
            
            // initialize the renderer
            
            initializeItemRenderer(renderer, columnIndex, column, true);
            if (renderer.parent != rendererLayer)
                rendererLayer.addElement(renderer);
            
            // layout the renderer
            
            var isLastColumn:Boolean = columnIndex == lastVisibleColumnIndex;
            var rendererX:Number = grid.getCellX(0, columnIndex) + paddingLeft;
            var rendererWidth:Number = grid.getColumnWidth(columnIndex);
            
            if (isLastColumn)
                rendererWidth = horizontalScrollPosition + unscaledWidth - rendererX - paddingRight;
            
            renderer.setLayoutBoundsSize(rendererWidth, rendererHeight);
            renderer.setLayoutBoundsPosition(rendererX, rendererY);
            
            if (index == 0)
                visibleLeft = rendererX;
            visibleRight = rendererX + rendererWidth;
            
            renderer.prepare(!createdVisualElement);
            
            if ((rendererX + rendererWidth) > maxRendererX)
                break;
            
            // allocate and layout a column separator
            
            if (columnSeparatorFactory && !isLastColumn)
            {
                separator = allocateVisualElement(columnSeparatorFactory);
                visibleHeaderSeparators.push(separator);
                separator.visible = true;
                if (separator.parent != overlayLayer)
                    overlayLayer.addElement(separator);
                
                var separatorWidth:Number = separator.getPreferredBoundsWidth();
                var separatorX:Number = rendererX + rendererWidth;
                separator.setLayoutBoundsSize(separatorWidth, rendererHeight);
                separator.setLayoutBoundsPosition(separatorX, rendererY);
            }
        }

        columnHeaderGroup.setContentSize(grid.contentWidth, rendererHeight);

		visibleRenderersBounds.left = visibleLeft - paddingLeft;
		visibleRenderersBounds.right = visibleRight = paddingRight;
		visibleRenderersBounds.top = rendererY - paddingTop;
        visibleRenderersBounds.height = rendererHeight + paddingTop + paddingBottom;
        
		
        // We may have created new renderers or changed their visibility.  Force
        // validation to avoid a display list flash.

        columnHeaderGroup.validateNow();
        
        // Update the renderer heights cache.
        // Invalidates the target's size if the maxRendererHeight has changed.
        
        updateRendererHeights(true);
    }
    
    //---------------------------------------------------------------
    //
    //  Public methods
    //
    //--------------------------------------------------------------- 
    
    /**
     *  Returns the column index corresponding to the specified coordinates,
     *  or -1 if the coordinates are out of bounds. The coordinates are 
     *  resolved with respect to the GridColumnHeaderGroup layout target.
     * 
     *  <p>If all of the columns or rows for the grid have not yet been scrolled
     *  into view, the returned index may only be an approximation, 
     *  based on all of the columns' <code>typicalItem</code>s.</p>
     *  
     *  @param x The pixel's x coordinate relative to the columnHeaderGroup
     *  @param y The pixel's y coordinate relative to the columnHeaderGroup
     *  @return the index of the column or -1 if the coordinates are out of bounds. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getHeaderIndexAt(x:Number, y:Number):int
    {
        const columnHeaderGroup:GridColumnHeaderGroup = columnHeaderGroup;
        const grid:Grid = grid;
        const columns:IList = columns;
        
        if (!columnHeaderGroup || !grid || !columns)
            return -1; 
        
        const paddingLeft:Number = columnHeaderGroup.getStyle("paddingLeft");
        const paddedX:Number = x + paddingLeft;
        var columnIndex:int = grid.getColumnIndexAt(paddedX, 0);
        
        // Special case for the stretched renderer above the vertical scrollbar
        // TODO (klin): Rethink this case if we change how the last header looks.
        if (columnIndex < 0)
        {
            const contentWidth:Number = columnHeaderGroup.contentWidth;
            const totalWidth:Number = horizontalScrollPosition + columnHeaderGroup.width - columnHeaderGroup.getStyle("paddingRight");
            if (paddedX >= contentWidth && paddedX < totalWidth)
                columnIndex = grid.getPreviousVisibleColumnIndex(columns.length)
        }
        
        return columnIndex;
    }
    
    /**
     *  Returns the column separator index corresponding to the specified 
     *  coordinates, or -1 if the coordinates don't overlap a separator. The 
     *  coordinates are resolved with respect to the GridColumnHeaderGroup layout target.
     * 
     *  <p>A separator is considered to "overlap" the specified location if the
     *  x coordinate is within <code>separatorMouseWidth</code> of separator's
     *  horizontal midpoint.</p>
     *  
     *  <p>The separator index is the same as the index of the column on the left
     *  (assuming that this component's layoutDirection is "rtl").  That means 
     *  that all column headers are flanked by two separators, except for the first
     *  visible column, which just has a separator on the right, and the last visible
     *  column, which just has a separator on the left.</p>
     * 
     *  <p>If all of the columns or rows for the grid have not yet been scrolled
     *  into view, the returned index may only be an approximation, 
     *  based on all of the columns' <code>typicalItem</code>s.</p>
     *  
     *  @param x The pixel's x coordinate relative to the columnHeaderGroup
     *  @param y The pixel's y coordinate relative to the columnHeaderGroup
     *  @return the index of the column or -1 if the coordinates don't overlap a separator.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getSeparatorIndexAt(x:Number, y:Number):int
    {
        const columnHeaderGroup:GridColumnHeaderGroup = columnHeaderGroup;
        const grid:Grid = grid;
        const columns:IList = columns;
        
        if (!columnHeaderGroup || !grid || !columns)
            return -1; 
        
        const paddingLeft:Number = columnHeaderGroup.getStyle("paddingLeft");
        const columnIndex:int = grid.getColumnIndexAt(x + paddingLeft, 0);
        
        if (columnIndex == -1)
            return -1;
        
        const isFirstColumn:Boolean = columnIndex == grid.getNextVisibleColumnIndex(-1);
        const isLastColumn:Boolean = columnIndex == grid.getPreviousVisibleColumnIndex(columns.length);
        
        const columnLeft:Number = grid.getCellX(0, columnIndex);
        const columnRight:Number = columnLeft + grid.getColumnWidth(columnIndex);
        const smw:Number = columnHeaderGroup.getStyle("separatorAffordance");
        
        if (!isFirstColumn && (x > (columnLeft - smw)) && (x < (columnLeft + smw)))
            return grid.getPreviousVisibleColumnIndex(columnIndex);
        
        if (!isLastColumn && (x > (columnRight - smw)) && (x < columnRight + smw))
            return columnIndex;
        
        return -1;
    }
    
    /**
     *  Returns the current pixel bounds of the specified header (renderer), or null if 
     *  no such column exists.  Header bounds are reported in GridColumnHeaderGroup coordinates.
     * 
     *  <p>If all of the visible columns preceeding the specified column have not 
     *  yet been scrolled into view, the returned bounds may only be an approximation, 
     *  based on all of the Grid's <code>typicalItem</code>s.</p>
     * 
     *  @param columnIndex The 0-based index of the column. 
     *  @return A <code>Rectangle</code> that represents the column header's pixel bounds, or null.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */     
    public function getHeaderBounds(columnIndex:int):Rectangle
    {
        const columnHeaderGroup:GridColumnHeaderGroup = columnHeaderGroup;
        const grid:Grid = grid;
        
        if (!columnHeaderGroup || !grid)
            return null;
        
        const columns:IList = columns;
        const columnsLength:int = (columns) ? columns.length : 0;
        
        if (columnIndex >= columnsLength)
            return null;
        
        const column:GridColumn = columns.getItemAt(columnIndex) as GridColumn;
        if (!column.visible)
            return null;
        
        const paddingLeft:Number = columnHeaderGroup.getStyle("paddingLeft");
        const paddingRight:Number = columnHeaderGroup.getStyle("paddingRight");
        const paddingTop:Number = columnHeaderGroup.getStyle("paddingTop");
        const paddingBottom:Number = columnHeaderGroup.getStyle("paddingBottom");
        
        var isLastColumn:Boolean = columnIndex == grid.getPreviousVisibleColumnIndex(columnsLength);
        var rendererX:Number = grid.getCellX(0, columnIndex) + paddingLeft;
        const rendererY:Number = paddingTop;
        var rendererWidth:Number = grid.getColumnWidth(columnIndex); 
        const rendererHeight:Number = columnHeaderGroup.height - paddingTop - paddingBottom;        
        
        if (isLastColumn)
            rendererWidth = horizontalScrollPosition + columnHeaderGroup.width - rendererX - paddingRight;
        
        return new Rectangle(rendererX, rendererY, rendererWidth, rendererHeight);
    }

    /**
     *  If the requested header renderer is visible, returns a reference to 
     *  the header renderer currently displayed for the specified column. 
     *  Note that once the returned header renderer is no longer visible it 
     *  may be recycled and its properties reset.  
     * 
     *  <p>If the requested header renderer is not visible then, 
     *  each time this method is called, a new header renderer is created.  The
     *  new item renderer is not visible</p>
     * 
     *  <p>The width of the returned renderer is the same as for item renderers
     *  returned by DataGrid/getItemRendererAt().</p>
     *  
     *  @param columnIndex The 0-based column index of the header renderer's column
     *  @return The item renderer or null if the column index is invalid.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getHeaderRendererAt(columnIndex:int):IGridItemRenderer
    {
        const columnHeaderGroup:GridColumnHeaderGroup = columnHeaderGroup;
        const grid:Grid = grid;
        
        if (!columnHeaderGroup || !grid || (columnIndex < 0))
            return null;
        
        // If columnIndex refers to a visible header renderer, return it
        
        const rendererLayer:Group = rendererLayer;
        const visibleColumnIndices:Vector.<int> = grid.getVisibleColumnIndices();
        const eltIndex:int = visibleColumnIndices.indexOf(columnIndex);
        if (eltIndex != -1)
        {
            const rendererLayerNumElements:int = rendererLayer.numElements;
            for (var index:int = 0; index < rendererLayerNumElements; index++)
            {
                var elt:IGridItemRenderer = rendererLayer.getElementAt(index) as IGridItemRenderer;
                if (elt && elt.visible && elt.column && (elt.column.columnIndex == columnIndex))
                    return elt;
            }
            return null;
        }
            
        // create a new renderer

        const columns:IList = columns;
        if (!columns || (columns.length <= columnIndex))
            return null;
        const column:GridColumn = columns.getItemAt(columnIndex) as GridColumn;
        if (!column.visible)
            return null;
        
        var factory:IFactory = column.headerRenderer;
        if (!factory)
            factory = columnHeaderGroup.headerRenderer;
        const renderer:IGridItemRenderer = allocateVisualElement(factory) as IGridItemRenderer;
        
        rendererLayer.addElement(renderer);

        // initialize the renderer
        
        initializeItemRenderer(renderer, columnIndex, column, renderer.visible);
        
        // layout the renderer

        const paddingLeft:Number = columnHeaderGroup.getStyle("paddingLeft");
        const paddingRight:Number = columnHeaderGroup.getStyle("paddingRight");
        const paddingTop:Number = columnHeaderGroup.getStyle("paddingTop");
        const paddingBottom:Number = columnHeaderGroup.getStyle("paddingBottom");
        
        const isLastColumn:Boolean = columnIndex == grid.getPreviousVisibleColumnIndex(columns.length);
        const rendererX:Number = grid.getCellX(0, columnIndex) + paddingLeft;
        const rendererY:Number = paddingTop;
        const rendererHeight:Number = columnHeaderGroup.height - paddingTop - paddingBottom;
        var rendererWidth:Number = grid.getColumnWidth(columnIndex); 
        
        if (isLastColumn)
            rendererWidth = horizontalScrollPosition + columnHeaderGroup.width - rendererX - paddingRight;
        
        renderer.setLayoutBoundsSize(rendererWidth, rendererHeight);
        renderer.setLayoutBoundsPosition(rendererX, rendererY);
        
        rendererLayer.removeElement(renderer);
        renderer.visible = false;
        
        return renderer;
    }
    
    //---------------------------------------------------------------
    //
    //  Internal methods, properties
    //
    //---------------------------------------------------------------    
    
    /**
     *  @private
     */
    private function initializeItemRenderer(renderer:IGridItemRenderer,
                                            columnIndex:int,
                                            column:GridColumn,
                                            visible:Boolean=true):void
    {
        renderer.visible = visible;
        renderer.column = column;
        renderer.label = column.headerText;
        
        const columnHeaderGroup:GridColumnHeaderGroup = columnHeaderGroup;

        const dataGrid:DataGrid = columnHeaderGroup.dataGrid;
        if (dataGrid)
            renderer.owner = dataGrid;
        
        renderer.hovered = columnIndex == columnHeaderGroup.hoverColumnIndex;
        renderer.down = columnIndex == columnHeaderGroup.downColumnIndex;
    }
    
    /**
     *  @private
     *  Let the allocateGridElement() caller know if the returned element was 
     *  created or recycled.
     */
    private var createdVisualElement:Boolean = false;
    
    /**
     *  @private
     */
    private function createVisualElement(factory:IFactory):IVisualElement
    {
        createdVisualElement = true;
        const newElement:IVisualElement = factory.newInstance() as IVisualElement;
        elementToFactoryMap[newElement] = factory;
        return newElement;
    }
    
    /**
     *  @private
     *  If the freeElementMap "free list" contains an instance of this factory, then 
     *  remove if from the free list and return it, otherwise create a new instance
     *  using createVisualElement().
     */
    private function allocateVisualElement(factory:IFactory):IVisualElement
    {
        createdVisualElement = false;
        const freeElements:Vector.<IVisualElement> = freeElementMap[factory] as Vector.<IVisualElement>;
        if (freeElements)
        {
            const freeElement:IVisualElement = freeElements.pop();
            if (freeElements.length == 0)
                delete freeElementMap[factory];
            if (freeElement)
                return freeElement;
        }
        
        return createVisualElement(factory);
    }
    
    /**
     *  @private
     *  Move the specified element to the free list after hiding it. Note that we 
     *  do not actually remove the element from its parent.
     */
    private function freeVisualElement(element:IVisualElement):void
    {
        const factory:IFactory = elementToFactoryMap[element];

        var freeElements:Vector.<IVisualElement> = freeElementMap[factory];
        if (!freeElements)
        {
            freeElements = new Vector.<IVisualElement>();
            freeElementMap[factory] = freeElements;
        }
        freeElements.push(element);
        
        element.visible = false;
    }
    
    /**
     *  @private
     *  Updates the renderer heights cache and the current max renderer height.
     *  Invalidates the target's size if the max renderer height has changed.
     * 
     *  <p>If the max live renderer height is the same as the max cached height, then
     *  just update the cache.
     *  If the max live renderer height is greater than the max cached height, then
     *  update the cache, cache the new height, and invalidate the target's size if
     *  necessary.
     *  If the max live renderer height is less than the max cached height, then
     *  update the cache, check to see if the cached max height has lowered, and
     *  invalidate the target's size if necessary.
     */
    private function updateRendererHeights(inUpdateDisplayList:Boolean = false):void
    {
        const columns:IList = columns;
        rendererHeights.length = (columns) ? columns.length : 0;
        
        var newHeight:Number = 0;
        
        // update cached renderer heights with live renderer heights.
        for each (var renderer:IGridItemRenderer in visibleHeaderRenderers)
        {
            var preferredHeight:Number = renderer.getPreferredBoundsHeight();
            rendererHeights[renderer.column.columnIndex] = preferredHeight;
            if (preferredHeight > newHeight)
                newHeight = preferredHeight;
        }
        
        // Do nothing if the heights are the same.
        if (newHeight == maxRendererHeight)
            return;
        
        if (newHeight < maxRendererHeight)
        {
            // If the live renderers' max height is less than the current
            // max height, check if this also lowers the maxRendererHeight.
            for (var i:int = 0; i < rendererHeights.length; i++)
            {
                var rendererHeight:Number = rendererHeights[i];
                if (!isNaN(rendererHeight) && rendererHeight > newHeight)
                    newHeight = rendererHeight;
            }
        }
        
        maxRendererHeight = newHeight;
        
        if (inUpdateDisplayList)
            columnHeaderGroup.invalidateSize();
    }
    
    //----------------------------------
    //  columnHeaderGroup
    //----------------------------------
    
    /**
     *  @private
     */
    private function get columnHeaderGroup():GridColumnHeaderGroup
    {
        return target as GridColumnHeaderGroup;
    }
    
    //----------------------------------
    //  grid
    //----------------------------------
    
    /**
     *  @private
     */
    private function get grid():Grid
    {
        const chg:GridColumnHeaderGroup = columnHeaderGroup;
        if (chg.dataGrid)
            return chg.dataGrid.grid;
        
        return null;
    }
    
    //----------------------------------
    //  columns
    //----------------------------------
    
    private var _columns:IList;
    
    /**
     *  @private
     *  The columns IList on the current Grid. A local reference is kept so
     *  that we can remove the colllection change handler if the columns
     *  list changes.
     */
    private function get columns():IList
    {
        const grid:Grid = grid;
        const newColumns:IList = (grid) ? grid.columns : null;
        
        if (newColumns != _columns)
        {
            if (_columns)
                _columns.removeEventListener(CollectionEvent.COLLECTION_CHANGE, columns_collectionChangeHandler);
            
            _columns = newColumns;
            
            if (_columns)
                _columns.addEventListener(CollectionEvent.COLLECTION_CHANGE, columns_collectionChangeHandler);
        }
        
        return _columns;
    }
    
    /**
     *  @private
     *  Handles changes to the columns IList that might affect the visible sort
     *  indicators.
     */
    private function columns_collectionChangeHandler(event:CollectionEvent):void
    {
        // TODO (klin): The cache could be adjusted here too.
        switch (event.kind)
        {
            case CollectionEventKind.ADD: 
            {
                columns_collectionChangeAdd(event);
                break;
            }
            
            case CollectionEventKind.REMOVE:
            {
                columns_collectionChangeRemove(event);
                break;
            }
                
            case CollectionEventKind.MOVE:
            {
                columns_collectionChangeMove(event);
                break;
            }
                
            case CollectionEventKind.REPLACE:
            case CollectionEventKind.UPDATE:
            {
                // Do nothing.
                break;
            }
                
            case CollectionEventKind.REFRESH:
            case CollectionEventKind.RESET:
            {
                columnHeaderGroup.visibleSortIndicatorIndices = null;
                break;
            }                
        }
    }
    
    /**
     *  @private
     *  Adjusts the visibleSortIndicatorIndices to the correct columns
     *  after columns are added.
     */
    private function columns_collectionChangeAdd(event:CollectionEvent):void
    {   
        const itemsLength:int = event.items.length;
        if (itemsLength <= 0)
            return;
        
        const chg:GridColumnHeaderGroup = columnHeaderGroup;
        const indices:Vector.<int> = chg.visibleSortIndicatorIndices;
        const indicesLength:int = indices.length;
        const startIndex:int = event.location;
        
        for (var i:int = 0; i < indicesLength; i++)
        {
            if (indices[i] >= startIndex)
                indices[i] += itemsLength;
        }
        chg.visibleSortIndicatorIndices = indices;
    }
    
    /**
     *  @private
     *  Adjusts the visibleSortIndicatorIndices to the correct columns
     *  after columns are removed.
     */
    private function columns_collectionChangeRemove(event:CollectionEvent):void
    {
        const itemsLength:int = event.items.length;
        if (itemsLength <= 0)
            return;
        
        const chg:GridColumnHeaderGroup = columnHeaderGroup;
        const indices:Vector.<int> = chg.visibleSortIndicatorIndices;
        const indicesLength:int = indices.length;
        const startIndex:int = event.location;
        const lastIndex:int = startIndex + itemsLength;
        const newIndices:Vector.<int> = new Vector.<int>();
        var index:int;
        
        for each (index in indices)
        {
            if (index < startIndex)
                newIndices.push(index);
            else if (index >= lastIndex)
                newIndices.push(index - lastIndex);
        }
        chg.visibleSortIndicatorIndices = newIndices;
    }
    
    /**
     *  @private
     *  Adjusts the visibleSortIndicatorIndices to the correct columns
     *  after columns are moved.
     */
    private function columns_collectionChangeMove(event:CollectionEvent):void
    {
        const itemsLength:int = event.items.length;
        if (itemsLength <= 0)
            return;
        
        const chg:GridColumnHeaderGroup = columnHeaderGroup;
        const indices:Vector.<int> = chg.visibleSortIndicatorIndices;
        const indicesLength:int = indices.length;
        const oldStart:int = event.oldLocation;
        const oldEnd:int = event.oldLocation + itemsLength;
        const newStart:int = event.location;
        const newEnd:int = event.location + itemsLength;
        var index:int;
        
        for (var i:int = 0; i < indicesLength; i++)
        {
            index = indices[i];
            
            if (index >= oldStart && index < oldEnd)
            {
                // Moved items move up to new position
                indices[i] = newStart + (index - oldStart);
                continue;
            }
            
            // Two cases:
            //      1) New position is greater than old position, so we
            //         decrement their position by the number of moved items.
            //      2) New position is less than old position, so we
            //         increment their position by the number of moved items.
            if (newStart > oldStart)
            {
                if (index >= oldEnd && index < newEnd)
                    indices[i] -= itemsLength;
            }
            else if (newStart < oldStart)
            {
                if (index >= newStart && index < oldStart)
                    indices[i] += itemsLength;
            }
        }
        chg.visibleSortIndicatorIndices = indices;
    }
}
}