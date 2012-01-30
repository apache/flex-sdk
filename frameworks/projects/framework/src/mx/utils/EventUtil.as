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
import mx.events.MarshalMouseEvent;

/**
 * Utilities to help in handling Events or Event Dispatching.
 * 
 */
public class EventUtil
{
	include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------
	
	private static var _marshalEventMap:Object;

	/**
	 *  mapping of MouseEvents to MarshalMouseEvent types
	 */
	public static function get marshalMouseEventMap():Object
	{
		if (!_marshalEventMap)
		{
			_marshalEventMap = {};
			_marshalEventMap[MarshalMouseEvent.CLICK] = MouseEvent.CLICK;
			_marshalEventMap[MarshalMouseEvent.DOUBLE_CLICK] = MouseEvent.DOUBLE_CLICK;
			_marshalEventMap[MarshalMouseEvent.MOUSE_DOWN] = MouseEvent.MOUSE_DOWN;
			_marshalEventMap[MarshalMouseEvent.MOUSE_MOVE] = MouseEvent.MOUSE_MOVE;
			_marshalEventMap[MarshalMouseEvent.MOUSE_UP] = MouseEvent.MOUSE_UP;
			_marshalEventMap[MarshalMouseEvent.MOUSE_WHEEL] = MouseEvent.MOUSE_WHEEL;
		}

		return _marshalEventMap;
	}

	private static var _mouseEventMap:Object;

	/**
	 *  mapping of MarshalMouseEvent to MouseEvents  types
	 */
	public static function get mouseEventMap():Object
	{
		if (!_mouseEventMap)
		{
			_mouseEventMap = {};
			_mouseEventMap[MouseEvent.CLICK] = MarshalMouseEvent.CLICK;
			_mouseEventMap[MouseEvent.DOUBLE_CLICK] = MarshalMouseEvent.DOUBLE_CLICK;
			_mouseEventMap[MouseEvent.MOUSE_DOWN] = MarshalMouseEvent.MOUSE_DOWN;
			_mouseEventMap[MouseEvent.MOUSE_MOVE] = MarshalMouseEvent.MOUSE_MOVE;
			_mouseEventMap[MouseEvent.MOUSE_UP] = MarshalMouseEvent.MOUSE_UP;
			_mouseEventMap[MouseEvent.MOUSE_WHEEL] = MarshalMouseEvent.MOUSE_WHEEL;
		}

		return _mouseEventMap;
	}
}
}