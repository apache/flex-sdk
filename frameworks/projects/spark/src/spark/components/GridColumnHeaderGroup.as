////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
import mx.managers.ILayoutManagerClient;

import spark.components.gridClasses.CellPosition;
import spark.components.gridClasses.GridColumn;
import spark.components.gridClasses.GridColumnHeaderView;
import spark.components.gridClasses.GridDimensionsView;
import spark.components.gridClasses.GridHeaderLayout;
import spark.components.gridClasses.GridHeaderViewLayout;
import spark.components.gridClasses.GridLayout;
import spark.components.gridClasses.GridView;
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
 *  Dispatched after a <code>gridMouseDown</code> event 
 *  if the mouse moves before the button is released.
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
 *  Dispatched after a <code>gridMouseDown</code> event 
 *  when the mouse button is released, even
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
 *  Dispatched after a <code>separatorMouseDown</code> event 
 *  if the mouse moves before the button is released.
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
 *  Dispatched after a <code>separatorMouseDown</code> event 
 *  when the mouse button is released, even if the mouse is 
 *  no longer within the separator affordance.
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
 *  area, so that separator events are dispatched when the mouse is closer than 
 *  <code>separatorMouseWidth</code> to the horizontal midpoint of a separator.</p> 
 * 
 *  @default 5
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
*/
[Style(name="separatorAffordance", type="Number", format="Length", inherit="no")]

