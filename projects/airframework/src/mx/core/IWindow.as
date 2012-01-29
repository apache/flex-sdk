////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.core
{

import flash.display.NativeWindow;

/**
 *  Documentation is not currently available.
 */
public interface IWindow
{
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
	//  maximizable
    //----------------------------------

	/**
	 *  Documentation is not currently available.
	 */
	function get maximizable():Boolean;
	
    //----------------------------------
	//  minimizable
    //----------------------------------

	/**
	 *  Documentation is not currently available.
	 */
	function get minimizable():Boolean;
	
    //----------------------------------
	//  nativeWindow
    //----------------------------------

	/**
	 *  Documentation is not currently available.
	 */
	function get nativeWindow():NativeWindow

    //----------------------------------
	//  resizable
    //----------------------------------

	/**
	 *  Documentation is not currently available.
	 */
	function get resizable():Boolean;
	
    //----------------------------------
	//  status
    //----------------------------------

	/**
	 *  Documentation is not currently available.
	 */
	function get status():String;
	
	/**
	 *  @private
	 */
	function set status(value:String):void;
	
    //----------------------------------
	//  systemChrome
    //----------------------------------

	/**
	 *  Documentation is not currently available.
	 */
	function get systemChrome():String;
	
    //----------------------------------
	//  title
    //----------------------------------

	/**
	 *  Documentation is not currently available.
	 */
	function get title():String;
	
	/**
	 *  @private
	 */
	function set title(value:String):void;
	
    //----------------------------------
	//  titleIcon
    //----------------------------------

	/**
	 *  Documentation is not currently available.
	 */
	function get titleIcon():Class;
	
	/**
	 *  @private
	 */
	function set titleIcon(value:Class):void;
	
    //----------------------------------
	//  transparent
    //----------------------------------

	/**
	 *  Documentation is not currently available.
	 */
	function get transparent():Boolean;
	
    //----------------------------------
	//  type
    //----------------------------------

	/**
	 *  Documentation is not currently available.
	 */
	function get type():String;
	
    //----------------------------------
	//  visible
    //----------------------------------

	/**
	 *  Documentation is not currently available.
	 */
	function get visible():Boolean;
	 
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

	/**
	 *  Documentation is not currently available.
	 */
	function close():void; 
	 
	/**
	 *  Documentation is not currently available.
	 */
	function maximize():void
	
	/**
	 *  Documentation is not currently available.
	 */
	function minimize():void;
	
	/**
	 *  Documentation is not currently available.
	 */
	function restore():void;
}

}
