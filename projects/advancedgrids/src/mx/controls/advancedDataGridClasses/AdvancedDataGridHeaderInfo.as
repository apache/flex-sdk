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

import mx.controls.listClasses.IListItemRenderer;
/**                                                                                                                                                                         
  *  The AdvancedDataGridHeaderInfo class contains information that describes the 
  *  hierarchy of the columns of the AdvancedDataGrid control.
  *  
  *  @langversion 3.0
  *  @playerversion Flash 9
  *  @playerversion AIR 1.1
  *  @productversion Flex 3
  */                                        
public class AdvancedDataGridHeaderInfo
{
	include "../../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
    /**                                                                                                                                                                         
     *  Constructor.
     *
     *  @param column A reference to the AdvancedDataGridColumn instance 
     *  that this AdvancedDataGridHeaderInfo instance corresponds to.
     *
     *  @param parent The parent AdvancedDataGridHeaderInfo instance 
     *  of this AdvancedDataGridHeaderInfo instance.
     *
     *  @param index The index of this AdvancedDataGridHeaderInfo instance 
     *  in the AdvancedDataGrid control.
     *
     *  @param depth The depth of this AdvancedDataGridHeaderInfo instance 
     *  in the columns hierarchy of the AdvancedDataGrid control.
     *
     *  @param children An Array of all of the child AdvancedDataGridHeaderInfo instances 
     *  of this AdvancedDataGridHeaderInfo instance.
     *
     *  @param internalLabelFunction A function that gets created if the column grouping 
     *  requires extracting data from nested objects.
     *
     *  @param headerItem A reference to IListItemRenderer instance used to 
     *  render the column header.
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */                                        
    public function AdvancedDataGridHeaderInfo(column:AdvancedDataGridColumn,
                                      parent:AdvancedDataGridHeaderInfo,
                                      index:int,
                                      depth:int,
                                      children:Array = null,
                                      internalLabelFunction:Function = null,
                                      headerItem:IListItemRenderer = null)
    {
       this.column = column;
       this.parent = parent;
       this.index = index;
       this.depth = depth;
       this.children = children;
       this.internalLabelFunction = internalLabelFunction;
       this.headerItem = headerItem;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------   
    
    //----------------------------------
    // column
    //----------------------------------

    /**
    *  A reference to the AdvancedDataGridColumn instance 
    *  corresponding to this AdvancedDataGridHeaderInfo instance.                                                                                         
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    public var column:AdvancedDataGridColumn;
    
    //----------------------------------
    // parent
    //----------------------------------
    
    /**
    *  The parent AdvancedDataGridHeaderInfo instance 
    *  of this AdvancedDataGridHeaderInfo instance 
    *  if this column is part of a column group.
    *
    *  @default null
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    public var parent:AdvancedDataGridHeaderInfo;
    
    //----------------------------------
    // index
    //----------------------------------
    
    /**
    *  The index of this AdvancedDataGridHeaderInfo instance 
    *  in the AdvancedDataGrid control.
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    public var index:int;
    
    //----------------------------------
    // depth
    //----------------------------------
    
    /**
    *  The depth of this AdvancedDataGridHeaderInfo instance 
    *  in the columns hierarchy of the AdvancedDataGrid control,
    *  if this column is part of a column group.
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    public var depth:int;
    
    //----------------------------------
    // children
    //----------------------------------
    
    /**
    *  An Array of all of the child AdvancedDataGridHeaderInfo instances
    *  of this AdvancedDataGridHeaderInfo instance,
    *  if this column is part of a column group.
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    public var children:Array;
    
    //----------------------------------
    // headerItem
    //----------------------------------
    
    /**
    *  A reference to IListItemRenderer instance used to render the column header.
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    public var headerItem:IListItemRenderer;
    
    //----------------------------------
    // internalLabelFunction
    //----------------------------------
    
    /**
    *  A function that gets created if the 
    *  column grouping requires extracting data from nested objects.
    *
    *  <p>For example, if each data row appears as: </p>
    *  <pre>row = {.., .., Q1: { y2005: 241, y2006:353}};</pre>
    *
    *  <p>and you define a column group as:</p>
    *  <pre>     &lt;mx:AdvancedDataGridColumnGroup dataField="Q1"&gt;
    *     &lt;mx:AdvancedDataGridColumn dataField="y2005"&gt;
    *     &lt;mx:AdvancedDataGridColumn dataField="y2006"&gt;
    *  &lt;/mx:AdvancedDataGridColumnGroup&gt;</pre>
    *
    * <p>The function for the column corresponding to y2005 is defined as:</p>
    * <pre>     function foo():String
    *  {
    *     return row["Q1"]["2005"];
    *  }</pre>
    * 
    *  <p>The function also handles the case when any of the column or column groups
    *  uses a label function instead of a data field.</p>
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    public var internalLabelFunction:Function;
    
    //----------------------------------
    // columnSpan
    //----------------------------------
    
    /**
    *  Number of actual columns spanned by the column header when using column groups.
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    public var columnSpan:int;
    
    //----------------------------------
    // actualColNum
    //----------------------------------
    
    /**
    *  The actual column index at which the header starts,
    *  relative to the currently displayed columns.
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    public var actualColNum:int;
    
    //----------------------------------
    // visible
    //----------------------------------
    
    /**
    *  Contains <code>true</code> if the column is currently visible.
    *
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    public var visible:Boolean;
    
    //----------------------------------
    // visibleChildren
    //----------------------------------
    
    /**
    *  An Array of the currently visible child AdvancedDataGridHeaderInfo instances. 
    *  if this column is part of a column group.
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    public var visibleChildren:Array;
    
    //----------------------------------
    // visibleIndex
    //----------------------------------
    
    /**
    *  The index of this column in the list of visible children of its parent
    *  AdvancedDataGridHeaderInfo instance,
    *  if this column is part of a column group.
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    public var visibleIndex:int;
}

}