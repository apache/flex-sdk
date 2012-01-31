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
 *  DataGrid visual elements that must remain in sync with the grid's layout and scroll
 *  position must implement this interface.   When the DataGrid's grid skin part is added, 
 *  it will set its IDataGridElements' dataGrid property (the grid's owner is the DataGrid). 
 *  IDataGridElements should respond to this by adding listeners for dataGrid.grid scroll 
 *  position changes.  When the DataGrid is changed in a way that affects row/colunm layout, 
 *  all IDataGridElements will be invalidated.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5 
 */
public interface IDataGridElement extends IVisualElement, ILayoutManagerClient, IInvalidating
{
    /**
     *  The DataGrid whose layout and grid scroll position this element must stay in sync with.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    function get dataGrid():DataGrid;
    function set dataGrid(value:DataGrid):void;        
}
}