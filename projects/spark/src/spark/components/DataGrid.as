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
import flash.events.Event;
import flash.events.EventPhase;
import flash.events.KeyboardEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.ui.Keyboard;

import mx.collections.IList;
import mx.core.IFactory;
import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.PropertyChangeEvent;
import mx.managers.IFocusManagerComponent;

import spark.components.supportClasses.CellPosition;
import spark.components.supportClasses.CellRegion;
import spark.components.supportClasses.GridDimensions;
import spark.components.supportClasses.GridLayout;
import spark.components.supportClasses.GridSelection;
import spark.components.supportClasses.GridSelectionMode;
import spark.components.supportClasses.SkinnableContainerBase;
import spark.core.NavigationUnit;
import spark.events.GridCaretEvent;
import spark.events.GridEvent;
import spark.events.GridSelectionEvent;
import spark.events.GridSelectionEventKind;

use namespace mx_internal;
    
//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched by the grid skin part when the mouse button is pressed over a Grid cell.
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
 *  Dispatched by the grid skin part after a GRID_MOUSE_DOWN event if the mouse moves before the button is released.
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
 *  Dispatched by the grid skin part after a GRID_MOUSE_DOWN event when the mouse button is released, even
 *  if the mouse is no longer within the Grid.
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
 *  Dispatched by the grid skin part when the mouse enters a grid cell.
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
 *  Dispatched by the grid skin part when the mouse leaves a grid cell.
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
 *  Dispatched by the grid skin part when the mouse is clicked over a cell
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
 *  Dispatched by the grid skin part when the mouse is double-clicked over a cell
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
 *  Dispatched when the selection has changed. 
 *  
 *  <p>This event is dispatched when the user interacts with the control.
 *  When you change the selection programmatically, 
 *  the component does not dispatch the <code>selectionChanging</code> event. 
 *  It dispatches the <code>valueCommit</code> event instead.</p>
 *
 *  @eventType spark.events.GridSelectionChangeEvent.SELECTION_CHANGING
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="selectionChanging", type="spark.events.GridSelectionEvent")]

/**
 *  Dispatched when the selection is going to change. 
 *  Calling the <code>preventDefault()</code> method
 *  on the event prevents the selection from changing.
 *  
 *  <p>This event is dispatched when the user interacts with the control.
 *  When you change the selection programmatically, 
 *  the component does not dispatch the <code>selectionChange</code> event. 
 *  It dispatches the <code>valueCommit</code> event instead.</p>
 *
 *  @eventType spark.events.GridSelectionChangeEvent.SELECTION_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="selectionChange", type="spark.events.GridSelectionEvent")]

/**
 *  Dispatched after the caret has changed.  
 *
 *  @eventType spark.events.GridCaretEvent.CARET_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="caretChange", type="spark.events.GridCaretEvent")]

[DefaultProperty("dataProvider")]
        
/**
 *  TBD
 */  
public class DataGrid extends SkinnableContainerBase implements IFocusManagerComponent, IGridItemRendererOwner
{
    include "../core/Version.as";
    
    public function DataGrid()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  columnHeaderBar
    //----------------------------------
    
    [SkinPart(required="false", type="spark.components.columnHeaderBar")]
    
    /**
     *  A reference to the ColumnHeaderBar that displays the column headers.
     */
    public var columnHeaderBar:ColumnHeaderBar;
    
    //----------------------------------
    //  grid
    //----------------------------------
    
    [SkinPart(required="false", type="spark.components.Grid")]
    [Bindable]
    
    /**
     *  A reference to the Grid that displays the dataProvider.
     */
    public var grid:spark.components.Grid;
    
    //----------------------------------
    //  scroller
    //----------------------------------
    
    [SkinPart(required="false", type="spark.components.Scroller")]
    
    /**
     *  A reference to the Scroller that scrolls the grid.
     */
    public var scroller:Scroller;  
    
    //--------------------------------------------------------------------------
    //
    //  Skin Part Property Internals
    //
    //-------------------------------------------------------------------------- 
    
    /**
     *  @private
     *  A list of functions to be applied to the grid skin part at partAdded() time.
     *  This list is used to defer making grid selection updates per the set methods for
     *  the selectedIndex, selectedIndices, selectedItem, selectedItems, selectedCell
     *  and selectedCells properties.
     */
    private const deferredGridOperations:Vector.<Function> = new Vector.<Function>();
    
    /**
     *  @private
     *  Defines one bit for each skin part property that's covered by DataGrid.  Currently
     *  there are only grid properties.
     */
    private static const partPropertyBits:Object = {
        columns: uint(1 << 0),
        dataProvider: uint(1 << 1),
        itemRenderer: uint(1 << 2),
        requestedRowCount: uint(1 << 3),
        requestedColumnCount: uint(1 << 4),
        requestedMinRowCount: uint(1 << 5),
        requestedMinColumnCount: uint(1 << 6),
        rowHeight: uint(1 << 7),
        typicalItem: uint(1 << 8),
        variableRowHeight: uint(1 << 9)
    };
    
    /**
     *  @private
     *  If the grid skin part hasn't been added, this var is an object whose properties
     *  temporarily record the values of DataGrid properties that just "cover" grid skin
     *  part properties. 
     * 
     *  If the grid skin part has been added (is non-null), then this var has 
     *  a single is a uint bitmask property called propertyBits that's used
     *  used to track which grid properties have been explicitly set.
     *  
     *  See getPartProperty(), setPartProperty().
     */
    private var gridProperties:Object = new Object();
    
    /**
     *  The default values of the grid skin part properties covered by DataGrid.
     */
    private static const gridPropertyDefaults:Object = {
        columns: null,
        dataProvider: null,
        itemRenderer: null,
        requestedRowCount: int(-1),
        requestedColumnCount: int(-1),
        requestedMinRowCount: int(-1),
        requestedMinColumnCount: int(-1),
        rowHeight: NaN,
        typicalItem: null,
        variableRowHeight: true            
    };
    
    /** 
     *  @private
     *  A utility method for looking up a skin part property that accounts for the possibility that
     *  the skin part is null.  It's intended to be used in the definition of properties that just
     *  "cover" skin part properties.
     * 
     *  If part is non-null, then return part[propertyName].  Otherwise return the value
     *  of properties[propertyName], or defaults[propertyName] if the specified property's 
     *  value is undefined.
     */
    private static function getPartProperty(part:Object, properties:Object, propertyName:String, defaults:Object):*
    {
        if (part)
            return part[propertyName];
        
        const value:* = properties[propertyName];
        return (value === undefined) ? defaults[propertyName] : value;
    }
    
    /** 
     *  @private
     *  A utility method for setting a skin part property that accounts for the possibility that
     *  the skin part is null.  It's intended to be used in the definition of properties that just
     *  "cover" skin part properties.
     * 
     *  Return true if the property's value was changed.
     * 
     *  If part is non-null, then set part[propertyName], otherwise set properties[propertyName].  
     * 
     *  If part is non-null then we set the bit for this property on the properties.propertyBits, to record
     *  the fact that the DataGrid cover property was explicitly set.
     * 
     *  In either case we treat setting a property to its default value specially: the effect
     *  is as if the property was never set at all.
     */
    private static function setPartProperty(part:Object, properties:Object, propertyName:String, value:*, defaults:Object):Boolean
    {
        if (getPartProperty(part, properties, propertyName, defaults) === value)
            return false;
        
        const defaultValue:* = defaults[propertyName];
        
        if (part)
        {
            part[propertyName] = value;
            if (value === defaultValue)
                properties.propertyBits &= ~partPropertyBits[propertyName];
            else
                properties.propertyBits |= partPropertyBits[propertyName];
        }
        else
        {
            if (value === defaultValue)
                delete properties[propertyName];
            else
                properties[propertyName] = value;
        }
        
        return true;
    }
    
