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
import flash.events.IEventDispatcher;

/**
 *  The IHierarchicalData interface defines the interface 
 *  used to represent hierarchical data as the data provider for
 *  a Flex component. 
 *  Hierarchical data is data in a structure of parent 
 *  and child data items.
 *
 *  @see mx.collections.ICollectionView
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IHierarchicalData extends IEventDispatcher
{
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
    /**
     *  Returns <code>true</code> if the node can contain children.
     *
     *  <p>Nodes do not have to contain children for the method
     *  to return <code>true</code>. 
     *  This method is useful in determining whether other 
     *  nodes can be appended as children to the specified node.</p>
     * 
     *  @param node The Object that defines the node.
     *
     *  @return <code>true</code> if the node can contain children.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function canHaveChildren(node:Object):Boolean;

    /**
     *  Returns <code>true</code> if the node has children. 
     * 
     *  @param node The Object that defines the node.
     *
     *  @return <code>true</code> if the node has children.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function hasChildren(node:Object):Boolean;
    
    /**
     *  Returns an Object representing the node's children. 
     *
     *  @param node The Object that defines the node.
     *  If <code>null</code>, return a collection of top-level nodes.
     *
     *  @return An Object containing the children nodes.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getChildren(node:Object):Object;

    /**
     *  Returns data from a node.
     *
     *  @param node The node Object from which to get the data.
     *
     *  @return The requested data.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getData(node:Object):Object;
    
    /**
     * Returns the root data item.
     * 
     * @return The Object containing the root data item.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    function getRoot():Object;
}

}
