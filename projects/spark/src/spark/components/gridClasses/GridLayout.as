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

package spark.components.supportClasses
{
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;
import flash.utils.getTimer;

import mx.collections.IList;
import mx.core.IFactory;
import mx.core.IInvalidating;
import mx.core.ILayoutElement;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.UIComponent;
import mx.core.UIComponentGlobals;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.PropertyChangeEvent;
import mx.styles.ISimpleStyleClient;

import spark.components.ColumnHeaderBar;
import spark.components.DataGrid;
import spark.components.Grid;
import spark.components.Group;
import spark.components.IGridItemRenderer;
import spark.components.IGridRowBackground;
import spark.layouts.supportClasses.LayoutBase;
import spark.primitives.supportClasses.GraphicElement;
import spark.skins.spark.DefaultGridItemRenderer;

use namespace mx_internal;

public class GridLayout extends LayoutBase
{
    include "../../core/Version.as";    

    // TBD: lazily create this so that if it's replaced we don't needlessly create two.
    // Perhaps it should be a constructor parameter.   That way there's no need to sort
    // out how to migrate data from the old GLC to the new one.
    // Note also: if this was going to be shared, it should arrive as a constructor parameter.
    public var gridDimensions:GridDimensions;
        
    public function GridLayout()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Property Overrides
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  useVirtualLayout
    //----------------------------------

    /**
     *  GridLayout only supports virtual layout, the value of this property can not be changed.
     *  
     *  @return True.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
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
    
    
    //--------------------------------------------------------------------------
    //
    //  Method Overrides
    //
    //-------------------------------------------------------------------------- 
    
    
    /**
     *  @private
     *  Clear everything.
     */
    override public function clearVirtualLayoutCache():void
    {
        freeGridElements(visibleRowBackgrounds);
        freeGridElements(visibleRowSeparators);
        visibleRowIndices.length = 0;
        
        freeGridElements(visibleColumnBackgrounds);
        freeGridElements(visibleColumnSeparators);        
        visibleColumnIndices.length = 0;
        
        freeItemRenderers(visibleItemRenderers);
        
        freeGridElements(visibleSelectionIndicators);
        visibleRowSelectionIndices.length = 0;
        visibleColumnSelectionIndices.length = 0;
        
        freeGridElement(hoverIndicator)
        hoverIndicator = null;
        
        freeGridElement(caretIndicator);
        caretIndicator = null;
        
        visibleItemRenderersBounds.setEmpty();
        visibleGridBounds.setEmpty();
    }      

    /**
     *  @private
     *  This version of the method uses gridDimensions to calcuate the bounds
     *  of the specified cell.   The index is the cell's position in the row-major
     *  layout. 
     */
    override public function getElementBounds(index:int):Rectangle
    {
        const dataProvider:IList = (grid) ? grid.dataProvider : null;
        if (!dataProvider || (dataProvider.length == 0)) 
            return null;
        
        const rowCount:uint = dataProvider.length;
        const rowIndex:int = index / rowCount;
        const columnIndex:int = index - (rowIndex * rowCount);
        return gridDimensions.getCellBounds(rowIndex, columnIndex); 
    }
    
    /**
     *  @private
     */    
    override protected function getElementBoundsAboveScrollRect(scrollRect:Rectangle):Rectangle
    {
        const y:int = Math.max(0, scrollRect.top - 1);
        const rowIndex:int = gridDimensions.getRowIndexAt(scrollRect.x, y);
        return gridDimensions.getRowBounds(rowIndex);
    }
    
    /**
     *  @private
     */    
    override protected function getElementBoundsBelowScrollRect(scrollRect:Rectangle):Rectangle
    {
        const maxY:int = Math.max(0, gridDimensions.getContentHeight() - 1); 
        const y:int = Math.min(maxY, scrollRect.bottom + 1);
        const rowIndex:int = gridDimensions.getRowIndexAt(scrollRect.x, y);
        return gridDimensions.getRowBounds(rowIndex);
    }
    
    /**
     *  @private
     */    
    override protected function getElementBoundsLeftOfScrollRect(scrollRect:Rectangle):Rectangle
    {
        const x:int = Math.max(0, scrollRect.left - 1);
        const columnIndex:int = gridDimensions.getColumnIndexAt(x, scrollRect.y);
        return gridDimensions.getColumnBounds(columnIndex);
    }
    
    /**
     *  @private
     */    
    override protected function getElementBoundsRightOfScrollRect(scrollRect:Rectangle):Rectangle
    {
        const maxX:int = Math.max(0, gridDimensions.getContentWidth() - 1); 
        const x:int = Math.min(maxX, scrollRect.right + 1);
        const columnIndex:int = gridDimensions.getColumnIndexAt(x, scrollRect.y);
        return gridDimensions.getColumnBounds(columnIndex);
    }
    
    /**
     *  @private
     */
    override protected function scrollPositionChanged():void
    {
        if (!grid)
            return;
        
        grid.hoverRowIndex = -1;
        grid.hoverColumnIndex = -1;
            
        super.scrollPositionChanged();  // sets grid.scrollRect
        
        // Only invalidate if we're clipping and scrollR extends outside validBounds
        
        const scrollR:Rectangle = grid.scrollRect;
        if (scrollR && !visibleItemRenderersBounds.containsRect(scrollR))
            grid.invalidateDisplayList();
    }
    
    /**
	 *  @private
     *  Computes new values for the grid's measuredWidth,Height and 
	 *  measuredMinWidth,Height properties.  
     * 
     *  If grid.requestedRowCount is GTE 0, then measuredHeight is estimated 
	 *  content height for as many rows.  Otherwise the measuredHeight is the estimated 
	 *  content height for all rows.  The measuredWidth calculation is similar.  The 
	 *  measuredMinWidth,Height properties are also similar however if the corresponding 
	 *  requestedMin property isn't specified, then the measuredMin size is the same 
	 *  as the measured size.
     */
    override public function measure():void
    {
        if (!grid)
            return;
        
        var startTime:Number;
        if (enablePerformanceStatistics)
            startTime = getTimer();        
        
        layoutColumns(horizontalScrollPosition, verticalScrollPosition, NaN /* width */);        
        
        var measuredWidth:Number = gridDimensions.getTypicalContentWidth(grid.requestedColumnCount);
        var measuredHeight:Number = gridDimensions.getTypicalContentHeight(grid.requestedRowCount);
		var measuredMinWidth:Number = gridDimensions.getTypicalContentWidth(grid.requestedMinColumnCount);
		var measuredMinHeight:Number = gridDimensions.getTypicalContentHeight(grid.requestedMinRowCount);
		
        // Use Math.ceil() to make sure that if the content partially occupies
        // the last pixel, we'll count it as if the whole pixel is occupied.
        
        grid.measuredWidth = Math.ceil(measuredWidth);    
        grid.measuredHeight = Math.ceil(measuredHeight);
        grid.measuredMinWidth = Math.ceil(measuredMinWidth);    
        grid.measuredMinHeight = Math.ceil(measuredMinHeight);
        
        if (enablePerformanceStatistics)
        {
            var elapsedTime:Number = getTimer() - startTime;
            performanceStatistics.measureTimes.push(elapsedTime);            
        }
    }
    
    /**
     *  @private
     */
    override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        if (!grid)
            return;
        
        var startTime:Number;
        if (enablePerformanceStatistics)
        {
            startTime = getTimer();
            if (performanceStatistics.updateDisplayListStartTime === undefined)
                performanceStatistics.updateDisplayListStartTime = startTime;
        }
        
        // Layout the item renderers and compute new values for visibleRowIndices et al
        
        oldVisibleRowIndices = visibleRowIndices;
        oldVisibleColumnIndices = visibleColumnIndices;
        
        const scrollX:Number = horizontalScrollPosition;
        const scrollY:Number = verticalScrollPosition;
        
        visibleGridBounds.x = scrollX;
        visibleGridBounds.y = scrollY;
        visibleGridBounds.width = unscaledWidth;
        visibleGridBounds.height = unscaledHeight;
        
        // Layout the columns and item renderers
        
		layoutColumns(scrollX, scrollY, unscaledWidth);
        layoutItemRenderers(grid.itemRendererGroup, scrollX, scrollY, unscaledWidth, unscaledHeight);
        
        // Update the content size.  Make sure that if the content spans partially 
        // over a pixel to the right/bottom, the content size includes the whole pixel.
        
        const contentWidth:Number = Math.ceil(gridDimensions.getContentWidth());
        const contentHeight:Number = Math.ceil(gridDimensions.getContentHeight());
        grid.setContentSize(contentWidth, contentHeight); 
        
        // If the grid's contentHeight is smaller than than the available height 
        // (unscaledHeight) then pad the visible rows
        
        var paddedRowCount:int = gridDimensions.rowCount;
        if ((scrollY == 0) && (contentHeight < unscaledHeight))
        {
            const unusedHeight:Number = unscaledHeight - gridDimensions.getContentHeight();
            paddedRowCount += Math.ceil(unusedHeight / gridDimensions.defaultRowHeight);
        }
        
        for (var rowIndex:int = gridDimensions.rowCount; rowIndex < paddedRowCount; rowIndex++)
            visibleRowIndices.push(rowIndex);
        
        // Layout the row backgrounds
        
        visibleRowBackgrounds = layoutLinearElements(grid.rowBackground, grid.backgroundGroup, 
            visibleRowBackgrounds, oldVisibleRowIndices, visibleRowIndices, layoutRowBackground);

        // Layout the row and column separators. 
        
        const lastRowIndex:int = paddedRowCount - 1;
        const lastColumnIndex:int = gridDimensions.columnCount - 1;
        const overlayGroup:Group = grid.overlayGroup

        visibleRowSeparators = layoutLinearElements(grid.rowSeparator, overlayGroup, 
            visibleRowSeparators, oldVisibleRowIndices, visibleRowIndices, layoutRowSeparator, lastRowIndex);
        
        visibleColumnSeparators = layoutLinearElements(grid.columnSeparator, overlayGroup, 
            visibleColumnSeparators, oldVisibleColumnIndices, visibleColumnIndices, layoutColumnSeparator, lastColumnIndex);
        
        // Tell the ColumnHeaderBar to update its layout.
        
        layoutColumnHeaderBar();
        
        // Layout the hoverIndicator, caretIndicator, and selectionIndicators        
        
        layoutHoverIndicator(grid.backgroundGroup);
        layoutSelectionIndicators(grid.selectionGroup);
        layoutCaretIndicator(grid.overlayGroup);
        
        // To avoid flashing, force all of the layers to render now
        
        grid.backgroundGroup.validateNow();
        grid.selectionGroup.validateNow();
        grid.overlayGroup.validateNow();

        // The old visible row,column indices are no longer needed
        
        oldVisibleRowIndices.length = 0;
        oldVisibleColumnIndices.length = 0;
                
        if (enablePerformanceStatistics)
        {
            var endTime:Number = getTimer();
            const cellCount:int = visibleRowIndices.length * visibleColumnIndices.length;
            performanceStatistics.updateDisplayListEndTime = endTime;            
            performanceStatistics.updateDisplayListTimes.push(endTime - startTime);
            performanceStatistics.updateDisplayListRectangles.push(visibleGridBounds.clone());
            performanceStatistics.updateDisplayListCellCounts.push(cellCount);
        }
    }  

    //--------------------------------------------------------------------------
    //
    //  DataGrid Access
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private function get grid():Grid
    {
        return target as Grid;
    }
    
    /**
     *  @private
     */
    private function getGridColumn(columnIndex:int):GridColumn
    {
        const columns:IList = grid.columns;
        if ((columns == null) || (columnIndex >= columns.length) || (columnIndex < 0))
            return null;
        
        return columns.getItemAt(columnIndex) as GridColumn;
    }
    
    /**
     *  @private
     */
    private function getDataProviderItem(rowIndex:int):Object
    {
        const dataProvider:IList = grid.dataProvider;
        if ((dataProvider == null) || (rowIndex >= dataProvider.length) || (rowIndex < 0))
            return null;
        
        return dataProvider.getItemAt(rowIndex);
    }
    
    /**
     *  @private
     *  ToDo(cframpto): what is the proper way to get at this?
     */
    private function getColumnHeaderBar():ColumnHeaderBar
    {
        const dataGrid:DataGrid = grid.gridOwner as DataGrid;
        if (dataGrid == null)
            return null;
        
        return dataGrid.columnHeaderBar;
    }

    /**
     *  @private
     */
    private function getGridColumnHeader(columnIndex:int):IVisualElement
    {
        const headerBar:ColumnHeaderBar = getColumnHeaderBar();
        if (headerBar == null || headerBar.dataGroup == null)
            return null;
        
        return headerBar.dataGroup.getElementAt(columnIndex);
    }
        
    // TBD(hmuller): need a change notification scheme for the factory properties
    // when one changes (which is unlikely to happen very often), need to make sure
    // that the old ones aren't reused.
	
	//--------------------------------------------------------------------------
	//
	//  Updating the GridDimensions' typicalCell sizes and columnWidths
	//
	//-------------------------------------------------------------------------- 
	
    /**
	 *  @private
	 *  Use the specified GridColumn's itemRenderer (IFactory) to create a temporary
	 *  item renderer.   The returned item renderer must be freed, with freeGridElement(),
	 *  after it's used.
	 */
	private function createTypicalItemRenderer(columnIndex:int):IVisualElement
	{
		var typicalItem:Object = grid.typicalItem;
		if (typicalItem == null)
			typicalItem = getDataProviderItem(0);
		
		const column:GridColumn = getGridColumn(columnIndex);
		const factory:IFactory = column.itemToRenderer(typicalItem);
		const renderer:IVisualElement = allocateGridElement(factory) as IVisualElement;
		
		grid.itemRendererGroup.addElement(renderer);

		initializeItemRenderer(renderer, 0 /* rowIndex */, columnIndex, grid.typicalItem, false);
       
        // The default width of a TextField is 100.  If autoWrap is true, and
        // multiline is true, the measured text will wrap if it is wider than
        // the width. This is not what we want when measuring the typicalItem
        // unless the width is explicitly set on the column.
        var w:Number = 
            !isNaN(column.width) || !(renderer is DefaultGridItemRenderer) ? 
            column.width : UIComponent.DEFAULT_MAX_WIDTH;
        
        layoutItemRenderer(renderer, 0, 0, w, NaN);
        		
		grid.itemRendererGroup.removeElement(renderer);
		return renderer;
	}
	
	/**
	 *  @private
     *  Update the typicalCellWidth,Height for all of the columns starting 
     *  with x coordinate startX and column startIndex that fit within the 
     *  specified width.  Typical sizes are only updated if the current 
     *  typical cell size is NaN. 
     * 
     *  The typicalCellWidth for GridColumns with an explicit width, is just 
     *  the explicit width.  Otherwise an item renderer is created for the column 
     *  and the item renderer's preferred bounds become the typical cell size.   
     * 
     *  This method also updates the column width in GridDimensions if the column
     *  has an explicit width.
	 */
	private function updateTypicalCellSizes(width:Number, scrollX:Number, firstVisibleColumnIndex:int):void
	{
		const gridDimensions:GridDimensions = gridDimensions;
        
        // If width isn't specified, then only update requestedColumnCount columns
        
        const requestedColumnCount:int = grid.requestedColumnCount;
        var columnCount:int = gridDimensions.columnCount;
        if (isNaN(width) && (requestedColumnCount != -1))
            columnCount = Math.min(columnCount, requestedColumnCount);
        
        // Update the GridDimensions typicalCellWidth,Height values as needed.
        
		const columnGap:int = gridDimensions.columnGap;
		const startCellX:Number = gridDimensions.getCellX(0 /* rowIndex */, firstVisibleColumnIndex);
        const isFixedRowHeight:Boolean = !grid.variableRowHeight;
        var maxTypicalCellHeight:Number = 0;

		for (var columnIndex:int = firstVisibleColumnIndex; 
                 (isNaN(width) || (width > 0)) && (columnIndex < columnCount); 
                 columnIndex++)
		{
            var cellHeight:Number = gridDimensions.getTypicalCellHeight(columnIndex);
			var cellWidth:Number = gridDimensions.getTypicalCellWidth(columnIndex);
			
            var column:GridColumn = getGridColumn(columnIndex);
            if (!isNaN(column.width))
                cellWidth = column.width;
            
            if (isNaN(cellWidth) || isNaN(cellHeight))
            {
                var renderer:IVisualElement = createTypicalItemRenderer(columnIndex);
                if (isNaN(cellWidth))
                {
                    cellWidth = renderer.getPreferredBoundsWidth();
                    gridDimensions.setTypicalCellWidth(columnIndex, cellWidth);
                }
                if (isNaN(cellHeight))
                {
                    cellHeight = renderer.getPreferredBoundsHeight();
                    gridDimensions.setTypicalCellHeight(columnIndex, cellHeight);
                }
                freeGridElement(renderer);
            }
            
            if (!isNaN(width))
            {
    			if (columnIndex == firstVisibleColumnIndex)
    				width -= startCellX + cellWidth - scrollX;
    			else
    				width -= cellWidth + columnGap;
            }
            
            maxTypicalCellHeight = Math.max(maxTypicalCellHeight, cellHeight);
		}
        
        if (isFixedRowHeight && isNaN(grid.rowHeight))
            gridDimensions.fixedRowHeight = maxTypicalCellHeight;
    }
	
	/**
	 *  @private
	 *  Update the column widths for the columns visible beginning at scrollX, that will fit
	 *  within the specified width, or for all columns if width is NaN.  The width of 
     *  GridColumns that lack an explicit width is the preferred width of an item renderer 
     *  for the grid's typicalItem. 
     * 
     *  If width is specified and all columns are visible, then we'll increase the widths
     *  of GridDimensions columns for GridColumns without an explicit width so that all of
     *  the available space is consumed.
	 */
 	private function layoutColumns(scrollX:Number, scrollY:Number, width:Number):void
	{
        const gridDimensions:GridDimensions = gridDimensions;
        var columnCount:int = gridDimensions.columnCount;
        if (columnCount <= 0)
            return;
        
        // If width isn't specified (see measure()), then only update requestedColumnCount columns
        
        const requestedColumnCount:int = grid.requestedColumnCount;
        if (isNaN(width) && (requestedColumnCount != -1))
            columnCount = Math.min(columnCount, requestedColumnCount);
        
        // Update the GridDimensions typicalCellWidth,Height values as needed.

		const firstVisibleColumnIndex:int = gridDimensions.getColumnIndexAt(scrollX, scrollY);
        updateTypicalCellSizes(width, scrollX, firstVisibleColumnIndex);
        
        // Set the GridDimensions columnWidth for no more than columnCount columns.
        
        const columnGap:int = gridDimensions.columnGap;
        const startCellX:Number = gridDimensions.getCellX(0 /* rowIndex */, firstVisibleColumnIndex);
        var availableWidth:Number = width;  // can be NaN
        var flexibleColumnCount:uint = 0;
                
        for (var columnIndex:int = firstVisibleColumnIndex; 
                (isNaN(availableWidth) || (availableWidth > 0)) && (columnIndex < columnCount); 
                 columnIndex++)
        {
            var columnWidth:Number = gridDimensions.getTypicalCellWidth(columnIndex);
            var gridColumn:GridColumn = getGridColumn(columnIndex);
            
            if (isNaN(gridColumn.width)) // if this column's width wasn't explicitly specified
            {
                flexibleColumnCount += 1;
                
                // Clamp columnWidth to the gridColumn's min,maxWidth
                
                var minColumnWidth:Number = gridColumn.minWidth;
                var maxColumnWidth:Number = gridColumn.maxWidth;
                if (!isNaN(minColumnWidth))
                    columnWidth = Math.max(columnWidth, minColumnWidth);
                if (!isNaN(maxColumnWidth))
                    columnWidth = Math.min(columnWidth, maxColumnWidth);
            }
            else
                columnWidth = gridColumn.width;
            
            gridDimensions.setColumnWidth(columnIndex, columnWidth);  // store the column width
            
            if (!isNaN(availableWidth))
            {
                if (columnIndex == firstVisibleColumnIndex)
                    availableWidth -= startCellX + columnWidth - scrollX;
                else
                    availableWidth -= columnWidth + columnGap;
            }
        }
        
        // If a width was specified, we haven't scrolled horizontally, and
        // there's space left over, widen the columns whose GridColumn width 
        // isn't set explicitly, to fill the extra space.
        
        if ((scrollX != 0) || isNaN(width) || (availableWidth < 1.0) || (flexibleColumnCount == 0))
            return;
        
        const columnWidthDelta:Number = Math.ceil(availableWidth / flexibleColumnCount);

        for (columnIndex = firstVisibleColumnIndex; (columnIndex < columnCount) && (availableWidth >= 1.0); columnIndex++)
        {
            gridColumn = getGridColumn(columnIndex);
            
            if (isNaN(gridColumn.width)) // if this column's width wasn't explicitly specified 
            {
                var oldColumnWidth:Number = gridDimensions.getColumnWidth(columnIndex);
                columnWidth = oldColumnWidth + Math.min(availableWidth, columnWidthDelta);
                
                minColumnWidth = gridColumn.minWidth;
                maxColumnWidth = gridColumn.maxWidth;
                if (!isNaN(minColumnWidth))
                    columnWidth = Math.max(columnWidth, minColumnWidth);
                if (!isNaN(maxColumnWidth))
                    columnWidth = Math.min(columnWidth, maxColumnWidth);
                
                gridDimensions.setColumnWidth(columnIndex, columnWidth);  // store the column width
                availableWidth -= (columnWidth - oldColumnWidth);
            }
        }    
	}
	

    //--------------------------------------------------------------------------
    //
    //  Item Renderer Management and Layout
    //
    //--------------------------------------------------------------------------   
    
    /**
     *  @private
     *  The following variables define the visible part of the grid, where each item
     *  renderer displays dataProvider[rowIndex][columns[columnIndex].dataField].
     *  The index vectors are sorted in increasing order but their items may not be
     *  sequential.  The item renderers are stored in row major order.
     */
    private var visibleRowIndices:Vector.<int> = new Vector.<int>(0);
    private var visibleColumnIndices:Vector.<int> = new Vector.<int>(0);
    private var visibleItemRenderers:Vector.<IVisualElement> = new Vector.<IVisualElement>(0);
    
    /**
     *  @private
     *  The previous values of the corresponding variables.   Set by layoutItemRenderers()
     *  and only valid during updateDisplayList().
     */
    private var oldVisibleRowIndices:Vector.<int> = new Vector.<int>(0);
    private var oldVisibleColumnIndices:Vector.<int> = new Vector.<int>(0);

    /**
     *  @private
     *  The bounding rectangle for all of the visible item renderers.  Note that this
     *  rectangle may be larger than the scrollRect, since the first/last rows/columns
     *  of item renderers may only be partially visible.   See scrollPositionChanged().
     */
    private const visibleItemRenderersBounds:Rectangle = new Rectangle();
    
    /**
     *  Initialized by updateDisplayList with the current scrollPosition, and grid.width,Height.
     */
    private const visibleGridBounds:Rectangle = new Rectangle();
    
    
    private function layoutItemRenderers(itemRendererGroup:Group, scrollX:Number, scrollY:Number, width:Number, height:Number):void
    {
        var rowIndex:int;
        var colIndex:int;
        
        const gridDimensions:GridDimensions = gridDimensions;
        const rowCount:int = gridDimensions.rowCount;
        const colCount:int = gridDimensions.columnCount;
        const rowGap:int = gridDimensions.rowGap;
        const colGap:int = gridDimensions.columnGap;
        
        // Compute the row,column index and bounds of the upper left "start" cell
                
        const startColIndex:int = gridDimensions.getColumnIndexAt(scrollX, scrollY);
        const startRowIndex:int = gridDimensions.getRowIndexAt(scrollX, scrollY);
        const startCellR:Rectangle = gridDimensions.getCellBounds(startRowIndex, startColIndex);        
        
        // when null, no dataProvider exists or grid in a bad state. So, clean up and return.
        if (!startCellR)
        {
            // free itemRenderers
            for each (var r:IVisualElement in visibleItemRenderers)
                freeItemRenderer(r);
                
            visibleItemRenderers = new Vector.<IVisualElement>();
            visibleRowIndices = new Vector.<int>();
            visibleColumnIndices = new Vector.<int>();
            return;
        }
        
        // Compute newVisibleColumns
        
        const newVisibleColumnIndices:Vector.<int> = new Vector.<int>();
        var availableWidth:Number = width;
        
        for (colIndex = startColIndex; (availableWidth > 0) && (colIndex < colCount); colIndex++)
        {
            newVisibleColumnIndices.push(colIndex);
            if (colIndex == startColIndex)
                availableWidth -= startCellR.x + startCellR.width - scrollX;
            else
                availableWidth -= gridDimensions.getColumnWidth(colIndex) + colGap;
        }
        
        // compute newVisibleRowIndices, newVisibleItemRenderers, layout item renderers
        
        const newVisibleRowIndices:Vector.<int> = new Vector.<int>();
        const newVisibleItemRenderers:Vector.<IVisualElement> = new Vector.<IVisualElement>();
        
        var cellX:Number = startCellR.x;
        var cellY:Number = startCellR.y;
        var availableHeight:Number = height;
        
        for (rowIndex = startRowIndex; (availableHeight > 0) && (rowIndex < rowCount); rowIndex++)
        {
            newVisibleRowIndices.push(rowIndex);
            
            var rowHeight:Number = gridDimensions.getRowHeight(rowIndex);
            for each (colIndex in newVisibleColumnIndices)
            {
                var renderer:IVisualElement = takeVisibleItemRenderer(rowIndex, colIndex);
                if (!renderer)
                {       
                    var dataItem:Object = getDataProviderItem(rowIndex);
                    var column:GridColumn = getGridColumn(colIndex);
                    var factory:IFactory = column.itemToRenderer(dataItem);
                    renderer = allocateGridElement(factory) as IVisualElement;                   
                }
            
                if (renderer.parent != itemRendererGroup)
                    itemRendererGroup.addElement(renderer);
                
                newVisibleItemRenderers.push(renderer);
                initializeItemRenderer(renderer, rowIndex, colIndex);
                var colWidth:Number = gridDimensions.getColumnWidth(colIndex);
                layoutItemRenderer(renderer, cellX, cellY, colWidth, rowHeight);
                
                gridDimensions.setCellHeight(rowIndex, colIndex, renderer.getPreferredBoundsHeight());
                cellX += colWidth + colGap;
            }
           
            // If gridDimensions.rowHeight is now larger, we need to make another
            // pass to fix up the item renderer heights. 
            
            const finalRowHeight:Number = gridDimensions.getRowHeight(rowIndex);
            if (rowHeight != finalRowHeight)
            {
                const visibleColumnsLength:int = newVisibleColumnIndices.length;
                rowHeight = finalRowHeight;
                for each (colIndex in newVisibleColumnIndices)
                {
                    const rowOffset:int = newVisibleRowIndices.indexOf(rowIndex);
                    const colOffset:int = newVisibleColumnIndices.indexOf(colIndex);                    
                    const index:int = (rowOffset * visibleColumnsLength) + colOffset;

                    renderer = newVisibleItemRenderers[index];                    
                    layoutItemRenderer(renderer, renderer.x, renderer.y, renderer.width, rowHeight);
                    gridDimensions.setCellHeight(rowIndex, colIndex, renderer.getPreferredBoundsHeight());
                }
            } 
                                               
            cellX = startCellR.x;
            cellY += rowHeight + rowGap;
            
            if (rowIndex == startRowIndex)
                availableHeight -= startCellR.y + startCellR.height - scrollY;
            else
                availableHeight -= rowHeight + rowGap;            
        }
           
        // Free renderers that aren't in use
        
        for each (var oldRenderer:IVisualElement in visibleItemRenderers)
            freeItemRenderer(oldRenderer);
        
        // Update visibleItemRenderersBounds
        
        if (newVisibleRowIndices.length > 0 && newVisibleColumnIndices.length > 0)
        {
            const lastRowIndex:int = newVisibleRowIndices[newVisibleRowIndices.length - 1];
            const lastColIndex:int = newVisibleColumnIndices[newVisibleColumnIndices.length - 1];
            const lastCellR:Rectangle = gridDimensions.getCellBounds(lastRowIndex, lastColIndex);
            
            visibleItemRenderersBounds.x = startCellR.x;
            visibleItemRenderersBounds.y = startCellR.y;
            visibleItemRenderersBounds.width = lastCellR.x + lastCellR.width - startCellR.x;
            visibleItemRenderersBounds.height = lastCellR.y + lastCellR.height - startCellR.y;
        }
        else
        {
            visibleItemRenderersBounds.x = 0;
            visibleItemRenderersBounds.y = 0;
            visibleItemRenderersBounds.width = 0;
            visibleItemRenderersBounds.height = 0;
        }
        
        // Update visibleItemRenderers et al
        
        visibleItemRenderers = newVisibleItemRenderers;
        visibleRowIndices = newVisibleRowIndices;
        visibleColumnIndices = newVisibleColumnIndices;
    }


    /**
     *  @private
     *  ToDo(cframpto): what is the correct way to do this?
     * 
     *  For now, header width is determined by the grid column width and the
     *  header height, is the column bar header height if it has been explicitly
     *  set, otherwise it is the column header bar dataGroup's 
     *  typicalLayoutElement height.
     */
    private function layoutColumnHeaderBar():void
    {
        const colGap:int = gridDimensions.columnGap;
        
        const columnHeaderBar:ColumnHeaderBar = getColumnHeaderBar();
        if (columnHeaderBar)
        {
            const layout:ColumnHeaderBarLayout = 
                columnHeaderBar.layout as ColumnHeaderBarLayout;
            if (layout)
                layout.updateLayout(this);
        }        
    }

    /**
     *  @private
     *  Callback for the ColumnHeaderBar layout to use to layout the column
     *  header separators so all the layout code doesn't have to be duplicated.
     */
    mx_internal function layoutColumnHeaderSeparators(
                        oldVisibleColumnIndices:Vector.<int>,
                        visibleColumnIndices:Vector.<int>,
                        visibleHeaderSeparators:Vector.<IVisualElement>):Vector.<IVisualElement>
    {
        // ToDo(cframpto): the factory and group should come in as args
        
        const columnHeaderBar:ColumnHeaderBar = getColumnHeaderBar();
        if (columnHeaderBar)
        {
            const factory:IFactory = 
                columnHeaderBar.headerSeparator ?
                columnHeaderBar.headerSeparator : grid.columnSeparator;
            const lastColumnIndex:int = gridDimensions.columnCount - 1;
            
            visibleHeaderSeparators =  layoutLinearElements(factory,
                columnHeaderBar.overlayGroup, visibleHeaderSeparators,
                oldVisibleColumnIndices, visibleColumnIndices, 
                layoutHeaderSeparator, lastColumnIndex);
        }
        
        return visibleHeaderSeparators;
    }

	/**
     *  @private
     */
    private function getVisibleItemRendererIndex(rowIndex:int, columnIndex:int):int
    {
        if ((visibleRowIndices == null) || (visibleColumnIndices == null))
            return -1;
        
        // TBD(hmuller) - binary search would be faster than indexOf()
        
        const rowOffset:int = visibleRowIndices.indexOf(rowIndex);
        const colOffset:int = visibleColumnIndices.indexOf(columnIndex);
        if ((rowOffset == -1) || (colOffset == -1))
            return -1;
        
        const index:int = (rowOffset * visibleColumnIndices.length) + colOffset;
        return index;
    }
    
    public function getVisibleItemRenderer(rowIndex:int, columnIndex:int):IVisualElement
    {
        const index:int = getVisibleItemRendererIndex(rowIndex, columnIndex);
        if (index == -1)
            return null;
        
        const renderer:IVisualElement = visibleItemRenderers[index];
        return renderer;        
    }
    
    /**
     *  @private
     */
    private function takeVisibleItemRenderer(rowIndex:int, columnIndex:int):IVisualElement
    {
        const index:int = getVisibleItemRendererIndex(rowIndex, columnIndex);
        if (index == -1)
            return null;
        
        const renderer:IVisualElement = visibleItemRenderers[index];
        visibleItemRenderers[index] = null;
        return renderer;
    }
    
    /**
     *  @private
     */
    private function initializeItemRenderer(renderer:IVisualElement, 
                                            rowIndex:int, columnIndex:int,
                                            dataItem:Object=null,
                                            visible:Boolean=true):void
    {
        renderer.visible = visible;
        
        // This is needed so DataGrid's NonInheriting styles will be seen
        // by the renderer.
        if (renderer is ISimpleStyleClient)
            ISimpleStyleClient(renderer).styleName = grid.gridOwner;

        const gridRenderer:IGridItemRenderer = renderer as IGridItemRenderer;
        const gridColumn:GridColumn = getGridColumn(columnIndex);
        
        if (gridRenderer && gridColumn)
        {
            gridRenderer.rowIndex = rowIndex;
            gridRenderer.column = gridColumn;
            if (dataItem == null)
                dataItem = getDataProviderItem(rowIndex);
            gridRenderer.label = gridColumn.itemToLabel(dataItem);
            
            if (isRowSelectionMode())
            {
                gridRenderer.selected = grid.selectionContainsIndex(rowIndex);
                gridRenderer.showsCaret = grid.caretRowIndex == rowIndex;
            }
            else if (isCellSelectionMode())
            {
                gridRenderer.selected = grid.selectionContainsCell(rowIndex, columnIndex);
                gridRenderer.showsCaret = (grid.caretRowIndex == rowIndex) && (grid.caretColumnIndex == columnIndex);
            }
            
            gridRenderer.data = dataItem;
            
            if (grid.gridOwner)
                grid.gridOwner.prepareItemRenderer(gridRenderer, true);
        }
    }
    
    private function uninitializeItemRenderer(renderer:IVisualElement):void
    {
        if (grid.gridOwner)
            grid.gridOwner.discardItemRenderer(renderer, true);
    }
    
    private function freeItemRenderer(renderer:IVisualElement):void
    {
        if (!renderer)
            return;
        
        const addedToFreeList:Boolean = freeGridElement(renderer);
        if (addedToFreeList)
            uninitializeItemRenderer(renderer);
    }
    
    private function freeItemRenderers(renderers:Vector.<IVisualElement>):void
    {
        for each (var renderer:IVisualElement in renderers)
            freeItemRenderer(renderer);
        renderers.length = 0;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Linear elements: row,column separators, backgrounds 
    //
    //-------------------------------------------------------------------------- 
    
    private var visibleRowBackgrounds:Vector.<IVisualElement> = new Vector.<IVisualElement>(0);
    private var visibleColumnBackgrounds:Vector.<IVisualElement> = new Vector.<IVisualElement>(0);
    
    private var visibleRowSeparators:Vector.<IVisualElement> = new Vector.<IVisualElement>(0);
    private var visibleColumnSeparators:Vector.<IVisualElement> = new Vector.<IVisualElement>(0);
    
    /**
     *  @private
     *  Common code for laying out the rowBackround, rowSeparator, columnSeparator visual elements.
     * 
     *  For row,columnSeparators, lastIndex identifies the element in the new layout for which 
     *  no separator is drawn.  If the previous layout - oldVisibleIndices - included the lastIndex,
     *  it needs to be freed, even though it exists in the new layout (newVisibleIndices).   See
     *  freeLinearElements().
     */
    private function layoutLinearElements (
        factory:IFactory,
        container:IVisualElementContainer,
        oldVisibleElements:Vector.<IVisualElement>,
        oldVisibleIndices:Vector.<int>,
        newVisibleIndices:Vector.<int>,
        layoutFunction:Function,
        lastIndex:int = -1):Vector.<IVisualElement>
    {
        // If a factory wasn't provided, discard the old visible elements, then return
        
        if (factory == null)
        {
            for each (var oldElt:IVisualElement in oldVisibleElements)
            {
                removeGridElement(oldElt);
                if (oldElt.parent == container)
                    container.removeElement(oldElt);
            }
            return new Vector.<IVisualElement>(0);
        }
        
        // Free and clear oldVisibleElements that are no long visible
        
        freeLinearElements(oldVisibleElements, oldVisibleIndices, newVisibleIndices, lastIndex);
            
        // Create, layout, and return newVisibleElements
        
        const newVisibleElementCount:uint = newVisibleIndices.length;
        const newVisibleElements:Vector.<IVisualElement> = new Vector.<IVisualElement>(newVisibleElementCount);
        
        for (var index:int = 0; index < newVisibleElementCount; index++) 
        {
            var newEltIndex:int = (index < newVisibleIndices.length) ? newVisibleIndices[index] : index;
            if (newEltIndex == lastIndex)
                break;
            
            // If an element already exists for visibleIndex then use it, otherwise create one
            
            var eltOffset:int = oldVisibleIndices.indexOf(newEltIndex);
            var elt:IVisualElement = (eltOffset != -1) ? oldVisibleElements[eltOffset] : null;
            if (elt == null)
                elt = allocateGridElement(factory);
            
            // Initialize the element, and then delegate to the layout function
            
            newVisibleElements[index] = elt;
                
            if (elt.parent != container)
                container.addElement(elt);
            elt.visible = true;
            
            layoutFunction(elt, newEltIndex);
        }

        return newVisibleElements;
    }
    
    private function layoutCellElements (
        factory:IFactory,
        container:IVisualElementContainer,
        oldVisibleElements:Vector.<IVisualElement>,
        oldVisibleRowIndices:Vector.<int>, oldVisibleColumnIndices:Vector.<int>,
        newVisibleRowIndices:Vector.<int>, newVisibleColumnIndices:Vector.<int>,
        layoutFunction:Function):Vector.<IVisualElement>
    {
        // If a factory wasn't provided, discard the old visible elements, then return
        
        if (factory == null)
        {
            for each (var oldElt:IVisualElement in oldVisibleElements)
            {
                removeGridElement(oldElt);
                if (oldElt.parent == container)
                    container.removeElement(oldElt);
            }
            return new Vector.<IVisualElement>(0);
        }
        
        // Create, layout, and return newVisibleElements
        
        const newVisibleElementCount:uint = newVisibleRowIndices.length;
        const newVisibleElements:Vector.<IVisualElement> = 
            new Vector.<IVisualElement>(newVisibleElementCount);

        // Free and clear oldVisibleElements that are no long visible.
        
        freeCellElements(oldVisibleElements, newVisibleElements,
                         oldVisibleRowIndices, newVisibleRowIndices,
                         oldVisibleColumnIndices, newVisibleColumnIndices);
                 
        for (var index:int = 0; index < newVisibleElementCount; index++) 
        {
            var newEltRowIndex:int = newVisibleRowIndices[index];
            var newEltColumnIndex:int = newVisibleColumnIndices[index];
            
            // If an element already exists for visibleIndex then use it, 
            // otherwise create one.
            
            var elt:IVisualElement = newVisibleElements[index];
            if (elt === null)
            {
                // Initialize the element, and then delegate to the layout 
                // function.
                elt = allocateGridElement(factory);
                newVisibleElements[index] = elt;
            }
                        
            if (elt.parent != container)
                container.addElement(elt);
            elt.visible = true;
            
            layoutFunction(elt, newEltRowIndex, newEltColumnIndex);
        }
        
        return newVisibleElements;
    }

    /** 
     *  @private
     *  Free each member of elements if the corresponding member of oldIndices doesn't 
     *  appear in newIndices.  Both vectors of indices must have been sorted in increasing
     *  order.  When an element is freed, the corresponding member of the vector parameter
     *  is set to null.
     * 
     *  This method is [supposed to be a] somewhat more efficient implementation of the following:
     * 
     *  for (var i:int = 0; i < elements.length; i++)
     *     {
     *     if ((oldIndices[i] == lastIndex) || (newIndices.indexOf(oldIndices[i]) == -1))
     *         freeGridElement(elements[i]);
     *         elements[i] = null;
     *     }
     *  
     *  The lastIndex parameter is used to handle row and column separators, where the last
     *  element is left out since separators only appear in between elements.  If the lastIndex
     *  appears in oldIndices, we're not going to need the old element.
     */
    private function freeLinearElements (
        elements:Vector.<IVisualElement>, 
        oldIndices:Vector.<int>, 
        newIndices:Vector.<int>, 
        lastIndex:int):void
    {
        // TBD(hmuller): rewrite this, should be one pass (no indexOf)
        for (var i:int = 0; i < elements.length; i++)
        {
            const offset:int = newIndices.indexOf(oldIndices[i]);
            if ((oldIndices[i] == lastIndex) || (offset == -1))
            {
                const elt:IVisualElement = elements[i];
                if (elt)
                {
                    freeGridElement(elt);
                    elements[i] = null;
                }
            }
        }
    }      
    
    private function freeCellElements (
        elements:Vector.<IVisualElement>, newElements:Vector.<IVisualElement>, 
        oldRowIndices:Vector.<int>, newRowIndices:Vector.<int>,
        oldColumnIndices:Vector.<int>, newColumnIndices:Vector.<int>):void
    {
        var freeElement:Boolean = true;
       
        // assumes newRowIndices.length == newColumnIndices.length
        const numNewCells:int = newRowIndices.length;
        var newIndex:int = 0;
        
        for (var i:int = 0; i < elements.length; i++)
        {
            const elt:IVisualElement = elements[i];
            if (elt == null)
                continue;
            
            // assumes oldIndices.length == elements.length
            const oldRowIndex:int = oldRowIndices[i];
            const oldColumnIndex:int = oldColumnIndices[i];
            
            for ( ; newIndex < numNewCells; newIndex++)
            {
                const newRowIndex:int = newRowIndices[newIndex];
                const newColumnIndex:int = newColumnIndices[newIndex];
                
                if (newRowIndex == oldRowIndex)
                {
                    if (newColumnIndex == oldColumnIndex)
                    {
                        // Same cell still selected so reuse the selection.
                        // Save it in the correct place in newElements.  That 
                        // way we know its location based on 
                        // newRowIndices[newIndex], newColumnIndices[newIndex].
                        newElements[newIndex] = elt;
                        freeElement = false;
                        break;
                    }
                    else if (newColumnIndex > oldColumnIndex)
                    {
                        // not found
                        break;
                    }
                }
                else if (newRowIndex > oldRowIndex)
                {
                    // not found
                    break;
                }
            }
            
            if (freeElement)
                freeGridElement(elt);
                
            freeElement = true;
        }
        
        elements.length = 0;
    }      
    
    private function layoutRowBackground(rowBackground:IVisualElement, rowIndex:int):void
    {
        const rowCount:int = gridDimensions.rowCount;
        const bounds:Rectangle = (rowIndex < rowCount) 
            ? gridDimensions.getRowBounds(rowIndex)
            : gridDimensions.getPadRowBounds(rowIndex);
        
        if (!bounds)
            return;
        
        if  ((rowIndex < rowCount) && (bounds.width == 0)) // implies no columns
            bounds.width = visibleGridBounds.width;
        
        // Call initializeRowBackground() if possible
        
        const gridRowBackground:IGridRowBackground = rowBackground as IGridRowBackground;
        if (gridRowBackground)
            gridRowBackground.initializeRowBackground(grid, rowIndex);
        
        layoutGridElementR(rowBackground, bounds);
    }

    private function layoutRowSeparator(separator:IVisualElement, rowIndex:int):void
    {
        const r:Rectangle = visibleItemRenderersBounds;
        const width:Number = r.width;  
        const height:Number = 1; // TBD: should be max(1, colGap)
        const x:Number = r.x;
        const rowCount:int = gridDimensions.rowCount;
        const bounds:Rectangle = (rowIndex < rowCount) 
            ? gridDimensions.getRowBounds(rowIndex)
            : gridDimensions.getPadRowBounds(rowIndex);
        
        if (!bounds)
            return;
     
        const y:Number = bounds.bottom;
        layoutGridElement(separator, x, y, width, height);
    }
    
    private function layoutColumnSeparator(separator:IVisualElement, columnIndex:int):void
    {
        const r:Rectangle = visibleItemRenderersBounds;
        const width:Number = 1;  // TBD: should be max(1, rowGap)
        const height:Number = Math.max(r.height, visibleGridBounds.height); 
        const bounds:Rectangle = gridDimensions.getColumnBounds(columnIndex);
        
        if (!bounds)
            return;

        const x:Number = bounds.right;
        const y:Number = r.y;
        layoutGridElement(separator, x, y, width, height);
    }
    
    private function layoutHeaderSeparator(separator:IVisualElement, columnIndex:int):void
    {
        var columnHeaderBar:ColumnHeaderBar = getColumnHeaderBar();
        const width:Number = 1;  // TBD: should be max(1, rowGap)
        const height:Number = columnHeaderBar.height; 
        const columnBounds:Rectangle = gridDimensions.getColumnBounds(columnIndex);
        
        if (!columnBounds)
            return;

        const x:Number = columnBounds.right;
        const y:Number = columnBounds.top;
        layoutGridElement(separator, x, y, width, height);
    }

    //--------------------------------------------------------------------------
    //
    //  Selection Indicators
    //
    //--------------------------------------------------------------------------
    
    private var visibleSelectionIndicators:Vector.<IVisualElement> = new Vector.<IVisualElement>(0);
    private var visibleRowSelectionIndices:Vector.<int> = new Vector.<int>(0);    
    private var visibleColumnSelectionIndices:Vector.<int> = new Vector.<int>(0);
    
    private function isRowSelectionMode():Boolean
    {
        const mode:String = grid.selectionMode;
        return mode == GridSelectionMode.SINGLE_ROW || 
                mode == GridSelectionMode.MULTIPLE_ROWS;
    }
    
    private function isCellSelectionMode():Boolean
    {
        const mode:String = grid.selectionMode;        
        return mode == GridSelectionMode.SINGLE_CELL || 
                mode == GridSelectionMode.MULTIPLE_CELLS;
    }     
    
    private function layoutSelectionIndicators(container:IVisualElementContainer):void
    {
        const selectionIndicatorFactory:IFactory = grid.selectionIndicator;
        
        // layout and update visibleSelectionIndicators,Indices
                
        if (isRowSelectionMode())
        {
            // Selection is row-based so if there are existing cell selections, 
            // free them since they can't be reused.
            // TBD: this check won't work with column selections.
            if (visibleColumnSelectionIndices.length > 0)
            {
                freeGridElements(visibleSelectionIndicators);
                visibleSelectionIndicators.length = 0;
                visibleRowSelectionIndices.length = 0;
                visibleColumnSelectionIndices.length = 0;
            }

            var oldVisibleRowSelectionIndices:Vector.<int> = 
                visibleRowSelectionIndices;
            
            // Load this up with the currently selected rows.
            visibleRowSelectionIndices = new Vector.<int>();
            
            for each (var rowIndex:int in visibleRowIndices)
            {
                if (grid.selectionContainsIndex(rowIndex))
                {
                    visibleRowSelectionIndices.push(rowIndex);
                }
            }
            
            // Display the row selections.
            visibleSelectionIndicators = layoutLinearElements(
                selectionIndicatorFactory,
                container,
                visibleSelectionIndicators, 
                oldVisibleRowSelectionIndices, 
                visibleRowSelectionIndices, 
                layoutRowSelectionIndicator);
            
            return;
        }
        
        // Selection is not row-based so if there are existing row selections, 
        // free them since they can't be reused.
        // TBD: this check won't work with column selections.
        if (visibleRowSelectionIndices.length > 0 && 
            visibleColumnSelectionIndices.length == 0)
        {
            freeGridElements(visibleSelectionIndicators);
            visibleSelectionIndicators.length = 0;
            visibleRowSelectionIndices.length = 0;
        }
        
        if (isCellSelectionMode())
        {
            oldVisibleRowSelectionIndices = visibleRowSelectionIndices;
            const oldVisibleColumnSelectionIndices:Vector.<int> = 
                visibleColumnSelectionIndices;
            
            // Load up the vectors with the row/column of each selected cell.
            visibleRowSelectionIndices = new Vector.<int>();
            visibleColumnSelectionIndices = new Vector.<int>();
            for each (rowIndex in visibleRowIndices)
            {
                for each (var columnIndex:int in visibleColumnIndices)
                {
                    if (grid.selectionContainsCell(rowIndex, columnIndex))
                    {
                        visibleRowSelectionIndices.push(rowIndex);
                        visibleColumnSelectionIndices.push(columnIndex);
                    }
                }
            } 
                 
            // Display the cell selections.
            visibleSelectionIndicators = layoutCellElements(
                selectionIndicatorFactory,
                container,
                visibleSelectionIndicators, 
                oldVisibleRowSelectionIndices, oldVisibleColumnSelectionIndices,
                visibleRowSelectionIndices, visibleColumnSelectionIndices,
                layoutCellSelectionIndicator);
            
            return;
        }
        
        // No selection.
        
        // If there are existing cell selections, 
        // free them since there is no selection.
        // TBD: this check won't work with column selections.
        if (visibleColumnSelectionIndices.length > 0)
        {
            freeGridElements(visibleSelectionIndicators);
            visibleSelectionIndicators.length = 0;
            visibleRowSelectionIndices.length = 0;
            visibleColumnSelectionIndices.length = 0;
        }
    }
    
    private function layoutRowSelectionIndicator(indicator:IVisualElement, rowIndex:int):void
    {
        layoutGridElementR(indicator, gridDimensions.getRowBounds(rowIndex));
    }    
    
    private function layoutCellSelectionIndicator(indicator:IVisualElement, 
                                                  rowIndex:int,
                                                  columnIndex:int):void
    {
        layoutGridElementR(indicator, gridDimensions.getCellBounds(rowIndex, columnIndex));
    }    

    //--------------------------------------------------------------------------
    //
    //  Indicators: hover, caret
    //
    //--------------------------------------------------------------------------
    
    private var hoverIndicator:IVisualElement = null;
    private var caretIndicator:IVisualElement = null;
    
    private function layoutIndicator(
        container:IVisualElementContainer,
        indicatorFactory:IFactory,
        indicator:IVisualElement, 
        rowIndex:int,
        columnIndex:int):IVisualElement
    {
        if (rowIndex == -1 || grid.selectionMode == GridSelectionMode.NONE)
        {
            if (indicator)
                indicator.visible = false;
            return indicator;
        }
        
        if (!indicator && indicatorFactory)
            indicator = indicatorFactory.newInstance() as IVisualElement;
        
        if (indicator)
        {
            var bounds:Rectangle = isRowSelectionMode() ? 
                gridDimensions.getRowBounds(rowIndex) :
                gridDimensions.getCellBounds(rowIndex, columnIndex);
                layoutGridElementR(indicator, bounds);
                container.addElement(indicator);  // add or move to the top
                indicator.visible = true;
            }
        
        return indicator;
    }
    

    private var mouseXOffset:Number = 0;
    private var mouseYOffset:Number = 0;
       
    private function layoutHoverIndicator(container:IVisualElementContainer):void
    {        
        const rowIndex:int = grid.hoverRowIndex;
        const columnIndex:int = grid.hoverColumnIndex;
        const factory:IFactory = grid.hoverIndicator;
        hoverIndicator = layoutIndicator(container, factory, hoverIndicator, rowIndex, columnIndex); 
    }
    
    private function layoutCaretIndicator(container:IVisualElementContainer):void
    {
        const rowIndex:int = grid.caretRowIndex;
        const colIndex:int = grid.caretColumnIndex;
        const factory:IFactory = grid.caretIndicator;        
        caretIndicator = layoutIndicator(container, factory, caretIndicator, rowIndex, colIndex);        
    }
    
    //--------------------------------------------------------------------------
    //
    //  CollectionEvent handling: dataProvider, columns
    //
    //--------------------------------------------------------------------------     
    
    // TBD(hmuller): make a note about the fact that this handler runs AFTER the GridDimension
    // object has been updated.
    
    public function dataProviderCollectionChanged(event:CollectionEvent):Boolean
    {
        switch (event.kind)
        {
            case CollectionEventKind.ADD:    
                return dataProviderCollectionAdd(event);
                
            case CollectionEventKind.REMOVE: 
                return dataProviderCollectionRemove(event);
                
            case CollectionEventKind.MOVE:
                // TBD(hmuller)
                break;
            
            case CollectionEventKind.REFRESH:
            case CollectionEventKind.RESET:
                return dataProviderCollectionReset(event);
                
            case CollectionEventKind.UPDATE:
                return dataProviderCollectionUpdate(event);
            case CollectionEventKind.REPLACE:
                break;
        }
        
        return false;
    }
    
    /**
     *  @private
     *  Called in response to one or more items having been inserted into the 
     *  grid's dataProvider.  Ensure that visibleRowIndices and visibleRowSelectionIndices 
     *  correspond to the same, potentially shifted, dataProvider items.  Return true
     *  any visible index had to be changed.   
     */
    private function dataProviderCollectionAdd(event:CollectionEvent):Boolean
    {
        const insertIndex:int = event.location;
        const insertLength:int = event.items.length;
        const b1:Boolean = incrementIndicesGTE(visibleRowIndices, insertIndex, insertLength);
        const b2:Boolean = incrementIndicesGTE(visibleRowSelectionIndices, insertIndex, insertLength);
        return b1 || b2;
    }
    
    /**
     *  @private
     *  Called in response to one or more items having been removed from the 
     *  grid's dataProvider.  
     */
    private function dataProviderCollectionRemove(event:CollectionEvent):Boolean
    {
        const eventItemsLength:uint = event.items.length;
        const firstRemoveIndex:int = event.location;
        const lastRemoveIndex:int = event.location + event.items.length - 1;
        
        // Compute the range of visibleRowIndices elements affected by the remove event.
        // And while we're at it, decrement the visibleRowIndices "to the right of" the  
        // deleted items.
        
        var firstVisibleOffset:int = -1; // remove visibleRowIndices[firstVisibleOffset] 
        var lastVisibleOffset:int = -1;  // ... through visibleRowIndices[lastVisibleOffset]
        
        for (var offset:int = 0; offset < visibleRowIndices.length; offset++)
        {
            var rowIndex:int = visibleRowIndices[offset];
            if ((rowIndex >= firstRemoveIndex) && (rowIndex <= lastRemoveIndex))
            {
                if (firstVisibleOffset == -1)
                    firstVisibleOffset = lastVisibleOffset = offset;
                else
                    lastVisibleOffset = offset;
            }
            else
                visibleRowIndices[offset] = rowIndex - eventItemsLength;
        }
        
        // Remove the elements of visibleRowBackgrounds, visibleRowSeparators, visibleRowIndices,  
        // and visibleItemRenderers in the range firstVisibleOffset, lastVisibleOffset.
        
        if ((firstVisibleOffset != -1) && (lastVisibleOffset != -1))
        {
            const removeCount:int = (lastVisibleOffset - firstVisibleOffset) + 1; 
            visibleRowIndices.splice(firstVisibleOffset, removeCount);
            freeGridElements(visibleRowBackgrounds.splice(firstVisibleOffset, removeCount));
            freeGridElements(visibleRowSeparators.splice(firstVisibleOffset, removeCount));
            
            // If the last row is now visible, then the last element of visibleRowSeparators
            // should be freed and replaced by null.
            
            const maxVisibleOffset:int = visibleRowIndices.length - 1;
            if (maxVisibleOffset >= 0)
            {
                const lastRowIndex:int = gridDimensions.rowCount - 1;
                const lastRowVisible:Boolean = visibleRowIndices[maxVisibleOffset] == lastRowIndex;
                if (lastRowVisible)
                {
                    freeGridElement(visibleRowSeparators[maxVisibleOffset]);
                    visibleRowSeparators[maxVisibleOffset] = null;
                }
            }

            const visibleColCount:int = visibleColumnIndices.length;
            const firstRendererOffset:int = firstVisibleOffset * visibleColCount;
            freeItemRenderers(visibleItemRenderers.splice(firstRendererOffset, removeCount * visibleColCount));

            return true;
        }
            
        return false;        
    }    

    /**
     *  @private
     *  Increment the elements of indices that are >= insertIndex by delta.  Returns true if any
     *  element was changed.
     */
    private function incrementIndicesGTE(indices:Vector.<int>, insertIndex:int, delta:int):Boolean
    {
        var elementChanged:Boolean = false;
        const indicesLength:int = indices.length;
        for (var i:int = 0; i < indicesLength; i++)
        {
            var index:int = indices[i];
            if (index >= insertIndex)
            {
                indices[i] = index + delta;
                elementChanged = true;
            }
        }
        return elementChanged;
    }
    
    /**
     *  @private
     *  Called in response to a refresh/reset CollectionEvent.  Clear everything.
     */
    private function dataProviderCollectionReset(event:CollectionEvent):Boolean
    {
        clearVirtualLayoutCache();
        return true;
    }
    
    /**
     *  @private
     *  Called in response to an item being updated in the dataProvider. Checks
     *  to see if the item is visible and invalidates the grid if it is. Otherwise, 
     *  do nothing.
     */
    private function dataProviderCollectionUpdate(event:CollectionEvent):Boolean
    {
        var data:Object;
        const itemsLength:int = event.items.length;
        const itemRenderersLength:int = visibleItemRenderers.length;
        
        for (var i:int = 0; i < itemsLength; i++)
        {
            data = PropertyChangeEvent(event.items[i]).source;
            
            for (var j:int = 0; j < itemRenderersLength; j++)
            {
                var renderer:IGridItemRenderer = visibleItemRenderers[j] as IGridItemRenderer;
                if (renderer && renderer.data == data)
                {
                    this.freeItemRenderer(renderer);
                    visibleItemRenderers[j] = null;
                }
            }
        }
        return true;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Grid Elements
    //
    //--------------------------------------------------------------------------     
    
    /**
     *  @private
     *  The elements currently "in use".
     * 
     *  Maps from an IFactory to a list of the elements allocated by that factory.
     *  The list is represented by a Vector.<IVisualElement>.
     */
    private const allocatedElementMap:Dictionary = new Dictionary();  // TBD: should be weak refs here?
    
    /**
     *  @private
     *  The elements available for reuse.
     * 
     *  Maps from an IFactory to a list of the elements that have been allocated by that factory
     *  and then freed.   The list is represented by a Vector.<IVisualElement>.
     */
    private const freeElementMap:Dictionary = new Dictionary();  // and here?
    
    /**
     *  @private
     *  Records the IFactory used to allocate a Element so that free(Element)
     *  can find it again.
     */
    private const elementToFactoryMap:Dictionary = new Dictionary();  // and here?
    
    private function createGridElement(factory:IFactory):IVisualElement
    {
        const element:IVisualElement = factory.newInstance() as IVisualElement;
        elementToFactoryMap[element] = factory;
        
        var elements:Vector.<IVisualElement> = allocatedElementMap[factory];
        if (!elements)
        {
            elements = new Vector.<IVisualElement>();
            allocatedElementMap[factory] = elements;     
        }
        elements.push(element);
        
        return element;
    }
    
    private function allocateGridElement(factory:IFactory):IVisualElement
    {
        const elements:Vector.<IVisualElement> = freeElementMap[factory] as Vector.<IVisualElement>;
        if (elements)
        {
            const element:IVisualElement = elements.pop();
            if (elements.length == 0)
                delete freeElementMap[factory];
            if (element)
                return element;
        }
        
        return createGridElement(factory);
    }
    
    /**
     *  Move the specified element to the free list after hiding it.  Return true if the 
     *  element was added to the free list (freeElements).
     */
    private function freeGridElement(element:IVisualElement):Boolean
    {
        if (!element)
            return false;
        
        element.visible = false;
        
        // Reset GridItemRenderers back to (0,0), otherwise when the element is reused
        // it will be validated at its last layout size which causes problems with 
        // text reflow.
        
        if (element is GridItemRenderer)
            element.setLayoutBoundsSize(0, 0, false);        
        
        const factory:IFactory = elementToFactoryMap[element]; 
        if (!factory)
            return false;
        
        // Remove the element from allocatedElementMap and then clear it
        
        const elements:Vector.<IVisualElement> = allocatedElementMap[factory];
        if (elements)
        {
            const index:int = elements.indexOf(element);
            if (index != -1)
                elements.splice(index, 1);
            if (elements.length == 0)
                delete allocatedElementMap[factory];
        }
        
        // Add the renderer to the freeElementMap
        
        var freeElements:Vector.<IVisualElement> = freeElementMap[factory];
        if (!freeElements)
        {
            freeElements = new Vector.<IVisualElement>();
            freeElementMap[factory] = freeElements;            
        }
        freeElements.push(element);
        
        return true;
    }

    private function freeGridElements (elements:Vector.<IVisualElement>):void
    {
        for each (var elt:IVisualElement in elements)
            freeGridElement(elt);
        elements.length = 0;
    }      
    
    private function removeGridElement(element:IVisualElement):void
    {
        // TBD
    }
    
    /**
     *  @private
     *  By default, this method uses the same approach as DataGroup/getVirtualElementAt() for elements
     *  that implement IInvalidating: elt.validateNow(), elt.setLayoutBoundsSize(), elt.validateNow().
     *  This is supposed to eliminate problems with (text) components that defer reflow until the next
     *  updateDisplayList() pass.
     *  
     *  Since doing so is rather expensive, we economize when the renderer is a DefaultGridItemRenderer,
     *  since UITextField reflows synchronously.
     */ 
    private function layoutItemRenderer(elt:IVisualElement, x:Number, y:Number, width:Number, height:Number):void
    {
        var startTime:Number;
        if (enablePerformanceStatistics)
            startTime = getTimer();
        
        if (elt is DefaultGridItemRenderer)
        {
            if (!isNaN(width) || !isNaN(height))            
                elt.setLayoutBoundsSize(width, height);
            DefaultGridItemRenderer(elt).validateNow();
        }
        else
        {
            const validatingElt:IInvalidating = elt as IInvalidating;
            if (!isNaN(width) || !isNaN(height))
            {
                if (validatingElt)
                    validatingElt.validateNow();
                elt.setLayoutBoundsSize(width, height);
            }
            if (validatingElt)        
                validatingElt.validateNow();
        }
        
        elt.setLayoutBoundsPosition(x, y);
        
        if (enablePerformanceStatistics)
        {
            var elapsedTime:Number = getTimer() - startTime;
            performanceStatistics.layoutGridElementTimes.push(elapsedTime);            
        }
    }

    private function layoutGridElementR(elt:IVisualElement, bounds:Rectangle):void
    {
        if (bounds)
        {
            elt.setLayoutBoundsSize(bounds.width, bounds.height);
            elt.setLayoutBoundsPosition(bounds.x, bounds.y);
        }
    }
    
    private function layoutGridElement(elt:IVisualElement, x:Number, y:Number, width:Number, height:Number):void
    {
        elt.setLayoutBoundsSize(width, height);
        elt.setLayoutBoundsPosition(x, y);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Public API Exported for Grid Cover Methods 
    //
    //--------------------------------------------------------------------------

    /**
     *  Return the dataProvider indices of the currently visible rows.  Note that the 
     *  item renderers for the first and last rows may only be partially visible.  The 
     *  returned vector's contents are in the order they're displayed.
     * 
     *  @return A vector of the visible row indices.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */ 
    public function getVisibleRowIndices():Vector.<int>
    {
        return visibleRowIndices.concat();
    }
    
    /**
     *  Return the indices of the currently visible columns.  Note that the 
     *  item renderers for the first and last columns may only be partially visible.  The 
     *  returned vector's contents are in the order they're displayed.
     * 
     *  <p>The following example function uses this method to compute a vector of 
     *  visible GridColumn objects.</p>
     *  <pre>
     *  function getVisibleColumns():Vector.&lt;GridColumn&gt;
     *  {
     *      var visibleColumns = new Vector.&lt;GridColumn&gt;;
     *      for each (var columnIndex:int in grid.getVisibleColumnIndices())
     *          visibleColumns.push(grid.columns.getItemAt(columnIndex));
     *      return visibleColumns;
     *  }
     *  </pre> 
     * 
     *  @return A vector of the visible column indices.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */ 
    public function getVisibleColumnIndices():Vector.<int>
    {
        return visibleColumnIndices.concat();
    }
    
    /**
     *  Returns the current pixel bounds of the specified cell, or null if no such cell exists.
     *  Cell bounds are reported in grid coordinates.
     * 
     *  <p>If all of the columns for the the specfied row and all of the rows preceeding 
     *  it have not yet been scrolled into view, the returned bounds may only be an approximation, 
     *  based on all of the columns' <code>typicalItem</code>s.</p>
     * 
     *  @param rowIndex The 0-based index of the row.
     *  @param columnIndex The 0-based index of the column. 
     *  @return A <code>Rectangle</code> that represents the cell's pixel bounds, or null.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */ 
    public function getCellBounds(rowIndex:int, columnIndex:int):Rectangle
    {
        return gridDimensions.getCellBounds(rowIndex, columnIndex);
    }

    /**
     *  Returns the current pixel bounds of the specified row, or null if no such row exists.
     *  Row bounds are reported in grid coordinates.

     *  <p>If all of the columns for the the specfied row and all of the rows preceeding 
     *  it have not yet been scrolled into view, the returned bounds may only be an approximation, 
     *  based on all of the columns' <code>typicalItem</code>s.</p>
     * 
     *  @param rowIndex The 0-based index of the row.
     *  @return A <code>Rectangle</code> that represents the row's pixel bounds, or null.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */
    public function getRowBounds(rowIndex:int):Rectangle
    {
        return gridDimensions.getRowBounds(rowIndex);        
    }

    /**
     *  Returns the current pixel bounds of the specified column, or null if no such column exists.
     *  Column bounds are reported in grid coordinates.
     * 
     *  <p>If all of the cells in the specified column have not yet been scrolled into view, the 
     *  returned bounds may only be an approximation, based on the column's <code>typicalItem</code>.</p>
     *  
     *  @param columnIndex The 0-based index of the column. 
     *  @return A <code>Rectangle</code> that represents the column's pixel bounds, or null.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getColumnBounds(columnIndex:int):Rectangle
    {
        return gridDimensions.getColumnBounds(columnIndex); 
    }

    /**
     *  Returns the row index corresponding to the specified coordinates,
     *  or -1 if the coordinates are out of bounds. The coordinates are 
     *  resolved with respect to the grid.
     * 
     *  <p>If all of the columns or rows for the grid have not yet been scrolled
     *  into view, the returned index may only be an approximation, 
     *  based on all of the columns' <code>typicalItem</code>s.</p>
     *  
     *  @param x The x coordinate.
     *  @param y The y coordinate.
     *  @return The index of the row corresponding to the specified coordinates.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getRowIndexAt(x:Number, y:Number):int
    {
        return gridDimensions.getRowIndexAt(x, y); 
    }
    
    /**
     *  Returns the column index corresponding to the specified coordinates,
     *  or -1 if the coordinates are out of bounds. The coordinates are 
     *  resolved with respect to the grid.
     * 
     *  <p>If all of the columns or rows for the grid have not yet been scrolled
     *  into view, the returned index may only be an approximation, 
     *  based on all of the columns' <code>typicalItem</code>s.</p>
     *  
     *  @param x The pixel's x coordinate relative to the grid.
     *  @param y The pixel's y coordinate relative to the grid.
     *  @return the index of the column or -1 if the coordinates are out of bounds. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getColumnIndexAt(x:Number, y:Number):int
    {
        return gridDimensions.getColumnIndexAt(x, y); 
    }
        
    /**
     *  Return the row and column indices of the cell that overlaps the pixel at the 
     *  specified grid coordinate as an Object with "rowIndex" and "columnIndex" properties.  
     *  If no such cell exists, null is returned.
     * 
     *  <p>The example function below uses this method to compute the value of the 
     *  <code>dataField</code> for a grid cell.</p> 
     *  <pre>
     *  function getCellData(x:Number, y:Number):Object
     *  {
     *      var cell:Object = getCellAt(x, y);
     *      if (!cell)
     *          return null;
     *      var GridColumn:column = grid.columns.getItemAt(cell.columnIndex);
     *      return grid.dataProvider[cell.rowIndex][column.dataField];
     *  }
     *  </pre> 
     * 
     *  @param x The pixel's x coordinate relative to the grid.
     *  @param y The pixel's y coordinate relative to the grid.
     *  @return An object like <code>{rowIndex:0, columnIndex:0}</code> or null. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getCellAt(x:Number, y:Number):Object
    {
        const rowIndex:int = gridDimensions.getRowIndexAt(x, y);
        const columnIndex:int = gridDimensions.getColumnIndexAt(x, y);
        if ((rowIndex == -1) || (columnIndex == -1))
            return null;
        return {rowIndex:rowIndex, columnIndex:columnIndex};
    }

    /**
     *  Returns a vector of CellPosition objects whose "rowIndex" and "columnIndex" properties specify the 
     *  row and column indices of the cells that overlap the specified grid region.  If no
     *  such cells exist, an empty vector is returned.
     *  
     *  @param x The x coordinate of the pixel at the origin of the region, relative to the grid.
     *  @param x The x coordinate of the pixel at the origin of the region, relative to the grid. 
     *  @return A vector of objects like <code>Vector.&lt;Object&gt;([{rowIndex:0, columnIndex:0}, ...])</code>. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getCellsAt(x:Number, y:Number, w:Number, h:Number):Vector.<CellPosition>
    { 
        // TBD(hmuller)
        return new Vector.<Object>;
    }

    
    /**
     *  Returns a reference to the item renderer currently displayed at the 
     *  specified cell.  If the requested item renderer is not visible then 
     *  (each time this method is called) a new item renderer is created.  If 
     *  the specified is invalid, e.g. if <code>rowIndex == -1</code>, 
     *  then null is returned.
     * 
     *  @param rowIndex The 0-based row index of the item renderer's cell.
     *  @param columnIndex The 0-based column index of the item renderer's cell.
     *  @return The item renderer
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getItemRendererAt(rowIndex:int, columnIndex:int):IVisualElement
    {
        const visibleItemRenderer:IVisualElement = getVisibleItemRenderer(rowIndex, columnIndex);
        if (visibleItemRenderer)
            return visibleItemRenderer;
        // TBD(hmuller): create an item renderer
        return null;
    }
    
    /**
     *  True if the specified cell is at least partially visible.  If columnIndex == -1 then 
     *  true is returned if the specified row is at least partially visible.
     *  
     *  @param rowIndex The 0-based row index of the item renderer's cell.
     *  @param columnIndex The 0-based column index of the item renderer's cell.
     *  @return True if the specified cell (or row if columnIndex == -1) is at least partially visible
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */ 
    public function isCellVisible(rowIndex:int, columnIndex:int):Boolean
    {
        return (visibleRowIndices.indexOf(rowIndex) != -1) && 
            ((columnIndex == -1) || (visibleColumnIndices.indexOf(columnIndex) != -1));
    }
    
    //--------------------------------------------------------------------------
    //
    //  Performance Statistics
    //
    //--------------------------------------------------------------------------   
    
    //----------------------------------
    //  performanceStatistics
    //----------------------------------
    
    private var _performanceStatistics:Object = null;
    
    /**
     *  @private
     *  The value of this object, if enablePerformanceStatistics == true, is an 
     *  object with the following properties:
     *
     *  updateDisplayListStartTime:Number
     *  updateDisplayListEndTime:Number
     *    The getTimer() value for start of the first updateDisplayList() call
     *    and the end of the last one.   These values can be used to compute an
     *    effective frame rate if Grid is continuously scrolled while
     *    enablePerformanceStatistics is true.
     *     
     *  updateDisplayListTimes:Vector.<Number>
     *    The elapsed time in ms for each updateDisplayList() call since 
     *    enablePerformanceStatistics was set to true.
     *  
     *  updateDisplayListRectangles:Vector.<Rectangle>
     *    The value of visibleGridBounds for each udpateDisplayList() call.
     * 
     *  updateDisplayListCellCounts:Vector.<int>
     *    The number of cells rendered in each updateDisplayList() call.
     * 
     *  layoutGridElementTimes:Vector.<Number>
     *    Execution times for the layoutGridElement() method.  This method is
     *    responsible for applying validateNow() to item renderers.
     * 
     *  measureTimes:Vector.<Number>
     *    The elapsed time in ms for each measure() call since 
     *    enablePerformanceStatistics was set to true.
     */
    public function get performanceStatistics():Object
    {
        return _performanceStatistics;
    }
    
    //----------------------------------
    //  enablePerformanceStatistics
    //----------------------------------
    
    private var _enablePerformanceStatistics:Boolean = false;
    
    /**
     *  @private
     *  When set to true the GridLayout implementation starts recording statistics
     *  per the performanceStatistics property.   When set to null (the default),
     *  recording stops.
     */
    public function get enablePerformanceStatistics():Boolean
    {
        return _enablePerformanceStatistics;
    }
    
    /**
     *  @private
     */
    public function set enablePerformanceStatistics(value:Boolean):void
    {
        if (value == _enablePerformanceStatistics)
            return;
    
        if (value)
            _performanceStatistics = {
                updateDisplayListTimes: new Vector.<Number>(),
                updateDisplayListRectangles: new Vector.<Rectangle>(),
                updateDisplayListCellCounts: new Vector.<int>(),                
                measureTimes: new Vector.<Number>(),             
                layoutGridElementTimes: new Vector.<Number>()                
            };
        
        _enablePerformanceStatistics = value;
    }

}
}
