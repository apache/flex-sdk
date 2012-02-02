////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.controls.advancedDataGridClasses
{

import mx.core.mx_internal;

use namespace mx_internal;

/**
 *  The AdvancedDataGridBaseSelectionData class defines a data structure 
 *  used by the advanced data grid classes to track selected cells in the AdvancedDataGrid control.
 *  Each selected cell is represented by an instance of this class.
 *
 *  @see mx.controls.AdvancedDataGrid
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class AdvancedDataGridBaseSelectionData
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
     *  @param data The data Object that represents the selected cell.
     *
     *  @param rowIndex The index in the data provider of the selected item. 
     *  This value may be approximate. 
     *
     *  @param columnIndex The column index of the selected cell.
     *
     *  @param approximate If <code>true</code>, the <code>index</code> property 
     *  contains an approximate value and not the exact value.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function AdvancedDataGridBaseSelectionData(data:Object,
                                                    rowIndex:int,
                                                    columnIndex:int,
                                                    approximate:Boolean)
    {
        super();

        this.data        = data;
        this.rowIndex    = rowIndex;
        this.columnIndex = columnIndex;
        this.approximate = approximate;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  The next AdvancedDataGridBaseSelectionData in a linked list
     *  of AdvancedDataGridBaseSelectionData.
     *  AdvancedDataGridBaseSelectionData instances are linked together and keep track
     *  of the order in which the user selects items.
     *  This order is reflected in selectedIndices, selectedItems, selectedCells.
     */
    mx_internal var nextSelectionData:AdvancedDataGridBaseSelectionData;

    /**
     *  @private
     *  The previous AdvancedDataGridBaseSelectionData in a linked list
     *  of AdvancedDataGridBaseSelectionData.
     *  AdvancedDataGridBaseSelectionData instances are linked together and keep track
     *  of the order in which the user selects items.
     *  This order is reflected in selectedIndices, selectedItems, selectedCells.
     */
    mx_internal var prevSelectionData:AdvancedDataGridBaseSelectionData;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  approximate
    //----------------------------------

    /**
     *  If <code>true</code>, the <code>rowIndex</code> and <code>columnIndex</code> 
     *  properties contain approximate values, and not the exact value.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var approximate:Boolean;

    //----------------------------------
    //  data
    //----------------------------------

    /**
     *  The data Object from the data provider that represents the selected cell.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var data:Object;

    //----------------------------------
    //  rowIndex
    //----------------------------------

    /**
     *  The row index in the data provider of the selected cell. 
     *  This value is approximate if the <code>approximate</code> property is <code>true</code>. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var rowIndex:int;

    //----------------------------------
    //  columnIndex
    //----------------------------------

    /**
     *  The column index in the data provider of the selected cell.
     *  This value is approximate if the <code>approximate</code> property is <code>true</code>. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var columnIndex:int;
}

}
