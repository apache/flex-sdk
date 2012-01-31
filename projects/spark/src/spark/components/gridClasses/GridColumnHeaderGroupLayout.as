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
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import mx.collections.IList;
import mx.core.IFactory;
import mx.core.ILayoutElement;
import mx.core.IVisualElement;
import mx.core.mx_internal;

import spark.components.ColumnHeaderBar;
import spark.components.DataGrid;
import spark.components.Grid;
import spark.components.Group;
import spark.components.IGridItemRenderer;
import spark.components.supportClasses.GridLayer;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

[ExcludeClass]

public class ColumnHeaderBarLayout extends LayoutBase
{
    /**
     *  Constructor. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    public function ColumnHeaderBarLayout()
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
     *  Cached header renderer heights maintained by the measure() method.
     */
    private const rendererHeights:Array = new Array();
    
    /**
     *  @private
     *  Bounds of all currently visible header renderers.
     */
    private const visibleRenderersBounds:Rectangle = new Rectangle();
    
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
    //  Overridden methods
    //
    //---------------------------------------------------------------
    
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
        rendererHeights.length = 0;
        visibleRenderersBounds.setEmpty();
        elementToFactoryMap = new Dictionary();
        freeElementMap = new Dictionary();
    }     
    
    /**
     *  @private
     */
    override protected function scrollPositionChanged():void
    {
        const columnHeaderBar:ColumnHeaderBar = columnHeaderBar;
        if (!columnHeaderBar)
            return;
        
        super.scrollPositionChanged();  // sets columnHeaderBar.scrollRect
        
        // Only invalidate if we're clipping and scrollR extends outside visibleRenderersBounds
        const scrollR:Rectangle = columnHeaderBar.scrollRect;
        if (scrollR && !visibleRenderersBounds.containsRect(scrollR))
            columnHeaderBar.invalidateDisplayList();
    }    
    
    /**
     *  @private
     */
    override public function measure():void
    {
        const columnHeaderBar:ColumnHeaderBar = columnHeaderBar;
        const grid:Grid = grid;
        
        if (!columnHeaderBar || !grid)
            return;        
        
        const columnHeaderBarNumElements:int = columnHeaderBar.numElements;
        for (var eltIndex:int = 0; eltIndex < columnHeaderBarNumElements; eltIndex++)
        {
            var renderer:IGridItemRenderer = columnHeaderBar.getElementAt(eltIndex) as IGridItemRenderer;
            if (!renderer || !renderer.visible)
                continue;
            
            rendererHeights[renderer.column.columnIndex] = renderer.getPreferredBoundsHeight();
        }
        
        const columns:IList = grid.columns;
        rendererHeights.length = (columns) ? columns.length : 0;
        
        var maxRendererHeight:Number = 0;
        for each (var rendererHeight:Number in rendererHeights)
            maxRendererHeight = Math.max(maxRendererHeight, rendererHeight);
        
        const paddingLeft:Number = columnHeaderBar.getStyle("paddingLeft");
        const paddingRight:Number = columnHeaderBar.getStyle("paddingRight");
        const paddingTop:Number = columnHeaderBar.getStyle("paddingTop");
        const paddingBottom:Number = columnHeaderBar.getStyle("paddingBottom");
            
        columnHeaderBar.measuredWidth = Math.ceil(grid.contentWidth + paddingLeft + paddingRight);
        columnHeaderBar.measuredHeight = Math.ceil(maxRendererHeight + paddingTop + paddingBottom);
    }

    /**
     *  @private
     */
    override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        const columnHeaderBar:ColumnHeaderBar = columnHeaderBar;
        const grid:Grid = grid;
        
        if (!columnHeaderBar || !grid)
            return;

        const visibleColumnIndices:Vector.<int> = grid.getVisibleColumnIndices();
        const oldRenderers:Dictionary = new Dictionary();

        const overlayGroup:Group = columnHeaderBar.overlayGroup;
        const columnSeparatorFactory:IFactory = columnHeaderBar.columnSeparator;
        
        // Add all of the renderers whose column is still visible to oldRenderers and free the rest
        
        for (var eltIndex:int = 0; eltIndex < columnHeaderBar.numElements; eltIndex++)
        {
            var renderer:IGridItemRenderer = columnHeaderBar.getElementAt(eltIndex) as IGridItemRenderer;
            if (!renderer || !renderer.visible)
                continue;
            
            var column:GridColumn = renderer.column;
            if (column && (visibleColumnIndices.indexOf(column.columnIndex) != -1))
                oldRenderers[column] = renderer;
            else
                freeVisualElement(renderer);
        }
        
        // Add all of the separators to the free-list, since laying them out is cheap
        
        for (eltIndex = 0; eltIndex < overlayGroup.numElements; eltIndex++)
            freeVisualElement(overlayGroup.getElementAt(eltIndex));
        
        // Layout the header renderers and update the CHB's content size
        
        const paddingLeft:Number = columnHeaderBar.getStyle("paddingLeft");
        const paddingRight:Number = columnHeaderBar.getStyle("paddingRight");
        const paddingTop:Number = columnHeaderBar.getStyle("paddingTop");
        const paddingBottom:Number = columnHeaderBar.getStyle("paddingBottom");
        
        const columns:IList = grid.columns;
        const columnsLength:int = (columns) ? columns.length : 0;
        const rendererY:Number = paddingTop;
        const rendererHeight:Number = unscaledHeight - paddingTop - paddingBottom;
        const maxRendererX:Number = columnHeaderBar.horizontalScrollPosition + unscaledWidth;
        
        var columnIndex:int = -1;
        var visibleLeft:Number = 0;
        var visibleRight:Number = 0;              
        
        // This isn't quite as simple as: 
        //     for each (var columnIndex:int in visibleColumnIndices)
        // since the ColumnHeaderBar may be wider than the grid because it
        // spans the vertical scrollbar.  If it does, we may need to display 
        // additional column headers (usually one).  
        
        for (var index:int = 0; /* termination conditions below */; index++)
        {
            if (index < visibleColumnIndices.length)
                columnIndex = visibleColumnIndices[index];
            else
                columnIndex += 1;  // TBD: find the next visible column
           
            if (columnIndex >= columnsLength)
                break;

            column = columns.getItemAt(columnIndex) as GridColumn;

            // reuse or create a new renderer
            
            renderer = oldRenderers[column];
            if (!renderer)
            {
                var factory:IFactory = column.headerRenderer;
                if (!factory)
                    factory = columnHeaderBar.headerRenderer;
                renderer = allocateVisualElement(factory) as IGridItemRenderer;
            }
                
            // initialize the renderer
            
            renderer.column = column;
            renderer.label = column.headerText;
            renderer.visible = true; 
            if (renderer.parent != columnHeaderBar)
                columnHeaderBar.addElement(renderer);
            
            // layout the renderer
            
            var isLastColumn:Boolean = columnIndex == (columnsLength - 1);
            var rendererX:Number = grid.getCellX(0, columnIndex) + paddingLeft;
            var rendererWidth:Number = grid.getColumnWidth(columnIndex); 

            if (isLastColumn)
                rendererWidth = horizontalScrollPosition + unscaledWidth - rendererX - paddingRight;

            renderer.setLayoutBoundsSize(rendererWidth, rendererHeight);
            renderer.setLayoutBoundsPosition(rendererX, rendererY);
            
            if (index == 0)
                visibleLeft = rendererX;
            visibleRight = rendererX + rendererWidth;
            
            if ((rendererX + rendererWidth) > maxRendererX)
                break;
            
            // allocate and layout a column separator
            
            if (columnSeparatorFactory && !isLastColumn)
            {
                var separator:IVisualElement = allocateVisualElement(columnSeparatorFactory);
                separator.visible = true;
                if (separator.parent != overlayGroup)
                    overlayGroup.addElement(separator);
               
                var separatorWidth:Number = separator.getPreferredBoundsWidth();
                var separatorX:Number = rendererX + rendererWidth;
                separator.setLayoutBoundsSize(separatorWidth, rendererHeight);
                separator.setLayoutBoundsPosition(separatorX, rendererY);
            }
        }
        
        columnHeaderBar.setContentSize(grid.contentWidth, rendererHeight);
        
        visibleRenderersBounds.left = visibleLeft;
        visibleRenderersBounds.right = visibleRight;
        visibleRenderersBounds.top = rendererY;
        visibleRenderersBounds.height = rendererHeight;
        
        // We may have created new renderers or changed their visibility.  Force
        // validation to avoid a display list flash.
        
        overlayGroup.validateNow();
        columnHeaderBar.validateNow();
    }
    
    //---------------------------------------------------------------
    //
    //  Public methods
    //
    //---------------------------------------------------------------    

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
     *  returned by DataGrid/getItemRenderer().</p>
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
        const columnHeaderBar:ColumnHeaderBar = columnHeaderBar;
        const grid:Grid = grid;
        
        if (!columnHeaderBar || !grid)
            return null;
        
        const visibleColumnIndices:Vector.<int> = grid.getVisibleColumnIndices();
        const eltIndex:int = visibleColumnIndices.indexOf(columnIndex);
        if ((eltIndex != -1) && (eltIndex < columnHeaderBar.numElements))
            return columnHeaderBar.getElementAt(eltIndex) as IGridItemRenderer;
            
        // create a new renderer

        const columns:IList = grid.columns;
        if (!columns || (columns.length <= columnIndex))
            return null;
        const column:GridColumn = grid.columns.getItemAt(columnIndex) as GridColumn;
        
        var factory:IFactory = column.headerRenderer;
        if (!factory)
            factory = columnHeaderBar.headerRenderer;
        const renderer:IGridItemRenderer = allocateVisualElement(factory) as IGridItemRenderer;
        
        columnHeaderBar.addElement(renderer);

        // initialize the renderer
        
        renderer.column = column;
        renderer.label = column.headerText;
        
        // layout the renderer

        const paddingLeft:Number = columnHeaderBar.getStyle("paddingLeft");
        const paddingRight:Number = columnHeaderBar.getStyle("paddingRight");
        const paddingTop:Number = columnHeaderBar.getStyle("paddingTop");
        const paddingBottom:Number = columnHeaderBar.getStyle("paddingBottom");
        
        const isLastColumn:Boolean = columnIndex == (columns.length - 1);
        const rendererX:Number = grid.getCellX(0, columnIndex) + paddingLeft;
        const rendererY:Number = paddingTop;
        const rendererHeight:Number = columnHeaderBar.height - paddingTop - paddingBottom;
        var rendererWidth:Number = grid.getColumnWidth(columnIndex); 
        
        if (isLastColumn)
            rendererWidth = horizontalScrollPosition + columnHeaderBar.width - rendererX - paddingRight;
        
        renderer.setLayoutBoundsSize(rendererWidth, rendererHeight);
        renderer.setLayoutBoundsPosition(rendererX, rendererY);
        
        columnHeaderBar.removeElement(renderer);
        renderer.visible = false;
        
        return renderer;
    }
    
    //---------------------------------------------------------------
    //
    //  Internal methods
    //
    //---------------------------------------------------------------    
    
    /**
     *  @private
     *  If the freeElementMap "free list" contains an instance of this factory, then 
     *  remove if from the free list and return it, otherwise return a new factory instance.
     */
    private function allocateVisualElement(factory:IFactory):IVisualElement
    {
        const freeElements:Vector.<IVisualElement> = freeElementMap[factory] as Vector.<IVisualElement>;
        if (freeElements)
        {
            const freeElement:IVisualElement = freeElements.pop();
            if (freeElements.length == 0)
                delete freeElementMap[factory];
            if (freeElement)
                return freeElement;
        }
        
        const newElement:IVisualElement = factory.newInstance() as IVisualElement;
        elementToFactoryMap[newElement] = factory;
        return newElement;
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
    
    
    private function get columnHeaderBar():ColumnHeaderBar
    {
        return target as ColumnHeaderBar;
    }       
    
    private function get grid():Grid
    {
        const chb:ColumnHeaderBar = columnHeaderBar;
        if (!chb)
            return null;
        
        const dg:DataGrid = chb.owner as DataGrid;
        return (dg) ? dg.grid : null;
    }       
}
}