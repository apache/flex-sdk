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

import mx.collections.IList;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;

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
 *  setRows(rowIndex:int, rowCount:int):void
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
     *  List of ordered selected/de-selected cell regions used to represent
     *  either row or cell selections depending on the selection mode.  
     *  (For row selection, a row region will be in column 0 and column count 
     *  will be 1.)
     *
     *  If selectAllFlag==false, this is the list of cell regions that have
     *  been added (isAdd==true) and removed (isAdd==false).  If
     *  selectAllFlag==true, this is the list of cell regions that have been 
     *  removed (isAdd==true) or re-added (isAdd==false) to the selection.
     *   
     *  Internally, regionsContainCell should be used to determine if a cell/row
     *  is in the selection.
     */    
    private var cellRegions:Vector.<CellRect> = new Vector.<CellRect>();
           
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
     *  <code>dataProvider</code> refreshes its collection.
     *  The selection will be clipped if it includes rows or columns that no
     *  longer exist after the refresh.  The selection sticks to its position,
     *  not the data.
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
    }
    
    //----------------------------------
    //  requireSelection
    //----------------------------------
    
    private var _requireSelection:Boolean = false;
    
    /**
     *  If <code>true</code>, a data item must always be selected in the 
     *  control as long as there is at least one item in 
     *  <code>dataProvider</code> and one column in <code>columns</code>.
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
       
    // 
    /**
     *  @private
     *  Cache the selectionLength.  Only recalculate if selectionLength is -1.
     */
    private var _selectionLength:int = 0;    
    
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
        // Note: this assumes there are no duplicate cells in cellRegions - ie
        // 2 adds of the same cell without an intermediate delete.
        
        if (_selectionLength < 0)
        {
            _selectionLength = selectAllFlag ? 
                getGridDataProviderLength() * getGridColumnsLength() : 0;
                        
            const cellRegionsLength:int = cellRegions.length;            
            for (var i:int = 0; i < cellRegionsLength; i++)
            {
                var cr:CellRect = cellRegions[i];
                const numCells:int = cr.width * cr.height; 
               
                // Shorthand for
                // if (cr.isAdd && !selectAllFlag || !cr.isAdd && selectAllFlag)
                if (cr.isAdd != selectAllFlag)
                    _selectionLength += numCells;
                else
                    _selectionLength -= numCells;
            }
        }
        
        return _selectionLength;        
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

        // Iterate over the selected cells region.
        const bounds:Rectangle = getCellRegionsBounds();        
        const left:int = bounds.left;
        const right:int = bounds.right;
        const bottom:int = bounds.bottom;
              
        for (var rowIndex:int = bounds.top; rowIndex < bottom; rowIndex++)
        {
            for (var columnIndex:int = left; columnIndex < right; columnIndex++)
            {
                if (regionsContainCell(rowIndex, columnIndex))
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
        
        var rows:Vector.<int> = new Vector.<int>();
        
        const bounds:Rectangle = getCellRegionsBounds();
        const bottom:int = bounds.bottom;
                
        for (var rowIndex:int = bounds.top; rowIndex < bottom; rowIndex++)
        {
            // row is represented as cell in column 0 of the row   
            if (regionsContainCell(rowIndex, 0))
                rows.push(rowIndex);
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
            _selectionLength = -1;
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
        var selectionChanged:Boolean = selectionLength > 0;
        
        removeSelection();
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

        return regionsContainCell(rowIndex, 0);
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
        
        for each (var rowIndex:int in rowsIndices)
        {
            if (!regionsContainCell(rowIndex, 0))
                return false;            
        }
                
        return true;
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
    
        internalSetCellRegion(rowIndex);
                
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
        
        internalAddCell(rowIndex);

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
                            
        internalRemoveCell(rowIndex);
        
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
        if (!validateRowRegion(rowIndex, rowCount))
            return false;

        internalSetCellRegion(rowIndex, 0, rowCount, 1);
         
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
                
        return regionsContainCell(rowIndex, columnIndex);
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
        
        if (rowCount * columnCount > selectionLength)
            return false;
        
        const cellRegionsLength:int = cellRegions.length;
        
        if (cellRegionsLength == 0)
            return selectAllFlag;
        
        if (!selectAllFlag && cellRegionsLength == 1)
        {
            const cr:CellRect = cellRegions[0];
            return (rowIndex >= cr.top && columnIndex >= cr.left &&
                    rowIndex + rowCount <= cr.bottom &&
                    columnIndex + columnCount <= cr.right);
        }
        
        // Not a simple selection so we're going to have to check each cell.
        
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
        
        internalSetCellRegion(rowIndex, columnIndex, 1, 1);
        
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
        
        internalAddCell(rowIndex, columnIndex);
        
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
        
        internalRemoveCell(rowIndex, columnIndex);
        
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
                       
        internalSetCellRegion(rowIndex, columnIndex, rowCount, columnCount);
        
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
     *  True if the given cell is contained in the list of cell regions.
     */
    private function regionsContainCell(rowIndex:int, columnIndex:int):Boolean
    {   
        // Find the index of the last isAdd=true cell region that contains 
        // row,columnIndex.
        const cellRegionsLength:int = cellRegions.length;
        var index:int = -1;
        for (var i:int = 0; i < cellRegionsLength; i++)
        {
            var cr:CellRect = cellRegions[i];
            if (cr.isAdd && cr.containsCell(rowIndex, columnIndex))
                index = i;
        }
        
        // Is there an isAdd=true CellRegion that contains the cell?
        if (index == -1) 
            return selectAllFlag;
        
        // Starting with index, if any subsequent isAdd=false cell region
        // contains row,columnIndex return false.
        for (i = index + 1; i < cellRegionsLength; i++)
        {
            cr = cellRegions[i];
            if (!cr.isAdd && cr.containsCell(rowIndex, columnIndex))
                return selectAllFlag;
        }
        
        return !selectAllFlag;
    }

    /**
     *  @private
     *  If requiredSelection, then there must always be at least one row/cell
     *  selected.  If the selection is changed, the caret is changed to match.
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
            if (selectionLength == 0)
                selectionChanged = grid.setSelectedIndex(0);
        }
        else if (isCellSelectionMode())
        {
            if (selectionLength == 0)
                selectionChanged = grid.setSelectedCell(0, 0);
        }
                
        return selectionChanged;
    }
    
    /**
     *  @private
     *  Remove any currently selected rows, cells and cached items.  This
     *  disregards the requireSelection flag.
     */    
    private function removeSelection():void
    {
        cellRegions.length = 0;       
        selectAllFlag = false;
        _selectionLength = 0;
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
     *  True if the selection mode is 
     *  <code>GridSelectionMode.MULTIPLE_ROW</code> and the entire row region 
     *  is contained within the grid.
     */    
    protected function validateRowRegion(rowIndex:int, rowCount:int):Boolean
    {
        if (selectionMode == GridSelectionMode.MULTIPLE_ROWS)
        {
            // Don't validate.
            if (inCollectionHandler)
                return true;
            
            const maxRows:int = getGridDataProviderLength();
            return (rowIndex >= 0 && rowCount >= 0 && rowIndex + rowCount <= maxRows);
        }
        
        return false;       
    }
            
    /**
     *  @private
     *  Initalize the list of cellRegions with this one.
     */
    private function internalSetCellRegion(rowIndex:int, columnIndex:int=0, 
                                           rowCount:uint=1, columnCount:uint=1):void
    {
        const cr:CellRect = 
            new CellRect(rowIndex, columnIndex, rowCount, columnCount, true);
        
        removeSelection();
        cellRegions.push(cr);
        
        _selectionLength = rowCount * columnCount;
    }

    /**
     *  @private
     *  Add the given row/cell to the list of cellRegions.
     */
    private function internalAddCell(rowIndex:int, columnIndex:int=0):void
    {
        if (!regionsContainCell(rowIndex, columnIndex))
        {
            const cr:CellRect = 
                new CellRect(rowIndex, columnIndex, 1, 1, !selectAllFlag);
            cellRegions.push(cr);
            
            // If the length is current before this add, just increment the 
            // length.
            if (_selectionLength >= 0)
                _selectionLength++;
        }
    }
              
    /**
     *  @private
     *  Remove the given row/cell from the list of cellRegions.
     */
    private function internalRemoveCell(rowIndex:int, columnIndex:int=0):void
    {
        if (regionsContainCell(rowIndex, columnIndex))
        {
            const cr:CellRect = 
                new CellRect(rowIndex, columnIndex, 1, 1, selectAllFlag);
            cellRegions.push(cr);
            
            // If the length is current before this remove, just decrement the 
            // length.
            if (_selectionLength >= 0)
                _selectionLength--;
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
        if (selectAllFlag)
        {
            const width:int = isRowSelectionMode() ? 1 : getGridColumnsLength();    
            return new Rectangle(0, 0, 
                                 width, getGridDataProviderLength());
        }
        
        var bounds:Rectangle = new Rectangle();                         
        const cellRegionsLength:int = cellRegions.length;
        for (var i:int = 0; i < cellRegionsLength; i++)
        {
            var cr:CellRect = cellRegions[i];
            if (!cr.isAdd)
                continue;
                
            bounds = bounds.union(cr);
        }
        
        return bounds;
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
    public function dataProviderCollectionChanged(event:CollectionEvent):void
    {
        inCollectionHandler = true;
        
        switch (event.kind)
        {
            case CollectionEventKind.ADD: 
            {
                dataProviderCollectionAdd(event);
                break;
            }
                
            case CollectionEventKind.MOVE:
            {
                dataProviderCollectionMove(event);
                break;
            }

            case CollectionEventKind.REFRESH:
            {
                dataProviderCollectionRefresh(event);
                break;
            }

            case CollectionEventKind.REMOVE:
            {
                dataProviderCollectionRemove(event);
                break;
            }
                
            case CollectionEventKind.REPLACE:
            {
                dataProviderCollectionReplace(event);
                break;
            }
                
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
        }
        
        inCollectionHandler = false;
    }
        
    /**
     *  @private
     *  Add an item to the collection.
     */
    private function dataProviderCollectionAdd(event:CollectionEvent):void
    {
        handleRowAdd(event.location, event.items.length);
        ensureRequiredSelection();
    }

    /**
     *  @private
     */
    private function handleRowAdd(insertIndex:int, insertCount:int=1):void
    {
        for (var cnt:int = 0; cnt < insertCount; cnt++)
        {
            for (var crIndex:int = 0; crIndex < cellRegions.length; crIndex++)
            {
                var cr:CellRect = cellRegions[crIndex];
                
                // If the insert is before the region or at the first row of
                // the region, move the region down a row.  If the insert is
                // in the region (but not the first row), split the region
                // into two and insert the new region.
                if (insertIndex <= cr.y)
                {
                    cr.y++;
                }
                else if (insertIndex < cr.bottom)
                {
                    var newCR:CellRect = 
                        new CellRect(insertIndex + 1, cr.x, 
                            cr.bottom - insertIndex, cr.width, 
                            cr.isAdd);
                    
                    cr.height = insertIndex - cr.y;
                    
                    // insert newCR just after cr
                    cellRegions.splice(++crIndex, 0, newCR);                    
                    _selectionLength = -1;      // recalculate
                }
            }
        }
    }

    /**
     *  @private
     *  The item has been moved from the oldLocation to location.
     */
    private function dataProviderCollectionMove(event:CollectionEvent):void
    {
        const oldRowIndex:int = event.oldLocation;
        const newRowIndex:int = event.location;
        
        handleRowRemove(oldRowIndex);
        
        // If the row is removed before the newly added item
        // then change index to account for this.
        if (newRowIndex > oldRowIndex)
            newRowIndex--;

        handleRowAdd(newRowIndex);
    }

    /**
     *  @private
     *  The sort or filter on the collection changed.
     */
    private function dataProviderCollectionRefresh(event:CollectionEvent):void
    {
        // Not preserving selection so this is similiar to a RESET.
        if (!preserveSelection)
        {            
            removeSelection();
            ensureRequiredSelection();
            return;
        }
        
        const rowCount:int = getGridDataProviderLength(); 
        var crIndex:int = 0
        while (crIndex < cellRegions.length)
        {
            var cr:CellRect = cellRegions[crIndex];
            
            // clip or remove any cell regions that extend beyond the
            // new number of rows
            if (cr.bottom > rowCount)
            {
                _selectionLength = -1;  // recalculate               
                if (cr.y >= rowCount)
                {
                    cellRegions.splice(crIndex, 1);
                    continue;
                }
                else
                {
                    cr.height = rowCount - cr.y;
                }
            }
            crIndex++;
        }
        
        ensureRequiredSelection();
    }
                
    /**
     *  @private
     *  An item has been removed from the collection.
     */
    private function dataProviderCollectionRemove(event:CollectionEvent):void
    {
        if (getGridDataProviderLength() == 0)
        {
            removeSelection();
            return;   
        }

        handleRowRemove(event.location, event.items.length);       
        ensureRequiredSelection();
    }
     
    /**
     *  @private
     */
    private function handleRowRemove(removeIndex:int, removeCount:int=1):void
    {
        for (var cnt:int = 0; cnt < removeCount; cnt++)
        {
            var crIndex:int = 0
            while (crIndex < cellRegions.length)
            {
                var cr:CellRect = cellRegions[crIndex];
                
                // Handle the cases where the remove is before the cell region
                // or in the cell region.
                if (removeIndex < cr.y)
                {
                    cr.y--;
                }
                else if (removeIndex >= cr.y && removeIndex < cr.bottom)
                {
                    _selectionLength = -1;  // recalculate               
                    cr.height--;
                    if (cr.height == 0)
                    {
                        cellRegions.splice(crIndex, 1);
                        continue;
                    }
                }
                crIndex++;
            }
        }        
    }
        
    /**
     *  @private
     *  The item has been replaced.
     */
    private function dataProviderCollectionReplace(event:CollectionEvent):void
    {
        // Nothing to do here unless we're saving the data items to preserve
        // the selection.
    }
    
    /**
     *  @private
     *  The data source changed so don't preserve the selection.  Clear the
     *  selectAll flag if set.
     */
    private function dataProviderCollectionReset(event:CollectionEvent):void
    {
        removeSelection();
        ensureRequiredSelection();
    }

    /**
     *  @private
     *  One or more items in the collection have been updated.
     */
    private function dataProviderCollectionUpdate(event:CollectionEvent):void
    {
        // Nothing to do.
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
    public function columnsCollectionChanged(event:CollectionEvent):void
    {
        inCollectionHandler = true;
        
        switch (event.kind)
        {
            case CollectionEventKind.ADD: 
            {
                columnsCollectionAdd(event);
                break;
            }
                
            case CollectionEventKind.MOVE:
            {
                columnsCollectionMove(event);
                break;
            }
                                
            case CollectionEventKind.REMOVE:
            {
                columnsCollectionRemove(event);
                break;
            }
                
            case CollectionEventKind.REPLACE:
            case CollectionEventKind.UPDATE:
            {
                break;
            }
                
            case CollectionEventKind.REFRESH:
            {
                columnsCollectionRefresh(event);
                break;                
            }
            case CollectionEventKind.RESET:
            {
                columnsCollectionReset(event);
                break;                
           }
        }
        
        inCollectionHandler = false;
    }

    /**
     *  @private
     *  Add an column to the columns collection.
     */
    private function columnsCollectionAdd(event:CollectionEvent):void
    {
        // If no selectionMode or a row-based selectionMode, nothing to do.
        if (!isCellSelectionMode())
            return;
        
        handleColumnAdd(event.location, event.items.length);
        ensureRequiredSelection();
    }

    /**
     *  @private
     */
    private function handleColumnAdd(insertIndex:int, insertCount:int=1):void
    {
        for (var cnt:int = 0; cnt < insertCount; cnt++)
        {
            for (var crIndex:int = 0; crIndex < cellRegions.length; crIndex++)
            {
                var cr:CellRect = cellRegions[crIndex];
                
                // If the insert is to the left of the region or at the 
                // first column of the region, move the region to the right a
                // column.  If the insert is in the region (but not the first
                // column), split the region into two and insert the new region.
                if (insertIndex <= cr.x)
                {
                    cr.x++;
                }
                else if (insertIndex < cr.x)
                {
                    var newCR:CellRect = 
                        new CellRect(cr.y, insertIndex + 1,
                            cr.height, cr.right - insertIndex, 
                            cr.isAdd);
                    
                    cr.width = insertIndex - cr.x;
                    
                    // insert newCR just after cr
                    cellRegions.splice(++crIndex, 0, newCR);
                    _selectionLength = -1;  // recalculate               
                }
            }
        }
    }

    /**
     *  @private
     *  The column has been moved from the oldLocation to location in the 
     *  columns collection.
     */
    private function columnsCollectionMove(event:CollectionEvent):void
    {
        // If no selectionMode or a row-based selectionMode, nothing to do.
        if (!isCellSelectionMode())
            return;

        const oldColumnIndex:int = event.oldLocation;
        const newColumnIndex:int = event.location;
        
        handleColumnRemove(oldColumnIndex);
        
        // If the column is removed before the newly added column
        // then change index to account for this.
        if (newColumnIndex > oldColumnIndex)
            newColumnIndex--;
        
        handleColumnAdd(newColumnIndex);
    }   

    /**
     *  @private
     *  A column has been removed from the columns collection.
     */
    private function columnsCollectionRemove(event:CollectionEvent):void
    {
        // If no selectionMode or a row-based selectionMode, nothing to do.
        if (!isCellSelectionMode())
            return;

        if (getGridColumnsLength() == 0)
        {
            removeSelection();
            return;   
        }
        
        handleColumnRemove(event.location, event.items.length);      
        ensureRequiredSelection();
    }
    
    /**
     *  @private
     */
    private function handleColumnRemove(removeIndex:int, removeCount:int=1):void
    {
        for (var cnt:int = 0; cnt < removeCount; cnt++)
        {
            var crIndex:int = 0
            while (crIndex < cellRegions.length)
            {
                var cr:CellRect = cellRegions[crIndex];
                
                // Handle the cases where the remove is before the cell region
                // or in the cell region.
                if (removeIndex < cr.x)
                {
                    cr.x--;
                }
                else if (removeIndex >= cr.x && removeIndex < cr.right)
                {
                    _selectionLength = -1;  // recalculate               
                    cr.width--;
                    if (cr.width == 0)
                    {
                        cellRegions.splice(crIndex, 1);
                        continue;
                    }
                }
                crIndex++;
            }
        }        
    }

    /**
     *  @private
     *  The sort or filter on the collection changed.  If the selectionMode is
     *  cell-based, reset the selection.
     */
    private function columnsCollectionRefresh(event:CollectionEvent):void
    {
        // If no selectionMode or a row-based selectionMode, nothing to do.
        if (!isCellSelectionMode())
            return;
        
        // Not preserving selection so this is similiar to a RESET.
        if (!preserveSelection)
        {            
            removeSelection();
            ensureRequiredSelection();
            return;
        }
        
        const columnCount:int = getGridColumnsLength();
        var crIndex:int = 0
        while (crIndex < cellRegions.length)
        {
            var cr:CellRect = cellRegions[crIndex];
            
            // clip or remove any cell regions that extend beyond the
            // new number of columns
            if (cr.right > columnCount)
            {
                _selectionLength = -1;  // recalculate               
                if (cr.x >= columnCount)
                {
                    cellRegions.splice(crIndex, 1);
                    continue;
                }
                else
                {
                    cr.width = columnCount - cr.x;
                }
            }
            crIndex++;
        }
        
        ensureRequiredSelection();
     }

    /**
     *  @private
     *  The columns changed.  If the selectionMode is cell-based, don't preserve 
     *  the selection.
     */
    private function columnsCollectionReset(event:CollectionEvent):void
    {
        // If no selectionMode or a row-based selectionMode, nothing to do.
        if (!isCellSelectionMode())
            return;

        removeSelection();
        ensureRequiredSelection();
    }
}
}

import flash.geom.Rectangle;


/**
 * @private
 * A CellRect is a rectangle with one additional, isAdd property.
 * A CellRect for a row is represented with columnIndex=0 and columnCount=1.
 * 
 * Mappings between Rectangle and selection cell regions:
 *     y = rowIndex
 *     x = columnIndex
 *     height = rowCount
 *     width = columnCount
 */
internal class CellRect extends Rectangle
{
    public var isAdd:Boolean = false;
                                         
    // For a row, columnIndex=0 and columnCount=1.
    public function CellRect(rowIndex:int, columnIndex:int, 
                               rowCount:uint, columnCount:uint, isAdd:Boolean)
    {
        super(columnIndex, rowIndex, columnCount, rowCount);
        this.isAdd = isAdd;
    }
    
    public function containsCell(cellRowIndex:int, cellColumnIndex:int):Boolean
    {
        return contains(cellColumnIndex, cellRowIndex);
    }
}
