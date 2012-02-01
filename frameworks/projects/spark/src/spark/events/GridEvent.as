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
import flash.events.MouseEvent;

import mx.core.IVisualElement;
import spark.components.supportClasses.GridColumn;


public class GridEvent extends MouseEvent
{
    include "../core/Version.as";    
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    public static const GRID_MOUSE_DOWN:String = "gridMouseDown";
    
    public static const GRID_MOUSE_DRAG:String = "gridMouseDrag";        
    
    public static const GRID_MOUSE_UP:String = "gridMouseUp";
    
    public static const GRID_ROLL_OVER:String = "gridRollOver";

    public static const GRID_ROLL_OUT:String = "gridRollOut";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    public function GridEvent(
        type:String,
        bubbles:Boolean = false,
        cancelable:Boolean = false,
        gridX:Number = NaN,
        gridY:Number = NaN,
        rowIndex:int = -1,
        columnIndex:int = -1,
        column:GridColumn = null,
        item:Object = null,
        itemRenderer:IVisualElement = null,
        ctrlKey:Boolean = false,
        altKey:Boolean = false,
        shiftKey:Boolean = false,
        buttonDown:Boolean = false,
        delta:int = 0)
    {
        super(type, bubbles, cancelable, gridX, gridY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
        
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
    
    public var rowIndex:int;
    
    //----------------------------------
    //  rowIndex
    //----------------------------------
    
    public var columnIndex:int;

    
    //----------------------------------
    //  column
    //----------------------------------
    
    public var column:GridColumn;

    
    //----------------------------------
    //  item
    //----------------------------------
    
    public var item:Object;
    
    //----------------------------------
    //  itemRenderer
    //----------------------------------
    
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
            ctrlKey, altKey, shiftKey, buttonDown, delta);
        
        cloneEvent.relatedObject = this.relatedObject;
        
        return cloneEvent;
    }
    
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
