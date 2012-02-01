////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.skins
{
	

/**
 *  The IHighlightBitmapCaptureClient defines the interface for skins that support
 *  highlight bitmap capture.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public interface IHighlightBitmapCaptureClient
{
	/**
	 *  Called before a bitmap capture is made for this skin. 
	 * 
	 *  Return true if the skin needs to be updated before the bitmap is captured.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.5
	 *  @productversion Flex 4.5
	 */
	function beginHighlightBitmapCapture():Boolean;
	
	/**
	 *  Called after a bitmap capture is made for this skin. 
	 * 
	 *  Return true if the skin needs to be updated.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.5
	 *  @productversion Flex 4.5
	 */
	function endHighlightBitmapCapture():Boolean;
	
	/**
	 *  Validate the skin.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.5
	 *  @productversion Flex 4.5
	 */
	function validateNow():void;
}
}