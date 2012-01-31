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
 *  Used when searching for a string.
 */
public class ListBaseFindPending
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
	public function ListBaseFindPending(searchString:String,
										startingBookmark:CursorBookmark,
										bookmark:CursorBookmark,
										offset:int, currentIndex:int,
										stopIndex:int)
	{
		super();

		this.searchString = searchString;
		this.startingBookmark = startingBookmark;
		this.bookmark = bookmark;
		this.offset = offset;
		this.currentIndex = currentIndex;
		this.stopIndex = stopIndex;
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
	 *  The bookmark we have to seek to when the data arrives
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var bookmark:CursorBookmark;

	//----------------------------------
	//  currentIndex
	//----------------------------------

	/**
	 *  The currentIndex we are looking at when we hit the page fault
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var currentIndex:int;

	//----------------------------------
	//  offset
	//----------------------------------

	/**
	 *  The offset from the bookmark we have to seek to when the data arrives
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var offset:int;

	//----------------------------------
	//  searchString
	//----------------------------------

	/**
	 *  The string we were searching for when the hit the page fault
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var searchString:String;

	//----------------------------------
	//  startingBookmark
	//----------------------------------

	/**
	 *  The bookmark where we were when we started
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var startingBookmark:CursorBookmark;

	//----------------------------------
	//  stopIndex
	//----------------------------------

	/**
	 *  The index we should stop at
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var stopIndex:int;
}

}
