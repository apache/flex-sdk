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

package spark.events
{

import flash.events.Event;

/**
 *  The GridSelectionEvent class represents events that are dispatched when 
 *  the selection changes in a Spark DataGrid as the result of user interaction.
 *
 *  @see spark.events.GridSelectionEventKind
 *  @see spark.components.DataGrid
 *  @see spark.components.Grid
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
public class GridSelectionEvent extends Event
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  The <code>GridSelectionEvent.SELECTION_CHANGE</code> constant defines 
     *  the value of the <code>type</code> property of the event object for a 
     *  <code>selectionChanging</code> event, which indicates that the current 
     *  selection has just been changed.
     *
     *  <p>The properties of the event object have the following values:</p>
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
     *       event listener that handles the event. For example, if you use 
     *       <code>myButton.addEventListener()</code> to register an event listener, 
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *     <tr><td><code>type</code></td><td>GridSelectionEvent.SELECTION_CHANGE</td></tr>
     *  </table>
     *   
     *  @eventType selectionChange
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public static const SELECTION_CHANGE:String = "selectionChange";
    
    /**
     *  The <code>GridSelectionEvent.SELECTION_CHANGING</code> constant defines 
     *  the value of the <code>type</code> property of the event object for a 
     *  <code>selectionChanging</code> event, which indicates that the current 
     *  selection is about to change. Call preventDefault() on this event
     *  to prevent the selection from changing.
     *
     *  <p>The properties of the event object have the following values:</p>
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
     *       event listener that handles the event. For example, if you use 
     *       <code>myButton.addEventListener()</code> to register an event listener, 
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td>columnCount<code></code></td><td>The number of columns in
     *      a cell region.</td></tr>
     *     <tr><td>columnIndex<code></code></td><td>The 0-based columnIndex of
     *      a cell or the origin of a cell region.</td></tr>
     *     <tr><td>indices<code></code></td><td>A list of rows.</td></tr>
     *     <tr><td>kind<code></code></td><td>The kind of changing event.
     *       The valid values are defined in GridSelectionEventKind 
     *       class as constants.  This value determines which properties in
     *       the event are used.</td></tr>
     *     <tr><td>rowCount<code></code></td><td>The number of rows in
     *      a cell region.</td></tr>
     *     <tr><td>rowIndex<code></code></td><td>The 0-based rowIndex or a
     *      row or a cell or the origin of a cell region.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *     <tr><td><code>type</code></td><td>GridSelectionEvent.SELECTION_CHANGING</td></tr>
     *  </table>
     *   
     *  @eventType selectionChanging
     *  
     *  @see spark.components.DataGrid
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public static const SELECTION_CHANGING:String = "selectionChanging";
        
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  @param type The event type; indicates the action that caused the event.
     *
     *  @param bubbles Specifies whether the event can bubble
     *  up the display list hierarchy.
     *
     *  @param cancelable Specifies whether the behavior
     *  associated with the event can be prevented.
     *
     *  @param kind The kind of changing event.  The valid values are defined in 
     *  <code>GridSelectionEventKind</code> class as constants.  This value 
     *  determines which properties in the event are used.
     * 
     *  @param rowIndex When type is <code>SELECTION_CHANGING</code> and the
     *  kind is one of <code>GridSelectionEvent.SET_ROW</code>, 
     *  <code>GridSelectionEvent.ADD_ROW</code>, or
     *  <code>GridSelectionEvent.REMOVE_ROW</code>, 
     *  the 0-based index from the <code>dataProvider</code> of the row, 
     *  and when kind is one of
     *  <code>GridSelectionEvent.SET_CELL</code>, 
     *  <code>GridSelectionEvent.ADD_CELL</code>, or
     *  <code>GridSelectionEvent.REMOVE_CELL</code>, 
     *  the 0-based index from the <code>dataProvider</code> of origin of the
     *  cell region.
     * 
     *  @param columnIndex When type is <code>SELECTION_CHANGING</code> and the
     *  kind is one of <code>GridSelectionEvent.SET_ROW</code>, 
     *  <code>GridSelectionEvent.ADD_ROW</code>, or
     *  <code>GridSelectionEvent.REMOVE_ROW</code>, 
     *  the 0-based index from the <code>columns</code> of the row, 
     *  and when kind is one of
     *  <code>GridSelectionEvent.SET_CELL</code>, 
     *  <code>GridSelectionEvent.ADD_CELL</code>, or
     *  <code>GridSelectionEvent.REMOVE_CELL</code>, 
     *  the 0-based index from the <code>columns</code> of origin of the
     *  cell region.
     * 
     *  @param rowCount When type is <code>SELECTION_CHANGING</code> and the
     *  kind is <code>GridSelectionEvent.SET_CELLS</code>, the number of
     *  rows in the cell region that is to be selected.  The rows originate 
     *  at rowIndex.
     * 
     *  @param columnCount When type is <code>SELECTION_CHANGING</code> and the
     *  kind is <code>GridSelectionEvent.SET_CELLS</code>, the number of
     *  columns in the cell region that is to be selected.  The columns 
     *  originate at columnIndex. 
     * 
     *  @param indices When type is <code>SELECTION_CHANGING</code> and 
     *  kind is <code>GridSelectionEvent.SET_ROWS</code>,
     *  a Vector of the row indices that are about to be selected.
     * 
     *  @see spark.components.DataGrid#columns
     *  @see spark.components.DataGrid#dataProvider
     *  @spark.events.GridSelectionEventKind
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function GridSelectionEvent(type:String, 
                                       bubbles:Boolean = false,
                                       cancelable:Boolean = false,
                                       kind:String = null,
                                       rowIndex:int = -1,
                                       columnIndex:int= -1,                                        
                                       rowCount:int = -1, 
                                       columnCount:int = -1,
                                       indices:Vector.<int> = null)
     {
        super(type, bubbles, cancelable);

        this.kind = kind;
        
        this.rowIndex = rowIndex;
        this.columnIndex = columnIndex;
        this.rowCount = rowCount;
        this.columnCount = columnCount;
        
        this.indices = indices;
    }

    //--------------------------------------------------------------------------
    //
    // Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  kind
    //----------------------------------
    
    /**
     *  Indicates the kind of event that occurred.
     *  The property value can be one of the values in the 
     *  GridSelectionEventKind class, 
     *  or <code>null</code>, which indicates that the kind is unknown.
     * 
     *  @see GridSelectionEventKind
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public var kind:String;
    
    
    //----------------------------------
    //  rowIndex
    //----------------------------------

    /**
     *  The 0-based index of the row in the <code>dataProvider</code> for
     *  either a row or a cell position, or the origin of a cell region.
     * 
     *  @see spark.components.DataGrid#dataProvider
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public var rowIndex:int;
    
    //----------------------------------
    //  columnIndex
    //----------------------------------
    
    /**
     *  The 0-based index of the column in the <code>columns</code> for
     *  either a cell position or the origin of a cell region.
     * 
     *  @see spark.components.DataGrid#columns
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public var columnIndex:int;
    
    //----------------------------------
    //  rowCount
    //----------------------------------
    
    /**
     *  If selecting a cell region, the number of rows in the cell region.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */    
    public var rowCount:int;

    //----------------------------------
    //  columnCount
    //----------------------------------
    
    /**
     *  If selecting a cell region, the number of columns in the cell region.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */    
    public var columnCount:int;
    
    //----------------------------------
    //  indices
    //----------------------------------
    
    /**
     *  If selecting multiple rows, a Vector of the row indices.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public var indices:Vector.<int>;

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: Object
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override public function toString():String
    {
        return formatToString(
            "GridSelectionEvent", "type", 
            "bubbles", "cancelable", "eventPhase",
            "kind", 
            "rowIndex","columnIndex", "rowCount", "columnCount", 
            "indices");
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: Event
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function clone():Event
    {
        return new GridSelectionEvent(
            type, bubbles, cancelable, kind,
            rowIndex, columnIndex, rowCount, columnCount, indices);
    }
}

}
