////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
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
