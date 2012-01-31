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