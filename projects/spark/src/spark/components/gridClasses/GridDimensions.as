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
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;

[ExcludeClass]

/**
 *  A sparse data structure that represents the widths and heights of a grid.
 *  
 *  Provides efficient support for finding the cumulative y distance to the
 *  start of a particular cell as well as finding the index of a particular
 *  cell at a certain y value.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
public class GridDimensions 
{
    include "../../core/Version.as";
    
    /**
     *  @private
     *  Restrict a number to a particular min and max.
     */
    private static function bound(a:Number, min:Number, max:Number):Number
    {
        if (a < min)
            a = min;
        else if (a > max)
            a = max;
        
        return a;
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var rowList:GridRowList = new GridRowList();
    private var _columnWidths:Vector.<Number>;

    //cache for cumulative y values.
    private var startY:Number = 0;
    private var recentNode:GridRowNode = null;
    private var startY2:Number = 0;
    private var recentNode2:GridRowNode = null;
    
    private const typicalCellWidths:Array = new Array();
    private const typicalCellHeights:Array = new Array();
    private var isFirstTypicalCellHeight:Boolean = true;
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor
     */
    public function GridDimensions()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  rowCount
    //----------------------------------
    
    private var _rowCount:int = 0;
    
    /**
     *  The number of rows in the Grid. If this is decreased, the 
     *  excess rows will be removed.
     */
    public function get rowCount():int
    {
        return _rowCount;
    }
    
    /**
     *  @private
     */
    public function set rowCount(value:int):void
    {
        if (value == _rowCount)
            return;
        
        _rowCount = value;
        
        if (recentNode && recentNode.rowIndex >= _rowCount)
            recentNode = null;
        if (recentNode2 && recentNode2.rowIndex >= _rowCount)
            recentNode2 = null;
        
        // FIXME (klin): remove a range of indices...
    }
    
    //----------------------------------
    //  columnCount
    //----------------------------------
    
    private var _columnCount:int = 0;
    
    /**
     *  The number of columns in the Grid. If this is decreased, the 
     *  excess columns will be removed.
     */
    public function get columnCount():int
    {
        return _columnCount;
    }
    
    /**
     *  @private
     */
    public function set columnCount(value:int):void
    {
        if (value == _columnCount)
            return;
        
        _columnCount = value;
        if (_columnCount == 0)
        {
            rowList.removeAll();
            recentNode = null;
            recentNode2 = null;
            return;
        }
        
        rowList.numColumns = value;        
        
        var i:int;
        
        if (!_columnWidths)
        {
            _columnWidths = new Vector.<Number>(_columnCount);
            
            for (i = 0; i < _columnCount; i++)
                _columnWidths[i] = NaN;
        }
        else
        {
            var temp:int = _columnWidths.length;
            _columnWidths.length = _columnCount;
            
            if (temp < _columnCount)
            {
                for (i = temp; i < _columnCount; i++)
                    _columnWidths[i] = NaN;
                
                if (_columnCount == 0)
                {
                    clearTypicalCellWidthsAndHeights();
                }
                else
                {
                    typicalCellWidths.length = _columnCount;
                    typicalCellHeights.length = _columnCount;
                }
            }
        }
        
        // clear cache
        recentNode = null;
        recentNode2 = null;
    }

    //----------------------------------
    //  rowGap
    //----------------------------------

    private var _rowGap:Number = 0;
    
    /**
     *  The gap between rows.
     * 
     *  @default 0 
     */
    public function get rowGap():Number
    {
        return _rowGap;
    }
    
    /**
     *  @private
     */
    public function set rowGap(value:Number):void
    {
        if (value == _rowGap)
            return;
        
        _rowGap = value;
        
        // reset recent node.
        recentNode = null;
        recentNode2 = null;
    }
    
    //----------------------------------
    //  columnGap
    //----------------------------------

    private var _columnGap:Number = 0;
    
    /**
     *  The gap between columns.
     * 
     *  @default 0 
     */
    public function get columnGap():Number
    {
        return _columnGap;
    }
    
    /**
     *  @private
     */
    public function set columnGap(value:Number):void
    {
        if (value == _columnGap)
            return;
        
        _columnGap = value;
        
        // reset recent node.
        recentNode = null;
        recentNode2 = null;
    }
    
    //----------------------------------
    //  defaultRowHeight
    //----------------------------------
    
    private var _defaultRowHeight:Number = 26;
    
    /**
     *  The default height of a row. The defaultRowHeight is always
     *  bounded by the minRowHeight and maxRowHeight.
     */
    public function get defaultRowHeight():Number
    {
        return _defaultRowHeight;
    }
    
    /**
     *  @private
     */
    public function set defaultRowHeight(value:Number):void
    {
        if (value == _defaultRowHeight)
            return;
        
        _defaultRowHeight = bound(value, _minRowHeight, _maxRowHeight);
        
        // reset recent node.
        recentNode = null;
        recentNode2 = null;
    }
    
    //----------------------------------
    //  defaultColumnWidth
    //----------------------------------
    
    /**
     *  The default width of a column.
     */
    public var defaultColumnWidth:Number = 150;
    
    //----------------------------------
    //  fixedRowHeight
    //----------------------------------
    
    private var _fixedRowHeight:Number = NaN;
    
    /**
     *  If fixedRowHeight is set, calling getRowHeight will return
     *  its value for every row. Individual cell heights are not
     *  affected, but calling getCellBounds will return bounds
     *  respecting fixedRowHeight. The fixedRowHeight is always
     *  bounded by the minRowHeight and maxRowHeight.
     * 
     *  @default NaN
     */
    public function get fixedRowHeight():Number
    {
        return _fixedRowHeight;
    }
    
    /**
     *  @private
     */
    public function set fixedRowHeight(value:Number):void
    {
        if (value == _fixedRowHeight)
            return;
        
        _fixedRowHeight = bound(value, _minRowHeight, _maxRowHeight);
    }
    
    //----------------------------------
    //  minRowHeight
    //----------------------------------
    
    private var _minRowHeight:Number = 0;
    
    /**
     *  The minimum height of each row.
     * 
     *  @default 0
     */
    public function get minRowHeight():Number
    {
        return _minRowHeight;
    }
    
    /**
     *  @private
     */
    public function set minRowHeight(value:Number):void
    {
        if (value == _minRowHeight)
            return;
        
        _minRowHeight = value;
        _defaultRowHeight = Math.max(_defaultRowHeight, _minRowHeight);
        _fixedRowHeight = Math.max(_fixedRowHeight, _minRowHeight);
    }
    
    //----------------------------------
    //  maxRowHeight
    //----------------------------------
    
    private var _maxRowHeight:Number = 10000;
    
    /**
     *  The maximum height of each row.
     * 
     *  @default 10000
     */
    public function get maxRowHeight():Number
    {
        return _maxRowHeight;
    }
    
    /**
     *  @private
     */
    public function set maxRowHeight(value:Number):void
    {
        if (value == _maxRowHeight)
            return;
        
        _maxRowHeight = value;
        _defaultRowHeight = Math.min(_defaultRowHeight, _maxRowHeight);
        _fixedRowHeight = Math.min(_fixedRowHeight, _maxRowHeight);
    }

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Returns the height of the row at the given index. Returns the
     *  fixedRowHeight if set. If not, returns the height specified by
     *  setRowHeight. If no height has been specified, returns the
     *  natural height of the row (maximum height of its cells. If the
     *  cells haven't been cached, returns defaultRowHeight.
     *  The return value is always bounded by the minRowHeight and
     *  maxRowHeight.
     */
    public function getRowHeight(row:int):Number
    {
        // Unless setRowHeight is called, return the max cell height for this row
        var height:Number = defaultRowHeight;
        
        if (!isNaN(fixedRowHeight))
        {
            height = fixedRowHeight;
        }
        else
        {
            var node:GridRowNode = rowList.find(row);
            if (node)
            {
                if (!isNaN(node.fixedHeight))
                    height = node.fixedHeight;
                else if (!isNaN(node.maxCellHeight))
                    height = node.maxCellHeight;
            }
        }
        
        return bound(height, minRowHeight, maxRowHeight);
    }
    
    /**
     *  Sets the height of a given row. This height takes precedence over
     *  the natural height of the row (determined by the maximum of its 
     *  cell heights) and the defaultRowHeight. However, fixedRowHeight
     *  takes precedence over this height.
     */
    public function setRowHeight(row:int, height:Number):void
    {
        if (!isNaN(fixedRowHeight))
            return;
        
        var node:GridRowNode = rowList.find(row);
        
        if (node)
        {
            node.fixedHeight = bound(height, minRowHeight, maxRowHeight);
        }
        else
        {
            node = rowList.insert(row);
            
            if (node)
                node.fixedHeight = bound(height, minRowHeight, maxRowHeight);
        }
    }

    /**
     *  Returns the width of the column at the given index. Returns
     *  the width specified by setColumnWidth. If no width has been
     *  specified, returns the defaultColumnWidth.
     */
    public function getColumnWidth(col:int):Number
    {    
        var w:Number = NaN;
        
        // out of bounds col will throw an error..should we handle it?
        if (_columnWidths)
            w = _columnWidths[col];
        
        if (!isNaN(w))
            return w;
        
        return this.defaultColumnWidth;
    }
    
    /**
     *  Sets the height of a given row. This height takes precedence over
     *  the natural height of the row (determined by the maximum of its 
     *  cell heights) and the defaultRowHeight. However, fixedRowHeight
     *  takes precedence over this height.
     */
    public function setColumnWidth(col:int, width:Number):void
    {
        // out of bounds col will throw an error..should we handle it?
        if (_columnWidths)
            _columnWidths[col] = width;
    }

    /**
     *  Returns the height of the specified cell. Returns the height
     *  set by setCellHeight. If the height has not been specified,
     *  returns NaN.
     */
    public function getCellHeight(row:int, col:int):Number
    {
        var node:GridRowNode = rowList.find(row);
        
        if (node)
            return node.getCellHeight(row);
        
        return NaN;
    }
    
    /**
     *  Sets the height of the specified cell.
     */
    public function setCellHeight(row:int, col:int, height:Number):void
    {
        if (!isNaN(fixedRowHeight))
            return;
        
        var node:GridRowNode = rowList.find(row);
        var oldHeight:Number = defaultRowHeight;
        
        if (node == null)
            node = rowList.insert(row);
        else
            oldHeight = node.maxCellHeight;
        
        if (node && node.setCellHeight(col, height))
        {
           if (recentNode && node.rowIndex < recentNode.rowIndex)
               startY += node.maxCellHeight - oldHeight;
           
           if (recentNode2 && node.rowIndex < recentNode2.rowIndex)
               startY2 += node.maxCellHeight - oldHeight;
        }
    }
    
    /**
     *  Returns the layout bounds of the specified cell. The cell height
     *  and width are determined by its row's height and column's width.
     */
    public function getCellBounds(row:int, col:int):Rectangle
    {
        // TBD: provide optional return value (Rectangle) parameter
        if (row < 0 || row >= rowCount || col < 0 || col >= columnCount)
            return null;
        
        var x:Number = getCellX(row, col);
        var y:Number = getCellY(row, col);
        
        var width:Number = getColumnWidth(col);
        var height:Number = getRowHeight(row);
        
        return new Rectangle(x, y, width, height);
    }
    
    /**
     *  Returns the X coordinate of the origin of the specified cell.
     */
    public function getCellX(row:int, col:int):Number
    {
        if (!_columnWidths)
            return col * (defaultColumnWidth + columnGap);
        
        var x:Number = 0;
        
        for (var i:int = 0; i < col; i++)
        {
            var temp:Number = _columnWidths[i];
            
            if (isNaN(temp))
                x += defaultColumnWidth + columnGap;
            else
                x += temp + columnGap;
        }
        
        return x;
    }
    
    /**
     *  Returns the Y coordinate of the origin of the specified cell.
     */
    public function getCellY(row:int, col:int):Number
    { 
        // no cache so we use default heights for each row.
        if (!isNaN(fixedRowHeight))
            return row * (fixedRowHeight + rowGap);
        
        if (rowList.length == 0)
            return row * (defaultRowHeight + rowGap);
        
        if (row == 0)
            return 0;
        
        // initialize first node.
        if (!recentNode2)
        {
            recentNode2 = rowList.first;
            startY2 = recentNode2.rowIndex * (defaultRowHeight + rowGap);
        }
        
        var y:Number;
        var recentIndex:int = recentNode2.rowIndex;

        if (row == recentIndex)
            y = startY2;
        else if (row < recentIndex)
            y = getPrevYAt(row, recentNode2, startY2);
        else
            y = getNextYAt(row, recentNode2, startY2);

        return y;
    }

    /**
     *  Returns the starting y value of the specified row. The row must be before
     *  startNode.
     *  
     *  @param row the target row
     *  @param startNode the node to search from
     *  @param startY the cumulative y value from the first row to the beginning
     *  of startNode's row.
     * 
     *  @return the y value of the start of the row.
     */
    private function getPrevYAt(row:int, startNode:GridRowNode, startY:Number):Number
    {
        var node:GridRowNode = startNode;
        var nodeY:Number = startY;
        var prevNode:GridRowNode;
        var currentY:Number = startY;
        var indDiff:int;
        
        while (node)
        {
            if (node.rowIndex == row)
                break;
            
            prevNode = node.prev;
            
            if (!prevNode || (row < node.rowIndex && row > prevNode.rowIndex))
            {
                // at the beginning or somewhere between nodes
                // so we've found the target row.
                indDiff = node.rowIndex - row;
                currentY -= indDiff * (defaultRowHeight + rowGap);
                break;
            }
            
            // subtract previous node's height and its gap.
            indDiff = node.rowIndex - prevNode.rowIndex - 1;
            currentY = currentY - indDiff * (defaultRowHeight + rowGap) - (prevNode.maxCellHeight + rowGap);
            nodeY = currentY;
            node = prevNode;
        }

        this.recentNode2 = node;
        this.startY2 = nodeY;
        
        return currentY;
    }
    
    /**
     *  Returns the starting y value of the specified row. The row must be after
     *  startNode.
     *  
     *  @param row the target row
     *  @param startNode the node to search from
     *  @param startY the cumulative y value from the first row to beginning of
     *  startNode's row.
     * 
     *  @return the y value of the start of the row.
     */
    private function getNextYAt(row:int, startNode:GridRowNode, startY:Number):Number
    {
        var node:GridRowNode = startNode;
        var nodeY:Number = startY;
        var nextNode:GridRowNode;
        var currentY:Number = startY;
        var indDiff:int;
        
        while (node)
        {
            if (node.rowIndex == row)
                break;
            
            currentY += node.maxCellHeight;
            if (node.rowIndex < _rowCount - 1)
                currentY += rowGap;
            
            nextNode = node.next;

            if (!nextNode || (row > node.rowIndex && row < nextNode.rowIndex))
            {
                // at the beginning or somewhere between nodes
                // so we've found the target row.
                indDiff = row - node.rowIndex - 1;
                currentY += indDiff * (defaultRowHeight + rowGap);
                break;
            }
            
            // add next node's maxCellHeight and rowGap
            indDiff = nextNode.rowIndex - node.rowIndex - 1;
            currentY = currentY + indDiff * (defaultRowHeight + rowGap);
            nodeY = currentY; 
            node = nextNode;
        }
        
        this.recentNode2 = node;
        this.startY2 = nodeY;
        
        return currentY;
    }
    
    /**
     *  Returns the layout bounds of the specified row.
     */
    public function getRowBounds(row:int):Rectangle
    {
        // TBD: provide optional return value (Rectangle) parameter    
        if ((row < 0) || (row >= _rowCount))
            return null;  // TBD: return empty Rectangle instead
        
        if (_columnCount == 0 || _rowCount == 0)
            return new Rectangle(0, 0, 0, 0);
        
        const x:Number = getCellX(row, 0);
        const y:Number = getCellY(row, 0);
        const rowWidth:Number = getCellX(row, _columnCount - 1) + getColumnWidth(_columnCount - 1) - x;
        const rowHeight:Number = getRowHeight(row);
        return new Rectangle(x, y, rowWidth, rowHeight);
    }
    
    /**
     *  Return the dimensions of a row that's being used to "pad" the grid
     *  by filling unused space below the last row in a layout where all rows
     *  are visible.  Pad rows have index >= rowCount, height = defaultRowHeight.
     */
    public function getPadRowBounds(row:int):Rectangle
    {
        if (row < 0)
            return null;
        
        if (row < rowCount)
            return getRowBounds(row);
        
        const lastRow:int = rowCount - 1;
        const lastCol:int = columnCount - 1;
        
        const x:Number = (lastRow >= 0) ? getCellX(lastRow, 0) : 0;
        const lastRowBottom:Number = (lastRow >= 0) ? getCellY(lastRow, 0) + getRowHeight(lastRow) : 0;
        const padRowCount:int = row - rowCount;
        const padRowTotalGap:Number = (padRowCount > 0) ? (padRowCount - 1) * rowGap : 0;
        const y:Number = lastRowBottom + (padRowCount * defaultRowHeight) + padRowTotalGap;
        const rowWidth:Number = 
            ((lastCol >= 0) && (lastRow >= 0)) ? getCellX(lastRow, lastCol) + getColumnWidth(lastCol) - x : 0;
        
        return new Rectangle(x, y, rowWidth, defaultRowHeight);
        
    }
    
    /**
     *  Returns the layout bounds of the specified column.
     */
    public function getColumnBounds(col:int):Rectangle
    {
        // TBD: provide optional return value (Rectangle) parameter
        if ((col < 0) || (col >= _columnCount))
            return null;  // TBD: return empty Rectangle instead
        
        if (_columnCount == 0 || _rowCount == 0)
            return new Rectangle(0, 0, 0, 0);

        const x:Number = getCellX(0, col);
        const y:Number = getCellY(0, col);
        const colWidth:Number = getColumnWidth(col);
        const colHeight:Number = getCellY(_rowCount - 1, col) + getRowHeight(_rowCount - 1) - y;
        return new Rectangle(x, y, colWidth, colHeight);
    }
    
    /**
     *  Returns the index of the row at the specified coordinates. If
     *  the coordinates lie in a gap area, the index returned is the
     *  previous row.
     * 
     *  @return The index of the row at the coordinates provided. If the
     *  coordinates are out of bounds, return -1.
     */
    public function getRowIndexAt(x:Number, y:Number):int
    {
        if (y < 0)
            return -1;
        
        var index:int;
        
        if (!isNaN(fixedRowHeight))
        {
            index = y / (fixedRowHeight + rowGap);
            return index < _rowCount ? index : -1;
        }
        
        if (rowList.length == 0)
        {
            index = y / (defaultRowHeight + rowGap);
            return index < _rowCount ? index : -1;
        }
        
        if (y == 0)
            return _rowCount > 0 ? 0 : -1;
        
        // initialize first node.
        if (!recentNode)
        {
            recentNode = rowList.first;
            startY = recentNode.rowIndex * (defaultRowHeight + rowGap);
        }
        
        // if we are already at the right row, then use the index.
        if (isYInRow(y, startY, recentNode))
            index = recentNode.rowIndex;
        else if (y < startY)
            index = getPrevRowIndexAt(y, recentNode, startY);
        else
            index = getNextRowIndexAt(y, recentNode, startY);
        
        return index < _rowCount ? index : -1;
    }
    
    /**
     *  Checks if a certain y value lies in a row's bounds.
     */
    private function isYInRow(y:Number, startY:Number, node:GridRowNode):Boolean
    {
        var end:Number = startY + node.maxCellHeight;
        
        // don't add gap for last row.
        if (node.rowIndex != rowCount - 1)
            end += rowGap;
        
        // if y is between cumY and cumY + rowHeight - 1 then y is in the row.
        if (y >= startY && y < end)
            return true;
        
        return false;
    }
    
    /**
     *  Returns the index of the row that contains the specified y value.
     *  The row will be before startNode.
     *  
     *  @param y the target y value
     *  @param startNode the node to search from
     *  @param startY the cumulative y value from the first row to startNode
     * 
     *  @return the index of the row that contains the y value.
     */
    private function getPrevRowIndexAt(y:Number, startNode:GridRowNode, startY:Number):int
    {
        var node:GridRowNode = startNode;
        var prevNode:GridRowNode = null;
        var index:int = node.rowIndex;
        var currentY:Number = startY;
        var prevY:Number;
        var targetY:Number = y;

        while (node)
        {
            // check the current node.
            if (isYInRow(targetY, currentY, node))
                break;
            
            // calculate previous y.
            prevNode = node.prev;
            
            if (!prevNode)
            {
                prevY = 0;
            }
            else
            {
                prevY = currentY;
                
                var indDiff:int = node.rowIndex - prevNode.rowIndex;
                
                // subtract default row heights if difference is greater than one.
                if (indDiff > 1)
                    prevY -= (indDiff - 1) * (defaultRowHeight + rowGap);
            }
            
            // check if target Y is in range.
            if (targetY < currentY && targetY >= prevY)
            {
                index = index - Math.ceil(Number(currentY - targetY)/(defaultRowHeight + rowGap));
                break;
            }

            // subtract previous node's height and its gap.
            currentY = prevY - prevNode.maxCellHeight - rowGap;
            node = node.prev;
            index = node.rowIndex;
        }
        
        this.recentNode = node;
        this.startY = currentY;
        
        return index;
    }
    
    /**
     *  Returns the index of the row that contains the specified y value.
     *  The row will be after startNode.
     *  
     *  @param y the target y value
     *  @param startNode the node to search from
     *  @param startY the cumulative y value from the first row to startNode
     * 
     *  @return the index of the row that contains the y value.
     */
    private function getNextRowIndexAt(y:Number, startNode:GridRowNode, startY:Number):int
    {
        var node:GridRowNode = startNode;
        var nextNode:GridRowNode = null;
        var index:int = node.rowIndex;
        var nodeY:Number = startY;
        var currentY:Number = startY;
        var nextY:Number;
        var targetY:Number = y;
        
        while (node)
        {
            // check the current node.
            if (isYInRow(targetY, nodeY, node))
                break;
            
            // currentY increments to end of the current node.
            currentY += node.maxCellHeight;
            if (node.rowIndex != rowCount - 1)
                currentY += rowGap;
            
            // calculate end of next section.
            nextNode = node.next;
            nextY = currentY;
            
            var indDiff:int;
            
            if (!nextNode)
            {
                indDiff = rowCount - 1 - node.rowIndex;
                // the y at the end doesn't have a rowGap, but includes the final pixel.
                nextY += indDiff * (defaultRowHeight + rowGap) - rowGap + 1;
            }
            else
            {
                indDiff = nextNode.rowIndex - node.rowIndex;
                nextY += (indDiff - 1) * (defaultRowHeight + rowGap);
            }
            
            // check if target Y is within default row heights range.
            if (targetY >= currentY && targetY < nextY)
            {
                index = index + Math.ceil(Number(targetY - currentY)/(defaultRowHeight + rowGap));
                break;
            }
            
            // if no next node and we didn't find the target, then the row doesn't exist.
            if (!nextNode)
            {
                index = -1;
                break;
            }
            
            // move y values ahead to next node.
            nodeY = currentY = nextY;
            
            node = node.next;
            index = node.rowIndex;
        }
        
        this.recentNode = node;
        this.startY = nodeY;
        
        return index;
    }
    
    /**
     *  Returns the index of the column at the specified coordinates. If
     *  the coordinates lie in a gap area, the index returned is the
     *  previous column. Returns -1 if the coordinates are out of bounds.
     */
    public function getColumnIndexAt(x:Number, y:Number):int
    {
        if (!_columnWidths)
            return x / (defaultColumnWidth + columnGap);
        
        var cur:Number = x;
        var i:int;
        
        for (i = 0; i < _columnCount; i++)
        {
            var temp:Number = _columnWidths[i];
            
            if (isNaN(temp))
                cur -= defaultColumnWidth + columnGap;
            else
                cur -= temp + columnGap;
            
            if (cur < 0)
                return i;
        }
        
        return -1;
    }
    
    /**
     *  Returns the total layout width of the content including gaps.   If 
	 *  columnCountOverride is specified, then the overall width of as many columns
	 *  is returned.
     */
    public function getContentWidth(columnCountOverride:int = -1):Number
    {
		const nCols:int = (columnCountOverride == -1) ? columnCount : columnCountOverride;
        var contentWidth:Number = 0;
        
        if (nCols > 1)
            contentWidth += (nCols - 1) * columnGap;
        
        // short circuit for no column widths set yet.
        if (!_columnWidths)
            return contentWidth + nCols * defaultColumnWidth;
        
        for (var i:int = 0; i < nCols; i++)
        {
            if ((i >= _columnWidths.length) || isNaN(_columnWidths[i]))
                contentWidth += defaultColumnWidth;
            else
                contentWidth += _columnWidths[i];
        }
        
        return contentWidth;
    }
    
    /**
     *  Returns the total layout height of the content including gaps.  If 
	 *  rowHeightOverride is specified, then the overall height of as many rows
	 *  is returned.
     */
    public function getContentHeight(rowCountOverride:int = -1):Number
    {
		const nRows:int = (rowCountOverride == -1) ? rowCount : rowCountOverride;
		var contentHeight:Number = 0;
        
        if (nRows > 1)
            contentHeight += (nRows - 1) * rowGap;
        
        if (!isNaN(fixedRowHeight))
            return contentHeight + nRows * fixedRowHeight;
        
        if (rowList.length == 0)
            return contentHeight + nRows * defaultRowHeight;
        
        var node:GridRowNode = rowList.first;
        var numRows:int = 0;
        
        while (node && node.rowIndex < nRows)
        {
            contentHeight += node.maxCellHeight;
            numRows++;
            node = node.next;
        }
    
        contentHeight += (nRows - numRows) * defaultRowHeight;
        
        return contentHeight;
    }
    
    /**
     *  Returns the sum of the typical cell widths including gaps.  If 
	 *  columnCountOverride is specified, then the overall typicalCellWidth 
     *  of as many columns is returned. 
     */
    public function getTypicalContentWidth(columnCountOverride:int = -1):Number
    {
        const nCols:int = (columnCountOverride == -1) ? columnCount : columnCountOverride;
        var contentWidth:Number = 0;
        
        for (var columnIndex:int = 0; columnIndex < nCols; columnIndex++)
        {
            var width:Number = typicalCellWidths[columnIndex];
            contentWidth += isNaN(width) ? defaultColumnWidth : width;
        }
        
        if (nCols > 1)
            contentWidth += (nCols - 1) * columnGap;

        return contentWidth;
    }
    
    /**
     *  Returns the content height which is maximum cell height of the
     *  typical item times the total number of rows including gaps. 
     *  If rowCountOverride is specified, then we only include that many rows.
     */
    public function getTypicalContentHeight(rowCountOverride:int = -1):Number
    {
        const nRows:int = (rowCountOverride == -1) ? rowCount : rowCountOverride;
        var contentHeight:Number = 0;
        
        if (nRows > 1)
            contentHeight += (nRows - 1) * rowGap;
        
        if (!isNaN(fixedRowHeight))
            return contentHeight + nRows * fixedRowHeight;
        
        // if typical cell heights have been specified.
        if (!isFirstTypicalCellHeight)
            return contentHeight + nRows * defaultRowHeight
        
        return 0;
    }
        
    /**
     *  Return the preferred bounds width of the grid's typicalItem when rendered with the item renderer 
     *  for the specified column.  If no value has yet been specified, return NaN.
     */
    public function getTypicalCellWidth(columnIndex:int):Number
    {
        return typicalCellWidths[columnIndex];
    }
    
    /**
     *  Sets the preferred bounds width of the grid's typicalItem for the specified column.
     */
    public function setTypicalCellWidth(columnIndex:int, value:Number):void
    {
        typicalCellWidths[columnIndex] = value;
    }
    
    /**
     *  Return the preferred bounds height of the grid's typicalItem when rendered with the item renderer 
     *  for the specified column.  If no value has yet been specified, return NaN.
     */    
    public function getTypicalCellHeight(columnIndex:int):Number
    {
        return typicalCellHeights[columnIndex];
    }
    
    /**
     *  Sets the preferred bounds height of the grid's typicalItem for the specified column.
     */    
    public function setTypicalCellHeight(columnIndex:int, value:Number):void
    {
        typicalCellHeights[columnIndex] = value;
        
        // if this is the first cell height, set default to it
        if (isFirstTypicalCellHeight)
        {
            this.defaultRowHeight = value;
            isFirstTypicalCellHeight = false;
        }
        else
        {
            // otherwise, find the max of the typical cell heights.
            var max:Number = 0;
            for (var i:int = 0; i < typicalCellHeights.length; i++)
                max = Math.max(max, typicalCellHeights[i]);
            this.defaultRowHeight = max;
        }
    }
    
    /**
     *  Clears the typical cell for every column and row.
     */
    public function clearTypicalCellWidthsAndHeights():void
    {
        typicalCellWidths.length = 0;
        typicalCellHeights.length = 0;
        defaultRowHeight = 26;
        isFirstTypicalCellHeight = true;
    }
        
    /**
     *  Inserts count number of rows starting from startRow. This shifts
     *  any rows after startRow down by count and will increment 
     *  rowCount.
     */
    public function insertRows(startRow:int, count:int):void
    {
        insertRowsAt(startRow, count);
    }
    
    /**
     *  Inserts count number of columns starting from startColumn. This
     *  shifts any columns after startColumn down by count and will
     *  increment columnCount. 
     */
    public function insertColumns(startColumn:int, count:int):void
    {
    }
    
    /**
     *  Removes count number of rows starting from startRow. This
     *  shifts any rows after startRow up by count and will
     *  decrement rowCount.
     */
    public function removeRows(startRow:int, count:int):void
    {
        removeRowsAt(startRow, count);
    }
    
    /**
     *  Removes count number of columns starting from startColumn. This
     *  shifts any columns after startColumn up by count and will
     *  decrement columnCount.
     */
    public function removeColumns(startColumn:int, count:int):void
    {
    }
    
    /**
     *  Moves count number of rows from the fromRow index to the toRow
     *  index. This operation will not affect rowCount.
     */
    public function moveRows(fromRow:int, toRow:int, count:int):void
    {
        var rows:Vector.<GridRowNode> = removeRowsAt(fromRow, count);
        
        // Set the row indices of the nodes that are moving.
        var diff:int = toRow - fromRow;
        for each (var node:GridRowNode in rows)
        {
            node.rowIndex = node.rowIndex + diff;
        }
        
        insertRowsAt(toRow, count, rows);
    }
    
    /**
     *  Moves count number of columns from the fromCol index to the toCol
     *  index. This operation will not affect colCount.
     */
    public function moveColumns(fromCol:int, toCol:int, count:int):void
    {
    }
    
    /**
     *  Removes all cells and sets rowCount to 0.
     */
    public function clear():void
    {
        rowCount = 0;
        rowList.removeAll();
        this.recentNode = null;
        this.recentNode2 = null;
        this.startY = 0;
        this.startY2 = 0;
    }
    
    /**
     *  Inserts count number of rows starting from startRow. This will increment 
     *  rowCount. If the nodes parameter is set, the nodes will be inserted
     *  to the rowList.
     */
    private function insertRowsAt(startRow:int, count:int, nodes:Vector.<GridRowNode> = null):void
    {
        if (startRow < 0 || count <= 0)
            return;
        
        var startNode:GridRowNode = rowList.findNearestLTE(startRow);
        var node:GridRowNode;
        
        // start on the index we're inserting at.
        if (startNode && startNode.rowIndex < startRow)
            startNode = startNode.next;
        
        // first we insert the nodes before this node.
        if (nodes)
        {
            for each (node in nodes)
            {
                rowList.insertBefore(startNode, node);
            }
        }
        
        // increment the index of nodes after this node.
        node = startNode;
        while (node)
        {
            node.rowIndex += count;
            node = node.next;
        }
        
        this.rowCount += count;
        
        // cache is invalid now.
        recentNode = null;
        recentNode2 = null;
    }
    
    /**
     *  Removes count number of rows starting from startRow. This will
     *  decrement rowCount. Returns any removed nodes.
     */
    private function removeRowsAt(startRow:int, count:int):Vector.<GridRowNode>
    {
        var vec:Vector.<GridRowNode> = new Vector.<GridRowNode>();
        if (startRow < 0 || count <= 0)
            return vec;
        
        var node:GridRowNode = rowList.findNearestLTE(startRow);
        var endRow:int = startRow + count;
        var oldNode:GridRowNode;
        
        if (node && node.rowIndex < startRow)
            node = node.next;
        
        while (node && node.rowIndex < endRow)
        {
            oldNode = node;
            vec.push(oldNode);
            node = node.next;
            rowList.removeNode(oldNode);
        }
        
        while (node)
        {
            node.rowIndex -= count;
            node = node.next;
        }
        
        this.rowCount -= count;
        
        // cache is invalid now.
        recentNode = null;
        recentNode2 = null;
        return vec;
    }
    
    /**
     *  Removes any nodes that occupy the indices between startRow
     *  and startRow + count.
     */
    private function clearRows(startRow:int, count:int):void
    {
        if (startRow < 0 || count <= 0)
            return;
        
        var node:GridRowNode = rowList.findNearestLTE(startRow);
        var endRow:int = startRow + count;
        var oldNode:GridRowNode;
        
        if (node && node.rowIndex < startRow)
            node = node.next;
        
        while (node && node.rowIndex < endRow)
        {
            oldNode = node;
            node = node.next;
            rowList.removeNode(oldNode);
        }
        
        // cache is invalid now.
        recentNode = null;
        recentNode2 = null;
    }

    /**
     *  Handles changes in the dataProvider.
     */
    public function dataProviderCollectionChanged(event:CollectionEvent):Boolean 
    {
        // TBD (klin): don't think we need to return booleans...
        switch (event.kind)
        {
            case CollectionEventKind.ADD: return dataProviderCollectionAdd(event);
            case CollectionEventKind.REMOVE: return dataProviderCollectionRemove(event);
            case CollectionEventKind.REPLACE: return dataProviderCollectionReplace(event);
            case CollectionEventKind.MOVE: return dataProviderCollectionMove(event);
            case CollectionEventKind.REFRESH: return dataProviderCollectionRefresh(event);
            case CollectionEventKind.RESET: return dataProviderCollectionReset(event);
            case CollectionEventKind.UPDATE: return true; // handled by GridLayout
        }
        
        return false;
    }
    
    /**
     *  @private
     */
    private function dataProviderCollectionAdd(event:CollectionEvent):Boolean
    {
        insertRows(event.location, event.items.length);
        return true;
    }
    
    /**
     *  @private
     */
    private function dataProviderCollectionRemove(event:CollectionEvent):Boolean
    {
        removeRows(event.location, event.items.length);
        return true;
    }
    
    /**
     *  @private
     */
    private function dataProviderCollectionReplace(event:CollectionEvent):Boolean
    {
        clearRows(event.location, event.items.length);
        return true;
    }
    
    /**
     *  @private
     */
    private function dataProviderCollectionMove(event:CollectionEvent):Boolean
    {
        moveRows(event.oldLocation, event.location, event.items.length);
        return true;
    }
    
    /**
     *  @private
     */
    private function dataProviderCollectionReset(event:CollectionEvent):Boolean
    {
        clear();
        clearTypicalCellWidthsAndHeights();
        this.rowCount = IList(event.target).length;
        return true;
    }
    
    /**
     *  @private
     */
    private function dataProviderCollectionRefresh(event:CollectionEvent):Boolean
    {
        clear();
        this.rowCount = IList(event.target).length;
        return true;
    }    
}
}