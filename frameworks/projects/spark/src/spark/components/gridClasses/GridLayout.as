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
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import mx.collections.IList;
import mx.core.IFactory;
import mx.core.IInvalidating;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;

import org.osmf.metadata.IFacet;

import spark.components.Grid;
import spark.components.Group;
import spark.layouts.supportClasses.LayoutBase;
import spark.primitives.Rect;


public class GridLayout extends LayoutBase
{
    include "../../core/Version.as";    

    // TBD: lazily create this so that if it's replaced we don't needlessly create two.
    // Perhaps it should be a constructor parameter.   That way there's no need to sort
    // out how to migrate data from the old GLC to the new one.
    // Note also: if this was going to be shared, it should arrive as a constructor parameter.
    public var gridDimensions:GridDimensions = new GridDimensions();
    
    //--------------------------------------------------------------------------
    //
    //  Method Overrides
    //
    //-------------------------------------------------------------------------- 
    
    /**
     *  @private
     */
    override protected function scrollPositionChanged():void
    {
        if (!grid)
            return;
        
        super.scrollPositionChanged();
        
        // Only invalidate if we're clipping and scrollR extends outside validBounds
        
        const scrollR:Rectangle = grid.scrollRect;
        if (scrollR && !visibleItemRenderersBounds.containsRect(scrollR))
            grid.invalidateDisplayList();
    }
    
    /**
     *  @private
     */
    override public function measure():void
    {
        if (!grid)
            return;
        
        // Use Math.ceil() to make sure that if the content partially occupies
        // the last pixel, we'll count it as if the whole pixel is occupied.
        /*
        grid.measuredWidth = Math.ceil(measuredWidth);    
        grid.measuredHeight = Math.ceil(measuredHeight);    
        grid.measuredMinWidth = Math.ceil(measuredMinWidth);    
        grid.measuredMinHeight = Math.ceil(measuredMinHeight); 
        */
    }
    
    /**
     *  @private
     */
    override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        if (!grid)
            return;
        
        // HACK
        gridDimensions.rowCount = grid.dataProvider.length;
        gridDimensions.columnCount = grid.columns.length;
        
        // Layout the item renderers and compute new values for visibleRowIndices et al
        
        oldVisibleRowIndices = visibleRowIndices;
        oldVisibleColumnIndices = visibleColumnIndices;
        
        const scrollX:Number = horizontalScrollPosition;
        const scrollY:Number = verticalScrollPosition;
        layoutItemRenderers(grid.itemRendererGroup, scrollX, scrollY, unscaledWidth, unscaledHeight);
        
        // Layout the row and column backgrounds
        
        visibleRowBackgrounds = layoutLinearElements(grid.rowBackground, grid.backgroundGroup, 
            visibleRowBackgrounds, oldVisibleRowIndices, visibleRowIndices, layoutRowBackground);
        
        visibleColumnBackgrounds = layoutLinearElements(grid.columnBackground, grid.backgroundGroup, 
            visibleColumnBackgrounds, oldVisibleColumnIndices, visibleColumnIndices, layoutColumnBackground);
        
        // Layout the row and column separators
        
        const lastRowIndex:int = gridDimensions.rowCount - 1;
        const lastColumnIndex:int = gridDimensions.columnCount - 1;
        const overlayGroup:Group = grid.overlayGroup
        
        visibleRowSeparators = layoutLinearElements(grid.rowSeparator, overlayGroup, 
            visibleRowSeparators, oldVisibleRowIndices, visibleRowIndices, layoutRowSeparator, lastRowIndex);
        
        visibleColumnSeparators = layoutLinearElements(grid.columnSeparator, overlayGroup, 
            visibleColumnSeparators, oldVisibleColumnIndices, visibleColumnIndices, layoutColumnSeparator, lastColumnIndex);
        
        // Layout the hoverIndicator, caretIndicator, and selectionIndicators
        
        layoutHoverIndicator(grid.backgroundGroup);
        layoutSelectionIndicators(grid.selectionGroup);
        layoutCaretIndicator(grid.overlayGroup);

        // The old visible row,column indices are no longer needed
        
