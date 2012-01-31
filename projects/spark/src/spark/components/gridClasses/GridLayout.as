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
import flash.utils.getTimer;

import mx.collections.IList;
import mx.core.ClassFactory;
import mx.core.IFactory;
import mx.core.IInvalidating;
import mx.core.IUITextField;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.Singleton;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.PropertyChangeEvent;
import mx.managers.ILayoutManagerClient;
import mx.managers.LayoutManager;

import spark.components.DataGrid;
import spark.components.Grid;
import spark.core.IGraphicElement;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 *  A virtual two dimensional layout for the Grid class.   This is not a general purpose layout,
 *  it's only intended to be use with Grid.
 */
public class GridLayout extends LayoutBase
{
    include "../../core/Version.as";    

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //-------------------------------------------------------------------------- 

    // TBD: lazily create this so that if it's replaced we don't needlessly create two.
    // Perhaps it should be a constructor parameter.   That way there's no need to sort
    // out how to migrate data from the old GLC to the new one.
    // Note also: if this was going to be shared, it should arrive as a constructor parameter.
    public var gridDimensions:GridDimensions;
    
    /**
     *  @private
     *  The following variables define the visible part of the grid, where each item
     *  renderer typically displays dataProvider[rowIndex][columns[columnIndex]].dataField.
     *  The index vectors are sorted in increasing order but their items may not be
     *  sequential. 
     */
    private var visibleRowIndices:Vector.<int> = new Vector.<int>(0);
    private var visibleColumnIndices:Vector.<int> = new Vector.<int>(0); 
    
    /**
     *  @private
     *  The previous values of the corresponding variables.   Set by layoutItemRenderers()
     *  and only valid during updateDisplayList(), for a complete relayout.
     */
    private var oldVisibleRowIndices:Vector.<int> = new Vector.<int>(0);
    private var oldVisibleColumnIndices:Vector.<int> = new Vector.<int>(0);
        
    /** 
     *  TODO (hmuller): document how do these vectors relate to visibleRow,ColumnIndices
     */
    private var visibleRowBackgrounds:Vector.<IVisualElement> = new Vector.<IVisualElement>(0);
    private var visibleRowSeparators:Vector.<IVisualElement> = new Vector.<IVisualElement>(0);
    private var visibleColumnSeparators:Vector.<IVisualElement> = new Vector.<IVisualElement>(0);
    private var visibleItemRenderers:Vector.<IGridItemRenderer> = new Vector.<IGridItemRenderer>(0);
    
    /** 
     *  TODO (hmuller): provide documentation
     */
    private var hoverIndicator:IVisualElement = null;
    private var caretIndicator:IVisualElement = null;
    private var editorIndicator:IVisualElement = null;
    
    /**
     *  @private
     *  The bounding rectangle for all of the visible item renderers.  Note that this
     *  rectangle may be larger than the scrollRect, since the first/last rows/columns
     *  of item renderers may only be partially visible.   See scrollPositionChanged().
     */
    private const visibleItemRenderersBounds:Rectangle = new Rectangle();
    
    /**
     *  @private
     *  The viewport's bounding rectangle; often smaller then visibleItemRenderersBounds.
     *  Initialized by updateDisplayList with the current scrollPosition, and grid.width,Height.
     */
    private const visibleGridBounds:Rectangle = new Rectangle();
    
    /**
     *  @private
     *  The elements available for reuse.  Maps from an IFactory to a list of the elements 
     *  that have been allocated by that factory and then freed.   The list is represented 
     *  by a Vector.<IVisualElement>.
     * 
     *  Updated by allocateGridElement().
     */
    private const freeElementMap:Dictionary = new Dictionary();
    
    /**
     *  @private
     *  Records the IFactory used to allocate a Element so that free(Element) can find it again.
     * 
     *  Updated by createGridElement().
     */
    private const elementToFactoryMap:Dictionary = new Dictionary();
    
    /**
     *  @private
     *  Used by scrollPositionChanged() to determine which scroll position properties changed.
     */    
    private var oldVerticalScrollPosition:Number = 0;
    private var oldHorizontalScrollPosition:Number = 0;
    
    //--------------------------------------------------------------------------
    //
    //  Class methods and properties
    //
    //-------------------------------------------------------------------------- 
    
    /**
     *  @private
     *  The static embeddedFontsRegistryExists property is initialized lazily. 
     */
    private static var  _embeddedFontRegistryExists:Boolean = false;
    private static var embeddedFontRegistryExistsInitialized:Boolean = false;
    
