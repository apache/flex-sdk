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

package spark.events
{

/**
 *  The GridSelectionEventKind class defines constants for the valid values 
 *  of the spark.events.GridSelectionEvent class <code>kind</code> property.
 *  These constants indicate the kind of change that was made to the selection.
 *
 *  @see spark.events.GridSelectionEvent#kind
 *  @see spark.events.GridSelectionEvent
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public final class GridSelectionEventKind
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /** 
     *  Indicates that the entire grid should be selected.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const SELECT_ALL:String = "selectAll";

    /** 
     *  Indicates that current selection should be cleared.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const CLEAR_SELECTION:String = "clearSelection";
    
    /** 
     *  Indicates that the current selection should be set to this row.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const SET_ROW:String = "setRow";
    
    /** 
     *  Indicates that this row should be added to the current selection.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const ADD_ROW:String = "addRow";

    /** 
     *  Indicates that this row should be removed from the current selection.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const REMOVE_ROW:String = "removeRow";

    /** 
     *  Indicates that the current selection should be set to these rows.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const SET_ROWS:String = "setRows";
    
    /** 
     *  Indicates that the current selection should be set to this cell.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const SET_CELL:String = "setCell";

    /** 
     *  Indicates that this cell should be added to the current selection.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    public static const ADD_CELL:String = "addCell";
    
    /** 
     *  Indicates that this cell should be removed from the current selection.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const REMOVE_CELL:String = "removeCell";
    
    /** 
     *  Indicates that the current selection should be set to this cell region.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const SET_CELL_REGION:String = "setCellRegion";
}

}
