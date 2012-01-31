package spark.components.gridClasses
{
import mx.core.IDataRenderer;
import mx.core.IIMESupport;
import mx.core.IVisualElement;
import mx.managers.IFocusManagerComponent;

import spark.components.gridClasses.GridItemRenderer;
import spark.components.gridClasses.GridColumn;
import spark.components.DataGrid;

/**
 *  Grid item editors must implement this interface. 
 * 
 *  <p>All of the item editor's properties are set by the DataGrid during 
 *  the start of the editor session. The <code>data</code> property is the 
 *  last property set. When the data property is set a grid item editor should
 *  set the value of the editor's controls. Next the editor's 
 *  <code>prepare()</code> method is called. IGridItemEditor 
 *  implementations should override the preprare() method to make any final
 *  adjustments to its properties or any aspect of its visual elements. 
 *  When the editor is closing the <code>discard()</code> method is called.</p>
 *  
 * <p>When the editor is closed the input value can be saved or cancelled. If saving, 
 * the <code>save()</code> function is called by the editor.
 * </p>
 */
public interface IGridItemEditor extends IDataRenderer, IVisualElement, 
                                 IFocusManagerComponent, IIMESupport
{
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  dataGrid
    //----------------------------------
    
    /**
     *  The data grid that owns this editor.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */
    function get dataGrid():DataGrid;

    //----------------------------------
    //  column
    //----------------------------------
    
    /**
     *  The column that is being edited.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */
    function get column():GridColumn;
    function set column(value:GridColumn):void;
    
    //----------------------------------
    //  columnIndex
    //----------------------------------
    
    /** 
     *  The zero-based index of the column that is being edited.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */ 
    function get columnIndex():int;

    //----------------------------------
    //  rowIndex
    //----------------------------------
    
    /** 
     *  The zero-based index of the row that is being edited.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */ 
    function get rowIndex():int;
    function set rowIndex(value:int):void;

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Called after the editor has been created and sized but before the 
     *  editor is visible. This is an oppurtunity to adjust the look of
     *  the editor before it becomes visible.
     *  
     *  This function should only be called by the data grid.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */ 
    function prepare():void;
    
    /**
     *  Called just before the editor is closed. This is a chance
     *  of clean up anything that was set in prepare().
     *  
     *  This function should only be called by the data grid.
     * 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */ 
    function discard():void;
    
    /**
     *  Saves the value in the editor back into the item renderer's
     *  data. This function calls <code>validate()</code> to verify
     *  the data may be saved. If the data is not valid, then the
     *  data is not saved and the editor is not closed.
     * 
     *  This function should only be called by the data grid. To save
     *  and close the editor call the <code>endItemEditorSession()</code>
     *  function of the data grid owner.
     *  
     *  @see spark.components.DataGrid
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */  
    function save():Boolean;

}
}