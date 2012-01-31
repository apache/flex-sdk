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
 *  The CellPosition class defines a data structure 
 *  used by the Spark data grid classes to represent selected cells in the 
 *  control.  
 *  Each selected cell is represented by an instance of this class.
 *
 *  @see spark.components.DataGrid#selectedCell
 *  @see spark.components.DataGrid#selectedCells
 *  @see spark.components.Grid#selectedCell
 *  @see spark.components.Grid#selectedCells
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class CellPosition
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
     *  @param rowIndex The 0-based row index of the cell. 
     *  A value of -1 indicates that the value is not set.
     * 
     *  @param columnIndex The 0-based column index of the cell. 
     *  A value of -1 indicates that the value is not set.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function CellPosition(rowIndex:int = -1, columnIndex:int = -1)
    {
        super();
        
        _rowIndex = rowIndex;
        _columnIndex = columnIndex;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  columnIndex
    //----------------------------------
    
    private var _columnIndex:int;
    
    /**
     *  The 0-based column index of the cell.
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
    //  rowIndex
    //----------------------------------
    
    private var _rowIndex:int;
    
    /**
     *  The 0-based row index of the cell.  
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
        return "[rowIndex=" + rowIndex + " columnIndex=" + columnIndex + "]";
    }   
}
}