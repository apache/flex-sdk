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

/**
 *  An object that stores data about a seek operation
 *  that was interrupted by an ItemPendingError error.
 *
 *  @see mx.collections.errors.ItemPendingError
 *  @see mx.controls.listClasses.ListBase#lastSeekPending
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class ListBaseSeekPending
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
	 *  @param bookmark The bookmark that was being used in the 
	 *                  seek operation.
	 *  @param offset The offset from the bookmark that was the target of
	 *                  the seek operation.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function ListBaseSeekPending(bookmark:CursorBookmark, offset:int)
	{
		super();

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
	 *  The bookmark that was being used in the seek operation.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var bookmark:CursorBookmark;

	//----------------------------------
	//  offset
	//----------------------------------

	/**
	 *  The offset from the bookmark that was the target of the seek operation.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var offset:int;
}

}