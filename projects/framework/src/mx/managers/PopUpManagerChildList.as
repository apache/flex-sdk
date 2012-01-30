////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.managers
{

/**
 *  The PopUpManagerChildList class defines the constant values for 
 *  the <code>detail</code> property of the
 *  PopUpManager <code>addPopUp()</code> and <code>createPopUp()</code> 
 *  methods.
 *  
 *  @see PopUpManager
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public final class PopUpManagerChildList
{
	include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

	/**
	 *  Indicates that the popup is placed in the same child list as the
	 *  application.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const APPLICATION:String = "application";

	/**
	 *  Indicates that the popup is placed in the popup child list
	 *  which will cause it to float over other popups in the application
	 *  layer.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const POPUP:String = "popup";

	/**
	 *  Indicates that the popup is placed in whatever child list the
	 *  parent component is in.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const PARENT:String = "parent";
}

}
