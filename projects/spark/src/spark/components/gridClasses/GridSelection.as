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
import mx.collections.ArrayList;
import mx.collections.IList;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;

/**
 *  <p>Track a Grid's selectionMode and its set of selected rows, columns, or cells.   
 *  The selected elements are defined by integer indices, where row indices are 
 *  relative to the Grid's dataProvider and column indices are relative to 
 *  the Grid's list of columns.</p>
 * 
 *  <p>Three sets of methods are provided for querying or changing the selection. 
 *  The methods for rows are typical:
 *  <pre>
 *  containsRow(rowIndex):Boolean
 *  setRow(rowIndex:int):void
 *  addRow(rowIndex:int):void
 *  removeRow(rowIndex:int):void
 *  setRows(rowIndices:Vector.<int>):void
 *  </pre>
 *  The <code>containsRow()</code> method returns true if specified row is selected.
 *  The <code>setRow()</code> method replaces the current selection with the
 *  specified row.  It's used to implement unshifted-click selection in the Grid.
 *  The <code>add/removeRow()</code> methods add or remove the specified row from 
 *  the selection and are used to implement control-click selection.
 *  The <code>setRows()</code> method replaces the current selection with the
 *  specified rows.  It's used for shift-click selection.</p>
 */
public class GridSelection
{
    include "../../core/Version.as";    

    private const selectedRows:Vector.<int> = new Vector.<int>();
    private var allSelected:Boolean = false;
    
    public function GridSelection()
    {
        super();
    }
    
    
    public function selectAll():void
    {
        // TBD: just set an internal flag        
    }
    
    public function clearAll():void
    {
        selectedRows.length = 0;
    }
    
    public function containsRow(rowIndex:int):Boolean
    {
        return selectedRows.indexOf(rowIndex) != -1;
    }
    
    public function setRow(rowIndex:int):void
    {
        selectedRows.length = 1;
        selectedRows[0] = rowIndex;
    }
    
    public function addRow(rowIndex:int):void
    {
        if (selectedRows.indexOf(rowIndex) == -1)        
            selectedRows.push(rowIndex);        
    }
    
    public function removeRow(rowIndex:int):void
    {
        const offset:int = selectedRows.indexOf(rowIndex);
        if (offset != -1)
            selectedRows.splice(offset, 1);        
    }
    
    public function setRows(rowIndices:Vector.<int>):void
    {
        selectedRows.length = rowIndices.length;
        var offset:int = 0;
        for each (var rowIndex:int in rowIndices)
            selectedRows[offset++] = rowIndex;
    }
    
    // TBD: column and cell analogs of the row methods

    public function dataProviderCollectionChanged(event:CollectionEvent):Boolean
    {
        switch (event.kind)
        {
            case CollectionEventKind.ADD:     
                return dataProviderCollectionAdd(event);
                
            case CollectionEventKind.REMOVE:  
                return dataProviderCollectionRemove(event);
                
            case CollectionEventKind.REPLACE:
            case CollectionEventKind.MOVE:
            case CollectionEventKind.REFRESH:
            case CollectionEventKind.RESET:
            case CollectionEventKind.UPDATE:
                break;
        }
        
        return false;
    }
    
    private function dataProviderCollectionAdd(event:CollectionEvent):Boolean
    {
        const insertIndex:int = event.location;
        const insertLength:int = event.items.length;
        
        var elementChanged:Boolean = false;
        const selectedRowsLength:int = selectedRows.length;
        for (var i:int = 0; i < selectedRowsLength; i++)
        {
            var index:int = selectedRows[i];
            if (index >= insertIndex)
            {
                selectedRows[i] = index + insertLength;
                elementChanged = true;
            }
        }
        return elementChanged;        
    }
    
