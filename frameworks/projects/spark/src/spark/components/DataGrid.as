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

package spark.components
{
import mx.collections.IList;
import mx.events.FlexEvent;

import spark.components.supportClasses.CellPosition;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched by the grid skin part when the mouse button is pressed over a Grid cell.
 *
 *  @eventType spark.events.GridEvent.GRID_MOUSE_DOWN
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="gridMouseDown", type="spark.events.GridEvent")]


/**
 *  Dispatched by the grid skin part after a GRID_MOUSE_DOWN event if the mouse moves before the button is released.
 *
 *  @eventType spark.events.GridEvent.GRID_MOUSE_DRAG
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="gridMouseDrag", type="spark.events.GridEvent")]

/**
 *  Dispatched by the grid skin part after a GRID_MOUSE_DOWN event when the mouse button is released, even
 *  if the mouse is no longer within the Grid.
 *
 *  @eventType spark.events.GridEvent.GRID_MOUSE_UP
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="gridMouseUp", type="spark.events.GridEvent")]

/**
 *  Dispatched by the grid skin part when the mouse enters a grid cell.
 *
 *  @eventType spark.events.GridEvent.GRID_ROLL_OVER
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="gridRollOver", type="spark.events.GridEvent")]

/**
 *  Dispatched by the grid skin part when the mouse leaves a grid cell.
 *
 *  @eventType spark.events.GridEvent.GRID_ROLL_OUT
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="gridRollOut", type="spark.events.GridEvent")]

/**
 *  Dispatched by the grid skin part when the mouse is clicked over a cell
 *
 *  @eventType spark.events.GridEvent.GRID_CLICK
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="gridClick", type="spark.events.GridEvent")]

/**
 *  Dispatched by the grid skin part when the mouse is double-clicked over a cell
 *
 *  @eventType spark.events.GridEvent.GRID_DOUBLE_CLICK
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="gridDoubleClick", type="spark.events.GridEvent")]

/**
 *  Dispatched when the selection has changed. 
 *  
 *  <p>This event is dispatched when the user interacts with the control.
 *  When you change the selection programmatically, 
 *  the component does not dispatch the <code>selectionChanging</code> event. 
 *  It dispatches the <code>valueCommit</code> event instead.</p>
 *
 *  @eventType spark.events.GridSelectionChangeEvent.SELECTION_CHANGING
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="selectionChanging", type="spark.events.GridSelectionEvent")]

/**
 *  Dispatched when the selection is going to change. 
 *  Calling the <code>preventDefault()</code> method
 *  on the event prevents the selection from changing.
 *  
 *  <p>This event is dispatched when the user interacts with the control.
 *  When you change the selection programmatically, 
 *  the component does not dispatch the <code>selectionChange</code> event. 
 *  It dispatches the <code>valueCommit</code> event instead.</p>
 *
 *  @eventType spark.events.GridSelectionChangeEvent.SELECTION_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="selectionChange", type="spark.events.GridSelectionEvent")]

/**
 *  Dispatched after the caret has changed.  
 *
 *  @eventType spark.events.GridCaretEvent.CARET_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="caretChange", type="spark.events.GridCaretEvent")]
        

/**
 *  TBD
 */  
