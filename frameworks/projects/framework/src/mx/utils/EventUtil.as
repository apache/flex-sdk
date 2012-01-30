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
import mx.events.SandboxRootMouseEvent;

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
    //  sandboxRootMouseEventMap
	//----------------------------------

	/**
     *  @private
     */
    private static var _sandboxRootEventMap:Object;

	/**
	 *  Mapping of MouseEvents to SandboxRootMouseEvent types.
	 */
	public static function get sandboxRootMouseEventMap():Object
	{
		if (!_sandboxRootEventMap)
		{
			_sandboxRootEventMap = {};

			_sandboxRootEventMap[SandboxRootMouseEvent.CLICK_SOMEWHERE] =
                MouseEvent.CLICK;
			_sandboxRootEventMap[SandboxRootMouseEvent.DOUBLE_CLICK_SOMEWHERE] =
                MouseEvent.DOUBLE_CLICK;
			_sandboxRootEventMap[SandboxRootMouseEvent.MOUSE_DOWN_SOMEWHERE] =
                MouseEvent.MOUSE_DOWN;
			_sandboxRootEventMap[SandboxRootMouseEvent.MOUSE_MOVE_SOMEWHERE] =
                MouseEvent.MOUSE_MOVE;
			_sandboxRootEventMap[SandboxRootMouseEvent.MOUSE_UP_SOMEWHERE] =
                MouseEvent.MOUSE_UP;
			_sandboxRootEventMap[SandboxRootMouseEvent.MOUSE_WHEEL_SOMEWHERE] =
                MouseEvent.MOUSE_WHEEL;
		}

		return _sandboxRootEventMap;
	}

	//----------------------------------
    //  mouseEventMap
	//----------------------------------

	/**
     *  @private
     */
	private static var _mouseEventMap:Object;

	/**
	 *  Mapping of SandboxRootMouseEvent to MouseEvents types.
	 */
	public static function get mouseEventMap():Object
	{
		if (!_mouseEventMap)
		{
			_mouseEventMap = {};

			_mouseEventMap[MouseEvent.CLICK] =
                SandboxRootMouseEvent.CLICK_SOMEWHERE;
			_mouseEventMap[MouseEvent.DOUBLE_CLICK] =
                SandboxRootMouseEvent.DOUBLE_CLICK_SOMEWHERE;
			_mouseEventMap[MouseEvent.MOUSE_DOWN] =
                SandboxRootMouseEvent.MOUSE_DOWN_SOMEWHERE;
			_mouseEventMap[MouseEvent.MOUSE_MOVE] =
                SandboxRootMouseEvent.MOUSE_MOVE_SOMEWHERE;
			_mouseEventMap[MouseEvent.MOUSE_UP] =
                SandboxRootMouseEvent.MOUSE_UP_SOMEWHERE;
			_mouseEventMap[MouseEvent.MOUSE_WHEEL] =
                SandboxRootMouseEvent.MOUSE_WHEEL_SOMEWHERE;
		}

		return _mouseEventMap;
	}
}

}
