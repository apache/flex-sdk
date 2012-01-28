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
 *  The IHierarchicalCollectionViewCursor interface defines the interface 
 *  for enumerating a hierarchical collection view bidirectionally.
 *  This cursor provides capabilities to find the current depth of an item. 
 * 
 *  @see mx.collections.IViewCursor
 *  @see mx.controls.IHierarchicalCollectionView
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IHierarchicalCollectionViewCursor extends IViewCursor
{
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
    /**
     *  Contains the depth of the node at the location
     *  in the source collection referenced by this cursor.
     *  If the cursor is beyond the end of the collection,
     *  this property contains 0.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
     function get currentDepth():int;

}

}
