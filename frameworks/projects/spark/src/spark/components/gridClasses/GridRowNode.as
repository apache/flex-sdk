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
import spark.components.supportClasses.GridDimensions;
    
[ExcludeClass]
    
/**
 *  A GridRowNode contains the heights of each cell for the row at rowIndex
 *  as well as the maximum height of the row's cells.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
public final class GridRowNode
{
    public var rowIndex:int;
    
    private var cellHeights:Vector.<Number>;
    public var maxCellHeight:Number = NaN;
    public var fixedHeight:Number = NaN;
    
    public var next:GridRowNode;
    public var prev:GridRowNode;
    
    /**
     *  Constructor.
     */
    public function GridRowNode(numColumns:uint, rowIndex:int)
    {
        super();
        
        this.rowIndex = rowIndex;
        _numColumns = numColumns;
        
        // initialize cellHeights. all are 0 to start out with.
        cellHeights = new Vector.<Number>(numColumns);
    }
    
    private var _numColumns:uint;
    
    /**
     *  Number of columns in this row.
     */
    public function get numColumns():uint
    {
        return _numColumns;
    }
    
    /**
     *  @private
     */
    public function set numColumns(value:uint):void
    {
        if (value == _numColumns)
            return;
        
        cellHeights.length = value;
        
        if (value > _numColumns)
        {
            for (var i:int = value - _numColumns; i < value; i++)
                cellHeights[i] = 0;
        }
        else
        {
            updateMaxHeight();
        }
        
        _numColumns = value;
    }

    /**
     *  Updates the current max height.
     * 
     *  @return true if changed
     */
    private function updateMaxHeight():Boolean
    {
        // FIXME (klin): use max heap? might not be worth the overhead.
        var max:Number = 0;
        for each (var cellHeight:Number in cellHeights)
            max = Math.max(max, cellHeight);
        
        const changed:Boolean = maxCellHeight != max;
        maxCellHeight = max;
        return changed;
    }
    
    /**
     *  Returns the cell height at the specified index.
     *  
     *  @return the cell height at the given index. NaN if index
     *  is out of bounds.
     */
    public function getCellHeight(index:int):Number
    {
        if (index < 0 || index >= cellHeights.length)
            return NaN;
        return cellHeights[index];
    }
    
    /**
     *  Updates the height at the specified column.
     * 
     *  @return true if max height has changed.
     */
    public function setCellHeight(index:int, value:Number):Boolean
    {
        if (cellHeights[index] == value)
            return false;
        
        cellHeights[index] = value;
        
        return updateMaxHeight();
    }
    
    /**
     *  Shifts values such that count columns are inserted
     *  from the startIndex.
     */
    public function insertColumns(startColumn:int, count:int):void
    {
        GridDimensions.insertValueToVector(cellHeights, startColumn, count, 0);
    }
    
    /**
     *  Removes and adds values such that the columns are moved.
     */
    public function moveColumns(fromCol:int, toCol:int, count:int):void
    {
        GridDimensions.insertValuesToVector(cellHeights, toCol, cellHeights.splice(fromCol, count));
    }
    
    /**
     *  Clears values such that count columns are 0.
     */
    public function clearColumns(startColumn:int, count:int):void
    {
        GridDimensions.clearVector(cellHeights, 0, startColumn, count);
        updateMaxHeight();
    }
    
    /**
     *  Shifts values such that count columns are removed
     *  from the startColumn.
     *  We assume that cellHeights is the right length.
     */
    public function removeColumns(startColumn:int, count:int):void
    {
        cellHeights.splice(startColumn, count);
        updateMaxHeight();
    }
    
    /**
     *  toString method for testing.
     */
    public function toString():String
    {
        var s:String = "";
        
        s += "(" + rowIndex + ", " + maxCellHeight + ") ";
        s += cellHeights + "\n";
        if (prev)
            s += prev.rowIndex;
        else
            s += "null";
        
        s += " <- -> ";
        if (next)
            s += next.rowIndex;
        else
            s += "null";
        
        return s;
    }
}
}