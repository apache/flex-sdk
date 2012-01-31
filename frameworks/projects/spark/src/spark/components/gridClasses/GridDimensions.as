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

import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;

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
        
        _columnCount = rowList.numColumns = value;
        
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
            }
        }
    }

    //----------------------------------
    //  rowGap
    //----------------------------------
    
    /**
     *  The gap between rows.
     * 
     *  @default 0 
     */
    public var rowGap:Number = 0;
    
    //----------------------------------
    //  columnGap
    //----------------------------------
    
    /**
     *  The gap between columns. 
     *      
     *  @default 0 
     */
    public var columnGap:Number = 0;
    
    //----------------------------------
    //  defaultRowHeight
    //----------------------------------
    
    private var _defaultRowHeight:Number = 32;
    
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
            return node.cellHeights[col];
        
        return NaN;
    }
    
    /**
     *  Sets the height of the specified cell.
     */
    public function setCellHeight(row:int, col:int, height:Number):void
    {
        var node:GridRowNode = rowList.find(row);
        if (!node)
            node = rowList.insert(row);
        
        if (node)
        {
            node.cellHeights[col] = height;
            node.updateMaxHeight();
        }
    }
    
    /**
     *  Returns the layout bounds of the specified cell. The cell height
     *  and width are determined by its row's height and column's width.
     */
    public function getCellBounds(row:int, col:int):Rectangle
    {
        // TBD: provide optional return value (Rectangle) parameter
        // TBD: return null if row or col are out of bounds
        var x:Number = getCellX(row, col);
        var y:Number = getCellY(row, col);
        
        var width:Number = this.getColumnWidth(col);
        var height:Number = this.getRowHeight(row);
        
        return new Rectangle(x, y, width, height);
    }
    
    private function getCellX(row:int, col:int):Number
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
    
    private function getCellY(row:int, col:int):Number
    {        // no cache so we use default heights for each row.
        if (!isNaN(fixedRowHeight))
            return row * (fixedRowHeight + rowGap);
        
        if (rowList.length == 0)
            return row * (defaultRowHeight + rowGap);
        
        var node:GridRowNode = rowList.first;
        var y:Number = 0;
        var index:int = 0;
        
        while (node)
        {
            // success case: row index is <= to node's index.
            if (row <= node.rowIndex)
            {
                y += (row - index) * (defaultRowHeight + rowGap);
                return y;
            }
            
            // otherwise, row index is > node's index
            
            // case if node index is much greater than current index.
            if (node.rowIndex > index)
            {
                y += (node.rowIndex - index) * (defaultRowHeight + rowGap);
                index += node.rowIndex - index; // index == node.rowIndex
            }
            
            // index is now equal to node's index but row index is > node's index so we add node.
            y += node.maxCellHeight;
            index++;
            
            node = node.next;
        }
        
        // no more nodes, so we just add the rest.
        y += (row - index) * (defaultRowHeight + rowGap);
        return y;
    }
    
    /**
     *  Returns the layout bounds of the specified row.
     */
    public function getRowBounds(row:int):Rectangle
    {
        // TBD: provide optional return value (Rectangle) parameter    
        if ((row < 0) || (row >= rowCount))
            return null;  // TBD: return empty Rectangle instead
        
        const firstCellR:Rectangle = getCellBounds(row, 0);
        const lastCellR:Rectangle = getCellBounds(row, columnCount - 1);
        const rowWidth:Number = lastCellR.x + lastCellR.width - firstCellR.x;
        const rowHeight:Number = firstCellR.height;
        return new Rectangle(firstCellR.x, firstCellR.y, rowWidth, rowHeight); 
    }
    
    /**
     *  Returns the layout bounds of the specified column.
     */
    public function getColumnBounds(col:int):Rectangle
    {
        // TBD: provide optional return value (Rectangle) parameter
        if ((col < 0) || (col >= columnCount))
            return null;  // TBD: return empty Rectangle instead

        const firstCellR:Rectangle = getCellBounds(0, col);
        const lastCellR:Rectangle = getCellBounds(rowCount - 1, col);
        const colWidth:Number = firstCellR.width;
        const colHeight:Number = lastCellR.y + lastCellR.height - firstCellR.y;
        return new Rectangle(firstCellR.x, firstCellR.y, colWidth, colHeight); 
    }
    
    /**
     *  Returns the index of the row at the specified coordinates. If
     *  the coordinates lie in a gap area, the index returned is the
     *  previous row.
     */
    public function getRowIndexAt(x:Number, y:Number):int
    {
        // TODO (klin): fixed height rows.
        if (!isNaN(fixedRowHeight))
            return y / (fixedRowHeight + rowGap);
        
        if (rowList.length == 0)
            return y / (defaultRowHeight + rowGap);
        
        var node:GridRowNode = rowList.first;
        var index:int = 0;
        var cur:Number = y;
        var n:int;
        
        while (node)
        {
            // add not included rows.
            if (node.rowIndex > index)
            {
                n = node.rowIndex - index;
                for (var i:int = 0; i < n; i++)
                {
                    cur -= defaultRowHeight + rowGap;
                    if (cur < 0)
                        return index;
                    index++;
                }
            }
            
            cur -= node.maxCellHeight + rowGap;
            if (cur < 0)
                return index;
            index++;
            
            node = node.next;
        }
        
        n = this.rowCount;
        for (; index < n; index++)
        {
            cur -= defaultRowHeight + rowGap;
            if (cur < 0)
                return index;
        }
        
        return -1;
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
     *  Returns the total layout width of the content including gaps.
     */
    public function get contentWidth():Number
    {
        if (!_columnWidths)
            return (_columnCount * (defaultColumnWidth + columnGap)) - columnGap;
        
        var width:Number = 0;
        
        for (var i:int = 0; i < _columnCount; i++)
        {
            if (isNaN(_columnWidths[i]))
                width += defaultColumnWidth + columnGap;
            else
                width += _columnWidths[i] + columnGap;
        }
        
        return width - columnGap;
    }
    
    /**
     *  Returns the total layout height of the content including gaps.
     */
    public function get contentHeight():Number
    {
        if (!isNaN(fixedRowHeight))
            return (rowCount * (fixedRowHeight + rowGap)) - rowGap;
        
        if (rowList.length == 0)
            return (rowCount * (defaultRowHeight + rowGap)) - rowGap;
        
        var height:Number = 0;
        var node:GridRowNode = rowList.first;
        var numRows:int = 0;
        
        while (node)
        {
            height += node.maxCellHeight;
            numRows++;
            node = node.next;
        }
        
        return height + ((rowCount - numRows) * (defaultRowHeight) + (rowCount - 1) * rowGap);
    }

    /**
     *  Inserts count number of rows starting from startRow. This shifts
     *  any rows after startRow down by count and will increment 
     *  rowCount.
     */
    public function insertRows(startRow:int, count:int):void
    {
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
    }

    /**
     *  Handles changes in the dataProvider.
     */
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
     */
    private function dataProviderCollectionAdd(event:CollectionEvent):Boolean
    {
        rowCount +=  event.items.length;
        return true;
    }
    
    /**
     *  @private
     */
    private function dataProviderCollectionRemove(event:CollectionEvent):Boolean
    {
        rowCount -= event.items.length;
        return true;
    }
}
}