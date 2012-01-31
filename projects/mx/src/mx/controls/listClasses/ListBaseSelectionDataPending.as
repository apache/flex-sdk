////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.controls.listClasses
{

import mx.collections.CursorBookmark;

[ExcludeClass]

/**
 *  @private
 *  The object that we use to store seek data
 *  that was interrupted by an ItemPendingError.
 *  Used when trying to select several items at once
 *  and match a selectedItem to its index.
 */
public class ListBaseSelectionDataPending
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
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function ListBaseSelectionDataPending(useFind:Boolean, index:int,
												 items:Array,
												 bookmark:CursorBookmark,
												 offset:int)
	{
		super();

		this.useFind = useFind;
		this.index = index;
		this.items = items;
		this.bookmark = bookmark;
		this.offset = offset;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  bookmark
	//----------------------------------

	/**
	 *  The bookmark we have to seek to
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var bookmark:CursorBookmark;

	//----------------------------------
	//  index
	//----------------------------------

	/**
	 *  The index into the iterator when we hit the page fault
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var index:int;

	//----------------------------------
	//  items
	//----------------------------------

	/**
	 *  The list if items being selected
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var items:Array;

	//----------------------------------
	//  offset
	//----------------------------------

	/**
	 *  The offset from the bookmark we have to seek to
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var offset:int;

	//----------------------------------
	//  useFind
	//----------------------------------

	/**
	 *  True if we use findAny, false if we iterate the collection
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var useFind:Boolean;
}

}
