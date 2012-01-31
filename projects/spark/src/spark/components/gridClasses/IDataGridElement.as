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
import mx.core.IInvalidating;
import mx.core.IVisualElement;
import mx.managers.ILayoutManagerClient;

import spark.components.DataGrid;

/**
 *  Visual elements of the Spark DataGrid control that must 
 *  remain in sync with the grid's layout and scroll
 *  position must implement this interface.   
 *  When the DataGrid control's <code>grid</code> skin part is added, 
 *  it sets the <code>IDataGridElement.dataGrid</code> property. 
 *  The IDataGridElements object can respond by adding event listeners 
 *  for scroll position changes.  
 *  When the DataGrid control is changed in a way that affects 
 *  its row or column layout, all IDataGridElements object are invalidated.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5 
 */
public interface IDataGridElement extends IVisualElement, ILayoutManagerClient, IInvalidating
{
    /**
     *  The DataGrid control associated with this element.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    function get dataGrid():DataGrid;
    function set dataGrid(value:DataGrid):void;        
}
}