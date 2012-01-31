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

package spark.components.supportClasses
{
import flash.display.DisplayObjectContainer;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.ui.Keyboard;
import flash.utils.describeType;

import mx.core.EventPriority;
import mx.core.IFactory;
import mx.core.IFlexModuleFactory;
import mx.core.IInvalidating;
import mx.core.IIMESupport;
import mx.core.IUIComponent;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.mx_internal;
import mx.core.UIComponent;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.events.SandboxMouseEvent;
import mx.managers.FocusManager;
import mx.managers.IFocusManager;
import mx.managers.IFocusManagerComponent;

import spark.components.IGridItemEditor;
import spark.components.DataGrid;
import spark.components.Grid;
import spark.components.Group;
import spark.components.IGridItemRenderer;
import spark.events.DataGridEditEvent;
import spark.events.GridEvent;

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
    private var previouslySelectedIndices:Vector.<int>;
    private var previouslySelectedCells:Vector.<CellPosition>;
   
    private var lastEvent:Event;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    private var _dataGrid:DataGrid;

    public function get dataGrid():DataGrid
    {
        return _dataGrid;    
    }
    
    public function get grid():Grid
    {
        return _dataGrid.grid;        
    }

    // properties that control how the cell editor behaves. This can be based on item editor properties.
    
    //----------------------------------
    //  editedItemPosition
    //----------------------------------
    
    /**
     *  @private
     */
    private var bEditedItemPositionChanged:Boolean = false;
    
    /**
     *  @private
     *  undefined means we've processed it
     *  null means don't put up an editor
     *  {} is the coordinates for the editor
     */
    private var _proposedEditedItemPosition:*;
    
    /**
     *  @private
     */
    private var lastItemDown:IVisualElement;
    
    /**
     *  @private
     */
    private var lastItemFocused:DisplayObject;
    
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
     */
    private var _editedItemPosition:Object;
    
    /**
     *  @private
     */
    private var itemEditorPositionChanged:Boolean = false;
    
    
    [Bindable("itemFocusIn")]
    
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
//            bEditedItemPositionChanged = true;
//            _proposedEditedItemPosition = coord;
//            dataGrid.invalidateDisplayList();
        
        commitEditedItemPosition(coord);
    }

// TODO (dloverin): investigate why imeMode is needed and how it is used
//    //----------------------------------
//    //  imeMode
//    //----------------------------------
//    
//    /**
//     *  @private
//     */
//    private var _imeMode:String = null;
//    
//    [Inspectable(environment="none")]
//    
//    /**
//     *  Specifies the IME (input method editor) mode.
//     *  The IME enables users to enter text in Chinese, Japanese, and Korean.
//     *  Flex sets the specified IME mode when the control gets the focus,
//     *  and sets it back to the previous value when the control loses the focus.
//     *
//     * <p>The flash.system.IMEConversionMode class defines constants for the
//     *  valid values for this property.
//     *  You can also specify <code>null</code> to specify no IME.</p>
//     *
//     *  @see flash.system.IMEConversionMode
//     *
//     *  @default null
//     *  
//     *  @langversion 3.0
//     *  @playerversion Flash 9
//     *  @playerversion AIR 1.1
//     *  @productversion Flex 3
//     */
//    public function get imeMode():String
//    {
//        return _imeMode;
//    }
//    
//    /**
//     *  @private
//     */
//    public function set imeMode(value:String):void
//    {
//        _imeMode = value;
//    }
//    
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
        
        dataGrid.addEventListener(DataGridEditEvent.START_GRID_ITEM_EDITOR_SESSION,
            dataGrid_startItemEditorSessionHandler,
            false, EventPriority.DEFAULT_HANDLER);
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
            
            var o:DisplayObject = (itemEditorInstance ? 
                                  itemEditorInstance : editedItemRenderer) as DisplayObject;
            
            o.removeEventListener(KeyboardEvent.KEY_DOWN, itemEditorInstance_keyDownHandler);
            o.removeEventListener(FocusEvent.FOCUS_OUT, itemEditorInstance_FocusOutHandler);
            o.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler);

            if (grid.focusManager)
                grid.focusManager.defaultButtonEnabled = true;
            
