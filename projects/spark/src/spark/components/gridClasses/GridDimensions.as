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

import spark.primitives.Rect;

public class GridDimensions 
{
    include "../../core/Version.as";    

    public function GridDimensions()
    {
        super();        
    }
    
    public var rowCount:int = 0;
    public var columnCount:int = 0;
    
    public var rowGap:Number = 0;
    public var columnGap:Number = 0;
    
    public var defaultRowHeight:Number = 32; 
    public var defaultColumnWidth:Number = 150;
    
    public var fixedRowHeight:Number = NaN; // if specified, applies to all rows
    
    // Unless setRowHeight is called, return the max cell height for this row
    public function getRowHeight(row:int):Number
    {
        return defaultRowHeight;
    }
    
    public function setRowHeight(row:int, height:Number):void
    {
    }

    public function getColumnWidth(col:int):Number
    {
        return defaultColumnWidth;
    }
    
    public function setColumnWidth(col:int, width:Number):void
    {
    }

    public function getCellHeight(row:int, col:int):Number
    {
        return defaultRowHeight;
    }
    
    public function setCellHeight(row:int, col:int, height:Number):void
    {
    }
    
    // TBD: provide optional return value (Rectangle) parameter
    public function getCellBounds(row:int, col:int):Rectangle
    {
        // TBD: return null if row or col are out of bounds
        return new Rectangle(col * (defaultColumnWidth + columnGap), row * (defaultRowHeight + rowGap), defaultColumnWidth, defaultRowHeight);
    }

    // TBD: provide optional return value (Rectangle) parameter    
    public function getRowBounds(row:int):Rectangle
    {
        if ((row < 0) || (row >= rowCount))
            return null;  // TBD: return empty Rectangle instead
        
        const firstCellR:Rectangle = getCellBounds(row, 0);
        const lastCellR:Rectangle = getCellBounds(row, columnCount - 1);
        const rowWidth:Number = lastCellR.x + lastCellR.width - firstCellR.x;
        const rowHeight:Number = firstCellR.height;
        return new Rectangle(firstCellR.x, firstCellR.y, rowWidth, rowHeight); 
    }
    
    // TBD: provide optional return value (Rectangle) parameter
    public function getColumnBounds(col:int):Rectangle
    {
        if ((col < 0) || (col >= columnCount))
            return null;  // TBD: return empty Rectangle instead

        const firstCellR:Rectangle = getCellBounds(0, col);
        const lastCellR:Rectangle = getCellBounds(rowCount - 1, col);
        const colWidth:Number = firstCellR.width;
        const colHeight:Number = lastCellR.y + lastCellR.height - firstCellR.y;
        return new Rectangle(firstCellR.x, firstCellR.y, colWidth, colHeight); 
    }
    
    // returns -1 if there isn't one
    public function getRowIndexAt(x:Number, y:Number):int
    {
        return y / (defaultRowHeight + rowGap);
    }

    // returns -1 if there isn't one
    public function getColumnIndexAt(x:Number, y:Number):int
    {
        return x / (defaultColumnWidth + columnGap);
    }
    
    public function get contentWidth():Number
    {
        return (columnCount * (defaultColumnWidth + columnGap)) - columnGap;         
    }
    
    public function get contentHeight():Number
    {
        return (rowCount * (defaultRowHeight + rowGap)) - rowGap;         
    }

    public function insertRows(startRow:int, count:int):void
    {
    }
    
    public function insertColumns(startColumn:int, count:int):void
    {
    }
    
    public function removeRows(startRow:int, count:int):void
    {
    }
    
    public function removeColumns(startColumn:int, count:int):void
    {
    }
    
    public function moveRows(fromRow:int, toRow:int, count:int):void
    {
    }
    
    public function moveColumns(fromCol:int, toCol:int, count:int):void
    {
    }
    
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
    
    private function dataProviderCollectionAdd(event:CollectionEvent):Boolean
    {
        rowCount +=  event.items.length;
        return true;
    }
    
    private function dataProviderCollectionRemove(event:CollectionEvent):Boolean
    {
        rowCount -= event.items.length;
        return true;
    }
}
}