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

import mx.collections.ArrayList;
import mx.collections.IList;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.PropertyChangeEvent;

import spark.components.DataGrid;
import spark.components.Grid;

use namespace mx_internal;
  

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
 *  setRows(startRowIndex:int, endRowIndex:int):void
 *  </pre>
 *  The <code>containsRow()</code> method returns true if specified row is selected.
 *  The <code>setRow()</code> method replaces the current selection with the
 *  specified row.  It's used to implement unshifted-click selection in the Grid.
 *  The <code>add/removeRow()</code> methods add or remove the specified row from 
 *  the selection and are used to implement control-click selection.
 *  The <code>setRows()</code> method replaces the current selection with the
 *  specified rows.  It's used for shift-click selection.</p> 
 * 
 *  @see spark.components.Grid
 *  @see spark.components.Grid#columns
 *  @see spark.components.Grid#dataProvider
 *  @see spark.components.supportClasses.GridSelectionMode
 */
public class GridSelection
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------
        
    /**
     *  @private
     *  Vector of rowIndexes that map to the dataProvider items.  If 
     *  selectAllFlag==false, this is the list of selected rows. If 
     *  selectAllFlag==true, this is the list of rows that have been removed 
     *  from the selection which initially consisted of all rows and columns.
     */    
    private const selectedRows:Vector.<int> = new Vector.<int>();

    /**
     *  @private
     *  List of ordered selected/de-selected cell regions.  If 
     *  selectAllFlag==false, this is the list of cell regions that have
     *  been added (isAdd==true) and removed (isAdd==false).  If
     *  selectAllFlag==true, this is the list of cell regions that have been 
     *  removed (isAdd==true) or re-added (isAdd==false) to the selection.  
     *  containsCell should be used to determine if a cell is in the selection.
     */    
    private var cellRegions:Vector.<CellRegion> = new Vector.<CellRegion>();
       
    /**
     *  @private
     *  Selected data provider rows.  Sparse array, index is rowIndex.  This is
     *  used for both row and cell selections.  If selectAllFlag==false, these
     *  are items for rows and cells that are NOT in the selection.
     */    
    private var selectedRowValues:Array /* of Object */ = [];
    
    /**
     *  @private
     *  True if all cells are selected.  In this case, the data structures are
     *  all reset and the flag should be used to determine the selection.
     */    
    // Fixme: need interface to determine if everything is selected
    mx_internal var selectAllFlag:Boolean;
    
    /**
     *  @private
     *  True if in a collection handler.  If this is the case, there is no
     *  need to validate the index/indices.  In the case of 
     *  CollectionEventKind.REMOVE, when the last item selected and it is 
     *  removed from the collection, the validate would fail since the index is 
     *  now out of range and the item would incorrectly remain in the selection.
     */    
    private var inCollectionHandler:Boolean;
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    public function GridSelection()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
   
    //----------------------------------
    //  grid
    //----------------------------------
    
    private var _grid:Grid;
    
    /**
     *  @private
     */
    public function get grid():Grid
    {
        return _grid;
    }
    
    /**
     *  This value is created by DataGrid/partAdded() and then set here.   
     *  It is should only be set once.
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function set grid(value:Grid):void
    {
        _grid = value;
    }
    
    //----------------------------------
    //  preserveSelection
    //----------------------------------
    
    private var _preserveSelection:Boolean = false;
    
    /**
     *  If true, the selection will be preserved when the 
     *  <code>dataProvider</code> refreshes its collection.  Because this
     *  requires each item in the selection to be saved this may not 
     *  be desirable if the selection is large.
     *
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get preserveSelection():Boolean
    {
        return _preserveSelection;
    }
    
    /**
     *  @private
     */    
    public function set preserveSelection(value:Boolean):void
    {
        if (_preserveSelection == value)
            return;
        
        _preserveSelection = value;
        
        if (!_preserveSelection)
            selectedRowValues.length = 0;
    }
    
    //----------------------------------
    //  requireSelection
    //----------------------------------
    
    private var _requireSelection:Boolean = false;
    
    /**
     *  If <code>true</code>, a data item must always be selected in the 
     *  control.  TBD: what if there are no items/columns
     *
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get requireSelection():Boolean
    {
        return _requireSelection;
    }
    
    /**
     *  @private
     */    
    public function set requireSelection(value:Boolean):void
    {
        if (_requireSelection == value)
            return;
        
        _requireSelection = value;
             
        if (_requireSelection)
            ensureRequiredSelection();
    }

    //----------------------------------
    //  selectionLength
    //----------------------------------
        
    /**
     *  If the selectionMode is either <code>GridSelectionMode.SINGLE_ROW</code> or
     *  <code>GridSelectionMode.MULTIPLE_ROWS</code>, returns the number of
     *  selected rows and if the selectionMode is either 
     *  <code>GridSelectionMode.SINGLE_CELL</code> or
     *  <code>GridSelectionMode.MULTIPLE_CELLS</code>, returns the number of
     *  selected cells.  If selectionMode is <code>GridSelectionMode.NONE</code>
     *  returns 0.
     * 
     *  @return Number of selected rows or cells depending on selectionMode.
     *
     *  @default 0
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectionLength():int
    {
        if (isRowSelectionMode())
        {           
            if (!selectAllFlag)
                return selectedRows.length;   
            
            const rowCount:int = getGridDataProviderLength();
            
            // selectAll and nothing on the delete list
            if (selectedRows.length == 0)
                return rowCount;
            
            // all rows minus the ones that were removed from the selection
            return rowCount - selectedRows.length;
        }        
        else if (isCellSelectionMode())
        { 
            var left:int;
            var right:int;
            var top:int;
            var bottom:int;
            
            if (selectAllFlag)
            {
                // Iterate over all rows and columns.
                left = 0;
                top = 0;
                right = getGridColumnsLength();
                bottom = getGridDataProviderLength();
                
                // selectAll and nothing on the delete list.
                if (cellRegions.length == 0)
                    return right * bottom;                    
            }
            else
            {
                // Iterate over the selected cells region.
                const bounds:Rectangle = getCellRegionsBounds();
                left = bounds.left;
                right = bounds.right;
                top = bounds.top;
                bottom = bounds.bottom;
            }
            
            var selectedCount:int = 0;
            
            for (var rowIndex:int = top; rowIndex < bottom; rowIndex++)
            {
                for (var columnIndex:int = left; columnIndex < right; columnIndex++)
                {
                    if (containsCell(rowIndex, columnIndex))
                        selectedCount++;
                }
            }
            
            return selectedCount;
        }
               
        return 0;
    }
    
    //----------------------------------
    //  selectionMode
    //----------------------------------
    
    private var _selectionMode:String = GridSelectionMode.SINGLE_ROW;
    
    /**
     *  The selection mode of the control.  Possible values are:
     *  <code>GridSelectionMode.MULTIPLE_CELLS</code>, 
     *  <code>GridSelectionMode.MULTIPLE_ROWS</code>, 
     *  <code>GridSelectionMode.NONE</code>, 
     *  <code>GridSelectionMode.SINGLE_CELL</code>, and 
     *  <code>GridSelectionMode.SINGLE_ROW</code>.
     * 
     *  <p>Changing the selectionMode causes the current selection to be 
     *  cleared.</p>
     *
     *  @default GridSelectionMode.SINGLE_ROW
     * 
     *  @see spark.components.supportClasses.GridSelectionMode
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectionMode():String
    {
        return _selectionMode;
    }
    
    /**
     *  @private
     */
    public function set selectionMode(value:String):void
    {
        if (value == _selectionMode)
            return;
        
        switch (value)
        {
            case GridSelectionMode.SINGLE_ROW:
            case GridSelectionMode.MULTIPLE_ROWS:
            case GridSelectionMode.SINGLE_CELL:
            case GridSelectionMode.MULTIPLE_CELLS:
            case GridSelectionMode.NONE:
                _selectionMode = value;
                removeAll();
                break;
        }
    }
    
    /**
     *  If the selectionMode is either <code>GridSelectionMode.SINGLE_CELL</code> or
     *  <code>GridSelectionMode.MULTIPLE_CELLS</code>, returns a list of all the
     *  selected cells.
     * 
     *  @return Vector of selected cell locations as row and column indices, or
     *  if none, a Vector of length 0.  Each cell location is 
     *  {rowIndex: rn, columnIndex: cn}.  The row indices 
     *  are relative to the Grid's dataProvider and column indices are relative 
     *  to the Grid's list of columns.
     *
     *  @default []
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function allCells():Vector.<CellPosition>
    {
        var cells:Vector.<CellPosition> = new Vector.<CellPosition>;
        
        if (!isCellSelectionMode())
            return cells;

        // Note: if this is changed, change the similiar code in selectionLength.
        
        var left:int;
        var right:int;
        var top:int;
        var bottom:int;

        if (selectAllFlag)
        {
            // Iterate over all rows and columns.
            left = 0;
            top = 0;
            right = getGridColumnsLength();
            bottom = getGridDataProviderLength();
        }
        else
        {
            // Iterate over the selected cells region.
            const bounds:Rectangle = getCellRegionsBounds();
            left = bounds.left;
            right = bounds.right;
            top = bounds.top;
            bottom = bounds.bottom;
        }
        
        for (var rowIndex:int = top; rowIndex < bottom; rowIndex++)
        {
            for (var columnIndex:int = left; columnIndex < right; columnIndex++)
            {
                if (containsCell(rowIndex, columnIndex))
                    cells.push(new CellPosition(rowIndex, columnIndex));
            }
        }
        
        return cells;
    }
        
    /**
     *  If the selectionMode is either <code>GridSelectionMode.SINGLE_ROW</code> or
     *  <code>GridSelectionMode.MULTIPLE_ROWS</code>, returns a list of all the
     *  selected rows.
     * 
     *  @return Vector of selected rows as row indices, or if none, a Vector 
     *  of length 0.  The row indices are relative to the Grid's dataProvider.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function allRows():Vector.<int>
    {
        if (!isRowSelectionMode())
            return new Vector.<int>(0, true);
        
        // Note: if this is changed, change the similiar code in selectionLength.

        var rows:Vector.<int>;
        
        if (selectAllFlag)
        {
            // Build a vector of all the rows except the ones in
            // selectedRowValues which is the delete list when everything is 
            // selected.
            var rowCount:int = getGridDataProviderLength();
            rows = new Vector.<int>();
            for (var rowIndex:int = 0; rowIndex < rowCount; rowIndex++)
            {
                if (containsRow(rowIndex))
                    rows.push(rowIndex);
            }
        }
        else
        {
            // Return a copy of the selected rows.
           rows = selectedRows.concat();
        }
        
        return rows;
    }

    /**
     *  If the selectionMode is <code>GridSelectionMode.MULTIPLE_ROWS</code> or
     *  <code>GridSelectionMode.MULTIPLE_CELLS</code>, selects all the rows or
     *  cells in the grid.
     * 
     *  @return true if the selection is changed.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectAll():Boolean
    {
        if (selectionMode == GridSelectionMode.MULTIPLE_ROWS || 
            selectionMode == GridSelectionMode.MULTIPLE_CELLS)
        {   
            // Do this even if selectAllFlag is already true since there might
            // be some removals that need to be cleared.
            removeSelection();
            selectAllFlag = true;
            return true;
        }
        
        return false;
     }
    
    /**
     *  Remove removes the current selection.  If <code>requireSelection</code> 
     *  is true, and the <code>selectionMode</code> is row-based, then row 0
     *  will be selected and if the <code>selectionMode</code> is cell-based,
     *  then cell 0,0 will be selected.
     * 
     *  @return true if the selection is changed.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function removeAll():Boolean
    {
        var selectionChanged:Boolean = removeSelection();
        selectionChanged = ensureRequiredSelection() || selectionChanged;
        
        return selectionChanged;
    }
            
    //----------------------------------
    //  Rows
    //----------------------------------

    /**
     *  If the selectionMode is either <code>GridSelectionMode.SINGLE_ROW</code> or
     *  <code>GridSelectionMode.MULTIPLE_ROWS</code>, determines if the row is in 
     *  the current selection. 
     * 
     *  @param rowIndex The 0-based row index relative to the Grid's 
     *  dataProvider.
     * 
     *  @return true if the row is in the selection
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function containsRow(rowIndex:int):Boolean
    {
        if (!validateIndex(rowIndex))
            return false;

        const found:Boolean = selectedRows.indexOf(rowIndex) != -1;
        
        return selectAllFlag ? !found : found;
    }
    
    /**
     *  If the selectionMode is <code>GridSelectionMode.MULTIPLE_ROWS</code>, 
     *  determines if the rows are in the current selection.
     * 
     *  @param rowIndex The 0-based row index relative to the Grid's 
     *  dataProvider.
     * 
     *  @return true if the rows are in the selection
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function containsRows(rowsIndices:Vector.<int>):Boolean
    {
        if (!validateIndices(rowsIndices))
            return false;
        
        const selectedRows:Vector.<int> = allRows();
        
        if (selectedRows.length >= rowsIndices.length)
        {
            for each (var rowIndex:int in rowsIndices)
            {
                if (selectedRows.indexOf(rowIndex) == -1)
                    return false;
            }
            return true;
        }
        
        return false;
    }
    
    /**
     *  If the selectionMode is either <code>GridSelectionMode.SINGLE_ROW</code> 
     *  or <code>GridSelectionMode.MULTIPLE_ROWS</code>, replaces the current 
     *  selection with the given row.
     * 
     *  @param rowIndex The 0-based row index relative to the Grid's 
     *  dataProvider.
     * 
     *  @return True if no errors, or false if the 
     *  <code>rowIndex</code> is not a valid index in <code>dataProvider</code> 
     *  or the selectionMode is not valid.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */    
    public function setRow(rowIndex:int):Boolean
    {        
        if (!validateIndex(rowIndex))
            return false;
        
        removeSelection();
        
        selectedRows.length = 1;
        selectedRows[0] = rowIndex;
        
        if (preserveSelection)
            selectedRowValues[rowIndex] = grid.getDataProviderItem(rowIndex);
    
        return true;
    }
    
    /**
     *  If the selectionMode is <code>GridSelectionMode.MULTIPLE_ROWS</code>, 
     *  adds the row to the selection.
     * 
     *  @param rowIndex The 0-based row index relative to the Grid's 
     *  dataProvider.
     * 
     *  @return True if no errors, or false if the 
     *  <code>rowIndex</code> is not a valid index in <code>dataProvider</code> 
     *  or the selectionMode is not valid.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */    
    public function addRow(rowIndex:int):Boolean
    {
        if (!validateIndex(rowIndex))
            return false;
             
        if (selectionMode != GridSelectionMode.MULTIPLE_ROWS)
            return false;
        
        if (selectAllFlag)
        {
            // Remove the row from the delete list.
            removeRowFromSelectedRows(rowIndex);
        }
        else
        {
            // Add the row if it isn't already in the selection.
            addRowToSelectedRows(rowIndex);
        }
        
        return true;
   }
    
    /**
     *  If the selectionMode is either <code>GridSelectionMode.SINGLE_ROW</code> 
     *  or <code>GridSelectionMode.MULTIPLE_ROWS</code>, removes the row from 
     *  the selection.
     * 
     *  @param rowIndex The 0-based row index relative to the Grid's 
     *  dataProvider.
     * 
     *  @return True if no errors, or false if the 
     *  <code>rowIndex</code> is not a valid index in <code>dataProvider</code> 
     *  or the selectionMode is not valid.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */    
    public function removeRow(rowIndex:int):Boolean
    {
        if (!validateIndex(rowIndex) )
            return false;
        
        if (requireSelection && containsRow(rowIndex) && selectionLength == 1)
            return false;
                            
        if (selectAllFlag)
        {
            // Add the row to the delete list.
            addRowToSelectedRows(rowIndex);
        }
        else
        {
            // Delete the row if is in the selection.
            removeRowFromSelectedRows(rowIndex);
        }
        
        return true;
    }
    
    /**
     *  If the selectionMode is <code>GridSelectionMode.MULTIPLE_ROWS</code>, 
     *  replaces the current selection with the rows starting at 
     *  <code>startRowIndex</code> and ending with <code>endRowIndex</code>.
     * 
     *  @param rowIndex 0-based row index of the first row in the selection.
     *  @param rowCount Number of rows in the selection.
     * 
     *  @return True if no errors, or false if any of the indices are invalid
     *  or <code>startRowIndex</code> is not less than or equal to <code>endRowIndex</code>
     *  or the selectionMode is not valid.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */    
    public function setRows(rowIndex:int, rowCount:int):Boolean
    {
        // ToDo: convert selection to use rowRange internally
        // For now, just change the API to use it.
                
         if (rowCount < 0)
            return false;
        
        const rowIndices:Vector.<int> = new Vector.<int>(rowCount, true);
        const endRowIndex:int = rowIndex + rowCount - 1;
        for (var i:int = rowIndex; i <= endRowIndex; i++)
        {
            rowIndices[i - rowIndex] = i;
        }                 
        
        if (!validateIndices(rowIndices))
            return false;
       
        removeSelection();
            
        for each (var rowIndex:int in rowIndices)
        {
            addRowToSelectedRows(rowIndex);
        }
        
        return true;
    }
     
    //----------------------------------
    //  Cells
    //----------------------------------

    /**
     *  If the selectionMode is either 
     *  <code>GridSelectionMode.SINGLE_CELLS</code> 
     *  or <code>GridSelectionMode.MULTIPLE_CELLS</code>, determines if the cell 
     *  is in the current selection.
     * 
     *  @param rowIndex The 0-based row index relative to the Grid's 
     *  dataProvider.
     * 
     *  @param columnsIndex The 0-based column index relative to the Grid's 
     *  columns.
     * 
     *  @return true if the cell is in the selection.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function containsCell(rowIndex:int, columnIndex:int):Boolean
    {   
        if (!validateCell(rowIndex, columnIndex))
            return false;
                
        return CellRegion.regionsContainCell(
                            selectAllFlag, cellRegions, rowIndex, columnIndex);
    }
        
    /**
     *  If the selectionMode is
     *  <code>GridSelectionMode.MULTIPLE_CELLS</code>, determines if all the 
     *  cells in the cell region are in the current selection.
     * 
     *  @param rowIndex The 0-based row index relative to the Grid's 
     *  dataProvider.
     * 
     *  @param columnsIndex The 0-based column index relative to the Grid's 
     *  columns.
     * 
     *  @param rowCount In number of cells, the height of the cell region.
     * 
     *  @param columnsCount In number of cells, the width of the cell region.
     * 
     *  @return true if the cells are in the selection.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function containsCellRegion(rowIndex:int, columnIndex:int,
                                       rowCount:int, columnCount:int):Boolean
    {
        if (!validateCellRegion(rowIndex, columnIndex, rowCount, columnCount))
            return false;
        
        const bottom:int = rowIndex + rowCount;
        const right:int = columnIndex + columnCount;
        
        for (var r:int = rowIndex; r < bottom; r++)
        {
            for (var c:int = columnIndex; c < right; c++)
            {
                if (!containsCell(r, c))
                    return false;
            }
        }
        
        return true;
    }
        
    /**
     *  If the selectionMode is either <code>GridSelectionMode.SINGLE_CELLS</code> 
     *  or <code>GridSelectionMode.MULTIPLE_CELLS</code>, replaces the current 
     *  selection with the cell at the given location.
     * 
     *  @param rowIndex The 0-based row index relative to the Grid's 
     *  dataProvider.
     * 
     *  @param columnsIndex The 0-based column index relative to the Grid's 
     *  columns.
     * 
     *  @return true no errors or false, if 
     *  <code>rowIndex</code> is not a valid index in <code>dataProvider</code> 
     *  or <code>columnIndex</code> is not a valid index in <code>columns</code>
     *  or the selectionMode is invalid.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */    
    public function setCell(rowIndex:int, columnIndex:int):Boolean
    {
        if (!validateCell(rowIndex, columnIndex))
            return false;
        
        removeSelection();
        addCellRegion(rowIndex, columnIndex, 1, 1);
        
        return true;
    }
        
    /**
     *  If the selectionMode is <code>GridSelectionMode.MULTIPLE_CELLS</code>, 
     *  adds the cell at the given location to the cell selection.
     * 
     *  @param rowIndex The 0-based row index relative to the Grid's 
     *  dataProvider.
     * 
     *  @param columnsIndex The 0-based column index relative to the Grid's 
     *  columns.
     * 
     *  @return true no errors or false, if 
     *  <code>rowIndex</code> is not a valid index in <code>dataProvider</code> 
     *  or <code>columnIndex</code> is not a valid index in <code>columns</code>
     *  or the selectionMode is invalid.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */    
    public function addCell(rowIndex:int, columnIndex:int):Boolean
    {   
        if (!validateCellRegion(rowIndex, columnIndex, 1, 1))
            return false;
        
        if (selectAllFlag)
            removeCellRegion(rowIndex, columnIndex, 1, 1);
        else
            addCellRegion(rowIndex, columnIndex, 1, 1);
        
        return true;
    }

    /**
     *  If the selectionMode is either <code>GridSelectionMode.SINGLE_CELL</code>
     *  or <code>GridSelectionMode.MULTIPLE_CELLS</code>, removes the cell at the
     *  given position from the cell selection.
     * 
     *  @param rowIndex The 0-based row index relative to the Grid's 
     *  dataProvider.
     * 
     *  @param columnsIndex The 0-based column index relative to the Grid's 
     *  columns.
     * 
     *  @return true if no errors, or false, if <code>rowIndex</code>
     *  is not a valid index in <code>dataProvider</code> or 
     *  <code>columnIndex</code> is not a valid index in <code>columns</code>
     *  or the selectionMode is invalid.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */    
    public function removeCell(rowIndex:int, columnIndex:int):Boolean
    {
        if (!validateCell(rowIndex, columnIndex))
            return false;

        if (requireSelection && containsCell(rowIndex, columnIndex) && selectionLength == 1)
            return false;
        
        if (selectAllFlag)
            addCellRegion(rowIndex, columnIndex, 1, 1);
        else        
            removeCellRegion(rowIndex, columnIndex, 1, 1);
        
        return true;
    }

    /**
     *  If the selectionMode is <code>GridSelectionMode.MULTIPLE_CELLS</code>, 
     *  replaces the current selection with the cells in the given cell region.
     *  The origin of the cell region is the cell location specified by
     *  <code>rowIndex</code> and <code>columnIndex</code>, the width is
     *  <code>columnCount</code> and the height is <code>rowCound</code>.
     * 
     *  @param rowIndex The 0-based row index of the origin, relative to the 
     *  Grid's dataProvider.
     * 
     *  @param columnsIndex The 0-based column index of the origin, relative to 
     *  the Grid's columns.
     * 
     *  @param rowCount In number of cells, the height of the cell region.
     * 
     *  @param columnsCount In number of cells, the width of the cell region.
     * 
     *  @return true if no errors, or false, if 
     *  <code>rowIndex</code> is not a valid index in <code>dataProvider</code> 
     *  or <code>columnIndex</code> is not a valid index in <code>columns</code>
     *  or the selectionMode is invalid.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */    
    public function setCellRegion(rowIndex:int, columnIndex:int, 
                                  rowCount:uint, columnCount:uint):Boolean
    {
        if (!validateCellRegion(rowIndex, columnIndex, rowCount, columnCount))
            return false;
                       
        removeSelection();
        addCellRegion(rowIndex, columnIndex, rowCount, columnCount);
        
        return true;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
        
    /**
     *  @private
     */
    private function isRowSelectionMode():Boolean
    {
        const mode:String = selectionMode;       
        return mode == GridSelectionMode.SINGLE_ROW || 
                mode == GridSelectionMode.MULTIPLE_ROWS;
    }
    
    /**
     *  @private
     */
    private function isCellSelectionMode():Boolean
    {
        const mode:String = selectionMode;        
        return mode == GridSelectionMode.SINGLE_CELL || 
                mode == GridSelectionMode.MULTIPLE_CELLS;
    }     
    
    /**
     *  @private
     */
    private function getGridColumnsLength():uint
    {
        if (grid == null)
            return 0;
        
        const columns:IList = grid.columns;
        return (columns) ? columns.length : 0;
    }
    
    /**
     *  @private
     */
    private function getGridDataProviderLength():uint
    {
        if (grid == null)
            return 0;
        
        const dataProvider:IList = grid.dataProvider;
        return (dataProvider) ? dataProvider.length : 0;
    }    
    
    /**
     *  @private
     *  True if one or more rows is selected.  There can be either selected
     *  rows or selected cells so if this is true it imples there are no
     *  selected cells.
     */    
    private function hasRowSelection():Boolean
    {
        return isRowSelectionMode() && selectionLength > 0;
    }
    
    /**
     *  @private
     *  True if one or more cells is selected.  There can be either selected
     *  rows or selected cells so if this is true it imples there are no
     *  selected rows.
     */    
    private function hasCellSelection():Boolean
    {   
        return isCellSelectionMode() && selectionLength > 0;
    }
    
    /**
     *  @private
     *  If requiredSelection, then there must always be at least one row/cell
     *  selected.
     * 
     *  @return true if the selection has changed.
     */    
    private function ensureRequiredSelection():Boolean
    {
        var selectionChanged:Boolean;
        
        if (!requireSelection)
            return false;
        
        if (getGridDataProviderLength() == 0 || getGridColumnsLength() == 0)
             return false;
        
        // If there isn't a selection, set one, using the grid method rather
        // than the internal one, so that the caretPosition will be updated too.
        if (isRowSelectionMode())
        {
            if (!hasRowSelection())
                selectionChanged = grid.setSelectedIndex(0);
        }
            else if (isCellSelectionMode())
        {
            if (!hasCellSelection())
                selectionChanged = grid.setSelectedCell(0, 0);
        }
                
        return selectionChanged;
    }
    
    /**
     *  @private
     *  Remove any currently selected rows, cells and cached items.  This
     *  disregards the requireSelection flag.
     * 
     *  @return true if the selection has changed.
     */    
    private function removeSelection():Boolean
    {
        const hasSelection:Boolean = selectionLength > 0;
        
        selectedRows.length = 0;
        cellRegions.length = 0;
        
        // Remove cached data items.
        selectedRowValues.length = 0;
        
        selectAllFlag = false;
        
        return hasSelection;
    }
    
    /**
     *  @private
     *  Return true if the selection has changed.
     */    
    private function addRowToSelectedRows(rowIndex:int):Boolean
    {
        const offset:int = selectedRows.indexOf(rowIndex);
        if (offset == -1)
        {
            selectedRows.push(rowIndex);    
            if (preserveSelection)
                selectedRowValues[rowIndex] = grid.getDataProviderItem(rowIndex);
            return true;
        }
        
        return false;
    }
    
    /**
     *  @private
     *  Return true if the selection has changed.
     */    
    private function removeRowFromSelectedRows(rowIndex:int):Boolean
    {
        const offset:int = selectedRows.indexOf(rowIndex);
        if (offset != -1)
        {
            selectedRows.splice(offset, 1);        
            if (preserveSelection)
                delete selectedRowValues[rowIndex];
            return true;
        }
        
        return false;
    }
    
    /**
     *  @private
     *  True if the selection mode is row-based and the 0-based index is 
     *  valid index in the <code>dataProvider</code>.
     */    
    protected function validateIndex(index:int):Boolean
    {
        // Don't validate.
        if (inCollectionHandler)
            return true;
        
        return isRowSelectionMode() && 
            index >= 0 && index < getGridDataProviderLength();
    }
    
    /**
     *  @private
     *  True if the selection mode is <code>GridSelectionMode.MULTIPLE_ROWS</code>
     *  and each index in indices is a valid index into the 
     *  <code>dataProvider</code>.
     */    
    protected function validateIndices(indices:Vector.<int>):Boolean
    {
        if (selectionMode == GridSelectionMode.MULTIPLE_ROWS)
        {
            // Don't validate.
            if (inCollectionHandler)
                return true;

            for each (var index:int in indices)
            {
                if (index < 0 || index >= getGridDataProviderLength())
                    return false;
            }            
            return true;
        }
        
        return false;
    }
    
    /**
     *  @private
     *  True if the selection mode is <code>GridSelectionMode.SINGLE_CELL</code>
     *  or code>GridSelectionMode.MULTIPLE_CELLS</code>
     *  and the 0-based index is valid index in <code>columns</code>.
     */    
    protected function validateCell(rowIndex:int, columnIndex:int):Boolean
    {
        // Don't validate.
        if (inCollectionHandler)
            return true;

        return isCellSelectionMode() && 
            rowIndex >= 0 && rowIndex < getGridDataProviderLength() &&
            columnIndex >= 0 && columnIndex < getGridColumnsLength();
    }
    
    /**
     *  @private
     *  True if the selection mode is 
     *  <code>GridSelectionMode.MULTIPLE_CELLS</code> and the entire cell region 
     *  is contained within the grid.
     */    
    protected function validateCellRegion(rowIndex:int, columnIndex:int, 
                                          rowCount:int, columnCount:int):Boolean
    {
        if (selectionMode == GridSelectionMode.MULTIPLE_CELLS)
        {
            // Don't validate.
            if (inCollectionHandler)
                return true;

            const maxRows:int = getGridDataProviderLength();
            const maxColumns:int = getGridColumnsLength();
            return (rowIndex >= 0 && rowCount >= 0 &&
                    rowIndex + rowCount <= maxRows &&
                    columnIndex >= 0 && columnCount >= 0 &&
                    columnIndex + columnCount <= maxColumns);
        }
        
        return false;       
    }
    
    /**
     *  @private
     *  Remove all cell regions that are completely contained by cr and then 
     *  append cr to cellRegions.
     */
    private function filterCellRegions(cr:CellRegion):void
    {
        const containsCR:Function = 
            function(item:CellRegion, index:int, vector:Vector.<CellRegion>):Boolean 
        {
            // Return true to add item to returned Vector.
            return cr.isAdd != item.isAdd || !cr.containsRegion(item);
        };
        cellRegions = cellRegions.filter(containsCR);
        cellRegions.push(cr);
    }
    
    /**
     *  @private
     *  Add the given cell region to the list of cellRegions.
     */
    private function addCellRegion(rowIndex:int, columnIndex:int, 
                                   rowCount:uint, columnCount:uint):void
    {
        //trace("addCellRegion", rowIndex, columnIndex, rowCount, columnCount);
        
        filterCellRegions(new CellRegion(rowIndex, columnIndex, 
                                         rowCount, columnCount, true));
        
        if (preserveSelection)
        {
            const endRowIndex:int = rowIndex + rowCount;
            while (rowIndex < endRowIndex)
            {
                if (selectedRowValues[rowIndex] === undefined)
                {
                    selectedRowValues[rowIndex] = 
                        grid.getDataProviderItem(rowIndex);
                }
                rowIndex++;
            }
        }
    }
       
    /**
     *  @private
     *  Remove the given cell region to the list of cellRegions.
     */
    private function removeCellRegion(rowIndex:int, columnIndex:int, 
                                      rowCount:uint, columnCount:uint,
                                      removePreservedSelection:Boolean=false):void
    {
        //trace("removeCellRegion", rowIndex, columnIndex, rowCount, columnCount);

        filterCellRegions(new CellRegion(rowIndex, columnIndex, 
            rowCount, columnCount, false));
                
        // By default, the selectedRowValues aren't removed since there 
        // could be other cell regions that contain these rows.  The caller
        // knows the context so let it decide.
        if (removePreservedSelection && preserveSelection)
        {
            const endRowIndex:int = rowIndex + rowCount;
            for (var i:int = rowIndex; i < endRowIndex; i++)
            {
                if (selectedRowValues[rowIndex] !== undefined)
                    selectedRowValues[rowIndex] = null;
            }
        }    
    }
       
    /**
     *  @private
     *  Find the bounding box for all the added cell regions.  It could be
     *  larger than the current selection region if cell regions have been
     *  removed.
     */
    private function getCellRegionsBounds():Rectangle
    {
        var bounds:Rectangle = new Rectangle();
        
        const cellRegionsLength:int = cellRegions.length;
        for (var i:int = 0; i < cellRegionsLength; i++)
        {
            var cr:CellRegion = cellRegions[i];
            if (!cr.isAdd)
                continue;
                
            bounds = bounds.union(cr);
        }
        
        return bounds;
    }
       
    /**
     *  @private
     *  Move all the selected cells in row oldRowIndex to newRowIndex.  No
     *  other adjustments are made to the selection.
     */
    private function moveCellsInRow(oldRowIndex:int, newRowIndex:int, 
                                    bounds:Rectangle=null):Boolean
    {
        var elementChanged:Boolean;
    
        if (bounds == null)
            bounds = getCellRegionsBounds();
        
        const firstIndex:int = bounds.left;
        const lastIndex:int = bounds.right;
        
        for (var columnIndex:int = firstIndex; columnIndex < lastIndex; 
            columnIndex++)
        {
            if (containsCell(oldRowIndex, columnIndex))
            {
                removeCellRegion(oldRowIndex, columnIndex, 1, 1, true);
                addCellRegion(newRowIndex, columnIndex, 1, 1);
                elementChanged = true;
            }
        }

        if (elementChanged && preserveSelection)
        {
            selectedRowValues[newRowIndex] = selectedRowValues[oldRowIndex];
            delete selectedRowValues[oldRowIndex];
        }
        
        return elementChanged;
    }
    
    /**
     *  @private
     *  Remove all the selected cells in row rowIndex.  No other adjustments to
     *  the selection are made.
     */
    private function removeCellsInRow(rowIndex:int, 
                                      bounds:Rectangle=null):Boolean
    {
        var elementChanged:Boolean;
        
        if (bounds == null)
            bounds = getCellRegionsBounds();
        
        const firstIndex:int = bounds.left;
        const lastIndex:int = bounds.right;
        
        for (var columnIndex:int = firstIndex; columnIndex < lastIndex; 
             columnIndex++)
        {
            if (containsCell(rowIndex, columnIndex))
            {
                removeCellRegion(rowIndex, columnIndex, 1, 1, true);
                elementChanged = true;
            }
        }
        
        if (elementChanged && preserveSelection)
            delete selectedRowValues[rowIndex];
        
        return elementChanged;
    }
       
    //--------------------------------------------------------------------------
    //
    //  Data Provider Collection methods
    //
    //-------------------------------------------------------------------------- 

    /**
     *  Called when the grid's dataProvider dispatches a 
     *  <code>CollectionEvent.COLLECTION_CHANGE</code> event.  It handles
     *  each of the events defined in <code>CollectionEventKind</code>.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function dataProviderCollectionChanged(event:CollectionEvent):Boolean
    {
        inCollectionHandler = true;
        
        var result:Boolean;
        
        switch (event.kind)
        {
            case CollectionEventKind.ADD: 
            {
                result = dataProviderCollectionAdd(event);
                break;
            }
                
            case CollectionEventKind.MOVE:
            {
                result = dataProviderCollectionMove(event);
                break;
            }

            case CollectionEventKind.REFRESH:
            {
                result = dataProviderCollectionRefresh(event);
                break;
            }

            case CollectionEventKind.REMOVE:
            {
                result = dataProviderCollectionRemove(event);
                break;
            }
                
            case CollectionEventKind.REPLACE:
            {
                result = dataProviderCollectionReplace(event);
                break;
            }
                
            case CollectionEventKind.RESET:
            {
                result = dataProviderCollectionReset(event);
                break;
            }

            case CollectionEventKind.UPDATE:
            {
                result = dataProviderCollectionUpdate(event);
                break;
            }                
        }
        
        inCollectionHandler = false;
        
        return result;
    }
        
    /**
     *  @private
     *  Add an item to the collection.
     */
    private function dataProviderCollectionAdd(event:CollectionEvent):Boolean
    {
        // If a pure selectAll, with nothing on the removal list, then there
        // is nothing that needs to be done.  If there is anything on the
        // removal list, their indices may need to be updated.
        if (selectAllFlag && selectedRows.length == 0 && cellRegions.length == 0)
            return true;
        
        const insertIndex:int = event.location;
        const insertLength:int = event.items.length;
        
        var elementChanged:Boolean;
        
        // All selected rows/cells at the insertIndex and below need to be shifted
        // down by the insertLength.
        
        if (hasRowSelection())
            elementChanged = adjustRowsAfterAdd(insertIndex, insertLength);
        else if (hasCellSelection())
            elementChanged = adjustCellsAfterAdd(insertIndex, insertLength);
        
        // If a selection is required and these are the first items to be
        // added make sure there is a selection now.
        ensureRequiredSelection();
        
        return elementChanged;        
    }

    /**
     *  @private
     *  Handle add event for selected rows.
     */
    private function adjustRowsAfterAdd(insertIndex:int, insertLength:int):Boolean
    {
        var elementChanged:Boolean;
        
        // All selected rows at the insertIndex and below need to be shifted
        // down by the insertLength.
        
        const selectedRowsLength:int = selectedRows.length;
        for (var i:int = 0; i < selectedRowsLength; i++)
        {
            var rowIndex:int = selectedRows[i];
            if (rowIndex >= insertIndex)
            {
                var newRowIndex:int = rowIndex + insertLength;
                selectedRows[i] = newRowIndex;
                
                if (preserveSelection)
                {
                    selectedRowValues[newRowIndex] = selectedRowValues[rowIndex];                
                    delete selectedRowValues[rowIndex];
                }
                
                elementChanged = true;
            }
        }

        return elementChanged;        
    }

    /**
     *  @private
     *  Handle add event for selected cells.
     */
    private function adjustCellsAfterAdd(insertIndex:int, insertLength:int):Boolean
    {        
        var elementChanged:Boolean;
        
        // Any selected cells with a rowIndex >= insertIndex have to be removed
        // and readded at rowIndex + insertLength.
            
        const bounds:Rectangle = getCellRegionsBounds();
        if (bounds.bottom >= insertIndex)
        {        
            const firstRowIndex:int = Math.max(insertIndex, bounds.top);
            for (var rowIndex:int = bounds.bottom - 1; 
                 rowIndex >= firstRowIndex; rowIndex--)
            {
                if (moveCellsInRow(rowIndex, rowIndex + insertLength, bounds))
                    elementChanged = true;
            }
        }
        
        return elementChanged;        
    }

    /**
     *  @private
     *  The item has been moved from the oldLocation to location.
     */
    private function dataProviderCollectionMove(event:CollectionEvent):Boolean
    {
        // FIXME: this needs to be reviewed/tested for correctness!!!
               
        // If a pure selectAll, with nothing on the removal list, then there
        // is nothing that needs to be done.  If there is anything on the
        // removal list, their indices may need to be updated.
        if (selectAllFlag && selectedRows.length == 0 && cellRegions.length == 0)
            return true;

        var elementChanged:Boolean;
                
        const oldRowIndex:int = event.oldLocation;
        const newRowIndex:int = event.location;
        
        // If the row or cells were selected in the old location, move
        // the selection to the new location, adjusting any other selections
        // that are impacted by the move.
        if (hasRowSelection())
        {
            adjustRowsAfterRemove(oldRowIndex, oldRowIndex);

            // If the row is removed before the newly added item
            // then change index to account for this.
            if (newRowIndex > oldRowIndex)
                newRowIndex--;
            
            adjustRowsAfterAdd(newRowIndex, 1);
            
            elementChanged = true;
        }
        else if (hasCellSelection())
        {
            const bounds:Rectangle = this.getCellRegionsBounds();
            const selectedCellColumns:Vector.<int> = new Vector.<int>();
            
            // Remember the selected cells in the old location.
            for (var columnIndex:int = bounds.left;
                 columnIndex < bounds.right; columnIndex++)
            {
                if (containsCell(oldRowIndex, columnIndex))
                    selectedCellColumns.push(columnIndex);
            }

            // Remove the old row, adjusting the cell selection locations for
            // cells in rows after this row.
            adjustCellsAfterRemove(oldRowIndex, oldRowIndex);

            // If the cells are removed before the newly added item
            // then change index to account for this.
            if (newRowIndex > oldRowIndex)
                newRowIndex--;

            // Add in the new row, adjusting the cell selection locations for
            // cells in rows after this row.
            adjustCellsAfterAdd(newRowIndex, 1);
            
            // Now reset the selected cells in the new location.
            for each (columnIndex in selectedCellColumns)
            {
                addCellRegion(newRowIndex, columnIndex, 1, 1);
            }
            
            elementChanged = true;
        }
        
        return elementChanged;
    }

    /**
     *  @private
     *  The sort or filter on the collection changed.
     */
    private function dataProviderCollectionRefresh(event:CollectionEvent):Boolean
    {
        // Not preserving selection so this is similiar to a RESET.
        if (!preserveSelection)
        {            
            removeSelection();
            ensureRequiredSelection();
            return true;
        }
        
        // If a pure selectAll, with nothing on the removal list, then there
        // is nothing that needs to be done.  If there is anything on the
        // removal list, their indices may need to be updated.
        if (selectAllFlag && selectedRows.length == 0 && cellRegions.length == 0)
            return true;
           
        // Nothing preserved, so don't bother looking.
        if (selectedRowValues.length == 0)
            return true;
        
        if (isRowSelectionMode())
            adjustRowsAfterRefresh();        
       else if (isCellSelectionMode())
            adjustCellsAfterRefresh();
        
        ensureRequiredSelection();
        
        return true;
    }
        
    /**
     *  @private
     *  Sort or filter on collection changed.  Update selected rows.
     */
    private function adjustRowsAfterRefresh():Boolean
    {
        // Make a pass thru the saved items, and if the item is still in 
        // the data provider, keep it in the selection, else remove it from 
        // the selection.        
        selectedRows.length = 0;            
        for each (var item:Object in selectedRowValues)
        {
            // Is this selected row still in the dataProvider?
            var itemIndex:int = grid.getDataProviderItemIndex(item);
            
            // Yes, so select it at its current position.
            if (itemIndex != -1)
            {
                selectedRows.push(itemIndex);
            }
        }
        
        return true;
    }
        
    /**
     *  @private
     *  Sort or filter on collection changed.  Update selected cells.
     */
    private function adjustCellsAfterRefresh():Boolean
    {
        // Make a pass thru the saved items, and if the item is still in 
        // the data provider, keep it in the selection, else remove it from 
        // the selection.        
        
        // FIXME(cframpto): this only works for the first refresh since the
        // selection before the refresh which is in cellRegions is overwritten
        
        var oldCellRegions:Vector.<CellRegion> = cellRegions;
        cellRegions = new Vector.<CellRegion>();
        
        const columnCount:int = getGridColumnsLength();
        const selectedRowValuesLength:int = selectedRowValues.length;
        
        for (var oldRowIndex:int = 0; oldRowIndex < selectedRowValuesLength; 
            oldRowIndex++)
        {
            if (selectedRowValues[oldRowIndex] === undefined)
                continue;
            
            var item:Object = selectedRowValues[oldRowIndex];
            
            // Is this selected row still in the dataProvider?  Did the
            // rowIndex change?
            var itemIndex:int = grid.getDataProviderItemIndex(item);
            if (itemIndex < 0)
                continue;
            
            // Any selected cells in the old row need to be selected
            // in the new row.
            for (var columnIndex:int = 0; columnIndex < columnCount; columnIndex++)
            {
                if (CellRegion.regionsContainCell(
                        selectAllFlag, oldCellRegions, oldRowIndex, columnIndex))
                {
                    addCell(itemIndex, columnIndex);
                }
            }
        }
                
        return true;
    }
    
    /**
     *  @private
     *  An item has been removed from the collection.
     */
    private function dataProviderCollectionRemove(event:CollectionEvent):Boolean
    {
        // If a pure selectAll, with nothing on the removal list, then there
        // is nothing that needs to be done.  If there is anything on the
        // removal list, their indices may need to be updated.
        if (selectAllFlag && selectedRows.length == 0 && cellRegions.length == 0)
            return true;
               
        const firstRemoveIndex:int = event.location;
        const lastRemoveIndex:int = event.location + event.items.length - 1;
  
        var elementChanged:Boolean;
        
        if (selectedRows.length)
            elementChanged = adjustRowsAfterRemove(firstRemoveIndex, lastRemoveIndex);
        else if (cellRegions.length)
            elementChanged = adjustCellsAfterRemove(firstRemoveIndex, lastRemoveIndex);
        
        // If a selection is required and there isn't one after the deletion,
        // select the item that took the place of the first item that was
        // deleted, except if the last item was deleted, select the new last
        // item.
        
        if (elementChanged && requireSelection)
        {        
            var dataProviderLength:int = getGridDataProviderLength();
            if (dataProviderLength > 0)
            {
                const rowIndex:int = firstRemoveIndex <= dataProviderLength - 1 ? 
                                     firstRemoveIndex : dataProviderLength - 1;
                if (isRowSelectionMode() && !hasRowSelection())
                        setRow(rowIndex);
                else if (isCellSelectionMode() && !hasCellSelection())
                        setCell(rowIndex, 0);
                }
            }

        return elementChanged;
    }
 
    /**
     *  @private
     *  Item removed.  Update selected rows.
     */
    private function adjustRowsAfterRemove(firstRemoveIndex:int, 
                                           lastRemoveIndex:int):Boolean
    {        
        var elementChanged:Boolean;
        
        // Compute the range of selectedRows elements affected by the remove 
        // event, and (while we're at it), decrement the visibleRowIndices 
        // elements which are "to the right" of the range.
        
        var firstVisibleOffset:int = -1; // remove selectedRows[firstVisibleOffset] 
        var lastVisibleOffset:int = -1;  // ... through visibleRowIndices[lastVisibleOffset]
        
        const selectedRowsLength:int = selectedRows.length;
        for (var offset:int = 0; offset < selectedRowsLength; offset++)
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
            {
                const newRowIndex:int = rowIndex - 1;
                if (preserveSelection)
                {
                    selectedRowValues[newRowIndex] = 
                        selectedRowValues[rowIndex];                
                    delete selectedRowValues[rowIndex];
                }
                selectedRows[offset] = newRowIndex;
                elementChanged = true;
            }   
        }
        
        if ((firstVisibleOffset != -1) && (lastVisibleOffset != -1))
        {
            // FIXME: so this is assuming selectedRows is in some kind of order??
            var removeCount:int = (lastVisibleOffset - firstVisibleOffset) + 1; 
            selectedRows.splice(firstVisibleOffset, removeCount);
            elementChanged = true;
            
            if (preserveSelection)
            {
                for (rowIndex = firstVisibleOffset; 
                    rowIndex <= lastVisibleOffset; rowIndex++)
                {
                    delete selectedRowValues[rowIndex];
                }
            }
        }
        
        return elementChanged;        
    }

    /**
     *  @private
     *  Item removed.  Update selected cells.
     */
    private function adjustCellsAfterRemove(firstRemoveIndex:int, 
                                             lastRemoveIndex:int):Boolean
    {
        var elementChanged:Boolean;
        
        const bounds:Rectangle = this.getCellRegionsBounds();
        
        for (var rowIndex:int = firstRemoveIndex; rowIndex < bounds.bottom; 
             rowIndex++)
        {
            if ((rowIndex >= firstRemoveIndex) && (rowIndex <= lastRemoveIndex))
            {
                if (removeCellsInRow(rowIndex, bounds))
                    elementChanged = true;
            }
            else if (rowIndex > lastRemoveIndex)
            {
                if (moveCellsInRow(rowIndex, rowIndex - 1, bounds))               
                    elementChanged = true;
            }
        }
        
        return elementChanged;        
    }
    
    /**
     *  @private
     *  The item has been replaced.
     */
    private function dataProviderCollectionReplace(event:CollectionEvent):Boolean
    {
        // If a pure selectAll, with nothing on the removal list, then there
        // is nothing that needs to be done.  If there is anything on the
        // removal list, their indices may need to be updated.
        if (selectAllFlag && selectedRows.length == 0 && cellRegions.length == 0)
            return true;
        
        var elementChanged:Boolean;
       
        if (preserveSelection && selectedRowValues.length > 0)
        {
            const rowIndex:int = event.location;            
            if (selectedRowValues[rowIndex] !== undefined)
            {
                selectedRowValues[rowIndex] = grid.getDataProviderItem(rowIndex);
                elementChanged = true;
            }
        }
        
        return elementChanged;
    }
    
    /**
     *  @private
     *  The data source changed so don't preserve the selection.  Clear the
     *  selectAll flag if set.
     */
    private function dataProviderCollectionReset(event:CollectionEvent):Boolean
    {
        removeSelection();
        ensureRequiredSelection();
        
        return true;
    }

    /**
     *  @private
     *  One or more items in the collection have been updated.
     */
    private function dataProviderCollectionUpdate(event:CollectionEvent):Boolean
    {
        // If a pure selectAll, with nothing on the removal list, then there
        // is nothing that needs to be done.  If there is anything on the
        // removal list, their indices may need to be updated.
        if (selectAllFlag && selectedRows.length == 0 && cellRegions.length == 0)
            return true;
        
        var elementChanged:Boolean;
               
        if (preserveSelection && selectedRowValues.length > 0)
        {
            for each (var updateInfo:PropertyChangeEvent in event.items)
            {
                if (updateInfo.property is int)
                {
                    const rowIndex:int = int(updateInfo.property);
                    if (selectedRowValues[rowIndex] !== undefined)
                    {
                        selectedRowValues[rowIndex] = updateInfo.newValue;
                        elementChanged = true;
                    }
                }
            }
        }

        return elementChanged;
    }

    //--------------------------------------------------------------------------
    //
    //  Columns Collection methods
    //
    //-------------------------------------------------------------------------- 
    
    /**
     *  Called when the grid's columns dispatches a 
     *  <code>CollectionEvent.COLLECTION_CHANGE</code> event.  It handles
     *  each of the events defined in <code>CollectionEventKind</code>.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function columnsCollectionChanged(event:CollectionEvent):Boolean
    {
        inCollectionHandler = true;
        
        var result:Boolean;
        
        switch (event.kind)
        {
            case CollectionEventKind.ADD: 
            {
                result = columnsCollectionAdd(event);
                break;
            }
                
            case CollectionEventKind.MOVE:
            {
                result = columnsCollectionMove(event);
                break;
            }
                                
            case CollectionEventKind.REMOVE:
            {
                result = columnsCollectionRemove(event);
                break;
            }
                
            case CollectionEventKind.REPLACE:
            case CollectionEventKind.UPDATE:
            {
                result = true;
                break;
            }
                
            case CollectionEventKind.REFRESH:
            {
                result = columnsCollectionRefresh(event);
                break;                
            }
            case CollectionEventKind.RESET:
            {
                result = columnsCollectionReset(event);
                break;                
           }
        }
        
        inCollectionHandler = false;
        
        return result;
    }

    /**
     *  @private
     *  Add an column to the columns collection.
     */
    private function columnsCollectionAdd(event:CollectionEvent):Boolean
    {
        // If no selectionMode or a row-based selectionMode, nothing to do.
        if (!isCellSelectionMode())
            return true;
        
        // If a pure selectAll with no cell removals, return.
        if (selectAllFlag && cellRegions.length == 0)
            return true;
        
        const insertIndex:int = event.location;
        const insertLength:int = event.items.length;
        
        var elementChanged:Boolean;
        
        // Any selected cells with a rowIndex >= insertIndex have to be removed
        // and readded at rowIndex + insertLength.
        
        const bounds:Rectangle = getCellRegionsBounds();
        if (bounds.right >= insertIndex)
        {        
            const rowCount:int = getGridDataProviderLength();            
            for (var rowIndex:int = 0; rowIndex < rowCount; rowIndex++)
            {
                const firstColumnIndex:int = Math.max(insertIndex, bounds.left);
                for (var columnIndex:int = bounds.right - 1; 
                    columnIndex >= firstColumnIndex; columnIndex--)
                {
                    if (containsCell(rowIndex, columnIndex))
                    {
                        removeCellRegion(rowIndex, columnIndex, 1, 1, true);
                        addCellRegion(rowIndex, columnIndex + insertLength, 1, 1);
                        elementChanged = true;
                    }
                 }
            }
        }
        
        ensureRequiredSelection();
        
        return elementChanged;        
    }

    /**
     *  @private
     *  The column has been moved from the oldLocation to location in the 
     *  columns collection.
     */
    private function columnsCollectionMove(event:CollectionEvent):Boolean
    {
        // If no selectionMode or a row-based selectionMode, nothing to do.
        if (!isCellSelectionMode())
            return true;
        
        // If a pure selectAll with no cell removals, return.
       if (selectAllFlag && cellRegions.length == 0)
            return true;
        
        var elementChanged:Boolean;
        
        const oldColumnIndex:int = event.oldLocation;
        const newColumnIndex:int = event.location;

        var bounds:Rectangle = getCellRegionsBounds();
        
        const firstIndex:int = bounds.top;
        const lastIndex:int = bounds.bottom;
        
        for (var rowIndex:int = firstIndex; rowIndex < lastIndex; rowIndex++)
        {
            if (containsCell(rowIndex, oldColumnIndex))
            {
                removeCellRegion(rowIndex, oldColumnIndex, 1, 1);
                addCellRegion(rowIndex, newColumnIndex, 1, 1);
                elementChanged = true;
            }
        }

        return elementChanged;
    }   

    /**
     *  @private
     *  A column has been removed from the columns collection.
     */
    private function columnsCollectionRemove(event:CollectionEvent):Boolean
    {
        // If no selectionMode or a row-based selectionMode, nothing to do.
        if (!isCellSelectionMode())
            return true;
        
        // If a pure selectAll with no cell removals, return.
        if (selectAllFlag && cellRegions.length == 0)
            return true;
                
        var elementChanged:Boolean;
        
        const firstRemoveIndex:int = event.location;
        const lastRemoveIndex:int = event.location + event.items.length - 1;
                    
        var bounds:Rectangle = getCellRegionsBounds();
        
        const firstIndex:int = bounds.top;
        const lastIndex:int = bounds.bottom;
        
        for (var rowIndex:int = firstIndex; rowIndex < lastIndex; rowIndex++)
        {
            for (var columnIndex:int = firstRemoveIndex; 
                 columnIndex <= lastRemoveIndex; columnIndex++)
            {
                if (containsCell(rowIndex, columnIndex))
                {
                    removeCellRegion(rowIndex, columnIndex, 1, 1);
                    elementChanged = true;
                }
            }
        }
            
        if (elementChanged && requireSelection)
        {        
            var dataProviderLength:int = getGridDataProviderLength();
            if (dataProviderLength > 0 && selectionLength == 0)
            {
                rowIndex = firstRemoveIndex <= dataProviderLength - 1 ? 
                           firstRemoveIndex : dataProviderLength - 1;
                setCell(rowIndex, 0);
            }
        }            

        return elementChanged;
    }
    
    /**
     *  @private
     *  The sort or filter on the collection changed.  If the selectionMode is
     *  cell-based, reset the selection.
     */
    private function columnsCollectionRefresh(event:CollectionEvent):Boolean
    {
        // If no selectionMode or a row-based selectionMode, nothing to do.
        if (!isCellSelectionMode())
            return true;
        
        // Columns changing could impact cell selection and we have no way
        // to map the column locations before the refresh to the column
        // locations after the refresh.
        removeSelection();
        ensureRequiredSelection();
        
        return true;
    }

    /**
     *  @private
     *  The columns changed.  If the selectionMode is cell-based, don't preserve 
     *  the selection.
     */
    private function columnsCollectionReset(event:CollectionEvent):Boolean
    {
        // If no selectionMode or a row-based selectionMode, nothing to do.
        if (!isCellSelectionMode())
            return true;

        removeSelection();
        ensureRequiredSelection();
            
        return true;
    }
}
}

