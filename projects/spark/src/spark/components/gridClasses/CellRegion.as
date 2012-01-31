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

package spark.components.gridClasses
{
    
/**
 *  The CellRegion class defines a data structure 
 *  used by the Spark data grid classes to represent a rectangular region of
 *  cells in the control. 
 *  The origin of the region is specified by the  
 *  <code>rowIndex</code> and <code>columnIndex</code> properties.
 *  The extent of the region is specified by the 
 *  <code>rowCount</code> and the <code>columnCount</code> properties.
 *
 *  @see spark.components.DataGrid
 *  @see spark.components.Grid
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
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
     *  @param rowIndex The 0-based row index of the origin cell. 
     *  A value of -1 indicates that the value is not set.
     * 
     *  @param columnIndex The 0-based column index of the origin cell. 
     *  A value of -1 indicates that the value is not set.
     * 
     *  @param rowCount The number of rows in the cell region.
     * 
     *  @param columnCount The number of columns in the cell region.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function CellRegion(rowIndex:int = -1, columnIndex:int = -1,
                               rowCount:int = 0, columnCount:int = 0)
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
    
    private var _columnCount:int;
    
    /**
     *  The number of columns in the cell region.
     *
     *  @default 0
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
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
        _columnCount = value;
    }
    
    //----------------------------------
    //  columnIndex
    //----------------------------------
    
    private var _columnIndex:int;
    
    /**
     *  The 0-based column index of the origin of the cell region.
     *  A value of -1 indicates that the value is not set.
     * 
     *  @default -1
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get columnIndex():int
    {
        return _columnIndex;
    }
    
    /**
     *  @private
     */
    public function set columnIndex(value:int):void
    {
        _columnIndex = value;
    }
    
    //----------------------------------
    //  rowCount
    //----------------------------------
    
    private var _rowCount:int;
    
    /**
     *  The number of rows in the cell region.
     *
     *  @default 0
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
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
        _rowCount = value;
    }

    //----------------------------------
    //  rowIndex
    //----------------------------------
    
    private var _rowIndex:int;
    
    /**
     *  The 0-based row index of the origin of the cell region.  
     *  A value of -1 indicates that the value is not set.
     * 
     *  @default -1
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5

     */
    public function get rowIndex():int
    {
        return _rowIndex;
    }
    
    /**
     *  @private
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