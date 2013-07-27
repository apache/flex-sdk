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

package spark.components.gridClasses
{
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import mx.collections.IList;
import mx.core.IFactory;
import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;

import spark.components.DataGrid;
import spark.components.Grid;
import spark.components.GridColumnHeaderGroup;
import spark.components.Group;
import spark.components.supportClasses.GroupBase;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 *  Virtual horizontal layout for each column header view Group.  This is not a general 
 *  purpose layout class, it's only intended for column header view Groups.
 * 
 *  This layout tracks the layout of the corresponding GridView. 
 *  
 */
public class GridHeaderViewLayout extends LayoutBase
{
    /**
     *  Constructor. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    public function GridHeaderViewLayout()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Internal variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Layers for header renderers and separators.
     */
    private var rendererLayer:Group;
    private var overlayLayer:Group;
    
    /**
     *  @private
     *  Cached header renderer heights maintained by the measure() method, 
     *  and the current content height.
     */
    private const rendererHeights:Array = [];
    private var maxRendererHeight:Number = 0;
    
    /**
     *  @private
     *  Bounds of all currently visible header renderers.
     */
    private const visibleRenderersBounds:Rectangle = new Rectangle();
    
    /**
     *  @private
     *  Currently visible header renderers.
     */
    private const visibleHeaderRenderers:Vector.<IGridItemRenderer> = new Vector.<IGridItemRenderer>();
    
    /**
     *  @private
     *  Currently visible header separators.
     */
    private const visibleHeaderSeparators:Vector.<IVisualElement> = new Vector.<IVisualElement>();
    
    /**
     *  @private
     *  The elements available for reuse aka the "free list".   Maps from an IFactory 
     *  to a list of the elements that have been allocated by that factory and then freed.   
     *  The list is represented by a Vector.<IVisualElement>.
     */
    private var freeElementMap:Dictionary = new Dictionary(); 
    
    /**
     *  @private
     *  Records the IFactory used to allocate a Element so that freeVisualElement()
     *  can find it again.
     */
    private var elementToFactoryMap:Dictionary = new Dictionary();
	
	//---------------------------------------------------------------
	//
	//  Properties
	//
	//---------------------------------------------------------------

	//----------------------------------
	//  columns
	//----------------------------------
	
	private var _columnsView:IList;
	
	/**
	 *  @private
	 *  Returns a cached reference to gridView.columns. A local reference is kept so
	 *  that we can remove the colllection change handler if the columns list changes.
	 */
	private function get columnsView():IList
	{
		const gridView:GridView = this.gridView;
		const newColumns:IList = (gridView) ? gridView.gridViewLayout.columnsView : null;
		
		if (newColumns != _columnsView)
		{
			if (_columnsView)
				_columnsView.removeEventListener(CollectionEvent.COLLECTION_CHANGE, columns_collectionChangeHandler);
			
			_columnsView = newColumns;
			
			if (_columnsView)
				_columnsView.addEventListener(CollectionEvent.COLLECTION_CHANGE, columns_collectionChangeHandler);
		}
		
		return _columnsView;
	}
	
	//----------------------------------
	//  grid (private read-only)
	//----------------------------------
	
	/**
	 *  @private
	 */
	private function get grid():Grid
	{
		const view:GridView = this.gridView;
		return (view) ? view.parent as Grid : null;
	}
	
	//----------------------------------
	//  gridColumnHeaderGroup
	//----------------------------------
	
	private var _gridColumnHeaderGroup:GridColumnHeaderGroup = null;
	
	/**
	 *  The GridColumnHeaderGroup whose columns this header view is associated with.
	 * 
	 *  This property is set by GridColumnHeaderGroup.
	 */
	public function get gridColumnHeaderGroup():GridColumnHeaderGroup
	{
		return _gridColumnHeaderGroup
	}
	
	/**
	 *  @private
	 */
	public function set gridColumnHeaderGroup(value:GridColumnHeaderGroup):void
	{
		if (value == _gridColumnHeaderGroup)
			return;
		
		_gridColumnHeaderGroup = value;
	}	
	
	//----------------------------------
	//  gridView
	//----------------------------------
	
	private var _gridView:GridView = null;
	
	/**
	 *  The GridView whose columns this header view is associated with.
	 * 
	 *  This property is set by GridColumnHeaderGroup.
	 */
	public function get gridView():GridView
	{
		return _gridView
	}
	
	/**
	 *  @private
	 */
	public function set gridView(value:GridView):void
	{
		if (value == _gridView)
			return;
		
		_gridView = value;
	}
	
    //---------------------------------------------------------------
    //
    //  Overridden methods
    //
    //---------------------------------------------------------------
    
    /**
     *  @private
     */
    override public function set target(value:GroupBase):void
    {
        super.target = value;
        
        const group:Group = value as Group;
		if (!group)
			return;
		
		rendererLayer = new Group();
		rendererLayer.layout = new LayoutBase();
		group.addElement(rendererLayer);
		
		overlayLayer = new Group();
		overlayLayer.layout = new LayoutBase();
		group.addElement(overlayLayer);
    }
    
    /**
     *  @private
     */
    override public function get useVirtualLayout():Boolean
    {
        return true;
    }
    
    /**
     *  @private
     */
    override public function set useVirtualLayout(value:Boolean):void
    {
    }
    
    /**
     *  @private
     *  Clear everything.
     */
    override public function clearVirtualLayoutCache():void
    {		
		freeRenderers(visibleHeaderRenderers);
        visibleHeaderRenderers.length = 0;
		
		freeVisualElements(visibleHeaderSeparators);
        visibleHeaderSeparators.length = 0;
		
        rendererHeights.length = 0;
        visibleRenderersBounds.setEmpty();
        elementToFactoryMap = new Dictionary();
        freeElementMap = new Dictionary();

		if (gridColumnHeaderGroup)
			gridColumnHeaderGroup.visibleSortIndicatorIndices = null;
    }     
    
    /**
     *  @private
     */
    override protected function scrollPositionChanged():void
    {
		const target:GroupBase = this.target;
        if (!target)
            return;
        
        super.scrollPositionChanged();  // sets target's scrollRect
        
        // Only invalidate if we're clipping and scrollR extends outside visibleRenderersBounds
        const scrollR:Rectangle = target.scrollRect;
		if (scrollR && !visibleRenderersBounds.containsRect(scrollR))
            target.invalidateDisplayList();
    }    
    
    /**
     *  @private
     */
    override public function measure():void
    {
		const target:GroupBase = this.target;
		if (!target)
			return;
		
		updateRendererHeights();
		
		const measuredWidth:Number = Math.max(0, target.minWidth);
		const measuredHeight:Number = Math.max(maxRendererHeight, target.minHeight);
		
        target.measuredWidth = Math.ceil(measuredWidth);
        target.measuredHeight = Math.ceil(measuredHeight);
    }

    /**
     *  @private
     */
    override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
		const target:GroupBase = this.target;
        const gridColumnHeaderGroup:GridColumnHeaderGroup = this.gridColumnHeaderGroup;
        const gridView:GridView = this.gridView;
        
        if (!target || !gridColumnHeaderGroup || !gridView)
            return;

		// TBD explain about Grid relative column indices...
		
		const visibleColumnIndices:Vector.<int> = gridView.gridViewLayout.getVisibleColumnIndices();  
		const visibleColumnCount:int = visibleColumnIndices.length;
		const firstVisibleColumnIndex:int = (visibleColumnCount > 0) ? visibleColumnIndices[0] : -1;
		const lastVisibleColumnIndex:int = (visibleColumnCount > 0) ? visibleColumnIndices[visibleColumnCount - 1] : -1;
		
        const oldRenderers:Array = [];
        const rendererLayer:Group = this.rendererLayer;
        const overlayLayer:Group = this.overlayLayer;
        const columnSeparatorFactory:IFactory = gridColumnHeaderGroup.columnSeparator;
        
        var renderer:IGridItemRenderer;
        var separator:IVisualElement;
        var column:GridColumn;
        var columnIndex:int = -1;
        
        // Add all of the renderers whose column is still visible to oldRenderers and free the rest
        
        for each (renderer in visibleHeaderRenderers)
        {
            column = renderer.column;
            columnIndex = (column) ? column.columnIndex : -1; 
            
            if ((visibleColumnIndices.indexOf(columnIndex) != -1) && (oldRenderers[columnIndex] == null))
                oldRenderers[columnIndex] = renderer;
            else
                freeRenderer(renderer);
        }
        visibleHeaderRenderers.length = 0;
        
        // Add all of the separators to the free-list, since laying them out is cheap.
        
		freeVisualElements(visibleHeaderSeparators);
		visibleHeaderSeparators.length = 0;
        
        // Layout the header renderers and update the CHB's content size
        // The loop below is written in terms of Grid - not GridView - column indices,
        // and terminates when we reach GridColumnCount.
        
        const gridColumns:IList = grid.columns;  // TBD what if grid.columns is null?
        const gridViewLayout:GridViewLayout = gridView.layout as GridViewLayout;
        const gridColumnCount:int = gridViewLayout.viewColumnIndex + gridViewLayout.columnsView.length; 
        
		const rendererY:Number = 0;
		const rendererHeight:Number = unscaledHeight;
        const maxRendererX:Number = target.horizontalScrollPosition + unscaledWidth;
        
        var visibleLeft:Number = 0;
        var visibleRight:Number = 0;
        
        // This isn't quite as simple as: 
        //     for each (var columnIndex:int in visibleColumnIndices)
        // since the GridColumnHeaderGroup may be wider than the grid because it
        // spans the vertical scrollbar.  If it does, we may need to display 
        // additional column headers (usually one).  
        
        for (var index:int = 0; /* termination conditions below */; index++)
        {
            if (index < visibleColumnIndices.length)
                columnIndex = visibleColumnIndices[index];
            else
                columnIndex = grid.getNextVisibleColumnIndex(columnIndex);
           
            if (columnIndex < 0 || columnIndex >= gridColumnCount)
                break;

            column = gridColumns.getItemAt(columnIndex) as GridColumn;

            // reuse or create a new renderer
            
            renderer = oldRenderers[columnIndex];
            delete oldRenderers[columnIndex];
            if (!renderer)
            {
                var factory:IFactory = column.headerRenderer;
                if (!factory)
                    factory = gridColumnHeaderGroup.headerRenderer;
                renderer = allocateVisualElement(factory) as IGridItemRenderer;
            }
            visibleHeaderRenderers.push(renderer);
            
            // initialize the renderer
            
            initializeItemRenderer(renderer, columnIndex, column, true);
            if (renderer.parent != rendererLayer)
                rendererLayer.addElement(renderer);
            
            // layout the renderer
            
            var isLastColumn:Boolean = columnIndex == lastVisibleColumnIndex;
            var headerViewColumnIndex:int = columnIndex - gridViewLayout.viewColumnIndex;
			var rendererX:Number = gridViewLayout.gridDimensionsView.getCellX(0, headerViewColumnIndex);
            var rendererWidth:Number = grid.getColumnWidth(columnIndex);
            
			if (isLastColumn)
                rendererWidth = horizontalScrollPosition + unscaledWidth - rendererX - 1; // TODO: this is a temporary hack
			
            renderer.setLayoutBoundsSize(rendererWidth, rendererHeight);
            renderer.setLayoutBoundsPosition(rendererX, rendererY);
            
            if (index == 0)
                visibleLeft = rendererX;
            visibleRight = rendererX + rendererWidth;
            
            renderer.prepare(!createdVisualElement);
            
            if (isLastColumn || ((rendererX + rendererWidth) >= maxRendererX))
                break;
            
            // allocate and layout a column separator
            
            if (columnSeparatorFactory && !isLastColumn)
            {
                separator = allocateVisualElement(columnSeparatorFactory);
                visibleHeaderSeparators.push(separator);
                separator.visible = true;
                if (separator.parent != overlayLayer)
                    overlayLayer.addElement(separator);
                
                var separatorWidth:Number = separator.getPreferredBoundsWidth();
                var separatorX:Number = rendererX + rendererWidth;
                separator.setLayoutBoundsSize(separatorWidth, rendererHeight);
                separator.setLayoutBoundsPosition(separatorX, rendererY);
            }
        }

        target.setContentSize(grid.contentWidth, rendererHeight);

		visibleRenderersBounds.left = visibleLeft;
		visibleRenderersBounds.right = visibleRight = 0;
		visibleRenderersBounds.top = rendererY;
        visibleRenderersBounds.height = rendererHeight;
		
        // We may have created new renderers or changed their visibility.  Force
        // validation to avoid a display list flash.

        target.validateNow();
        
        // Update the renderer heights cache.
        // Invalidates the target's size if the maxRendererHeight has changed.
        
        updateRendererHeights(true);
    }
    
    //---------------------------------------------------------------
    //
    //  Public methods
    //
    //--------------------------------------------------------------- 
    
    /**
     *  Returns the column index corresponding to the specified coordinates,
     *  or -1 if the coordinates are out of bounds. The coordinates are 
     *  resolved with respect to the column header view layout target.
     * 
     *  <p>If all of the columns or rows for the grid have not yet been scrolled
     *  into view, the returned index may only be an approximation, 
     *  based on all of the columns' <code>typicalItem</code>s.</p>
     *  
     *  @param x The pixel's x coordinate relative to the target column header view
     *  @param y The pixel's y coordinate relative to the target column header view
     *  @return the index of the column or -1 if the coordinates are out of bounds. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getHeaderIndexAt(x:Number, y:Number):int
    {
        return gridView.gridViewLayout.gridDimensionsView.getColumnIndexAt(x, y);
        
        // TODO: restore the special case handling below
        /*
        const gridColumnHeaderGroup:GridColumnHeaderGroup = this.gridColumnHeaderGroup;
        const grid:Grid = this.grid;
        const columnsView:IList = this.columnsView;
        
        if (!gridColumnHeaderGroup || !grid || !columnsView)
            return -1; 
        
        const paddingLeft:Number = gridColumnHeaderGroup.getStyle("paddingLeft");
        const paddedX:Number = x + paddingLeft;
        var columnIndex:int = grid.getColumnIndexAt(paddedX, 0);
        
        // Special case for the stretched renderer above the vertical scrollbar
        // TODO (klin): Rethink this case if we change how the last header looks.
        if (columnIndex < 0)
        {
            const contentWidth:Number = gridColumnHeaderGroup.contentWidth;
            const totalWidth:Number = horizontalScrollPosition + gridColumnHeaderGroup.width - gridColumnHeaderGroup.getStyle("paddingRight");
            if (paddedX >= contentWidth && paddedX < totalWidth)
                columnIndex = grid.getPreviousVisibleColumnIndex(columnsView.length)
        }
        
        return columnIndex;
        */
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
     *  <p>The separator index is the same as the index of the column on the left
     *  (assuming that this component's layoutDirection is "rtl").  That means 
     *  that all column headers are flanked by two separators, except for the first
     *  visible column, which just has a separator on the right, and the last visible
     *  column, which just has a separator on the left.</p>
     * 
     *  <p>If all of the columns or rows for the grid have not yet been scrolled
     *  into view, the returned index may only be an approximation, 
     *  based on all of the columns' <code>typicalItem</code>s.</p>
     *  
     *  @param x The pixel's x coordinate relative to the columnHeaderGroup
     *  @param y The pixel's y coordinate relative to the columnHeaderGroup
     *  @return the index of the column or -1 if the coordinates don't overlap a separator.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getSeparatorIndexAt(x:Number, y:Number):int
    {
        const gdv:GridDimensionsView = gridView.gridViewLayout.gridDimensionsView;
        const columnIndex:int = gdv.getColumnIndexAt(x, y); 
        if (columnIndex == -1)
            return -1;        
        
        const isFirstColumn:Boolean = columnIndex == gridView.getNextVisibleColumnIndex(-1);
        const isLastColumn:Boolean = false; //columnIndex == gridView.getPreviousVisibleColumnIndex(gridView.viewColumnCount);
        
        const columnLeft:Number = gdv.getCellX(0, columnIndex);
        const columnRight:Number = columnLeft + gdv.getColumnWidth(columnIndex);
        const smw:Number = gridColumnHeaderGroup.getStyle("separatorAffordance");
        
        if (!isFirstColumn && (x > (columnLeft - smw)) && (x < (columnLeft + smw)))
            return grid.getPreviousVisibleColumnIndex(columnIndex);
        
        if (!isLastColumn && (x > (columnRight - smw)) && (x < columnRight + smw))
            return columnIndex;
        
        return -1;
    }
    
    /**
     *  Returns the current pixel bounds of the specified header (renderer), or null if 
     *  no such column exists.  Header bounds are reported in GridColumnHeaderGroup coordinates.
     * 
     *  <p>If all of the visible columns preceeding the specified column have not 
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
        const gridColumnHeaderGroup:GridColumnHeaderGroup = this.gridColumnHeaderGroup;
        const grid:Grid = this.grid;
        
        if (!gridColumnHeaderGroup || !grid)
            return null;
        
        const columns:IList = columns;
        const columnsLength:int = (columns) ? columns.length : 0;
        
        if (columnIndex >= columnsLength)
            return null;
        
        const column:GridColumn = columns.getItemAt(columnIndex) as GridColumn;
        if (!column.visible)
            return null;
        
        const paddingLeft:Number = gridColumnHeaderGroup.getStyle("paddingLeft");
        const paddingRight:Number = gridColumnHeaderGroup.getStyle("paddingRight");
        const paddingTop:Number = gridColumnHeaderGroup.getStyle("paddingTop");
        const paddingBottom:Number = gridColumnHeaderGroup.getStyle("paddingBottom");
        
        var isLastColumn:Boolean = columnIndex == grid.getPreviousVisibleColumnIndex(columnsLength);
        var rendererX:Number = grid.getCellX(0, columnIndex) + paddingLeft;
        const rendererY:Number = paddingTop;
        var rendererWidth:Number = grid.getColumnWidth(columnIndex); 
        const rendererHeight:Number = gridColumnHeaderGroup.height - paddingTop - paddingBottom;        
        
        if (isLastColumn)
            rendererWidth = horizontalScrollPosition + gridColumnHeaderGroup.width - rendererX - paddingRight;
        
        return new Rectangle(rendererX, rendererY, rendererWidth, rendererHeight);
    }

    /**
     *  If the requested header renderer is visible, returns a reference to 
     *  the header renderer currently displayed for the specified column. 
     *  Note that once the returned header renderer is no longer visible it 
     *  may be recycled and its properties reset.  
     * 
     *  <p>If the requested header renderer is not visible then, 
     *  each time this method is called, a new header renderer is created.  The
     *  new item renderer is not visible</p>
     * 
     *  <p>The width of the returned renderer is the same as for item renderers
     *  returned by DataGrid/getItemRendererAt().</p>
     *  
     *  @param columnIndex The 0-based column index of the header renderer's column
     *  @return The item renderer or null if the column index is invalid.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getHeaderRendererAt(columnIndex:int):IGridItemRenderer
    {
        const gridColumnHeaderGroup:GridColumnHeaderGroup = this.gridColumnHeaderGroup;
        const grid:Grid = this.grid;
        
        if (!gridColumnHeaderGroup || !grid || (columnIndex < 0))
            return null;
        
        // If columnIndex refers to a visible header renderer, return it
        
        const rendererLayer:Group = rendererLayer;
        const visibleColumnIndices:Vector.<int> = grid.getVisibleColumnIndices();
        const eltIndex:int = visibleColumnIndices.indexOf(columnIndex);
        if (eltIndex != -1)
        {
            const rendererLayerNumElements:int = rendererLayer.numElements;
            for (var index:int = 0; index < rendererLayerNumElements; index++)
            {
                var elt:IGridItemRenderer = rendererLayer.getElementAt(index) as IGridItemRenderer;
                if (elt && elt.visible && elt.column && (elt.column.columnIndex == columnIndex))
                    return elt;
            }
            return null;
        }
            
        // create a new renderer

        const columns:IList = columns;
        if (!columns || (columns.length <= columnIndex))
            return null;
        const column:GridColumn = columns.getItemAt(columnIndex) as GridColumn;
        if (!column.visible)
            return null;
        
        var factory:IFactory = column.headerRenderer;
        if (!factory)
            factory = gridColumnHeaderGroup.headerRenderer;
        const renderer:IGridItemRenderer = allocateVisualElement(factory) as IGridItemRenderer;
        
        rendererLayer.addElement(renderer);

        // initialize the renderer
        
        initializeItemRenderer(renderer, columnIndex, column, renderer.visible);
        
        // layout the renderer

        const paddingLeft:Number = gridColumnHeaderGroup.getStyle("paddingLeft");
        const paddingRight:Number = gridColumnHeaderGroup.getStyle("paddingRight");
        const paddingTop:Number = gridColumnHeaderGroup.getStyle("paddingTop");
        const paddingBottom:Number = gridColumnHeaderGroup.getStyle("paddingBottom");
        
        const isLastColumn:Boolean = columnIndex == grid.getPreviousVisibleColumnIndex(columns.length);
        const rendererX:Number = grid.getCellX(0, columnIndex) + paddingLeft;
        const rendererY:Number = paddingTop;
        const rendererHeight:Number = gridColumnHeaderGroup.height - paddingTop - paddingBottom;
        var rendererWidth:Number = grid.getColumnWidth(columnIndex); 
        
        if (isLastColumn)
            rendererWidth = horizontalScrollPosition + gridColumnHeaderGroup.width - rendererX - paddingRight;
        
        renderer.setLayoutBoundsSize(rendererWidth, rendererHeight);
        renderer.setLayoutBoundsPosition(rendererX, rendererY);
        
        rendererLayer.removeElement(renderer);
        renderer.visible = false;
        
        return renderer;
    }
    
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

    //---------------------------------------------------------------
    //
    //  Internal methods, properties
    //
    //---------------------------------------------------------------    
    
    /**
     *  @private
     */
    private function initializeItemRenderer(renderer:IGridItemRenderer,
                                            columnIndex:int,
                                            column:GridColumn,
                                            visible:Boolean=true):void
    {
        renderer.visible = visible;
        renderer.column = column;
        renderer.label = column.headerText;
        
        const columnHeaderGroup:GridColumnHeaderGroup = this.gridColumnHeaderGroup;

        const dataGrid:DataGrid = columnHeaderGroup.dataGrid;
        if (dataGrid)
            renderer.owner = dataGrid;
        
        renderer.hovered = columnIndex == columnHeaderGroup.hoverColumnIndex;
        renderer.selected = columnIndex == columnHeaderGroup.selectedColumnIndex;
        renderer.down = columnIndex == columnHeaderGroup.downColumnIndex;
    }
    
    /**
     *  @private
     *  Let the allocateGridElement() caller know if the returned element was 
     *  created or recycled.
     */
    private var createdVisualElement:Boolean = false;
    
    /**
     *  @private
     */
    private function createVisualElement(factory:IFactory):IVisualElement
    {
        createdVisualElement = true;
        const newElement:IVisualElement = factory.newInstance() as IVisualElement;
        elementToFactoryMap[newElement] = factory;
        return newElement;
    }
    
    /**
     *  @private
     *  If the freeElementMap "free list" contains an instance of this factory, then 
     *  remove if from the free list and return it, otherwise create a new instance
     *  using createVisualElement().
     */
    private function allocateVisualElement(factory:IFactory):IVisualElement
    {
        createdVisualElement = false;
        const freeElements:Vector.<IVisualElement> = freeElementMap[factory] as Vector.<IVisualElement>;
        if (freeElements)
        {
            const freeElement:IVisualElement = freeElements.pop();
            if (freeElements.length == 0)
                delete freeElementMap[factory];
            if (freeElement)
                return freeElement;
        }
        
        return createVisualElement(factory);
    }
    
    /**
     *  @private
     *  Move the specified element to the free list after hiding it. Note that we 
     *  do not actually remove the element from its parent.
     */
    private function freeVisualElement(element:IVisualElement):void
    {
        const factory:IFactory = elementToFactoryMap[element];

        var freeElements:Vector.<IVisualElement> = freeElementMap[factory];
        if (!freeElements)
        {
            freeElements = new Vector.<IVisualElement>();
            freeElementMap[factory] = freeElements;
        }
        freeElements.push(element);
        
        element.visible = false;
    }
	
	private function freeVisualElements(elements:Vector.<IVisualElement>):void
	{
		for each (var elt:IVisualElement in elements)
		    freeVisualElement(elt);
			
		elements.length = 0;
	}
	
	private function freeRenderer(renderer:IGridItemRenderer):void
	{
		freeVisualElement(renderer as IVisualElement);
		renderer.discard(true);	
	}
	
	private function freeRenderers(renderers:Vector.<IGridItemRenderer>):void
	{
		for each (var renderer:IGridItemRenderer in renderers)
			freeRenderer(renderer);
			
		renderers.length = 0;
	}		
    
    /**
     *  @private
     *  Updates the renderer heights cache and the current max renderer height.
     *  Invalidates the target's size if the max renderer height has changed.
     * 
     *  <p>If the max live renderer height is the same as the max cached height, then
     *  just update the cache.
     *  If the max live renderer height is greater than the max cached height, then
     *  update the cache, cache the new height, and invalidate the target's size if
     *  necessary.
     *  If the max live renderer height is less than the max cached height, then
     *  update the cache, check to see if the cached max height has lowered, and
     *  invalidate the target's size if necessary.
     */
    private function updateRendererHeights(inUpdateDisplayList:Boolean = false):void
    {
        const columns:IList = this.columnsView;
        rendererHeights.length = (columns) ? columns.length : 0;
        
        var newHeight:Number = 0;
        
        // update cached renderer heights with live renderer heights.
        for each (var renderer:IGridItemRenderer in visibleHeaderRenderers)
        {
            var preferredHeight:Number = renderer.getPreferredBoundsHeight();
            rendererHeights[renderer.column.columnIndex] = preferredHeight;
            if (preferredHeight > newHeight)
                newHeight = preferredHeight;
        }
        
        // Do nothing if the heights are the same.
        if (newHeight == maxRendererHeight)
            return;
        
        if (newHeight < maxRendererHeight)
        {
            // If the live renderers' max height is less than the current
            // max height, check if this also lowers the maxRendererHeight.
			for each (var rendererHeight:Number in rendererHeights)
			{
                if (!isNaN(rendererHeight) && rendererHeight > newHeight)
                    newHeight = rendererHeight;
            }
        }
        
        maxRendererHeight = newHeight;
        
        if (inUpdateDisplayList) // TBD: should be target.invalidateSize()?
            gridColumnHeaderGroup.invalidateSize();
    }
    

    /**
     *  @private
     *  Handles changes to the columns IList that might affect the visible sort
     *  indicators.
     */
    private function columns_collectionChangeHandler(event:CollectionEvent):void
    {
        // TODO (klin): The cache could be adjusted here too.
        switch (event.kind)
        {
            case CollectionEventKind.ADD: 
            {
                columns_collectionChangeAdd(event);
                break;
            }
            
            case CollectionEventKind.REMOVE:
            {
                columns_collectionChangeRemove(event);
                break;
            }
                
            case CollectionEventKind.MOVE:
            {
                columns_collectionChangeMove(event);
                break;
            }
                
            case CollectionEventKind.REPLACE:
            case CollectionEventKind.UPDATE:
            {
                // Do nothing.
                break;
            }
                
            case CollectionEventKind.REFRESH:
            case CollectionEventKind.RESET:
            {
                clearVirtualLayoutCache();
                break;
            }                
        }
    }
    
    /**
     *  @private
     *  Adjusts the visibleSortIndicatorIndices to the correct columns
     *  after columns are added.
     */
    private function columns_collectionChangeAdd(event:CollectionEvent):void
    {   
        const itemsLength:int = event.items.length;
        if (itemsLength <= 0)
            return;
        
        const chg:GridColumnHeaderGroup = gridColumnHeaderGroup;
        const indices:Vector.<int> = chg.visibleSortIndicatorIndices;
        const indicesLength:int = indices.length;
        const startIndex:int = event.location;
        
        for (var i:int = 0; i < indicesLength; i++)
        {
            if (indices[i] >= startIndex)
                indices[i] += itemsLength;
        }
        chg.visibleSortIndicatorIndices = indices;
    }
    
    /**
     *  @private
     *  Adjusts the visibleSortIndicatorIndices to the correct columns
     *  after columns are removed.
	 * 
	 *  TBD: Remove the rendererHeights cache entries for the corresponding columns.
     */
    private function columns_collectionChangeRemove(event:CollectionEvent):void
    {
        const itemsLength:int = event.items.length;
        if (itemsLength <= 0)
            return;
        
        const chg:GridColumnHeaderGroup = gridColumnHeaderGroup;
        const indices:Vector.<int> = chg.visibleSortIndicatorIndices;
        const indicesLength:int = indices.length;
        const startIndex:int = event.location;
        const lastIndex:int = startIndex + itemsLength;
        const newIndices:Vector.<int> = new Vector.<int>();
        var index:int;
        
        for each (index in indices)
        {
            if (index < startIndex)
                newIndices.push(index);
            else if (index >= lastIndex)
                newIndices.push(index - lastIndex);
        }
        chg.visibleSortIndicatorIndices = newIndices;
    }
    
    /**
     *  @private
     *  Adjusts the visibleSortIndicatorIndices to the correct columns
     *  after columns are moved.
     */
    private function columns_collectionChangeMove(event:CollectionEvent):void
    {
        const itemsLength:int = event.items.length;
        if (itemsLength <= 0)
            return;
        
        const gridColumnHeaderGroup:GridColumnHeaderGroup = this.gridColumnHeaderGroup;
        const indices:Vector.<int> = gridColumnHeaderGroup.visibleSortIndicatorIndices;
        const indicesLength:int = indices.length;
        const oldStart:int = event.oldLocation;
        const oldEnd:int = event.oldLocation + itemsLength;
        const newStart:int = event.location;
        const newEnd:int = event.location + itemsLength;
        var index:int;
        
        for (var i:int = 0; i < indicesLength; i++)
        {
            index = indices[i];
            
            if (index >= oldStart && index < oldEnd)
            {
                // Moved items move up to new position
                indices[i] = newStart + (index - oldStart);
                continue;
            }
            
            // Two cases:
            //      1) New position is greater than old position, so we
            //         decrement their position by the number of moved items.
            //      2) New position is less than old position, so we
            //         increment their position by the number of moved items.
            if (newStart > oldStart)
            {
                if (index >= oldEnd && index < newEnd)
                    indices[i] -= itemsLength;
            }
            else if (newStart < oldStart)
            {
                if (index >= newStart && index < oldStart)
                    indices[i] += itemsLength;
            }
        }
		
        gridColumnHeaderGroup.visibleSortIndicatorIndices = indices;
    }
}
}

