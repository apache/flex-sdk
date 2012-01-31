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
import mx.core.IDataRenderer;
import mx.core.IVisualElement;

import spark.components.supportClasses.GridColumn;
    
/**
 *  Grid item renderers must implement this interface.  The Grid component 
 *  uses this API to provide the item renderer with the information needed 
 *  to render one grid <i>cell</i>.  
 * 
 *  <p>All of the renderer's properties are set by Grid during <code>updateDisplayList()</code>.
 *  After they've been set, the renderer's <code>prepare()</code> method is called.  IGridItemRenderer
 *  implementations should override the preprare() method to make any final adjustments to 
 *  its properties or any aspect of its visual elements.   When an item renderer is no longer
 *  needed, either because it's going to be added to the Grid's internal reusable renderer "free" 
 *  list, or because it's no longer needed, the <code>discard()</code> method is called.</p> 
 */
public interface IGridItemRenderer extends IDataRenderer, IVisualElement
{
    /**
     *  The dataProvider index of the item being displayed.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    function get rowIndex():int;
    function set rowIndex(value:int):void;
    
    /**
     *  True if the item renderer is being dragged, typically as part of a drag and drop operation.
     *  Currently not supported by DataGrid.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    function get dragging():Boolean;
    function set dragging(value:Boolean):void;
    
    /**
     *  True if the item renderer is being hovered over by the mouse.
     *  Unlike a List item renderer, grid item renderers do not have exclusive
     *  responsibility for displaying the hovered indicator.  The Grid itself
     *  renders the hovered indicator for the selected row or cell. 
     *  The item renderer can also change its visual properties to emphasize
     *  that it's being hovered over.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    function get hovered():Boolean;
    function set hovered(value:Boolean):void;
    
    /**
     *  The string to display in the item renderer's cell.  
     * 
     *  <p>The GridItemRenderer class automatically copies the 
     *  value of this property to the text property of its <code>labelDisplay</code>. 
     *  The Grid sets the label to the value returned by the column's 
     *  <code>itemToLabel()</code> method.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    function get label():String;
    function set label(value:String):void;
    
    /**
     *  True if the item renderer's cell is part 
     *  of the current selection.  Unlike a List item renderer, 
     *  grid item renderers do not have exclusive responsibility for displaying the 
     *  selection indicator.  The Grid itself renders the selection indicator for the 
     *  selected row or cell.  The item renderer can also change its visual properties 
     *  to emphasize that it's part of the selection.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    function get selected():Boolean;
    function set selected(value:Boolean):void;
    
    /**
     *  True if the item renderer's cell is contained within the caret indicator.  
     *  As with the selected property, grid item renderers do not have exclusive 
     *  responsibility for displaying the caret indicator.  Contains <code>true</code> 
     *  if the item renderer can show itself as focused. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    function get showsCaret():Boolean;
    function set showsCaret(value:Boolean):void;    
    
    /**
     *  The column for the item renderer's cell.   This property is set by the Grid by its
     *  <code>updateDisplayList()</code> method.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */
    function get column():GridColumn;
    function set column(value:GridColumn):void;
    
    /**
     *  Called from the Grid's <code>updateDisplayList()</code> method after all of the 
     *  column's properties have been set.  The <code>willBeRecycled</code> parameter is false
     *  if this renderer hasn't been used be for, i.e. if it wasn't "recycled".  This method is 
     *  called when a renderer is about to become visible, typically because it was
     *  scrolled into view.
     * 
     *  <p>This method is not intended to be called directly, it's called by the Grid implementation.</p>
     * 
     *  @param willBeRecycled True if this renderer is being reused.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */
    function prepare(willBeRecycled:Boolean):void;
        
    /**
     *  Called from the Grid's <code>updateDisplayList()</code> when it has been determined
     *  that this renderer will no longer be visible.   If the <code>hasBeenRecycled</code> parameter
     *  is true, then the Grid will add this renderer to its internal "free" list.  Implementations
     *  can use this method to clear any renderer properties that are no longer needed.
     * 
     *  <p>This method is not intended to be called directly, it's called by the Grid implementation.</p>
     * 
     *  @param hasBeenRecycled True if this renderer is going to be added to the Grid's internal free list, to be reused later.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5  
     */
    function discard(hasBeenRecycled:Boolean):void;
}

}