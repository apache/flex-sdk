////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components
{ 
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.collections.IList;
import mx.core.IFactory;
import mx.core.mx_internal;
import mx.events.PropertyChangeEvent;
import mx.managers.IFocusManagerComponent;

import spark.components.gridClasses.GridColumn;
import spark.components.gridClasses.GridColumnHeaderGroupLayout;
import spark.components.gridClasses.IDataGridElement;
import spark.components.gridClasses.IGridItemRenderer;
import spark.events.GridEvent;
import spark.utils.MouseEventUtil;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the mouse button is pressed over a column header.
 *
 *  @eventType spark.events.GridEvent.GRID_MOUSE_DOWN
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="gridMouseDown", type="spark.events.GridEvent")]


/**
 *  Dispatched after a GRID_MOUSE_DOWN event if the mouse moves before the button is released.
 *
 *  @eventType spark.events.GridEvent.GRID_MOUSE_DRAG
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="gridMouseDrag", type="spark.events.GridEvent")]

/**
 *  Dispatched after a GRID_MOUSE_DOWN event when the mouse button is released, even
 *  if the mouse is no longer within the GridColumnHeaderGroup.
 *
 *  @eventType spark.events.GridEvent.GRID_MOUSE_UP
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="gridMouseUp", type="spark.events.GridEvent")]

/**
 *  Dispatched when the mouse enters a column header.
 *
 *  @eventType spark.events.GridEvent.GRID_ROLL_OVER
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="gridRollOver", type="spark.events.GridEvent")]

/**
 *  Dispatched when the mouse leaves a column header.
 *
 *  @eventType spark.events.GridEvent.GRID_ROLL_OUT
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="gridRollOut", type="spark.events.GridEvent")]

/**
 *  Dispatched when the mouse is clicked over a column header.
 *
 *  @eventType spark.events.GridEvent.GRID_CLICK
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="gridClick", type="spark.events.GridEvent")]

/**
 *  Dispatched when the mouse is double-clicked over a column header.
 *
 *  @eventType spark.events.GridEvent.GRID_DOUBLE_CLICK
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="gridDoubleClick", type="spark.events.GridEvent")]


/**
 *  Dispatched when the mouse button is pressed over a column header.
 *
 *  @eventType spark.events.GridEvent.GRID_MOUSE_DOWN
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="gridMouseDown", type="spark.events.GridEvent")]

/**
 *  Dispatched after a SEPARATOR_MOUSE_DOWN event if the mouse moves before 
 *  the button is released.
 *
 *  @eventType spark.events.GridEvent.SEPARATOR_MOUSE_DRAG
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="separatorMouseDrag", type="spark.events.GridEvent")]

/**
 *  Dispatched after a SEPARATOR_MOUSE_DOWN event when the mouse button is 
 *  released, even if the mouse is no longer within the separator affordance.
 *
 *  @eventType spark.events.GridEvent.SEPARATOR_MOUSE_UP
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="separatorMouseUp", type="spark.events.GridEvent")]

/**
 *  Dispatched when the mouse enters the area defined by a column 
 *  separator and <code>separatorMouseWidth</code>.
 *
 *  @eventType spark.events.GridEvent.SEPARATOR_ROLL_OVER
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="separatorRollOver", type="spark.events.GridEvent")]

/**
 *  Dispatched when the mouse leaves the area defined by a column 
 *  separator and <code>separatorMouseWidth</code>.
 *
 *  @eventType spark.events.GridEvent.SEPARATOR_ROLL_OUT
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="separatorRollOut", type="spark.events.GridEvent")]

/**
 *  Dispatched when the mouse is clicked over a column header separator.
 *
 *  @eventType spark.events.GridEvent.SEPARATOR_CLICK
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="separatorClick", type="spark.events.GridEvent")]

/**
 *  Dispatched when the mouse is double-clicked over a column 
 *  header separator.
 *
 *  @eventType spark.events.GridEvent.SEPARATOR_DOUBLE_CLICK
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="separatorDoubleClick", type="spark.events.GridEvent")]


//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  Horizontal space on either side of a column separator that's considered to be 
 *  part of the separator for the sake of mouse event dispatching.
 * 
 *  <p>Separators are often just one pixel wide which makes interacting with them difficult.
 *  This value is used by <code>getSeparatorIndexAt()</code> to give separators a wider
 *  berth, so that separator events are dispatched when the mouse is closer than 
 *  <code>separatorMouseWidth</code> to the horizontal midpoint of a separator.</p> 
 * 
 *  @default 5
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
*/
[Style(name="separatorAffordance", type="Number", format="Length", inherit="no")]

