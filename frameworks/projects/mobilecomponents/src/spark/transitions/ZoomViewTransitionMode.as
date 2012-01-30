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
 *  The ZoomTransitionMode class provides the constants used when hinting
 *  the style mode of a zoom transition instance.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class ZoomViewTransitionMode
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  The new view zooms in to cover the previous view.
     */
    public static const IN:String = "in";
    
    /**
     * The previous view zooms out to reveal the new view.
     */
    public static const OUT:String = "out";     
}
    
}