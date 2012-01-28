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

package mx.collections
{

/**
 *  The IGroupingCollection interface defines the interface required 
 *  to create grouped data from flat data.
 *
 *  @see mx.collections.GroupingCollection
 *  @see mx.controls.AdvancedDataGrid
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Deprecated(replacement="IGroupingCollection2", since="4.0")]

public interface IGroupingCollection extends IHierarchicalData
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  grouping
	//----------------------------------
	
    /**
     *  The Grouping object applied to the source data. 
     *  Setting this property does not automatically refresh the view;
     *  therefore, you must call the <code>refresh()</code> method
     *  after setting this property.
     *
     *  <p>Note: The Flex implementations of IGroupingCollection retrieve all
     *  items from a remote location before executing grouping.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get grouping():Grouping;
       
    /**
     *  @private
     */
    function set grouping(value:Grouping):void;
    
    //--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
    
    /**
     *  Applies the grouping to the view.
     *  The IGroupingCollection does not detect changes to a group 
     *  automatically, so you must call the <code>refresh()</code>
     *  method to update the view after setting the <code>group</code> property.
     *
     *  <p>The <code>refresh()</code> method can be applied asynchronously
     *  by calling <code>refresh(true)</code>.</p>
     *  
     *  <p>When <code>refresh()</code> is called synchronously, 
     *  a client should wait for a CollectionEvent event
     *  with the value of the <code>kind</code> property set 
     *  to <code>CollectionEventKind.REFRESH</code> 
     *  to ensure that the <code>refresh()</code> method completed.</p>
     *
     *  @param async If <code>true</code>, defines the refresh to be asynchronous.
     *  By default it is <code>false</code> denoting synchronous refresh.
     *  
     *  @return <code>true</code> if the <code>refresh()</code> method completed,
     *  and <code>false</code> if the refresh is incomplete, 
     *  which can mean that items are still pending.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function refresh(async:Boolean = false):Boolean;
    
    /**
     *  If the refresh is performed asynchronously,
     *  cancels the refresh operation and stops the building of the groups.
     *  
     *  This method only cancels the refresh
     *  if it is initiated by a call to the <code>refresh()</code> method 
     *  with an argument of <code>true</code>, corresponding to an asynchronous refresh.
     *  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function cancelRefresh():void;
}

}