//                var event:DataGridEvent =
//                    new DataGridEvent(DataGridEvent.ITEM_FOCUS_OUT);
//                event.columnIndex = _editedItemPosition.columnIndex;
//                event.rowIndex = _editedItemPosition.rowIndex;
//                //event.itemRenderer = itemEditorInstance;
//                dataGrid.dispatchEvent(event);
                
                //            if (! columns.getItemAt(_editedItemPosition.columnIndex).rendererIsEditor)
                //            {
                // FocusManager.removeHandler() does not find
                // itemEditors in focusableObjects[] array
                // and hence does not remove the focusRectangle
//                 if (itemEditorInstance && itemEditorInstance is UIComponent)
//                    UIComponent(itemEditorInstance).drawFocus(false);
//                
            // setfocus back to us so something on stage has focus
            deferFocus();
            
            // defer focus can cause focusOutHandler to destroy the editor
            // and make itemEditorInstance null
            if (itemEditorInstance)
                dataGrid.itemEditorLayer.removeElement(itemEditorInstance);   

            dataGrid.hasFocusableChildren = false; // TODO (dloverin): restore to last value not always false
            if (dataGrid.grid)
                dataGrid.grid.hasFocusableChildren = false; // TODO (dloverin): restore to last value not always false

            
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
     *  <p>You may only call this method from within the event listener
     *  for the <code>itemEditBegin</code> event. 
     *  To create an editor at other times, set the
     *  <code>editedItemPosition</code> property to generate 
     *  the <code>itemEditBegin</code> event.</p>
     *
     *  @param rowIndex The row index in the data provider of the item to be edited.
     * 
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
        //        if (rowIndex >= lockedRowCount)
        //            rowIndex -= verticalScrollPosition + lockedRowCount;
        //        
        //        if (colIndex >= lockedColumnCount)
        //            colIndex -= horizontalScrollPosition + lockedColumnCount;
        //        
        var item:IVisualElement = grid.getItemRendererAt(rowIndex, columnIndex);
        var cellBounds:Rectangle = grid.getCellBounds(rowIndex,columnIndex);
        
        // convert the row origin from the grid to the editor layer.
        var globalCellOrigin:Point = grid.localToGlobal(new Point(cellBounds.x, cellBounds.y));
        cellBounds.topLeft = DisplayObject(dataGrid.itemEditorLayer).globalToLocal(globalCellOrigin);
        
        _editedItemRenderer = item;
        
        if (!col.renderIsEditable)
        {
            var dx:Number = 0;
            var dy:Number = 0; // TODO: (dloverin) why was this -2;
            var dw:Number = 0;
            var dh:Number = 0 // TODO: (dloverin) whay was this 4;
            
            // if this isn't implemented, use an input control as editor
            if (!itemEditorInstance)
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
                
                
                //                if (itemEditor == DataGridColumn.defaultItemEditorFactory)
                //                {
                //                    // if it is the default factory, see if someone
                //                    // overrode it with this style
                //                    var c:Class = getStyle("defaultDataGridItemEditor");
                //                    if (c)
                //                    {
                //                        var fontName:String =
                //                            StringUtil.trimArrayElements(col.getStyle("fontFamily"), ",");
                //                        var fontWeight:String = col.getStyle("fontWeight");
                //                        var fontStyle:String = col.getStyle("fontStyle");
                //                        var bold:Boolean = (fontWeight == "bold");
                //                        var italic:Boolean = (fontStyle == "italic");
                //                        
                //                        var flexModuleFactory:IFlexModuleFactory =
                //                            getFontContext(fontName, bold, italic);
                //                        
                //                        itemEditor = col.itemEditor = new ContextualClassFactory(
                //                            c, flexModuleFactory);
                //                    }
                //                }
                
                //                // TODO: (dloverin) do we need this properties?                
                //                dx = col.editorXOffset;
                //                dy = col.editorYOffset;
                //                dw = col.editorWidthOffset;
                //                dh = col.editorHeightOffset;
                
                itemEditorInstance = itemEditor.newInstance();
                itemEditorInstance.owner = dataGrid;
                itemEditorInstance.data = IGridItemRenderer(item).data;
                itemEditorInstance.value = itemEditorInstance.data[col.dataField];
                itemEditorInstance.rowIndex = rowIndex;
                itemEditorInstance.columnIndex = columnIndex;
                itemEditorInstance.column = col;
                itemEditorInstance.hasFocusableChildren = true;
                
                UIComponent(itemEditorInstance).styleName = col;
                if (dataGrid.itemEditorLayer)
                {
                    dataGrid.itemEditorLayer.addElement(itemEditorInstance);
                    dataGrid.hasFocusableChildren = true;
                }
            }
            
            // give it the right size, look and placement
            if (itemEditorInstance is IInvalidating)
                IInvalidating(itemEditorInstance).validateNow();
            
            // TODO (dloverin): Should IGridItemEditor implement IUIComponent? Why isn't IVisualElement enough?
            if (itemEditorInstance is IUIComponent)
            {
                // position and set the size of the editor.
                IUIComponent(itemEditorInstance).move(cellBounds.x + dx, cellBounds.y + dy);
                IUIComponent(itemEditorInstance).setActualSize(
                    Math.min(item.width + dw, 
                        grid.width - 1 - itemEditorInstance.x),
                    Math.min(item.height + dh, 
                        grid.height - itemEditorInstance.y));
                
                // set the min width and height of the editor to the cell bounds.
                // set the max widht and height of the editor not to exceed the
                // bounds of the application. 
                if (itemEditorInstance is UIComponent)
                {
                    UIComponent(itemEditorInstance).minWidth = cellBounds.width;
                    UIComponent(itemEditorInstance).minHeight = cellBounds.height;
                    
                    // TODO (dloverin): set max width/height not to exceed the width
                    // of the application.
                }
                
                
            }
            itemEditorInstance.prepare();
            DisplayObject(dataGrid.itemEditorLayer).visible = true;
            itemEditorInstance.visible = true;
            
            itemEditorInstance.addEventListener(FocusEvent.FOCUS_OUT, itemEditorInstance_FocusOutHandler);

            // listen for keyStrokes on the itemEditorInstance (which lets the grid supervise for ESC/ENTER)
            itemEditorInstance.addEventListener(KeyboardEvent.KEY_DOWN, itemEditorInstance_keyDownHandler);
            itemEditorInstance.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler, false, 1000);
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
                
                dataGrid.hasFocusableChildren = true;
                if (dataGrid.scroller)
                    dataGrid.scroller.hasFocusableChildren = true;
                
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
                    fm.setFocus(IFocusManagerComponent(o));
                
                editedItemRenderer.addEventListener(FocusEvent.FOCUS_OUT, itemEditorInstance_FocusOutHandler);
                
                // listen for keyStrokes on the itemEditorInstance (which lets the grid supervise for ESC/ENTER)
                editedItemRenderer.addEventListener(KeyboardEvent.KEY_DOWN, itemEditorInstance_keyDownHandler);
                editedItemRenderer.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler, false, 1000);

                // It would be nice to hide the selection on the cell while it is
                // being edited to provide better contrast for the focus rect 
                // around the controls.
            
            }
        }
        
        if (grid.focusManager)
            grid.focusManager.defaultButtonEnabled = false;

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
        
        // Dispatch our item editor created event
        // TODO (dloverin): should we create an equivalent event?
        
