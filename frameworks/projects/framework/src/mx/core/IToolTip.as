////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.core
{

import flash.geom.Rectangle;

/**
 *  The IToolTip interface defines the API that tooltip-like components
 *  must implement in order to work with the ToolTipManager.
 *  The ToolTip class implements this interface.
 *
 *  @see mx.controls.ToolTip
 *  @see mx.managers.ToolTipManager
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IToolTip extends IUIComponent
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  screen
	//----------------------------------

	/**
	 *  A Rectangle that specifies the size and position
	 *  of the base drawing surface for this tooltip.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function get screen():Rectangle;

	//----------------------------------
	//  text
	//----------------------------------

	/**
	 *  The text that appears in the tooltip.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function get text():String;
	
	/**
	 *  @private
	 */
	function set text(value:String):void;
}

}
