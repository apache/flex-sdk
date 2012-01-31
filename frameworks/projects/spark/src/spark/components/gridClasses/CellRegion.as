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
    
/**
 *  The CellRegion class defines a data structure 
 *  used by the spark data grid classes to represent a rectangular region of
 *  cells in the DataGrid control. The origin of the region is specified with
 *  the rowIndex and columnIndex and the extent of the region is specified with
 *  the rowCount and the columnCount.
 *
 *  @see spark.component.DataGrid
 *  @see spark.component.Grid
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2
 *  @productversion Flex 4.5
 */
public class CellRegion
{        
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     * 
     *  @param rowIndex The 0-based row index of the origin cell. A value of -1 indicates "not set".
     *  @param columnIndex The 0-based column index of the origin cell. A value of -1 indicates "not set".
     *  @param rowCount The number of rows in the cell region. 
     *  @param columnCount The number of columns in the cell region.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function CellRegion(rowIndex:int = -1, columnIndex:int = -1,
                               rowCount:uint = 0, columnCount:uint = 0)
    {
        super();
        
        _rowIndex = rowIndex;
        _columnIndex = columnIndex;
        
        _rowCount = rowCount;
        _columnCount = columnCount;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  columnCount
    //----------------------------------
    
    private var _columnCount:uint;
    
    /**
     *  @private
     */
    public function get columnCount():uint
    {
        return _columnCount;
    }
    
    /**
     *  The number of columns in the cell region.
     *
     *  @default 0
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function set columnCount(value:uint):void
    {
        _columnCount = value;
    }
    
    //----------------------------------
    //  columnIndex
    //----------------------------------
    
    private var _columnIndex:int;
    
    /**
     *  @private
     */
    public function get columnIndex():int
    {
        return _columnIndex;
    }
    
    /**
     *  The 0-based column index of the origin of the cell region.
     *  A value of -1 indicates "not set".
     * 
     *  @default -1
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function set columnIndex(value:int):void
    {
        _columnIndex = value;
    }
    
    //----------------------------------
    //  rowCount
    //----------------------------------
    
    private var _rowCount:uint;
    
    /**
     *  @private
     */
    public function get rowCount():uint
    {
        return _rowCount;
    }
    
    /**
     *  The number of rows in the cell region.
     *
     *  @default 0
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function set rowCount(value:uint):void
    {
        _rowCount = value;
    }

    //----------------------------------
    //  rowIndex
    //----------------------------------
    
    private var _rowIndex:int;
    
    /**
     *  @private
     */
    public function get rowIndex():int
    {
        return _rowIndex;
    }
    
    /**
     *  The 0-based row index of the origin of the cell region.  
     *  A value of -1 indicates "not set".
     * 
     *  @default -1
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function set rowIndex(value:int):void
    {
        _rowIndex = value;
    }  
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: Object
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    public function toString():String
    {
        return "[rowIndex=" + rowIndex + " columnIndex=" + columnIndex + 
                " rowCount=" + rowCount + " columnCount=" + columnCount + "]";
    }   
}
}