//            var event:DataGridEvent =
//                new DataGridEvent(DataGridEvent.ITEM_EDITOR_CREATE, false, true, colIndex, null, rowIndex);
//            dataGrid.dispatchEvent(event);
    }
    
    /**
     *  @private
     * 
     *  Start editing a cell for a specified row and column index.
     *  
     *  Dispatches a <code>DataGridEditEvent.START_GRID_ITEM_EDITOR_SESSION
     *  </code> event. 
     * 
     *  @param rowIndex The zero-based row index of the cell to edit.
     * 
     *  @param columnIndex The zero-based column index of the cell to edit.
     */
    public function startItemEditorSession(rowIndex:int, columnIndex:int):Boolean
    {
        
        var dataGridEvent:DataGridEditEvent =
            new DataGridEditEvent(DataGridEditEvent.START_GRID_ITEM_EDITOR_SESSION, false, true);
        
        // The BEGIN_GRID_ITEM_EDITOR_CREATION event is cancelable
        dataGridEvent.rowIndex = Math.min(rowIndex, grid.dataProvider.length - 1);
        dataGridEvent.columnIndex = Math.min(columnIndex, grid.columns.length - 1);
        dataGridEvent.column = grid.columns.getItemAt(columnIndex) as GridColumn;
        
        //dataGridEvent.dataField = grid.columns.getItemAt(columnIndex).dataField;
        //dataGridEvent.itemRenderer = itemRenderer;
        if (!dataGrid.dispatchEvent(dataGridEvent))
        {
            lastEditedItemPosition = { columnIndex: columnIndex, rowIndex: rowIndex };
            return true;
        }
        
        return false;
    }
    
    /** 
     *  @private
     * 
     *  Ends a currently active editor.
     * 
     *  @param cancel If false the data in the editor is saved into the item. 
     *  Otherwise the data in the editor is discarded. 
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
            return endEdit("");
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
            // Notify event that the editor session is cancelled.
            // This event cannot be cancelled.
            var dataGridEvent:DataGridEditEvent =
                new DataGridEditEvent(DataGridEditEvent.CANCEL_GRID_ITEM_EDITOR_SESSION);
            
            dataGridEvent.columnIndex = editedItemPosition.columnIndex;
            dataGridEvent.column = itemEditorInstance.column;
            dataGridEvent.rowIndex = editedItemPosition.rowIndex;
            dataGrid.dispatchEvent(dataGridEvent);
            
            destroyItemEditor();
        }
        else if (editedItemRenderer)
        {
            dataGrid.setFocus();
        }

    }
    
    /**
     *  @private
     *  When the user finished editing an item, this method is called.
     * 
     *  
     */
    // TODO (dloverin): remove reason from this function
    
    private function endEdit(reason:String):Boolean
    {
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
            // TODO (dloverin): need to dispatch a cancel event in this case
            inEndEdit = false;
            return false;
        }
        
        var dataGridEvent:DataGridEditEvent =
            new DataGridEditEvent(DataGridEditEvent.SAVE_GRID_ITEM_EDITOR_SESSION, false, true);
        
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
            var reason:String;
            if (!coord)
            {
                reason = "DataGridEventReason.OTHER";
            }
            else
            {
                reason = (!editedItemPosition || coord.rowIndex == editedItemPosition.rowIndex) ?
                    "DataGridEventReason.NEW_COLUMN" :
                    "DataGridEventReason.NEW_ROW";
            }
            if (!endEdit(reason) && reason != "DataGridEventReason.OTHER")
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
        //        if (displayableColumns.length != _columns.length)
        //        {
        //            for (var i:int = 0; i < displayableColumns.length; i++)
        //            {
        //                if (displayableColumns[i].colNum >= columnIndex)
        //                {
        //                    columnIndex = i;
        //                    break;
        //                }
        //            }
        //            if (i == displayableColumns.length)
        //                columnIndex = 0;
        //        }
        
        // trace("commitEditedItemPosition ", coord.rowIndex, selectedIndex);
        
        //        var needChangeEvent:Boolean = false;
        //        if (selectedIndex != coord.rowIndex)
        //        {
        //            commitSelectedIndex(coord.rowIndex);
        //            needChangeEvent = true;
        //        }
        //        
        
        dataGrid.ensureCellIsVisible(rowIndex, columnIndex);
        
        // get the actual references for the column, row, and item
        var item:IVisualElement = grid.getItemRendererAt(rowIndex, columnIndex);
        if (!item)
        {
            // assume that editing was cancelled
            commitEditedItemPosition(null);
            return;
        }
        //        if (!isItemEditable(item.data))
        //        {
        //            // assume that editing was cancelled
        //            commitEditedItemPosition(null);
        //            return;
        //        }
        
        //        if (needChangeEvent)
        //        {
        //            var evt:ListEvent = new ListEvent(ListEvent.CHANGE);
        //            evt.columnIndex = coord.columnIndex;
        //            evt.rowIndex = coord.rowIndex;;
        //            evt.itemRenderer = item;
        //            dataGrid.dispatchEvent(evt);
        //        }
        
        createItemEditor(rowIndex, columnIndex);
        
        // if rendererIsEditor, don't apply the data as the data may have already changed in some way.
        // This can happen if clicking on a checkbox rendererIsEditor as the checkbox will try to change
        // its value as we try to stuff in an old value here.
        //if (!columns.getItemAt(event.columnIndex).rendererIsEditor)
        //            itemEditorInstance = editedItemRenderer;
        
        if (itemEditorInstance is IInvalidating)
            IInvalidating(itemEditorInstance).validateNow();
        
        //            if (itemEditorInstance is IIMESupport)
        //                IIMESupport(itemEditorInstance).imeMode =
        //                    (columns.getItemAt(event.columnIndex).imeMode == null) ? _imeMode : columns[event.columnIndex].imeMode;
        
        var fm:IFocusManager = grid.focusManager;
        // trace("setting focus to item editor");
        if (itemEditorInstance is IFocusManagerComponent)
            fm.setFocus(IFocusManagerComponent(itemEditorInstance));
        
        lastEditedItemPosition = _editedItemPosition;
        
        // Notify event that a new editor is starting.
        var dataGridEvent:DataGridEditEvent =
            new DataGridEditEvent(DataGridEditEvent.OPEN_GRID_ITEM_EDITOR_SESSION);
        
        dataGridEvent.columnIndex = editedItemPosition.columnIndex;
        dataGridEvent.column = dataGrid.columns.getItemAt(columnIndex) as GridColumn;
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
     *  Find the next editable cell. 
     * 
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
        return (dataGrid.editable && GridColumn(grid.columns.getItemAt(columnIndex)).editable);
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
        lastEvent = event;
        
        if (event.keyCode == dataGrid.editKey)
        {
            // Edit the last column edited. If now last column then try to 
            // edit the first column.
            var nextCell:Point = null;
            if (dataGrid.isRowSelectionMode())
            {
                var lastColumn:int = lastEditedItemPosition ? lastEditedItemPosition.columnIndex : 0;
                nextCell = getNextEditableCell(dataGrid.grid.caretRowIndex, 
                    lastColumn - 1,
                    false);
            }
            else
            {
                nextCell = new Point(grid.caretRowIndex, grid.caretColumnIndex); 
            }
            
            if (nextCell)
                startItemEditorSession(nextCell.x, nextCell.y);
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
        }
    }
    
    /**
     *  @private
     * 
     */
    private function grid_gridMouseDownHandler(event:GridEvent):void
    {
        lastEvent = event;
        
        const rowIndex:int = event.rowIndex; //gridDimensions.getRowIndexAt(eventGridXY.x, eventGridXY.y);
        const columnIndex:int = event.columnIndex; //gridDimensions.getColumnIndexAt(eventGridXY.x, eventGridXY.y);
        
//        trace("grid_gridMouseDownHandler: (rowIndex, columnIndex) = (" + rowIndex + "," + columnIndex + ")");
        
        // item editor handling
        var r:IVisualElement;
        
        r = event.itemRenderer; // grid.getItemRendererAt(rowIndex, columnIndex);
        
        lastItemDown = null;
        
        // if selection is being modified with shift or ctrl keys then
        // don't start up an editor session.
        if (event.shiftKey || event.ctrlKey)
            return;
        
        //            var isItemEditor:Boolean = itemEditorInstance && grid.contains(DisplayObject(itemEditorInstance));
        //            
        //            // If it isn't an item renderer, or an item editor do default behavior
        //            if (!isItemEditor)
        //            {
       // trace("mouseDown rowIndex is selected = " + priorSelectedIndices.indexOf(rowIndex));
        
        var pos:Point;
        if (r && wasCellPreviouslySelected(rowIndex, columnIndex))
        {
            lastItemDown = r;
            
            //                pos = itemRendererToIndices(r);
            
            var bEndedEdit:Boolean = true;
            
            if (itemEditorInstance)
            {
                if (grid.columns[columnIndex].editable == false)
                {
                    endEdit("DataGridEventReason.OTHER");
                    bEndedEdit = true;
                }
                else
                {
                    //Possible to get here and not have an editedItemPosition
                    if (editedItemPosition)
                    {
                        bEndedEdit = endEdit(editedItemPosition.rowIndex == pos.y ?
                            "DataGridEventReason.NEW_COLUMN" :
                            "DataGridEventReason.NEW_ROW");
                    }
                    else
                    {
                        bEndedEdit = false;
                    }
                }
            }
            
            // if we didn't end edit session, don't do default behavior (call super)
            if (!bEndedEdit)
                return;
        }
        else
        {
            // trace("end edit?");
            if (itemEditorInstance)
                endEdit("DataGridEventReason.OTHER");
        }
        //            }
        
    }
    
    /**
     *  @private
     * 
     *  If clicked on a the same cell as mouse down then start editing the cell.
     */
    private function grid_gridMouseUpHandler(event:GridEvent):void
    {
        //            const eventStageXY:Point = new Point(event.stageX, event.stageY);
        //            const eventGridXY:Point = grid.globalToLocal(eventStageXY);
        //            const gridDimensions:GridDimensions = GridLayout(grid.layout).gridDimensions;
        lastEvent = event;
        
        const eventRowIndex:int = event.rowIndex; //gridDimensions.getRowIndexAt(eventGridXY.x, eventGridXY.y);
        const eventColumnIndex:int = event.columnIndex; //gridDimensions.getColumnIndexAt(eventGridXY.x, eventGridXY.y);
        
        // Only start an edit if the row is the only selected row.
        // Only start editing when one row is selected.
        if (dataGrid.selectionLength != 1)
            return;
        
        const rowIndex:int = eventRowIndex;
        var columnIndex:int = eventColumnIndex;
        var pos:Point;
        
        var r:IVisualElement = event.itemRenderer; // grid.getItemRendererAt(rowIndex, eventColumnIndex);
        //trace("grid_gridMouseUpHandler: itemRenderer = " + event.itemRenderer);  
        if (r && r != itemEditorInstance && 
            (lastItemDown == r || (lastItemDown && grid.contains(DisplayObject(lastItemDown)))))
        {
            // if lastItemDown != r, we clicked in one cell and dragged to another.
            // if lastItemFocused is in that cell, then we give lastItemDown the
            // edit session
            if (lastItemDown != r)
                r = lastItemDown;
            
            lastItemFocused = null;
            pos = new Point(rowIndex, columnIndex);
            
            if (pos && pos.y >= 0 && dataGrid.editable && !dontEdit)
            {
                if (grid.columns.getItemAt(pos.x).editable)
                {
                    startItemEditorSession(pos.x, pos.y);
                }
                else
                    // if the item is not editable, set lastPosition to it anyways
                    // so future tabbing starts from there
                    lastEditedItemPosition = { columnIndex: pos.x, rowIndex: pos.y };
            }
        }
        else if (lastItemDown && lastItemDown != itemEditorInstance)
        {
            pos = new Point(rowIndex, columnIndex);
            
            if (pos && pos.y >= 0 && dataGrid.editable && !dontEdit)
            {
                if (grid.columns.getItemAt(pos.x).editable)
                {
                    startItemEditorSession(pos.x, pos.y);
                }
                else
                    // if the item is not editable, set lastPosition to it anyways
                    // so future tabbing starts from there
                    lastEditedItemPosition = { columnIndex: pos.x, rowIndex: pos.y };
            }
        }
        
        lastItemDown = null;            
    }
    
   /**
     *  @private
     *  Closes the itemEditorInstance.
     */
    private function itemEditorInstance_FocusOutHandler(event:FocusEvent):void
    {
        trace("itemEditorInstance_FocusOutHandler " + event.relatedObject);
        if (event.relatedObject && 
           ((itemEditorInstance && DisplayObjectContainer(itemEditorInstance).contains(event.relatedObject)) ||
           (editedItemRenderer && DisplayObjectContainer(editedItemRenderer).contains(event.relatedObject))) )
            return;
        
        // ignore textfields losing focus on mousedowns
        if (!event.relatedObject)
            return;
        
        // trace("endEdit from itemEditorFocusOut");
        if (itemEditorInstance || editedItemRenderer)
            endEdit("DataGridEventReason.OTHER");
        else
            destroyItemEditor();
            
    }
    
    /**
     *  @private
     * 
     *  Default handler for the startItemEditorSession event.
     */
    private function dataGrid_startItemEditorSessionHandler(event:DataGridEditEvent):void
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
            endEdit("DataGridEventReason.OTHER");
            deferFocus();
        }
    }
    
    /**
     *  @private
     * 
     *  Handle keys on the editor to stop the editing session.
     */
    private function itemEditorInstance_keyDownHandler(event:KeyboardEvent):void
    {
        // ESC just kills the editor, no new data
        if (event.keyCode == Keyboard.ESCAPE)
        {
            cancelEdit(); //endEdit(DataGridEventReason.CANCELLED);
        }
        else if (event.ctrlKey && event.charCode == 46)
        {   // Check for Ctrl-.
            cancelEdit(); //endEdit(DataGridEventReason.CANCELLED);
        }
        else if (event.charCode == Keyboard.ENTER && event.keyCode != 229)
        {
            // multiline editors can take the enter key.
            if (!_editedItemPosition)
                return;
            
            //            if (columns.getItemAt(_editedItemPosition.columnIndex).editorUsesEnterKey)
            //                return;
            
            // Enter edits the item, moves down a row
            // The 229 keyCode is for IME compatability. When entering an IME expression,
            // the enter key is down, but the keyCode is 229 instead of the enter key code.
            // Thanks to Yukari for this little trick...
            if (endEdit("DataGridEventReason.NEW_ROW"))
            {
                //                findNextEnterItemRenderer(event);
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
                    
                    var nextCell:Point = getNextEditableCell(lastRow, 
                                                             lastColumn - 1,
                                                             false);
                    if (nextCell)
                        startItemEditorSession(nextCell.x, nextCell.y);
                }                    
            }
        }
    }
    
    /**
     *  @private
     */
    private function editorAncestorResizeHandler(event:Event):void
    {
        endEdit("DataGridEventReason.OTHER");
    }
    
    /**
     *  @private
     */
    private function sandBoxRoot_mouseDownHandler(event:Event):void
    {
        // check if the mouse was clicked outside of the editor. If it was
        // then end the editing session.
        if (event is MouseEvent && 
            (itemEditorInstance &&
            (itemEditorInstance == event.target || 
            IUIComponent(itemEditorInstance).owns(DisplayObject(event.target)))) ||
            (editedItemRenderer == event.target || 
                IUIComponent(editedItemRenderer).owns(DisplayObject(event.target))))
        {
            return;
        }
        
        endEdit("DataGridEventReason.OTHER");
        // set focus back to the grid so grid logic will deal if focus doesn't
        // end up somewhere else
        deferFocus();
    }
    
 
    /**
     *  @private
     *  handle focus changes generated from keyboard keys.
     */
    private function keyFocusChangeHandler(event:FocusEvent):void
    {
        // if we tabbed out of the edit then prevent the tab and
        // save the edit. Next start up a new edit session in the
        // next cell.
        // TODO (dloverin): do I need to add the TAB key check here.
        //                  look at flash bug (workaround in focus managere
        //                  and handle it if so.
        trace("keyFocusChangeHandler");
        if (itemEditorInstance || editedItemRenderer)
        {
            var nextObject:IFocusManagerComponent = grid.focusManager.getNextFocusManagerComponent(event.shiftKey);
            if (nextObject == itemEditorInstance ||
                (itemEditorInstance && !DisplayObjectContainer(itemEditorInstance).contains(DisplayObject(nextObject))) ||
                nextObject == editedItemRenderer ||
                (editedItemRenderer && !DisplayObjectContainer(editedItemRenderer).contains(DisplayObject(nextObject))))
            {
                event.preventDefault();
                endEdit("");
                
                var nextCellPosition:Point = getNextEditableCell(lastEditedItemPosition.rowIndex,
                                                                 lastEditedItemPosition.columnIndex,
                                                                 event.shiftKey);
                if (nextCellPosition)
                    startItemEditorSession(nextCellPosition.x, nextCellPosition.y);
            }
        }
    }
    
}
}