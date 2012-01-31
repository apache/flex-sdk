package spark.components
{
import spark.components.supportClasses.GridColumn;
    
/**
 *  Grid item renderers must implement this interface.  The Grid component 
 *  uses this API to provide the item renderer with the information needed 
 *  to render one grid <i>cell</i>.  
 * 
 *  <p>This interface extends the IItemRenderer interface which is used by the List 
 *  component.  The semantics of the inherited properties are specific to Grid:
 *  <table class="innertable">
 *     <tr><th>Property</th><th>Grid Usage</th></tr>
 *     <tr><td><code>owner</code></td><td>The Grid that created this item renderer.</td></tr>
 *     <tr><td><code>data</code></td><td>The value of the dataProvider "item" for this 
 *       row, i.e. <code>dataProvider.getItemAt(itemIndex)</code>.  Item renderers often 
 *       bind visual element attributes to data properties.  Note that, despite its name, 
 *       this property does not depend on the column's "dataField".</td></tr>
 *     <tr><td><code>itemIndex</code>The index of the dataProvider item for this 
 *       item renderer's row.</td></tr>
 *     <tr><td><code>label</code></td><td>The string to display in the item 
 *       renderer's cell.  The GridItemRenderer class automatically copies the 
 *       value of this property to the text property of its <code>labelDisplay</code>. 
 *       The Grid sets the label to the value returned by the column's 
 *       <code>itemToLabel()</code> method.</td></tr>
 *     <tr><td><code>selected</code></td><td>True if the item renderer's cell is part 
 *       of the current selection.  Unlike a List item renderer, 
 *       grid item renderers do not have exclusive responsibility for displaying the 
 *       selection indicator.  The Grid itself renders the selection indicator for the 
 *       selected row or cell.  The item renderer can also change its visual properties 
 *       to emphasize that it's part of the selection.</td></tr>
 *     <tr><td><code>showsCaret</code></td><td>True if the item renderer's cell 
 *        is contained within the caret indicator.  As with the selected property, 
 *        grid item renderers do not have exclusive responsibility for displaying 
 *        the caret indicator.</td></tr>
 *     <tr><td><code>draggable</code></td><td>TBD(hmulller)</td></tr>
 *  </table></p>
 * 
 *  <p>All of the renderer's properties are set by Grid during <code>updateDisplayList()</code>.
 *  After they've been set, the renderer's <code>preprare()</code> method is called.  IGridItemRenderer
 *  implementations should override the preprare() method to make any final adjustments to 
 *  its properties or any aspect of its visual elements.   When an item renderer is no longer
 *  needed, either because it's going to be added to the Grid's internal reusable renderer "free" 
 *  list, or because it's no longer needed, the <code>discard()</code> method is called.</p> 
 */
public interface IGridItemRenderer extends IItemRenderer
{
    
    /**
     *  The column for the item renderer's cell.   This property is set by the Grid by its
     *  <code>updateDisplayList()</code> method.
     */
    function get column():GridColumn;
    function set column(value:GridColumn):void;
    
    /**
     *  Called from the Grid's <code>updateDisplayList()</code> method after all of the 
     *  column's properties have been set.  The <code>recycle<code> parameter is false
     *  if this renderer hasn't been used be for, i.e. if it wasn't "recycled".  This method is 
     *  called when a renderer is about to become visible, typically because it was
     *  scrolled into view.
     * 
     *  <p>This method is not intended to be called directly, it's called by the Grid implementation.</p>
     * 
     *  @param recycle True if this renderer is being reused.
     */
    function prepare(recycle:Boolean):void;
        
    /**
     *  Called from the Grid's <code>updateDisplayList()</code> when it has been determined
     *  that this renderer will no longer be visible.   If the <code>recycle</code> parameter
     *  is true, then the Grid will add this renderer to its internal "free" list.  Implementations
     *  can use this method to clear any renderer properties that are no longer needed.
     * 
     *  <p>This method is not intended to be called directly, it's called by the Grid implementation.</p>
     * 
     *  @param recycle True if this renderer is going to be added to the Grid's internal free list, to be reused later.
     */
    function discard(recycle:Boolean):void;
}

}