public class DataGrid extends GridContainerBase
{
    public function DataGrid()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  selectedCell
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]
    
    /**
     *  @copy spark.components.Grid#selectedCell
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectedCell():CellPosition
    {
        if (grid)
            return grid.selectedCell;
        
        return selectedCells.length ? selectedCells[0] : null;
    }
    
    //----------------------------------
    //  selectedCells
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]
    
    /**
     *  @copy spark.components.Grid#selectedCells
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectedCells():Vector.<CellPosition>
    {
        return grid ? grid.selectedCells : gridSelection.allCells();
    }
    
    //----------------------------------
    //  selectedIndex
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]
    
    /**
     *  @copy spark.components.Grid#selectedIndex
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectedIndex():int
    {
        if (grid)
            return grid.selectedIndex;
        
        return selectedIndices.length ? selectedIndices[0] : -1;
    }
    
    //----------------------------------
    //  selectedIndices
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]
    
    /**
     *  @copy spark.components.Grid#selectedIndices
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectedIndices():Vector.<int>
    {
        return grid ? grid.selectedIndices : gridSelection.allRows();
    }
    
    //----------------------------------
    //  selectedItem
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]
    
    /**
     *  @copy spark.components.Grid#selectedItem
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectedItem():Object
    {
        if (grid)
            return grid.selectedItem;
        
        return (dataProvider && (selectedIndex > 0)) ? 
                dataProvider.getItemAt(selectedIndex) : undefined;
    }
    
    //----------------------------------
    //  selectedItems
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]
    
    /**
     *  @copy spark.components.Grid#selectedItems
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectedItems():Vector.<Object>
    {
        if (grid)
            return grid.selectedItems;
                
        var items:Vector.<Object> = new Vector.<Object>();
        
        for (var i:int = 0; i < selectedIndices.length; i++)
            items.push(selectedIndices[i]);
        
        return items;
    }
    
    //----------------------------------
    //  selectionLength
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]
    
    /**
     *  @copy spark.components.Grid#selectionLength
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectionLength():int
    {
        return grid ? grid.selectionLength : gridSelection.selectionLength;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Public Methods
    //
    //--------------------------------------------------------------------------
        
    //----------------------------------
    //  selection for rows
    //----------------------------------    
    
    /**
     *  @copy spark.components.Grid#selectionContainsIndex
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectionContainsIndex(rowIndex:int):Boolean 
    {
        if (grid)
            return grid.selectionContainsIndex(rowIndex);
        else
            return gridSelection.containsRow(rowIndex);         
    }
    
    /**
     *  @copy spark.components.Grid#selectionContainsIndices
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectionContainsIndices(rowIndices:Vector.<int>):Boolean 
    {
        if (grid)
            return grid.selectionContainsIndices(rowIndices);
        else
            return gridSelection.containsRows(rowIndices);
    }
        
    /**
     *  @copy spark.components.Grid#setSelectedIndex
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function setSelectedIndex(rowIndex:int):Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.setSelectedIndex(rowIndex);
        }
        else
        {
            selectionChanged = gridSelection.setRow(rowIndex);
            if (selectionChanged)
            {
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
        }
        
        return selectionChanged;
    }
    
    /**
     *  @copy spark.components.Grid#addSelectedIndex
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function addSelectedIndex(rowIndex:int):Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.addSelectedIndex(rowIndex);
        }
        else
        {
            selectionChanged = gridSelection.addRow(rowIndex);
            if (selectionChanged)
            {
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
        }
        
        return selectionChanged;
    }
    
    /**
     *  @copy spark.components.Grid#removeSelectedIndex
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function removeSelectedIndex(rowIndex:int):Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.removeSelectedIndex(rowIndex);
        }
        else
        {
            selectionChanged = gridSelection.removeRow(rowIndex);
            if (selectionChanged)
            {
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
        }
        
        return selectionChanged;
    }
    
    /**
     *  @copy spark.components.Grid#setSelectedIndices
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectIndices(rowIndex:int, rowCount:int):Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.selectIndices(rowIndex, rowCount);
        }
        else
        {
            selectionChanged = gridSelection.setRows(rowIndex, rowCount);
            if (selectionChanged)
            {
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
        }
        
        return selectionChanged;
    }
    
    //----------------------------------
    //  selection for cells
    //----------------------------------    
    
    /**
     *  @copy spark.components.Grid#selectionContainsCell
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectionContainsCell(rowIndex:int, columnIndex:int):Boolean
    {
        if (grid)
            return grid.selectionContainsCell(rowIndex, columnIndex);
        else
            return gridSelection.containsCell(rowIndex, columnIndex);
    }
    
    /**
     *  @copy spark.components.Grid#selectionContainsCellRegion
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectionContainsCellRegion(rowIndex:int, columnIndex:int, 
                                                rowCount:int, columnCount:int):Boolean
    {
        if (grid)
        {
            return grid.selectionContainsCellRegion(
                rowIndex, columnIndex, rowCount, columnCount);
        }
        else
        {
            return gridSelection.containsCellRegion(
                rowIndex, columnIndex, rowCount, columnCount);
        }
    }
        
    /**
     *  @copy spark.components.Grid#setSelectedCell
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function setSelectedCell(rowIndex:int, columnIndex:int):Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.setSelectedCell(rowIndex, columnIndex);
        }
        else
        {
            selectionChanged = gridSelection.setCell(rowIndex, columnIndex);
            if (selectionChanged)
            {
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
        }
        
        return selectionChanged;
    }
    
    /**
     *  @copy spark.components.Grid#addSelectedCell
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function addSelectedCell(rowIndex:int, columnIndex:int):Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.addSelectedCell(rowIndex, columnIndex);
        }
        else
        {
            selectionChanged = gridSelection.addCell(rowIndex, columnIndex);
            if (selectionChanged)
            {
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
        }
        
        return selectionChanged;
    }
    
    /**
     *  @copy spark.components.Grid#removeSelectedCell
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function removeSelectedCell(rowIndex:int, columnIndex:int):Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.removeSelectedCell(rowIndex, columnIndex);
        }
        else
        {
            selectionChanged = gridSelection.removeCell(rowIndex, columnIndex);
            if (selectionChanged)
            {
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
        }
        
        return selectionChanged;
    }
    
    /**
     *  @copy spark.components.Grid#selectCellRegion
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectCellRegion(rowIndex:int, columnIndex:int, 
                                     rowCount:uint, columnCount:uint):Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.selectCellRegion(
                rowIndex, columnIndex, rowCount, columnCount);
        }
        else
        {
            selectionChanged = gridSelection.setCellRegion(
                rowIndex, columnIndex, rowCount, columnCount);
            if (selectionChanged)
            {
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
        }
        
        return selectionChanged;
    }
}
}