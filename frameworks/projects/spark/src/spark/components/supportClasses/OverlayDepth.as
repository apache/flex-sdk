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
 *  various overlay elements used by Flex.
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
     *  The default depth value under all Flex overlay elements.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const BOTTOM:Number = 0;

    /**
	 *  The overlay depth for a drop indicator.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public static const DROP_INDICATOR:Number = 1000;

	/**
	 *  The overlay depth for a focus pane.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public static const FOCUS_PANE:Number = 2000;

    /**
     *  The overlay depth for a mask.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const MASK:Number = 3000;
    
	/**
	 *  The default depth value above all Flex overlay elements.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public static const TOP:Number = 10000;
}
}