    /**
     *  @private
     *  Return the specified grid property.
     */
    private function getGridProperty(propertyName:String):*
    {
        return getPartProperty(grid, gridProperties, propertyName, gridPropertyDefaults);
    }
    
    /**
     *  @private
     *  Set the specified grid property and return true if the property actually changed.
     */
    private function setGridProperty(propertyName:String, value:*):Boolean
    {
        return setPartProperty(grid, gridProperties, propertyName, value, gridPropertyDefaults);
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
    
    /**
     *  @private
     */
    private function dispatchFlexEvent(type:String):void
    {
        if (hasEventListener(type))
            dispatchEvent(new FlexEvent(type));
    }
    
    // TBD(hmuller): baselinePosition override
    // TBD(hmuller): methods to enable scrolling
    
    
    //----------------------------------
    //  columns (delgates to grid.columns)
    //----------------------------------
    
    [Bindable("columnsChanged")]
    
    /**
     *  @copy spark.components.Grid#columns
     * 
     *  @default null
     */
    public function get columns():IList
    {
        return getGridProperty("columns");
    }
    
    /**
     *  @private
     */
    public function set columns(value:IList):void
    {
        if (setGridProperty("columns", value))
        {
            if (columnHeaderBar)
                columnHeaderBar.dataProvider = columns;
            // TBD This, and  grid_columnsChangedEventHandler() should do their job at commitProperties time
            dispatchChangeEvent("columnsChanged");
        }
    }
    
    /**
     *  @private
     */
    private function getColumnsLength():uint
    {
        const columns:IList = columns;
        return (columns) ? columns.length : 0;
    }
    
    //----------------------------------
    //  dataProvider (delgates to grid.dataProvider)
    //----------------------------------
    
    [Bindable("dataProviderChanged")]
    
    /**
     *  @copy spark.components.Grid#dataProvider
     * 
     *  @default nulll
     */
    public function get dataProvider():IList
    {
        return getGridProperty("dataProvider");
    }
    
    /**
     *  @private
     */
    public function set dataProvider(value:IList):void
    {
        if (setGridProperty("dataProvider", value))
            dispatchChangeEvent("dataProviderChanged");
    }
    
    /**
     *  @private
     */
    private function getDataProviderLength():uint
    {
        const dataProvider:IList = dataProvider;
        return (dataProvider) ? dataProvider.length : 0;
    }
    
    //----------------------------------
    //  gridDimensions (private, read-only)
    //----------------------------------
    
    private var _gridDimensions:GridDimensions = null;
    
    /**
     *  @private
     */
    protected function get gridDimensions():GridDimensions
    {
        if (!_gridDimensions)
            _gridDimensions = new GridDimensions();  // TBD(hmuller):delegate to protected createGridDimensions()
        return _gridDimensions;
    }
    
    //----------------------------------
    //  gridSelection (private)
    //----------------------------------    
    
    private var _gridSelection:GridSelection = null;
    
    /**
     *  @private
     *  This object becomes the grid's gridSelection property after the grid skin part has been
     *  added.  It should only be referenced by this class when the grid skin part is null. 
     */
    protected function get gridSelection():GridSelection
    {
        if (!_gridSelection)
            _gridSelection = new GridSelection();  // TBD(hmuller):delegate to protected createGridSelection()
        return _gridSelection;
    }
    
    //----------------------------------
    //  itemRenderer delegates to (delegates to grid.itemRenderer)
    //----------------------------------    
    
    [Bindable("itemRendererChanged")]
    
    /**
     *  @copy spark.components.Grid#itemRenderer
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get itemRenderer():IFactory
    {
        return getGridProperty("itemRenderer");
    }
    
    /**
     *  @private
     */
    public function set itemRenderer(value:IFactory):void
    {
        if (setGridProperty("itemRenderer", value))
            dispatchChangeEvent("itemRendererChanged");
    }    
    
    //----------------------------------
    //  preserveSelection (delegates to grid.preserveSelection)
    //----------------------------------
    
    /**
     *  @copy spark.components.Grid#preserveSelection
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get preserveSelection():Boolean
    {
        if (grid)
            return grid.preserveSelection;
        else
            return gridSelection.preserveSelection;
    }
    
    /**
     *  @private
     */    
    public function set preserveSelection(value:Boolean):void
    {
        if (grid)
            grid.preserveSelection = value;
        else
            gridSelection.preserveSelection = value;
    }
    
    //----------------------------------
    //  requireSelection (delegates to grid.requireSelection)
    //----------------------------------
    
    /**
     *  @copy spark.components.Grid#requireSelection
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get requireSelection():Boolean
    {
        if (grid)
            return grid.requireSelection;
        else
            return gridSelection.requireSelection;
    }
    
    /**
     *  @private
     */    
    public function set requireSelection(value:Boolean):void
    {
        if (grid)
            grid.requireSelection = value;
        else
            gridSelection.requireSelection = value;
    }
    
    //----------------------------------
    //  requestedRowCount(delegates to grid.requestedRowCount)
    //----------------------------------
    
    /**
     *  @copy spark.components.Grid#requestedRowCount
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get requestedRowCount():int
    {
        return getGridProperty("requestedRowCount");
    }
    
    /**
     *  @private
     */    
    public function set requestedRowCount(value:int):void
    {
        setGridProperty("requestedRowCount", value);
    }
    
    //----------------------------------
    //  requestedColumnCount(delegates to grid.requestedColumnCount)
    //----------------------------------
    
    /**
     *  @copy spark.components.Grid#requestedColumnCount
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get requestedColumnCount():int
    {
        return getGridProperty("requestedColumnCount");
    }
    
    /**
     *  @private
     */    
    public function set requestedColumnCount(value:int):void
    {
        setGridProperty("requestedColumnCount", value);
    }
    
    //----------------------------------
    //  requestedMinRowCount(delegates to grid.requestedMinRowCount)
    //----------------------------------
    
    /**
     *  @copy spark.components.Grid#requestedMinRowCount
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get requestedMinRowCount():int
    {
        return getGridProperty("requestedMinRowCount");
    }
    
    /**
     *  @private
     */    
    public function set requestedMinRowCount(value:int):void
    {
        setGridProperty("requestedMinRowCount", value);
    }
    
    //----------------------------------
    //  requestedMinColumnCount(delegates to grid.requestedMinColumnCount)
    //----------------------------------
    
    /**
     *  @copy spark.components.Grid#requestedMinColumnCount
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get requestedMinColumnCount():int
    {
        return getGridProperty("requestedMinColumnCount");
    }
    
    /**
     *  @private
     */    
    public function set requestedMinColumnCount(value:int):void
    {
        setGridProperty("requestedMinColumnCount", value);
    }
    
    //----------------------------------
    //  rowHeight(delegates to grid.rowHeight)
    //----------------------------------
    
    [Bindable("rowHeightChanged")]
    
    /**
     *  @copy spark.components.Grid#rowHeight
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get rowHeight():Number
    {
        return getGridProperty("rowHeight");
    }
    
    /**
     *  @private
     */    
    public function set rowHeight(value:Number):void
    {
        if (setGridProperty("rowHeight", value))
            dispatchChangeEvent("rowHeightChanged");
    }    
    
    //----------------------------------
    //  selectionMode delegates to (delegates to grid.selectionMode)
    //----------------------------------    
    
    [Bindable("selectionModeChanged")]
    [Inspectable(category="General", enumeration="none,singleRow,multipleRows,singleCell,multipleCells", defaultValue="singleRow")]
    
    /**
     *  @copy spark.components.Grid#selectionMode
     *
     *  @see spark.components.supportClasses.GridSelectionMode
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get selectionMode():String
    {
        if (grid)
            return grid.selectionMode;
        else
            return gridSelection.selectionMode;
    }
    
    /**
     *  @private
     */
    public function set selectionMode(value:String):void
    {
        if (selectionMode == value)
            return;
        
        if (grid)
            grid.selectionMode = value;
        else
            gridSelection.selectionMode = value;
        
        dispatchChangeEvent("selectionModeChanged");
    }
    
    private function isRowSelectionMode():Boolean
    {
        const mode:String = selectionMode;
        return mode == GridSelectionMode.SINGLE_ROW || mode == GridSelectionMode.MULTIPLE_ROWS;
    }
    
    private function isCellSelectionMode():Boolean
    {
        const mode:String = selectionMode;        
        return mode == GridSelectionMode.SINGLE_CELL || mode == GridSelectionMode.MULTIPLE_CELLS;
    } 
    
    //----------------------------------
    //  typicalItem delegates to (delegates to grid.typicalItem)
    //----------------------------------    
    
    [Bindable("typicalItemChanged")]
    
    /**
     *  @copy spark.components.Grid#typicalItem
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get typicalItem():Object
    {
        return getGridProperty("typicalItem");
    }
    
    /**
     *  @private
     */
    public function set typicalItem(value:Object):void
    {
        if (setGridProperty("typicalItem", value))
            dispatchChangeEvent("typicalItemChanged");
    }
    
    //----------------------------------
    //  variableRowHeight(delegates to grid.variableRowHeight)
    //----------------------------------
    
    /**
     *  @copy spark.components.Grid#variableRowHeight
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get variableRowHeight():Boolean
    {
        return getGridProperty("variableRowHeight");
    }
    
    /**
     *  @private
     */    
    public function set variableRowHeight(value:Boolean):void
    {
        setGridProperty("variableRowHeight", value);
    }     
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Build in basic keyboard navigation support in Grid. The focus is on
     *  the DataGrid which means the Scroller doesn't see the Keyboard events
     *  unless the event is dispatched to it.
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {   
        // If the key is passed down to the Scroller it will come back here when
        // it bubbles back up.  It may or may not have default prevented.
        if (event.eventPhase != EventPhase.AT_TARGET)
            return;
        
        if (!grid || event.isDefaultPrevented())
            return;
        
        // Row selection requires valid row caret, cell selection
        // requires both a valid row and a valid column caret.

        if (selectionMode == GridSelectionMode.NONE || 
            grid.caretRowIndex < 0 || 
            grid.caretRowIndex >= getDataProviderLength() ||
            (isCellSelectionMode() && 
            (grid.caretColumnIndex < 0 || 
            grid.caretColumnIndex >= getColumnsLength())))
        {
            if (scroller)
                scroller.dispatchEvent(event);
            return;
        }
        
        var op:String;
        
        // Was the space bar hit? 
        if (event.keyCode == Keyboard.SPACE)
        {
            if (event.ctrlKey)
            {
                // Updates the selection.  The caret remains the same and the
                // anchor is updated.
                if (toggleSelection(grid.caretRowIndex, grid.caretColumnIndex))
                {
                    grid.anchorRowIndex = grid.caretRowIndex;
                    grid.anchorColumnIndex = grid.caretColumnIndex;
                    event.preventDefault();                
                }
            }
            else if (event.shiftKey)
            {
                // Extend the selection.  The caret remains the same.
                if (extendSelection(grid.caretRowIndex, grid.caretColumnIndex))
                    event.preventDefault();                
            }
            else
            {
                if (grid.caretRowIndex != -1)
                {
                    if (isRowSelectionMode())
                    {
                        op = selectionMode == GridSelectionMode.SINGLE_ROW ?
                            GridSelectionEventKind.SET_ROW :
                            GridSelectionEventKind.ADD_ROW;
                        
                        // Add the row and leave the caret position unchanged.
                        if (!commitInteractiveSelection(
                            op, grid.caretRowIndex, grid.caretColumnIndex))
                        {
                            return;
                        }
                        event.preventDefault();                
                    }
                    else if (isCellSelectionMode() && grid.caretColumnIndex != -1)
                    {
                            op = selectionMode == GridSelectionMode.SINGLE_CELL ?
                            GridSelectionEventKind.SET_CELL :
                            GridSelectionEventKind.ADD_CELL;

                        // Add the cell and leave the caret position unchanged.
                        if (!commitInteractiveSelection(
                            op, grid.caretRowIndex, grid.caretColumnIndex))
                        {
                            return;
                        }
                        event.preventDefault();                
                    }
                }
            }
            return;
        }
        else if (event.keyCode == Keyboard.A && event.ctrlKey)
        {            
            commitInteractiveSelection(
                GridSelectionEventKind.SELECT_ALL,
                0, 0, dataProvider.length, columns.length);
            
            grid.anchorRowIndex = 0;
            grid.anchorColumnIndex = 0;
            commitCaretPosition(-1, -1);
            return;
        }
        
        // Was some other navigation key hit?
        adjustSelectionUponNavigation(event);
    }
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == grid)
        {
            // Basic Initialization
            
            const layout:GridLayout = new GridLayout();
            grid.layout = layout;  // TBD(hmuller): delegate to protected createGridLayout()
            grid.gridDimensions = layout.gridDimensions = gridDimensions;
            gridSelection.grid = grid;
            grid.gridSelection = gridSelection;
            grid.gridOwner = this;
            
            // Cover Properties
            
            const modifiedGridProperties:Object = gridProperties;  // explicitly set properties
            gridProperties = {propertyBits:0};
            
            for (var propertyName:String in modifiedGridProperties)
            {
                if (propertyName == "propertyBits")
                    continue;
                setGridProperty(propertyName, modifiedGridProperties[propertyName]);
            }
            
            // Event Handlers
            
            grid.addEventListener(GridEvent.GRID_MOUSE_DOWN, gridMouseDownHandler);
            grid.addEventListener(GridEvent.GRID_ROLL_OVER, gridRollOverHandler);
            grid.addEventListener(GridEvent.GRID_ROLL_OUT, gridRollOutHandler);
            grid.addEventListener(GridCaretEvent.CARET_CHANGE, grid_caretChangeHandler);            
            grid.addEventListener(FlexEvent.VALUE_COMMIT, grid_valueCommitHandler);
            grid.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, grid_changeEventHandler);
            grid.addEventListener("columnsChanged", grid_columnsChangedEventHandler);
            
