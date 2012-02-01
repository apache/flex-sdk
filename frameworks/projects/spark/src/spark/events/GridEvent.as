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
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.MouseEvent;

import mx.core.IVisualElement;

import spark.components.supportClasses.GridColumn;

/**
 *  An extended mouse event that includes additional grid specific information based
 *  on the event's location relative to a grid cell: the row and column index, the 
 *  GridColumn object, the dataProvider item that corresponds to the row, and the 
 *  item renderer.  GridEvents are dispatched by the Grid class.
 * 
 *  <p>In general, GridEvents have a one to one correspondence with MouseEvents.  They are 
 *  dispatched in response to mouse events that have "bubbled" from some Grid descendant
 *  to the Grid itself.   One significant difference is that listeners are guaranteed to
 *  see an entire down-drag-up mouse gesture, even if the drag and up parts of the
 *  gesture do not occur over the grid.   The gridMouseDrag event corresponds to a 
 *  mouse move event with the button held down.</p> 
 * 
 *  @see spark.components.Grid
 */
public class GridEvent extends MouseEvent
{
    include "../core/Version.as";    
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  The value of the <code>type</code> property for a gridMouseDown GridEvent.
     *
     *  @eventType gridMouseDown
     * 
     *  @see flash.display.InteractiveObject.mouseDown
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */    
    public static const GRID_MOUSE_DOWN:String = "gridMouseDown";
    
    /**
     *  The value of the <code>type</code> property for a gridMouseDrag GridEvent.  This event is
     *  only dispatched when a listener has handled a mouseDown event, and then only while the
     *  mouse moves with the button held down.
     *
     *  @eventType gridMouseDrag
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */    
    public static const GRID_MOUSE_DRAG:String = "gridMouseDrag";        
    
    /**
     *  The value of the <code>type</code> property for a gridMouseUp GridEvent.
     *
     *  @eventType gridMouseUp
     * 
     *  @see flash.display.InteractiveObject.mouseUp
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */    
    public static const GRID_MOUSE_UP:String = "gridMouseUp";
    
    /**
     *  The value of the <code>type</code> property for a gridClick GridEvent.
     *
     *  @eventType gridClick
     * 
     *  @see flash.display.InteractiveObject.click
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */    
    public static const GRID_CLICK:String = "gridClick";
    
    /**
     *  The value of the <code>type</code> property for a gridDoubleClick GridEvent.
     *
     *  @eventType gridDoubleClick
     * 
     *  @see flash.display.InteractiveObject.doubleClick
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */    
    public static const GRID_DOUBLE_CLICK:String = "gridDoubleClick";     
    
    /**
     *  The value of the <code>type</code> property for a gridRollOver GridEvent.
     *
     *  @eventType gridRollOver
     * 
     *  @see flash.display.InteractiveObject.rollOver
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */    
    public static const GRID_ROLL_OVER:String = "gridRollOver";

    /**
     *  The value of the <code>type</code> property for a gridRollOut GridEvent.
     *
     *  @eventType gridRollOut
     * 
     *  @see flash.display.InteractiveObject.rollOut
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */    
    public static const GRID_ROLL_OUT:String = "gridRollOut";
    
    /**
     *  The value of the <code>type</code> property for a separatorMouseDrag GridEvent.
     *
     *  @eventType separatorMouseDrag
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */  
    public static const SEPARATOR_MOUSE_DRAG:String = "separatorMouseDrag";
    
    /**
     *  The value of the <code>type</code> property for a separatorClick GridEvent.
     *
     *  @eventType separatorClick
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */      
    public static const SEPARATOR_CLICK:String = "separatorClick";
    
    /**
     *  The value of the <code>type</code> property for a separatorDoubleClick GridEvent.
     *
     *  @eventType separatorDoubleClick
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */      
    public static const SEPARATOR_DOUBLE_CLICK:String = "separatorDoubleClick";    
    
    /**
     *  The value of the <code>type</code> property for a separatorMouseDown GridEvent.
     *
     *  @eventType separatorMouseDown
     * 
     *  @see flash.display.InteractiveObject.rollOut
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */  
    public static const SEPARATOR_MOUSE_DOWN:String = "separatorMouseDown";
    
