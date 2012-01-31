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

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import mx.collections.IList;
import mx.core.IFactory;
import mx.core.mx_internal;
import mx.managers.IFocusManagerComponent;

import spark.components.supportClasses.GridDimensions;
import spark.components.supportClasses.GridEvent;
import spark.components.supportClasses.GridLayout;
import spark.components.supportClasses.GridSelection;
import spark.components.supportClasses.SelectionMode;
import spark.components.supportClasses.SkinnableContainerBase;
import spark.core.NavigationUnit;

use namespace mx_internal;

/**
 *  TBD
 */
public class DataGrid extends SkinnableContainerBase implements IFocusManagerComponent
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
    //  grid
    //----------------------------------

    [SkinPart(required="false", type="spark.components.Grid")]
    
    /**
     *  TBD
     */
    public var grid:spark.components.Grid;
    
    //----------------------------------
    //  scroller
    //----------------------------------
    
    [SkinPart(required="false", type="spark.components.Scroller")]
    
    /**
     *  TBD
     */
    public var scroller:Scroller;    
    
    //--------------------------------------------------------------------------
    //
    //  Properties 
    //
    //--------------------------------------------------------------------------
    
    private function dispatchChangeEvent(type:String):void
    {
        if (hasEventListener(type))
            dispatchEvent(new Event(type));
    }
    
    // TBD(hmuller): baselinePosition override
    // TBD(hmuller): methods to expose the selection
    // TBD(hmuller): methods to enable scrolling
    
    
    //----------------------------------
    //  dataProvider (delgates to grid.dataProvider)
    //----------------------------------

    [Bindable("dataProviderChanged")]
    
    private var _dataProvider:IList = null;  // same default value as Grid dataProvider
    
    /**
     *  @copy spark.components.Grid#dataProvider
     * 
     *  @default nulll
     */
    public function get dataProvider():IList
    {
        return (grid) ? grid.dataProvider : _dataProvider;
    }
    
    /**
     *  @private
     */
    public function set dataProvider(value:IList):void
    {
        if (dataProvider == value) // note: we're using the get method, not _dataProvider
            return;
        
        _dataProvider = value;
        if (grid)
            grid.dataProvider = value;
        
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
    //  columns (delgates to grid.columns)
    //----------------------------------
    
    [Bindable("columnsChanged")]
    
    private var _columns:IList = null;  // same default value as Grid columns
    
    /**
     *  @copy spark.components.Grid#columns
     * 
     *  @default null
     */
    public function get columns():IList
    {
        return (grid) ? grid.columns : _columns;
    }
    
    /**
     *  @private
     */
    public function set columns(value:IList):void
    {
        if (columns == value) // note: we're using the get method, not _columns
            return;
        
        _columns = value;
        if (grid)
            grid.columns = value;
        
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
    
    //----------------------------------
    //  anchorColumnIndex (delgates to grid.anchorColumnIndex)
    //----------------------------------
    
    [Bindable("anchorColumnIndexChanged")]
    
    private var _anchorColumnIndex:int = 0;  // same default value as Grid anchorColumnIndex
    
    /**
     *  @copy spark.components.Grid#anchorColumnIndex
     * 
     *  @default null
     */
    public function get anchorColumnIndex():int
    {
        return (grid) ? grid.anchorColumnIndex : _anchorColumnIndex;
    }
    
    /**
     *  @private
     */
    public function set anchorColumnIndex(value:int):void
    {
        if (anchorColumnIndex == value) // note: we're using the get method, not _anchorColumnIndex
            return;
        
        _anchorColumnIndex = value;
        if (grid)
            grid.anchorColumnIndex = value;
        
        dispatchChangeEvent("anchorColumnIndexChanged");
    }
    

    //----------------------------------
    //  anchorRowIndex (delgates to grid.anchorRowIndex)
    //----------------------------------
    
    [Bindable("anchorRowIndexChanged")]
    
    private var _anchorRowIndex:int = 0;  // same default value as Grid anchorRowIndex
    
    /**
     *  @copy spark.components.Grid#anchorRowIndex
     * 
     *  @default null
     */
    public function get anchorRowIndex():int
    {
        return (grid) ? grid.anchorRowIndex : _anchorRowIndex;
    }
    
    /**
     *  @private
     */
    public function set anchorRowIndex(value:int):void
    {
        if (anchorRowIndex == value) // note: we're using the get method, not _anchorRowIndex
            return;
        
        _anchorRowIndex = value;
        if (grid)
            grid.anchorRowIndex = value;
        
        dispatchChangeEvent("anchorRowIndexChanged");
    }
    
    //----------------------------------
    //  caretColumnIndex (delgates to grid.caretColumnIndex)
    //----------------------------------
    
    [Bindable("caretColumnIndexChanged")]
    
    private var _caretColumnIndex:int = -1;  // same default value as Grid caretColumnIndex
    
    /**
     *  @copy spark.components.Grid#caretColumnIndex
     * 
     *  @default null
     */
    public function get caretColumnIndex():int
    {
        return (grid) ? grid.caretColumnIndex : _caretColumnIndex;
    }
    
    /**
     *  @private
     */
    public function set caretColumnIndex(value:int):void
    {
        if (caretColumnIndex == value) // note: we're using the get method, not _caretColumnIndex
            return;
        
        _caretColumnIndex = value;
        if (grid)
            grid.caretColumnIndex = value;
        
        dispatchChangeEvent("caretColumnIndexChanged");
    }
    
    
    //----------------------------------
    //  caretRowIndex (delgates to grid.caretRowIndex)
    //----------------------------------
    
    [Bindable("caretRowIndexChanged")]
    
    private var _caretRowIndex:int = -1;  // same default value as Grid caretRowIndex
    
    /**
     *  @copy spark.components.Grid#caretRowIndex
     * 
     *  @default null
     */
    public function get caretRowIndex():int
    {
        return (grid) ? grid.caretRowIndex : _caretRowIndex;
    }
    
    /**
     *  @private
     */
    public function set caretRowIndex(value:int):void
    {
        if (caretRowIndex == value) // note: we're using the get method, not _caretRowIndex
            return;
        
        _caretRowIndex = value;
        if (grid)
            grid.caretRowIndex = value;
        
        dispatchChangeEvent("caretRowIndexChanged");
    }
    
    //----------------------------------
    //  hoverColumnIndex (delgates to grid.hoverColumnIndex)
    //----------------------------------
    
    [Bindable("hoverColumnIndexChanged")]
    
    private var _hoverColumnIndex:int = -1;  // same default value as Grid hoverColumnIndex
    
    /**
     *  @copy spark.components.Grid#hoverColumnIndex
     * 
     *  @default null
     */
    public function get hoverColumnIndex():int
    {
        return (grid) ? grid.hoverColumnIndex : _hoverColumnIndex;
    }
    
    /**
     *  @private
     */
    public function set hoverColumnIndex(value:int):void
    {
        if (hoverColumnIndex == value) // note: we're using the get method, not _hoverColumnIndex
            return;
        
        _hoverColumnIndex = value;
        if (grid)
            grid.hoverColumnIndex = value;
        
        dispatchChangeEvent("hoverColumnIndexChanged");
    }
    
    
    //----------------------------------
    //  hoverRowIndex (delgates to grid.hoverRowIndex)
    //----------------------------------
    
    [Bindable("hoverRowIndexChanged")]
    
    private var _hoverRowIndex:int = -1;  // same default value as Grid hoverRowIndex
    
    /**
     *  @copy spark.components.Grid#hoverRowIndex
     * 
     *  @default null
     */
    public function get hoverRowIndex():int
    {
        return (grid) ? grid.hoverRowIndex : _hoverRowIndex;
    }
    
    /**
     *  @private
     */
    public function set hoverRowIndex(value:int):void
    {
        if (hoverRowIndex == value) // note: we're using the get method, not _hoverRowIndex
            return;
        
        _hoverRowIndex = value;
        if (grid)
            grid.hoverRowIndex = value;
        
        dispatchChangeEvent("hoverRowIndexChanged");
    }
    
    //----------------------------------
    //  selectionMode delegates to (delegates to grid.selectionMode)
    //----------------------------------    
    
    [Bindable("selectionModeChanged")]
    
    /**
     *  TBD
     */
    public function get selectionMode():String
    {
        return grid.selectionMode;
    }
    
    /**
     *  @private
     */
    public function set selectionMode(value:String):void
    {
        if (selectionMode == value)
            return;
        
        grid.selectionMode = value;
        dispatchChangeEvent("selectionModeChanged");        
    }
    
    //----------------------------------
    //  gridDimensions (private, read-only)
    //----------------------------------
    
    private var _gridDimensions:GridDimensions = null;
    
    private function get gridDimensions():GridDimensions
    {
        if (!_gridDimensions)
            _gridDimensions = new GridDimensions();  // TBD(hmuller):delegate to protected createGridDimensions()
        return _gridDimensions;
    }

    //----------------------------------
    //  gridSelection (private)
    //----------------------------------    

    private var _gridSelection:GridSelection = null;
    
    private function get gridSelection():GridSelection
    {
        if (!_gridSelection)
            _gridSelection = new GridSelection(grid);  // TBD(hmuller):delegate to protected createGridSelection()
        return _gridSelection;
    }

    //--------------------------------------------------------------------------
    //
    //  GridEvent handlers
    //
    //--------------------------------------------------------------------------

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
        const columnIndex:int = event.columnIndex;
        
        if (event.ctrlKey)
        {
            if (!toggleSelection(rowIndex, columnIndex))
                return;
            
            // ctrl-click updates caret and anchor.
            caretRowIndex = anchorRowIndex = rowIndex;
            caretColumnIndex = anchorColumnIndex = columnIndex;
        }
        else if (event.shiftKey && 
            (caretRowIndex != -1) && (caretColumnIndex != -1) &&
            (selectionMode == SelectionMode.MULTIPLE_ROWS || 
                selectionMode == SelectionMode.MULTIPLE_CELLS))
        {
            if (!extendSelection(anchorRowIndex, anchorColumnIndex, 
                rowIndex, columnIndex))
            {
                return;
            }
            
            // shift-click always updates caret.
            caretRowIndex = rowIndex;
            caretColumnIndex = columnIndex;                
        }
        else
        {
            if (gridSelection.isRowSelectionMode())
                gridSelection.setRow(rowIndex);
            else if (gridSelection.isCellSelectionMode())
                gridSelection.setCell(rowIndex, columnIndex);
            else
                return;
            
            // click updates caret and anchor.
            caretRowIndex = anchorRowIndex = rowIndex;
            caretColumnIndex = anchorColumnIndex = columnIndex;
        }
        
        invalidateDisplayList();
    }
    
    private function toggleSelection(rowIndex:int, columnIndex:int):Boolean
    {
        if (gridSelection.isRowSelectionMode())
        {
            if (gridSelection.containsRow(rowIndex))
                gridSelection.removeRow(rowIndex);
            else if (selectionMode == SelectionMode.MULTIPLE_ROWS)
                gridSelection.addRow(rowIndex);
            else
                gridSelection.setRow(rowIndex);
            return true;
        }
        else if (gridSelection.isCellSelectionMode())
        {
            if (gridSelection.containsCell(rowIndex, columnIndex))
                gridSelection.removeCell(rowIndex, columnIndex);
            else if (selectionMode == SelectionMode.MULTIPLE_CELLS)
                gridSelection.addCell(rowIndex, columnIndex);
            else
                gridSelection.setCell(rowIndex, columnIndex);
            return true;
        }
        
        return false;
    }
    
    private function extendSelection(anchorRowIndex:int, 
        anchorColumnIndex:int,
        caretRowIndex:int, 
        caretColumnIndex:int):Boolean
    {
        // The caller is responsible for ensuring there is a valid caret.
        
        if (anchorRowIndex < 0 || anchorColumnIndex < 0)
            return false;
        
        const startRowIndex:int = Math.min(anchorRowIndex, caretRowIndex);
        const endRowIndex:int = Math.max(anchorRowIndex, caretRowIndex);
        
        if (selectionMode == SelectionMode.MULTIPLE_ROWS)
        {
            const rowIndices:Vector.<int> = 
                new Vector.<int>(1 + (endRowIndex - startRowIndex), true);
            for (var selectedRowIndex:int = startRowIndex; 
                selectedRowIndex <= endRowIndex; selectedRowIndex++)
            {
                rowIndices[selectedRowIndex - startRowIndex] = selectedRowIndex;
            }
            gridSelection.setRows(rowIndices);
            return true;
        }
        else if (selectionMode == SelectionMode.MULTIPLE_CELLS)
        {
            const startColumnIndex:int = 
                Math.min(anchorColumnIndex, caretColumnIndex);
            const endColumnIndex:int = 
                Math.max(anchorColumnIndex, caretColumnIndex);                
            gridSelection.setCellRegion(startRowIndex, startColumnIndex,
                endRowIndex - startRowIndex + 1,
                endColumnIndex - startColumnIndex + 1);
            return true;
        }            
        
        return false;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Build in basic keyboard navigation support in Grid. 
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {   
        super.keyDownHandler(event);
        
        if (event.isDefaultPrevented())
            return;
        
        // Was the space bar hit? 
        if (event.keyCode == Keyboard.SPACE)
        {
            if (caretRowIndex != -1 && caretColumnIndex != -1)
            {
                if (event.ctrlKey)
                {
                    if (toggleSelection(caretRowIndex, caretColumnIndex))
                    {
                        anchorRowIndex = caretRowIndex;
                        anchorColumnIndex = caretColumnIndex;
                    }
                }
                else if (event.shiftKey)
                {
                    extendSelection(anchorRowIndex, anchorColumnIndex, 
                        caretRowIndex, caretColumnIndex);
                }
                else
                {
                    if (gridSelection.isRowSelectionMode())
                        gridSelection.addRow(caretRowIndex);
                    else if (gridSelection.isCellSelectionMode())
                        gridSelection.addCell(caretRowIndex, caretColumnIndex);
                }
                invalidateDisplayList();
            }
            event.preventDefault();
            return; 
        }
        
        // Was some other navigation key hit in combination with ctrl/cmd 
        // or shift?     
        if (event.ctrlKey || event.shiftKey)
            adjustSelectionUponNavigation(event); 
    }
    
    /**
     *  Adjusts the caret and the selection based on what keystroke is used
     *  in combination with a ctrl/cmd key or a shift key.
     */
    protected function adjustSelectionUponNavigation(event:KeyboardEvent):void
    {
        // Some unrecognized key stroke was entered, return. 
        if (!NavigationUnit.isNavigationUnit(event.keyCode))
            return; 
        
        // If rtl layout, need to swap Keyboard.LEFT and Keyboard.RIGHT.
        var navigationUnit:uint = mapKeycodeForLayoutDirection(event);
        
        if (!setCaretToNavigationDestination(navigationUnit))
            return;
        
        event.preventDefault(); 
        
        // If its a ctrl/cmd key-nav key combination, there is nothing
        // more to do then set the caret.
        // The shift key-nav key combination extends the selection.
        if (event.shiftKey)
        {
            if (!extendSelection(anchorRowIndex, anchorColumnIndex, 
                caretRowIndex, caretColumnIndex))
            {
                return;
            }
        }
        
        invalidateDisplayList();
        
        // TBD: ensure caret is visible
        
    }
    
    public function setCaretToNavigationDestination(navigationUnit:uint):Boolean
    {
        if (caretRowIndex == -1 || caretColumnIndex == -1)
            return false;
        
        const inRows:Boolean = gridSelection.isRowSelectionMode();
        
        const rowCount:int = getDataProviderLength();
        const columnCount:int = getColumnsLength();
        
        switch (navigationUnit)
        {
            case NavigationUnit.LEFT: 
            {
                if (!inRows && caretColumnIndex > 0)
                    caretColumnIndex--;
                break;
            }
                
            case NavigationUnit.RIGHT:
            {
                if (!inRows && caretColumnIndex + 1 < columnCount)
                    caretColumnIndex++;
                break;
            } 
                
            case NavigationUnit.UP:
            {
                if (caretRowIndex > 0)
                    caretRowIndex--;
                break; 
            }
                
            case NavigationUnit.DOWN:
            {
                if (caretRowIndex + 1 < rowCount)
                    caretRowIndex++;
                break; 
            }
                
            case NavigationUnit.PAGE_UP:
            {
                // TBD: try for 20 lines for now.
                caretRowIndex  = Math.max(0, caretRowIndex - 20);
                break; 
            }
            case NavigationUnit.PAGE_DOWN:
            {
                // TBD: try for 20 lines for now.
                caretRowIndex = Math.min(rowCount - 1, caretRowIndex + 20);
                break; 
            }
                
            case NavigationUnit.HOME:
            {
                caretRowIndex = 0;
                caretColumnIndex = 0; 
                break;
            }
                
            case NavigationUnit.END:
            {
                caretRowIndex = rowCount - 1;
                caretColumnIndex = columnCount - 1;
                break;
            }
                
            default: 
            {
                return false;
            }
        }
        
        return true;
    }
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == grid)
        {
            grid.dataProvider = _dataProvider;
            grid.columns = _columns;
            grid.layout = new GridLayout();  // TBD(hmuller): delegate to protected createGridLayout()
            grid.gridDimensions = gridDimensions;
            grid.gridSelection = gridSelection;
            grid.addEventListener(GridEvent.GRID_MOUSE_DOWN, gridMouseDownHandler);
            grid.addEventListener(GridEvent.GRID_ROLL_OVER, gridRollOverHandler);
            grid.addEventListener(GridEvent.GRID_ROLL_OUT, gridRollOutHandler);            
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
            grid.removeEventListener(GridEvent.GRID_MOUSE_DOWN, gridMouseDownHandler);
            grid.removeEventListener(GridEvent.GRID_ROLL_OVER, gridRollOverHandler);
            grid.removeEventListener(GridEvent.GRID_ROLL_OUT, gridRollOutHandler);            
            grid.layout = null;
            grid.gridSelection = null;
            grid.gridDimensions = null;
            grid.dataProvider = null;
            grid.columns = null;
        }
    }
    
    
    
}
}