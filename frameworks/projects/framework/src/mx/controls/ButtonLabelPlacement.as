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

package mx.controls
{

/**
 *  The ButtonLabelPlacement class defines the constants for the allowed values 
 *  of the <code>labelPlacement</code>
 *  property of a Button, CheckBox, LinkButton, or RadioButton control.
 *
 *  @see mx.controls.Button
 *  @see mx.controls.CheckBox
 *  @see mx.controls.LinkButton
 *  @see mx.controls.RadioButton
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public final class ButtonLabelPlacement
{
	include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

	/**
	 *  Specifies that the label appears below the icon.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const BOTTOM:String = "bottom";
	
	/**
	 *  Specifies that the label appears to the left of the icon.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const LEFT:String = "left";
	
	/**
	 *  Specifies that the label appears to the right of the icon.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const RIGHT:String = "right";
	
	/**
	 *  Specifies that the label appears above the icon.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const TOP:String = "top";
}

}
