////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components.supportClasses
{
/**
 *  The OverlayDepth class defines the default depth values for 
 *  various overlay elements.
 * 
 *  @see spark.components.Group#overlay
 *  @see spark.components.DataGroup#overlay
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public final class OverlayDepth
{
	/**
	 *  The overlay depth for a drop indicator.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public static const DROP_INDICATOR_DEPTH:Number = 100;

	/**
	 *  The overlay depth for a mask object.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public static const MASK_DEPTH:Number = 200;

	/**
	 *  The overlay depth for a focus object.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public static const FOCUS_DEPTH:Number = 300;

	/**
	 *  The default top most overlay depth.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public static const TOPMOST:Number = 10000;
}
}