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
	
import flash.events.MouseEvent;
import mx.events.SandboxMouseEvent;

[ExcludeClass]

/**
 *  @private
 * 
 *  Utilities to help with event dispatching or event handling.
 */
public class EventUtil
{
	include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
    //  sandboxMouseEventMap
	//----------------------------------

	/**
     *  @private
     */
    private static var _sandboxEventMap:Object;

	/**
	 *  Mapping of MouseEvents to SandboxMouseEvent types.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static function get sandboxMouseEventMap():Object
	{
		if (!_sandboxEventMap)
		{
			_sandboxEventMap = {};

			_sandboxEventMap[SandboxMouseEvent.CLICK_SOMEWHERE] =
                MouseEvent.CLICK;
			_sandboxEventMap[SandboxMouseEvent.DOUBLE_CLICK_SOMEWHERE] =
                MouseEvent.DOUBLE_CLICK;
			_sandboxEventMap[SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE] =
                MouseEvent.MOUSE_DOWN;
			_sandboxEventMap[SandboxMouseEvent.MOUSE_MOVE_SOMEWHERE] =
                MouseEvent.MOUSE_MOVE;
			_sandboxEventMap[SandboxMouseEvent.MOUSE_UP_SOMEWHERE] =
                MouseEvent.MOUSE_UP;
			_sandboxEventMap[SandboxMouseEvent.MOUSE_WHEEL_SOMEWHERE] =
                MouseEvent.MOUSE_WHEEL;
		}

		return _sandboxEventMap;
	}

	//----------------------------------
    //  mouseEventMap
	//----------------------------------

	/**
     *  @private
     */
	private static var _mouseEventMap:Object;

	/**
	 *  Mapping of SandboxMouseEvent to MouseEvents types.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static function get mouseEventMap():Object
	{
		if (!_mouseEventMap)
		{
			_mouseEventMap = {};

			_mouseEventMap[MouseEvent.CLICK] =
                SandboxMouseEvent.CLICK_SOMEWHERE;
			_mouseEventMap[MouseEvent.DOUBLE_CLICK] =
                SandboxMouseEvent.DOUBLE_CLICK_SOMEWHERE;
			_mouseEventMap[MouseEvent.MOUSE_DOWN] =
                SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE;
			_mouseEventMap[MouseEvent.MOUSE_MOVE] =
                SandboxMouseEvent.MOUSE_MOVE_SOMEWHERE;
			_mouseEventMap[MouseEvent.MOUSE_UP] =
                SandboxMouseEvent.MOUSE_UP_SOMEWHERE;
			_mouseEventMap[MouseEvent.MOUSE_WHEEL] =
                SandboxMouseEvent.MOUSE_WHEEL_SOMEWHERE;
		}

		return _mouseEventMap;
	}
}

}
