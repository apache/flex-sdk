////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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