/**
 *  Bottom inset, in pixels, for all header renderers. 
 * 
 *  @default 0
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Style(name="paddingBottom", type="Number", format="Length", inherit="no")]

/**
 *  Left inset, in pixels, for the first header renderer. 
 * 
 *  @default 0
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Style(name="paddingLeft", type="Number", format="Length", inherit="no")]

/**
 *  Right inset, in pixels, for the last header renderer. 
 * 
 *  @default 0
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Style(name="paddingRight", type="Number", format="Length", inherit="no")]

/**
 *  Top inset, in pixels, for all header renderers. 
 * 
 *  @default 0
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Style(name="paddingTop", type="Number", format="Length", inherit="no")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("GridColumnHeaderGroup.png")]

/**
 *  The GridColumnHeaderGroup class displays a row of column headers 
 *  and separators aligned with the grid's layout.  
 * 
 *  <p>Headers are rendered by the class specified by the <code>headerRenderer</code> property.
 *  Separators are rendered by the class specified by the <code>columnSeparator</code> property.
 *  The layout, which cannot be changed, is virtual; that means renderers and separators that have been 
 *  scrolled out of view are reused.</p>
 *
 *  @mxml <p>The <code>&lt;s:GridColumnHeaderGroup&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:GridColumnHeaderGroup 
 *    <strong>Properties</strong>
 *    columnSeperator="null"
 *    dataGrid="null"  
 *    downColumnIndex="-1"  
 *    headerRenderer="null"  
 *    hoverColumnIndex="-1" 
 *    selectedColumnIndex="-1"  
 *    highlightSelectedColumn="false" 
 *    visibleSortIndicatorIndices="<i>empty Vector.&lt;int&gt<i>"
 * 
 *    <strong>Styles</strong>
 *    paddingBottom="0"
 *    paddingLeft="0"
 *    paddingRight="0"
 *    paddingTop="0"
 *    separatorAffordance="5" 
 *
 *    <strong>Events</strong>
 *    gridClick="<i>No default</i>"
 *    gridDoubleClick="<i>No default</i>"
 *    gridMouseDown="<i>No default</i>"
 *    gridMouseDrag="<i>No default</i>"
 *    gridMouseUp="<i>No default</i>"
 *    gridMouseRollOut="<i>No default</i>"
 *    gridMouseRollOver="<i>No default</i>"
 *    separatorClick="<i>No default</i>"
 *    separatorDoubleClick="<i>No default</i>"
 *    separatorMouseDrag="<i>No default</i>"
 *    separatorMouseUp="<i>No default</i>"
 *    separatorMouseRollOut="<i>No default</i>"
 *    separatorMouseRollOver="<i>No default</i>"
 *  /&gt;
 *  </pre>
 *
 *  @see Grid
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
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function GridColumnHeaderGroup()
    {
        super();
        
		layout = new GridHeaderLayout();

        // Event handlers that dispatch GridEvents
        
        MouseEventUtil.addDownDragUpListeners(this, 
            gchg_mouseDownDragUpHandler, 
            gchg_mouseDownDragUpHandler, 
            gchg_mouseDownDragUpHandler);

        addEventListener(MouseEvent.MOUSE_MOVE, gchg_mouseMoveHandler);
        addEventListener(MouseEvent.ROLL_OUT, gchg_mouseRollOutHandler);
        addEventListener(MouseEvent.CLICK, gchg_clickHandler);
        addEventListener(MouseEvent.DOUBLE_CLICK, gchg_doubleClickHandler);
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
    //  columnSeparator
    //----------------------------------
    
    private var _columnSeparator:IFactory = null;
    
    [Bindable("columnSeparatorChanged")]
    
    /**
     *  A visual element that's displayed between each column.
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
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
    
    private var _dataGrid:DataGrid = null;
	private var lockedColumnCountChanged:Boolean = false;
    
    [Bindable("dataGridChanged")]
    
    /**
     *  The DataGrid control that defines the column layout and 
     *  horizontal scroll position for this component.
     *  This property is set by the DataGrid control after 
     *  its <code>grid</code> skin part has been added.
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
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
		{
            _dataGrid.grid.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, grid_propertyChangeHandler);
			_dataGrid.grid.removeEventListener("columnsChanged", grid_propertyChangeHandler);				
			_dataGrid.grid.removeEventListener("lockedColumnCountChanged", grid_propertyChangeHandler);			
		}
        
        _dataGrid = value;

        if (_dataGrid && _dataGrid.grid)
		{
            _dataGrid.grid.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, grid_propertyChangeHandler);
			_dataGrid.grid.addEventListener("columnsChanged", grid_propertyChangeHandler);				
			_dataGrid.grid.addEventListener("lockedColumnCountChanged", grid_propertyChangeHandler);	
		}
        
        layout.clearVirtualLayoutCache();

		invalidateSize();
        invalidateDisplayList();
        
        dispatchChangeEvent("dataGridChanged");
    }
    
    /**
     *  @private
     */
    private function grid_propertyChangeHandler(event:Event):void
    {
        const ghl:GridHeaderLayout = layout as GridHeaderLayout;
        if (!ghl)
            return;
        
		const pce:PropertyChangeEvent = event as PropertyChangeEvent;
		if (pce && (pce.property ==  "horizontalScrollPosition"))
			ghl.centerGridColumnHeaderView.horizontalScrollPosition = Number(pce.newValue);
		else if ((event.type == "columnsChanged") || (event.type == "lockedColumnCountChanged"))
			invalidateProperties();
    }
	
    //----------------------------------
    //  downColumnIndex
    //----------------------------------
    
    private var _downColumnIndex:int = -1;
    
    [Bindable("downColumnIndexChanged")]
    
    /**
     *  Specifies the column index of the header renderer currently
     *  being pressed down by the user.
     *  
     *  <p>Setting <code>downColumnIndex</code> to -1 (the default) means 
     *  that the column index is undefined, and the header renderer has 
     *  its <code>down</code> property set to <code>false</code>.</p>
     * 
     *  @default -1
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */
    public function get downColumnIndex():int
    {
        return _downColumnIndex;
    }
    
    /**
     *  @private
     */
    public function set downColumnIndex(value:int):void
    {
        if (_downColumnIndex == value)
            return;
        
        _downColumnIndex = value;
        invalidateDisplayList();
        dispatchChangeEvent("downColumnIndexChanged");
    }
    
    //----------------------------------
    //  headerRenderer
    //----------------------------------
    
    private var _headerRenderer:IFactory = null;
    
    [Bindable("headerRendererChanged")]
    
    /**
     *  The IGridItemRenderer class used to renderer each column header.
     *
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get headerRenderer():IFactory
    {
        return _headerRenderer;  // TODO: find a way to make it possible to specify this with DataGrid...
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
    //  hoverColumnIndex 
    //----------------------------------
    
    private var _hoverColumnIndex:int = -1;
    
    [Bindable("hoverColumnIndexChanged")]
    
    /**
     *  Specifies the column index of the header renderer currently
     *  being hovered over by the user.
     *  
     *  <p>Setting <code>hoverColumnIndex</code> to -1, the default, means that 
     *  the column index is undefined, and the header renderer has its 
     *  <code>hovered</code> property set to <code>false</code>.</p>
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
        invalidateDisplayList();
        dispatchChangeEvent("hoverColumnIndexChanged");
    }
    
    //----------------------------------
    //  selectedColumnIndex 
    //----------------------------------
    
    private var _selectedColumnIndex:int = -1;
    
    [Bindable("selectedColumnIndexChanged")]
    
    /**
     *  Specifies the column index of the header renderer currently selected by the user.
     *  The selected property of the header renderer for selectedColumnIndex will be true 
     *  and false for all other header renderers.
     *  
     *  <p>Setting selectedColumnIndex to -1, the default, means that no column is selected and 
     *  selected property for all header renderers will be false.</p>

     * 
     *  @default -1
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */
    public function get selectedColumnIndex():int
    {
        return _selectedColumnIndex;
    }
    
    /**
     *  @private
     */
    public function set selectedColumnIndex(value:int):void
    {
        if (_selectedColumnIndex == value)
            return;
        
        _selectedColumnIndex = value;
        invalidateDisplayList();
        dispatchChangeEvent("selectedColumnIndexChanged");
    }
        
    //----------------------------------
    //  highlightSelectedColumn 
    //----------------------------------
    
    private var _highlightSelectedColumn:Boolean = false;
    
    [Bindable("highlightSelectedColumnChanged")]
    
    /**
     *  The DefaultGridHeaderRenderer only highlights the selected column when selectedColumnIndex is
     *  valid and highlightSelectedColumn is true.  If this property is set to true and 
     *  the selectedColumnIndex is -1, then the selectedColumnIndex is set to the hoverColumnIndex,
     *  and if that's -1, then the first visible column.
     * 
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */
    public function get highlightSelectedColumn():Boolean
    {
        return _highlightSelectedColumn;
    }
    
    /**
     *  @private
     */
    public function set highlightSelectedColumn(value:Boolean):void
    {
        if (_highlightSelectedColumn == value)
            return;
        
        // If this property's value is being changed to true, make sure that the 
        // initial value of selectedColumnIndex corresponds to a visible column.
        // Tabbing to the DataGrid header shouldn't cause the DataGrid to scroll.
        
        if (value)
        {
            if ((selectedColumnIndex == -1) && (hoverColumnIndex != 1))
                selectedColumnIndex = hoverColumnIndex;
            
            if (dataGrid.grid && !dataGrid.grid.isCellVisible(-1, selectedColumnIndex))
            {
                const visibleColumnIndices:Vector.<int> = dataGrid.grid.getVisibleColumnIndices();
                selectedColumnIndex = (visibleColumnIndices.length > 0) ? visibleColumnIndices[0] : -1;
            }
        }

        _highlightSelectedColumn = value;
        invalidateDisplayList();
        dispatchChangeEvent("highlightSelectedColumnChanged");
    }
        
    //----------------------------------
    //  visibleSortIndicatorIndices
    //----------------------------------
    
    private var _visibleSortIndicatorIndices:Vector.<int> = new Vector.<int>();
    
    [Bindable("visibleSortIndicatorIndicesChanged")]
    
    /**
     *  A vector of column indices corresponding to the header renderers
     *  which currently have their sort indicators visible.
     * 
     *  @default an empty Vector.&lt;int&gt;
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
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
     *  Returns <code>true</code> if the sort indicator for the specified column
     *  is visible.
     *  This is just a more efficient version of:
     *  <pre>
     *      visibleSortIndicatorIndices.indexOf(columnIndex) != -1</pre>
     *
     *  @param columnIndex The 0-based column index of the header renderer's column.
     *
     *  @return <code>true</code> if the sort indicator for the specified column
     *  is visible.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
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
	
	private function createGridColumnHeaderView():Group
	{
		const view:GridColumnHeaderView = new GridColumnHeaderView();
		view.gridColumnHeaderGroup = this;		
		addElement(view);
				
		return view;
	}
		
	/**
	 *  Create and/or configure the GridColumnHeaderViews.  We're assuming that the
	 *  DataGrid's GridViews have already been created.
	 */
	public function configureGridColumnHeaderViews():void
	{
        const ghl:GridHeaderLayout = layout as GridHeaderLayout;
        if (!ghl)
            return;
        
		if (ghl.centerGridColumnHeaderView == null)
			ghl.centerGridColumnHeaderView = createGridColumnHeaderView();
		
		if (dataGrid.lockedColumnCount > 0)
		{
			ghl.leftGridColumnHeaderView = createGridColumnHeaderView();
		}
		else if (ghl.leftGridColumnHeaderView)
		{
			removeElement(ghl.leftGridColumnHeaderView);
			ghl.leftGridColumnHeaderView = null;
		}
		
		const gridLayout:GridLayout = dataGrid.grid.layout as GridLayout;

		GridHeaderViewLayout(ghl.centerGridColumnHeaderView.layout).gridView = gridLayout.centerGridView;
		if (ghl.leftGridColumnHeaderView)
			GridHeaderViewLayout(ghl.leftGridColumnHeaderView.layout).gridView = gridLayout.leftGridView;
	}
	
	/**
     *  Returns the column index corresponding to the specified coordinates,
     *  or -1 if the coordinates are out of bounds. The coordinates are 
     *  resolved with respect to the GridColumnHeaderGroup layout target.
     * 
     *  <p>If all of the columns or rows for the grid have not yet been scrolled
     *  into view, the returned index may only be an approximation, 
     *  based on the <code>typicalItem</code> property of all columns.</p>
     *  
     *  @param x The pixel's x coordinate relative to the <code>columnHeaderGroup</code>.
     * 
     *  @param y The pixel's y coordinate relative to the <code>columnHeaderGroup</code>.
     * 
     *  @return the index of the column or -1 if the coordinates are out of bounds. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getHeaderIndexAt(x:Number, y:Number):int
    {
        // TODO: fix this: x coordinate has to be adjusted
		const view:Group = getColumnHeaderViewAtX(x);
        return GridHeaderViewLayout(view.layout).getHeaderIndexAt(x, y);
    }
    
    /**
     *  Returns the column separator index corresponding to the specified 
     *  coordinates, or -1 if the coordinates don't overlap a separator. The 
     *  coordinates are resolved with respect to the GridColumnHeaderGroup layout target.
     * 
     *  <p>A separator is considered to "overlap" the specified location if the
     *  x coordinate is within <code>separatorMouseWidth</code> of separator's
     *  horizontal midpoint.</p>
     *  
     *  <p>The separator index is the same as the index of the column on the left,
     *  assuming that this component's <code>layoutDirection</code> is <code>"ltr"</code>.  
     *  That means all column headers are flanked by two separators, except for the first
     *  visible column, which just has a separator on the right, and the last visible
     *  column, which just has a separator on the left.</p>
     * 
     *  <p>If all of the columns or rows for the grid have not yet been scrolled
     *  into view, the returned index may only be an approximation, 
     *  based on the <code>typicalItem</code> property of all columns.</p>
     *  
     *  @param x The pixel's x coordinate relative to the <code>columnHeaderGroup</code>.
     * 
     *  @param y The pixel's y coordinate relative to the <code>columnHeaderGroup</code>.
     * 
     *  @return the index of the column or -1 if the coordinates don't overlap a separator.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getSeparatorIndexAt(x:Number, y:Number):int
    {
        // TODO: fix this: x coordinate has to be adjusted        
		const view:Group = getColumnHeaderViewAtX(x);		
        return GridHeaderViewLayout(view.layout).getSeparatorIndexAt(x, y);
    }    
        
    /**
     *  If the requested header renderer is visible, returns a reference to 
     *  the header renderer currently displayed for the specified column. 
     *  Note that once the returned header renderer is no longer visible it 
     *  may be recycled and its properties reset.  
     * 
     *  <p>If the requested header renderer is not visible then, 
     *  each time this method is called, a new header renderer is created.  
     *  The new item renderer is not visible</p>
     * 
     *  <p>The width of the returned renderer is the same as for item renderers
     *  returned by DataGrid/getItemRendererAt().</p>
     *  
     *  @param columnIndex The 0-based column index of the header renderer's column.
     * 
     *  @return The item renderer or null if the column index is invalid.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getHeaderRendererAt(columnIndex:int):IGridItemRenderer
    {
        // TODO: fix this: do the work here, rather than the layout            
		const view:Group = getColumnHeaderViewAtIndex(columnIndex);	
        return GridHeaderViewLayout(view.layout).getHeaderRendererAt(columnIndex);
    }
    
    /**
     *  Returns the current pixel bounds of the specified header (renderer), or null if 
     *  no such column exists.  Header bounds are reported in GridColumnHeaderGroup coordinates.
     * 
     *  <p>If all of the visible columns preceding the specified column have not 
     *  yet been scrolled into view, the returned bounds may only be an approximation, 
     *  based on all of the Grid's <code>typicalItem</code>s.</p>
     * 
     *  @param columnIndex The 0-based index of the column. 
     *  @return A <code>Rectangle</code> that represents the column header's pixel bounds, or null.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */  
    public function getHeaderBounds(columnIndex:int):Rectangle
    {
        // TODO: fix this: do the work here, rather than the layout         
		const view:Group = getColumnHeaderViewAtIndex(columnIndex);		
        return GridHeaderViewLayout(view.layout).getHeaderBounds(columnIndex);
    }
	
	/**
	 *  @private
	 */
	override public function invalidateSize():void
	{
		super.invalidateSize();
		
        const ghl:GridHeaderLayout = layout as GridHeaderLayout;
        if (!ghl)
            return;
        
		if (ghl.leftGridColumnHeaderView)
			ghl.leftGridColumnHeaderView.invalidateSize();
		
		if (ghl.centerGridColumnHeaderView)
			ghl.centerGridColumnHeaderView.invalidateSize();
	}
	
	/**
	 *  @private
	 */
	override public function invalidateDisplayList():void
	{
		super.invalidateDisplayList();
        
        const ghl:GridHeaderLayout = layout as GridHeaderLayout; 
        if (!ghl)
            return;

		if (ghl.leftGridColumnHeaderView)
			ghl.leftGridColumnHeaderView.invalidateDisplayList();
		
		if (ghl.centerGridColumnHeaderView)
			ghl.centerGridColumnHeaderView.invalidateDisplayList();		
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
    private var pressColumnIndex:int = -1;      // column button press occurred on
    private var pressSeparatorIndex:int = -1;   // separator button press occurred on
    
	/** 
	 *  @private
	 *  Return the GridView whose bounds contain the MouseEvent, or null.  Note that the 
	 *  comparison is based strictly on the event's location and the GridViews' bounds.
	 *  The event's target can be anything.
	 */
	private function mouseEventHeaderView(event:MouseEvent):GridColumnHeaderView
	{
		const ghl:GridHeaderLayout = layout as GridHeaderLayout;

		const centerGridColumnHeaderView:GridColumnHeaderView = GridColumnHeaderView(ghl.centerGridColumnHeaderView)
		if (centerGridColumnHeaderView && centerGridColumnHeaderView.containsMouseEvent(event))
			return centerGridColumnHeaderView;
		
		const leftGridColumnHeaderView:GridColumnHeaderView = GridColumnHeaderView(ghl.leftGridColumnHeaderView);
		if (leftGridColumnHeaderView && leftGridColumnHeaderView.containsMouseEvent(event))
			return leftGridColumnHeaderView;
		
		return null;
	}

    // TODO: apologize for stashing the separatorIndex in headerCP.rowIndex
    private function eventToHeaderLocations(event:MouseEvent, headerCP:CellPosition, headerXY:Point):Boolean
    {
        const view:Group = mouseEventHeaderView(event);
        if (!view)
            return false;

		const stageXY:Point = new Point(event.stageX, event.stageY);
        const viewXY:Point = view.globalToLocal(stageXY);
        const viewLayout:GridHeaderViewLayout = view.layout as GridHeaderViewLayout;
        const gdv:GridDimensionsView = viewLayout.gridView.gridViewLayout.gridDimensionsView;
        const separatorIndex:int = viewLayout.getSeparatorIndexAt(viewXY.x, 0);
        
        headerCP.rowIndex = (separatorIndex != -1) ? separatorIndex + gdv.viewColumnIndex : -1;
        headerCP.columnIndex = (separatorIndex == -1) ? viewLayout.getHeaderIndexAt(viewXY.x, 0) + gdv.viewColumnIndex : -1;
        
        headerXY.x = viewXY.x + gdv.viewOriginX;
        headerXY.y = viewXY.y;
		
        return true;
    }
    
    /**
     *  @private
     * 
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
    protected function gchg_mouseDownDragUpHandler(event:MouseEvent):void
    {
        const eventHeaderCP:CellPosition = new CellPosition();
        const eventHeaderXY:Point = new Point();
        if (!eventToHeaderLocations(event, eventHeaderCP, eventHeaderXY))
            return;

        const eventSeparatorIndex:int = eventHeaderCP.rowIndex;
        const eventColumnIndex:int = (eventSeparatorIndex == -1) ? eventHeaderCP.columnIndex : -1;
        
        var gridEventType:String;
        switch(event.type)
        {
            case MouseEvent.MOUSE_MOVE:
            {
                gridEventType = (pressSeparatorIndex != -1) ? GridEvent.SEPARATOR_MOUSE_DRAG : GridEvent.GRID_MOUSE_DRAG;
                break;
            }

            case MouseEvent.MOUSE_UP:
            {
                gridEventType = (pressSeparatorIndex != -1) ? GridEvent.SEPARATOR_MOUSE_UP : GridEvent.GRID_MOUSE_UP;
                downColumnIndex = -1; // update renderer property
                break;
            }

            case MouseEvent.MOUSE_DOWN:
            {
                if (eventSeparatorIndex != -1)
                {
                    gridEventType = GridEvent.SEPARATOR_MOUSE_DOWN;
                    pressSeparatorIndex = eventSeparatorIndex;
                    pressColumnIndex = -1;
                    downColumnIndex = -1; // update renderer property
                }
                else
                {
                    gridEventType = GridEvent.GRID_MOUSE_DOWN;
                    pressSeparatorIndex = -1;
                    pressColumnIndex = eventColumnIndex;
                    downColumnIndex = eventColumnIndex; // update renderer property
                }
                break;
            }
        }
        
        const columnIndex:int = (pressSeparatorIndex != -1) ? pressSeparatorIndex : eventColumnIndex;
        dispatchGridEvent(event, gridEventType, eventHeaderXY, columnIndex);
    }
    
    /**
     *  @private
     * 
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
    protected function gchg_mouseMoveHandler(event:MouseEvent):void
    {
        const eventHeaderCP:CellPosition = new CellPosition();
        const eventHeaderXY:Point = new Point();
        if (!eventToHeaderLocations(event, eventHeaderCP, eventHeaderXY))
            return;
        
        const eventSeparatorIndex:int = eventHeaderCP.rowIndex;
        const eventColumnIndex:int = (eventSeparatorIndex == -1) ? eventHeaderCP.columnIndex : -1;        
        
        if (eventSeparatorIndex != rollSeparatorIndex)
        {
            if (rollSeparatorIndex != -1)
                dispatchGridEvent(event, GridEvent.SEPARATOR_ROLL_OUT, eventHeaderXY, rollSeparatorIndex);
            if (eventSeparatorIndex != -1)
                dispatchGridEvent(event, GridEvent.SEPARATOR_ROLL_OVER, eventHeaderXY, eventSeparatorIndex);
        } 
        
        if (eventColumnIndex != rollColumnIndex)
        {
            if (rollColumnIndex != -1)
                dispatchGridEvent(event, GridEvent.GRID_ROLL_OUT, eventHeaderXY, rollColumnIndex);
            if (eventColumnIndex != -1)
                dispatchGridEvent(event, GridEvent.GRID_ROLL_OVER, eventHeaderXY, eventColumnIndex);
        } 
        
        rollColumnIndex = eventColumnIndex;
        rollSeparatorIndex = eventSeparatorIndex;
    }
    
    /**
     *  @private
     *     
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
    protected function gchg_mouseRollOutHandler(event:MouseEvent):void
    {
        const eventHeaderXY:Point = globalToLocal(new Point(event.stageX, event.stageY));      
        
        if (rollSeparatorIndex != -1)
            dispatchGridEvent(event, GridEvent.SEPARATOR_ROLL_OUT, eventHeaderXY, rollSeparatorIndex);
        else if (rollColumnIndex != -1)
            dispatchGridEvent(event, GridEvent.GRID_ROLL_OUT, eventHeaderXY, rollColumnIndex);

        rollColumnIndex = -1;
        rollSeparatorIndex = -1;
    }
    
    /**
     *  @private 
     * 
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
    protected function gchg_clickHandler(event:MouseEvent):void 
    {
        const eventHeaderCP:CellPosition = new CellPosition();
        const eventHeaderXY:Point = new Point();
        if (!eventToHeaderLocations(event, eventHeaderCP, eventHeaderXY))
            return;
        
        const eventSeparatorIndex:int = eventHeaderCP.rowIndex;
        const eventColumnIndex:int = (eventSeparatorIndex == -1) ? eventHeaderCP.columnIndex : -1;              
 
        if ((eventSeparatorIndex != -1) && (pressSeparatorIndex == eventSeparatorIndex))
            dispatchGridEvent(event, GridEvent.SEPARATOR_CLICK, eventHeaderXY, eventSeparatorIndex);
        else if ((eventColumnIndex != -1) && (pressColumnIndex == eventColumnIndex))
            dispatchGridEvent(event, GridEvent.GRID_CLICK, eventHeaderXY, eventColumnIndex);
    }
    
    /**
     *  @private
     *  
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
    protected function gchg_doubleClickHandler(event:MouseEvent):void 
    {
        const eventHeaderCP:CellPosition = new CellPosition();
        const eventHeaderXY:Point = new Point();
        if (!eventToHeaderLocations(event, eventHeaderCP, eventHeaderXY))
            return;
        
        const eventSeparatorIndex:int = eventHeaderCP.rowIndex;
        const eventColumnIndex:int = (eventSeparatorIndex == -1) ? eventHeaderCP.columnIndex : -1;             
        
        if ((eventSeparatorIndex != -1) && (pressSeparatorIndex == eventSeparatorIndex))
            dispatchGridEvent(event, GridEvent.SEPARATOR_DOUBLE_CLICK, eventHeaderXY, eventSeparatorIndex);
//Commented out because it completely bypasses the grids normal doubleclick handler, yet it calls a doubleclick.
//        else if ((eventColumnIndex != -1) && (pressColumnIndex == eventColumnIndex))
//            dispatchGridEvent(event, GridEvent.GRID_DOUBLE_CLICK, eventHeaderXY, eventColumnIndex);
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
            headerGroupXY.x, headerGroupXY.y, 
            relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta,
            -1 /* rowIndex */, columnIndex, column, item, itemRenderer);
        dispatchEvent(event);
    }     
    
    //--------------------------------------------------------------------------
    //
    //  Private methods, properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private function getColumnAt(columnIndex:int):GridColumn
    {
        const grid:Grid = (dataGrid) ? dataGrid.grid : null;
        if (!grid || !grid.columns)
            return null;
        
        const columns:IList = grid.columns;
        return ((columnIndex >= 0) && (columnIndex < columns.length)) ? columns.getItemAt(columnIndex) as GridColumn : null;
    }
	
	/**
	 *  @private
	 */
	private function getColumnHeaderViewAtX(x:Number):Group
	{
        const ghl:GridHeaderLayout = layout as GridHeaderLayout;
        
		if (ghl.leftGridColumnHeaderView && (x < ghl.centerGridColumnHeaderView.getLayoutBoundsX()))
			return ghl.leftGridColumnHeaderView;
		
		return ghl.centerGridColumnHeaderView;
	}

	/**
	 *  @private
	 */
	private function getColumnHeaderViewAtIndex(columnIndex:int):Group
	{
        const ghl:GridHeaderLayout = layout as GridHeaderLayout;
        
		if (ghl.leftGridColumnHeaderView && (columnIndex < dataGrid.lockedColumnCount))
			return ghl.leftGridColumnHeaderView;
		
		return ghl.centerGridColumnHeaderView;
	}
	
}    
}