    /**
     *  The value of the <code>type</code> property for a separatorMouseUp GridEvent.
     *
     *  @eventType separatorMouseUp
     * 
     *  @see flash.display.InteractiveObject.rollOut
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */      
    public static const SEPARATOR_MOUSE_UP:String = "separatorMouseUp";
    
    /**
     *  The value of the <code>type</code> property for a separatorRollOut GridEvent.
     *
     *  @eventType separatorRollOut
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */      
    public static const SEPARATOR_ROLL_OUT:String = "separatorRollOut";
    
    /**
     *  The value of the <code>type</code> property for a separatorRollOver GridEvent.
     *
     *  @eventType separatorRollOver
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */  
    public static const SEPARATOR_ROLL_OVER:String = "separatorRollOver";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    

    /**
     *  GridEvents dispatched by the Grid class in response to MouseEvents are constructed with
     *  the incoming mouse event's properties.   The grid event's x,y location, i.e. the value of
     *  its localX and localY properties, is defined relative to the entire grid, not just the 
     *  part of the grid that has been scrolled into view.   Similarly, the event's row and column
     *  indices may correspond to a cell that has not been scrolled into view.
     *
     *  @param type Distinguishes the mouse gesture that caused this event to be dispatched.
     *
     *  @param bubbles Specifies whether the event can bubble up the display list hierarchy.
     *
     *  @param cancelable Specifies whether the behavior associated with the event can be prevented.
     * 
     *  @param localX The event's x coordinate relative to grid.
     * 
     *  @param localY The event's y coordinate relative to grid.
     * 
     *  @param rowIndex The index of the row where the event occurred, or -1.
     * 
     *  @param columnIndex The index of the column where the event occurred, or -1.
     * 
     *  @param column The column where the event occurred or null.
     * 
     *  @param item The dataProvider item at rowIndex.
     * 
     *  @param relatedObject The relatedObject property of the MouseEvent that triggered this GridEvent.
     * 
     *  @param itemRenderer The visible item renderer where the event occurred or null.
     * 
     *  @param ctrlKey Whether the Control key is down.
     * 
     *  @param altKey Whether the Alt key is down.
     * 
     *  @param shiftKey Whether the Shift key is down.
     * 
     *  @param buttonDown Whether the Control key is down.
     * 
     *  @param delta Not used.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5 
     */
    public function GridEvent(
        type:String,
        bubbles:Boolean = false,
        cancelable:Boolean = false,
        localX:Number = NaN,
        localY:Number = NaN,
        rowIndex:int = -1,
        columnIndex:int = -1,
        column:GridColumn = null,
        item:Object = null,
        itemRenderer:IVisualElement = null,
        relatedObject:InteractiveObject = null,
        ctrlKey:Boolean = false,
        altKey:Boolean = false,
        shiftKey:Boolean = false,
        buttonDown:Boolean = false,
        delta:int = 0)
    {
        super(type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
   
        this.rowIndex = rowIndex;
        this.columnIndex = columnIndex;
        this.column = column;
        this.item = item;
        this.itemRenderer = itemRenderer;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  rowIndex
    //----------------------------------
    
    /**
     *  The index of the row where the event occurred, or -1 if the event
     *  did not occur over a grid row.
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
     *  The index of the column where the event occurred, or -1 if the event did not occur
     *  over a grid column.
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
     *  The column where the event occurred, or null if the event did not occur
     *  over a column.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */
    public var column:GridColumn;

    
    //----------------------------------
    //  item
    //----------------------------------
    
    /**
     *  The dataProvider item for this row, or null if the event did not occur over 
     *  a grid row.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */    
    public var item:Object;
    
    //----------------------------------
    //  itemRenderer
    //----------------------------------
    
    /**
     *  The itemRenderer that displayed this cell, or null if the event did not occur over
     *  a visible cell. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */       
    public var itemRenderer:IVisualElement;
    
    
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
        var cloneEvent:GridEvent = new GridEvent(type, bubbles, cancelable, 
            localX, localY, rowIndex, columnIndex, column, item, itemRenderer, 
            relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
        
        cloneEvent.relatedObject = this.relatedObject;
        
        return cloneEvent;
    }

    /**
     *  @private
     */
    override public function toString():String
    {
        return "GridEvent{" + 
            "type=\"" + type + "\"" +
            " localX,Y=" + localX + "," + localY + 
            " rowIndex,columnIndex=" + rowIndex + "," + columnIndex + 
            "}";
    }        
}
}