        oldVisibleRowIndices.length = 0;
        oldVisibleColumnIndices.length = 0;
        
        // Update the content size.  Make sure that if the content spans partially 
        // over a pixel to the right/bottom, the content size includes the whole pixel.
        
        const contentWidth:Number = Math.ceil(gridDimensions.contentWidth);
        const contentHeight:Number = Math.ceil(gridDimensions.contentHeight);
        grid.setContentSize(contentWidth, contentHeight);
    }
    
    /**
     *  @private
     */
    override public function clearVirtualLayoutCache():void
    {
        // TBD(hmuller):DTRT when the target changes
    }    
    
    //--------------------------------------------------------------------------
    //
    //  DataGrid Access
    //
    //--------------------------------------------------------------------------
    
    private function get grid():Grid
    {
        return target as Grid;
    }
    
    private function getGridColumn(columnIndex:int):GridColumn
    {
        const columns:IList = grid.columns;
        if ((columns == null) || (columnIndex >= columns.length))
            return null;
        
        return columns.getItemAt(columnIndex) as GridColumn;
    }
    
    private function getDataProviderItem(rowIndex:int):Object
    {
        const dataProvider:IList = grid.dataProvider;
        if ((dataProvider == null) || (rowIndex >= dataProvider.length))
            return null;
        
        return dataProvider.getItemAt(rowIndex);
    }
    
    private function getItemRendererFactory(columnIndex:int):IFactory
    {
        const column:GridColumn = getGridColumn(columnIndex);
        return (column) ? column.itemRenderer as IFactory : null;        
    }
    
    // TBD(hmuller): need a change notification scheme for the factory properties
    // when one changes (which is unlikely to happen very often), need to make sure
    // that the old ones aren't reused.

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
                    var factory:IFactory = getItemRendererFactory(colIndex);
                    renderer = allocateGridElement(factory) as IVisualElement;
                    // TBD(hmuller): if factory == null, then dataProvider[row][gridColumn.dataField]
                    // TBD(hmuller): what if renderer is *still* null (no factory, nothing at dataField).
                }
                
                if (renderer.parent != itemRendererGroup)
                    itemRendererGroup.addElement(renderer);
                
                newVisibleItemRenderers.push(renderer);
                initializeItemRenderer(renderer, rowIndex, colIndex);
                var colWidth:Number = gridDimensions.getColumnWidth(colIndex);
                layoutGridElement(renderer, cellX, cellY, colWidth, rowHeight);
                
                // TBD(hmuller): need a local preferred bounds method once layoutGridElement supports constraints
                gridDimensions.setCellHeight(rowIndex, colIndex, renderer.getPreferredBoundsHeight());
                cellX += colWidth + colGap;
            }
            
            // TBD: if gridDimensions.rowHeight is now larger, we need to make another
            // pass to fix up the item renderer heights.
            
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
        
        const lastRowIndex:int = newVisibleRowIndices[newVisibleRowIndices.length - 1];
        const lastColIndex:int = newVisibleColumnIndices[newVisibleColumnIndices.length - 1];
        const lastCellR:Rectangle = gridDimensions.getCellBounds(lastRowIndex, lastColIndex);
        
        visibleItemRenderersBounds.x = startCellR.x;
        visibleItemRenderersBounds.y = startCellR.y;
        visibleItemRenderersBounds.width = lastCellR.x + lastCellR.width - startCellR.x;
        visibleItemRenderersBounds.height = lastCellR.y + lastCellR.height - startCellR.y;
        
        // Update visibleItemRenderers et al
        
        visibleItemRenderers = newVisibleItemRenderers;
        visibleRowIndices = newVisibleRowIndices;
        visibleColumnIndices = newVisibleColumnIndices;
    }
    
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
    
    private function takeVisibleItemRenderer(rowIndex:int, columnIndex:int):IVisualElement
    {
        const index:int = getVisibleItemRendererIndex(rowIndex, columnIndex);
        if (index == -1)
            return null;
        
        const renderer:IVisualElement = visibleItemRenderers[index];
        visibleItemRenderers[index] = null;
        return renderer;
    }
    
    private function initializeItemRenderer(renderer:IVisualElement, rowIndex:int, columnIndex:int):void
    {
        renderer.visible = true;
        
        const gridRenderer:GridItemRenderer = renderer as GridItemRenderer;
        const gridColumn:GridColumn = getGridColumn(columnIndex);
        
        if (gridRenderer && gridColumn)
        {
            gridRenderer.itemIndex = rowIndex;
            gridRenderer.column = gridColumn;
            const dataItem:Object = getDataProviderItem(rowIndex);
            const dataField:String = gridColumn.dataField;
            gridRenderer.data = (dataItem && dataField) ? gridRenderer.data = dataItem[dataField] : dataItem;
        }
    }
    
    private function uninitializeItemRenderer(renderer:IVisualElement):void
    {
        renderer.visible = false;
        
        // TBD: should this be done later, like right before the renderer is validated?
        // Reset back to (0,0), otherwise when the element is reused
        // it will be validated at its last layout size which causes
        // problems with text reflow.
        renderer.setLayoutBoundsSize(0, 0, false);        
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
        
        freeLinearElements(oldVisibleElements, oldVisibleIndices, newVisibleIndices);
        
        // Create, layout, and return newVisibleElements
        
        const newVisibleElementCount:uint = newVisibleIndices.length;
        const newVisibleElements:Vector.<IVisualElement> = new Vector.<IVisualElement>(newVisibleElementCount);
        
        for (var index:int = 0; index < newVisibleElementCount; index++) 
        {
            var newEltIndex:int = newVisibleIndices[index];
            if (newEltIndex == lastIndex)
                continue;
            
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
    
    
    /** 
     *  @private
     *  Free each member of elements if the corresponding member of oldIndices doesn't 
     *  appear in newIndices.  Both vectors of indices must have been sorted in increasing
     *  order.  When an element is freed, the corresponding member of the vector parameter
     *  is set to null.
     * 
     *  This method is a somewhat more efficient implementation of the following:
     * 
     *  for (var i:int = 0; i < elements.length; i++)
     *     if (newIndices.indexOf(oldIndices[i]) == -1)
     *     {
     *         freeGridElement(elements[i]);
     *         elements[i] = null;
     *     }
     *  
     */
    private function freeLinearElements (
        elements:Vector.<IVisualElement>, 
        oldIndices:Vector.<int>, 
        newIndices:Vector.<int>):void
    {
        const lastOffset:int = newIndices.length - 1;
        
        // TBD(hmuller): rewrite this, should be one pass (no indexOf)
        for (var i:int = 0; i < elements.length; i++)
        {
            const offset:int = newIndices.indexOf(oldIndices[i]);
            if (offset == -1)
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
    
    private function layoutRowBackground(rowBackground:IVisualElement, rowIndex:int):void
    {
        // TBD: call via IGridElement method
        Object(rowBackground)["initializeGridElement"](rowIndex, 0);
        layoutGridElementR(rowBackground, gridDimensions.getRowBounds(rowIndex));
    }

    private function layoutColumnBackground(rowBackground:IVisualElement, columnIndex:int):void
    {
        // TBD
    }

    private function layoutRowSeparator(separator:IVisualElement, rowIndex:int):void
    {
        const r:Rectangle = visibleItemRenderersBounds;
        const width:Number = r.width;  
        const height:Number = 1; // TBD: should be max(1, colGap)
        const x:Number = r.x;
        const y:Number = gridDimensions.getRowBounds(rowIndex).bottom;
        layoutGridElement(separator, x, y, width, height);
    }
    
    private function layoutColumnSeparator(separator:IVisualElement, columnIndex:int):void
    {
        const r:Rectangle = visibleItemRenderersBounds;
        const width:Number = 1;  // TBD: should be max(1, rowGap)
        const height:Number = r.height; 
        const x:Number = gridDimensions.getColumnBounds(columnIndex).right;
        const y:Number = r.y;
        layoutGridElement(separator, x, y, width, height);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Selection Indicators
    //
    //--------------------------------------------------------------------------
    
    private var visibleRowSelectionIndicators:Vector.<IVisualElement> = new Vector.<IVisualElement>(0);
    private var visibleRowSelectionIndices:Vector.<int> = new Vector.<int>(0);    
    
    private function layoutSelectionIndicators(container:IVisualElementContainer):void
    {
        const gridSelection:GridSelection = grid.gridSelection;
        const selectionIndicatorFactory:IFactory = grid.selectionIndicator;
        
        // TBD: if gridSelection or indicatorFactory are null, then clear everything and punt.
        
        // layout and update visibleRowSelectionIndicators,Indices
        
        // TBD: this could be a GridSelection operation
        const oldVisibleRowSelectionIndices:Vector.<int> = visibleRowSelectionIndices;
        visibleRowSelectionIndices = new Vector.<int>();
        for each (var rowIndex:int in visibleRowIndices)
            if (gridSelection.containsRow(rowIndex))
                visibleRowSelectionIndices.push(rowIndex);
            
        visibleRowSelectionIndicators = layoutLinearElements(
            selectionIndicatorFactory,
            container,
            visibleRowSelectionIndicators, 
            oldVisibleRowSelectionIndices, 
            visibleRowSelectionIndices, 
            layoutRowSelectionIndicator);
        
        // TBD: columns and cells...
    }
    
    private function layoutRowSelectionIndicator(indicator:IVisualElement, rowIndex:int):void
    {
        layoutGridElementR(indicator, gridDimensions.getRowBounds(rowIndex));
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
        if ((rowIndex == -1) && indicator)
            indicator.visible = false;
        else if (rowIndex != -1)
        {
            if (!indicator && indicatorFactory)
                indicator = indicatorFactory.newInstance() as IVisualElement;
            if (indicator)
            {
                layoutGridElementR(indicator, gridDimensions.getRowBounds(rowIndex));
                container.addElement(indicator);  // add or move to the top
                indicator.visible = true;
            }
        }
        return indicator;
    }
    
    private function layoutHoverIndicator(container:IVisualElementContainer):void
    {
        const rowIndex:int = grid.hoverRowIndex;
        const colIndex:int = grid.hoverColumnIndex;
        const factory:IFactory = grid.hoverIndicator;
        hoverIndicator = layoutIndicator(container, factory, hoverIndicator, rowIndex, colIndex); 
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
            case CollectionEventKind.ADD:    return dataProviderCollectionAdd(event);
            case CollectionEventKind.REMOVE: return dataProviderCollectionRemove(event);
                
            case CollectionEventKind.REPLACE:
            case CollectionEventKind.MOVE:
            case CollectionEventKind.REFRESH:
            case CollectionEventKind.RESET:
            case CollectionEventKind.UPDATE:
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
     *  Maps from an IFactory to a list of the vlements that have been allocated by that factory
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
            elements = allocatedElementMap[factory] = new Vector.<IVisualElement>(); 
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
            freeElements = freeElementMap[factory] = new Vector.<IVisualElement>(); 
        freeElements.push(element);
        
        return true;
    }

    private function freeGridElements (elements:Vector.<IVisualElement>):void
    {
        for each (var elt:IVisualElement in elements)
            freeGridElement(elt);
    }      
    
    private function removeGridElement(element:IVisualElement):void
    {
        // TBD
    }
    
    private function layoutGridElement(elt:IVisualElement, x:Number, y:Number, width:Number, height:Number):void
    {
        // TBD(hmuller): support for BasicLayout constraints
        
        const validatingElt:IInvalidating = elt as IInvalidating;
        
        if (!isNaN(width) || !isNaN(height))
        {
            if (validatingElt)
                validatingElt.validateNow();
            elt.setLayoutBoundsSize(width, height);
        }
        if (validatingElt)        
            validatingElt.validateNow();
        elt.setLayoutBoundsPosition(x, y);
    }

    private function layoutGridElementR(elt:IVisualElement, bounds:Rectangle):void
    {
        if (bounds)
            layoutGridElement(elt, bounds.x, bounds.y, bounds.width, bounds.height);
    }
}
}
