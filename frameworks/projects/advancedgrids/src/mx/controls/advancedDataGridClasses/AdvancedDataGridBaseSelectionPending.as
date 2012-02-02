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

import mx.collections.CursorBookmark;

[ExcludeClass]

/**
 *  @private
 *  The object that we use to store seek data
 *  that was interrupted by an ItemPendingError.
 *  Used when trying to match a selectedIndex to a selectedItem
 */
public class AdvancedDataGridBaseSelectionPending
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
	public function AdvancedDataGridBaseSelectionPending(index:int,
                                            anchorIndex:int,
                                            columnIndex:int,
                                            anchorColumnIndex:int,
											stopData:Object,
											transition:Boolean,
											placeHolder:CursorBookmark,
											bookmark:CursorBookmark,
											offset:int)
	{
		super();

		this.index       = index;
		this.anchorIndex = anchorIndex;
		this.columnIndex = columnIndex;
		this.stopData    = stopData;
		this.transition  = transition;
		this.placeHolder = placeHolder;
		this.bookmark    = bookmark;
		this.offset      = offset;
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
	//  anchorIndex
	//----------------------------------

	/**
	 *  The row position of the anchor
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var anchorIndex:int;

	//----------------------------------
	//  columnIndex
	//----------------------------------

	/**
	 *  The current column
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var columnIndex:int;

	//----------------------------------
	//  anchorColumnIndex
	//----------------------------------

	/**
	 *  The column position of the anchor
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var anchorColumnIndex:int;

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
	//  placeHolder
	//----------------------------------

	/**
	 *  The bookmark we have to restore after we're done
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var placeHolder:CursorBookmark;

	//----------------------------------
	//  stopData
	//----------------------------------

	/**
	 *  The data of the current item, which is the thing we are looking for.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var stopData:Object;

	//----------------------------------
	//  transition
	//----------------------------------

	/**
	 *  Whether to tween in the visuals
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var transition:Boolean;
}

}