            // Deferred operations (grid selection updates)
            
            for each (var deferredGridOperation:Function in deferredGridOperations)
                deferredGridOperation(grid);
            deferredGridOperations.length = 0;
        }
        
        if (instance == columnHeaderBar)
        {
            columnHeaderBar.dataProvider = columns;
            columnHeaderBar.owner = this;
        }
    }
    
    /**
     * @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        
        if (instance == grid)
        {
            // Basic Initialization
            
            const layout:GridLayout = GridLayout(grid.layout);
            grid.gridDimensions = layout.gridDimensions = null;
            grid.layout = null;
            gridSelection.grid = null;
            grid.gridSelection = null;
            grid.gridOwner = null;            
            
            // Event Handlers
            
            grid.removeEventListener(GridEvent.GRID_MOUSE_DOWN, gridMouseDownHandler);
            grid.removeEventListener(GridEvent.GRID_ROLL_OVER, gridRollOverHandler);
            grid.removeEventListener(GridEvent.GRID_ROLL_OUT, gridRollOutHandler);            
            grid.removeEventListener(GridCaretEvent.CARET_CHANGE, grid_caretChangeHandler);            
            grid.removeEventListener(FlexEvent.VALUE_COMMIT, grid_valueCommitHandler);            
            grid.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, grid_changeEventHandler);            
            
            // Cover Properties
            
            const gridPropertyBits:uint = gridProperties.propertyBits;
            gridProperties = new Object();
            
            for (var propertyName:String in gridPropertyDefaults)
            {
                var propertyBit:uint = partPropertyBits[propertyName];
                if ((propertyBit & gridPropertyBits) == propertyBit)
                    gridProperties[propertyName] = getGridProperty(propertyName);                
            }
        }
        
        if (instance == columnHeaderBar)
        {
            columnHeaderBar.dataProvider = null;
            columnHeaderBar.horizontalScrollPosition = 0;
            columnHeaderBar.owner = null;
        }
    }
    
    //----------------------------------
    //  selectedCell
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]
    
    /**
     *  @copy spark.components.Grid#selectedCell
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectedCell():CellPosition
    {
        if (grid)
            return grid.selectedCell;
        
        return selectedCells.length ? selectedCells[0] : null;
    }
    
    /**
     *  @private
     */
    public function set selectedCell(value:CellPosition):void
    {
        if (grid)
            grid.selectedCell = value;
        else
        {
            const valueCopy:CellPosition = (value) ? new CellPosition(value.rowIndex, value.columnIndex) : null;

            var f:Function = function(g:Grid):void
            {
                g.selectedCell = valueCopy;
            }
            deferredGridOperations.push(f);
        }
    }    
    
    //----------------------------------
    //  selectedCells
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]
    
    /**
     *  @copy spark.components.Grid#selectedCells
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectedCells():Vector.<CellPosition>
    {
        return grid ? grid.selectedCells : gridSelection.allCells();
    }
    
    /**
     *  @private
     */
    public function set selectedCells(value:Vector.<CellPosition>):void
    {
        if (grid)
            grid.selectedCells = value;
        else
        {
            const valueCopy:Vector.<CellPosition> = (value) ? value.concat() : null;
            var f:Function = function(g:Grid):void
            {
                g.selectedCells = valueCopy;
            }
            deferredGridOperations.push(f);
        }
    }       
    
    //----------------------------------
    //  selectedIndex
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]
    
    /**
     *  @copy spark.components.Grid#selectedIndex
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectedIndex():int
    {
        if (grid)
            return grid.selectedIndex;
        
        return (selectedIndices.length > 0) ? selectedIndices[0] : -1;
    }
    
    /**
     *  @private
     */
    public function set selectedIndex(value:int):void
    {
        if (grid)
            grid.selectedIndex = value;
        else
        {
            var f:Function = function(g:Grid):void
            {
                g.selectedIndex = value;
            }
            deferredGridOperations.push(f);
        }
    }

    //----------------------------------
    //  selectedIndices
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]
    
    /**
     *  @copy spark.components.Grid#selectedIndices
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectedIndices():Vector.<int>
    {
        return grid ? grid.selectedIndices : gridSelection.allRows();
    }
    
    /**
     *  @private
     */
    public function set selectedIndices(value:Vector.<int>):void
    {
        if (grid)
            grid.selectedIndices = value;
        else
        {
            const valueCopy:Vector.<int> = (value) ? value.concat() : null;
            var f:Function = function(g:Grid):void
            {
                g.selectedIndices = valueCopy;
            }
            deferredGridOperations.push(f);
        }
    }    
    
    //----------------------------------
    //  selectedItem
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]
    
    /**
     *  @copy spark.components.Grid#selectedItem
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectedItem():Object
    {
        if (grid)
            return grid.selectedItem;
        
        return (dataProvider && (selectedIndex > 0)) ? 
            dataProvider.getItemAt(selectedIndex) : undefined;
    }
    
    /**
     *  @private
     */
    public function set selectedItem(value:Object):void
    {
        if (grid)
            grid.selectedItem = value;
        else
        {
            var f:Function = function(g:Grid):void
            {
                g.selectedItem = value;
            }
            deferredGridOperations.push(f);
        }
    }    
    
    //----------------------------------
    //  selectedItems
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]
    
    /**
     *  @copy spark.components.Grid#selectedItems
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectedItems():Vector.<Object>
    {
        if (grid)
            return grid.selectedItems;
        
        var items:Vector.<Object> = new Vector.<Object>();
        
        for (var i:int = 0; i < selectedIndices.length; i++)
            items.push(selectedIndices[i]);
        
        return items;
    }
    
    /**
     *  @private
     */
    public function set selectedItems(value:Vector.<Object>):void
    {
        if (grid)
            grid.selectedItems = value;
        else
        {
            const valueCopy:Vector.<Object> = value.concat();
            var f:Function = function(g:Grid):void
            {
                g.selectedItems = valueCopy;
            }
            deferredGridOperations.push(f);
        }
    }      
    
    //----------------------------------
    //  selectionLength
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]
    
    /**
     *  @copy spark.components.Grid#selectionLength
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectionLength():int
    {
        return grid ? grid.selectionLength : gridSelection.selectionLength;
    }    
    
    //--------------------------------------------------------------------------
    //
    //  Public Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @copy spark.components.Grid#selectAll()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectAll():Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.selectAll();
        }
        else
        {
            selectionChanged = gridSelection.selectAll();
            if (selectionChanged)
            {
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
        }
        
        return selectionChanged;
    }
    
    /**
     *  @copy spark.components.Grid#clearSelection()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function clearSelection():Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.clearSelection();
        }
        else
        {
            selectionChanged = gridSelection.removeAll();
            if (selectionChanged)
            {
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
        }
        
        return selectionChanged;
    }
    
    
    //----------------------------------
    //  selection for rows
    //----------------------------------    
    
    /**
     *  @copy spark.components.Grid#selectionContainsIndex
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectionContainsIndex(rowIndex:int):Boolean 
    {
        if (grid)
            return grid.selectionContainsIndex(rowIndex);
        else
            return gridSelection.containsRow(rowIndex);         
    }
    
    /**
     *  @copy spark.components.Grid#selectionContainsIndices
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectionContainsIndices(rowIndices:Vector.<int>):Boolean 
    {
        if (grid)
            return grid.selectionContainsIndices(rowIndices);
        else
            return gridSelection.containsRows(rowIndices);
    }
    
    /**
     *  @copy spark.components.Grid#setSelectedIndex
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function setSelectedIndex(rowIndex:int):Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.setSelectedIndex(rowIndex);
        }
        else
        {
            selectionChanged = gridSelection.setRow(rowIndex);
            if (selectionChanged)
            {
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
        }
        
        return selectionChanged;
    }
    
    /**
     *  @copy spark.components.Grid#addSelectedIndex
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function addSelectedIndex(rowIndex:int):Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.addSelectedIndex(rowIndex);
        }
        else
        {
            selectionChanged = gridSelection.addRow(rowIndex);
            if (selectionChanged)
            {
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
        }
        
        return selectionChanged;
    }
    
    /**
     *  @copy spark.components.Grid#removeSelectedIndex
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function removeSelectedIndex(rowIndex:int):Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.removeSelectedIndex(rowIndex);
        }
        else
        {
            selectionChanged = gridSelection.removeRow(rowIndex);
            if (selectionChanged)
            {
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
        }
        
        return selectionChanged;
    }
    
    /**
     *  @copy spark.components.Grid#setSelectedIndices
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectIndices(rowIndex:int, rowCount:int):Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.selectIndices(rowIndex, rowCount);
        }
        else
        {
            selectionChanged = gridSelection.setRows(rowIndex, rowCount);
            if (selectionChanged)
            {
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
        }
        
        return selectionChanged;
    }
    
    //----------------------------------
    //  selection for cells
    //----------------------------------    
    
    /**
     *  @copy spark.components.Grid#selectionContainsCell
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectionContainsCell(rowIndex:int, columnIndex:int):Boolean
    {
        if (grid)
            return grid.selectionContainsCell(rowIndex, columnIndex);
        else
            return gridSelection.containsCell(rowIndex, columnIndex);
    }
    
    /**
     *  @copy spark.components.Grid#selectionContainsCellRegion
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectionContainsCellRegion(rowIndex:int, columnIndex:int, 
                                                rowCount:int, columnCount:int):Boolean
    {
        if (grid)
        {
            return grid.selectionContainsCellRegion(
                rowIndex, columnIndex, rowCount, columnCount);
        }
        else
        {
            return gridSelection.containsCellRegion(
                rowIndex, columnIndex, rowCount, columnCount);
        }
    }
    
    /**
     *  @copy spark.components.Grid#setSelectedCell
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function setSelectedCell(rowIndex:int, columnIndex:int):Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.setSelectedCell(rowIndex, columnIndex);
        }
        else
        {
            selectionChanged = gridSelection.setCell(rowIndex, columnIndex);
            if (selectionChanged)
            {
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
        }
        
        return selectionChanged;
    }
    
    /**
     *  @copy spark.components.Grid#addSelectedCell
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function addSelectedCell(rowIndex:int, columnIndex:int):Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.addSelectedCell(rowIndex, columnIndex);
        }
        else
        {
            selectionChanged = gridSelection.addCell(rowIndex, columnIndex);
            if (selectionChanged)
            {
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
        }
        
        return selectionChanged;
    }
    
    /**
     *  @copy spark.components.Grid#removeSelectedCell
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function removeSelectedCell(rowIndex:int, columnIndex:int):Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.removeSelectedCell(rowIndex, columnIndex);
        }
        else
        {
            selectionChanged = gridSelection.removeCell(rowIndex, columnIndex);
            if (selectionChanged)
            {
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
        }
        
        return selectionChanged;
    }
    
    /**
     *  @copy spark.components.Grid#selectCellRegion
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectCellRegion(rowIndex:int, columnIndex:int, 
                                     rowCount:uint, columnCount:uint):Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.selectCellRegion(
                rowIndex, columnIndex, rowCount, columnCount);
        }
        else
        {
            selectionChanged = gridSelection.setCellRegion(
                rowIndex, columnIndex, rowCount, columnCount);
            if (selectionChanged)
            {
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
        }
        
        return selectionChanged;
    }    
    
    /**
     *  In response to user input (mouse or keyboard) which changes the 
     *  selection, this dispatches the "selectionChanging" event, and if the 
     *  event is not cancelled, commits the selection change and then 
     *  dispatches the "selectionChange" event.  The caret is not udpated here.  
     *  To detect if the caret has changed use the "caretChanged" event.
     * 
     *  @param selectionEventKind The <code>GridSelectionEventKind</code> of
     *  selection that is being committed.  If not null, this will be used to 
     *  generate the <code>selectionChanging</code> event.
     * 
     *  @param rowIndex If <code>selectionEventKind</code> is for a row or a
     *  cell, the 0-based rowIndex of the selection in the 
     *  <code>dataProvider</code>. If <code>selectionEventKind</code> is 
     *  for multiple cells, the 0-based rowIndex of the origin of the
     *  cell region. The default is -1 to indicate this
     *  parameter is not being used.
     * 
     *  @param columnIndex If <code>selectionEventKind</code> is for a single row or 
     *  a single cell, the 0-based columnIndex of the selection in 
     *  <code>columns</code>. If <code>selectionEventKind</code> is for multiple 
     *  cells, the 0-based columnIndex of the origin of the
     *  cell region. The default is -1 to indicate this
     *  parameter is not being used.
     * 
     *  @param rowCount If <code>selectionEventKind</code> is for a cell region, 
     *  the number of rows in the cell region.  The default is -1 to indicate
     *  this parameter is not being used.
     * 
     *  @param columnCount If <code>selectionEventKind</code> is for a cell region, 
     *  the number  of columns in the cell region.  The default is -1 to 
     *  indicate this parameter is not being used.
     * 
     *  @param indices If <code>selectionEventKind</code> is for multiple rows,
     *  the 0-based row indicies of the rows in the selection.  The default is 
     *  null to indicate this parameter is not being used.
     * 
     *  @return True if the selection was committed, or false if the selection
     *  was cancelled or could not be committed due to an error, such as
     *  index out of range or the <code>selectionEventKind</code> is not compatible 
     *  s the <code>selectionMode</code>.
     * 
     *  @see spark.events.GridSelectionEvent#SELECTION_CHANGE
     *  @see spark.events.GridSelectionEvent#SELECTION_CHANGING
     *  @see spark.events.GridSelectionEventKind
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    protected function commitInteractiveSelection(
        selectionEventKind:String,                                         
        rowIndex:int,
        columnIndex:int, 
        rowCount:int = 1, 
        columnCount:int = 1):Boolean
        
    {
        if (!grid)
            return false;
        
        // Assumes selectionEventKind is valid for given selectionMode.  Assumes
        // indices are within range.
        
        var selectionChange:CellRegion = 
            new CellRegion(rowIndex, columnIndex, rowCount, columnCount);
        
        // Step 1: determine if the selection will change if the operation.
        // is committed.  
        if (!doesChangeCurrentSelection(selectionEventKind, selectionChange))
            return false;
        
        // Step 1: dispatch the "changing" event. If preventDefault() is called
        // on this event, the selection change will be cancelled.        
        if (hasEventListener(GridSelectionEvent.SELECTION_CHANGING))
        {
            const changingEvent:GridSelectionEvent = 
                new GridSelectionEvent(GridSelectionEvent.SELECTION_CHANGING, 
                    false, true, 
                    selectionEventKind, selectionChange); 
            
            // The event was cancelled so don't change the selection.
            if (!dispatchEvent(changingEvent))
                return false;
        }
        
        // Step 2: commit the selection change.  Call the gridSelection
        // methods directly so that the caret position is not altered and 
        // a VALUE_COMMIT event is not dispatched.
        
        var changed:Boolean;
        switch (selectionEventKind)
        {
            case GridSelectionEventKind.SET_ROW:
            {
                changed = grid.gridSelection.setRow(rowIndex);
                break;
            }
            case GridSelectionEventKind.ADD_ROW:
            {
                changed = grid.gridSelection.addRow(rowIndex);
                break;
            }
                
            case GridSelectionEventKind.REMOVE_ROW:
            {
                changed = grid.gridSelection.removeRow(rowIndex);
                break;
            }
                
            case GridSelectionEventKind.SET_ROWS:
            {
                changed = grid.gridSelection.setRows(rowIndex, rowCount);
                break;
            }
                
            case GridSelectionEventKind.SET_CELL:
            {
                changed = grid.gridSelection.setCell(rowIndex, columnIndex);
                break;
            }
                
            case GridSelectionEventKind.ADD_CELL:
            {
                changed = grid.gridSelection.addCell(rowIndex, columnIndex);
                break;
            }
                
            case GridSelectionEventKind.REMOVE_CELL:
            {
                changed = grid.gridSelection.removeCell(rowIndex, columnIndex);
                break;
            }
                
            case GridSelectionEventKind.SET_CELL_REGION:
            {
                changed = grid.gridSelection.setCellRegion(
                    rowIndex, columnIndex, 
                    rowCount, columnCount);
                break;
            }
                
            case GridSelectionEventKind.SELECT_ALL:
            {
                changed = grid.gridSelection.selectAll();
                break;
            }
        }
        
        // Selection change failed for some unforseen reason.
        if (!changed)
            return false;
        
        grid.invalidateDisplayList();
        
        // Step 3: dispatch the "change" event.
        if (hasEventListener(GridSelectionEvent.SELECTION_CHANGE))
        {
            const changeEvent:GridSelectionEvent = 
                new GridSelectionEvent(GridSelectionEvent.SELECTION_CHANGE, 
                    false, true, 
                    selectionEventKind, selectionChange); 
            dispatchEvent(changeEvent);
            // FIXME - to trigger bindings on grid selectedCell/Index/Item properties
            if (grid.hasEventListener(GridSelectionEvent.SELECTION_CHANGE))
                grid.dispatchEvent(changeEvent);
        }
        
        return true;
    }
    
    /**
     *  Updates the grid's caret position.  If the caret position changes
     *  a GridCaretEvent.CARET_CHANGE event will be dispatched by grid.
     *
     *  @param newCaretRowIndex The 0-based rowIndex of the new caret position.
     * 
     *  @param newCaretColumnIndex The 0-based columnIndex of the new caret 
     *  position.  If the selectionMode is row-based, this is -1.
     * 
     *  @see spark.events.GridCaretEvent#CARET_CHANGE
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    protected function commitCaretPosition(newCaretRowIndex:int, 
                                           newCaretColumnIndex:int):void
    {
        grid.caretRowIndex = newCaretRowIndex;
        grid.caretColumnIndex = newCaretColumnIndex;
    }
    
    //--------------------------------------------------------------------------
    //
    //  IGridItemRendererOwner Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    public function prepareItemRenderer(renderer:IVisualElement, recycle:Boolean):void
    {            
        // Set the owner
        if (renderer is IItemRenderer)
        {
            IItemRenderer(renderer).owner = this;
        }
    }
    
    /**
     *  @private
     */
    public function discardItemRenderer(renderer:IVisualElement, recycle:Boolean):void
    {
        // TODO (jszeto)
    }
    
    //--------------------------------------------------------------------------
    //
    //  Selection Utility Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    protected function selectionContainsOnlyIndex(index:int):Boolean 
    {
        if (grid)
            return grid.selectionContainsIndex(index) && grid.selectionLength == 1;
        else
            return gridSelection.containsRow(index) && gridSelection.selectionLength == 1;
    }
    
    /**
     *  @private
     */
    protected function selectionContainsOnlyIndices(indices:Vector.<int>):Boolean 
    {
        const selectedRows:Vector.<int> = 
            grid ? grid.selectedIndices : gridSelection.allRows();
        
        // This assumes no duplicate rows.
        if (selectedRows.length != indices.length)
            return false;
        
        for each (var rowIndex:int in indices)
        {
            const offset:int = selectedRows.indexOf(rowIndex);
            if (offset == -1)
                return false;
            else
                selectedRows.splice(offset, 1);
        }
        
        return selectedRows.length == 0;        
    }
    
    /**
     *  @private
     */
    protected function selectionContainsOnlyIndicesCR(cellRegion:CellRegion):Boolean 
    {
        const selectedRows:Vector.<int> = 
            grid ? grid.selectedIndices : gridSelection.allRows();
        
        // This assumes no duplicate rows.
        if (selectedRows.length != cellRegion.rowCount)
            return false;
        
        for (var rowIndex:int = cellRegion.rowIndex; 
            rowIndex < cellRegion.rowIndex + cellRegion.rowCount; rowIndex++)
        {
            const offset:int = selectedRows.indexOf(rowIndex);
            if (offset == -1)
                return false;
            else
                selectedRows.splice(offset, 1);
        }
        
        return selectedRows.length == 0;        
    }
    
    /**
     *  @private
     */
    private function selectionContainsOnlyCell(rowIndex:int, columnIndex:int):Boolean
    {
        if (grid)
            return grid.selectionContainsCell(rowIndex, columnIndex) && grid.selectionLength == 1;
        else
            return gridSelection.containsCell(rowIndex, columnIndex) && gridSelection.selectionLength == 1;
    }
    
    /**
     *  @private
     */
    private function selectionContainsOnlyCellRegion(rowIndex:int, 
                                                     columnIndex:int, 
                                                     rowCount:int, 
                                                     columnCount:int):Boolean
    {
        if (grid)
        {
            return grid.selectionContainsCellRegion(
                rowIndex, columnIndex, rowCount, columnCount) &&
                grid.selectionLength == rowCount * columnCount;
        }
        else
        {
            return gridSelection.containsCellRegion(
                rowIndex, columnIndex, rowCount, columnCount) &&
                gridSelection.selectionLength == rowCount * columnCount;
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @return True if there is an anchor position set.
     */    
    private function isAnchorSet():Boolean
    {
        if (!grid)
            return false;
        
        if (isRowSelectionMode())
            return grid.anchorRowIndex != -1;
        else
            return grid.anchorRowIndex != -1 && grid.anchorRowIndex != -1;
    }
    
    /**
     *  @private
     *  Toggle the selection and set the caret to rowIndex/columnIndex.
     * 
     *  @return True if the selection has changed.
     */
    private function toggleSelection(rowIndex:int, columnIndex:int):Boolean
    {
        var kind:String;
        
        if (isRowSelectionMode())
        { 
            if (grid.selectionContainsIndex(rowIndex))
                kind = GridSelectionEventKind.REMOVE_ROW;
            else if (selectionMode == GridSelectionMode.MULTIPLE_ROWS)
                kind = GridSelectionEventKind.ADD_ROW;
            else
                kind = GridSelectionEventKind.SET_ROW;
            
        }
        else if (isCellSelectionMode())
        {
            if (grid.selectionContainsCell(rowIndex, columnIndex))
                kind = GridSelectionEventKind.REMOVE_CELL;
            else if (selectionMode == GridSelectionMode.MULTIPLE_CELLS)
                kind = GridSelectionEventKind.ADD_CELL;
            else
                kind = GridSelectionEventKind.SET_CELL;
        }
        
        var changed:Boolean = 
            commitInteractiveSelection(kind, rowIndex, columnIndex);
        
        // Update the caret even if the selection did not change.
        commitCaretPosition(rowIndex, columnIndex);
        
        return changed;
    }
    
    /**
     *  @private
     *  Extends the selection from the anchor position to the given 'caret'
     *  position and updates the caret position.
     */
    private function extendSelection(caretRowIndex:int, 
                                     caretColumnIndex:int):Boolean
    {
        if (!isAnchorSet())
            return false;
        
        const startRowIndex:int = Math.min(grid.anchorRowIndex, caretRowIndex);
        const endRowIndex:int = Math.max(grid.anchorRowIndex, caretRowIndex);
        var changed:Boolean;
        
        if (selectionMode == GridSelectionMode.MULTIPLE_ROWS)
        {
            changed = commitInteractiveSelection(
                GridSelectionEventKind.SET_ROWS,
                startRowIndex, -1,
                endRowIndex - startRowIndex + 1, 0);
        }
        else if (selectionMode == GridSelectionMode.MULTIPLE_CELLS)
        {
            const rowCount:int = endRowIndex - startRowIndex + 1;
            const startColumnIndex:int = 
                Math.min(grid.anchorColumnIndex, caretColumnIndex);
            const endColumnIndex:int = 
                Math.max(grid.anchorColumnIndex, caretColumnIndex); 
            const columnCount:int = endColumnIndex - startColumnIndex + 1;
            
            changed = commitInteractiveSelection(
                GridSelectionEventKind.SET_CELL_REGION, 
                startRowIndex, startColumnIndex,
                rowCount, columnCount);
        }            
        
        // Update the caret.
        commitCaretPosition(caretRowIndex, caretColumnIndex);
        
        return changed;
    }
    
    /**
     *  @private
     *  Sets the selection and updates the caret and anchor positions.
     */
    private function setSelectionAnchorCaret(rowIndex:int, columnIndex:int):Boolean
    {
        // click sets the selection and updates the caret and anchor 
        // positions.
        var changed:Boolean;
        if (isRowSelectionMode())
        {
            // Select the row.
            changed = commitInteractiveSelection(
                GridSelectionEventKind.SET_ROW, 
                rowIndex, columnIndex);
        }
        else if (isCellSelectionMode())
        {
            // Select the cell.
            changed = commitInteractiveSelection(
                GridSelectionEventKind.SET_CELL, 
                rowIndex, columnIndex);
        }
        
        // Update the caret and anchor positions even if the selection did not
        // change.
        commitCaretPosition(rowIndex, columnIndex);
        grid.anchorRowIndex = rowIndex;
        grid.anchorColumnIndex = columnIndex; 
        
        return changed;
    }
    
    /**
     *  @private
     *  Returns the new caret position based on the current caret position and 
     *  the navigationUnit as a Point, where x is the columnIndex and y is the 
     *  rowIndex.  Assures there is a valid caretPosition.
     */
    private function setCaretToNavigationDestination(navigationUnit:uint):CellPosition
    {
        var caretRowIndex:int = grid.caretRowIndex;
        var caretColumnIndex:int = grid.caretColumnIndex;
        
        const inRows:Boolean = isRowSelectionMode();
        
        const rowCount:int = getDataProviderLength();
        const columnCount:int = getColumnsLength();
        var visibleRows:Vector.<int>;
        var caretRowBounds:Rectangle;
        
        switch (navigationUnit)
        {
            case NavigationUnit.LEFT: 
            {
                if (isCellSelectionMode())
                {
                    if (grid.caretColumnIndex > 0)
                        caretColumnIndex--;
                }
                break;
            }
                
            case NavigationUnit.RIGHT:
            {
                if (isCellSelectionMode())
                {
                    if (grid.caretColumnIndex + 1 < columnCount)
                        caretColumnIndex++;
                }
                break;
            } 
                
            case NavigationUnit.UP:
            {
                if (grid.caretRowIndex > 0)
                    caretRowIndex--;
                break; 
            }
                
            case NavigationUnit.DOWN:
            {
                if (grid.caretRowIndex + 1 < rowCount)
                    caretRowIndex++;
                break; 
            }
                
            case NavigationUnit.PAGE_UP:
            {
                // Page up to first fully visible row on the page.  If there is
                // a partially visible row at the top of the page, the next
                // page up should include it in its entirety.
                visibleRows = grid.getVisibleRowIndices();
                if (visibleRows.length == 0)
                    break;
                
                // This row might be only partially visible.
                var firstVisibleRowIndex:int = visibleRows[0];                
                var firstVisibleRowBounds:Rectangle =
                    grid.getRowBounds(firstVisibleRowIndex);
                
                // Set to the first fully visible row.
                if (firstVisibleRowIndex < rowCount - 1 && 
                    firstVisibleRowBounds.top < grid.scrollRect.top)
                {
                    firstVisibleRowIndex = visibleRows[1];
                }
                
                if (caretRowIndex > firstVisibleRowIndex)
                {
                    caretRowIndex = firstVisibleRowIndex;
                }
                else
                {     
                    // If the caret is above the visible rows or the
                    // first visible row, scroll so that caret row is the last 
                    // visible row.
                    caretRowBounds = grid.getRowBounds(caretRowIndex);
                    const delta:Number = 
                        grid.scrollRect.bottom - caretRowBounds.bottom;
                    grid.verticalScrollPosition -= delta;
                    validateNow();
                    
                    // Visible rows have been updated so figure out which one
                    // is now the first fully visible row.
                    visibleRows = grid.getVisibleRowIndices();
                    firstVisibleRowIndex = visibleRows[0];
                    if (visibleRows.length > 0)
                    {
                        firstVisibleRowBounds = grid.getRowBounds(firstVisibleRowIndex);
                        if (firstVisibleRowIndex < rowCount - 1 && 
                            grid.scrollRect.top > firstVisibleRowBounds.top)
                        {
                            firstVisibleRowIndex = visibleRows[1];
                        }
                        caretRowIndex = firstVisibleRowIndex;
                    }
                }
                break; 
            }
            case NavigationUnit.PAGE_DOWN:
            {
                // Page down to last fully visible row on the page.  If there is
                // a partially visible row at the bottom of the page, the next
                // page down should include it in its entirety.
                visibleRows = grid.getVisibleRowIndices();
                if (visibleRows.length == 0)
                    break;
                
                // This row might be only partially visible.
                var lastVisibleRowIndex:int = 
                    visibleRows[visibleRows.length - 1];                
                var lastVisibleRowBounds:Rectangle =
                    grid.getRowBounds(lastVisibleRowIndex);
                
                // If there is more than one visible row, set to the last
                // fully visible row.
                if (lastVisibleRowIndex > 0 && 
                    grid.scrollRect.bottom < lastVisibleRowBounds.bottom)
                {
                    lastVisibleRowIndex = visibleRows[visibleRows.length - 2];
                }
                
                if (caretRowIndex < lastVisibleRowIndex)
                {
                    caretRowIndex = lastVisibleRowIndex;
                }
                else
                {                        
                    // Caret is last visible row or it is after the visible rows.
                    // Scroll, so the caret row is the first visible row.
                    caretRowBounds = grid.getRowBounds(caretRowIndex);
                    grid.verticalScrollPosition = caretRowBounds.y;
                    validateNow();
                    
                    // Visible rows have been updated so figure out which one
                    // is now the last fully visible row.
                    visibleRows = grid.getVisibleRowIndices();
                    lastVisibleRowIndex = visibleRows[visibleRows.length - 1];
                    if (visibleRows.length >= 0)
                    {
                        lastVisibleRowBounds = grid.getRowBounds(lastVisibleRowIndex);
                        if (lastVisibleRowIndex > 0 && 
                            grid.scrollRect.bottom < lastVisibleRowBounds.bottom)
                        {
                            lastVisibleRowIndex = visibleRows[visibleRows.length - 2];
                        }
                        caretRowIndex = lastVisibleRowIndex;
                    }
                }
                break; 
            }
                
            case NavigationUnit.HOME:
            {
                caretRowIndex = 0;
                caretColumnIndex = isCellSelectionMode() ? 0 : -1; 
                break;
            }
                
            case NavigationUnit.END:
            {
                caretRowIndex = rowCount - 1;
                caretColumnIndex = isCellSelectionMode() ? columnCount - 1 : -1;
                
                // The heights of any rows that have not been rendered yet are
                // estimated.  Force them to draw so the heights are accurate.
                // TBD: is there a better way to do this?
                grid.verticalScrollPosition = grid.contentHeight;
                validateNow();
                if (grid.contentHeight != grid.verticalScrollPosition)
                {
                    grid.verticalScrollPosition = grid.contentHeight;
                    validateNow();
                }
                break;
            }
                
            default: 
            {
                return null;
            }
        }
        
        return new CellPosition(caretRowIndex, caretColumnIndex);
    }
    
    /**
     *  @copy spark.components.supportClasses.Grid#ensureIndexIsVisible
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function ensureCellIsVisible(rowIndex:int, columnIndex:int = -1):void
    {
        if (grid)
            grid.ensureCellIsVisible(rowIndex, columnIndex);
    }
    
    /**
     *  @private
     * 
     *  Adjusts the caret and the selection based on what keystroke is used
     *  in combination with a ctrl/cmd key or a shift key.  Returns false
     *  if the selection was not changed.
     */
    protected function adjustSelectionUponNavigation(event:KeyboardEvent):Boolean
    {
        // Some unrecognized key stroke was entered, return. 
        if (!NavigationUnit.isNavigationUnit(event.keyCode))
            return false; 
        
        // If rtl layout, need to swap Keyboard.LEFT and Keyboard.RIGHT.
        var navigationUnit:uint = mapKeycodeForLayoutDirection(event);
        
        const newPosition:CellPosition = setCaretToNavigationDestination(navigationUnit);
        if (!newPosition)
            return false;
        
        // Cancel so another component doesn't handle this event.
        event.preventDefault(); 
        
        var selectionChanged:Boolean = false;
        
        if (event.shiftKey)
        {
            // The shift key-nav key combination extends the selection and 
            // updates the caret.
            selectionChanged = 
                extendSelection(newPosition.rowIndex, newPosition.columnIndex);
        }
        else if (event.ctrlKey)
        {
            // If its a ctrl/cmd key-nav key combination, there is nothing
            // more to do then set the caret.
            commitCaretPosition(newPosition.rowIndex, newPosition.columnIndex);
        }
        else
        {
            // Select the current row/cell.
            setSelectionAnchorCaret(newPosition.rowIndex, newPosition.columnIndex);
        }
       
        // Ensure this position is visible.
        ensureCellIsVisible(newPosition.rowIndex, newPosition.columnIndex);            
        
        return true;
        
    }
    
    /**
     *  @private
     * 
     *  Returns true if committing the given selection operation would change
     *  the current selection.
     */
    private function doesChangeCurrentSelection(
        selectionEventKind:String, 
        selectionChange:CellRegion):Boolean
    {
        var changesSelection:Boolean;
        
        const rowIndex:int = selectionChange.rowIndex;
        const columnIndex:int = selectionChange.columnIndex;
        const rowCount:int = selectionChange.rowCount;
        const columnCount:int = selectionChange.columnCount;
        
        switch (selectionEventKind)
        {
            case GridSelectionEventKind.SET_ROW:
            {
                changesSelection = 
                    !selectionContainsOnlyIndex(rowIndex);
                break;
            }
            case GridSelectionEventKind.ADD_ROW:
                
            {
                changesSelection = 
                    !grid.selectionContainsIndex(rowIndex);
                break;
            }
                
            case GridSelectionEventKind.REMOVE_ROW:
            {
                changesSelection = requireSelection ?
                    !selectionContainsOnlyIndex(rowIndex) :
                    grid.selectionContainsIndex(rowIndex);
                break;
            }
                
            case GridSelectionEventKind.SET_ROWS:
            {
                changesSelection = 
                    !selectionContainsOnlyIndicesCR(selectionChange);
                break;
            }
                
            case GridSelectionEventKind.SET_CELL:
            {
                changesSelection = 
                    !selectionContainsOnlyCell(rowIndex, columnIndex);
                break;
            }
                
            case GridSelectionEventKind.ADD_CELL:
            {
                changesSelection = 
                    !grid.selectionContainsCell(rowIndex, columnIndex);
                break;
            }
                
            case GridSelectionEventKind.REMOVE_CELL:
            {
                changesSelection = requireSelection ?
                    !selectionContainsOnlyCell(rowIndex, columnIndex) :                  
                    grid.selectionContainsCell(rowIndex, columnIndex);
                break;
            }
                
            case GridSelectionEventKind.SET_CELL_REGION:
            {
                changesSelection = 
                    !selectionContainsOnlyCellRegion(
                        rowIndex, columnIndex, rowCount, columnCount);
                break;
            }
                
            case GridSelectionEventKind.SELECT_ALL:
            {
                changesSelection = !gridSelection.selectAllFlag;
                break;
            }
        }
        
        return changesSelection;
    }
    
    //--------------------------------------------------------------------------
    //
    //  GridEvent handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    protected function gridRollOverHandler(event:GridEvent):void
    {
        grid.hoverRowIndex = event.rowIndex;
        grid.hoverColumnIndex = event.columnIndex;
    }
    
    /**
     *  @private
     */
    protected function gridRollOutHandler(event:GridEvent):void
    {
        grid.hoverRowIndex = -1;
        grid.hoverColumnIndex = -1;
    }
    
    /**
     *  @private
     */
    protected function gridMouseDownHandler(event:GridEvent):void
    {
        const rowIndex:int = event.rowIndex;
        var columnIndex:int = isRowSelectionMode() ? -1 : event.columnIndex;
        
        if (event.ctrlKey)
        {
            // ctrl-click toggles the selection and updates caret and anchor.
            if (!toggleSelection(rowIndex, columnIndex))
                return;
            
            grid.anchorRowIndex = rowIndex;
            grid.anchorColumnIndex = columnIndex;
        }
        else if (event.shiftKey)
        {
            // shift-click extends the selection and updates the caret.
            if  (grid.selectionMode == GridSelectionMode.MULTIPLE_ROWS || 
                grid.selectionMode == GridSelectionMode.MULTIPLE_CELLS)
            {    
                if (!extendSelection(rowIndex, columnIndex))
                    return;
            }
        }
        else
        {
            // click sets the selection and updates the caret and anchor 
            // positions.
            setSelectionAnchorCaret(rowIndex, columnIndex);
        }
    } 
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Redispatch the grid's "caretChange" event.
     */
    protected function grid_caretChangeHandler(event:GridCaretEvent):void
    {
        if (hasEventListener(GridCaretEvent.CARET_CHANGE))
            dispatchEvent(event);
    }
    
    /**
     *  @private
     *  Redispatch the grid's "valueCommit" event.
     */
    protected function grid_valueCommitHandler(event:FlexEvent):void
    {
        if (hasEventListener(FlexEvent.VALUE_COMMIT))
            dispatchEvent(event);
    }
    
    /**
     *  @private
     */
    protected function grid_changeEventHandler(event:PropertyChangeEvent):void
    {
        if (columnHeaderBar && event.property == "horizontalScrollPosition")
            columnHeaderBar.horizontalScrollPosition = Number(event.newValue);
    }
    
    protected function grid_columnsChangedEventHandler(event:Event):void
    {
        if (columnHeaderBar)
            columnHeaderBar.dataProvider = columns;
        // TBD(hmuller) - should be done at commitproperties time
    }    
    
    //--------------------------------------------------------------------------
    //
    //  Public Methods
    //
    //--------------------------------------------------------------------------

}
}