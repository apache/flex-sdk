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

package mx.utils
{

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import mx.core.IRawChildrenContainer;

/**
 *  The DisplayUtil utility class is an all-static class with utility methods
 *  related to DisplayObjects.
 *  You do not create instances of the DisplayUtil class;
 *  instead you call static methods such as the 
 *  <code>DisplayUtil.walkDisplayObjects()</code>.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class DisplayUtil
{
	include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------
		
	/**
	 *  Recursively calls the specified function on each node in the specified DisplayObject's tree,
	 *  passing it a reference to that DisplayObject.
	 *  
	 *  @param displayObject The target DisplayObject.
	 *  @param callbackFunction The method to call on each node in the specified DisplayObject's tree. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static function walkDisplayObjects(displayObject:DisplayObject,
											  callbackFunction:Function):void
	{
		callbackFunction(displayObject)

		if (displayObject is DisplayObjectContainer)
		{
			var n:int =
				displayObject is IRawChildrenContainer ?
				IRawChildrenContainer(displayObject).rawChildren.numChildren :
				DisplayObjectContainer(displayObject).numChildren;
			
			for (var i:int = 0; i < n; i++)
			{
				var child:DisplayObject =
					displayObject is IRawChildrenContainer ?
					IRawChildrenContainer(displayObject).
					rawChildren.getChildAt(i) :
					DisplayObjectContainer(displayObject).getChildAt(i);

				walkDisplayObjects(child, callbackFunction);
			}
		}
	}
}

}
