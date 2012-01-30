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
 *  The SlideViewTransitionMode class provides the constants used when hinting
 *  the style mode of a slide transition instance.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class SlideViewTransitionMode
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     * The new view slides in to cover the previous view.
     */
    public static const COVER:String = "cover";
    
    /**
     * The previous view slides away as the new view slides in.
     */
    public static const PUSH:String = "push";
    
    /**
     * The previous view slides away to reveal the new view.
     */
    public static const UNCOVER:String = "uncover";

}
    
}