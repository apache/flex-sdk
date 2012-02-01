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
import flash.events.Event;

import spark.components.IGridItemEditor;
import spark.components.supportClasses.GridColumn;

/**
 *  The DatGridEditEvent class represents events that are dispatched over 
 *  the life cycle of an item editor.
 *
 *  <p>The life cycle starts with the dispatch of an <code>
 *  START_GRID_ITEM_EDITOR_SESSION</code> event. This event may be cancelled by a
 *  listener to stop the creation of an editing session.</p>
 * 
 *  <p>Next, after the editor is opened the <code>OPEN_GRID_ITEM_EDITOR_SESSION
 * </code> is dispatched to notify listeners that the editor has been opened.</p>
 * 
 *  <p>The editing session can be saved or cancelled. If the session is saved
 *  then the <code>SAVE_GRID_ITEM_EDITOR_SESSION</code> event is dispatched.
 *  If the editor is cancelled a <code>CANCEL_GRID_ITEM_EDITOR_SESSION</code>
 *  event is dispatched.
 * </p>
 * 
 *  @see spark.components.DataGrid
 *  @see spark.components.IGridItemEditor
 *  @see spark.components.supportClasses.GridColumn;
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
public class DataGridEditEvent extends Event
{
    include "../core/Version.as";    
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  The <code>DataGridEditEvent.START_GRID_ITEM_EDITOR_SESSION</code> 
     *  constant defines the value of the <code>type</code> property of the
     *  event object for a <code>startGridItemEditorSession</code> event. 
     *  This event is dispatch by the data grid when a new item editor 
     *  session has been requested. A listener can dynamically determine 
     *  if a cell is editable and cancel the edit if it is not. A listener 
     *  may also dynamically change the editor that will be used by assigning a
     *  different item editor to a column.
     * 
     *  <p>If this event is cancelled the item editor will not be created.</p>
     *
     *  <p>The properties of the event object have the following values:</p>
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
     *     <tr><td><code>cancelable</code></td><td>true</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
     *       event listener that handles the event. For example, if you use 
     *       <code>myButton.addEventListener()</code> to register an event listener, 
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>columnIndex</code></td><td>The zero-based column 
     *       index of the requested item editor.</td></tr>
     *     <tr><td><code>rowIndex</code></td><td>The zero-based row index 
     *        of the requested item editor.</td></tr>
     *     <tr><td><code>column</code></td><td>The column of the cell associated
     *     with the edit request.
     *     </td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *     <tr><td><code>type</code></td><td>
     *     DataGridEditEvent.START_GRID_ITEM_EDITOR_SESSION</td></tr>
     *  </table>
     *   
     *  @eventType startGridItemEditorSession
     * 
     *  @see spark.components.supportClasses.GridColumn;
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public static const START_GRID_ITEM_EDITOR_SESSION:String = "startGridItemEditorSession";
    
    /**
     *  The <code>DataGridEditEvent.OPEN_GRID_ITEM_EDITOR_SESSION</code> 
     *  constant defines the value of the <code>type</code> property of the
     *  event object for a <code>openGridItemEditor</code> event. 
     *  This event is dispatch by the data grid after an item editor has 
     *  been opened for a cell. 
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
     *     <tr><td><code>columnIndex</code></td><td>The zero-based column 
     *       index of the item editor.</td></tr>
     *     <tr><td><code>rowIndex</code></td><td>The zero-based row index 
     *        of the item editor.</td></tr>
     *     <tr><td><code>column</code></td><td>The column of the cell that is
     *     being edited.
     *     </td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *     <tr><td><code>type</code></td><td>
     *     DataGridEditEvent.OPEN_GRID_ITEM_EDITOR_SESSION</td></tr>
     *  </table>
     *   
     *  @eventType openGridItemEditor
     * 
     *  @see spark.components.supportClasses.GridColumn;
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public static const OPEN_GRID_ITEM_EDITOR_SESSION:String = "openGridItemEditor";

    /**
     *  The <code>DataGridEditEvent.SAVE_GRID_ITEM_EDITOR_SESSION</code> 
     *  constant defines the value of the <code>type</code> property of the
     *  event object for a <code>saveGridItemEditor</code> event. 
     *  This event is dispatch by the data grid after the data in item editor
     *  has been saved into the item and the editor has been closed.  
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
     *     <tr><td><code>columnIndex</code></td><td>The zero-based column 
     *       index of the item that was modified.</td></tr>
     *     <tr><td><code>rowIndex</code></td><td>The zero-based row index 
     *        of the item that was modified.</td></tr>
     *     <tr><td><code>column</code></td><td>The column of the cell that was
     *     edited.
     *     </td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *     <tr><td><code>type</code></td><td>
     *     DataGridEditEvent.SAVE_GRID_ITEM_EDITOR_SESSION</td></tr>
     *  </table>
     *   
     *  @eventType saveGridItemEditor
     * 
     *  @see spark.components.supportClasses.GridColumn;
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public static const SAVE_GRID_ITEM_EDITOR_SESSION:String = "saveGridItemEditor";

    /**
     *  The <code>DataGridEditEvent.CANCEL_GRID_ITEM_EDITOR_SESSION</code> 
     *  constant defines the value of the <code>type</code> property of the
     *  event object for a <code>cancelridItemEditor</code> event. 
     *  This event is dispatch by the data grid after item editor has been 
     *  closed with saving its data.  
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
     *     <tr><td><code>columnIndex</code></td><td>The zero-based column 
     *       index of the item that was edited but not modified.</td></tr>
     *     <tr><td><code>rowIndex</code></td><td>The zero-based row index 
     *        of the item that was edited but not modified.</td></tr>
     *     <tr><td><code>column</code></td><td>The column of the cell that was
     *     edited.
     *     </td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *     <tr><td><code>type</code></td><td>
     *     DataGridEditEvent.CANCEL_GRID_ITEM_EDITOR_SESSION</td></tr>
     *  </table>
     *   
     *  @eventType cancelGridItemEditor
     * 
     *  @see spark.components.supportClasses.GridColumn;
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public static const CANCEL_GRID_ITEM_EDITOR_SESSION:String = "cancelGridItemEditor";
    
    
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
     *  @param rowIndex The zero-based index of the column that is being edited.
     * 
     *  @param columnIndex The zero-based index of the column that is being edited.
     * 
     *  @param column The column that is being edited.
     *   
     *  @see spark.components.supportClasses.GridColumn;
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function DataGridEditEvent(type:String, 
                                      bubbles:Boolean = false, 
                                      cancelable:Boolean = false,
                                      rowIndex:uint = -1,
                                      columnIndex:uint = -1, 
                                      column:GridColumn = null)
    {
        super(type, bubbles, cancelable);
        
        this.rowIndex = rowIndex;
        this.columnIndex = columnIndex;
        this.column = column;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  columnIndex
    //----------------------------------
    
    /** 
     *  The zero-based index of the column that is being edited.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */ 
    public var columnIndex:int;
    
    
    //----------------------------------
    //  column
    //----------------------------------
    
    /**
     *  The column of the cell that is being edited.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */
    public var column:GridColumn;
    
    //----------------------------------
    //  rowIndex
    //----------------------------------
    
    /**
     *  The index of the row that is being edited.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */
    public var rowIndex:int;
    
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
        var cloneEvent:DataGridEditEvent = new DataGridEditEvent(type, bubbles, cancelable, 
            rowIndex, columnIndex, column); 
        
        return cloneEvent;
    }
    
}
}