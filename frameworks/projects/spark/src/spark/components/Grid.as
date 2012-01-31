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

package spark.components
{
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import mx.collections.IList;
import mx.core.IFactory;
import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.SandboxMouseEvent;
import mx.graphics.SolidColor;
import mx.utils.MatrixUtil;

import spark.components.Button;
import spark.components.Group;
import spark.components.supportClasses.GridColumn;
import spark.components.supportClasses.GridDimensions;
import spark.components.supportClasses.GridEvent;
import spark.components.supportClasses.GridLayout;
import spark.components.supportClasses.GridSelection;
import spark.components.supportClasses.GroupBase;
import spark.components.supportClasses.ItemRenderer;
import spark.primitives.Rect;

use namespace mx_internal;


public class Grid extends Group
{
    include "../core/Version.as";

    // TBD(hmuller): not clear where this belongs yet..
    public var gridSelection:GridSelection = new GridSelection();
    

    public var backgroundGroup:Group;
    public var selectionGroup:Group;    
    public var itemRendererGroup:Group;
    public var overlayGroup:Group;
    
    private var inUpdateDisplayList:Boolean = false;
    
    public function Grid()
    {
        super();
        layout = new GridLayout();

        backgroundGroup = new Group();
        backgroundGroup.layout = new NullLayout();
        addElement(backgroundGroup);
        
        selectionGroup = new Group();
        selectionGroup.layout = new NullLayout();
        addElement(selectionGroup);
        
        itemRendererGroup = this;  
        
        overlayGroup = new Group();
        overlayGroup.layout = new NullLayout();
        addElement(overlayGroup);        
        
        addDownDragUpHandler(this, grid_mouseDownDragUpHandler);
        addEventListener(MouseEvent.MOUSE_MOVE, grid_mouseMoveHandler);
        addEventListener(MouseEvent.ROLL_OUT, grid_mouseRollOutHandler);
        
        addEventListener(GridEvent.GRID_MOUSE_DOWN, gridMouseDownHandler);
        addEventListener(GridEvent.GRID_ROLL_OVER, gridRollOverHandler);
        addEventListener(GridEvent.GRID_ROLL_OUT, gridRollOutHandler);
    }
    
    private function get gridLayout():GridLayout
    {
        return layout as GridLayout;
    }
    
    private function get gridDimensions():GridDimensions
    {
        return gridLayout.gridDimensions;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  dataProvider
    //----------------------------------
    
    private var _dataProvider:IList = null;
    
    [Bindable("dataProviderChanged")]
    
    /**
     *  A list of <i>items</i> that correspond to the rows in the grid.   The grid's <i>columns</i>
     *  select different item properties to display in grid <i>cells</i>.
     * 
     *  @default null
     * 
     *  @see columns
     */
    public function get dataProvider():IList
    {
        return _dataProvider;
    }
    
    /**
     *  @private
     */
    public function set dataProvider(value:IList):void
    {
        if (_dataProvider == value)
            return;
        
        const oldDataProvider:IList = dataProvider;
        if (oldDataProvider)
            oldDataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, dataProvider_collectionChangeHandler);
        
        _dataProvider = value;
        
        // The listener is a local method, so creating a weak reference to it (last addEventListener 
        // parameter) is safe, since the listener's lifetime is the same as this object.
        
        const newDataProvider:IList = dataProvider;
        if (newDataProvider)
            newDataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, dataProvider_collectionChangeHandler, false, 0, true);        
        
        invalidateSize();
        invalidateDisplayList();
        
        //TBD: clear selection and dimnsions
        
        dispatchEvent(new Event("dataProviderChanged"));        
    }
    
    //----------------------------------
    //  columns
    //----------------------------------    
    
    private var _columns:IList = null; // list of GridColumns
    
    [Bindable("columnsChanged")]
    
    /**
     *  The list of GridColumns displayed by this grid.  Each column
     *  selects different dataProvider item properties to display in grid <i>cells</i>.
     *  
     *  @default null
     * 
     *  @see dataProvider
     */
    public function get columns():IList
    {
        return _columns;
    }
    
    /**
     *  @private
     */
    public function set columns(value:IList):void
    {
        if (_columns == value)
            return;
        
        // Remove the old column listener, and set each column's grid=null, columnIndex=-1.
        
        const oldColumns:IList = columns;
        if (oldColumns)
        {
            oldColumns.removeEventListener(CollectionEvent.COLLECTION_CHANGE, columns_collectionChangeHandler);
            for (var index:int = 0; index < oldColumns.length; index++)
            {
                var oldColumn:GridColumn = GridColumn(oldColumns.getItemAt(index));
                oldColumn.setGrid(null);
                oldColumn.setColumnIndex(-1);
            }
        }

        _columns = value; 
        
        // Add the new columns listener, and set their grid,columnIndex properties.
        // The listener is a local method, so creating a weak reference to it (last 
        // addEventListener parameter) is safe, since the listener's lifetime is the 
        // same as this object.        
        
        const newColumns:IList = columns;
        if (newColumns)
        {
            newColumns.addEventListener(CollectionEvent.COLLECTION_CHANGE, columns_collectionChangeHandler, false, 0, true);            
            for (index = 0; index < newColumns.length; index++)
            {
                var newColumn:GridColumn = GridColumn(newColumns.getItemAt(index));
                newColumn.setGrid(this);
                newColumn.setColumnIndex(index);
            }
        }
        
        invalidateSize();
        invalidateDisplayList();
        
        //TBD: clear selection and dimnsions        
        
        dispatchEvent(new Event("columnsChanged"));        
    }
    
    
    //----------------------------------
    //  hoverRowIndex
    //----------------------------------
    
    private var _hoverRowIndex:int = -1;
    
    public function get hoverRowIndex():int
    {
        return _hoverRowIndex;
    }
    
    public function set hoverRowIndex(value:int):void
    {
        if (value == _hoverRowIndex)
            return;
        
        _hoverRowIndex = value;
        if (hoverIndicator)
            invalidateDisplayList();
    }

    //----------------------------------
    //  hoverColumnIndex
    //----------------------------------
    
    public var hoverColumnIndex:int = -1;
    
    //----------------------------------
    //  caretRowIndex
    //----------------------------------
    
    private var _caretRowIndex:int = -1;
    
    public function get caretRowIndex():int
    {
        return _caretRowIndex;
    }
    
    public function set caretRowIndex(value:int):void
    {
        if (value == _caretRowIndex)
            return;
        
        _caretRowIndex = value;
        if (caretIndicator)
            invalidateDisplayList();
    }
    
    //----------------------------------
    //  caretColumnIndex
    //----------------------------------
    
    public var caretColumnIndex:int = -1;
    
    
    //----------------------------------
    //  caretIndicator
    //----------------------------------
    
    //[SkinPart(required="false", type="flash.display.DisplayObject")]
    
    public var caretIndicator:IFactory; 
    
    //----------------------------------
    //  hoverIndicator
    //----------------------------------
    
    //[SkinPart(required="false", type="flash.display.DisplayObject")]
    
    public var hoverIndicator:IFactory; 
    

    //----------------------------------
    //  selectionIndicator
    //----------------------------------
    
    //[SkinPart(required="false", type="flash.display.DisplayObject")]
    
    public var selectionIndicator:IFactory; 
    

    //----------------------------------
    //  columnSeparator
    //----------------------------------
    
    //[SkinPart(required="false", type="mx.core.IVisualElement")]
    
    public var columnSeparator:IFactory;
    
    //----------------------------------
    //  rowSeparator
    //----------------------------------
    
    //[SkinPart(required="false", type="mx.core.IVisualElement")]
    
    public var rowSeparator:IFactory;
    

    //----------------------------------
    //  rowBackground
    //----------------------------------
    
    //[SkinPart(required="false", type="mx.core.IVisualElement")]
    
    public var rowBackground:IFactory;
    
    
    //----------------------------------
    //  columnBackground
    //----------------------------------
    
    //[SkinPart(required="false", type="mx.core.IVisualElement")]
    
    public var columnBackground:IFactory;    
    
    //--------------------------------------------------------------------------
    //
    //  Method Overrides
    //
    //--------------------------------------------------------------------------    

    /**
     *  @private
     *  During virtual layout updateDisplayList() eagerly validates lazily
     *  created (or recycled) IRs.   We don't want changes to those IRs to
     *  invalidate the size of the Grid.
     */
    override public function invalidateSize():void
    {
        if (!inUpdateDisplayList)
            super.invalidateSize();
    }
    
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        inUpdateDisplayList = true;
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        inUpdateDisplayList = false;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Internal Grid Access
    //
    //--------------------------------------------------------------------------      
    
    private function getGridColumn(columnIndex:int):GridColumn
    {
        const columns:IList = columns;
        if ((columns == null) || (columnIndex >= columns.length))
            return null;
        
        return columns.getItemAt(columnIndex) as GridColumn;
    }
    
    private function getDataProviderItem(rowIndex:int):Object
    {
        const dataProvider:IList = dataProvider;
        if ((dataProvider == null) || (rowIndex >= dataProvider.length))
            return null;
        
        return dataProvider.getItemAt(rowIndex);
    }
    
    private function getVisibleItemRenderer(rowIndex:int, columnIndex:int):IVisualElement
    {
        const layout:GridLayout = layout as GridLayout;
        if (!layout)
            return null;
        
        return layout.getVisibleItemRenderer(rowIndex, columnIndex);
    }

    //--------------------------------------------------------------------------
    //
    //  GridEvents
    //
    //--------------------------------------------------------------------------  
    
    private var rollRowIndex:int = -1;
    private var rollColumnIndex:int = -1;
    
    protected function grid_mouseDownDragUpHandler(event:MouseEvent):void
    {
        const eventStageXY:Point = new Point(event.stageX, event.stageY);
        const eventGridXY:Point = globalToLocal(eventStageXY);
        const gridDimensions:GridDimensions = GridLayout(layout).gridDimensions;
        const eventRowIndex:int = gridDimensions.getRowIndexAt(eventGridXY.x, eventGridXY.y);
        const eventColIndex:int = gridDimensions.getColumnIndexAt(eventGridXY.x, eventGridXY.y);

        var gridEventType:String;
        switch(event.type)
        {
            case MouseEvent.MOUSE_MOVE: gridEventType = GridEvent.GRID_MOUSE_DRAG; break;
            case MouseEvent.MOUSE_DOWN: gridEventType = GridEvent.GRID_MOUSE_DOWN; break;
            case MouseEvent.MOUSE_UP:   gridEventType = GridEvent.GRID_MOUSE_UP; break;
        }
        
        dispatchGridEvent(event, gridEventType, eventGridXY, eventRowIndex, eventColIndex);        
    }
    
    protected function grid_mouseMoveHandler(event:MouseEvent):void
    {
        const eventStageXY:Point = new Point(event.stageX, event.stageY);
        const eventGridXY:Point = globalToLocal(eventStageXY);
        const gridDimensions:GridDimensions = GridLayout(layout).gridDimensions;
        const eventRowIndex:int = gridDimensions.getRowIndexAt(eventGridXY.x, eventGridXY.y);
        const eventColIndex:int = gridDimensions.getColumnIndexAt(eventGridXY.x, eventGridXY.y);
        
        if ((eventRowIndex != rollRowIndex) || (eventColIndex != rollColumnIndex))
        {
            if ((rollRowIndex != -1) || (rollColumnIndex != -1))
                dispatchGridEvent(event, GridEvent.GRID_ROLL_OUT, eventGridXY, rollRowIndex, rollColumnIndex);
            if ((eventRowIndex != -1) || (eventColIndex != -1))
                dispatchGridEvent(event, GridEvent.GRID_ROLL_OVER, eventGridXY, eventRowIndex, eventColIndex);
            rollRowIndex = eventRowIndex;
            rollColumnIndex = eventColIndex;
        }
    }
    
    protected function grid_mouseRollOutHandler(event:MouseEvent):void
    {
        if ((rollRowIndex != -1) || (rollColumnIndex != -1))
        {
            const eventStageXY:Point = new Point(event.stageX, event.stageY);
            const eventGridXY:Point = globalToLocal(eventStageXY);            
            dispatchGridEvent(event, GridEvent.GRID_ROLL_OUT, eventGridXY, rollRowIndex, rollColumnIndex);
            rollRowIndex = -1;
            rollColumnIndex = -1;
        }
    }
    
    /** 
     *  Return itemRenderer["excludedEventTargets"] contains event.target.id,
     *  where itemRenderer is the item renderer ancestor of event.target.
     */ 
    private function isEventTargetExcluded(event:Event):Boolean
    {
        const eventTarget:UIComponent = event.target as UIComponent;
        const eventTargetID:String = (eventTarget) ? eventTarget.id : null;
        if (!eventTargetID)
            return false;

        // Find the eventTarget's ancestor whose parent is the Grid.  That's the
        // item renderer.  If it has an excludedEventTargets array that contains
        // event.target.id, then this event is to be excluded.
        
        for (var elt:IVisualElement = eventTarget; elt && (elt != this); elt = elt.parent as IVisualElement)
            if (elt.parent == this)  // then elt is an item renderer
            {
                if ("excludedGridEventTargets" in Object(elt))
                {
                    const excludedTargets:Array = Object(elt)["excludedGridEventTargets"] as Array;
                    return excludedTargets.indexOf(eventTargetID) != -1;
                }
                return false;
            }
       
        return false;
    }
    
    private function dispatchGridEvent(mouseEvent:MouseEvent, type:String, gridXY:Point, rowIndex:int, columnIndex:int):void
    {
        if (isEventTargetExcluded(mouseEvent))
            return;
        
        const column:GridColumn = getGridColumn(columnIndex);
        const item:Object = getDataProviderItem(rowIndex);
        const itemRenderer:IVisualElement = getVisibleItemRenderer(rowIndex, columnIndex);
        const bubbles:Boolean = mouseEvent.bubbles;
        const cancelable:Boolean = mouseEvent.cancelable;
        const ctrlKey:Boolean = mouseEvent.ctrlKey;
        const altKey:Boolean = mouseEvent.altKey;
        const shiftKey:Boolean = mouseEvent.shiftKey;
        const buttonDown:Boolean = mouseEvent.buttonDown;
        const delta:int = mouseEvent.delta;        
        
        const event:GridEvent = new GridEvent(
            type, bubbles, cancelable, 
            gridXY.x, gridXY.y, rowIndex, columnIndex, column, item, itemRenderer, 
            ctrlKey, altKey, shiftKey, buttonDown, delta);
        dispatchEvent(event);
    }
    
    protected function gridRollOverHandler(event:GridEvent):void
    {
        hoverRowIndex = event.rowIndex;
        hoverColumnIndex = event.columnIndex;
    }
    
    protected function gridRollOutHandler(event:GridEvent):void
    {
        hoverRowIndex = -1;
        hoverColumnIndex = -1;
    }
    
    protected function gridMouseDownHandler(event:GridEvent):void
    {
        const rowIndex:int = event.rowIndex;
        const colIndex:int = event.columnIndex;
        
        if (event.ctrlKey)
        {
            if (gridSelection.containsRow(rowIndex))
                gridSelection.removeRow(rowIndex);
            else
                gridSelection.addRow(rowIndex);
            caretRowIndex = rowIndex;
            caretColumnIndex = colIndex;
        }
        else if (event.shiftKey && (caretRowIndex != -1) && (caretColumnIndex != -1))
        {
            const startRowIndex:int = Math.min(rowIndex, caretRowIndex);
            const endRowIndex:int = Math.max(rowIndex, caretRowIndex);
            const rowIndices:Vector.<int> = new Vector.<int>(1 + (endRowIndex - startRowIndex), true);
            for (var selectedRowIndex:int = startRowIndex; selectedRowIndex <= endRowIndex; selectedRowIndex++)
                rowIndices[selectedRowIndex - startRowIndex] = selectedRowIndex;
            gridSelection.setRows(rowIndices);
        }
        else
        {
            gridSelection.setRow(rowIndex);
            caretRowIndex = rowIndex;
            caretColumnIndex = colIndex;
        }

        invalidateDisplayList();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Down-Drag-Up Mouse Handling
    //
    //--------------------------------------------------------------------------   
    
    /**
     *  @private
     *  This listener is runs in the capture phase (before any other MouseEvent listeners)
     *  so that it can redispatch a cancelable=true copy of the event.
     */ 
    private static function redispatchMouseDownHandler(e:MouseEvent):void
    {
        if (e.cancelable)
            return;

        e.stopImmediatePropagation();
        const cancelableEvent:MouseEvent = 
            new MouseEvent(e.type, e.bubbles, true, e.localX, e.localY, e.relatedObject, 
                e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta);
        e.target.dispatchEvent(cancelableEvent);               
    }
    
    private static function addDownDragUpHandler(target:UIComponent, handler:Function):void
    {
        var f:Function = function(e:Event):void 
        {
            var sbr:IEventDispatcher;
            switch(e.type)
            {
                case MouseEvent.MOUSE_DOWN:
                    if (e.isDefaultPrevented())
                        break;
                    handler(e);
                    sbr = target.systemManager.getSandboxRoot();
                    sbr.addEventListener(MouseEvent.MOUSE_MOVE, f, true);
                    sbr.addEventListener(MouseEvent.MOUSE_UP, f, true );
                    sbr.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, f, true); 
                    break;
                case MouseEvent.MOUSE_MOVE:
                    handler(e);
                    break;
                case MouseEvent.MOUSE_UP:
                    handler(e);
                    sbr = target.systemManager.getSandboxRoot(); 
                    sbr.removeEventListener(MouseEvent.MOUSE_MOVE, f, true);
                    sbr.removeEventListener(MouseEvent.MOUSE_UP, f, true);
                    sbr.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, f, true); 
                    break;
                case "removeHandler":
                    target.removeEventListener("removeHandler", f);            
                    target.removeEventListener(MouseEvent.MOUSE_DOWN, f);
                    sbr = target.systemManager.getSandboxRoot();
                    sbr.removeEventListener(MouseEvent.MOUSE_MOVE, f, true);
                    sbr.removeEventListener(MouseEvent.MOUSE_UP, f, true);
                    sbr.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, f, true); 
                    break;
            }
        }
        target.addEventListener(MouseEvent.MOUSE_DOWN, f);
        target.addEventListener("removeHandler", f);
    }
    
    private static function removeDownDragUpHandler(target:UIComponent, handler:Function):void
    {
        target.dispatchEvent(new RemoveHandlerEvent(handler));
    }
    
    
    //--------------------------------------------------------------------------
    //
    //  IList listeners: columns, dataProvider
    //
    //--------------------------------------------------------------------------  
    
    /**
     *  @private
     */
    private function dataProvider_collectionChangeHandler(event:CollectionEvent):void
    {
        gridDimensions.dataProviderCollectionChanged(event);
        gridLayout.dataProviderCollectionChanged(event);
        gridSelection.dataProviderCollectionChanged(event);
        
        // TBD: hover and caretIndex
        
        invalidateSize();
        invalidateDisplayList();
    }
    

    
    /**
     *  @private
     */
    private function columns_collectionChangeHandler(event:CollectionEvent):void
    {
        // TBD
    }    
}
}

import spark.layouts.supportClasses.LayoutBase;

class RemoveHandlerEvent extends flash.events.Event
{
    public var handler:Function;
    public function RemoveHandlerEvent(handler:Function)
    {
        this.handler = handler;
        super("removeHandler");
    }
}

class NullLayout extends LayoutBase
{
    public function NullLayout()
    {
        super();
    }
}