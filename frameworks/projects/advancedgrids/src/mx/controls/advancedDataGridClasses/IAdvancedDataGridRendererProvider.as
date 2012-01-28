////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.controls.advancedDataGridClasses
{
    
import mx.controls.AdvancedDataGrid;

/**
 *  The IAdvancedDataGridRendererProvider interface defines the interface 
 *  implemented by the AdvancedDataGridRendererProvider class, 
 *  which defines the item renderer for the AdvancedDataGrid control. 
 *
 *  @see mx.controls.AdvancedDataGrid
 *  @see mx.controls.advancedDataGridClasses.AdvancedDataGridRendererProvider
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */    
public interface IAdvancedDataGridRendererProvider
{
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /** 
     *  Updates the IAdvancedDataGridRendererDescription instance with 
     *  information about this IAdvancedDataGridRendererProvider.
     * 
     *  @param data The data item to display.
     * 
     *  @param dataDepth The depth of the data item in the AdvancedDataGrid control.
     * 
     *  @param column The column associated with the item.
     * 
     *  @param description The AdvancedDataGridRendererDescription object 
     *  populated with the renderer and column span information.
     * 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function describeRendererForItem(data:Object, 
                                       dataDepth:int, 
                                       column:AdvancedDataGridColumn,
                                       description:AdvancedDataGridRendererDescription):void;
}
}