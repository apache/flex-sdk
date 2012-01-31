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
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import mx.collections.ArrayList;
import mx.collections.IList;
import mx.core.IFactory;
import mx.core.IVisualElement;
import mx.core.UIComponentGlobals;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.FlexEvent;
import mx.events.PropertyChangeEvent;
import mx.utils.ObjectUtil;

import spark.components.gridClasses.CellPosition;
import spark.components.gridClasses.GridColumn;
import spark.components.gridClasses.GridDimensions;
import spark.components.gridClasses.GridLayer;
import spark.components.gridClasses.GridLayout;
import spark.components.gridClasses.GridSelection;
import spark.components.gridClasses.GridSelectionMode;
import spark.components.gridClasses.IDataGridElement;
import spark.components.gridClasses.IGridItemRenderer;
import spark.events.GridCaretEvent;
import spark.events.GridEvent;
import spark.utils.MouseEventUtil;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the mouse button is pressed over a Grid cell.
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
 *  Dispatched when the mouse button is released over a Grid cell, or, 
 *  during a drag operation, it is dispatched after a GRID_MOUSE_DOWN event 
 *  when the mouse button is released, even if the mouse is no longer 
 *  within the Grid.
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
 *  Dispatched when the mouse enters a grid cell.
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
 *  Dispatched when the mouse leaves a grid cell.
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
 *  Dispatched when the mouse is clicked over a cell
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
 *  Dispatched when the mouse is double-clicked over a cell
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

