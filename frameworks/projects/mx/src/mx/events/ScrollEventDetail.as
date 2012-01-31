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

package mx.events
{

/**
 *  Constants for the values of the <code>detail</code> property
 *  of a ScrollEvent.
 *
 *  @see mx.events.ScrollEvent
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public final class ScrollEventDetail
{
	include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

	/**
	 *  Indicates that the scroll bar is at the bottom of its scrolling range.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const AT_BOTTOM:String = "atBottom";

	/**
	 *  Indicates that the scroll bar is at the left of its scrolling range.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const AT_LEFT:String = "atLeft";

	/**
	 *  Indicates that the scroll bar is at the right of its scrolling range.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const AT_RIGHT:String = "atRight";

	/**
	 *  Indicates that the scroll bar is at the top of its scrolling range.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const AT_TOP:String = "atTop";

	/**
	 *  Indicates that the scroll bar has moved down by one line.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const LINE_DOWN:String = "lineDown";

	/**
	 *  Indicates that the scroll bar has moved left by one line.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const LINE_LEFT:String = "lineLeft";

	/**
	 *  Indicates that the scroll bar has moved right by one line.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const LINE_RIGHT:String = "lineRight";

	/**
	 *  Indicates that the scroll bar has moved up by one line.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const LINE_UP:String = "lineUp";

	/**
	 *  Indicates that the scroll bar has moved down by one page.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const PAGE_DOWN:String = "pageDown";

	/**
	 *  Indicates that the scroll bar has moved left by one page.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const PAGE_LEFT:String = "pageLeft";

	/**
	 *  Indicates that the scroll bar has moved right by one page.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const PAGE_RIGHT:String = "pageRight";

	/**
	 *  Indicates that the scroll bar has moved up by one page.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const PAGE_UP:String = "pageUp";

	/**
	 *  Indicates that the scroll bar thumb has stopped moving.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const THUMB_POSITION:String = "thumbPosition";

	/**
	 *  Indicates that the scroll bar thumb is moving.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const THUMB_TRACK:String = "thumbTrack";
}

}
