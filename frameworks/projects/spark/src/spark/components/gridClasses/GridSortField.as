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

import spark.collections.SortField;

[ExcludeClass]

/**
 *  A subclass of SortField used by DataGrid and GridColumn to keep track
 *  of complex dataFields when trying to reverse the sort.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class GridSortField extends SortField
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function GridSortField(name:String=null, descending:Boolean=false, numeric:Object=null)
    {
        super(name, descending, numeric);
    }
    
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  The complex dataField in dot notation
     *  of the column associated with this SortField.
     *  
     *  If dataFieldPath is specified, the name is null.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var dataFieldPath:String;
}
}