/**
 *  Bottom inset, in pixels, for all header renderers. 
 * 
 *  @default 0
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="paddingBottom", type="Number", format="Length", inherit="no")]

/**
 *  Left inset, in pixels, for the first header renderer. 
 * 
 *  @default 0
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="paddingLeft", type="Number", format="Length", inherit="no")]

/**
 *  Right inset, in pixels, for the last header renderer. 
 * 
 *  @default 0
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="paddingRight", type="Number", format="Length", inherit="no")]

/**
 *  Top inset, in pixels, for all header renderers. 
 * 
 *  @default 0
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="paddingTop", type="Number", format="Length", inherit="no")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("GridColumnHeaderGroup.png")]

/**
 *  Displays a row of column headers and separators aligned with the grid's layout.  
 * 
 *  <p>Headers are rendererd with the headerRenderer and separators with the columnSeparator.
 *  The layout, which can not be changed, is virtual: renderers and separators that have been 
 *  scrolled out of view are reused.</p>
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
public class GridColumnHeaderGroup extends Group implements IDataGridElement
{
    include "../core/Version.as";
    
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function GridColumnHeaderGroup()
    {
        super();
        
        layout = new GridColumnHeaderGroupLayout();
        layout.clipAndEnableScrolling = true;

        // Event handlers that dispatch GridEvents
        
        MouseEventUtil.addDownDragUpListeners(this, 
            chb_mouseDownDragUpHandler, 
            chb_mouseDownDragUpHandler, 
            chb_mouseDownDragUpHandler);

        addEventListener(MouseEvent.MOUSE_MOVE, chg_mouseMoveHandler);
        addEventListener(MouseEvent.ROLL_OUT, chg_mouseRollOutHandler);
        addEventListener(MouseEvent.CLICK, chg_clickHandler);
        addEventListener(MouseEvent.DOUBLE_CLICK, chg_doubleClickHandler);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties 
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private function dispatchChangeEvent(type:String):void
    {
        if (hasEventListener(type))
            dispatchEvent(new Event(type));
    }    
    
    //----------------------------------
    //  headerRenderer
    //----------------------------------    
    
    [Bindable("headerRendererChanged")]
    
    private var _headerRenderer:IFactory = null;
    
    /**
     *  The IGridItemRenderer class used to renderer each column header.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get headerRenderer():IFactory
    {
        return _headerRenderer;
    }
    
    /**
     *  @private
     */
    public function set headerRenderer(value:IFactory):void
    {
        if (value == _headerRenderer)
            return;
        
        
        _headerRenderer = value;
        
        layout.clearVirtualLayoutCache();
        invalidateSize();
        invalidateDisplayList();
        
        dispatchChangeEvent("headerRendererChanged");
    }
    
    //----------------------------------
    //  columnSeparator
    //----------------------------------
    
    [Bindable("columnSeparatorChanged")]
    
    private var _columnSeparator:IFactory = null;
    
    /**
     *  A visual element that's displayed in between each column.
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get columnSeparator():IFactory
    {
        return _columnSeparator;
    }
    
    /**
     *  @private
     */
    public function set columnSeparator(value:IFactory):void
    {
        if (_columnSeparator == value)
            return;
        
        _columnSeparator = value;
        invalidateDisplayList();
        dispatchChangeEvent("columnSeparatorChanged");
    }
    
    //----------------------------------
    //  dataGrid
    //----------------------------------
    
    [Bindable("dataGridChanged")]
    
    private var _dataGrid:DataGrid = null;
    
    /**
     *  The DataGrid that defines the column layout and horizontal scroll position for this component.
     *  This property is set by the DataGrid after its grid skin part has been added.
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get dataGrid():DataGrid
    {
        return _dataGrid;
    }
    
    /**
     *  @private
     */
    public function set dataGrid(value:DataGrid):void
    {
        if (_dataGrid == value)
            return;
        
        if (_dataGrid && _dataGrid.grid)
            _dataGrid.grid.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, grid_changeEventHandler);

        _dataGrid = value;

        if (_dataGrid && _dataGrid.grid)
            _dataGrid.grid.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, grid_changeEventHandler);
        
        layout.clearVirtualLayoutCache();
        invalidateSize();
        invalidateDisplayList();
        
        dispatchChangeEvent("dataGridChanged");
    }
    
    /**
     *  @private
     */
    private function grid_changeEventHandler(event:PropertyChangeEvent):void
    {
        if (event.property == "horizontalScrollPosition")
            horizontalScrollPosition = Number(event.newValue);
    }        
    
    //----------------------------------
    //  visibleSortIndicatorIndices
    //----------------------------------
    
    [Bindable("visibleSortIndicatorIndicesChanged")]
    
    private var _visibleSortIndicatorIndices:Vector.<int> = new Vector.<int>();
    
    /**
     *  A vector of column indices corresponding to the header renderers
     *  which currently have their sort indicators visible.
     * 
     *  @default An empty Vector.<int>
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get visibleSortIndicatorIndices():Vector.<int>
    {
        return _visibleSortIndicatorIndices.concat();
    }
    
    /**
     *  @private
     */
    public function set visibleSortIndicatorIndices(value:Vector.<int>):void
    {
        // Defensively copy vector and tolerate null
        const valueCopy:Vector.<int> = (value) ? value.concat() : new Vector.<int>();
        
        _visibleSortIndicatorIndices = valueCopy;
        
        invalidateDisplayList();
        dispatchChangeEvent("visibleSortIndicatorIndicesChanged");
    }
    
    /**
     *  Returns true if the sort indicator for the specified column
     *  is visible.
     *  
     *  This is just a more efficient version of:
     *      visibleSortIndicatorIndices.indexOf(columnIndex) != -1
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function isSortIndicatorVisible(columnIndex:int):Boolean
    {
        return (_visibleSortIndicatorIndices.indexOf(columnIndex) != -1);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods 
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @copy spark.components.gridClasses.GridColumnHeaderGroupLayout#getColumnIndexAt()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getHeaderIndexAt(x:Number, y:Number):int
    {
        return GridColumnHeaderGroupLayout(layout).getHeaderIndexAt(x, y);
    }
    
    /**
     *  @copy spark.components.gridClasses.GridColumnHeaderGroupLayout#getSeparatorIndexAt()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getSeparatorIndexAt(x:Number, y:Number):int
    {
        return GridColumnHeaderGroupLayout(layout).getSeparatorIndexAt(x, y);
    }    
        
    /**
     *  @copy spark.components.gridClasses.GridColumnHeaderGroupLayout#getHeaderRendererAt()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getHeaderRendererAt(columnIndex:int):IGridItemRenderer
    {
        return GridColumnHeaderGroupLayout(layout).getHeaderRendererAt(columnIndex);
    }
    
    /**
     *  @copy spark.components.gridClasses.GridColumnHeaderGroupLayout#getHeaderBounds()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getHeaderBounds(columnIndex:int):Rectangle
    {
        return GridColumnHeaderGroupLayout(layout).getHeaderBounds(columnIndex);
    }
    
    //--------------------------------------------------------------------------
    //
    //  GridEvent dispatching
    //
    //--------------------------------------------------------------------------  
    
    // The down,roll pairs of variables below define column indices.  Only one
    // member of each pair will be not equal to -1 at a time. 
    
    private var rollColumnIndex:int = -1;      // column mouse has rolled into
    private var rollSeparatorIndex:int = -1;   // separator mouse has rolled into
    private var downColumnIndex:int = -1;      // column button press occurred on
    private var downSeparatorIndex:int = -1;   // separator button press occurred on
    
    /**
     *  This method is called when a MOUSE_DOWN event occurs within the column header group and 
     *  for all subsequent MOUSE_MOVE events until the button is released (even if the 
     *  mouse leaves the column header group).  The last event in such a "down drag up" gesture is 
     *  always a MOUSE_UP.  By default this method dispatches GRID_MOUSE_DOWN, 
     *  GRID_MOUSE_DRAG, or a GRID_MOUSE_UP event in response to the the corresponding
     *  mouse event on a column header or SEPARATOR_MOUSE_DOWN, SEPARATOR_MOUSE_DRAG, 
     *  or a SEPARATOR_MOUSE_UP event in response to the the corresponding
     *  mouse event on a column header separator.
     * 
     *  The GridEvent's columnIndex, column itemRenderer properties correspond to the 
     *  column header or separator under the mouse.  
     * 
     *  @param event A MOUSE_DOWN, MOUSE_MOVE, or MOUSE_UP MouseEvent from a 
     *  down/move/up gesture initiated within the column header group.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */    
    protected function chb_mouseDownDragUpHandler(event:MouseEvent):void
    {
        const eventStageXY:Point = new Point(event.stageX, event.stageY);
        const eventHeaderGroupXY:Point = globalToLocal(eventStageXY);
        const eventSeparatorIndex:int = getSeparatorIndexAt(eventHeaderGroupXY.x, 0);
        const eventColumnIndex:int = 
            (eventSeparatorIndex == -1) ? getHeaderIndexAt(eventHeaderGroupXY.x, 0) : -1;
        
        var gridEventType:String;
        switch(event.type)
        {
            case MouseEvent.MOUSE_MOVE: 
                gridEventType = (downSeparatorIndex != -1) ? GridEvent.SEPARATOR_MOUSE_DRAG : GridEvent.GRID_MOUSE_DRAG; 
                break;

            case MouseEvent.MOUSE_UP:  
                gridEventType = (downSeparatorIndex != -1) ? GridEvent.SEPARATOR_MOUSE_UP : GridEvent.GRID_MOUSE_UP; 
                break;

            case MouseEvent.MOUSE_DOWN:
                if (eventSeparatorIndex != -1)
                {
                    gridEventType = GridEvent.SEPARATOR_MOUSE_DOWN;
                    downSeparatorIndex = eventSeparatorIndex;
                    downColumnIndex = -1;
                }
                else
                {
                    gridEventType = GridEvent.GRID_MOUSE_DOWN;
                    downSeparatorIndex = -1;
                    downColumnIndex = eventColumnIndex;
                }
                break;
        }
        
        const columnIndex:int = (eventSeparatorIndex != -1) ? eventSeparatorIndex : eventColumnIndex;
        dispatchGridEvent(event, gridEventType, eventHeaderGroupXY, columnIndex);
    }
    
    /**
     *  This method is called whenever a MOUSE_MOVE event occurs and the
     *  button is not pressed.   Despite the fact that the area considered to be
     *  occupied by the separators overlaps the headers (see <code>mouseSeparatorWidth</code>)
     *  the mouse is considered to be in either a header or a separator, but not both.
     * 
     *  This method dispatches a GRID_ROLL_OVER event when the mouse enters a header,
     *  a SEPARATOR_ROLL_OVER when the mouse enters a separator, and GRID_ROLL_OUT
     *  and SEPARATOR_ROLL_OUT when the mouse leaves a header or separator respectively.
     *  
     *  Listeners are guaranteed to receive a GRID_ROLL_OUT event for every 
     *  GRID_ROLL_OVER event and to receive a SEPARATOR_ROLL_OUT event for
     *  every SEPARATOR_ROLL_OVER event.
     * 
     *  @param event A MOUSE_MOVE MouseEvent within the column header group
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */    
    protected function chg_mouseMoveHandler(event:MouseEvent):void
    {
        const eventStageXY:Point = new Point(event.stageX, event.stageY);
        const eventHeaderGroupXY:Point = globalToLocal(eventStageXY);
        const eventSeparatorIndex:int = getSeparatorIndexAt(eventHeaderGroupXY.x, 0);
        const eventColumnIndex:int = 
            (eventSeparatorIndex == -1) ? getHeaderIndexAt(eventHeaderGroupXY.x, 0) : -1;
        
        if (eventSeparatorIndex != rollSeparatorIndex)
        {
            if (rollSeparatorIndex != -1)
                dispatchGridEvent(event, GridEvent.SEPARATOR_ROLL_OUT, eventHeaderGroupXY, rollSeparatorIndex);
            if (eventSeparatorIndex != -1)
                dispatchGridEvent(event, GridEvent.SEPARATOR_ROLL_OVER, eventHeaderGroupXY, eventSeparatorIndex);
        } 
        
        if (eventColumnIndex != rollColumnIndex)
        {
            if (rollColumnIndex != -1)
                dispatchGridEvent(event, GridEvent.GRID_ROLL_OUT, eventHeaderGroupXY, rollColumnIndex);
            if (eventColumnIndex != -1)
                dispatchGridEvent(event, GridEvent.GRID_ROLL_OVER, eventHeaderGroupXY, eventColumnIndex);
        } 
        
        rollColumnIndex = eventColumnIndex;
        rollSeparatorIndex = eventSeparatorIndex;
    }
    
    /**
     *  Called when the mouse moves out of the GridColumnHeaderGroup. 
     *  By default it dispatches either a GRID_ROLL_OUT or a
     *  SEPARATOR_ROLL_OUT event.
     * 
     *  @param event A ROLL_OUT MouseEvent from the column header group.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */       
    protected function chg_mouseRollOutHandler(event:MouseEvent):void
    {
        const eventStageXY:Point = new Point(event.stageX, event.stageY);
        const eventHeaderGroupXY:Point = globalToLocal(eventStageXY);
        
        if (rollSeparatorIndex != -1)
            dispatchGridEvent(event, GridEvent.SEPARATOR_ROLL_OUT, eventHeaderGroupXY, rollSeparatorIndex);
        else if (rollColumnIndex != -1)
            dispatchGridEvent(event, GridEvent.GRID_ROLL_OUT, eventHeaderGroupXY, rollColumnIndex);

        rollColumnIndex = -1;
        rollSeparatorIndex = -1;
    }
    
    /**
     *  This method is called whenever a CLICK MouseEvent occurs on the 
     *  column header group if both the corresponding down and up events occur 
     *  within the same column header cell. By default it dispatches a 
     *  GRID_CLICK event.
     * 
     *  @param event A CLICK MouseEvent from the column header group.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */       
    protected function chg_clickHandler(event:MouseEvent):void 
    {
        const eventStageXY:Point = new Point(event.stageX, event.stageY);
        const eventHeaderGroupXY:Point = globalToLocal(eventStageXY);
        const eventSeparatorIndex:int = getSeparatorIndexAt(eventHeaderGroupXY.x, 0);
        const eventColumnIndex:int = 
            (eventSeparatorIndex == -1) ? getHeaderIndexAt(eventHeaderGroupXY.x, 0) : -1;
        
        if ((eventSeparatorIndex != -1) && (downSeparatorIndex == eventSeparatorIndex))
            dispatchGridEvent(event, GridEvent.SEPARATOR_CLICK, eventHeaderGroupXY, eventSeparatorIndex);
        else if ((eventColumnIndex != -1) && (downColumnIndex == eventColumnIndex))
            dispatchGridEvent(event, GridEvent.GRID_CLICK, eventHeaderGroupXY, eventColumnIndex);
    }
    
    /**
     *  This method is called whenever a DOUBLE_CLICK MouseEvent occurs 
     *  if the corresponding sequence of down and up events occur within 
     *  the same column header cell.  It dispatches a GRID_DOUBLE_CLICK event.
     * 
     *  @param event A DOUBLE_CLICK MouseEvent from the column header group.
     * 
     *  @see flash.display.InteractiveObject#doubleClickEnabled    
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */       
    protected function chg_doubleClickHandler(event:MouseEvent):void 
    {
        const eventStageXY:Point = new Point(event.stageX, event.stageY);
        const eventHeaderGroupXY:Point = globalToLocal(eventStageXY);
        const eventSeparatorIndex:int = getSeparatorIndexAt(eventHeaderGroupXY.x, 0);
        const eventColumnIndex:int = 
            (eventSeparatorIndex == -1) ? getHeaderIndexAt(eventHeaderGroupXY.x, 0) : -1;
        
        if ((eventSeparatorIndex != -1) && (downSeparatorIndex == eventSeparatorIndex))
            dispatchGridEvent(event, GridEvent.SEPARATOR_DOUBLE_CLICK, eventHeaderGroupXY, eventSeparatorIndex);
        else if ((eventColumnIndex != -1) && (downColumnIndex == eventColumnIndex))
            dispatchGridEvent(event, GridEvent.GRID_DOUBLE_CLICK, eventHeaderGroupXY, eventColumnIndex);
    }    
    
    /**
     *  @private
     */
    private function dispatchGridEvent(mouseEvent:MouseEvent, type:String, headerGroupXY:Point, columnIndex:int):void
    {
        const column:GridColumn = getColumnAt(columnIndex);
        const item:Object = null;
        const itemRenderer:IGridItemRenderer = getHeaderRendererAt(columnIndex);
        const bubbles:Boolean = mouseEvent.bubbles;
        const cancelable:Boolean = mouseEvent.cancelable;
        const relatedObject:InteractiveObject = mouseEvent.relatedObject;
        const ctrlKey:Boolean = mouseEvent.ctrlKey;
        const altKey:Boolean = mouseEvent.altKey;
        const shiftKey:Boolean = mouseEvent.shiftKey;
        const buttonDown:Boolean = mouseEvent.buttonDown;
        const delta:int = mouseEvent.delta;        
        
        const event:GridEvent = new GridEvent(
            type, bubbles, cancelable, 
            headerGroupXY.x, headerGroupXY.y, -1, columnIndex, column, item, itemRenderer, 
            relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
        dispatchEvent(event);
    }     
    
    //--------------------------------------------------------------------------
    //
    //  Private methods, properties
    //
    //--------------------------------------------------------------------------
    
    private function getColumnAt(columnIndex:int):GridColumn
    {
        const grid:Grid = (dataGrid) ? dataGrid.grid : null;
        if (!grid || !grid.columns)
            return null;
        
        const columns:IList = grid.columns;
        return ((columnIndex >= 0) && (columnIndex < columns.length)) ? columns.getItemAt(columnIndex) as GridColumn : null;
    }
    
}    
}
