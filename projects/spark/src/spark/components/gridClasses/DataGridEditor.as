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

/**
 *  The DataGridEditor contains all the logic and event handling needed to 
 *  manage the life cycle of an item editor. A DataGridEditor is owned by a 
 *  specified DataGrid. The owning DataGrid is responsible for calling
 *  initialize() to enable editing and uninitialize() when editing is no 
 *  longer needed.
 * 
 */
package spark.components.gridClasses
{
import flash.display.DisplayObjectContainer;
import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.ui.Keyboard;
import flash.utils.describeType;
import flash.utils.Timer;

import mx.core.ClassFactory;
import mx.core.EventPriority;
import mx.core.IFactory;
import mx.core.IFlexModuleFactory;
import mx.core.IInvalidating;
import mx.core.IIMESupport;
import mx.core.IUIComponent;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.SandboxMouseEvent;
import mx.managers.FocusManager;
import mx.managers.IFocusManager;
import mx.managers.IFocusManagerComponent;
import mx.styles.ISimpleStyleClient;
import mx.styles.IStyleClient;
import mx.utils.StringUtil;

import spark.components.supportClasses.CellPosition;
import spark.components.supportClasses.GridColumn;
import spark.components.IGridItemEditor;
import spark.components.DataGrid;
import spark.components.Grid;
import spark.components.Group;
import spark.components.IGridItemRenderer;
import spark.events.GridEvent;
import spark.events.GridItemEditorEvent;
import flash.debugger.enterDebugger;

use namespace mx_internal;

[ExcludeClass]

//--------------------------------------------------------------------------
//
//  Constructor
//
//--------------------------------------------------------------------------

/**
 *  Constructor
 * 
 *  @param dataGrid The owner of this editor.
 */
public class DataGridEditor
{
    include "../../core/Version.as";    

    public function DataGridEditor(dataGrid:DataGrid)
    {
        _dataGrid = dataGrid;
        
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    /**
     *  @private
     *  Timer used to cancel edits it a double click occurs.
     */
    private var doubleClickTimer:Timer;
    
    /**
     *  @private
     *  True if we have received double click event since the last click.
     */
    private var gotDoubleClickEvent:Boolean;

    /**
     *  @private
     *  True if we have received a FlexEvent.ENTER.
     */
    private var gotFlexEnterEvent:Boolean;
    
    /**
     *  @private
     *  The state of the grid selection at the last selection snapshot. Used in 
     *  row selection mode.
     */
    private var previouslySelectedIndices:Vector.<int>;
    
    /**
     *  @private
     *  The state of the grid selection at the last selection snapshot. Used in
     *  cell selection mode.
     * 
     */
    private var previouslySelectedCells:Vector.<CellPosition>;
   
    /**
     *  @private
     */
    private var lastEvent:Event;

    /**
     *  @private
     *  Position of the last item renderer that was clicked.
     */
    private var lastItemClickedPosition:Object;
    
    /**
     *  @private
     *  Used to make sure the mouse up is on the same item
     *  renderer as the mouse down.
     */
    private var lastItemDown:IVisualElement;
    
    /**
     *  @private
     *  the last editedItemPosition and the last
     *  position where editing was attempted if editing
     *  was cancelled.  We restore editing
     *  to this point if we get focus from the TAB key
     */
    private var lastEditedItemPosition:*;
    
    /**
     *  @private
     *  Used to restore the value of DataGrid's hasFocusableChildren.
     */
    private var saveDataGridHasFocusableChildren:Boolean;
    
    /**
     *  @private
     *  Used to restore the value of scroller's hasFocusableChildren.
     */
    private var saveScrollerHasFocusableChildren:Boolean;

    /**
     *  @private
     *  true if a new editor is planned to be started
     *  after the current editor is closed. This hint can keep us from doing
     *  work when closing the editor that would just need to be redone shortly.
     */
    private var willStartNewEditor:Boolean;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var _dataGrid:DataGrid;

    /**
     *  @private
     *  The data grid that owns this editor.
     */
    public function get dataGrid():DataGrid
    {
        return _dataGrid;    
    }
    
    /**
     *  @private
     *  Convenience property to get the grid.
     */
    public function get grid():Grid
    {
        return _dataGrid.grid;        
    }

    //----------------------------------
    //  editedItemPosition
    //----------------------------------
    
    /**
     *  @private
     */
    private var _editedItemPosition:Object;
    
    /**
     *  The column and row index of the item renderer for the
     *  data provider item being edited, if any.
     *
     *  <p>This Object has two fields, <code>columnIndex</code> and 
     *  <code>rowIndex</code>,
     *  the zero-based column and row indexes of the item.
     *  For example: {columnIndex:2, rowIndex:3}</p>
     *
     *  <p>Setting this property scrolls the item into view and
     *  dispatches the <code>itemEditBegin</code> event to
     *  open an item editor on the specified item renderer.</p>
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get editedItemPosition():Object
    {
        if (_editedItemPosition)
            return {rowIndex: _editedItemPosition.rowIndex,
                columnIndex: _editedItemPosition.columnIndex};
        else
            return _editedItemPosition;
    }
    
    /**
     *  @private
     */
    public function set editedItemPosition(value:Object):void
    {
        if (!value)
        {
            setEditedItemPosition(null);
            return;
        }
        
        var newValue:Object = {rowIndex: value.rowIndex,
            columnIndex: value.columnIndex};
        
        setEditedItemPosition(newValue);
    }
    
    /**
     *  @private
     */
    private function setEditedItemPosition(coord:Object):void
    {
        commitEditedItemPosition(coord);
    }

    /**
     *  @private
     *  true if we want to block editing on mouseUp
     */
    private var dontEdit:Boolean = false;
    
    /**
     *  @private
     *  true if we want to block editing on mouseUp
     */
    private var losingFocus:Boolean = false;
    
    /**
     *  @private
     *  true if we're in the endEdit call.  Used to handle
     *  some timing issues with collection updates
     */
    private var inEndEdit:Boolean = false;
    
    /**
     *  A reference to the currently active instance of the item editor, 
     *  if it exists.
     *
     *  <p>To access the item editor instance and the new item value when an 
     *  item is being edited, you use the <code>itemEditorInstance</code> 
     *  property. The <code>itemEditorInstance</code> property
     *  is not valid until after the event listener for
     *  the <code>itemEditBegin</code> event executes. Therefore, you typically
     *  only access the <code>itemEditorInstance</code> property from within 
     *  the event listener for the <code>itemEditEnd</code> event.</p>
     *
     *  <p>The <code>DataGridColumn.itemEditor</code> property defines the
     *  class of the item editor
     *  and, therefore, the data type of the item editor instance.</p>
     *
     *  <p>You do not set this property in MXML.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var itemEditorInstance:IGridItemEditor;
    
    
    /**
     *  @private
     */
    private var _editedItemRenderer:IVisualElement;
    
    /**
     *  A reference to the item renderer
     *  in the DataGrid control whose item is currently being edited.
     *
     *  <p>From within an event listener for the <code>itemEditBegin</code>
     *  and <code>itemEditEnd</code> events,
     *  you can access the current value of the item being edited
     *  using the <code>editedItemRenderer.data</code> property.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get editedItemRenderer():IVisualElement
    {
        return _editedItemRenderer;
    }
    
    //----------------------------------
    //  editorColumnIndex
    //----------------------------------
    
    /**
     *  The zero-based column index of the cell that is being edited. The 
     *  value is -1 if no cell is being edited.
     * 
     *  @default -1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4.5
     */
    public function get editorColumnIndex():int
    {
        if (editedItemPosition)
            return editedItemPosition.columnIndex;
        
        return -1;
    }
    
    //----------------------------------
    //  editorRowIndex
    //----------------------------------
    
    /**
     *  The zero-based row index of the cell that is being edited. The 
     *  value is -1 if no cell is being edited.
     * 
     *  @default -1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4.5
     */
    public function get editorRowIndex():int
    {
        if (editedItemPosition)
            return editedItemPosition.rowIndex;
        
        return -1;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Called by the data grid after construction to initialize the editor. No
     *  item editors can be created until after this method is called.
     */  
    public function initialize():void
    {
        // add listeners to enable cell editing
        var grid:Grid = dataGrid.grid;
        
        dataGrid.addEventListener(KeyboardEvent.KEY_DOWN, dataGrid_keyboardDownHandler);
        
        // make sure we get first shot at mouse events before selection is changed. We use 
        // this is test if you are clicking on a selected row or not.
        grid.addEventListener(MouseEvent.MOUSE_DOWN, grid_mouseDownHandler, false, 1000);
        grid.addEventListener(GridEvent.GRID_MOUSE_DOWN, grid_gridMouseDownHandler);
        grid.addEventListener(GridEvent.GRID_MOUSE_UP, grid_gridMouseUpHandler);
        grid.addEventListener(GridEvent.GRID_DOUBLE_CLICK, grid_gridDoubleClickHandler);
    }
    
    /**
     *  @private
     * 
     *  The method is called to disable item editing on the data grid.
     */ 
    public function uninitialize():void
    {
        // remove listeners to disable cell editing   
        
        grid.removeEventListener(KeyboardEvent.KEY_DOWN, dataGrid_keyboardDownHandler);
        grid.removeEventListener(MouseEvent.MOUSE_DOWN, grid_mouseDownHandler);
        grid.removeEventListener(GridEvent.GRID_MOUSE_DOWN, grid_gridMouseDownHandler);
        grid.removeEventListener(GridEvent.GRID_MOUSE_UP, grid_gridMouseUpHandler);
        grid.removeEventListener(GridEvent.GRID_DOUBLE_CLICK, grid_gridDoubleClickHandler);
    }
    
    /**
     *  @private
     *  
     *  This method closes an item editor currently open on an item renderer. 
     *  You typically only call this method from within the event listener 
     *  for the <code>itemEditEnd</code> event, after
     *  you have already called the <code>preventDefault()</code> method to 
     *  prevent the default event listener from executing.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    mx_internal function destroyItemEditor():void
    {
        // trace("destroyItemEditor");
        if (grid.root)
            grid.systemManager.addEventListener(Event.DEACTIVATE, deactivateHandler, false, 0, true);
        
        grid.systemManager.getSandboxRoot().
            removeEventListener(MouseEvent.MOUSE_DOWN, sandBoxRoot_mouseDownHandler, true);
        grid.systemManager.getSandboxRoot().
            removeEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE, sandBoxRoot_mouseDownHandler);
        grid.systemManager.removeEventListener(Event.RESIZE, editorAncestorResizeHandler);
        dataGrid.removeEventListener(Event.RESIZE, editorAncestorResizeHandler);
        
        if (itemEditorInstance || editedItemRenderer)
        {
            if (itemEditorInstance)
                itemEditorInstance.discard();
            
            var o:IVisualElement = (itemEditorInstance ? 
                                    itemEditorInstance : editedItemRenderer);
            
            o.removeEventListener(KeyboardEvent.KEY_DOWN, editor_keyDownHandler);
            o.removeEventListener(FocusEvent.FOCUS_OUT, editor_focusOutHandler);
            o.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, editor_keyFocusChangeHandler);
            addRemoveFlexEventEnterListener(DisplayObject(o), false);
            
            if (grid.focusManager)
                grid.focusManager.defaultButtonEnabled = true;
            
            // setfocus back to us so something on stage has focus
            deferFocus();
            
            // defer focus can cause focusOutHandler to destroy the editor
            // and make itemEditorInstance null
            if (itemEditorInstance)
                grid.removeElement(itemEditorInstance);
            else
                grid.invalidateDisplayList();   // force the editorIndicator to be redrawn
            
            dataGrid.hasFocusableChildren = saveDataGridHasFocusableChildren;
            //dataGrid.grid.hasFocusableChildren = saveGridHasFocusableChildren;

            if (dataGrid.scroller)
                dataGrid.scroller.hasFocusableChildren = saveScrollerHasFocusableChildren;
            
            itemEditorInstance = null;
            _editedItemRenderer = null;
            _editedItemPosition = null;
        }
    }
    
    /**
     *  @private
     * 
     *  Creates the item editor for the item renderer at the
     *  <code>editedItemPosition</code> using the editor
     *  specified by the <code>itemEditor</code> property.
     *
     *  <p>This method sets the editor instance as the 
     *  <code>itemEditorInstance</code> property.</p>
     *
     *  @param rowIndex The row index in the data provider of the item to be edited.
     *  @param columnIndex The column index in the data provider of the item to be edited.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    mx_internal function createItemEditor(rowIndex:int, columnIndex:int):void
    {
        // check for bad values
        if (columnIndex >= grid.columns.length)
            return;
        
        var col:GridColumn = grid.columns.getItemAt(columnIndex) as GridColumn;
        var item:IVisualElement = grid.getItemRendererAt(rowIndex, columnIndex);
        var cellBounds:Rectangle = grid.getCellBounds(rowIndex,columnIndex);
        
        // convert the row origin from the grid to the editor layer.
        var globalCellOrigin:Point = grid.localToGlobal(new Point(cellBounds.x, cellBounds.y));
        var localCellOrigin:Point = cellBounds.topLeft;
        
        _editedItemRenderer = item;
        
        // Need to turn on focusable children flag so focus manager will
        // allow focus into the data grid's children.
        saveDataGridHasFocusableChildren = dataGrid.hasFocusableChildren; 
        dataGrid.hasFocusableChildren = true;
        
        if (dataGrid.scroller)
        {
            saveScrollerHasFocusableChildren = dataGrid.scroller.hasFocusableChildren; 
            dataGrid.scroller.hasFocusableChildren = true;
        }
        
        if (!col.rendererIsEditable)
        {
            // First use the column's itemEditor.
            // If that is unspecified try the dataGrid's itemEditor.
            // If that is unspecified then use the default itemEditor
            // set on the column.
            var itemEditor:IFactory = col.itemEditor;
            if (!itemEditor)
                itemEditor = dataGrid.itemEditor;
            if (!itemEditor)
                itemEditor = GridColumn.defaultItemEditorFactory;
            
            if (itemEditor == GridColumn.defaultItemEditorFactory)
            {
                // if it is the default factory, see if someone
                // overrode it with this style
                var c:Class = dataGrid.getStyle("defaultDataGridItemEditor");
                if (c)
                {
                    itemEditor = col.itemEditor = new ClassFactory(c);
                }
            }
            
            itemEditorInstance = itemEditor.newInstance();
            itemEditorInstance.owner = dataGrid;
            itemEditorInstance.rowIndex = rowIndex;
            itemEditorInstance.column = col;
            itemEditorInstance.hasFocusableChildren = true;
            if (itemEditorInstance is ISimpleStyleClient)
                ISimpleStyleClient(itemEditorInstance).styleName = item;
            itemEditorInstance.data = IGridItemRenderer(item).data;
            
            grid.addElement(itemEditorInstance);
            
            // position the editor over the cell with the same size as the cell.
            itemEditorInstance.width = cellBounds.width;
            itemEditorInstance.height = cellBounds.height;
            itemEditorInstance.setLayoutBoundsPosition(localCellOrigin.x, localCellOrigin.y);
            
            if (itemEditorInstance is IInvalidating)
                IInvalidating(itemEditorInstance).validateNow();
            
            // Allow the user code to make any final adjustments and make the editor visible.
            itemEditorInstance.prepare();
            itemEditorInstance.visible = true;
            
            itemEditorInstance.addEventListener(FocusEvent.FOCUS_OUT, editor_focusOutHandler);

            // listen for keyStrokes on the itemEditorInstance (which lets the grid supervise for ESC/ENTER)
            itemEditorInstance.addEventListener(KeyboardEvent.KEY_DOWN, editor_keyDownHandler);
            itemEditorInstance.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, editor_keyFocusChangeHandler, false, 1000);
            addRemoveFlexEventEnterListener(DisplayObject(itemEditorInstance), true);
        }
        else
        {
            // if the item renderer is editable
            // add the itemRenderer to focus manager to get the 
            // focusable objects under its control. Next set focus
            // to the first item that should get focus.
            if (grid.focusManager && grid.focusManager is FocusManager)
            {
                var fm:FocusManager = grid.focusManager as FocusManager;
                var o:DisplayObject = item as DisplayObject;
                var found:Boolean = false;
                do
                {
                    fm.fauxFocus = o;
                    o = fm.getNextFocusManagerComponent(false) as DisplayObject;
                    if (o == item || 
                        item is DisplayObjectContainer && 
                        DisplayObjectContainer(item).contains(o))
                    {
                        found = true;
                        break;
                    }
                } while (o && dataGrid.contains(o));
                
                if (lastEvent && lastEvent.type == KeyboardEvent.KEY_DOWN && 
                    KeyboardEvent(lastEvent).keyCode == Keyboard.TAB &&
                    KeyboardEvent(lastEvent).shiftKey)
                {
                    // put focus on last item in cell editor instead of first.
                    var lastItem:DisplayObject = o;
                    do
                    {
                        fm.fauxFocus = o;
                        lastItem = o;
                        o = fm.getNextFocusManagerComponent(false) as DisplayObject;
                    } while (o && DisplayObjectContainer(item).contains(o));
                    
                    o = lastItem;
                }
                
                fm.fauxFocus = null;
                
                if (found)
                {
                    fm.setFocus(IFocusManagerComponent(o));
                    
                    // Since we may have gotton here with the F2 key show the focus
                    // indicator to make it obvious which control has focus.
                    fm.showFocus();
                }
                
                editedItemRenderer.addEventListener(FocusEvent.FOCUS_OUT, editor_focusOutHandler);
                
                // listen for keyStrokes on the itemEditorInstance (which lets the grid supervise for ESC/ENTER)
                editedItemRenderer.addEventListener(KeyboardEvent.KEY_DOWN, editor_keyDownHandler);
                editedItemRenderer.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, editor_keyFocusChangeHandler, false, 1000);
                addRemoveFlexEventEnterListener(DisplayObject(editedItemRenderer), true);
                
                // It would be nice to hide the selection on the cell while it is
                // being edited to provide better contrast for the focus rect 
                // around the controls.
            
            }
        }
        
        if (grid.focusManager)
            grid.focusManager.defaultButtonEnabled = false;

        // Invalidate the grid so the editor indicator will be shown.
        grid.invalidateDisplayList();
        
        if (grid.root)
            grid.systemManager.addEventListener(Event.DEACTIVATE, deactivateHandler, false, 0, true);
        
        // we disappear on any mouse down outside the editor
        grid.systemManager.getSandboxRoot().
            addEventListener(MouseEvent.MOUSE_DOWN, sandBoxRoot_mouseDownHandler, true, 0, true);
        grid.systemManager.getSandboxRoot().
            addEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE, sandBoxRoot_mouseDownHandler, false, 0, true);
        // we disappear if stage or our grid is resized
        grid.systemManager.addEventListener(Event.RESIZE, editorAncestorResizeHandler);
        grid.addEventListener(Event.RESIZE, editorAncestorResizeHandler);        
    }
    
    /**
     *  @private
     * 
     *  Start editing a cell for a specified row and column index.
     *  
     *  Dispatches a <code>GridItemEditorEvent.START_GRID_ITEM_EDITOR_SESSION
     *  </code> event. 
     * 
     *  @param rowIndex The zero-based row index of the cell to edit.
     * 
     *  @param columnIndex The zero-based column index of the cell to edit.
     */
    public function startItemEditorSession(rowIndex:int, columnIndex:int):Boolean
    {
        
        dataGrid.addEventListener(GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_STARTING,
                                  dataGrid_startItemEditorSessionHandler,
                                  false, EventPriority.DEFAULT_HANDLER);
        
        var dataGridEvent:GridItemEditorEvent =
            new GridItemEditorEvent(GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_STARTING, false, true);
        
        // The START_GRID_ITEM_EDITOR_SESSION event is cancelable
        dataGridEvent.rowIndex = Math.min(rowIndex, grid.dataProvider.length - 1);
        dataGridEvent.columnIndex = Math.min(columnIndex, grid.columns.length - 1);
        dataGridEvent.column = grid.columns.getItemAt(columnIndex) as GridColumn;
        
        var editorStarted:Boolean = dataGrid.dispatchEvent(dataGridEvent);         
        if (editorStarted) 
        {
            lastEditedItemPosition = { columnIndex: columnIndex, rowIndex: rowIndex };
            
            dataGrid.grid.caretRowIndex = rowIndex;
            dataGrid.grid.caretColumnIndex = columnIndex;
        }
        
        dataGrid.removeEventListener(GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_STARTING,
                                     dataGrid_startItemEditorSessionHandler);
        
        return editorStarted;
    }
    
    /**
     *  Closes the currently active editor and optionally saves the editor's value
     *  by calling the item editor's save() method.  If the cancel parameter is true,
     *  then the editor's cancel() method is called instead.
     * 
     *  @param cancel If false the data in the editor is saved. 
     *  Otherwise the data in the editor is discarded.
     *
     *  @see spark.components.IGridItemEditor
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */ 
    public function endItemEditorSession(cancel:Boolean = false):Boolean
    {
        if (cancel)
        {
            cancelEdit();
            return false;
        }
        else
        {
            return endEdit();
        }
    }
    
    /**
     *  @private
     * 
     *  Close the item editor without saving the data.
     */
    mx_internal function cancelEdit():void
    {
        if (itemEditorInstance)
        {
            // send the cancel event and tear down the editor.
            dispatchCancelEvent();
            destroyItemEditor();
        }
        else if (editedItemRenderer)
        {
            // cancel focus in an item editor by setting focus back to the grid.
            destroyItemEditor();
        }

    }

    
    /**
     *  @private
     * 
     *  Notify event that the editor session is cancelled.
     *  This event cannot be cancelled.
     */
    private function dispatchCancelEvent():void
    {
        var dataGridEvent:GridItemEditorEvent =
            new GridItemEditorEvent(GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_CANCEL);
        
        dataGridEvent.columnIndex = editedItemPosition.columnIndex;
        dataGridEvent.column = itemEditorInstance.column;
        dataGridEvent.rowIndex = editedItemPosition.rowIndex;
        dataGrid.dispatchEvent(dataGridEvent);
    }
    
    /**
     *  @private
     * 
     *  When the user finished editing an item, this method is called to close 
     *  the editor and save the data.
     *  
     */
    private function endEdit():Boolean
    {
        // Focus is inside an item renderer
        if (!itemEditorInstance && editedItemRenderer)
        {
            inEndEdit = true;
            destroyItemEditor();
            inEndEdit = false;
            return true;
        }
        
        // this happens if the renderer is removed asynchronously ususally with FDS
        if (!itemEditorInstance)
            return true;
        
        inEndEdit = true;
        
        var itemPosition:Object = editedItemPosition;
        if (!saveItemEditorSession())
        {
            // the save was cancelled so dispatch a cancel event.
            dispatchCancelEvent();
            inEndEdit = false;
            return false;
        }
        
        var dataGridEvent:GridItemEditorEvent =
            new GridItemEditorEvent(GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_SAVE, false, true);
        
        // SAVE_GRID_ITEM_EDITOR_SESSION events are cancelable
        dataGridEvent.columnIndex = itemPosition.columnIndex;
        dataGridEvent.column = dataGrid.columns.getItemAt(itemPosition.columnIndex) as GridColumn;
        dataGridEvent.rowIndex = itemPosition.rowIndex;
        dataGrid.dispatchEvent(dataGridEvent);

        inEndEdit = false;
        
        return true;
    }
    
    /**
     *  @private
     *  focus an item renderer in the grid
     */
    private function commitEditedItemPosition(coord:Object):void
    {
        if (!grid.enabled || !dataGrid.editable)
            return;
        
        if (!grid.dataProvider || grid.dataProvider.length == 0)
            return;
        
        // just give focus back to the itemEditorInstance
        if (itemEditorInstance && coord &&
            itemEditorInstance is IFocusManagerComponent &&
            _editedItemPosition.rowIndex == coord.rowIndex &&
            _editedItemPosition.columnIndex == coord.columnIndex)
        {
            IFocusManagerComponent(itemEditorInstance).setFocus();
            return;
        }
        
        // dispose of any existing editor, saving away its data first
        if (itemEditorInstance)
        {
            if (!dataGrid.endItemEditorSession())
                return;
        }
        
        // store the value
        _editedItemPosition = coord;
        
        // allow setting of undefined to dispose item editor instance
        if (!coord)
            return;
        
        if (dontEdit)
        {
            return;
        }
        
        var rowIndex:int = coord.rowIndex;
        var columnIndex:int = coord.columnIndex;
        
        dataGrid.ensureCellIsVisible(rowIndex, columnIndex);
        
        // get the actual references for the column, row, and item
        var item:IVisualElement = grid.getItemRendererAt(rowIndex, columnIndex);
        if (!item)
        {
            // assume that editing was cancelled
            commitEditedItemPosition(null);
            return;
        }

        createItemEditor(rowIndex, columnIndex);
        
        if (itemEditorInstance is IInvalidating)
            IInvalidating(itemEditorInstance).validateNow();

        var column:GridColumn = dataGrid.columns.getItemAt(columnIndex) as GridColumn;
        if (itemEditorInstance is IIMESupport)
            IIMESupport(itemEditorInstance).imeMode =
                (column.imeMode == null) ? dataGrid.imeMode : column.imeMode;
        
        var fm:IFocusManager = grid.focusManager;
        // trace("setting focus to item editor");
        if (itemEditorInstance is IFocusManagerComponent)
            fm.setFocus(IFocusManagerComponent(itemEditorInstance));
        
        lastEditedItemPosition = _editedItemPosition;
        
        // Notify event that a new editor is starting.
        var dataGridEvent:GridItemEditorEvent =
            new GridItemEditorEvent(GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_START);
        
        dataGridEvent.columnIndex = editedItemPosition.columnIndex;
        dataGridEvent.column = column;
        dataGridEvent.rowIndex = editedItemPosition.rowIndex;
        dataGrid.dispatchEvent(dataGridEvent);
    }

    /**
     *  @private
     *  Sets focus back to the grid so default handler will move it to the 
     *  next component.
     */ 
    private function deferFocus():void
    {
        losingFocus = true;
        dataGrid.setFocus();
        losingFocus = false;
    }
    
    /**
     *  @private
     *  Save the editor session. The developer can still cancel out so the 
     *  data may not be saved.
     * 
     *  @return true if the data is saved, false otherwise.
     */
    private function saveItemEditorSession():Boolean
    {
        var dataSaved:Boolean = false;
        
        if (itemEditorInstance)
        {
            dataSaved = itemEditorInstance.save();
            
            if (dataSaved)
            {
                destroyItemEditor();
            }
            else
            {            
                if (itemEditorInstance && _editedItemPosition)
                {
                    // edit session is continued so restore focus and selection
                    if (grid.selectedIndex != _editedItemPosition.rowIndex)
                        grid.selectedIndex = _editedItemPosition.rowIndex;
                    var fm:IFocusManager = grid.focusManager;
                    // trace("setting focus to itemEditorInstance", selectedIndex);
                    if (itemEditorInstance is IFocusManagerComponent)
                        fm.setFocus(IFocusManagerComponent(itemEditorInstance));
                }
            }
        }
        
        return dataSaved;
    }
    
    /**
     *  @private
     *  Start an editor session in the next editable cell. 
     *
     *  @param rowIndex zero-based row index to start search from, inclusive.
     *  @param columnIndex zero-based column index to start search from, not inclusive. 
     *  @param backward - if true move backward column by column and then row by row.
     *  If false, then move forward column by column, row by row.
     * 
     */
    private function openEditorInNextEditableCell(rowIndex:int, columnIndex:int, backward:Boolean):void
    {
        var nextCell:Point = new Point(rowIndex, columnIndex);
        var openedEditor:Boolean = false;
        
        do
        {
            nextCell = getNextEditableCell(nextCell.x, nextCell.y, backward);
            
            if (nextCell)
                openedEditor = startItemEditorSession(nextCell.x, nextCell.y);                
        } while (nextCell && !openedEditor);
        
    }
    
    /**
     *  @private
     *  Find the next editable cell. 
     * 
     *  @param rowIndex zero-based row index to start search from, inclusive.
     *  @param columnIndex zero-based column index to start search from, not inclusive. 
     *  @param backward - if true move backward column by column and then row by row.
     *  If false, then move forward column by column, row by row.
     * 
     *  @return If an editable cell was found then return a Point with the x property
     *  containing the rowIndex and the y property containing the column index. If no
     *  editable cell was found then null is returned.
     */
    private function getNextEditableCell(rowIndex:int, columnIndex:int, backward:Boolean):Point
    {
        // what is the next cell?
        // increment is -1 if we are moving backward and 1 if moving
        // forward.
        const increment:int = backward ? -1 : 1;
        var rowIndex:int = rowIndex;
        var columnIndex:int = columnIndex;
        do {
            var nextColumn:int = columnIndex + increment;
            if (nextColumn >= 0 && nextColumn < dataGrid.columns.length)
            {
                columnIndex += increment;    
            }
            else
            {
                // move to next row.
                columnIndex = backward ? dataGrid.grid.columns.length - 1: 0;
                var nextRow:int = rowIndex + increment;
                if (nextRow < dataGrid.dataProvider.length)
                    rowIndex += increment;
                else
                    return null;
            }
        } while (!canEditColumn(columnIndex));
        
        return new Point(rowIndex, columnIndex);
    }
    
    
    /**
     *  @private
     * 
     *  @param columnIndex
     * 
     *  @return true if the column can be edited, false otherwise.
     */ 
    private function canEditColumn(columnIndex:int):Boolean
    {
        var column:GridColumn = grid.columns.getItemAt(columnIndex) as GridColumn; 
        return (dataGrid.editable && 
                column.editable &&
                column.visible);
    }
    
    /**
     *  @private
     * 
     *  Test if the cell was selected at the last selection snapshot.
     */
    private function wasCellPreviouslySelected(rowIndex:int, columnIndex:int):Boolean
    {
        if (dataGrid.isRowSelectionMode())
            return (dataGrid.isCellSelectionMode() || previouslySelectedIndices.indexOf(rowIndex) >= 0);
        else
        {
            // loop thru the previously selected cells to compare
            for each (var cp:CellPosition in previouslySelectedCells)
            {
                if (cp.rowIndex == rowIndex &&
                    cp.columnIndex == columnIndex)
                    return true;
            }
        }
        
        return false;
    }

    /**
     *  @private
     *  
     *  Add a FlexEvent.ENTER listener to all child IVisualElements.
     * 
     *  @param element add listener to element and its children.
     *  @param addListener if true add a listener, otherwise remove a listener.
     */
    private function addRemoveFlexEventEnterListener(element:DisplayObject, addListener:Boolean):void
    {
        if (addListener)
            element.addEventListener(FlexEvent.ENTER, editor_enterHandler);
        else
            element.removeEventListener(FlexEvent.ENTER, editor_enterHandler);
        
        if (element is DisplayObjectContainer)
        {
            var container:DisplayObjectContainer = DisplayObjectContainer(element);
            var n:int = container.numChildren;
            for (var i:int = 0; i < n; i++)
            {
                var child:DisplayObject = container.getChildAt(i);
                
                if (child is DisplayObjectContainer)
                {
                    addRemoveFlexEventEnterListener(child, addListener);
                }
                else
                {
                    if (addListener)
                        child.addEventListener(FlexEvent.ENTER, editor_enterHandler);
                    else
                        child.removeEventListener(FlexEvent.ENTER, editor_enterHandler);
                }
            }
        }
        
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     * 
     *  Handle the F2 key to start editing a cell.
     */
    private function dataGrid_keyboardDownHandler(event:KeyboardEvent):void
    {
        if (!dataGrid.editable)
            return;
        
        if (event.isDefaultPrevented())
            return;
        
        lastEvent = event;
        
        if (event.keyCode == dataGrid.editKey)
        {
            // ignore F2 if we are already editting a cell.
            if (itemEditorInstance)
                return;
            
            // Edit the last column edited. If no last column then try to 
            // edit the first column.
            var nextCell:Point = null;
            if (dataGrid.isRowSelectionMode())
            {
                var lastColumn:int = lastEditedItemPosition ? lastEditedItemPosition.columnIndex : 0;
                openEditorInNextEditableCell(dataGrid.grid.caretRowIndex, 
                                                        lastColumn - 1,
                                                        false);
                return;
            }
            else
            {
                startItemEditorSession(grid.caretRowIndex, grid.caretColumnIndex);                
            }
        }            
    }
    
    /**
     *  @private
     * 
     *  Get a selection snapshot on mouse down before the grid's selection is 
     *  changed. This is how we can telll if we have clicked on a selected cell
     *  or not.
     */
    private function grid_mouseDownHandler(event:MouseEvent):void
    {
        if (!dataGrid.editable)
            return;

        lastEvent = event;
        
        if (dataGrid.isRowSelectionMode())
        {
            previouslySelectedIndices = dataGrid.selectedIndices.slice(0, dataGrid.selectedIndices.length);
            previouslySelectedCells = null;
        }
        else
        {
            previouslySelectedIndices = null;
            previouslySelectedCells = dataGrid.selectedCells.slice(0, dataGrid.selectedCells.length);
//            for each (var cell:CellPosition in dataGrid.selectedCells)
//            {
//                trace("cell position = (" + cell.rowIndex + "," + cell.columnIndex + ")");    
//            }
        }
    }
    
    /**
     *  @private
     * 
     */
    private function grid_gridMouseDownHandler(event:GridEvent):void
    {
        //trace("grid_gridMouseDownHandler");
        
        gotDoubleClickEvent = false;
        
        if (!dataGrid.editable || editorOwnsClick(event))
            return;

        lastEvent = event;
        
        const rowIndex:int = event.rowIndex;
        const columnIndex:int = event.columnIndex;
        
        //trace("grid_gridMouseDownHandler: (rowIndex, columnIndex) = (" + rowIndex + "," + columnIndex + ")");
        
        // item editor handling
        var r:IGridItemRenderer = event.itemRenderer as IGridItemRenderer;
        
        lastItemDown = null;
        
        // if selection is being modified with shift or ctrl keys then
        // don't start up an editor session.
        if (event.shiftKey || event.ctrlKey)
            return;
        
        // if an editor is already up, close it without starting a new editor.
        if (itemEditorInstance)
        {
            dataGrid.endItemEditorSession();
            return;
        }
        
        if (r && wasCellPreviouslySelected(rowIndex, columnIndex))
        {
            //trace("cell was previously selected: (" + rowIndex + "," + columnIndex + ")");  
            lastItemDown = r;
        }
        
    }
    
    /**
     *  @private
     * 
     *  If clicked on a the same cell as mouse down then start editing the cell.
     */
    private function grid_gridMouseUpHandler(event:GridEvent):void
    {
        //trace("grid_gridMouseUpHandler");
        
        if (!dataGrid.editable)
            return;

        lastEvent = event;
        
        const eventRowIndex:int = event.rowIndex;
        const eventColumnIndex:int = event.columnIndex;
        
        // Only start an edit if the row is the only selected row.
        // Only start editing when one row is selected.
        if (dataGrid.selectionLength != 1)
            return;
        
        const rowIndex:int = eventRowIndex;
        var columnIndex:int = eventColumnIndex;
        
        var r:IVisualElement = event.itemRenderer;
        //trace("grid_gridMouseUpHandler: itemRenderer = " + event.itemRenderer);  
        if (r && r != editedItemRenderer && 
            (lastItemDown == r || (lastItemDown && grid.contains(DisplayObject(lastItemDown)))))
        {
            // if lastItemDown != r, we clicked in one cell and dragged to another.
            if (lastItemDown != r)
                r = lastItemDown;
            
            if (columnIndex >= 0 && dataGrid.editable && !dontEdit)
            {
                if (grid.columns.getItemAt(columnIndex).editable)
                {
                    // Check if clicking again on the same item
                    if (doubleClickTimer)
                    {
                        if (rowIndex == lastItemClickedPosition.rowIndex &&
                            columnIndex == lastItemClickedPosition.columnIndex)
                        {
                            // Clicked on the same item again and we 
                            // already have a timer. Wait on the existing timer.
                            lastItemDown == null;
                            return;
                        }
                        else 
                        {
                            // Clicked on a different item. Stop the timer and start a new one
                            doubleClickTimer.stop();
                            doubleClickTimer = null;
                        }
                    }
                    
                    lastItemClickedPosition = { columnIndex: columnIndex, rowIndex: rowIndex};
                    
                    // If double click is not enabled or we want a double click to open an
                    // editor, then open the editor directly now. Otherwise start a timer
                    // and wait to see if a double click comes in that will cancel the edit.
                    if (dataGrid.editOnDoubleClick || 
                        InteractiveObject(lastItemDown).doubleClickEnabled == false)
                    {
                        // we don't need to wait on the time since editting double click is ok.
                        startItemEditorSession(rowIndex, columnIndex);
                    }
                    else 
                    {
                        doubleClickTimer = new Timer(dataGrid.doubleClickTime, 1);
                        doubleClickTimer.addEventListener(TimerEvent.TIMER, doubleClickTimerHandler);
                        doubleClickTimer.start();                        
                    }
                }
                else
                    // if the item is not editable, set lastPosition to it anyways
                    // so future tabbing starts from there
                    lastEditedItemPosition = { columnIndex: columnIndex, rowIndex: rowIndex };
            }
        }
        else if (lastItemDown && lastItemDown != editedItemRenderer)
        {
            if (columnIndex >= 0 && dataGrid.editable && !dontEdit)
            {
                if (grid.columns.getItemAt(columnIndex).editable)
                {
                    // Check if clicking again on the same item
                    if (doubleClickTimer)
                    {
                        if (rowIndex == lastItemClickedPosition.rowIndex &&
                            columnIndex == lastItemClickedPosition.columnIndex)
                        {
                            // click on the same item again and we already have a timer
                            // do, wait on the timer
                            lastItemDown == null;
                            return;
                        }
                        else 
                        {
                            // click on a different item. Stop the timer and start a new one
                            doubleClickTimer.stop();
                            doubleClickTimer = null;
                        }
                    }
                    
                    lastItemClickedPosition = { columnIndex: columnIndex, rowIndex: rowIndex};
                    
                    // start timer to make sure a double click does not cancel the edit.
                    if (dataGrid.editOnDoubleClick || 
                        InteractiveObject(lastItemDown).doubleClickEnabled == false)
                    {
                        // we don't need to wait on the time since editting double click is ok.
                        startItemEditorSession(rowIndex, columnIndex);
                    }
                    else 
                    {
                        doubleClickTimer = new Timer(dataGrid.doubleClickTime, 1);
                        doubleClickTimer.addEventListener(TimerEvent.TIMER, doubleClickTimerHandler);
                        doubleClickTimer.start();                        
                    }
                }
                else
                    // if the item is not editable, set lastPosition to it anyways
                    // so future tabbing starts from there
                    lastEditedItemPosition = { columnIndex: columnIndex, rowIndex: rowIndex};
            }
        }
        
        lastItemDown = null;            
    }

    /**
     *  @private
     * 
     *  If clicked on a the same cell as mouse down then start editing the cell.
     */
    private function grid_gridDoubleClickHandler(event:GridEvent):void
    {
        //trace("grid_gridDoubleClickHandler: got double click");
        
        if (!dataGrid.editable)
            return;
        
        lastEvent = event;
        
        gotDoubleClickEvent = true;
    }
    
    /**
     *  @private
     * 
     *  Timer for double click events.
     */
    private function doubleClickTimerHandler(event:TimerEvent):void
    {
        //trace("doubleClickTimerHandler");
        
        doubleClickTimer.removeEventListener(TimerEvent.TIMER, doubleClickTimerHandler);
        doubleClickTimer = null;
        
        if (!gotDoubleClickEvent)
        {
            dataGrid.startItemEditorSession(lastItemClickedPosition.rowIndex, lastItemClickedPosition.columnIndex);
        }

        gotDoubleClickEvent = false;
    }
    
    
    /**
     *  @private
     * 
     *  Default handler for the startItemEditorSession event.
     */
    private function dataGrid_startItemEditorSessionHandler(event:GridItemEditorEvent):void
    {
        // trace("itemEditorItemEditBeginningHandler");
        if (!event.isDefaultPrevented())
            setEditedItemPosition({columnIndex: event.column.columnIndex, rowIndex: event.rowIndex});
        else if (!itemEditorInstance)
        {
            _editedItemPosition = null;
            // return focus to the grid w/o selecting an item
            dataGrid.editable = false;
            dataGrid.setFocus();
            dataGrid.editable = true;
        }
    }
    
    /**
     *  @private
     */
    private function deactivateHandler(event:Event):void
    {
        // if stage losing activation, set focus to DG so when we get it back
        // we popup an editor again
        if (itemEditorInstance || editedItemRenderer)
        {
            dataGrid.endItemEditorSession();
            deferFocus();
        }
    }
    
    /**
     *  @private
     *  Closes the itemEditorInstance if the foucs is outside of the dataGrid.
     */
    private function editor_focusOutHandler(event:FocusEvent):void
    {
        //trace("editor_focusOutHandler " + event.relatedObject);
        if (event.relatedObject && 
            ((itemEditorInstance && DisplayObjectContainer(itemEditorInstance).contains(event.relatedObject)) ||
                (editedItemRenderer && DisplayObjectContainer(editedItemRenderer).contains(event.relatedObject))) ||
            dataGrid.contains(event.relatedObject))
            return;
        
        // ignore textfields losing focus on mousedowns
        if (!event.relatedObject)
            return;
        
        if (itemEditorInstance || editedItemRenderer)
            dataGrid.endItemEditorSession();
        else
            destroyItemEditor();
        
    }
    
    /**
     *  @private
     *  Handle the ENTER event by closing the editor.
     */
    private function editor_enterHandler(event:FlexEvent):void
    {
        //trace("FlexEvent" );
        gotFlexEnterEvent = true;
    }
    
    /**
     *  @private
     * 
     *  Handle keys on the editor to stop the editing session.
     */
    private function editor_keyDownHandler(event:KeyboardEvent):void
    {
        //trace("keyboard event = " + event);
        if (event.isDefaultPrevented())
        {
            // Special case the ENTER key since TextArea cancels the ENTER when it 
            // doesn't use it but instead if dispatched an FlexEvent.ENTER.
            // The problem is the ENTER event does not have the control and 
            // shift key flags we need.
            if (!(event.charCode == Keyboard.ENTER && gotFlexEnterEvent))
            {
                gotFlexEnterEvent = false;
                return;
            }
        }
        
        gotFlexEnterEvent = false;
        
        // ESC just kills the editor, no new data
        if (event.keyCode == Keyboard.ESCAPE)
        {
            cancelEdit();
        }
        else if (event.ctrlKey && event.charCode == 46)
        {   // Check for Ctrl-.
            cancelEdit();
        }
        else if (event.charCode == Keyboard.ENTER && event.keyCode != 229)
        {
            if (!_editedItemPosition)
                return;
            
            // Enter closes the editor.
            // The 229 keyCode is for IME compatability. When entering an IME expression,
            // the enter key is down, but the keyCode is 229 instead of the enter key code.
            // Thanks to Yukari for this little trick...
            if (dataGrid.endItemEditorSession())
            {
                if (grid.focusManager)
                    grid.focusManager.defaultButtonEnabled = false;
                
                if (event.ctrlKey || (event.ctrlKey && event.shiftKey))
                {
                    var lastRow:int = lastEditedItemPosition ? lastEditedItemPosition.rowIndex : 0;
                    var lastColumn:int = lastEditedItemPosition ? lastEditedItemPosition.columnIndex : 0;
                    
                    if (event.shiftKey)
                        lastRow -= 1;
                    else
                        lastRow += 1;
                    
                    // If we have a valid next row, then start another editor.
                    if (lastRow >= 0 && lastRow < dataGrid.dataProvider.length)
                        openEditorInNextEditableCell(lastRow, lastColumn - 1, false);
                }                    
            }
        }
    }
    
    /**
     *  @private
     *  handle focus changes generated from keyboard keys.
     */
    private function editor_keyFocusChangeHandler(event:FocusEvent):void
    {
        // if we tabbed out of the edit then prevent the tab and
        // save the edit. Next start up a new edit session in the
        // next cell.
        //trace("editor_editor_keyFocusChangeHandler");
        
        if (itemEditorInstance || editedItemRenderer)
        {
            if (event.isDefaultPrevented())
                return;
            
            var nextObject:IFocusManagerComponent = grid.focusManager.getNextFocusManagerComponent(event.shiftKey);
            if (nextObject == itemEditorInstance ||
                (itemEditorInstance && !DisplayObjectContainer(itemEditorInstance).contains(DisplayObject(nextObject))) ||
                (!itemEditorInstance && 
                    (nextObject == editedItemRenderer ||
                        (editedItemRenderer && !DisplayObjectContainer(editedItemRenderer).contains(DisplayObject(nextObject))))))
            {
                event.preventDefault();
                dataGrid.endItemEditorSession();
                
                openEditorInNextEditableCell(lastEditedItemPosition.rowIndex,
                    lastEditedItemPosition.columnIndex,
                    event.shiftKey);
            }
        }
    }

    /**
     *  @private
     */
    private function editorAncestorResizeHandler(event:Event):void
    {
        dataGrid.endItemEditorSession();
    }
    
    /**
     *  @private
     */
    private function sandBoxRoot_mouseDownHandler(event:Event):void
    {
        if (editorOwnsClick(event))
        {
            return;
        }
        
        // If clicked on the scroll bars then keep the editor up
        if (dataGrid.scroller && 
            dataGrid.scroller.contains(DisplayObject(event.target)) &&
            !grid.contains(DisplayObject(event.target)))
        {
            return;
        }
        
        dataGrid.endItemEditorSession();
        // set focus back to the grid so grid logic will deal if focus doesn't
        // end up somewhere else
        deferFocus();
    }

    private function editorOwnsClick(event:Event):Boolean
    {
        // check if the mouse was clicked outside of the editor. If it was
        // then end the editing session.
        if (event is MouseEvent && 
            (itemEditorInstance &&
                (itemEditorInstance == event.target || 
                IUIComponent(itemEditorInstance).owns(DisplayObject(event.target)))) ||
            (editedItemRenderer &&
                (editedItemRenderer == event.target || 
                IUIComponent(editedItemRenderer).owns(DisplayObject(event.target)))))
        {
            return true;
        }
        
        return false;
    }
 
    
}
}