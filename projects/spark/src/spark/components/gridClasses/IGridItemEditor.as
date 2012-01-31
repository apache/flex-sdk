package spark.components
{
import mx.core.IDataRenderer;
import mx.core.IIMESupport;
import mx.core.IVisualElement;
import mx.managers.IFocusManagerComponent;

import spark.components.supportClasses.GridItemRenderer;
import spark.components.supportClasses.GridColumn;
import spark.components.DataGrid;

/**
 *  Grid item editors must implement this interface. 
 * 
 *  <p>All of the item editor's properties are set by the DataGrid during 
 *  the start of the editor session. After they've been set, the editor's 
 *  <code>prepare()</code> method is called. IGridItemEditor 
 *  implementations should override the preprare() method to make any final
 *  adjustments to its properties or any aspect of its visual elements. 
 *  When the editor is closing the <code>discard()</code> method is called.</p>
 *  
 * <p>When the editor is closed the input value can be saved or cancelled. If saving, 
 * the <code>save()</code> function is called. If canceling the <code>
 * cancel()</code> function is called. 
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
     *  The dataGrid that owns this editor.
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
    function set columnIndex(value:int):void;

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

    //----------------------------------
    //  value
    //----------------------------------
    
    /** 
     *  The value of the edit control. This is set by the data grid when
     *  the editor is first created. When the editor is saved, the
     *  data grid gets the editor value from this property. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */ 
    function get value():Object;
    function set value(newValue:Object):void;
    
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
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */ 
    function discard():void;
    
    /**
     *  Tests if the value in the editor is valid and may be saved.
     * 
     *  @returns true if the value in the editor is valid. Otherwise
     *  false is returned.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */  
    function validate():Boolean;

    /**
     *  Saves the value in the editor back into the item renderer's
     *  data. This function calls <code>validate()</code> to verify
     *  the data may be saved. If the data is not valid, then the
     *  data is not saved and the editor is not closed.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */  
    function save():Boolean;

    /**
     *  Closes the editor without saving the data.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */  
    function cancel():void;
    
}
}