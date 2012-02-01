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
 *  The GridCaretEvent class represents events that are dispatched when 
 *  the caret changes in a Spark DataGrid control as the result of 
 *  user interaction.
 *
 *  @see spark.components.DataGrid
 *  @see spark.components.Grid
 *  @see spark.components.gridClasses.GridSelectionMode
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class GridCaretEvent extends Event
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  The <code>GridSelectionEvent.CARET_CHANGE</code> constant defines 
     *  the value of the <code>type</code> property of the event object for a 
     *  <code>caretChange</code> event, which indicates that the current 
     *  caret position has just been changed.
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
     *     <tr><td><code>newColumnIndex</code></td><td>The zero-based column 
     *       index of the caret position after it was changed.  It is -1 if
     *       the <code>selectionMode</code> is row-based.</td></tr>
     *     <tr><td><code>newRowIndex</code></td><td>The zero-based row index 
     *       of the caret position after it was changed.</td></tr>
     *     <tr><td><code>oldColumnIndex</code></td><td>The zero-based column 
     *       index of the caret position before it was changed.  It is -1 if
     *       the <code>selectionMode</code> is row-based.</td></tr>
     *     <tr><td><code>oldRowIndex</code></td><td>The zero-based row index 
     *       of the caret position before it was changed.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *     <tr><td><code>type</code></td><td>GirdCaretEvent.CARET_CHANGE</td></tr>
     *  </table>
     *   
     *  @eventType caretChange
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const CARET_CHANGE:String = "caretChange";
        
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
     *  @param oldColumnIndex The zero-based column index of the caret position
     *  before the change.  If the <code>selectionMode</code> is either 
     *  <code>SelectionMode.SINGLE_ROW</code> or 
     *  <code>SelectionMode.MULTIPLE_ROWS</code>, this is -1.
     * 
     *  @param oldRowIndex The zero-based row index of the caret position before 
     *  the change.
     * 
     *  @param newColumnIndex The zero-based column index of the caret position
     *  after the change.  If the <code>selectionMode</code> is either 
     *  <code>SelectionMode.SINGLE_ROW</code> or 
     *  <code>SelectionMode.MULTIPLE_ROWS</code>, this is -1.
     * 
     *  @param newRowIndex The zero-based row index of the caret position after 
     *  the change.
     * 
     *  @see spark.components.DataGrid#columns
     *  @see spark.components.DataGrid#dataProvider
     *  @spark.events.GridSelectionEventKind
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function GridCaretEvent(type:String, 
                                       bubbles:Boolean = false,
                                       cancelable:Boolean = false,
                                       oldRowIndex:int = -1,
                                       oldColumnIndex:int = -1,
                                       newRowIndex:int = -1,
                                       newColumnIndex:int = -1)
     {
        super(type, bubbles, cancelable);

        this.oldRowIndex = oldRowIndex;
        this.oldColumnIndex = oldColumnIndex;
        this.newRowIndex = newRowIndex;
        this.newColumnIndex = newColumnIndex;
    }

    //--------------------------------------------------------------------------
    //
    // Properties
    //
    //--------------------------------------------------------------------------
       
    
    //----------------------------------
    //  oldRowIndex
    //----------------------------------

    /**
     *  The zero-based index of the row of the
     *  caret position before it was changed.
     * 
     *  @default -1
     * 
     *  @see spark.components.DataGrid#dataProvider
     *  @see spark.components.Grid#dataProvider
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var oldRowIndex:int;
    
    //----------------------------------
    //  oldColumnIndex
    //----------------------------------
    
    /**
     *  The zero-based index of the column of the
     *  caret position before it was changed.      
     * 
     *  <p>If the <code>selectionMode</code> is <code>SelectionMode.SINGLE_ROW</code> or 
     *  <code>SelectionMode.MULTIPLE_ROWS</code>, this valueis -1 to indicate
     *  it is not being used.</p>
     *  
     *  @see spark.components.DataGrid#columns
     *  @see spark.components.Grid#columns
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var oldColumnIndex:int;
 
    //----------------------------------
    //  newRowIndex
    //----------------------------------
    
    /**
     *  The zero-based index of the row of the
     *  caret position after it was changed.
     * 
     *  @see spark.components.DataGrid#dataProvider
     *  @see spark.components.Grid#dataProvider
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var newRowIndex:int;
    
    //----------------------------------
    //  newColumnIndex
    //----------------------------------
    
    /**
     *  The zero-based index of the column of the
     *  caret position after it was changed.  
     * 
     *  <p>If the <code>selectionMode</code> is <code>SelectionMode.SINGLE_ROW</code> or 
     *  <code>SelectionMode.MULTIPLE_ROWS</code> this will be -1 to indicate
     *  it is not being used.</p>
     *  
     *  @see spark.components.DataGrid#columns
     *  @see spark.components.Grid#columns
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var newColumnIndex:int;    

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
            "GridCaretEvent", "type", 
            "bubbles", "cancelable", "eventPhase",
            "oldRowIndex","oldColumnIndex", 
            "newRowIndex", "newColumnIndex");
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
        return new GridCaretEvent(
            type, bubbles, cancelable, 
            oldRowIndex, oldColumnIndex, 
            newRowIndex, newColumnIndex);
    }
}

}
