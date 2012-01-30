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
	
	/**
	 * Determine if the type of an event is a mouse event.
	 *
	 * @return true if the type is a one of the events in MouseEvent, false otherwise.
	 * 
	 */
	public static function isMouseEvent(type:String):Boolean
	{
		if (type == MouseEvent.CLICK || type == MouseEvent.DOUBLE_CLICK ||
			type == MouseEvent.MOUSE_DOWN || type == MouseEvent.MOUSE_MOVE ||
			type == MouseEvent.MOUSE_OUT || type == MouseEvent.MOUSE_OVER ||
			type == MouseEvent.MOUSE_UP ||  type == MouseEvent.MOUSE_WHEEL ||
			type == MouseEvent.ROLL_OUT ||  type == MouseEvent.ROLL_OVER)
		{
			return true;
		}
		
		return false;
	}

}
}