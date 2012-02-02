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

/**
 *  The SortInfo class defines information about the sorting of a column
 *  of the AdvancedDataGrid control.
 *  Each column in the AdvancedDataGrid control has an associated 
 *  SortInfo instance. 
 *  The AdvancedDataGridSortItemRenderer class uses the 
 *  information in the SortInfo instance to create the item renderer 
 *  for the sort icon and text field in the column header of each column in 
 *  the AdvancedDataGrid control.
 *
 *  @see mx.controls.AdvancedDataGrid
 *  @see mx.controls.advancedDataGridClasses.AdvancedDataGridSortItemRenderer 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class SortInfo
{
    include "../../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Specifies that the sort is only a visual
     *  indication of the proposed sort.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const PROPOSEDSORT:String = "proposedSort";

    /**
     *  Specifies that the sort is the actual current sort.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const ACTUALSORT:String   = "actualSort";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  @param sequenceNumber The number of this column in the sort order sequence.
     *
     *  @param descending <code>true</code> when the column is sorted in descending order.
     *
     *  @param status <code>PROPOSEDSORT</code> if the sort is only a visual
     *  indication of the proposed sort, or <code>ACTUALSORT</code>
     *  if the sort is the actual current sort.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function SortInfo(sequenceNumber:int = -1, descending:Boolean = false,
                                status:String = ACTUALSORT)
    {
        this.sequenceNumber = sequenceNumber;
        this.descending     = descending;
        this.status         = status;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    // sequenceNumber
    //--------------------------------------------------------------------------

    /**
     *  The number of this column in the sort order sequence. 
     *  This number is used when sorting by multiple columns.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var sequenceNumber:int;

    //--------------------------------------------------------------------------
    // descending
    //--------------------------------------------------------------------------

    /**
     *  Contains <code>true</code> when the column is sorted in descending order,
     *  and <code>false</code> when the column is sorted in ascending order.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var descending:Boolean;

    //--------------------------------------------------------------------------
    // status
    //--------------------------------------------------------------------------

    /**
     *  Contains <code>PROPOSEDSORT</code> if the sort is only a visual
     *  indication of the proposed sort, or contains <code>ACTUALSORT</code>
     *  if the sort is the actual current sort.
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var status:String;
    
} // end class SortInfo

} // end package mx.controls.advancedDataGridClasses