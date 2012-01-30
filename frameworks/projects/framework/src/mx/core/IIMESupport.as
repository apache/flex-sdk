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

/**
 *  The IIMESupport interface defines the interface for any component that supports IME 
 *  (input method editor).
 *  IME is used for entering characters in Chinese, Japanese, and Korean.
 * 
 *  @see flash.system.IME
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IIMESupport
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  editable
	//----------------------------------

	/**
     *  Specifies whether the user is allowed to edit the text in this control.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	function get editable():Boolean;

	//----------------------------------
	//  imeMode
	//----------------------------------

	/**
	 *  The IME mode of the component.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function get imeMode():String;

	/**
	 *  @private
	 */
	function set imeMode(value:String):void;


}

}
