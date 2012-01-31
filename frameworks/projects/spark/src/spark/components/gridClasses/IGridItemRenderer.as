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

package spark.components.gridClasses
{
import mx.core.IDataRenderer;
import mx.core.IVisualElement;

import spark.components.Grid;
    
/**
 *  The IGridItemRenderer interface defines the interface that item renderers 
 *  for the Spark DataGrid and Spark Grid controls must implement.  
 *  The DataGrid and Grid controls are referred to as the item renderer owner
 *  or as the host component of the item renderer.
 *  The item renderer owner uses this API to provide the item renderer 
 *  with the information needed to render one cell of the grid.  
 *
 *  <p>All of the renderer's properties are set by owner
 *  during the execution of the <code>updateDisplayList()</code> method.
 *  After the properties have been set, Flex calls the item renderer's
 *  <code>prepare()</code> method.  
 *  IGridItemRenderer implementations should override the <code>prepare()</code> method 
 *  to make any final adjustments to its properties or any aspect of its visual elements.</p>
 *
 *  <p>When an item renderer is no longer needed, either because it's going to be added 
 *  to the owner's internal reusable renderer "free" list, 
 *  or because it's no longer needed, the <code>discard()</code> method is called.</p> 
 * 
 *  @see spark.components.DataGrid
 *  @see spark.components.Grid
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5 
 */
public interface IGridItemRenderer extends IDataRenderer, IVisualElement
{
    /**
     *  The Grid associated with this item renderer, typically just the value of
     *  <code>column.grid</code>.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    function get grid():Grid;
    
    /**
     *  The zero-based index of the row of the cell being rendered.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    function get rowIndex():int;
    function set rowIndex(value:int):void;
    
    /**
     *  Contains <code>true</code> when either two input gestures occurs within a 
     *  grid cell: the mouse button is pressed or the touch screen is pressed.   
     *  The <code>down</code> property is reset to <code>false</code> when 
     *  the mouse button is released, the user lifts their finger off of
     *  the touch screen, or the selection is dragged off of the grid cell.   
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    function get down():Boolean;
    function set down(value:Boolean):void;
    
    /**
     *  Contains <code>true</code> if the item renderer is being dragged, 
     *  typically as part of a drag and drop operation.
     *  Currently, drag and drop is not supported by the Spark DataGrid control.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    function get dragging():Boolean;
    function set dragging(value:Boolean):void;
    
    /**
     *  Contains <code>true</code> if the item renderer is being hovered over by the mouse.
     *  The item renderer owner is responsible for drawing the hovered indicator 
     *  for the selected row or cell. 
     *  However, the item renderer can also change its visual properties to emphasize
     *  that it's being hovered over.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    function get hovered():Boolean;
    function set hovered(value:Boolean):void;
    
    /**
     *  The string to display in the item renderer.  
     * 
     *  <p>For example, the GridItemRenderer class automatically copies the 
     *  value of this property to the <code>text</code> property 
     *  of its <code>labelDisplay</code> control. 
     *  The Grid sets the <code>label</code> to the value returned by the column's 
     *  <code>itemToLabel()</code> method.</p>
     *
     *  @see spark.components.gridClasses.GridItemRenderer
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    function get label():String;
    function set label(value:String):void;
    
    /**
     *  Contains <code>true</code> if the item renderer's cell is part 
     *  of the current selection.  
     *  The item renderer owner is responsible for drawing the selection 
     *  indicator for the selected row or cell.  
     *  The item renderer can also change its visual properties 
     *  to emphasize that it's part of the selection.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    function get selected():Boolean;
    function set selected(value:Boolean):void;
    
    /**
     *  Contains <code>true</code> if the item renderer's cell is 
     *  contained within the caret indicator.  
     *  The item renderer owner is responsible for drawing the caret 
     *  indicator for the row or cell.  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    function get showsCaret():Boolean;
    function set showsCaret(value:Boolean):void;    
    
    /**
     *  The GridColumn object representing the column
     *  associated with this item renderer.
     *
     *  <p>This property is set by the item renderer owner by its
     *  <code>updateDisplayList()</code> method. </p>
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5 
     */
    function get column():GridColumn;
    function set column(value:GridColumn):void;
    
    /**
     *  The column index for this item renderer's cell.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5 
     */
    function get columnIndex():int;    
    
    /**
     *  Called from the item renderer owner's <code>updateDisplayList()</code> method 
     *  after all of the renderer's properties have been set.  
     *  The <code>willBeRecycled</code> parameter is <code>false</code>
     *  if this renderer has not been used before, meaning it was not recycled.  
     *  This method is called when a renderer is about to become visible 
     *  and each time it's redisplayed because of a change in a renderer
     *  property, or because a redisplay was explicitly requested. 
     * 
     *  <p>This method can be used to configure all of a renderer's visual 
     *  elements and properties
     *  using this method can be more efficient data binding.  
     *  Note: Because the <code>prepare()</code> method is called frequently, 
     *  make sure that it performs only what is absolutely necessary.</p>
     *
     *  <p>The <code>prepare()</code> method may be called many times 
     *  before the <code>discard()</code> method is called.</p>
     * 
     *  <p>This method is not intended to be called directly.
     *  It is called by the item renderer owner.</p>
     * 
     *  @param hasBeenRecycled  <code>true</code> if this renderer is being reused.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5 
     */
    function prepare(hasBeenRecycled:Boolean):void;
        
    /**
     *  Called from the item renderer owner's <code>updateDisplayList()</code> method 
     *  when it has been determined that this renderer will no longer be visible.   
     *  If the <code>hasBeenRecycled</code> parameter is <code>true</code>, 
     *  then the owner adds this renderer to its internal free list for reuse.  
     *  Implementations can use this method to clear any renderer properties that are no longer needed.
     * 
     *  <p>This method is not intended to be called directly.
     *  It is called by the item renderer owner.</p>
     * 
     *  @param willBeRecycled <code>true</code> if this renderer is going to be added 
     *  to the owner's internal free list for reuse.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5  
     */
    function discard(willBeRecycled:Boolean):void;
}
}