    /**
     *  @private
     *  True if an embedded font registry singleton exists.
     */
    private static function get embeddedFontRegistryExists():Boolean
    {
        if (!embeddedFontRegistryExistsInitialized)
        {
            embeddedFontRegistryExistsInitialized = true;
            try
            {
                _embeddedFontRegistryExists = Singleton.getInstance("mx.core::IEmbeddedFontRegistry") != null;
            }
            catch (e:Error)
            {
                _embeddedFontRegistryExists = false;
            }
        }
        
        return _embeddedFontRegistryExists;
    }    
    
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
     *  @playerversion AIR 2.4
     *  @productversion Flex 4.5
     */    
    public function GridLayout()
    {
        super();
        gridDimensions = new GridDimensions();
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
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  showCaret
    //----------------------------------
    
    /**
     *  @private
     */
    private var _showCaret:Boolean = false;
    
    /**
     *  Determines if the caret is visible.
     */
    public function get showCaret():Boolean
    {
        return _showCaret;
    }

    /**
     *  @private
     */
    public function set showCaret(show:Boolean):void
    {
        if (caretIndicator)
            caretIndicator.visible = show;
        
        _showCaret = show;
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
        
        freeGridElements(visibleColumnSeparators);        
        visibleColumnIndices.length = 0;
        
        freeItemRenderers(visibleItemRenderers);
        
        clearSelectionIndicators();
        
        freeGridElement(hoverIndicator)
        hoverIndicator = null;
        
        freeGridElement(caretIndicator);
        caretIndicator = null;
        
        freeGridElement(editorIndicator);
        editorIndicator = null;
        
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
        const columns:IList = (grid) ? grid.columns : null;
        if (!columns) 
            return null;
        
        const columnsLength:uint = columns.length;
        const rowIndex:int = index / columnsLength;
        const columnIndex:int = index - (rowIndex * columnsLength);
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
        
        const hspChanged:Boolean = oldHorizontalScrollPosition != horizontalScrollPosition;
        const vspChanged:Boolean = oldVerticalScrollPosition != verticalScrollPosition;
        
        oldHorizontalScrollPosition = horizontalScrollPosition;
        oldVerticalScrollPosition = verticalScrollPosition;
        
        // Only invalidate if we're clipping and rows and/or columns covered
		// by the scrollR changes.  If so, the visible row/column indicies need
		// to be updated.
        
		var invalidate:Boolean;
		
		if (visibleRowIndices.length == 0 || visibleColumnIndices.length == 0)
			invalidate = true;
		
		if (!invalidate && vspChanged)
		{
			const oldFirstRowIndex:int = visibleRowIndices[0];
			const oldLastRowIndex:int = visibleRowIndices[visibleRowIndices.length - 1];
			
			const newFirstRowIndex:int = 
				gridDimensions.getRowIndexAt(horizontalScrollPosition, verticalScrollPosition);
			const newLastRowIndex:int = 
				gridDimensions.getRowIndexAt(horizontalScrollPosition, verticalScrollPosition + target.height);
			
			if (oldFirstRowIndex != newFirstRowIndex || oldLastRowIndex != newLastRowIndex)
				invalidate = true;
		}
		
		if (!invalidate && hspChanged)
		{
			const oldFirstColIndex:int = visibleColumnIndices[0];			
			const oldLastColIndex:int = visibleColumnIndices[visibleColumnIndices.length - 1];
			
			const newFirstColIndex:int = 
				gridDimensions.getColumnIndexAt(horizontalScrollPosition, verticalScrollPosition);
			const newLastColIndex:int = 
				gridDimensions.getColumnIndexAt(horizontalScrollPosition + target.width, verticalScrollPosition);
			
			if (oldFirstColIndex != newFirstColIndex || oldLastColIndex != newLastColIndex)
				invalidate = true;
		}
		
		if (invalidate)
        {
            var reason:String = "none";
            if (vspChanged && hspChanged)
                reason = "bothScrollPositions";
            else if (vspChanged)
                reason = "verticalScrollPosition"
            else if (hspChanged)
                reason = "horizontalScrollPosition";
            
            grid.invalidateDisplayListFor(reason);
        }
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
        
        updateTypicalCellSizes();
        
        var measuredRowCount:int = grid.requestedRowCount;
        if (measuredRowCount == -1)
        {
            const rowCount:int = gridDimensions.rowCount;
            if (grid.requestedMaxRowCount != -1)
                measuredRowCount = Math.min(grid.requestedMaxRowCount, rowCount);
            if (grid.requestedMinRowCount != -1)
                measuredRowCount = Math.max(grid.requestedMinRowCount, measuredRowCount);                
        }
        
        var measuredWidth:Number = gridDimensions.getTypicalContentWidth(grid.requestedColumnCount);
        var measuredHeight:Number = gridDimensions.getTypicalContentHeight(measuredRowCount);
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
        
        // Find the index of the last GridColumn.visible==true column
        
        const columns:IList = grid.columns;
        const lastVisibleColumnIndex:int = (columns) ? grid.getPreviousVisibleColumnIndex(grid.columns.length) : -1;
        if (!columns || lastVisibleColumnIndex < 0)
            return;
        
        // Layers
        
        const backgroundLayer:GridLayer = getLayer("backgroundLayer");
        const selectionLayer:GridLayer = getLayer("selectionLayer");    
        const editorIndicatorLayer:GridLayer = getLayer("editorIndicatorLayer");
        const rendererLayer:GridLayer = getLayer("rendererLayer");
        const overlayLayer:GridLayer = getLayer("overlayLayer"); 
        
        // Relayout everything if the scroll position changed or if no 
        // "invalidateDisplayList reason" was specified.  See
        // Grid/invalidateDisplayListFor(reason)
        
        const completeLayoutNeeded:Boolean = 
            grid.isInvalidateDisplayListReason("verticalScrollPosition") ||
            grid.isInvalidateDisplayListReason("horizontalScrollPosition");
            
        
        // Layout the columns and item renderers; compute new values for visibleRowIndices et al.
        
        if (completeLayoutNeeded)
        {
            oldVisibleRowIndices = visibleRowIndices;
            oldVisibleColumnIndices = visibleColumnIndices;
            
            // Determine the x/y position of the visible content.  Note that the 
            // actual scroll positions may be negative.
            
            const scrollX:Number = Math.max(0, horizontalScrollPosition);
            const scrollY:Number = Math.max(0, verticalScrollPosition);
            
            visibleGridBounds.x = scrollX;
            visibleGridBounds.y = scrollY;
            visibleGridBounds.width = unscaledWidth;
            visibleGridBounds.height = unscaledHeight;
            
            layoutColumns(scrollX, scrollY, unscaledWidth);
            layoutItemRenderers(rendererLayer, scrollX, scrollY, unscaledWidth, unscaledHeight);
            
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
            
            visibleRowBackgrounds = layoutLinearElements(grid.rowBackground, backgroundLayer,
                visibleRowBackgrounds, oldVisibleRowIndices, visibleRowIndices, layoutRowBackground);
    
            // Layout the row and column separators. 
            
            const lastRowIndex:int = paddedRowCount - 1;
    
            visibleRowSeparators = layoutLinearElements(grid.rowSeparator, overlayLayer, 
                visibleRowSeparators, oldVisibleRowIndices, visibleRowIndices, layoutRowSeparator, lastRowIndex);
            
            visibleColumnSeparators = layoutLinearElements(grid.columnSeparator, overlayLayer, 
                visibleColumnSeparators, oldVisibleColumnIndices, visibleColumnIndices, layoutColumnSeparator, lastVisibleColumnIndex);
            
            
            // The old visible row,column indices are no longer needed
            
            oldVisibleRowIndices.length = 0;
            oldVisibleColumnIndices.length = 0;            
        }
        
        // Layout the hoverIndicator, caretIndicator, and selectionIndicators        
        
        if (completeLayoutNeeded || grid.isInvalidateDisplayListReason("hoverIndicator"))
            layoutHoverIndicator(backgroundLayer);
        
        if (completeLayoutNeeded || grid.isInvalidateDisplayListReason("selectionIndicator"))
            layoutSelectionIndicators(selectionLayer);
        
        if (completeLayoutNeeded || grid.isInvalidateDisplayListReason("caretIndicator"))
            layoutCaretIndicator(overlayLayer);
        
        if (completeLayoutNeeded || grid.isInvalidateDisplayListReason("editorIndicator"))
            layoutEditorIndicator(editorIndicatorLayer);
        
        if (!completeLayoutNeeded)
            updateVisibleItemRenderers();
        
        // To avoid flashing, force all of the layers to render now
        
        grid.validateNow();
                
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
    
    /** 
     *  @private
     *  Reset the selected, showsCaret, and hovered properties for all visible item renderers.
     *  Run the prepare() method for renderers that have changed.
     * 
     *  This method is only called when the item renderers are not updated as part of a general
     *  redisplay, by layoutItemRenderers(). 
     */
    private function updateVisibleItemRenderers():void
    {
        const grid:Grid = grid;  // avoid get method cost
        const rowSelectionMode:Boolean = isRowSelectionMode();
        const cellSelectionMode:Boolean = isCellSelectionMode();
        
        if (!rowSelectionMode && !cellSelectionMode)
            return;
        
        for each (var renderer:IGridItemRenderer in visibleItemRenderers)            
        {
            var rowIndex:int = renderer.rowIndex;
            var columnIndex:int = renderer.columnIndex;
            
            var oldSelected:Boolean  = renderer.selected;
            var oldShowsCaret:Boolean = renderer.showsCaret;
            var oldHovered:Boolean = renderer.hovered;
            
            // The following initializations should match what's done in initializeItemRenderer()
            if (rowSelectionMode)
            {                
                renderer.selected = grid.selectionContainsIndex(rowIndex);
                renderer.showsCaret = grid.caretRowIndex == rowIndex;
                renderer.hovered = grid.hoverRowIndex == rowIndex;
            }
            else if (cellSelectionMode)
            {
                renderer.selected = grid.selectionContainsCell(rowIndex, columnIndex);
                renderer.showsCaret = (grid.caretRowIndex == rowIndex) && (grid.caretColumnIndex == columnIndex);
                renderer.hovered = (grid.hoverRowIndex == rowIndex) && (grid.hoverColumnIndex == columnIndex);                    
            }
            
            if ((oldSelected != renderer.selected) || 
                (oldShowsCaret != renderer.showsCaret) || 
                (oldHovered != renderer.hovered))
                renderer.prepare(true);
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
    
    private function getLayer(name:String):GridLayer
    {
        const grid:Grid = target as Grid;
        if (!grid)
            return null;
        
        return grid.getChildByName(name) as GridLayer;
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
    
    //--------------------------------------------------------------------------
    //
    //  Updating the GridDimensions' typicalCell sizes and columnWidths
    //
    //-------------------------------------------------------------------------- 
    
    /**
     *  @private
     *  Return width clamped to the column's minWidth and maxWidth properties.
     */
    private static function clampColumnWidth(width:Number, column:GridColumn):Number
    {
       const minColumnWidth:Number = column.minWidth;
       const maxColumnWidth:Number = column.maxWidth;
       
       if (!isNaN(minColumnWidth))
           width = Math.max(width, minColumnWidth);
       if (!isNaN(maxColumnWidth))
           width = Math.min(width, maxColumnWidth);
       
       return width;
    }
    
    /**
     *  @private
     *  Use the specified GridColumn's itemRenderer (IFactory) to create a temporary
     *  item renderer.   The returned item renderer must be freed, with freeGridElement(),
     *  and removed from the rendererLayer after it's used.
     */
    private function createTypicalItemRenderer(columnIndex:int):IGridItemRenderer
    {
        const rendererLayer:GridLayer = getLayer("rendererLayer");
        if (!rendererLayer)
            return null;
        
        var typicalItem:Object = grid.typicalItem;
        if (typicalItem == null)
            typicalItem = getDataProviderItem(0);
        
        const column:GridColumn = getGridColumn(columnIndex);
        const factory:IFactory = itemToRenderer(column, typicalItem);
        const renderer:IGridItemRenderer = allocateGridElement(factory) as IGridItemRenderer;
        
        rendererLayer.addElement(renderer);

        initializeItemRenderer(renderer, 0 /* rowIndex */, columnIndex, grid.typicalItem, false);
        
        // If the column's width isn't specified, then use the renderer's explicit
        // width, if any.   If that isn't specified, then use 4096, to avoid wrapping.
        
        var columnWidth:Number = column.width;
        
        if (isNaN(columnWidth))
        {
            // Sadly, IUIComponent, UITextField, and UIFTETextField all have an 
            // explicitWidth property but do not share a common type.  
            if ("explicitWidth" in renderer)
                columnWidth = Object(renderer).explicitWidth;
        }
        
        // The default width of a UI[FTE]TextField is 100.  If autoWrap is true, and
        // multiline is true, the measured text will wrap if it is wider than
        // the TextField's width. This is not what we want when measuring the 
        // width of typicalItem columns that lack an explicit column width.
        
        if (isNaN(columnWidth))
            columnWidth = 4096;
        
        layoutItemRenderer(renderer, 0, 0, columnWidth, NaN);
  
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
     */
    private function updateVisibleTypicalCellSizes(width:Number, scrollX:Number, firstVisibleColumnIndex:int):void
    {
        const rendererLayer:GridLayer = getLayer("rendererLayer");
        if (!rendererLayer)
            return;        
        
        const gridDimensions:GridDimensions = gridDimensions;
        const columnCount:int = gridDimensions.columnCount;
        const startCellX:Number = gridDimensions.getCellX(0 /* rowIndex */, firstVisibleColumnIndex);
        const columnGap:int = gridDimensions.columnGap;
        
        for (var columnIndex:int = firstVisibleColumnIndex;
            (width > 0) && (columnIndex >= 0) && (columnIndex < columnCount);
            columnIndex = grid.getNextVisibleColumnIndex(columnIndex))
        {
            var cellHeight:Number = gridDimensions.getTypicalCellHeight(columnIndex);
            var cellWidth:Number = gridDimensions.getTypicalCellWidth(columnIndex);
            
            var column:GridColumn = getGridColumn(columnIndex);
            if (!isNaN(column.width))
            {
                cellWidth = column.width;
                gridDimensions.setTypicalCellWidth(columnIndex, cellWidth);
            }
            
            if (isNaN(cellWidth) || isNaN(cellHeight))
            {
                var renderer:IGridItemRenderer = createTypicalItemRenderer(columnIndex);
                if (isNaN(cellWidth))
                {
                    cellWidth = clampColumnWidth(renderer.getPreferredBoundsWidth(), column);
                    gridDimensions.setTypicalCellWidth(columnIndex, cellWidth);
                }
                if (isNaN(cellHeight))
                {
                    cellHeight = renderer.getPreferredBoundsHeight();
                    gridDimensions.setTypicalCellHeight(columnIndex, cellHeight);
                }
                
                rendererLayer.removeElement(renderer);                
                freeGridElement(renderer);
            }
            
            if (columnIndex == firstVisibleColumnIndex)
                width -= startCellX + cellWidth - scrollX;
            else
                width -= cellWidth + columnGap;
        }
    }
    
    /**
     *  @private
     *  Used by the measure() method to initialize the GridDimensions typical width,height of 
     *  requestedColumnCount columns, and the typical width of *all* columns with an explicit width.
     */
    private function updateTypicalCellSizes():void
    {
        const rendererLayer:GridLayer = getLayer("rendererLayer");
        if (!rendererLayer)
            return;  
        
        const gridDimensions:GridDimensions = gridDimensions;
        const columnCount:int = gridDimensions.columnCount;
        const columnGap:int = gridDimensions.columnGap;
        const requestedColumnCount:int = grid.requestedColumnCount;
        var measuredColumnCount:int = 0;
        
        for (var columnIndex:int = 0; (columnIndex < columnCount); columnIndex++)
        {
            var cellHeight:Number = gridDimensions.getTypicalCellHeight(columnIndex);
            var cellWidth:Number = gridDimensions.getTypicalCellWidth(columnIndex);
            
            var column:GridColumn = getGridColumn(columnIndex);
            
            // GridColumn.visible==false columns have a typical size of (0,0)
            // to distinguish them from the GridColumn.visible==true columns
            // that aren't in view yet.
            
            if (!column.visible)
            {
                gridDimensions.setTypicalCellWidth(columnIndex, 0);
                gridDimensions.setTypicalCellHeight(columnIndex, 0);
                continue;
            }
            
            if (!isNaN(column.width))
            {
                cellWidth = column.width;
                gridDimensions.setTypicalCellWidth(columnIndex, cellWidth);
            }
            
            var needTypicalRenderer:Boolean = (requestedColumnCount == -1) || (measuredColumnCount < requestedColumnCount);
            if (needTypicalRenderer && (isNaN(cellWidth) || isNaN(cellHeight)))
            {
                var renderer:IGridItemRenderer = createTypicalItemRenderer(columnIndex);
                if (isNaN(cellWidth))
                {
                    cellWidth = clampColumnWidth(renderer.getPreferredBoundsWidth(), column);
                    gridDimensions.setTypicalCellWidth(columnIndex, cellWidth);
                }
                if (isNaN(cellHeight))
                {
                    cellHeight = renderer.getPreferredBoundsHeight();
                    gridDimensions.setTypicalCellHeight(columnIndex, cellHeight);
                }
                
                rendererLayer.removeElement(renderer);
                freeGridElement(renderer);
            }
            measuredColumnCount++;
        }
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
        
        // Update the GridDimensions typicalCellWidth,Height values as needed.

        const firstVisibleColumnIndex:int = gridDimensions.getColumnIndexAt(scrollX, scrollY);
        updateVisibleTypicalCellSizes(width, scrollX, firstVisibleColumnIndex);
        
        // Set the GridDimensions columnWidth for no more than columnCount columns.
        
        const columnGap:int = gridDimensions.columnGap;
        const startCellX:Number = gridDimensions.getCellX(0 /* rowIndex */, firstVisibleColumnIndex);
        var availableWidth:Number = width;
        var flexibleColumnCount:uint = 0;
        
        for (var columnIndex:int = firstVisibleColumnIndex;
             (availableWidth > 0) && (columnIndex >= 0) && (columnIndex < columnCount);
             columnIndex = grid.getNextVisibleColumnIndex(columnIndex))
        {
            var columnWidth:Number = gridDimensions.getTypicalCellWidth(columnIndex);
            var gridColumn:GridColumn = getGridColumn(columnIndex);
            
            if (isNaN(gridColumn.width)) // if this column's width wasn't explicitly specified
            {
                flexibleColumnCount += 1;
                columnWidth = clampColumnWidth(columnWidth, gridColumn);
            }
            else
                columnWidth = gridColumn.width;
            
            gridDimensions.setColumnWidth(columnIndex, columnWidth);  // store the column width
            
            if (columnIndex == firstVisibleColumnIndex)
                availableWidth -= startCellX + columnWidth - scrollX;
            else
                availableWidth -= columnWidth + columnGap;
        }
        
        // If we haven't scrolled horizontally, and there's space left over, widen 
        // the columns whose GridColumn width isn't set explicitly, to fill the extra space.
        
        if ((scrollX != 0) || (availableWidth < 1.0) || (flexibleColumnCount == 0))
            return;
        
        const columnWidthDelta:Number = Math.ceil(availableWidth / flexibleColumnCount);

        for (columnIndex = firstVisibleColumnIndex;
             (columnIndex >= 0) && (columnIndex < columnCount) && (availableWidth >= 1.0);
             columnIndex = grid.getNextVisibleColumnIndex(columnIndex))
        {
            gridColumn = getGridColumn(columnIndex);
            
            if (isNaN(gridColumn.width)) // if this column's width wasn't explicitly specified 
            {
                var oldColumnWidth:Number = gridDimensions.getColumnWidth(columnIndex);
                columnWidth = oldColumnWidth + Math.min(availableWidth, columnWidthDelta);
                columnWidth = clampColumnWidth(columnWidth, gridColumn);
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
    
    private const gridItemRendererClassFactories:Dictionary = new Dictionary(true);
    
    /**
     *  @private
     *  Return the item renderer for the specified column and dataProvider item,
     *  essentially column.itemToRenderer(dataItem). 
     * 
     *  If this app might have embedded fonts then item renderers must be created with the Grid's
     *  module factory.  To enable that, we wrap the real item renderer ClassFactory with 
     *  a GridItemRendererClassFactory.  Wrapped factories are cached in 
     *  the gridItemRendererClassFactories Dictionary.
     */
    private function itemToRenderer(column:GridColumn, dataItem:Object):IFactory
    {
        var factory:IFactory = column.itemToRenderer(dataItem);
        var rendererClassFactory:IFactory = null;

        if (embeddedFontRegistryExists && (factory is ClassFactory))
        {
            rendererClassFactory = gridItemRendererClassFactories[factory];
            if (!rendererClassFactory)
            {
                rendererClassFactory = new GridItemRendererClassFactory(grid, ClassFactory(factory));
                gridItemRendererClassFactories[factory] = rendererClassFactory;
            }
        }
        
        return (rendererClassFactory) ? rendererClassFactory : factory;
    }

    private function layoutItemRenderers(rendererLayer:GridLayer, scrollX:Number, scrollY:Number, width:Number, height:Number):void
    {
        if (!rendererLayer)
            return;
        
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
        const startCellX:Number = gridDimensions.getCellX(startRowIndex, startColIndex); 
        const startCellY:Number = gridDimensions.getCellY(startRowIndex, startColIndex); 
        
        // Compute newVisibleColumns
        
        const newVisibleColumnIndices:Vector.<int> = new Vector.<int>();
        var availableWidth:Number = width;
        var column:GridColumn;
        
        for (colIndex = startColIndex; 
             (availableWidth > 0) && (colIndex >= 0) && (colIndex < colCount);
             colIndex = grid.getNextVisibleColumnIndex(colIndex))
        {
            newVisibleColumnIndices.push(colIndex);
            var columnWidth:Number = gridDimensions.getColumnWidth(colIndex);
            if (colIndex == startColIndex)
                availableWidth -= startCellX + columnWidth - scrollX;
            else
                availableWidth -= columnWidth + colGap;
        }
        
        // compute newVisibleRowIndices, newVisibleItemRenderers, layout item renderers
        
        const newVisibleRowIndices:Vector.<int> = new Vector.<int>();
        const newVisibleItemRenderers:Vector.<IGridItemRenderer> = new Vector.<IGridItemRenderer>();
        
        var cellX:Number = startCellX;
        var cellY:Number = startCellY;
        var availableHeight:Number = height;
        
        for (rowIndex = startRowIndex; (availableHeight > 0) && (rowIndex >= 0) && (rowIndex < rowCount); rowIndex++)
        {
            newVisibleRowIndices.push(rowIndex);
            
            var rowHeight:Number = gridDimensions.getRowHeight(rowIndex);
            for each (colIndex in newVisibleColumnIndices)
            {
                var renderer:IGridItemRenderer = takeVisibleItemRenderer(rowIndex, colIndex);
                if (!renderer)
                {       
                    var dataItem:Object = getDataProviderItem(rowIndex);
                    column = getGridColumn(colIndex);
                    var factory:IFactory = itemToRenderer(column, dataItem);
                    renderer = allocateGridElement(factory) as IGridItemRenderer;
                }
                if (renderer.parent != rendererLayer)
                    rendererLayer.addElement(renderer);
                newVisibleItemRenderers.push(renderer);

                initializeItemRenderer(renderer, rowIndex, colIndex);
                
                var colWidth:Number = gridDimensions.getColumnWidth(colIndex);
                layoutItemRenderer(renderer, cellX, cellY, colWidth, rowHeight);                
                
                var preferredRowHeight:Number = renderer.getPreferredBoundsHeight()
                gridDimensions.setCellHeight(rowIndex, colIndex, preferredRowHeight);
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
                    var rowOffset:int = newVisibleRowIndices.indexOf(rowIndex);
                    var colOffset:int = newVisibleColumnIndices.indexOf(colIndex);                    
                    var index:int = (rowOffset * visibleColumnsLength) + colOffset;
                    renderer = newVisibleItemRenderers[index];                    
                    
                    // We're using layoutBoundsX,Y,Width instead of x,y.width because
                    // the IUITextField item renderers pad their x,y,width,height properties 
                    var rendererX:Number = renderer.getLayoutBoundsX();
                    var rendererY:Number = renderer.getLayoutBoundsY();
                    var rendererWidth:Number = renderer.getLayoutBoundsWidth();

                    layoutItemRenderer(renderer, rendererX, rendererY, rendererWidth, rowHeight);
                    gridDimensions.setCellHeight(rowIndex, colIndex, renderer.getPreferredBoundsHeight());
                }
            } 
                                               
            cellX = startCellX;
            cellY += rowHeight + rowGap;
            
            if (rowIndex == startRowIndex)
                availableHeight -= startCellY + rowHeight - scrollY;
            else
                availableHeight -= rowHeight + rowGap;            
        }
        
        // Free renderers that aren't in use
        
        for each (var oldRenderer:IGridItemRenderer in visibleItemRenderers)
        {
            freeItemRenderer(oldRenderer);
            if (oldRenderer)
                oldRenderer.discard(true);  // TODO (hmuller): need a scheme for shrinking the free-list
        }
        
        // Update visibleItemRenderersBounds
        
        if ((newVisibleRowIndices.length > 0) && (newVisibleColumnIndices.length > 0))
        {
            const lastRowIndex:int = newVisibleRowIndices[newVisibleRowIndices.length - 1];
            const lastColIndex:int = newVisibleColumnIndices[newVisibleColumnIndices.length - 1];
            const lastCellR:Rectangle = gridDimensions.getCellBounds(lastRowIndex, lastColIndex);
            
            visibleItemRenderersBounds.x = startCellX;
            visibleItemRenderersBounds.y = startCellY; 
            visibleItemRenderersBounds.width = lastCellR.x + lastCellR.width - startCellX;
            visibleItemRenderersBounds.height = lastCellR.y + lastCellR.height - startCellY;
        }
        else
        {
            visibleItemRenderersBounds.setEmpty();
        }
        
        // Update visibleItemRenderers et al
        
        visibleItemRenderers = newVisibleItemRenderers;
        visibleRowIndices = newVisibleRowIndices;
        visibleColumnIndices = newVisibleColumnIndices;
    }
    
    /**
     *  Reinitialize and layout the visible renderer at rowIndex, columnIndex.  If the cell's preferred 
     *  height changes and the Grid has been configured with variableRowHeight=true, the entire grid is 
     *  invalidated.
     * 
     *  <p>If row,columnIndex do not correspond to a visible cell, nothing is done.</p>
     * 
     *  @param rowIndex The 0-based row index of the cell that changed.
     *  @param columnIndex The 0-based column index of the cell that changed.
     */
    public function invalidateCell(rowIndex:int, columnIndex:int):void
    {
        const renderer:IGridItemRenderer = getVisibleItemRenderer(rowIndex, columnIndex);
        if (!renderer)
            return;
        
        // If the renderer at rowIndex,columnIndex is going to have to be replaced, because
        // this columns itemRendererFunction now returns a different (IFactory) value, punt.
       
        if (itemRendererFunctionValueChanged(renderer))
        {
            renderer.grid.invalidateDisplayList();
            return;
        }
        
        initializeItemRenderer(renderer, rowIndex, columnIndex);
        
        // We're using layoutBoundsX,Y,Width,Height instead of x,y,width,height because
        // the IUITextField item renderers pad their x,y,width,height properties 
        
        const rendererX:Number = renderer.getLayoutBoundsX();
        const rendererY:Number = renderer.getLayoutBoundsY();
        const rendererWidth:Number = renderer.getLayoutBoundsWidth();
        const rendererHeight:Number = renderer.getLayoutBoundsHeight();
        
        layoutItemRenderer(renderer, rendererX, rendererY, rendererWidth, rendererHeight);
        
        // If the renderer's preferredHeight has changed and variableRowHeight=true, then
        // the row's height may have changed, which implies we need to layout -everything-.
        // Warning: the unconditional getPreferredBoundsHeight() call also serves to 
        // force DefaultGridItemRenderer and UITextFieldGridItemRenderer to validate;
        // similar to what happens in layoutItemRenderers() and updateTypicalCellSizes()
        
        const preferredRendererHeight:Number = renderer.getPreferredBoundsHeight();
        if (gridDimensions.variableRowHeight && (rendererHeight != preferredRendererHeight))
            grid.invalidateDisplayList();
    }
    
    /**
     *  @private
     *  Return true if the specified item renderer was defined by an itemRendererFunction whose
     *  value has changed.
     */
    private function itemRendererFunctionValueChanged(renderer:IGridItemRenderer):Boolean
    {
        const column:GridColumn = renderer.column;
        if (!column || (column.itemRendererFunction === null))
            return false;
        
        const factory:IFactory = itemToRenderer(column, renderer.data);
        return factory !== elementToFactoryMap[renderer];
    }

    /**
     *  @private
     */
    private function getVisibleItemRendererIndex(rowIndex:int, columnIndex:int):int
    {
        if ((visibleRowIndices == null) || (visibleColumnIndices == null))
            return -1;
        
        // TODO (hmuller) - binary search would be faster than indexOf()
        
        const rowOffset:int = visibleRowIndices.indexOf(rowIndex);
        const colOffset:int = visibleColumnIndices.indexOf(columnIndex);
        if ((rowOffset == -1) || (colOffset == -1))
            return -1;

        const index:int = (rowOffset * visibleColumnIndices.length) + colOffset;
        return index;
    }
    
    public function getVisibleItemRenderer(rowIndex:int, columnIndex:int):IGridItemRenderer
    {
        const index:int = getVisibleItemRendererIndex(rowIndex, columnIndex);
        if (index == -1 || index >= visibleItemRenderers.length)
            return null;
        
        const renderer:IGridItemRenderer = visibleItemRenderers[index];
        return renderer;        
    }
    
    /**
     *  @private
     */
    private function takeVisibleItemRenderer(rowIndex:int, columnIndex:int):IGridItemRenderer
    {
        const index:int = getVisibleItemRendererIndex(rowIndex, columnIndex);
        if (index == -1 || index >= visibleItemRenderers.length)
            return null;
        
        const renderer:IGridItemRenderer = visibleItemRenderers[index];
        visibleItemRenderers[index] = null;
        
        // If the renderer at rowIndex,columnIndex is going to have to be replaced, because
        // this column's itemRendererFunction now returns a different (IFactory) value, then 
        // get rid of the old one and return null.
        
        if (renderer && itemRendererFunctionValueChanged(renderer))
        {
            freeItemRenderer(renderer);
            return null;
        }
        
        return renderer;
    }
    
    /**
     *  @private
     */
    private function initializeItemRenderer(
        renderer:IGridItemRenderer, 
        rowIndex:int, columnIndex:int,
        dataItem:Object=null,
        visible:Boolean=true):void
    {
        renderer.visible = visible;
        
        const gridColumn:GridColumn = getGridColumn(columnIndex);
        if (gridColumn)
        {
            renderer.rowIndex = rowIndex;
            renderer.column = gridColumn;
            if (dataItem == null)
                dataItem = getDataProviderItem(rowIndex);
            
            renderer.label = gridColumn.itemToLabel(dataItem);
            
            // The following code must be kept in sync with updateVisibleItemRenderers()
            if (isRowSelectionMode())
            {
                renderer.selected = grid.selectionContainsIndex(rowIndex);
                renderer.showsCaret = grid.caretRowIndex == rowIndex;
                renderer.hovered = grid.hoverRowIndex == rowIndex;
            }
            else if (isCellSelectionMode())
            {
                renderer.selected = grid.selectionContainsCell(rowIndex, columnIndex);
                renderer.showsCaret = (grid.caretRowIndex == rowIndex) && (grid.caretColumnIndex == columnIndex);
                renderer.hovered = (grid.hoverRowIndex == rowIndex) && (grid.hoverColumnIndex == columnIndex);
            }
            
            renderer.data = dataItem;
            
            if (grid.dataGrid)
                renderer.owner = grid.dataGrid;
            
            renderer.prepare(!createdGridElement);             
        }
    }
    
    private function freeItemRenderer(renderer:IGridItemRenderer):void
    {
        if (!renderer)
            return;
        
        freeGridElement(renderer);
    }
    
    private function freeItemRenderers(renderers:Vector.<IGridItemRenderer>):void
    {
        for each (var renderer:IGridItemRenderer in renderers)
            freeItemRenderer(renderer);
        renderers.length = 0;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Linear elements: row,column separators, backgrounds 
    //
    //-------------------------------------------------------------------------- 
    
    /**
     *  @private
     *  Common code for laying out the rowBackround, rowSeparator, columnSeparator visual elements.
     * 
     *  For row,columnSeparators, lastIndex identifies the element in the new layout for which 
     *  no separator is drawn.  If the previous layout - oldVisibleIndices - included the lastIndex,
     *  it needs to be freed, even though it exists in the new layout (newVisibleIndices).   See
     *  freeLinearElements().
     */
    private function layoutLinearElements(
        factory:IFactory,
        layer:GridLayer, 
        oldVisibleElements:Vector.<IVisualElement>,
        oldVisibleIndices:Vector.<int>,
        newVisibleIndices:Vector.<int>,
        layoutFunction:Function,
        lastIndex:int = -1):Vector.<IVisualElement>
    {
        if (!layer)
            return new Vector.<IVisualElement>(0);
        
        // If a factory changed, free the old visual elements and set oldVisibleElements.length=0
        
        discardGridElementsIfFactoryChanged(factory, layer, oldVisibleElements);
                       
        if (factory == null)
            return new Vector.<IVisualElement>(0);

        // Free and clear oldVisibleElements that are no long visible
        
        freeLinearElements(oldVisibleElements, oldVisibleIndices, newVisibleIndices, lastIndex);
            
        // Create, layout, and return newVisibleElements
        
        const newVisibleElementCount:uint = newVisibleIndices.length;
        const newVisibleElements:Vector.<IVisualElement> = new Vector.<IVisualElement>(newVisibleElementCount);

        for (var index:int = 0; index < newVisibleElementCount; index++) 
        {
            var newEltIndex:int = newVisibleIndices[index];
            if (newEltIndex == lastIndex)
            {
                newVisibleElements.length = index;
                break;
            }
            
            // If an element already exists for visibleIndex then use it, otherwise create one
            
            var eltOffset:int = oldVisibleIndices.indexOf(newEltIndex);
            var elt:IVisualElement = (eltOffset != -1 && eltOffset < oldVisibleElements.length) ? oldVisibleElements[eltOffset] : null;
            if (elt == null)
                elt = allocateGridElement(factory);
            
            // Initialize the element, and then delegate to the layout function
            
            newVisibleElements[index] = elt;
                
            layer.addElement(elt);
            
            elt.visible = true;
            
            layoutFunction(elt, newEltIndex);
        }

        return newVisibleElements;
    }
    
    private function layoutCellElements(
        factory:IFactory,
        layer:GridLayer,
        oldVisibleElements:Vector.<IVisualElement>,
        oldVisibleRowIndices:Vector.<int>, oldVisibleColumnIndices:Vector.<int>,
        newVisibleRowIndices:Vector.<int>, newVisibleColumnIndices:Vector.<int>,
        layoutFunction:Function):Vector.<IVisualElement>
    {
        if (!layer)
            return new Vector.<IVisualElement>(0);

        // If a factory changed, discard the old visual elements.
        
        if (discardGridElementsIfFactoryChanged(factory, layer, oldVisibleElements))
        {
            oldVisibleRowIndices.length = 0;
            oldVisibleColumnIndices.length = 0;
        }

        if (factory == null)
            return new Vector.<IVisualElement>(0);
        
        // Create, layout, and return newVisibleElements
        
        const newVisibleElementCount:uint = newVisibleRowIndices.length;
        const newVisibleElements:Vector.<IVisualElement> = new Vector.<IVisualElement>(newVisibleElementCount);

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
                        
            layer.addElement(elt);
            
            elt.visible = true;
            
            layoutFunction(elt, newEltRowIndex, newEltColumnIndex);
        }
        
        return newVisibleElements;
    }

    /** 
     *  @private
     *  If the factory has changed, or is now null, remove and free all the old
     *  visual elements, if there were any.
     * 
     *  @returns True if at least one visual element was removed.
     */
    private function discardGridElementsIfFactoryChanged(
        factory:IFactory,
        layer:GridLayer,
        oldVisibleElements:Vector.<IVisualElement>):Boolean    
    {
        if ((oldVisibleElements.length) > 0 && (factory != elementToFactoryMap[oldVisibleElements[0]]))
        {
            for each (var oldElt:IVisualElement in oldVisibleElements)
            {
                layer.removeElement(oldElt);
                freeGridElement(oldElt);
            }
            oldVisibleElements.length = 0;
            return true;
        }
        
        return false;
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
        // TODO(hmuller): rewrite this, should be one pass (no indexOf)
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
        
        // Initialize this visual element
        intializeGridVisualElement(rowBackground, rowIndex);
        
        layoutGridElementR(rowBackground, bounds);
    }

    private function layoutRowSeparator(separator:IVisualElement, rowIndex:int):void
    {
        // Initialize this visual element
        intializeGridVisualElement(separator, rowIndex);
        
        const height:Number = separator.getPreferredBoundsHeight();
        const rowCount:int = gridDimensions.rowCount;
        const bounds:Rectangle = (rowIndex < rowCount) 
            ? gridDimensions.getRowBounds(rowIndex)
            : gridDimensions.getPadRowBounds(rowIndex);
        
        if (!bounds)
            return;
        
        const x:Number = bounds.x;
        const width:Number = Math.max(bounds.width, visibleGridBounds.right);
        const y:Number = bounds.bottom; // TODO (klin): should center on gap here.
        layoutGridElement(separator, x, y, width, height);
    }
    
    private function layoutColumnSeparator(separator:IVisualElement, columnIndex:int):void
    {
        // Initialize this visual element
        intializeGridVisualElement(separator, -1, columnIndex);
        
        const r:Rectangle = visibleItemRenderersBounds;
        const width:Number = separator.getPreferredBoundsWidth();
        const height:Number = Math.max(r.height, visibleGridBounds.height); 
        const x:Number = gridDimensions.getCellX(0, columnIndex) + gridDimensions.getColumnWidth(columnIndex); // TODO (klin): should center on gap here.
        const y:Number = r.y;
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
    
    private function layoutSelectionIndicators(layer:GridLayer):void
    {
        const selectionIndicatorFactory:IFactory = grid.selectionIndicator;

        // layout and update visibleSelectionIndicators,Indices
                
        if (isRowSelectionMode())
        {
            // Selection is row-based so if there are existing cell selections, 
            // free them since they can't be reused.
            if (visibleColumnSelectionIndices.length > 0)
                clearSelectionIndicators();

            var oldVisibleRowSelectionIndices:Vector.<int> = visibleRowSelectionIndices;
            
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
                layer,
                visibleSelectionIndicators, 
                oldVisibleRowSelectionIndices, 
                visibleRowSelectionIndices, 
                layoutRowSelectionIndicator);
            
            return;
        }
        
        // Selection is not row-based so if there are existing row selections, 
        // free them since they can't be reused.
        if (visibleRowSelectionIndices.length > 0 && 
            visibleColumnSelectionIndices.length == 0)
        {
            clearSelectionIndicators();
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
                layer,
                visibleSelectionIndicators, 
                oldVisibleRowSelectionIndices, oldVisibleColumnSelectionIndices,
                visibleRowSelectionIndices, visibleColumnSelectionIndices,
                layoutCellSelectionIndicator);
            
            return;
        }
        
        // No selection.
        
        // If there are existing cell selections, 
        // free them since there is no selection.
        if (visibleColumnSelectionIndices.length > 0)
            clearSelectionIndicators();
    }
    
    private function layoutRowSelectionIndicator(indicator:IVisualElement, rowIndex:int):void
    {
        // Initialize this visual element
        intializeGridVisualElement(indicator, rowIndex);
        layoutGridElementR(indicator, gridDimensions.getRowBounds(rowIndex));
    }    
    
    private function layoutCellSelectionIndicator(indicator:IVisualElement, 
                                                  rowIndex:int,
                                                  columnIndex:int):void
    {
        // Initialize this visual element
        intializeGridVisualElement(indicator, rowIndex, columnIndex);
        layoutGridElementR(indicator, gridDimensions.getCellBounds(rowIndex, columnIndex));
    }    

    private function clearSelectionIndicators():void
    {
        freeGridElements(visibleSelectionIndicators);
        visibleRowSelectionIndices.length = 0;
        visibleColumnSelectionIndices.length = 0;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Indicators: hover, caret
    //
    //--------------------------------------------------------------------------
    
    private function layoutIndicator(
        layer:GridLayer,
        indicatorFactory:IFactory,
        indicator:IVisualElement, 
        rowIndex:int,
        columnIndex:int):IVisualElement
    {
        if (!layer)
            return null;
        
        // If the indicatorFactory has changed for the specified non-null indicator, 
        // then free the old indicator.
        
        if (indicator && (indicatorFactory != elementToFactoryMap[indicator]))
        {
            removeGridElement(indicator);
            indicator = null;
            if (indicatorFactory == null)
                return null;
        }
        
        if (rowIndex == -1 || grid.selectionMode == GridSelectionMode.NONE ||
            (isCellSelectionMode() && (grid.getNextVisibleColumnIndex(columnIndex - 1) != columnIndex)))
        {
            if (indicator)
                indicator.visible = false;
            return indicator;
        }
        
        if (!indicator && indicatorFactory)
            indicator = createGridElement(indicatorFactory);
        
        if (indicator)
        {
            const bounds:Rectangle = isRowSelectionMode() ? 
                gridDimensions.getRowBounds(rowIndex) :
                gridDimensions.getCellBounds(rowIndex, columnIndex);
            
            // Initialize this visual element
            intializeGridVisualElement(indicator, rowIndex, columnIndex);
            
            // TODO (klin): Remove this special case for the caret overlapping separators
            // when we implement column/row gaps.
            if (indicatorFactory == grid.caretIndicator && bounds)
            {
                // increase width and height by 1 to cover separator.
                if (isCellSelectionMode() && (columnIndex < grid.columns.length - 1))
                    bounds.width += 1;
                
                if ((rowIndex < grid.dataProvider.length - 1) || (visibleRowIndices.length > grid.dataProvider.length))
                    bounds.height += 1;
            }
            
            layoutGridElementR(indicator, bounds);
            layer.addElement(indicator);
            indicator.visible = true;
        }
        
        return indicator;
    }

    private var mouseXOffset:Number = 0;
    private var mouseYOffset:Number = 0;
       
    private function layoutHoverIndicator(layer:GridLayer):void
    {        
        const rowIndex:int = grid.hoverRowIndex;
        const columnIndex:int = grid.hoverColumnIndex;
        const factory:IFactory = grid.hoverIndicator;
        hoverIndicator = layoutIndicator(layer, factory, hoverIndicator, rowIndex, columnIndex); 
    }
    
    private function layoutCaretIndicator(layer:GridLayer):void
    {
        const rowIndex:int = grid.caretRowIndex;
        const colIndex:int = grid.caretColumnIndex;
        const factory:IFactory = grid.caretIndicator; 
        caretIndicator = layoutIndicator(layer, factory, caretIndicator, rowIndex, colIndex);  

        // Hide caret based on the showCaret property. Don't show caret
        // if its already hidden by layoutIndicator() because it has 
        // an invalid position.
        if (caretIndicator && !_showCaret)
            caretIndicator.visible = _showCaret;
    }
    
    private function layoutEditorIndicator(layer:GridLayer):void
    {
        const dataGrid:DataGrid = grid.dataGrid;
        if (!dataGrid)
            return;
        
        const rowIndex:int = dataGrid.editorRowIndex;
        const columnIndex:int = dataGrid.editorColumnIndex;
        var indicatorFactory:IFactory = dataGrid.editorIndicator;
        
        // If the indicatorFactory has changed for the specified non-null indicator, 
        // then free the old indicator.
        
        if (editorIndicator && (indicatorFactory != elementToFactoryMap[editorIndicator]))
        {
            removeGridElement(editorIndicator);
            editorIndicator = null;
            if (indicatorFactory == null)
                return;
        }
        
        if (rowIndex == -1 || columnIndex == -1)
        {
            if (editorIndicator)
                editorIndicator.visible = false;
            return;
        }
        
        if (!editorIndicator && indicatorFactory)
            editorIndicator = createGridElement(indicatorFactory);
        
        if (editorIndicator)
        {
            const bounds:Rectangle = gridDimensions.getCellBounds(rowIndex, columnIndex);
            
            // Initialize this visual element
            intializeGridVisualElement(editorIndicator, rowIndex, columnIndex);
            
            layoutGridElementR(editorIndicator, bounds);
            layer.addElement(editorIndicator);
            editorIndicator.visible = true;
        }
        
    }
    
    //--------------------------------------------------------------------------
    //
    //  CollectionEvent handling: dataProvider, columns
    //
    //--------------------------------------------------------------------------     
    
    public function dataProviderCollectionChanged(event:CollectionEvent):void
    {
        switch (event.kind)
        {
            case CollectionEventKind.ADD:
            {
                dataProviderCollectionAdd(event);
                break;
            }
                
            case CollectionEventKind.REMOVE: 
            {
                dataProviderCollectionRemove(event);
                break;
            }
                
            case CollectionEventKind.MOVE:
            {
                // TBD(hmuller)
                break;
            }
            
            case CollectionEventKind.REFRESH:
            case CollectionEventKind.RESET:
            {
                dataProviderCollectionReset(event);
                break;
            }
                
            case CollectionEventKind.UPDATE:
            {
                dataProviderCollectionUpdate(event);
                break;
            }
                
            case CollectionEventKind.REPLACE:
            {
                break;
            }
        }
    }
    
    /**
     *  @private
     *  Called in response to one or more items having been inserted into the 
     *  grid's dataProvider.  Ensure that visibleRowIndices and visibleRowSelectionIndices 
     *  correspond to the same, potentially shifted, dataProvider items.
     */
    private function dataProviderCollectionAdd(event:CollectionEvent):void
    {
        const insertIndex:int = event.location;
        const insertLength:int = event.items.length;
        incrementIndicesGTE(visibleRowIndices, insertIndex, insertLength);
        incrementIndicesGTE(visibleRowSelectionIndices, insertIndex, insertLength);
    }
    
    /**
     *  @private
     *  Called in response to one or more items having been removed from the 
     *  grid's dataProvider.  
     */
    private function dataProviderCollectionRemove(event:CollectionEvent):void
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
            else if (rowIndex > lastRemoveIndex)
            {
                visibleRowIndices[offset] = rowIndex - eventItemsLength;
            }
        }
        
        // Remove the elements of visibleRowBackgrounds, visibleRowSeparators, visibleRowIndices,  
        // and visibleItemRenderers in the range firstVisibleOffset, lastVisibleOffset.
        
        if ((firstVisibleOffset != -1) && (lastVisibleOffset != -1))
        {
            const removeCount:int = (lastVisibleOffset - firstVisibleOffset) + 1; 
            visibleRowIndices.splice(firstVisibleOffset, removeCount);
            
            if (lastVisibleOffset < visibleRowBackgrounds.length)
                freeGridElements(visibleRowBackgrounds.splice(firstVisibleOffset, removeCount));
            
            if (lastVisibleOffset < visibleRowSeparators.length)
                freeGridElements(visibleRowSeparators.splice(firstVisibleOffset, removeCount));
            
            const visibleColCount:int = visibleColumnIndices.length;
            const firstRendererOffset:int = firstVisibleOffset * visibleColCount;
            freeItemRenderers(visibleItemRenderers.splice(firstRendererOffset, removeCount * visibleColCount));
        }
    }    

    /**
     *  @private
     *  Increment the elements of indices that are >= insertIndex by delta.
     */
    private function incrementIndicesGTE(indices:Vector.<int>, insertIndex:int, delta:int):void
    {
        const indicesLength:int = indices.length;
        for (var i:int = 0; i < indicesLength; i++)
        {
            var index:int = indices[i];
            if (index >= insertIndex)
            {
                indices[i] = index + delta;
            }
        }
    }
    
    /**
     *  @private
     *  Called in response to a refresh/reset CollectionEvent.  Clear everything.
     */
    private function dataProviderCollectionReset(event:CollectionEvent):void
    {
        clearVirtualLayoutCache();
    }
    
    /**
     *  @private
     *  Called in response to an item being updated in the dataProvider. Checks
     *  to see if the item is visible and invalidates the grid if it is. Otherwise, 
     *  do nothing.
     */
    private function dataProviderCollectionUpdate(event:CollectionEvent):void
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
    }
    
    /**
     * @private
     * This handler runs AFTER the GridDimension object has been updated.
     */
    public function columnsCollectionChanged(event:CollectionEvent):void
    {
        switch (event.kind)
        {
            case CollectionEventKind.UPDATE:
            {
                clearVirtualLayoutCache();
                break;
            }
                
            default:
            {
                clearVirtualLayoutCache();
                if (grid)
                    grid.setContentSize(0, 0);
                break;
            }
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Grid Elements
    //
    //-------------------------------------------------------------------------- 
    
    /**
     *  @private
     *  Let the allocateGridElement() caller know if the returned element was 
     *  created or recycled.
     */
    private var createdGridElement:Boolean = false;
    
    private function createGridElement(factory:IFactory):IVisualElement
    {
        createdGridElement = true;
        const element:IVisualElement = factory.newInstance() as IVisualElement;
        elementToFactoryMap[element] = factory;
        return element;
    }
    
    /** 
     *  @private
     *  Return an element the factory-specific free-list, or create a new element,
     *  with createGridElement, if a free element isn't available.
     */
    private function allocateGridElement(factory:IFactory):IVisualElement
    {
        createdGridElement = false;
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
     *  @private
     *  Move the specified element to the free list after hiding it.  Return true if the 
     *  element was added to the free list (freeElements).   Note that we do not remove
     *  the element from its parent.
     */
    private function freeGridElement(element:IVisualElement):Boolean
    {
        if (!element)
            return false;
        
        element.visible = false;
        
        const factory:IFactory = elementToFactoryMap[element]; 
        if (!factory)
            return false;

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

    private function freeGridElements(elements:Vector.<IVisualElement>):void
    {
        for each (var elt:IVisualElement in elements)
            freeGridElement(elt);
        elements.length = 0;
    }
    
    /** 
     *  @private
     *  Remove the element from the elementToFactory map and from the per-factory free list and, finally,
     *  from its container.   On the off chance that someone is monitoring the visible property,
     *  we set that to false, just for good measure.
     */
    private function removeGridElement(element:IVisualElement):void
    {
        const factory:IFactory = elementToFactoryMap[element];
        const freeElements:Vector.<IVisualElement> = (factory) ? freeElementMap[factory] : null;
        if (freeElements)
        {
            const index:int = freeElements.indexOf(element);
            if (index != -1)
                freeElements.splice(index, 1);
            if (freeElements.length == 0)
                delete freeElementMap[factory];      
        }
        
        delete elementToFactoryMap[element];
        
        element.visible = false;
        const parent:IVisualElementContainer = element.parent as IVisualElementContainer;
        if (parent)
            parent.removeElement(element);
    }
    
    /**
     *  @private
     */ 
    private function layoutItemRenderer(renderer:IGridItemRenderer, x:Number, y:Number, width:Number, height:Number):void
    {
        var startTime:Number;
        if (enablePerformanceStatistics)
            startTime = getTimer();
        
        if (!isNaN(width) || !isNaN(height))
        {
            if (renderer is ILayoutManagerClient) 
            {
                const validateClientRenderer:ILayoutManagerClient = renderer as ILayoutManagerClient;                
                LayoutManager.getInstance().validateClient(validateClientRenderer, true); // true => skip validateDisplayList()
            }
            else if (renderer is IGraphicElement)
            {
                const graphicElementRenderer:IGraphicElement = renderer as IGraphicElement;                
                graphicElementRenderer.validateProperties();
                graphicElementRenderer.validateSize();
            }
                    
            renderer.setLayoutBoundsSize(width, height);            
        }
        
        if ((renderer is IInvalidating) && !(renderer is IGraphicElement))
        {
            const validateNowRenderer:IInvalidating = renderer as IInvalidating;
            validateNowRenderer.validateNow();            
        }
        
        renderer.setLayoutBoundsPosition(x, y);

        if (enablePerformanceStatistics)
        {
            var elapsedTime:Number = getTimer() - startTime;
            performanceStatistics.layoutGridElementTimes.push(elapsedTime);            
        }
    }

    private function layoutGridElementR(elt:IVisualElement, bounds:Rectangle):void
    {
        if (bounds)
            layoutGridElement(elt, bounds.x, bounds.y, bounds.width, bounds.height);
    }
    
    private static const MAX_ELEMENT_SIZE:Number = 8192;
    private static const ELEMENT_EDGE_PAD:Number = 512;
    

    /**
     *  @private
     *  Set the visual element's layoutBounds size and position.
     *  
     *  Attempting to render graphics whose size is larger than MAX_ELEMENT_SIZE can cause the 
     *  Flash Player to fail.  We reduce the size of visual elements here and preserve
     *  the visibility of edges.   For example if the element's left edge is not showing,
     *  then we ensure that it's no more than ELEMENT_EDGE_PAD to the left of the left edge of
     *  the scrollRect (that's the horizontalScrollPosition).   The unfortunate assumption here
     *  is that shrinking the size of a visual element in this way will not affect the appearance
     *  of the part of the element that overlaps the scrollRect.
     */
    private function layoutGridElement(elt:IVisualElement, x:Number, y:Number, width:Number, height:Number):void
    {   
        if (width > MAX_ELEMENT_SIZE)
        {
            const scrollX:Number = Math.max(0, horizontalScrollPosition);
            const gridWidth:Number = grid.getLayoutBoundsWidth();
            
            const newX:Number = Math.max(x, scrollX - ELEMENT_EDGE_PAD);
            const newRight:Number = Math.min(x + width, scrollX + gridWidth + ELEMENT_EDGE_PAD);
            
            x = newX;
            width = newRight - newX;
        }
        
        if (height > MAX_ELEMENT_SIZE)
        {
            const scrollY:Number = Math.max(0, verticalScrollPosition);
            const gridHeight:Number = grid.getLayoutBoundsHeight();
            
            const newY:Number = Math.max(y, scrollY - ELEMENT_EDGE_PAD);
            const newBottom:Number = Math.min(y + height, scrollY + gridHeight + ELEMENT_EDGE_PAD);
            
            y = newY;
            height = newBottom - newY;
        }
        
        elt.setLayoutBoundsSize(width, height);
        elt.setLayoutBoundsPosition(x, y);
    }
    
    /**
     *  @private
     *  Calls <code>prepareGridVisualElement()</code> on the element if it is an
     *  IGridVisualElement.
     */
    private function intializeGridVisualElement(elt:IVisualElement, rowIndex:int = -1, columnIndex:int = -1):void
    {
        const gridVisualElement:IGridVisualElement = elt as IGridVisualElement;
        if (gridVisualElement)
        {
            gridVisualElement.prepareGridVisualElement(grid, rowIndex, columnIndex);
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Public API Exported for Grid Cover Methods 
    //
    //--------------------------------------------------------------------------

    /**
     *  @copy spark.components.Grid#getVisibleRowIndices()
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
     *  @copy spark.components.Grid#getVisibleColumnIndices()
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
     *  @copy spark.components.Grid#getCellBounds()
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
     *  @copy spark.components.Grid#getRowBounds()
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
     *  @copy spark.components.Grid#getColumnBounds()
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
     *  @copy spark.components.Grid#getRowIndexAt()
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
     *  @copy spark.components.Grid#getColumnIndexAt()
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
     *  @copy spark.components.Grid#getCellAt()
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getCellAt(x:Number, y:Number):CellPosition
    {
        const rowIndex:int = gridDimensions.getRowIndexAt(x, y);
        const columnIndex:int = gridDimensions.getColumnIndexAt(x, y);
        if ((rowIndex == -1) || (columnIndex == -1))
            return null;
        return new CellPosition(rowIndex, columnIndex);
    }

    /**
     *  @copy spark.components.Grid#getCellsAt()
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getCellsAt(x:Number, y:Number, w:Number, h:Number):Vector.<CellPosition>
    { 
        var cells:Vector.<CellPosition> = new Vector.<CellPosition>;
		
		if (w <= 0 || h <= 0)
			return cells;
		
		// Get the row/column indexes of the corners of the region.
		var topLeft:CellPosition = getCellAt(x, y);
		var bottomRight:CellPosition = getCellAt(x + w, y + h);
		if (!topLeft || !bottomRight)
			return cells;
		
		for (var rowIndex:int = topLeft.rowIndex; 
			 rowIndex <= bottomRight.rowIndex; rowIndex++)
		{
			for (var columnIndex:int = topLeft.columnIndex; 
				 columnIndex <= bottomRight.columnIndex; columnIndex++)
			{
				cells.push(new CellPosition(rowIndex, columnIndex));
			}
		}
		
        return cells;
    }
    
    /**
     *  @copy spark.components.Grid#getItemRendererAt()
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getItemRendererAt(rowIndex:int, columnIndex:int):IGridItemRenderer
    {
        const visibleItemRenderer:IGridItemRenderer = getVisibleItemRenderer(rowIndex, columnIndex);
        if (visibleItemRenderer)
            return visibleItemRenderer;
        
        const rendererLayer:GridLayer = getLayer("rendererLayer");
        if (!rendererLayer)
            return null;
        
        // Create an item renderer.
        var dataItem:Object = getDataProviderItem(rowIndex);
        var column:GridColumn = getGridColumn(columnIndex);
        
        // Invalid row or column.
        if (dataItem == null || column == null)
            return null;

        // column is GridColumn.visible==false
        if (!column.visible)
            return null;
                
        const factory:IFactory = itemToRenderer(column, dataItem);
        const renderer:IGridItemRenderer = factory.newInstance() as IGridItemRenderer;
        createdGridElement = true;  // initializeItemRenderer() depends on this
       
        rendererLayer.addElement(renderer);
        
        initializeItemRenderer(renderer, rowIndex, columnIndex, dataItem, false);

        // The width/height may change later if the cell becomes visible.
        var bounds:Rectangle = gridDimensions.getCellBounds(rowIndex, columnIndex);
        if (bounds == null)
            return null;
        layoutItemRenderer(renderer, bounds.x, bounds.y, bounds.width, bounds.height);
        
        rendererLayer.removeElement(renderer);
        renderer.visible = false;
        
        return renderer;
    }
    
    /**
     *  @copy spark.components.Grid#isCellVisible()
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */ 
    public function isCellVisible(rowIndex:int, columnIndex:int):Boolean
    {
        if (rowIndex == -1 && columnIndex == -1)
            return false;
        
        return ((rowIndex == -1) || (visibleRowIndices.indexOf(rowIndex) != -1)) && 
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

import flash.utils.getQualifiedClassName;

import mx.core.ClassFactory;
import mx.core.IFactory;
import mx.core.IFlexModuleFactory;

import spark.components.Grid;

/**
 *  @private
 *  A wrapper class for item renderers that creates the renderer instance with the grid's
 *  module factory.  
 * 
 *  This is necessary for applications that use embedded fonts.   The module factory creates
 *  the renderer instance in the correct "font context" in the same way as ContextualClassFactory
 *  does.   More about this in the  ContextualClassFactory  ASDoc.
 */
class GridItemRendererClassFactory extends ClassFactory
{
    public var grid:Grid;
    public var factory:ClassFactory;
    
    public function GridItemRendererClassFactory(grid:Grid, factory:ClassFactory)
    {
        super(factory.generator);
        this.grid = grid;
        this.factory = factory;
    }
    
    override public function newInstance():*
    {
        const factoryGenerator:Class = factory.generator;
        const moduleFactory:IFlexModuleFactory = grid.moduleFactory;
        const instance:Object = 
            (moduleFactory) ? moduleFactory.create(getQualifiedClassName(factoryGenerator)) : new factoryGenerator();
        
        const factoryProperties:Object = factory.properties;
        if (factoryProperties)
        {
            for (var p:String in factoryProperties)
                instance[p] = factoryProperties[p];
        }
        
        return instance;
    }
}
