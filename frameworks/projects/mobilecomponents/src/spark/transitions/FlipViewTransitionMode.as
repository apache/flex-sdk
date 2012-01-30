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

package spark.transitions
{
	
/**
 *  The FlipViewTransitionMode class provides the constants used when hinting
 *  the style mode of a flip transition instance.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class FlipViewTransitionMode
{
	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  The previous view flips at its center point as the new view is revealed 
     *  on the other side.
	 */
	public static const CARD:String = "card";
	
	/**
     * The previous view is transformed away like the face on a rotating cube, as 
     * the new view is revealed as the adjacent face of the cube.
	 */
	public static const CUBE:String = "cube";		
}
	
}