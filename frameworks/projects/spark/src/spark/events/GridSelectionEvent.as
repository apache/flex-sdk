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
import spark.components.gridClasses.CellRegion;

/**
 *  The GridSelectionEvent class represents events that are dispatched when 
 *  the selection changes in a Spark DataGrid control as the 
 *  result of user interaction.
 *
 *  @see spark.events.GridSelectionEventKind
 *  @see spark.components.DataGrid
 *  @see spark.components.Grid
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
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
     *  <code>selectionChange</code> event, which indicates that the current 
     *  selection has just been changed.
     *
     *  <p>This event is dispatched when the user interacts with the control.
     *  When you sort the data provider's collection programmatically, 
     *  the component does not dispatch the <code>selectionChange</code> event. </p>
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
     *     <tr><td>kind<code></code></td><td>The kind of changing event.
     *       The valid values are defined in GridSelectionEventKind 
     *       class as constants.  This value determines which properties in
     *       the event are used.</td></tr>
     *     <tr><td><code>selectionChange</code></td><td>The just completed selection
     *      change that was triggered by a user gesture. Use the DataGrid
     *      selection methods to determine the current selection.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *     <tr><td><code>type</code></td><td>GridSelectionEvent.SELECTION_CHANGE</td></tr>
     *  </table>
     *   
     *  @eventType selectionChange
     *  
     *  @see spark.components.DataGrid#selectedCells
     *  @see spark.components.DataGrid#selectedIndices
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
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
     *  <p>This event is dispatched when the user interacts with the control.
     *  When you sort the data provider's collection programmatically, 
     *  the component does not dispatch the <code>selectionChanging</code> event. </p>
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
     *     <tr><td>kind<code></code></td><td>The kind of changing event.
     *       The valid values are defined in GridSelectionEventKind 
     *       class as constants.  This value determines which properties in
     *       the event are used.</td></tr>
     *     <tr><td><code>selectionChange</code></td><td>The upcoming selection
     *      change that is triggered by a user gesture.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *     <tr><td><code>type</code></td><td>GridSelectionEvent.SELECTION_CHANGING</td></tr>
     *  </table>
     *   
     *  @eventType selectionChanging
     *  
     *  @see spark.components.DataGrid#selectedCells
     *  @see spark.components.DataGrid#selectedIndices
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
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
     *  @param selectionChange The proposed or accepted change to the 
     *  current selection.  Use the Spark DataGrid selection methods to 
     *  determine the current selection.
     *  
     *  @see spark.components.DataGrid#selectedCells
     *  @see spark.components.DataGrid#selectedIndices
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
                                       selectionChange:CellRegion = null)
     {
        super(type, bubbles, cancelable);

        this.kind = kind;       
        this.selectionChange = selectionChange;
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
     *  @see spark.events.GridSelectionEventKind
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var kind:String;
    
    
    //----------------------------------
    //  selectionChange
    //----------------------------------

    /**
     *  The upcoming or just-completed selection changes triggered by some 
     *  user gesture.  If this change is adding to the current selection, it 
     *  will not represent the complete selection.  Use the DataGrid
     *  selection methods to determine the selection.
     *
     *  @see spark.components.DataGrid
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var selectionChange:CellRegion;
    

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
            "selectionChange");
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
            type, bubbles, cancelable, kind, selectionChange);
    }
}

}