/**
 *  Grid is a Spark component that displays a list of data items called
 *  its <i>dataProvider</i> in a scrollable table or "grid", one item per
 *  row.  Each of the grid's columns, defined by a <code>GridColumn</code>
 *  object, displays a value based on the item for the corresponding row.
 *  The grid's dataProvider is mutable, dataProvider items can be added or
 *  removed, or changed.  Similarly the Grid's list of columns is mutable.
 * 
 *  <p>The Grid component is intended to be used as a DataGrid skin part, or
 *  as an element of other custom composite components.  As such it is not
 *  skinnable, it does not include a scroller or scrollbars, and it does
 *  not provide default mouse or keyboard event handling.  Its role is
 *  similar to DataGroup, the workhorse skin part for the Spark List.</p>
 * 
 *  <p>Each visible Grid <i>cell</i> is displayed by a <code>GridItemRenderer</code>
 *  instance created using the <code>itemRenderer</code> factory.  One
 *  item renderer (factory) is specified for each column and, before it's
 *  displayed, each item renderer instance is configured with the value of
 *  the dataProvider item for that row, and its row and column indices.
 *  Item renderers are created as needed and then, to keep creation
 *  overhead to a minimum, pooled and "recycled".</p>
 * 
 *  <p>Grids support selection, according the <code>selectionMode</code>
 *  property.  The set of selected row or cell indices can be modified or
 *  queried programatically using the selection methods like
 *  <code>setSelectedIndex</code> or <code>selectionContainsIndex()</code>.</p>
 * 
 *  <p>Grids display hover, caret, and selection <i>indicators</i> per the
 *  selectionMode and the corresponding row,columnIndex properties like
 *  <code>hoverRowIndex</code> and <code>columnRowIndex</code>.  An
 *  indicator can be any visual element.  Indicators that implement IGridElement
 *  can configure themselves according to the row and column they're
 *  displayed on.</p>
 * 
 *  <p>Grids support smooth scrolling.  Their vertical and horizontal
 *  scroll positions define the pixel origin of the visible part of the
 *  grid and the grid's layout only displays as many cell item renderers
 *  as are needed to fill the available space.  Grids support variable
 *  height rows that automatically compute their height based on the item
 *  renderers' contents.  This support is called grid "virtualization"
 *  because the mapping from (pixel) scroll positions to row and column indices
 *  is typically based on incomplete information about the preferred sizes 
 *  for grid cells.  The Grid caches the computed heights of rows that have been
 *  scrolled into view and estimates the rest based on a single 
 *  <code>typicalItem</code>.</p>
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
public class Grid extends Group implements IDataGridElement
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  A list of functions to be called at commitProperties() time, after the dataProvider
     *  has been set.  This list is used to defer making grid selection updates per the 
     *  set methods for the selectedIndex, selectedIndices, selectedItem, selectedItems, 
     *  selectedCell and selectedCells properties.
     */
    private const deferredOperations:Vector.<Function> = new Vector.<Function>();
    
    /**
     *  @private
     *  True while updateDisplayList is running.  Use to disable invalidateSize(),
     *  invalidateDisplayList() here and in the GridLayer class.
     */
    mx_internal var inUpdateDisplayList:Boolean = false;  
    
    /**
     *  @private
     *  True while doing a drag operation with the mouse.
     */
    private var dragInProgress:Boolean = false;
    
    /**
     *  @private
     *  True if the columns were generated rather than explicitly set.
     */
    private var generatedColumns:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.4
     *  @productversion Flex 4.5
     */
    public function Grid()
    {
        super();
        layout = new GridLayout();
        
        MouseEventUtil.addDownDragUpListeners(this, 
            grid_mouseDownDragUpHandler, 
            grid_mouseDownDragUpHandler, 
            grid_mouseDownDragUpHandler);
                    
        addEventListener(MouseEvent.MOUSE_UP, grid_mouseUpHandler);
        addEventListener(MouseEvent.MOUSE_MOVE, grid_mouseMoveHandler);
        addEventListener(MouseEvent.ROLL_OUT, grid_mouseRollOutHandler);
        addEventListener(MouseEvent.CLICK, grid_clickHandler);
        addEventListener(MouseEvent.DOUBLE_CLICK, grid_doubleClickHandler);        
    }
    
    private function get gridLayout():GridLayout
    {
        return layout as GridLayout;
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
    
    //----------------------------------
    //  anchorColumnIndex
    //----------------------------------

    [Bindable("anchorColumnIndexChanged")]
    
    private var _anchorColumnIndex:int = 0;

    // True if either anchorColumnIndex or anchorRowIndex changes.
    private var anchorChanged:Boolean = false;
    
    /**
     *  The column index of the "anchor" for the next shift selection.
     *  Grid event handlers should use this property to record the
     *  location of the most recent unshifted mouse down or keyboard
     *  event that defines one end of the next potential shift
     *  selection.  The caret index defines the other end.
     * 
     *  @default 0
     * 
     *  @see spark.components.Grid#caretRowIndex
     *  @see spark.components.Grid#caretColumnIndex
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */
    public function get anchorColumnIndex():int
    {
        return _anchorColumnIndex;
    }
    
    /**
     *  @private
     */
    public function set anchorColumnIndex(value:int):void
    {
        if (_anchorColumnIndex == value || 
            selectionMode == GridSelectionMode.SINGLE_ROW || 
            selectionMode == GridSelectionMode.MULTIPLE_ROWS)
        {
            return;
        }
        
        _anchorColumnIndex = value;
        
        anchorChanged = true;
        invalidateProperties();
        
        dispatchChangeEvent("anchorColumnIndexChanged");
    }
    
    
    //----------------------------------
    //  anchorRowIndex
    //----------------------------------
    
    [Bindable("anchorRowIndexChanged")]
    
    private var _anchorRowIndex:int = 0; 
    
    /**
     *  The row index of the "anchor" for the next shift selection.
     *  Grid event handlers should use this property to record the
     *  location of the most recent unshifted mouse down or keyboard
     *  event that defines one end of the next potential shift
     *  selection.  The caret index defines the other end.
     * 
     *  @default 0
     *
     *  @see spark.components.Grid#caretRowIndex
     *  @see spark.components.Grid#caretColumnIndex
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */
    public function get anchorRowIndex():int
    {
        return _anchorRowIndex;
    }
    
    /**
     *  @private
     */
    public function set anchorRowIndex(value:int):void
    {
        if (_anchorRowIndex == value)
            return;
        
        _anchorRowIndex = value;
        
        anchorChanged = true;
        invalidateProperties();
        
        dispatchChangeEvent("anchorRowIndexChanged");
    }
    
    //----------------------------------
    //  caretIndicator
    //----------------------------------
    
    [Bindable("caretIndicatorChanged")]
    
    private var _caretIndicator:IFactory = null;
    
    /**
     *  A single visual element that's displayed for the caret row, if
     *  selectionMode is <code>GridSelectionMode.SINGLE_ROW</code> or
     *  <code>GridSelectionMode.MULTIPLE_ROWS</code>, or for the caret
     *  cell, if selectionMode is
     *  <code>GridSelectionMode.SINGLE_CELL</code> or
     *  <code>GridSelectionMode.MULTIPLE_CELLS</code>.
     *  
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get caretIndicator():IFactory
    {
        return _caretIndicator;
    }
    
    /**
     *  @private
     */
    public function set caretIndicator(value:IFactory):void
    {
        if (_caretIndicator == value)
            return;
        
        _caretIndicator = value;
        invalidateDisplayList();
        dispatchChangeEvent("caretIndicatorChanged");
    }    
    
    //----------------------------------
    //  caretColumnIndex
    //----------------------------------
    
    [Bindable("caretColumnIndexChanged")]
    
    private var _caretColumnIndex:int = -1;
    private var _oldCaretColumnIndex:int = -1;
    
    private var caretChanged:Boolean = false;
    
    /**
     *  The column index of the caretIndicator visualElement if
     *  <code>showCaretIndicator</code> is true.  If selectionMode is
     *  <code>GridSelectionMode.SINGLE_ROW</code> or
     *  <code>GridSelectionMode.MULTIPLE_ROWS</code> then the indicator
     *  occupies the entire row and caretColumnIndex is ignored.  If
     *  selectionMode is <code>GridSelectionMode.SINGLE_CELL</code> or
     *  <code>GridSelectionMode.MULTIPLE_CELLS</code> then the caretIndicator
     *  occupies the specified cell.
     * 
     *  <p>Setting caretColumnIndex to -1 means that the column index is undefined and 
     *  a cell caret will not be shown.</p>
     * 
     *  @default -1
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */
    public function get caretColumnIndex():int
    {
        return _caretColumnIndex;
    }
    
    /**
     *  @private
     */
    public function set caretColumnIndex(value:int):void
    {
        _oldCaretColumnIndex = _caretColumnIndex;

        if (caretColumnIndex == value || value < -1)
            return;
        
        _caretColumnIndex = value;
        
        caretChanged = true;
        invalidateProperties();
        
        if (caretIndicator)
            invalidateDisplayList();         
        dispatchChangeEvent("caretColumnIndexChanged");
    }
    
    
    //----------------------------------
    //  caretRowIndex
    //----------------------------------
    
    [Bindable("caretRowIndexChanged")]
    
    private var _caretRowIndex:int = -1;
    private var _oldCaretRowIndex:int = -1;
    
    /**
     *  The row index of the caretIndicator visualElement if
     *  <code>showCaretIndicator</code> is true.  If selectionMode is
     *  <code>GridSelectionMode.SINGLE_ROW</code> or
     *  <code>GridSelectionMode.MULTIPLE_ROWS</code> then the indicator
     *  occupies the entire row and caretColumnIndex is ignored.  If
     *  selectionMode is <code>GridSelectionMode.SINGLE_CELL</code> or
     *  <code>GridSelectionMode.MULTIPLE_CELLS</code> then the caretIndicator
     *  occupies the specified cell.
     * 
     *  <p>Setting caretRowIndex to -1 means that the row index is undefined and 
     *  the caret will not be shown.</p>
     * 
     *  @default -1
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */
    public function get caretRowIndex():int
    {
        return _caretRowIndex;
    }
    
    /**
     *  @private
     */
    public function set caretRowIndex(value:int):void
    {
        _oldCaretRowIndex = _caretRowIndex;

        if (_caretRowIndex == value || value < -1)
            return;
        
        _caretRowIndex = value;
        
        caretChanged = true;
        invalidateProperties();
        
        if (caretIndicator)
            invalidateDisplayList();         
        dispatchChangeEvent("caretRowIndexChanged");
    }
    
    //----------------------------------
    //  hoverIndicator
    //----------------------------------
    
    [Bindable("hoverIndicatorChanged")]
    
    private var _hoverIndicator:IFactory = null;
    
    /**
     *  A single visual element that's displayed for the row under the
     *  mouse, if selectionMode is
     *  <code>GridSelectionMode.SINGLE_ROW</code>, or
     *  <code>GridSelectionMode.MULTIPLE_ROWS</code>, or for the caret
     *  cell, if selectionMode is
     *  <code>GridSelectionMode.SINGLE_CELL</code> or
     *  <code>GridSelectionMode.MULTIPLE_CELLS</code>.
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get hoverIndicator():IFactory
    {
        return _hoverIndicator;
    }
    
    /**
     *  @private
     */
    public function set hoverIndicator(value:IFactory):void
    {
        if (_hoverIndicator == value)
            return;
        
        _hoverIndicator = value;
        invalidateDisplayList();
        dispatchChangeEvent("hoverIndicatorChanged");
    }    
    
    //----------------------------------
    //  hoverColumnIndex 
    //----------------------------------
    
    [Bindable("hoverColumnIndexChanged")]
    
    private var _hoverColumnIndex:int = -1;
    
    /**
     *  Specifies column index of the hoverIndicator visualElement if
     *  <code>showHoverIndicator</code> is true.  If selectionMode is
     *  <code>GridSelectionMode.SINGLE_ROW</code> or
     *  <code>GridSelectionMode.MULTIPLE_ROWS</code> then the indicator
     *  occupies the entire row and hoverColumnIndex is ignored.  If
     *  selectionMode is <code>GridSelectionMode.SINGLE_CELL</code> or
     *  <code>GridSelectionMode.MULTIPLE_CELLS</code> then the hoverIndicator
     *  occupies the specified cell.
     *  
     *  <p>Setting hoverColumnIndex to -1 (the default) means that the column index
     *  is undefined and a cell hover indicator will not be displayed.</p>
     * 
     *  @default -1
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */
    public function get hoverColumnIndex():int
    {
        return _hoverColumnIndex;
    }
    
    /**
     *  @private
     */
    public function set hoverColumnIndex(value:int):void
    {
        if (_hoverColumnIndex == value)
            return;
        
        _hoverColumnIndex = value;
        if (hoverIndicator)
            invalidateDisplayList();         
        dispatchChangeEvent("hoverColumnIndexChanged");
    }
    
    
    //----------------------------------
    //  hoverRowIndex
    //----------------------------------
    
    [Bindable("hoverRowIndexChanged")]
    
    private var _hoverRowIndex:int = -1;
    
    /**
     *  Specifies column index of the hoverIndicator visualElement if
     *  <code>showHoverIndicator</code> is true.  If selectionMode is
     *  <code>GridSelectionMode.SINGLE_ROW</code> or
     *  <code>GridSelectionMode.MULTIPLE_ROWS</code> then the indicator
     *  occupies the entire row and hoverColumnIndex is ignored.  If
     *  selectionMode is <code>GridSelectionMode.SINGLE_CELL</code> or
     *  <code>GridSelectionMode.MULTIPLE_CELLS</code> then the hoverIndicator
     *  occupies the specified cell.
     * 
     *  <p>Setting hoverRowIndex to -1 (the default) means that the row index
     *  is undefined and a hover indicator will not be displayed.</p>
     * 
     *  @default -1
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */
    public function get hoverRowIndex():int
    {
        return _hoverRowIndex;
    }
    
    /**
     *  @private
     */
    public function set hoverRowIndex(value:int):void
    {
        if (_hoverRowIndex == value)
            return;
        
        _hoverRowIndex = value;
        if (hoverIndicator)
            invalidateDisplayList();           
        dispatchChangeEvent("hoverRowIndexChanged");
    }
    
    //----------------------------------
    //  columns
    //----------------------------------    
    
    private var _columns:IList = null; // list of GridColumns
    private var columnsChanged:Boolean = false;
    
    [Bindable("columnsChanged")]
    
    /**
     *  The list of GridColumns displayed by this grid.  Each column
     *  selects different dataProvider item properties to display in grid <i>cells</i>.
     *  
     *  <p>GridColumn objects can only appear in one columns list.</p> 
     *  
     *  @default null
     * 
     *  @see spark.components.Grid#dataProvider
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
        
        const oldColumns:IList = _columns;
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
        
        const newColumns:IList = _columns;
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
                                   
        columnsChanged = true;
        generatedColumns = false;        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
        
        dispatchChangeEvent("columnsChanged");             
    }
    
    /**
     *  @private
     */
    private function getColumnsLength():uint
    {
        const columns:IList = columns;
        return (columns) ? columns.length : 0;
    }
    
    /**
     *  @private
     *  This method is similar to mx.controls.DataGrid/ls().
     */
    private function generateColumns():IList
    {
        var item:Object = typicalItem;
        if (!item && dataProvider && (dataProvider.length > 0))
            item = dataProvider.getItemAt(0);
        
        var itemColumns:IList = null;
        if (item)
        {
            itemColumns = new ArrayList();
            const classInfo:Object = ObjectUtil.getClassInfo(item, ["uid", "mx_internal_uid"]);
            if (classInfo)
            {
                for each (var property:QName in classInfo.properties)
                {
                    var column:GridColumn = new GridColumn();
                    column.dataField = property.localName;
                    itemColumns.addItem(column);                        
                }
            }
        }
        
        return itemColumns;
    }
   
    
    //----------------------------------
    //  dataProvider
    //----------------------------------
    
    private var _dataProvider:IList = null;
    private var dataProviderChanged:Boolean;
    
    [Bindable("dataProviderChanged")]
    
    /**
     *  A list of <i>items</i> that correspond to the rows in the grid.   The grid's <i>columns</i>
     *  select different item properties to display in grid <i>cells</i>.
     * 
     *  @default null
     * 
     *  @see spark.components.Grid#columns
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
       
        dataProviderChanged = true;
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
        
        dispatchChangeEvent("dataProviderChanged");        
    }
    
    //----------------------------------
    //  dataTipField
    //----------------------------------
    
    private var _dataTipField:String = null;
    
    [Bindable("dataTipFieldChanged")]    
    
    /**
     *  The dataTipField that's used for columns that do not specify one.
     * 
     *  @default null
     * 
     *  @see spark.components.gridClasses.GridColumn#dataTipField
     */
    public function get dataTipField():String
    {
        return _dataTipField;
    }
    
    /**
     *  @private
     */
    public function set dataTipField(value:String):void
    {
        if (_dataTipField == value)
            return;
        
        _dataTipField = value;
        
        invalidateDisplayList();
        dispatchChangeEvent("dataTipFieldChanged");
    }
    
    //----------------------------------
    //  dataTipFunction
    //----------------------------------
    
    private var _dataTipFunction:Function = null;
    
    [Bindable("dataTipFunctionChanged")]
    
    /**
     *  The dataTipFunction that's used for columns that do not specify one.
     * 
     *  @default null
     * 
     *  @see spark.components.gridClasses.GridColumn#dataTipField
     */
    public function get dataTipFunction():Function
    {
        return _dataTipFunction;
    }
    
    /**
     *  @private
     */
    public function set dataTipFunction(value:Function):void
    {
        if (_dataTipFunction == value)
            return;
        
        _dataTipFunction = value;
        
        invalidateDisplayList();        
        dispatchChangeEvent("dataTipFunctionChanged");
    }    
    
    //----------------------------------
    //  itemRenderer
    //----------------------------------
    
    [Bindable("itemRendererChanged")]
    
    private var _itemRenderer:IFactory = null;
    
    private var itemRendererChanged:Boolean = false;
    
    /**
     *  The item renderer that's used for columns that do not specify one.
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5 
     */
    public function get itemRenderer():IFactory
    {
        return _itemRenderer;
    }
    
    /**
     *  @private
     */
    public function set itemRenderer(value:IFactory):void
    {
        if (_itemRenderer == value)
            return;
        
        _itemRenderer = value;
        
        itemRendererChanged = true;
        invalidateSize();
        invalidateDisplayList();
        
        dispatchChangeEvent("itemRendererChanged");
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
    //  gridSelection (mx_internal)
    //----------------------------------
    
    private var _gridSelection:GridSelection;
    
    /**
     *  @private
     */
    mx_internal function get gridSelection():GridSelection
    {
        return _gridSelection;
    }
    
    /**
     *  @private
     *  This value is created by DataGrid/partAdded() and then set here.   It is only
     *  set once, unless that "grid" part is removed, at which point it's set to null.
     */
    mx_internal function set gridSelection(value:GridSelection):void
    {
        _gridSelection = value;
    }
    
    
    //----------------------------------
    //  gridDimensions (mx_internal)
    //----------------------------------
    
    private var _gridDimensions:GridDimensions;
    
    /**
     *  @private
     */
    mx_internal function get gridDimensions():GridDimensions
    {
        return _gridDimensions;
    }
    
    /**
     *  @private
     *  This value is created by DataGrid/partAdded() and then set here.   It is only
     *  set once, unless that "grid" part is removed, at which point it's set to null.
     */
    mx_internal function set gridDimensions(value:GridDimensions):void
    {
        _gridDimensions = value;
    }
    
    //----------------------------------
    //  dataGrid
    //----------------------------------
    
    [Bindable("dataGridChanged")]
    
    private var _dataGrid:DataGrid = null;
    
    /**
     *  The DataGrid for which this Grid is the grid skin part.
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
        
        _dataGrid = value;
        dispatchChangeEvent("dataGridChanged");
    }
    
    //----------------------------------
    //  layers
    //----------------------------------
    
    private var _layers:Vector.<GridLayer> = null;
    private var layersMap:Dictionary = new Dictionary();
    
    [Bindable("layersChanged")]
    
    /**
     *  The GridLayer objects that define the stacking order or "layering" for Grid visual elements.
     * 
     *  <p>The GridLayout adds rowBackround and hoverIndicator elements to the backgroundLayer, 
     *  selectionIndicators to the selectionLayer, item renderers to the rendererLayer, caretIndicator, 
     *  row and column separators to the overlayLayer.</p>
     * 
     *  <p>If a value for this property isn't specified, then at commitProperties() time
     *  a Vector of the four minimum GridLayers expected by the Grid's layout is created.  The layers
     *  have the following ids: "backgroundLayer", "selectionLayer", "rendererLayer", "overlayLayer".
     *  The rendererLayer's root is this Grid.</p>
     * 
     *  @default Four layers with the following ids: "backgroundLayer", "selectionLayer", "rendererLayer", "overlayLayer".
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get layers():Vector.<GridLayer>
    {
        return (_layers) ? _layers.concat() : new Vector.<GridLayer>(0);
    }
    
    /**
     *  @private
     */        
    public function set layers(value:Vector.<GridLayer>):void
    {
        _layers = (!value) ? new Vector.<GridLayer>(0) : value.concat();

        layersMap = new Dictionary();
        for each (var layer:GridLayer in _layers)
        {
            var layerID:String = layer.id;
            if (layerID)
                layersMap[layerID] = layer;
            
            if (layer.root != this)
                addElement(layer.root)
        }
        
        dispatchChangeEvent("layersChanged");            
    }
    
    /**
     *  Returns the GridLayer element of the layers property with the specified id, or null.
     * 
     *  <p>Grid's layout uses this method to lookup GridLayers.</p>
     * 
     *  @param id The id of the GridLayer to be returned.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function getLayer(id:String):GridLayer
    {
        return layersMap[id] as GridLayer;
    }
    
    //----------------------------------
    //  preserveSelection (delegates to gridSelection.preserveSelection)
    //----------------------------------
    
    /**
     *  @copy spark.components.gridClasses.GridSelection#preserveSelection
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get preserveSelection():Boolean
    {
        return gridSelection.preserveSelection;
    }
    
    /**
     *  @private
     */    
    public function set preserveSelection(value:Boolean):void
    {
        gridSelection.preserveSelection = value;
    }
    
    
    //----------------------------------
    //  requestedMinRowCount
    //----------------------------------
    
    private var _requestedMinRowCount:int = -1;
    
    [Inspectable(category="General", minValue="-1")]
    
    /**
     *  The measured height of this grid will be large enough to display 
     *  at least <code>requestedMinRowCount</code> rows.
     * 
     *  <p>This property has no effect if any of the following are true;
     *  <ul>
     *      <li><code>requestedRowCount</code> is set</li>
     *      <li>the actual size of the grid has been explicitly set</li>
     *      <li>the grid is inside a Scroller component</li>
     *  </ul>
     *  </p>
     * 
     *  @default -1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get requestedMinRowCount():int
    {
        return _requestedMinRowCount;
    }
    
    /**
     *  @private
     */
    public function set requestedMinRowCount(value:int):void
    {
        if (_requestedMinRowCount == value)
            return;
        
        _requestedMinRowCount = value;
        invalidateSize();
    }    
    
    //----------------------------------
    //  requestedRowCount
    //----------------------------------
    
    private var _requestedRowCount:int = 10;
    
    [Inspectable(category="General", minValue="-1")]
    
    /**
     *  The measured height of this grid will be large enough to display 
     *  the first <code>requestedRowCount</code> rows. 
     * 
     *  <p>If <code>requestedRowCount</code> is -1, then the measured
     *  size will be big enough for all of the layout elements.</p>
     * 
     *  <p>If the actual size of the grid has been explicitly set,
     *  then this property has no effect.</p>
     * 
     *  @default 10
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get requestedRowCount():int
    {
        return _requestedRowCount;
    }
    
    /**
     *  @private
     */
    public function set requestedRowCount(value:int):void
    {
        if (_requestedRowCount == value)
            return;
        
        _requestedRowCount = value;
        invalidateSize();
    }
    
    
    //----------------------------------
    //  requestedMinColumnCount
    //----------------------------------
    
    private var _requestedMinColumnCount:int = -1;
    
    [Inspectable(category="General", minValue="-1")]
    
    /**
     *  The measured width of this grid will be large enough to display 
     *  at least <code>requestedMinColumnCount</code> columns.
     * 
     *  <p>This property has no effect if any of the following are true;
     *  <ul>
     *      <li><code>requestedColumnCount</code> is set</li>
     *      <li>the actual size of the grid has been explicitly set</li>
     *      <li>the grid is inside a Scroller component</li>
     *  </ul>
     *  </p>
     *  
     *  @default -1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get requestedMinColumnCount():int
    {
        return _requestedMinColumnCount;
    }
    
    /**
     *  @private
     */
    public function set requestedMinColumnCount(value:int):void
    {
        if (_requestedMinColumnCount == value)
            return;
        
        _requestedMinColumnCount = value;
        invalidateSize();
    }   
    
    //----------------------------------
    //  requestedColumnCount
    //----------------------------------
    
    private var _requestedColumnCount:int = -1;
    
    [Inspectable(category="General", minValue="-1")]
    
    /**
     *  The measured width of this grid will be large enough to display 
     *  the first <code>requestedColumnCount</code> columns. 
     *  If <code>requestedColumnCount</code> is -1, then the measured
     *  width will be big enough for all of the columns.
     * 
     *  <p>If the actual size of the grid has been explicitly set,
     *  then this property has no effect.</p>
     * 
     *  @default -1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get requestedColumnCount():int
    {
        return _requestedColumnCount;
    }
    
    /**
     *  @private
     */
    public function set requestedColumnCount(value:int):void
    {
        if (_requestedColumnCount == value)
            return;
        
        _requestedColumnCount = value;
        invalidateSize();
    }    
    
    //----------------------------------
    //  requireSelection
    //----------------------------------
    
    /**
     *  If <code>true</code> and the <code>selectionMode</code> is not 
     *  <code>GridSelectionMode.NONE</code>, an item must always be selected 
     *  in the grid.
     *
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get requireSelection():Boolean
    {
        return gridSelection.requireSelection;
    }
    
    /**
     *  @private
     */    
    public function set requireSelection(value:Boolean):void
    {
        gridSelection.requireSelection = value;
        
        if (value)
            invalidateDisplayList();
    }
 
    //----------------------------------
    //  resizableColumns
    //----------------------------------
    
    private var _resizableColumns:Boolean = true;
    
    [Bindable("resizableColumnsChanged")]
    
    /**
     *  A flag that indicates whether the user can change the size of the
     *  columns.
     *  If <code>true</code>, the user can stretch or shrink the columns of 
     *  the DataGrid control by dragging the grid lines between the header cells.
     *  If <code>true</code>, individual columns must also have their 
     *  <code>resizable</code> properties set to <code>false</code> to 
     *  prevent the user from resizing a particular column.  
     *
     *  @default true
     *    
     *  @see spark.components.gridClasses.GridColumn
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get resizableColumns():Boolean
    {
        return _resizableColumns;
    }
    
    /**
     *  @private
     */        
    public function set resizableColumns(value:Boolean):void
    {
        if (value == resizableColumns)
            return;
        
        _resizableColumns = value;        
        dispatchChangeEvent("resizableColumnsChanged");            
    }
    
    //----------------------------------
    //  rowBackground
    //----------------------------------
    
    [Bindable("rowBackgroundChanged")]
    
    private var _rowBackground:IFactory = null;
    
    /**
     *  A visual element that's displayed for each row.  
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get rowBackground():IFactory
    {
        return _rowBackground;
    }
    
    /**
     *  @private
     */
    public function set rowBackground(value:IFactory):void
    {
        if (_rowBackground == value)
            return;
        
        _rowBackground = value;
        invalidateDisplayList();
        dispatchChangeEvent("rowBackgroundChanged");
    }
    
    //----------------------------------
    //  rowHeight
    //----------------------------------
    
    /**
     *  @private
     */
    private var _rowHeight:Number = NaN;      
    
    /**
     *  @private
     */
    private var rowHeightChanged:Boolean;
    
    [Inspectable(category="General", minValue="0.0")]            
    [Bindable("rowBackgroundChanged")]
    
    /**
     *  If <code>variableRowHeight</code> is <code>false</code>, then 
     *  this property specifies the actual height of each row, in pixels.
     * 
     *  <p>If <code>variableRowHeight</code> is <code>true</code>, 
     *  the default, the value of this property is used as the estimated
     *  height for rows that haven't been scrolled into view yet, rather
     *  than the preferred height of renderers configured with the typicalItem.
     *  Similarly, when the Grid pads its display with empty rows, this property
     *  specifies the empty rows' height.</p>
     * 
     *  <p>If <code>variableRowHeight</code> is <code>false</code>, 
     *  the default value of this property is the maximum preferred height
     *  of the per-column renderers created for the typicalItem.</p>
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get rowHeight():Number
    {
        return _rowHeight;
    }
    
    /**
     *  @private
     */
    public function set rowHeight(value:Number):void
    {
        if (_rowHeight == value)
            return;
        
        _rowHeight = value;
        rowHeightChanged = true;        
        invalidateProperties();

        dispatchChangeEvent("rowHeightChanged");            
    }
    
    
    //----------------------------------
    //  rowSeparator
    //----------------------------------
    
    [Bindable("rowSeparatorChanged")]
    
    private var _rowSeparator:IFactory = null;
    
    /**
     *  A visual element that's displayed in between each row.
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get rowSeparator():IFactory
    {
        return _rowSeparator;
    }
    
    /**
     *  @private
     */
    public function set rowSeparator(value:IFactory):void
    {
        if (_rowSeparator == value)
            return;
        
        _rowSeparator = value;
        invalidateDisplayList();
        dispatchChangeEvent("rowSeparatorChanged");
    }    
    
    //----------------------------------
    //  selectedCell
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]

    /**
     *  If <code>selectionMode</code> is <code>GridSelectionMode.SINGLE_CELL</code> 
     *  or <code>GridSelectionMode.MULTIPLE_CELLS</code>, returns the first
     *  selected cell starting at row 0 column 0 and progressing thru each
     *  column in a row before moving to the next row.
     * 
     *  <p>When the user changes the selection by interacting with the 
     *  control, the control dispatches the <code>selectionChange</code> 
     *  event. When the user changes the selection programmatically, the 
     *  control dispatches the <code>valueCommit</code> event.</p>
     * 
     *  <p>Attempts to set this property are deferred until commitProperties()
     *  runs, and the dataProvider property has been set.  This property is not
     *  intended for programatic selection updates, it can be used to initialize the
     *  selection in MXML markup.  The setSelectedCell() method should be used
     *  for programatic selection updates, for example when writing a keyboard
     *  or mouse event handler. </p> 
     *
     *  @default null
     * 
     *  @return CellPosition of the first selected cell or null if there is
     *  no cell selection.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectedCell():CellPosition
    {
        var selectedCells:Vector.<CellPosition> = gridSelection.allCells();
        return selectedCells.length ? selectedCells[0] : null;
    }
    
    /**
     *  @private
     */
    public function set selectedCell(value:CellPosition):void
    {
        const rowIndex:int = (value) ? value.rowIndex : -1;
        const columnIndex:int = (value) ? value.columnIndex : -1;
        
        var f:Function = function():void
        {
            if ((rowIndex != -1) && (columnIndex != -1))
                setSelectedCell(rowIndex, columnIndex);
            else
                clearSelection();
        }
        deferredOperations.push(f);  // function f() to be called by commitProperties()
        invalidateProperties();
    }        
                   
    //----------------------------------
    //  selectedCells
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]

    /**
     *  If <code>selectionMode</code> is <code>GridSelectionMode.SINGLE_CELL</code> 
     *  or <code>GridSelectionMode.MULTIPLE_CELLS</code>, returns a Vector
     *  of CellPosition objects representing the positions of the selected
     *  cells in the grid.
     * 
     *  <p>When the user changes the selection by interacting with the 
     *  control, the control dispatches the <code>selectionChange</code> 
     *  event. When the user changes the selection programmatically, the 
     *  control dispatches the <code>valueCommit</code> event.</p>
     * 
     *  <p>Attempts to set this property are deferred until commitProperties()
     *  runs, and the dataProvider property has been set.  This property is not
     *  intended for programatic selection updates, it can be used to initialize the
     *  selection in MXML markup.  The setSelectedCell(), addSelectedCell(),
     *  and selectCellRegion() methods should be used for programatic selection 
     *  updates, for example when writing a keyboard or mouse event handler. </p>  
     * 
     *  @default An empty Vector.<CellPosition>
     * 
     *  @return Vector of CellPosition objects where each element represents
     *  a selected cell.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectedCells():Vector.<CellPosition>
    {
        return gridSelection.allCells();
    }
    
    /**
     *  @private
     */
    public function set selectedCells(value:Vector.<CellPosition>):void
    {
        // Defensively deep-copy the incoming value; tolerate value=null

        var valueCopy:Vector.<CellPosition> = new Vector.<CellPosition>(0);
        if (value)
        {
            for each (var cell:CellPosition in value)
                valueCopy.push(new CellPosition(cell.rowIndex, cell.columnIndex));
        }
        
        // Append a deferred operation function that selects the specified cells
        
        var f:Function = function():void
        {
            clearSelection();
            for each (cell in valueCopy)
                addSelectedCell(cell.rowIndex, cell.columnIndex);
        }
        deferredOperations.push(f);  // function f() to be called by commitProperties()
        invalidateProperties();
    }          

    //----------------------------------
    //  selectedIndex
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]

    /**
     *  If <code>selectionMode</code> is <code>GridSelectionMode.SINGLE_ROW</code> 
     *  or <code>GridSelectionMode.MULTIPLE_ROWS</code>, returns the
     *  rowIndex of the first selected row. 
     * 
     *  <p>When the user changes the selection by interacting with the 
     *  control, the control dispatches the <code>selectionChange</code> 
     *  event. When the user changes the selection programmatically, the 
     *  control dispatches the <code>valueCommit</code> event.</p>
     * 
     *  <p>Attempts to set this property are deferred until commitProperties()
     *  runs, and the dataProvider property has been set.  This property is not
     *  intended for programatic selection updates, it can be used to initialize the
     *  selection in MXML markup.  The setSelectedIndex() method should be used
     *  for programatic selection updates, for example when writing a keyboard
     *  or mouse event handler. </p>
     *
     *  @default -1
     * 
     *  @return rowIndex of first selected row or -1 if there are no
     *  selected rows.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectedIndex():int
    {
        var selectedRows:Vector.<int> = gridSelection.allRows();
        return (selectedRows.length > 0) ? selectedRows[0] : -1;
    }
    
    /**
     *  @private
     */
    public function set selectedIndex(value:int):void
    {
        var f:Function = function():void
        {
            if (value != -1)
                setSelectedIndex(value);
            else
                clearSelection();
        }
        deferredOperations.push(f);  // function f() to be called by commitProperties()
        invalidateProperties();
    }
    
    //----------------------------------
    //  selectedIndices
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]

    /**
     *  If <code>selectionMode</code> is <code>GridSelectionMode.SINGLE_ROW</code> 
     *  or <code>GridSelectionMode.MULTIPLE_ROWS</code>, returns a Vector of 
     *  the selected rows indices.  For all other selection modes, this 
     *  method has no effect.
     * 
     *  <p>When the user changes the selection by interacting with the 
     *  control, the control dispatches the <code>selectionChange</code> 
     *  event. When the user changes the selection programmatically, the 
     *  control dispatches the <code>valueCommit</code> event.</p>
     * 
     *  <p>Attempts to set this property are deferred until commitProperties()
     *  runs, and the dataProvider property has been set.  This property is not
     *  intended for programatic selection updates, it can be used to initialize the
     *  selection in MXML markup.  The setSelectedIndex(), addSelectedIndex(),
     *  and selectIndices() methods should be used for programatic selection 
     *  updates, for example when writing a keyboard or mouse event handler. </p> 
     *
     *  @default An empty Vector.<int>
     * 
     *  @return Vector of ints where each element is the index in 
     *  <code>dataProvider</code> of the selected row.
     *  
     *  @see spark.components.Grid#dataProvider
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectedIndices():Vector.<int>
    {
        return gridSelection.allRows();
    }
    
    /**
     *  @private
     */
    public function set selectedIndices(value:Vector.<int>):void
    {
        // Defensively copy the incoming value; tolerate value=null
        
        const valueCopy:Vector.<int> = (value) ? value.concat() : new Vector.<int>(0);
        
        // Append a deferred operation function that selects the specified indices            
        
        var f:Function = function():void
        {
            clearSelection();
            for each (var index:int in valueCopy)
                addSelectedIndex(index);
        }
        deferredOperations.push(f);  // function f() to be called by commitProperties()
        invalidateProperties();
    }        
    
    //----------------------------------
    //  selectedItem
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]
    
    /**
     *  If <code>selectionMode</code> is <code>GridSelectionMode.SINGLE_ROW</code> 
     *  or <code>GridSelectionMode.MULTIPLE_ROWS</code>, returns the 
     *  item in the <code>dataProvider</code> that is currently selected or
     *  <code>undefined</code> if no rows are selected.  
     * 
     *  <p>When the user changes the selection by interacting with the 
     *  control, the control dispatches the <code>selectionChange</code> 
     *  event. When the user changes the selection programmatically, the 
     *  control dispatches the <code>valueCommit</code> event.</p>
     * 
     *  <p>Attempts to set this property are deferred until commitProperties()
     *  runs, and the dataProvider property has been set.  This property is not
     *  intended for programatic selection updates, it can be used to initialize the
     *  selection in MXML markup.  To programatically set the "selected item"
     *  use <code>dataProvider.getItemIndex()</code> to compute the item's location
     *  and <code>setSelectedIndex()</code> to change the selection.</p>
     *  
     *  @default undefined
     * 
     *  @return Vector of <code>dataProvider</code> items.
     *  
     *  @see spark.components.Grid#dataProvider
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectedItem():Object
    {
        var rowIndex:int = selectedIndex;
        if (rowIndex == -1)
            return undefined;
        
        return getDataProviderItem(rowIndex);           
    }
    
    /**
     *  @private
     */
    public function set selectedItem(value:Object):void
    {
        var f:Function = function():void
        {
            if (!dataProvider)
                return;

            const rowIndex:int = dataProvider.getItemIndex(value);
            if (rowIndex == -1)
                clearSelection();
            else
                setSelectedIndex(rowIndex);
        }
        deferredOperations.push(f);  // function f() to be called by commitProperties()
        invalidateProperties();
    }        
    
    //----------------------------------
    //  selectedItems
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]

    /**
     *  If <code>selectionMode</code> is <code>GridSelectionMode.SINGLE_ROW</code> 
     *  or <code>GridSelectionMode.MULTIPLE_ROWS</code>, returns a Vector of 
     *  the dataProvider items that are currently selected.
     * 
     *  <p>When the user changes the selection by interacting with the 
     *  control, the control dispatches the <code>selectionChange</code> 
     *  event. When the user changes the selection programmatically, the 
     *  control dispatches the <code>valueCommit</code> event.</p>
     * 
     *  <p>Attempts to set this property are deferred until commitProperties()
     *  runs, and the dataProvider property has been set.  This property is not
     *  intended for programatic selection updates, it can be used to initialize the
     *  selection in MXML markup.  To programatically set the "selected item"
     *  use <code>dataProvider.getItemIndex()</code> to compute the item's location
     *  and <code>setSelectedIndex()</code> to change the selection.</p>
     *  
     *  @default An empty Vector.<Object>
     * 
     *  @return Vector of <code>dataProvider</code> items.
     *  
     *  @see spark.components.Grid#dataProvider
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectedItems():Vector.<Object>
    {
        var rowIndices:Vector.<int> = selectedIndices;
        if (rowIndices.length == 0)
            return undefined;
        
        var items:Vector.<Object> = new Vector.<Object>();
        
        for each (var rowIndex:int in rowIndices)        
            items.push(dataProvider.getItemAt(rowIndex));
       
        return items;
    }
    
    /**
     *  @private
     */
    public function set selectedItems(value:Vector.<Object>):void
    {
        // Defensively copy the incoming value; tolerate value=null
        
        const valueCopy:Vector.<Object> = (value) ? value.concat() : new Vector.<Object>(0);
        
        // Append a deferred operation function that selects the specified indices            
        
        var f:Function = function():void
        {
            if (!dataProvider)
                return;
            
            clearSelection();
            for each (var item:Object in valueCopy)
                addSelectedIndex(dataProvider.getItemIndex(item));
        }
        deferredOperations.push(f);  // function f() to be called by commitProperties()
        invalidateProperties();
    }        
    
    //----------------------------------
    //  selectionIndicator
    //----------------------------------
    
    [Bindable("selectionIndicatorChanged")]
    
    private var _selectionIndicator:IFactory = null;
    
    /**
     *  A visual element that's displayed for each selected row, if
     *  selectionMode is <code>GridSelectionMode.SINGLE_ROW</code> or
     *  <code>GridSelectionMode.MULTIPLE_ROWS</code>, or for each
     *  selected cell, if selectionMode is
     *  <code>GridSelectionMode.SINGLE_CELL</code> or
     *  <code>GridSelectionMode.MULTIPLE_CELLS</code>.
     *  
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get selectionIndicator():IFactory
    {
        return _selectionIndicator;
    }
    
    /**
     *  @private
     */
    public function set selectionIndicator(value:IFactory):void
    {
        if (_selectionIndicator == value)
            return;
        
        _selectionIndicator = value;
        invalidateDisplayList();
        dispatchChangeEvent("selectionIndicatorChanged");
    }    
    
    //----------------------------------
    //  selectionLength (delegates to gridSelection.selectionLength)
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]
    
    /**
     *  If <code>selectionMode</code> is <code>GridSelectionMode.SINGLE_ROW</code>
     *  or <code>GridSelectionMode.MULTIPLE_ROWS</code>, returns the
     *  number of selected rows, and if <code>selectionMode</code> is 
     *  <code>GridSelectionMode.SINGLE_CELLS</code>
     *  or <code>GridSelectionMode.MULTIPLE_CELLS</code>, returns the
     *  number of selected cells.
     * 
     *  @default 0
     * 
     *  @return Number of selected rows or cells.
     *    
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectionLength():int
    {
        return gridSelection.selectionLength;   
    }
    
    //----------------------------------
    //  selectionMode (delegates to gridSelection.selectionMode)
    //----------------------------------
    
    [Bindable("selectionModeChanged")]
    [Inspectable(category="General", enumeration="none,singleRow,multipleRows,singleCell,multipleCells", defaultValue="singleRow")]
    
    /**
     *  The selection mode of the control.  Possible values are:
     *  <code>GridSelectionMode.MULTIPLE_CELLS</code>, 
     *  <code>GridSelectionMode.MULTIPLE_ROWS</code>, 
     *  <code>GridSelectionMode.NONE</code>, 
     *  <code>GridSelectionMode.SINGLE_CELL</code>, and 
     *  <code>GridSelectionMode.SINGLE_ROW</code>.
     * 
     *  <p>Changing the selectionMode causes the current selection to be 
     *  cleared and the caretRowIndex and caretColumnIndex to be set to -1.</p>
     *
     *  @default GridSelectionMode.SINGLE_ROW
     * 
     *  @see spark.components.gridClasses.GridSelectionMode
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectionMode():String
    {
        return gridSelection.selectionMode;
    }
    
    /**
     *  @private
     */
    public function set selectionMode(value:String):void
    {
        if (selectionMode == value)
            return;
        
        gridSelection.selectionMode = value;
        if (selectionMode != value) // value wasn't a valid GridSelectionMode constant
            return;
        
        initializeAnchorPosition();
        if (!requireSelection)
            initializeCaretPosition();
        
        invalidateDisplayList();
        
        dispatchChangeEvent("selectionModeChanged");
    }
    
    
    //----------------------------------
    //  showDataTips
    //----------------------------------
    
    private var _showDataTips:Boolean = false;
    
    [Bindable("showDataTipsChanged")]
    [Inspectable(category="Data", defaultValue="false")]
    
    /**
     *  If true then a dataTip is displayed for all visible cells.  If false (the default),
     *  then a dataTip is only displayed if the column's showDataTips property is true.
     * 
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get showDataTips():Boolean
    {
        return _showDataTips;
    }
    
    /**
     *  @private
     */
    public function set showDataTips(value:Boolean):void
    {
        if (_showDataTips == value)
            return;
        
        _showDataTips = value;

        invalidateDisplayList();
        dispatchEvent(new Event("showDataTipsChanged"));
    }
        
    
    //----------------------------------
    //  typicalItem
    //----------------------------------
    
    /**
     *  @private
     */
    private var _typicalItem:Object = null;

    /**
     *  @private
     */
    private var typicalItemChanged:Boolean = false;
    
    [Bindable("typicalItemChanged")]
    
    /**
     *  The grid's layout ensures that columns whose width is not specified will be wide
     *  enough to display an item renderer for this default dataProvider item.  If a typical
     *  item is not specified, then the first dataProvider item is used.
     * 
     *  <p>Restriction: if the <code>typicalItem</code> is an IVisualItem, it must not 
     *  also be a member of the data Provider.</p>
     * 
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get typicalItem():Object
    {
        return _typicalItem;
    }
    
    /**
     *  @private
     */
    public function set typicalItem(value:Object):void
    {
        if (_typicalItem == value)
            return;
        
        _typicalItem = value;
        
        typicalItemChanged = true;       
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
        
        dispatchChangeEvent("typicalItemChanged");
    }
    
    //----------------------------------
    //  variableRowHeight
    //----------------------------------
    
    /**
     *  @private
     */
    private var _variableRowHeight:Boolean = false;

    /**
     *  @private
     */
    private var variableRowHeightChanged:Boolean = false;
    
    [Bindable("variableRowHeightChanged")]
    
    /**
     *  If true, each row's height is the maximum of preferred heights of the cells displayed so far.
     * 
     *  <p>If <code>false</code>, the height of each row is just the value of <code>rowHeight</code>.
     *  If rowHeight isn't specified, then the height of each row is defined by the typicalItem</p>
     * 
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get variableRowHeight():Boolean
    {
        return _variableRowHeight;
    }
    
    /**
     *  @private
     */        
    public function set variableRowHeight(value:Boolean):void
    {
        if (value == variableRowHeight)
            return;
        
        _variableRowHeight = value;        
        variableRowHeightChanged = true;        
        invalidateProperties();
        
        dispatchChangeEvent("variableRowHeightChanged");            
    }
    
    
    //--------------------------------------------------------------------------
    //
    //  GridSelection Cover Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  If <code>selectionMode</code> is 
     *  <code>GridSelectionMode.MULTIPLE_ROWS</code>, selects all rows and
     *  removes the caret or if <code>selectionMode</code> is 
     *  <code>GridSelectionMode.MULTIPLE_CELLS</code> selects all cells  
     *  and removes the caret.  For all other selection modes, this method 
     *  has no effect.
     *
     *  <p>If items are added to the <code>dataProvider</code> or 
     *  <code>columns</code> are added after this method is called, the
     *  new rows or cells in the new column will be selected.</p>
     * 
     *  <p>This implicit "selectAll" mode ends when any of the following occur:
     *  <ul>
     *    <li>selection is cleared using <code>clearSelection</code></li>
     *    <li>selection reset using one of <code>setSelectedCell</code>, 
     *    <code>setSelectedCells</code>, <code>setSelectedIndex</code>, 
     *    <code>selectIndices</code></li>
     *    <li><code>dataProvider</code> is refreshed and <code>preserveSelection</code> is false</li>
     *    <li><code>dataProvider</code> is reset</li>
     *    <li><code>columns</code> is refreshed, 
     *    <code>preserveSelection</code> is <code>false</code> and 
     *    <code>selectionMode</code> is 
     *    <code>GridSelectionMode.MULTIPLE_CELLS</code></li>
     *    <li><code>columns</code> is reset and <code>selectionMode</code> is 
     *    <code>GridSelectionMode.MULTIPLE_CELLS</code></li> 
     *  </ul></p>
     * 
     *  @return True if the selection changed.
     *    
     *  @see spark.components.Grid#clearSelection
     *  @see spark.components.Grid#selectIndices
     *  @see spark.components.Grid#setSelectedCell
     *  @see spark.components.Grid#setSelectedCells
     *  @see spark.components.Grid#setSelectedIndex
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectAll():Boolean
    {           
        // Need to apply pending dataProvider and column changes so selection
        // isn't reset after it is set here.
        if (invalidatePropertiesFlag)
            UIComponentGlobals.layoutManager.validateClient(this, false);
        
        const selectionChanged:Boolean = gridSelection.selectAll();
        if (selectionChanged)
        {               
            initializeCaretPosition()               
            invalidateDisplayList()
            dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
 
        return selectionChanged;
    }
    
    /**
     *  Removes all of the selected rows and cells, if <code>selectionMode</code>  
     *  is not <code>GridSelectionMode.NONE</code>.  Removes the caret and
     *  sets the anchor to the initial item.
     *
     *  @return True if the selection changed or false if there was nothing
     *  previously selected.
     *    
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function clearSelection():Boolean
    {
        // Need to apply pending dataProvider and column changes so selection
        // isn't reset after it is set here.
        if (invalidatePropertiesFlag)
            UIComponentGlobals.layoutManager.validateClient(this, false);

        const selectionChanged:Boolean = gridSelection.removeAll();
        if (selectionChanged)
        {
            invalidateDisplayList()
            dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
        
        // Remove caret and reset the anchor.
        initializeCaretPosition();
        initializeAnchorPosition();
        
        return selectionChanged;
    }
    
    //----------------------------------
    //  selection for rows
    //----------------------------------    
    
    /**
     *  If <code>selectionMode</code> is <code>GridSelectionMode.SINGLE_ROW</code>
     *  or <code>GridSelectionMode.MULTIPLE_ROWS</code>, returns true if the row 
     *  at <code>index></code> is in the current selection.
     * 
     *  <p>The <code>rowIndex</code> is the index in <code>dataProvider</code> 
     *  of the item containing the selected cell.</p>
     *
     *  @param rowIndex The 0-based row index of the row.
     * 
     *  @return True if the selection contains the row.
     *    
     *  @see spark.components.Grid#dataProvider
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectionContainsIndex(rowIndex:int):Boolean 
    {
        return gridSelection.containsRow(rowIndex);
    }
    
    /**
     *  If <code>selectionMode</code> is 
     *  <code>GridSelectionMode.MULTIPLE_ROWS</code>, returns true if the rows 
     *  in <code>indices</code> are in the current selection.
     * 
     *  @param rowIndices Vector of 0-based row indices to include in selection. 
     * 
     *  @return True if the current selection contains these rows.
     *    
     *  @see spark.components.Grid#dataProvider
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectionContainsIndices(rowIndices:Vector.<int>):Boolean 
    {
        return gridSelection.containsRows(rowIndices);
    }
    
    /**
     *  If <code>selectionMode</code>
     *  is <code>GridSelectionMode.SINGLE_ROW</code> or 
     *  <code>GridSelectionMode.MULTIPLE_ROWS</code>, sets the selection and 
     *  the caret position to this row.
     *  For all other selection modes, this method has no effect.
     * 
     *  <p>The <code>rowIndex</code> is the index in <code>dataProvider</code> 
     *  of the item containing the selected cell.</p>
     *
     *  @param rowIndex The 0-based row index of the cell.
     *
     *  @return True if no errors, or false if <code>index</code> is invalid or
     *  the <code>selectionMode</code> is invalid. 
     *    
     *  @see spark.components.Grid#caretColumnIndex
     *  @see spark.components.Grid#caretRowIndex
     *  @see spark.components.Grid#dataProvider
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function setSelectedIndex(rowIndex:int):Boolean
    {
        // Need to apply pending dataProvider and column changes so selection
        // isn't reset after it is set here.
        if (invalidatePropertiesFlag)
            UIComponentGlobals.layoutManager.validateClient(this, false);
                
        const selectionChanged:Boolean = gridSelection.setRow(rowIndex);
        if (selectionChanged)
        {
            caretRowIndex = rowIndex;
            caretColumnIndex = -1;
            
            invalidateDisplayList()
            dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
        
        return selectionChanged;
    }
    
    /**
     *  If <code>selectionMode</code>
     *  is <code>GridSelectionMode.MULTIPLE_ROWS</code>, adds this row to
     *  the selection and sets the caret position to this row.
     *  For all other selection modes, this method has no effect.
     * 
     *  <p>The <code>rowIndex</code> is the index in <code>dataProvider</code> 
     *  of the item containing the selected cell.</p>
     *
     *  @param rowIndex The 0-based row index of the cell.
     *
     *  @return True if no errors, or false if <code>index</code> is invalid or
     *  the <code>selectionMode</code> is invalid. 
     *    
     *  @see spark.components.Grid#caretColumnIndex
     *  @see spark.components.Grid#caretRowIndex
     *  @see spark.components.Grid#dataProvider
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function addSelectedIndex(rowIndex:int):Boolean
    {
        // Need to apply pending dataProvider and column changes so selection
        // isn't reset after it is set here.
        if (invalidatePropertiesFlag)
            UIComponentGlobals.layoutManager.validateClient(this, false);
                
        const selectionChanged:Boolean = gridSelection.addRow(rowIndex);
        if (selectionChanged)
        {
            caretRowIndex = rowIndex;
            caretColumnIndex = -1;                

            invalidateDisplayList()
            dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
        
        return selectionChanged;
    }
    
    /**
     *  If <code>selectionMode</code>
     *  is <code>GridSelectionMode.SINGLE_ROW</code> or 
     *  <code>GridSelectionMode.MULTIPLE_ROWS</code>, removes this row
     *  from the selection and sets the caret position to this row.
     *  For all other selection modes, this method has no effect.
     * 
     *  <p>The <code>rowIndex</code> is the index in <code>dataProvider</code> 
     *  of the item containing the selected cell.</p>
     *
     *  @param rowIndex The 0-based row index of the cell.
     *
     *  @return True if no errors, or false if <code>index</code> is invalid or
     *  the <code>selectionMode</code> is invalid. 
     *       
     *  @see spark.components.Grid#caretColumnIndex
     *  @see spark.components.Grid#caretRowIndex
     *  @see spark.components.Grid#dataProvider
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function removeSelectedIndex(rowIndex:int):Boolean
    {
        // Need to apply pending dataProvider and column changes so selection
        // isn't reset after it is set here.
        if (invalidatePropertiesFlag)
            UIComponentGlobals.layoutManager.validateClient(this, false);
        
        const selectionChanged:Boolean = gridSelection.removeRow(rowIndex);
        if (selectionChanged)
        {
            caretRowIndex = rowIndex;
            caretColumnIndex = -1;
            
            invalidateDisplayList()
            dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
        
        return selectionChanged;
    }
    
    /**
     *  If <code>selectionMode</code> is <code>GridSelectionMode.MULTIPLE_ROWS</code>,
     *  sets the selection to the specfied rows and the caret position to
     *  <code>endRowIndex</code>.
     *  For all other selection modes, this method has no effect.
     * 
     *  <p>Each index represents an item in <code>dataProvider</code> 
     *  to include in the selection.</p>
     *
     *  @param rowIndex 0-based row index of the first row in the selection.
     *  @param rowCount Number of rows in the selection.
     * 
     *  @return True if no errors, or false if any of the indices are invalid
     *  or <code>startRowIndex</code> is not less than or equal to 
     *  <code>endRowIndex</code> or the <code>selectionMode</code> is invalid. 
     *    
     *  @see spark.components.Grid#dataProvider
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectIndices(rowIndex:int, rowCount:int):Boolean
    {
        // Need to apply pending dataProvider and column changes so selection
        // isn't reset after it is set here.
        if (invalidatePropertiesFlag)
            UIComponentGlobals.layoutManager.validateClient(this, false);
        
        const selectionChanged:Boolean = 
            gridSelection.setRows(rowIndex, rowCount);
        if (selectionChanged)
        {
            caretRowIndex = rowIndex + rowCount - 1;
            caretColumnIndex = -1;
            
            invalidateDisplayList()
            dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
        
        return selectionChanged;
    }

    //----------------------------------
    //  selection for cells
    //----------------------------------    
    
    /**
     *  If <code>selectionMode</code> is <code>GridSelectionMode.SINGLE_CELL</code>
     *  or <code>GridSelectionMode.MULTIPLE_CELLS</code>, returns true if the cell 
     *  is in the current selection.
     * 
     *  <p>The <code>rowIndex</code> must be between 0 and the
     *  length of <code>dataProvider</code>.  The <code>columnIndex</code>
     *  must be between 0 and the length of <code>columns</code>. </p>
     *
     *  @param rowIndex The 0-based row index of the cell.
     *
     *  @param columnIndex The 0-based column index of the cell.
     *  
     *  @return True if the current selection contains the cell.
     * 
     *  @see spark.components.Grid#columns
     *  @see spark.components.Grid#dataProvider
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectionContainsCell(rowIndex:int, columnIndex:int):Boolean
    {
        return gridSelection.containsCell(rowIndex, columnIndex);
    }
    
    /**
     *  If <code>selectionMode</code> is 
     *  <code>GridSelectionMode.MULTIPLE_CELLS</code>, returns true if the cells 
     *  in the cell region are in the current selection.
     * 
     *  <p>The <code>rowIndex</code> must be between 0 and the
     *  length of <code>dataProvider</code>.  The <code>columnIndex</code>
     *  must be between 0 and the length of <code>columns</code>. </p>
     *
     *  @param rowIndex The 0-based row index of the cell.
     *
     *  @param columnIndex The 0-based column index of the cell.
     *  
     *  @param rowCount Number of rows, starting at <code>rowIndex</code> to 
     *  include in the cell region.
     *
     *  @param columnCount Number of columns, starting at 
     *  <code>columnIndex</code> to include in the cell region.
     * 
     *  @return True if the current selection contains all the cells in the cell
     *  region.
     * 
     *  @see spark.components.Grid#columns
     *  @see spark.components.Grid#dataProvider
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectionContainsCellRegion(rowIndex:int, columnIndex:int, 
                                                rowCount:int, columnCount:int):Boolean
    {
        return gridSelection.containsCellRegion(rowIndex, columnIndex, 
            rowCount, columnCount);
    }
    
    /**
     *  If <code>selectionMode</code>
     *  is <code>GridSelectionMode.SINGLE_CELL</code> or 
     *  <code>GridSelectionMode.MULTIPLE_CELLS</code>, sets the selection
     *  and the caret position to this cell.
     *  For all other selection modes, this method has no effect.
     * 
     *  <p>The <code>rowIndex</code> is the index in <code>dataProvider</code> 
     *  of the item containing the selected cell.  The <code>columnIndex</code>
     *  is the index in <code>columns</code> of the column containing the
     *  selected cell.</p>
     *
     *  @param rowIndex The 0-based row index of the cell.
     *
     *  @param columnIndex The 0-based column index of the cell.
     * 
     *  @return True if no errors, or false if <code>rowIndex</code> 
     *  or <code>columnIndex</code> is invalid or the <code>selectionMode</code> 
     *  is invalid.     
     *  
     *  @see spark.components.Grid#caretColumnIndex
     *  @see spark.components.Grid#caretRowIndex
     *  @see spark.components.Grid#columns
     *  @see spark.components.Grid#dataProvider
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function setSelectedCell(rowIndex:int, columnIndex:int):Boolean
    {
        // Need to apply pending dataProvider and column changes so selection
        // isn't reset after it is set here.
        if (invalidatePropertiesFlag)
            UIComponentGlobals.layoutManager.validateClient(this, false);
        
        const selectionChanged:Boolean = gridSelection.setCell(rowIndex, columnIndex);
        if (selectionChanged)
        {
            caretRowIndex = rowIndex;
            caretColumnIndex = columnIndex;
            
            invalidateDisplayList()
            dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
        
        return selectionChanged;
    }
    
    /**
     *  If <code>selectionMode</code>
     *  is <code>GridSelectionMode.SINGLE_CELL</code> or
     *  <code>GridSelectionMode.MULTIPLE_CELLS</code>, adds the cell to
     *  the selection and sets the caret position to the cell.
     *  For all other selection modes, this method has no effect.
     * 
     *  <p>The <code>rowIndex</code> is the index in <code>dataProvider</code> 
     *  of the item containing the selected cell.  The <code>columnIndex</code>
     *  is the index in <code>columns</code> of the column containing the
     *  selected cell.</p>
     *
     *  @param rowIndex The 0-based row index of the cell.
     *
     *  @param columnIndex The 0-based column index of the cell.
     * 
     *  @return True if no errors, or false if <code>rowIndex</code> 
     *  or <code>columnIndex</code> is invalid or the <code>selectionMode</code> 
     *  is invalid.     
     *  
     *  @see spark.components.Grid#caretColumnIndex
     *  @see spark.components.Grid#caretRowIndex
     *  @see spark.components.Grid#columns
     *  @see spark.components.Grid#dataProvider
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function addSelectedCell(rowIndex:int, columnIndex:int):Boolean
    {
        // Need to apply pending dataProvider and column changes so selection
        // isn't reset after it is set here.
        if (invalidatePropertiesFlag)
            UIComponentGlobals.layoutManager.validateClient(this, false);
        
        const selectionChanged:Boolean = gridSelection.addCell(rowIndex, columnIndex);
        if (selectionChanged)
        {
            caretRowIndex = rowIndex;
            caretColumnIndex = columnIndex;
            
            invalidateDisplayList()
            dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
        
        return selectionChanged;
    }
    
    /**
     *  If <code>selectionMode</code>
     *  is <code>GridSelectionMode.SINGLE_CELL</code> or
     *  <code>GridSelectionMode.MULTIPLE_CELLS</code>, removes the cell
     *  from the selection and sets the caret position to the cell.
     *  For all other selection modes, this method has no effect.
     * 
     *  <p>The <code>rowIndex</code> is the index in <code>dataProvider</code> 
     *  of the item containing the selected cell.  The <code>columnIndex</code>
     *  is the index in <code>columns</code> of the column containing the
     *  selected cell.</p>
     *
     *  @param rowIndex The 0-based row index of the cell.
     *
     *  @param columnIndex The 0-based column index of the cell.
     * 
     *  @return True if no errors, or false if <code>rowIndex</code> 
     *  or <code>columnIndex</code> is invalid or the <code>selectionMode</code> 
     *  is invalid.     
     *  
     *  @see spark.components.Grid#caretColumnIndex
     *  @see spark.components.Grid#caretRowIndex
     *  @see spark.components.Grid#columns
     *  @see spark.components.Grid#dataProvider
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function removeSelectedCell(rowIndex:int, columnIndex:int):Boolean
    {
        // Need to apply pending dataProvider and column changes so selection
        // isn't reset after it is set here.
        if (invalidatePropertiesFlag)
            UIComponentGlobals.layoutManager.validateClient(this, false);
        
        const selectionChanged:Boolean = gridSelection.removeCell(rowIndex, columnIndex);
        if (selectionChanged)
        {
            caretRowIndex = rowIndex;
            caretColumnIndex = columnIndex;
            
            invalidateDisplayList()
            dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
        
        return selectionChanged;
    }
    
    /** 
     *  If <code>selectionMode</code> is <code>GridSelectionMode.MULTIPLE_CELLS</code>,
     *  sets the selection to all the cells in the cell region and the
     *  caret position to the last cell in the cell region.
     *  For all other selection modes, this method has no effect.
     * 
     *  <p>The <code>rowIndex</code> is the index in <code>dataProvider</code> 
     *  of the item containing the origin of the cell region.  
     *  The <code>columnIndex</code>
     *  is the index in <code>columns</code> of the column containing the
     *  origin of the cell region.</p>
     *
     *  <p>This method has no effect if the cell region is not wholly
     *  contained within the grid.</p>
     * 
     *  @param rowIndex The 0-based row index of the origin of the cell region.
     *
     *  @param columnIndex The 0-based column index of the origin of the cell 
     *  region.
     *  
     *  @param rowCount Number of rows, starting at <code>rowIndex</code> to 
     *  include in the cell region.
     *
     *  @param columnCount Number of columns, starting at 
     *  <code>columnIndex</code> to include in the cell region.
     * 
     *  @return True if no errors, or false if the cell region is invalid or 
     *  the <code>selectionMode</code> is invalid.     
     *  
     *  @see spark.components.Grid#caretColumnIndex
     *  @see spark.components.Grid#caretRowIndex
     *  @see spark.components.Grid#columns
     *  @see spark.components.Grid#dataProvider
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectCellRegion(rowIndex:int, columnIndex:int, 
                                     rowCount:uint, columnCount:uint):Boolean
    {
        // Need to apply pending dataProvider and column changes so selection
        // isn't reset after it is set here.
        if (invalidatePropertiesFlag)
            UIComponentGlobals.layoutManager.validateClient(this, false);
        
        const selectionChanged:Boolean = gridSelection.setCellRegion(
            rowIndex, columnIndex, 
            rowCount, columnCount);
        if (selectionChanged)
        {
            caretRowIndex = rowIndex + rowCount - 1;
            caretColumnIndex = columnIndex + columnCount - 1;
                
            invalidateDisplayList()
            dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
        
        return selectionChanged;
    }
           
    //--------------------------------------------------------------------------
    //
    //  GridLayout Cover Methods, Properties
    //
    //-------------------------------------------------------------------------- 
    
    /** 
     *  Update the scroll position so that the virtual Grid element at the specified
     *  index is visible.   Note that getScrollPositionDeltaToElement() is only 
     *  approximate when variableRowHeight=true, so calling this method once will
     *  not necessarily scroll far enough to expose the specified element.
     */
    private function scrollToIndex(elementIndex:int, scrollHorizontally:Boolean):void
    {
        var spDelta:Point = gridLayout.getScrollPositionDeltaToElement(elementIndex);
        if (!spDelta)
            return;  // the specified index is no longer valid, punt
        
        if (scrollHorizontally)
            horizontalScrollPosition += spDelta.x;
        verticalScrollPosition += spDelta.y;
    }
    
    /**
     *  If necessary, set the verticalScrollPosition and horizontalScrollPosition 
     *  properties so that the specified cell is completely visible.  If columnIndex
     *  is -1, then just adjust the verticalScrollPosition so that the specified
     *  row is visible.
     * 
     *  @param rowIndex The 0-based row index of the item renderer's cell.
     *  @param columnIndex The 0-based column index of the item renderer's cell, or -1 to specify a row.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function ensureCellIsVisible(rowIndex:int, columnIndex:int = -1):void
    {
        const columns:IList = this.columns;
        
        if (!columns || columnIndex < -1 || columnIndex >= columns.length || 
            !dataProvider || rowIndex < 0 || rowIndex >= dataProvider.length)
            return;
        
        const columnsLength:int = columns.length;
        
        // Make sure either all columns or the specified column is visible.
        if (columnIndex == -1)
            columnIndex = getNextVisibleColumnIndex(-1);
            
        var columnIsVisible:Boolean = (columnIndex != -1) && (GridColumn(columns.getItemAt(columnIndex)).visible);
        if (!columnIsVisible)
            return;

        // A cell's index as defined by LayoutBase it's just its position
        // in the row-major linear ordering of the grid's cells.  
        const elementIndex:int = (rowIndex * columnsLength) + columnIndex;
        const scrollHorizontally:Boolean = columnIndex != -1;
        
        // Iterate until we've scrolled elementIndex at least partially into view.
        do
        {
            scrollToIndex(elementIndex, scrollHorizontally);
            if (variableRowHeight || scrollHorizontally)
                validateNow();
            else
                break;  // fixed row heights, and we're only scrolling vertically
        }
        while(!isCellVisible(rowIndex, columnIndex))
        
        // At this point we've only ensured that the requested cell is at least 
        // partially visible.  Ensure that it's completely visible.
      
        scrollToIndex(elementIndex, scrollHorizontally);
    }        
    
    /**
     *  @copy spark.components.gridClasses.GridLayout#getVisibleRowIndices()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */ 
    public function getVisibleRowIndices():Vector.<int>
    {
        return gridLayout.getVisibleRowIndices();
    }
    
    /**
     *  @copy spark.components.gridClasses.GridLayout#getVisibleColumnIndices()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */ 
    public function getVisibleColumnIndices():Vector.<int>
    {
        return gridLayout.getVisibleColumnIndices();
    }
    
    /**
     *  @copy spark.components.gridClasses.GridLayout#getCellBounds()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */ 
    public function getCellBounds(rowIndex:int, columnIndex:int):Rectangle
    {
        return gridLayout.getCellBounds(rowIndex, columnIndex);
    }
    
    /**
     *  @copy spark.components.gridClasses.GridLayout#getRowBounds()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getRowBounds(rowIndex:int):Rectangle
    {
        return gridLayout.getRowBounds(rowIndex);      
    }
    
    /**
     *  @copy spark.components.gridClasses.GridLayout#getColumnBounds()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getColumnBounds(columnIndex:int):Rectangle
    {
        return gridLayout.getColumnBounds(columnIndex);
    }
    
    /**
     *  @copy spark.components.gridClasses.GridLayout#getRowIndexAt()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getRowIndexAt(x:Number, y:Number):int
    {
        return gridLayout.getRowIndexAt(x, y);
    }
    
    /**
     *  @copy spark.components.gridClasses.GridLayout#getColumnIndexAt()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getColumnIndexAt(x:Number, y:Number):int
    {
        return gridLayout.getColumnIndexAt(x, y); 
    }
    
    /**
     *  Return the width of the specified column.  If the cell's entire bounds
     *  aren't needed, this method is more efficient than <code>getColumnBounds().width</code>.
     * 
     *  <p>If the specified column's width property isn't defined, then the returned value 
     *  may only be an approximation.  The actual column width is only computed after the column
     *  has been scrolled into view.</p>
     * 
     *  @param columnIndex The 0-based index of the column. 
     *  @return The width of the specified column.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getColumnWidth(columnIndex:int):Number
    {
        const column:GridColumn = getGridColumn(columnIndex);
        return (column && !isNaN(column.width)) ? column.width : gridDimensions.getColumnWidth(columnIndex);
    }

    /**
     *  @copy spark.components.gridClasses.GridLayout#getCellAt()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getCellAt(x:Number, y:Number):CellPosition
    {
        return gridLayout.getCellAt(x, y);
    }
    
    /**
     *  @copy spark.components.gridClasses.GridLayout#getCellsAt()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getCellsAt(x:Number, y:Number, w:Number, h:Number):Vector.<CellPosition>
    { 
        return gridLayout.getCellsAt(x, y, w, h);
    }
    
    /**
     *  Return the X coordinate of the specified cell's origin.  If the cell's entire bounds
     *  aren't needed, this method is more efficient than <code>getCellBounds().x</code>.
     * 
     *  <p>If all of the columns for the the specfied row and all of the rows preceeding 
     *  it have not yet been scrolled into view, the returned value may only be an approximation, 
     *  based on all of the columns' <code>typicalItem</code>s.</p>
     * 
     *  @param rowIndex The 0-based index of the row.
     *  @param columnIndex The 0-based index of the column. 
     *  @return The x coordindate of the specified cell's origin.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getCellX(rowIndex:int, columnIndex:int):Number
    { 
        return gridDimensions.getCellX(rowIndex, columnIndex);
    }
    
    /**
     *  Return the Y coordinate of the specified cell's origin.  If the cell's entire bounds
     *  aren't needed, this method is more efficient than <code>getCellBounds().y</code>.
     * 
     *  <p>If all of the columns for the the specfied row and all of the rows preceeding 
     *  it have not yet been scrolled into view, the returned value may only be an approximation, 
     *  based on all of the columns' <code>typicalItem</code>s.</p>
     * 
     *  @param rowIndex The 0-based index of the row.
     *  @param columnIndex The 0-based index of the column. 
     *  @return The y coordindate of the specified cell's origin.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getCellY(rowIndex:int, columnIndex:int):Number
    { 
        return gridDimensions.getCellY(rowIndex, columnIndex);
    }      
    
    
    /**
     *  @copy spark.components.gridClasses.GridLayout#getItemRendererAt()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getItemRendererAt(rowIndex:int, columnIndex:int):IVisualElement
    {
        return gridLayout.getItemRendererAt(rowIndex, columnIndex);
    }
    
    /**
     *  @copy spark.components.gridClasses.GridLayout#isCellVisible()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */        
    public function isCellVisible(rowIndex:int, columnIndex:int = -1):Boolean
    {
        return gridLayout.isCellVisible(rowIndex, columnIndex);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Method Overrides
    //
    //--------------------------------------------------------------------------    
    
    /**
     *  @private
     *  During virtual layout updateDisplayList() eagerly validates lazily
     *  created (or recycled) IRs.   We don't want changes to those IRs to
     *  invalidate the size of the grid.
     */
    override public function invalidateSize():void
    {
        if (!inUpdateDisplayList)
            super.invalidateSize();
    }
    
    /**
     *  @private
     *  During virtual layout updateDisplayList() eagerly validates lazily
     *  created (or recycled) IRs.  Calls to invalidateDisplayList() eventually
     *  short-circuit but doing so early saves a few percent.
     */
    override public function invalidateDisplayList():void
    {
        if (!inUpdateDisplayList)
            super.invalidateDisplayList();
    }
    
    /**
     *  Used to create a default value for the layers property in commitProperties below.
     */
    private function createLayer(id:String):GridLayer
    {
        const layer:GridLayer = new GridLayer();
        layer.id = id;
        if (id == "rendererLayer")
            layer.root = this;
        return layer;
    }

    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        // Create a default layers vector if necessary
        if (_layers == null)
        {
            layers = new <GridLayer> [
                createLayer("backgroundLayer"), 
                createLayer("selectionLayer"), 
                createLayer("rendererLayer"),
                createLayer("overlayLayer")]
        }
                
        // rowHeight and variableRowHeight can be set in either order
        if (variableRowHeightChanged || rowHeightChanged)
        {
            if (rowHeightChanged)
                gridDimensions.defaultRowHeight = _rowHeight;
            gridDimensions.variableRowHeight = variableRowHeight;
            
            if ((!variableRowHeight && rowHeightChanged) || variableRowHeightChanged)
            {
                clearGridLayoutCache(false);
                invalidateSize();
                invalidateDisplayList();
            }
            
            rowHeightChanged = false;
            variableRowHeightChanged = false;
        }

        // item renderer changed or typical item changed
        if (itemRendererChanged || typicalItemChanged)
        {
            clearGridLayoutCache(true);
            itemRendererChanged = false;
        }
        
        // Try to generate columns if there aren't any or there are generated
        // ones which need to be regenerated because the typicalItem or 
        // dataProvider changed.
        if (!columns || (generatedColumns && 
            (typicalItemChanged || (!typicalItem && dataProviderChanged))))
        {
            const oldColumns:IList = columns;
            columns = generateColumns();
            generatedColumns = (columns != null);
            columnsChanged = columns != oldColumns;
        }
        typicalItemChanged = false;
        
        // If the dataProvider or columns change, reset the selection and 
        // the grid dimensions.  This has to be done here rather than in the 
        // setters because the gridSelection and gridDimensions might not 
        // be set yet, depending on the order they are initialized when the 
        // grid skin part is added to the data grid.
        
        if (dataProviderChanged || columnsChanged)
        {
            // Remove the current selection and, if requireSelection, make
            // sure the selection is reset to row 0 or cell 0,0.
            if (gridSelection)
            {
                var savedRequireSelection:Boolean = gridSelection.requireSelection;
                gridSelection.requireSelection = false;
                gridSelection.removeAll();
                gridSelection.requireSelection = savedRequireSelection;
            }

           // make sure we have the right number of columns.
           gridDimensions.columnCount = _columns ? _columns.length : 0;
           clearGridLayoutCache(columnsChanged);
            
            if (!caretChanged)
                initializeCaretPosition();

            if (!anchorChanged)
                initializeAnchorPosition();
            
            dataProviderChanged = false;
            columnsChanged = false;
        }
        anchorChanged = false;
        
        // Deferred selection operations
        
        if (dataProvider)
        {
            for each (var deferredOperation:Function in deferredOperations)
                deferredOperation();
            deferredOperations.length = 0;                
        }
        
        // Only want one event if both caretRowIndex and caretColumnIndex
        // changed.
        if (caretChanged)
        {
            // Validate values now.  Need to let caret be set in the same
            // update as the dp and/or columns.  -1 is a valid value.
            if (_dataProvider && caretRowIndex >= _dataProvider.length)
                caretRowIndex = _dataProvider.length - 1;
            if (_columns && caretColumnIndex >= _columns.length)
                caretColumnIndex =  _columns.length - 1;
            dispatchCaretChangeEvent();
            caretChanged = false;
        }
    }
    
    /**
     *  @private
     */
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
    
    /**
     *  @private
     */
    private function getGridColumn(columnIndex:int):GridColumn
    {
        const columns:IList = columns;
        if ((columns == null) || (columnIndex < 0) || (columnIndex >= columns.length))
            return null;
        
        return columns.getItemAt(columnIndex) as GridColumn;
    }
    
    /**
     *  @private
     */
    mx_internal function getDataProviderItem(rowIndex:int):Object
    {
        const dataProvider:IList = dataProvider;
        if ((dataProvider == null) || (rowIndex >= dataProvider.length))
            return null;
        
        return dataProvider.getItemAt(rowIndex);
    }
    
    /**
     *  @private
     */
    mx_internal function getDataProviderItemIndex(item:Object):int
    {
        const dataProvider:IList = dataProvider;
        if ((dataProvider == null))
            return -1;
        
        return dataProvider.getItemIndex(item);
    }
    
    /**
     *  @private
     */
    private function getVisibleItemRenderer(rowIndex:int, columnIndex:int):IGridItemRenderer
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
    private var mouseDownRowIndex:int = -1;
    private var mouseDownColumnIndex:int = -1;
    
    /**
     *  This method is called when a MOUSE_DOWN event occurs within the grid and 
     *  for all subsequent MOUSE_MOVE events until the button is released (even if the 
     *  mouse leaves the grid).  The last event in such a "down drag up" gesture is 
     *  always a MOUSE_UP.  By default this method dispatches GRID_MOUSE_DOWN, 
     *  GRID_MOUSE_DRAG, or a GRID_MOUSE_UP event in response to the the corresponding
     *  mouse event.  The GridEvent's rowIndex, columnIndex, column, item, and itemRenderer 
     *  properties correspond to the grid cell under the mouse.  
     * 
     *  @param event A MOUSE_DOWN, MOUSE_MOVE, or MOUSE_UP MouseEvent from a down/move/up gesture initiated within the grid.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */    
    protected function grid_mouseDownDragUpHandler(event:MouseEvent):void
    {
        const eventStageXY:Point = new Point(event.stageX, event.stageY);
        const eventGridXY:Point = globalToLocal(eventStageXY);
        const gridDimensions:GridDimensions = GridLayout(layout).gridDimensions;
        const eventRowIndex:int = gridDimensions.getRowIndexAt(eventGridXY.x, eventGridXY.y);
        const eventColumnIndex:int = gridDimensions.getColumnIndexAt(eventGridXY.x, eventGridXY.y);
        
        var gridEventType:String;
        switch(event.type)
        {
            case MouseEvent.MOUSE_MOVE: 
                gridEventType = GridEvent.GRID_MOUSE_DRAG; 
                break;
            case MouseEvent.MOUSE_UP: 
                gridEventType = GridEvent.GRID_MOUSE_UP;
                break;
            case MouseEvent.MOUSE_DOWN: 
                gridEventType = GridEvent.GRID_MOUSE_DOWN;
                mouseDownRowIndex = eventRowIndex;
                mouseDownColumnIndex = eventColumnIndex;
                dragInProgress = true;
                break;
        }
        
        dispatchGridEvent(event, gridEventType, eventGridXY, eventRowIndex, eventColumnIndex);        
    }
    
    /**
     *  This method is called whenever a MOUSE_MOVE event occurs within the grid
     *  without the button pressed.  By default it dispatches a GRID_ROLL_OVER for the
     *  first MOUSE_MOVE GridEvent whose location is within a grid cell, and a 
     *  GRID_ROLL_OUT GridEvent when the mouse leaves a cell.  Listeners are guaranteed
     *  to receive a GRID_ROLL_OUT event for every GRID_ROLL_OVER event.
     * 
     *  @param event A MOUSE_MOVE MouseEvent within the grid, without the button pressed.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */    
    protected function grid_mouseMoveHandler(event:MouseEvent):void
    {
        const eventStageXY:Point = new Point(event.stageX, event.stageY);
        const eventGridXY:Point = globalToLocal(eventStageXY);
        const gridDimensions:GridDimensions = GridLayout(layout).gridDimensions;
        const eventRowIndex:int = gridDimensions.getRowIndexAt(eventGridXY.x, eventGridXY.y);
        const eventColumnIndex:int = gridDimensions.getColumnIndexAt(eventGridXY.x, eventGridXY.y);
                    
        if ((eventRowIndex != rollRowIndex) || (eventColumnIndex != rollColumnIndex))
        {
            if ((rollRowIndex != -1) || (rollColumnIndex != -1))
                dispatchGridEvent(event, GridEvent.GRID_ROLL_OUT, eventGridXY, rollRowIndex, rollColumnIndex);
            if ((eventRowIndex != -1) && (eventColumnIndex != -1))
                dispatchGridEvent(event, GridEvent.GRID_ROLL_OVER, eventGridXY, eventRowIndex, eventColumnIndex);
            rollRowIndex = eventRowIndex;
            rollColumnIndex = eventColumnIndex;
        }
    }
    
    /**
     *  This method is called whenever a ROLL_OUT occurs on the grid.
     *  By default it dispatches a GRID_ROLL_OUT event.
     * 
     *  @param event A ROLL_OUT MouseEvent from the grid.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */       
    protected function grid_mouseRollOutHandler(event:MouseEvent):void
    {
        // Handle the case where the mouse up happens outside the data grid.
        dragInProgress = false
            
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
     *  This method is called whenever a GRID_MOUSE_UP occurs on the grid.
     *  By default it dispatches a GRID_MOUSE_UP event.
     * 
     *  @param event A GRID_MOUSE_UP MouseEvent from the grid.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */       
    protected function grid_mouseUpHandler(event:MouseEvent):void 
    {
        // If in a drag, the drag handler already dispatched a mouse up
        // event so don't do it again here.
        if (dragInProgress)
        {
            dragInProgress = false;
            return;
        }
        
        const eventStageXY:Point = new Point(event.stageX, event.stageY);
        const eventGridXY:Point = globalToLocal(eventStageXY);
        const gridDimensions:GridDimensions = GridLayout(layout).gridDimensions;
        const eventRowIndex:int = gridDimensions.getRowIndexAt(eventGridXY.x, eventGridXY.y);
        const eventColumnIndex:int = gridDimensions.getColumnIndexAt(eventGridXY.x, eventGridXY.y);
        
        dispatchGridEvent(event, GridEvent.GRID_MOUSE_UP, eventGridXY, eventRowIndex, eventColumnIndex);
    }

    /**
     *  This method is called whenever a CLICK MouseEvent occurs on the grid if both
     *  the corresponding down and up events occur within the same grid cell.
     *  By default it dispatches a GRID_CLICK event.
     * 
     *  @param event A CLICK MouseEvent from the grid.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */       
    protected function grid_clickHandler(event:MouseEvent):void 
    {
        const eventStageXY:Point = new Point(event.stageX, event.stageY);
        const eventGridXY:Point = globalToLocal(eventStageXY);
        const gridDimensions:GridDimensions = GridLayout(layout).gridDimensions;
        const eventRowIndex:int = gridDimensions.getRowIndexAt(eventGridXY.x, eventGridXY.y);
        const eventColumnIndex:int = gridDimensions.getColumnIndexAt(eventGridXY.x, eventGridXY.y);
        
        if ((eventRowIndex == mouseDownRowIndex) && (eventColumnIndex == mouseDownColumnIndex)) 
            dispatchGridEvent(event, GridEvent.GRID_CLICK, eventGridXY, eventRowIndex, eventColumnIndex);
    }
    
    /**
     *  This method is called whenever a DOUBLE_CLICK MouseEvent occurs on the grid
     *  if the corresponding sequence of down and up events occur within the same grid cell.
     *  By default it dispatches a GRID_DOUBLE_CLICK event.
     * 
     *  @param event A DOUBLE_CLICK MouseEvent from the grid.
     * 
     *  @see flash.display.InteractiveObject#doubleClickEnabled    
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */       
    protected function grid_doubleClickHandler(event:MouseEvent):void 
    {
        const eventStageXY:Point = new Point(event.stageX, event.stageY);
        const eventGridXY:Point = globalToLocal(eventStageXY);
        const gridDimensions:GridDimensions = GridLayout(layout).gridDimensions;
        const eventRowIndex:int = gridDimensions.getRowIndexAt(eventGridXY.x, eventGridXY.y);
        const eventColumnIndex:int = gridDimensions.getColumnIndexAt(eventGridXY.x, eventGridXY.y);
        
        // This isn't stricly adequate, since the mouse might have been on a different cell for 
        // the first click.  It's not clear that the extra checking would be worthwhile.
        
        if ((eventRowIndex == mouseDownRowIndex) && (eventColumnIndex == mouseDownColumnIndex)) 
            dispatchGridEvent(event, GridEvent.GRID_DOUBLE_CLICK, eventGridXY, eventRowIndex, eventColumnIndex);            
    }    
    
    /**
     *  @private
     */
    private function dispatchGridEvent(mouseEvent:MouseEvent, type:String, gridXY:Point, rowIndex:int, columnIndex:int):void
    {
        const column:GridColumn = columnIndex >= 0 ? getGridColumn(columnIndex) : null;
        const item:Object = rowIndex >= 0 ? getDataProviderItem(rowIndex) : null;
        const itemRenderer:IGridItemRenderer = getVisibleItemRenderer(rowIndex, columnIndex);
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
            gridXY.x, gridXY.y, rowIndex, columnIndex, column, item, itemRenderer, 
            relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
        dispatchEvent(event);
    }
        
    //--------------------------------------------------------------------------
    //
    //  IList listeners: columns, dataProvider
    //
    //--------------------------------------------------------------------------  

    /**
     *  @private
     *  Update caretRowIndex if necessary.  This method should only be called when 
     *  caretRowIndex is valid, i.e. != -1.
     */
    private function updateCaretForDataProviderChange(event:CollectionEvent):void
    {
        const oldCaretRowIndex:int = caretRowIndex;
        const location:int = event.location;
        var itemsLength:int;

        // this should stay in sync with updateCaretForColumnsChange
        switch (event.kind)
        {
            case CollectionEventKind.ADD:
                if (oldCaretRowIndex >= location)
                    caretRowIndex += event.items.length;
                break;
           
            case CollectionEventKind.REMOVE:
                if (oldCaretRowIndex >= location)
                {
                    itemsLength = event.items.length;
                    if (oldCaretRowIndex < (location + itemsLength))
                        caretRowIndex = _dataProvider.length > 0 ? 0 : -1; 
                    else
                        caretRowIndex -= itemsLength;    
                }
                
                break;
            
            case CollectionEventKind.MOVE:
                {
                    const oldLocation:int = event.oldLocation;
                    itemsLength = event.items.length;
                    if ((oldCaretRowIndex >= oldLocation) && (oldCaretRowIndex < (oldLocation + itemsLength)))
                        caretRowIndex += location - oldLocation;
                }
                break;                        
                
            case CollectionEventKind.REPLACE:
            case CollectionEventKind.UPDATE:
                break;
            
            case CollectionEventKind.REFRESH:
            case CollectionEventKind.RESET:
                initializeCaretPosition();
                horizontalScrollPosition = 0;
                verticalScrollPosition = 0;
                break;
        }            
    }
    
    /**
     *  @private
     *  Update caretColumnIndex if necessary.  This method should only be 
     *  called when caretColumnIndex is valid, i.e. != -1.
     */
    private function updateCaretForColumnsChange(event:CollectionEvent):void
    {
        const oldCaretColumnIndex:int = caretColumnIndex;
        const location:int = event.location;
        var itemsLength:int;
        
        // this should stay in sync with updateCaretForDataProviderChange
        
        switch (event.kind)
        {
            case CollectionEventKind.ADD:
                if (oldCaretColumnIndex >= location)
                    caretColumnIndex += event.items.length;
                break;
            
            case CollectionEventKind.REMOVE:
                if (oldCaretColumnIndex >= location)
                {
                    itemsLength = event.items.length;
                    if (oldCaretColumnIndex < (location + itemsLength))
                        caretColumnIndex = _columns.length > 0 ? 0 : -1; 
                    else
                        caretColumnIndex -= itemsLength;    
                }                   
                break;
            
            case CollectionEventKind.MOVE:
                const oldLocation:int = event.oldLocation;
                itemsLength = event.items.length;
                if ((oldCaretColumnIndex >= oldLocation) && (oldCaretColumnIndex < (oldLocation + itemsLength)))
                    caretColumnIndex += location - oldLocation;
                break;                        
            
            case CollectionEventKind.REPLACE:
            case CollectionEventKind.UPDATE:
                break;
            
            case CollectionEventKind.REFRESH:
            case CollectionEventKind.RESET:
                initializeCaretPosition();
                horizontalScrollPosition = 0;
                verticalScrollPosition = 0;
                break;
        }            
    }


    /**
     *  @private
     *  Update hoverRowIndex if necessary.  This method should only be called when 
     *  hoverRowIndex is valid, i.e. != -1.
     */
    private function updateHoverForDataProviderChange(event:CollectionEvent):void
    {
        const oldHoverRowIndex:int = hoverRowIndex;
        const location:int = event.location;
        
        switch (event.kind)
        {
            case CollectionEventKind.ADD:
            case CollectionEventKind.REMOVE:
            case CollectionEventKind.REPLACE:
            case CollectionEventKind.UPDATE:
            case CollectionEventKind.MOVE:
                if (oldHoverRowIndex >= location)
                    hoverRowIndex = gridDimensions.getRowIndexAt(mouseX, mouseY);
                break;
                           
            case CollectionEventKind.REFRESH:
            case CollectionEventKind.RESET:
                hoverRowIndex = gridDimensions.getRowIndexAt(mouseX, mouseY);
                break;
        }                        
    }
    
    /**
     *  @private
     *  Update hoverColumnIndex if necessary.  This method should only be called when 
     *  hoverColumnIndex is valid, i.e. != -1.
     */
    private function updateHoverForColumnsChange(event:CollectionEvent):void
    {
        switch (event.kind)
        {
            case CollectionEventKind.ADD:
            case CollectionEventKind.REMOVE:
            case CollectionEventKind.REPLACE:
            case CollectionEventKind.UPDATE:
            case CollectionEventKind.MOVE:
                if (hoverColumnIndex >= event.location)
                    hoverColumnIndex = gridDimensions.getColumnIndexAt(mouseX, mouseY);
                break;
                            
            case CollectionEventKind.REFRESH:
            case CollectionEventKind.RESET:
                hoverColumnIndex = gridDimensions.getColumnIndexAt(mouseX, mouseY);
                break;
        }                        
    }

    /**
     *  @private
     */
    private function dataProvider_collectionChangeHandler(event:CollectionEvent):void
    {
        if (gridDimensions)
            gridDimensions.dataProviderCollectionChanged(event);
        
        if (gridLayout)
            gridLayout.dataProviderCollectionChanged(event);
        
        if (gridSelection)
            gridSelection.dataProviderCollectionChanged(event);
            
        // ToDo:  do we need to do any scrolling to keep either the hover
        // indicator or the caret indicator visible?
        
        if (caretRowIndex != -1)
            updateCaretForDataProviderChange(event);
        
        if (gridDimensions && hoverRowIndex != -1)
            updateHoverForDataProviderChange(event);    

        invalidateSize();
        invalidateDisplayList();
    }
    
    /**
     *  @private
     */
    private function columns_collectionChangeHandler(event:CollectionEvent):void
    {
        // TBD - need to double-check all of these and perhaps move it elsewhere
        
        var column:GridColumn;
        var columnIndex:int = event.location;
        var i:int;
        
        switch (event.kind)
        {
            case CollectionEventKind.ADD: 
            {
                // Note: multiple columns may be added.
                while (columnIndex < columns.length)
                {
                    column = GridColumn(columns.getItemAt(columnIndex));
                    column.setGrid(this);
                    column.setColumnIndex(columnIndex);
                    columnIndex++;
                }                  
                break;
            }
                
            case CollectionEventKind.MOVE:
            {
                // All columns between the old and new locations need to 
                // have their index updated.
                columnIndex = Math.min(event.oldLocation, event.location);
                var maxIndex:int = Math.max(event.oldLocation, event.location);
                while (columnIndex <= maxIndex)
                {
                    column = GridColumn(columns.getItemAt(columnIndex));
                    column.setColumnIndex(columnIndex);
                    columnIndex++;
                }                
                break;
            }
                
            case CollectionEventKind.REPLACE:
            {
                var items:Array = event.items;                   
                var length:int = items.length;
                for (i = 0; i < length; i++)
                {
                    if (items[i].oldValue is GridColumn)
                    {
                        column = GridColumn(items[i].oldValue);
                        column.setGrid(null);
                        column.setColumnIndex(-1);
                    }
                    if (items[i].newValue is GridColumn)
                    {
                        column = GridColumn(items[i].newValue);
                        column.setGrid(this);
                        column.setColumnIndex(columnIndex);
                    }
                }
                break;
            }
                
            case CollectionEventKind.UPDATE:
            {
                // column may have changed visiblity                
                const itemsLength:int = event.items.length;
                var itemsLeft:int = itemsLength;
                var pcEvent:PropertyChangeEvent;
                
                for (i = 0; i < itemsLength; i++)
                {
                    pcEvent = event.items[i] as PropertyChangeEvent;
                    if (pcEvent && pcEvent.property == "visible")
                    {
                        columns_visibleChangedHandler(pcEvent);
                        itemsLeft--;
                    }
                }
                
                // return if all were visible property changes
                if (itemsLeft == 0)
                    return;
                
                break;
            }
                
            case CollectionEventKind.REFRESH:
            {
                for (columnIndex = 0; columnIndex < columns.length; columnIndex++)
                {
                    column = GridColumn(columns.getItemAt(columnIndex));
                    column.setColumnIndex(columnIndex);
                }                
                break;
            }
                
            case CollectionEventKind.REMOVE:
            {
                // Note: multiple columns may be removed.
                var count:int = event.items.length;
                
                for (i = 0; i < count; i++)
                {
                    column = GridColumn(event.items[i]);
                    column.setGrid(null);
                    column.setColumnIndex(-1);
                }
                
                // Renumber the columns which follow the removed columns.
                while (columnIndex < columns.length)
                {
                    column = GridColumn(columns.getItemAt(columnIndex));
                    column.setColumnIndex(columnIndex);
                    columnIndex++;
                }                  
                
                break;
            }
                
            case CollectionEventKind.RESET:
            {
                for (columnIndex = 0; columnIndex < columns.length; columnIndex++)
                {
                    column = GridColumn(columns.getItemAt(columnIndex));
                    column.setGrid(this);
                    column.setColumnIndex(columnIndex);
                }                     
                break;
            }                                
        }

        gridDimensions.columnsCollectionChanged(event);
        if (dataProvider)
            gridDimensions.rowCount = dataProvider.length;
        
        if (gridLayout)
            gridLayout.columnsCollectionChanged(event);
        
        if (gridSelection)
            gridSelection.columnsCollectionChanged(event);
        
        if (caretColumnIndex != -1)
            updateCaretForColumnsChange(event);                
        
        if (gridDimensions && hoverColumnIndex != -1)
            updateHoverForColumnsChange(event); 

        invalidateSize();
        invalidateDisplayList();        
    } 
    
    /**
     *  @private
     */
    private function columns_visibleChangedHandler(event:PropertyChangeEvent):void
    {
        const column:GridColumn = event.source as GridColumn;
        const columnIndex:int = columns.getItemIndex(column);
        if (!column || columnIndex == -1)
            return;
        
        // Fix up gridDimensions
        if (gridDimensions)
        {
            gridDimensions.clearColumns(columnIndex, 1);
            
            // column.visible==true columns need to have their typical sizes and 
            // actual column width updated, while column.visible==false column
            // have their typical sizes updated to 0 and actual column width
            // set to NaN.
            if (column.visible)
            {
                gridDimensions.setTypicalCellWidth(columnIndex, NaN);
                gridDimensions.setTypicalCellHeight(columnIndex, NaN);
                if (!isNaN(column.width))
                    gridDimensions.setColumnWidth(columnIndex, column.width);
            }
            else
            {
                gridDimensions.setTypicalCellWidth(columnIndex, 0);
                gridDimensions.setTypicalCellHeight(columnIndex, 0);
                gridDimensions.setColumnWidth(columnIndex, NaN);
            }
        }
        
        // Clear out gridLayout
        gridLayout.clearVirtualLayoutCache();
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------  
    
    /**
     *  @private
     *  Clears the layout's renderers and cached sizes. Also clears
     *  the typical item's size if clearTypicalSizes is true.
     */
    mx_internal function clearGridLayoutCache(clearTypicalSizes:Boolean):void
    {
        gridLayout.clearVirtualLayoutCache();
        
        if (gridDimensions)
        {
            if (clearTypicalSizes)
                gridDimensions.clearTypicalCellWidthsAndHeights();
            
            gridDimensions.clear();
            
            // clearing the gridDimensions resets rowCount
            gridDimensions.rowCount = _dataProvider ? _dataProvider.length : 0;
        }
        
        // Reset content size so scroller's viewport can be resized.  There
        // is loop-prevention logic in the scroller which may not allow the
        // width/height to be reduced if there are automatic scrollbars.
        // See ScrollerLayout/measure().
        setContentSize(0, 0);
    }
    
    /**
     *  Returns the index of the next GridColumn.visible==true column
     *  after index.
     *  Returns -1 if there are no more visible columns.
     *  To find the first GridColumn.visible==true column index, use
     *  getNextVisibleColumnIndex(-1).
     */
    mx_internal function getNextVisibleColumnIndex(index:int):int
    {
        if (index < -1)
            return -1;
        
        const columns:IList = this.columns;
        const columnsLength:int = (columns) ? columns.length : 0;
                
        for (var i:int = index + 1; i < columnsLength; i++)
        {
            var column:GridColumn = columns.getItemAt(i) as GridColumn;
            if (column && column.visible)
                return i;
        }
        
        return -1;
    }
    
    /**
     *  Returns the index of the previous GridColumn.visible==true column
     *  before index.
     *  Returns -1 if there are no more visible columns.
     *  To find the last GridColumn.visible==true column index, use
     *  getPreviousVisibleColumnIndex(columns.length).
     */
    mx_internal function getPreviousVisibleColumnIndex(index:int):int
    {
        const columns:IList = this.columns;
        if (!columns || index > columns.length)
            return -1;
        
        for (var i:int = index - 1; i >= 0; i--)
        {
            var column:GridColumn = columns.getItemAt(i) as GridColumn;
            if (column && column.visible)
                return i;
        }
        
        return -1;
    }
    
    /**
     *  @private
     */
    private function initializeAnchorPosition():void
    {
        anchorRowIndex = 0; 
        anchorColumnIndex = 0; 
    }
    
    /**
     *  @private
     */
    private function initializeCaretPosition():void
    {
        caretRowIndex = _dataProvider && _dataProvider.length > 0 ? 0 : -1; 
        caretColumnIndex = _columns && _columns.length > 0 ? 0 : -1; 
    }
    
    /**
     *  @private
     *  The caret change has already been comitted.  Dispatch the "caretChange"
     *  event.
     */
    private function dispatchCaretChangeEvent():void
    {
        if (hasEventListener(GridCaretEvent.CARET_CHANGE))
        {
            const caretChangeEvent:GridCaretEvent = 
                new GridCaretEvent(GridCaretEvent.CARET_CHANGE);
            caretChangeEvent.oldRowIndex = _oldCaretRowIndex;
            caretChangeEvent.oldColumnIndex = _oldCaretColumnIndex;
            caretChangeEvent.newRowIndex = _caretRowIndex;
            caretChangeEvent.newColumnIndex = _caretColumnIndex;
            dispatchEvent(caretChangeEvent);
        }
    }
}
}