import flash.geom.Rectangle;

internal class CellRegion extends Rectangle
{
    public var isAdd:Boolean = false;
                                     
    /**
     *  @private
     *  True if the given cell is contained in the list of cell regions.
     */
    static public function regionsContainCell(
                                selectAllFlag:Boolean,
                                regions:Vector.<CellRegion>,
                                rowIndex:int, columnIndex:int):Boolean
    {   
        // Find the index of the last isAdd=true cell region that contains 
        // row,columnIndex.
        var index:int = -1;
        for (var i:int = 0; i < regions.length; i++)
        {
            var cr:CellRegion = regions[i];
            if (cr.isAdd && cr.containsCell(rowIndex, columnIndex))
                index = i;
        }
        
        // Is there an isAdd=true CellRegion that contains the cell?
        if (index == -1) 
            return selectAllFlag;
        
        // Starting with index, if any subsequent isAdd=false cell region
        // contains row,columnIndex return false.
        for (i = index + 1; i < regions.length; i++)
        {
            cr = regions[i];
            if (!cr.isAdd && cr.containsCell(rowIndex, columnIndex))
                return selectAllFlag;
        }
        
        return !selectAllFlag;
    }
    
    public function CellRegion(rowIndex:int, columnIndex:int, rowCount:uint, 
                               columnCount:uint, isAdd:Boolean)
    {
        super(columnIndex, rowIndex, columnCount, rowCount);
        this.isAdd = isAdd;
    }
    
    public function containsRegion(cr:CellRegion):Boolean
    {
        return containsRect(cr);
    }
    
    public function containsCell(cellRowIndex:int, cellColumnIndex:int):Boolean
    {
        return contains(cellColumnIndex, cellRowIndex);
    }
}