    private function dataProviderCollectionRemove(event:CollectionEvent):Boolean
    {
        const firstRemoveIndex:int = event.location;
        const lastRemoveIndex:int = event.location + event.items.length - 1;
        
        // Compute the range of selectedRows elements affected by the remove event,
        // and (while we're at it), decrement the visibleRowIndices elements which are
        // "to the right" of the range.
        
        var firstVisibleOffset:int = -1; // remove selectedRows[firstVisibleOffset] 
        var lastVisibleOffset:int = -1;  // ... through visibelRowIndices[lastVisibleOffset]
        
        for (var offset:int = 0; offset < selectedRows.length; offset++)
        {
            var rowIndex:int = selectedRows[offset];
            if ((rowIndex >= firstRemoveIndex) && (rowIndex <= lastRemoveIndex))
            {
                if (firstVisibleOffset == -1)
                    firstVisibleOffset = lastVisibleOffset = offset;
                else
                    lastVisibleOffset = offset;
            }
            else if (rowIndex > lastRemoveIndex)
                selectedRows[offset] = rowIndex - 1;
        }
        
        if ((firstVisibleOffset != -1) && (lastVisibleOffset != -1))
        {
            var removeCount:int = (lastVisibleOffset - firstVisibleOffset) + 1; 
            selectedRows.splice(firstVisibleOffset, removeCount);
            return true;
        }
        
        return false;        

    }
    
    //----------------------------------
    //  Cells
    //----------------------------------

    private var cellRegions:Vector.<CellRegion> = new Vector.<CellRegion>();
    
    public function containsCell(rowIndex:int, columnIndex:int):Boolean
    {   
        if (allSelected)
            return true;
        
        // Find the index of the last isAdd=true cell region that contains row,columnIndex
        var index:int = -1;
        for (var i:int = 0; i < cellRegions.length; i++)
        {
            var cr:CellRegion = cellRegions[i];
            if (cr.isAdd && cr.containsCell(rowIndex, columnIndex))
                index = i;
        }
        
        if (index == -1)
            return false;
        
        // Starting with index, if any subsequent isAdd=false cell region contains row,columnIndex return false
        for (i = index; i < cellRegions.length; i++)
        {
            cr = cellRegions[i];
            if (!cr.isAdd && cr.containsCell(rowIndex, columnIndex))
                return false;
        }
        
        return true;
    }
    
    
    /**
     *  @private
     *  Remove all cell regions that are completely contained by cr and then append cr to cellRegions.
     */
    private function filterCellRegions(cr:CellRegion):void
    {
        const containsCR:Function = function(item:CellRegion, index:int, vector:Vector.<CellRegion>):Boolean 
        {
            return !cr.containsRegion(item);
        };
        cellRegions = cellRegions.filter(containsCR);
        cellRegions.push(cr);
    }
    
    public function addCellRegion(rowIndex:int, columnIndex:int, rowCount:uint, columnCount:uint):void
    {
        filterCellRegions(new CellRegion(rowIndex, columnIndex, rowCount, columnCount, true));
    }
    

    public function removeCellRegion(rowIndex:int, columnIndex:int, rowCount:uint, columnCount:uint):void
    {
        filterCellRegions(new CellRegion(rowIndex, columnIndex, rowCount, columnCount, false));        
    }

    public function setCell(rowIndex:int, columnIndex:int):void
    {
        // TBD
    }
    
    public function removeCell(rowIndex:int, columnIndex:int):void
    {
        // TBD
    }
}
}

class CellRegion
{
    public var rowIndex:int;
    public var columnIndex:int;
    public var rowCount:uint;
    public var columnCount:uint;
    public var isAdd:Boolean = false;
    
    public function CellRegion(rowIndex:int, columnIndex:int, rowCount:uint, columnCount:uint, isAdd:Boolean)
    {
        super();
        this.rowIndex = rowIndex;
        this.columnIndex = columnIndex;
        this.rowCount = rowCount;
        this.columnCount = columnCount;
        this.isAdd = isAdd;
    }
    
    public function containsRegion(cr:CellRegion):Boolean
    {
        return (cr.rowIndex >= rowIndex) && 
            (cr.columnIndex >= columnIndex) && 
            ((cr.rowIndex + cr.rowCount) <= (rowIndex + rowCount)) && 
            ((cr.columnIndex + cr.columnCount) <= (columnIndex + columnCount));
    }
    
    public function containsCell(cellRowIndex:int, cellColumnIndex:int):Boolean
    {
        return (cellRowIndex >= rowIndex) && 
            (cellColumnIndex >= columnIndex) && 
            (cellRowIndex <= (rowIndex + rowCount)) && 
            (cellColumnIndex <= (columnIndex + columnCount));
    }
}
