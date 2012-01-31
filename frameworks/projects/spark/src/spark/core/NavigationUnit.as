////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.core
{
import flash.ui.Keyboard;

/**
 *  The NavigationUnit class defines the possible values for the 
 *  <code>getVerticalScrollPositionDelta()</code> and 
 *  <code>getHorizontalScrollPositionDelta()</code> 
 *  methods of the IViewport class.
 * 
 *  <p>All of these constants have the same values as their flash.ui.Keyboard
 *  counterparts, except PAGE_LEFT and PAGE_RIGHT, for which no keyboard
 *  key equivalents exist.</p>
 * 
 *  @see flash.ui.Keyboard
 *  @see IViewport#getVerticalScrollPositionDelta
 *  @see IViewport#getHorizontalScrollPositionDelta
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public final class NavigationUnit
{
    /**
     *  Navigate to the origin of the document.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const HOME:uint = Keyboard.HOME;
    
    /**
     *  Navigate to the end of the document.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const END:uint = Keyboard.END;
    
    /**
     *  Navigate one line or "step" upwards.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const UP:uint = Keyboard.UP;
    
    /**
     *  Navigate one line or "step" downwards.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const DOWN:uint = Keyboard.DOWN;
    
    /**
     *  Navigate one line or "step" to the left.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const LEFT:uint = Keyboard.LEFT;
    
    /**
     *  Navigate one line or "step" to the right.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const RIGHT:uint = Keyboard.RIGHT;
    
    /**
     *  Navigate one page upwards.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const PAGE_UP:uint = Keyboard.PAGE_UP;
    
    /**
     *  Navigate one page downwards.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const PAGE_DOWN:uint = Keyboard.PAGE_DOWN;
    
    /**
     *  Navigate one page to the left.
     * 
     *  The value of this constant, 0x2397, is the same as the Unicode
     *  "previous page" character. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const PAGE_LEFT:uint = 0x2397;
    
    /**
     *  Navigate one page to the right.
     * 
     *  The value of this constant, 0x2398, is the same as the Unicode
     *  "next page" character. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const PAGE_RIGHT:uint = 0x2398;
    
    /**
     *  Returns <code>true</code> if the <code>keyCode</code> maps directly 
     *  to a NavigationUnit enum value.
     *
     *  @param keyCode A key code value. 
     *
     *  @return <code>true</code> if the <code>keyCode</code> maps directly 
     *  to a NavigationUnit enum value.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static function isNavigationUnit(keyCode:uint):Boolean
    {
        switch (keyCode)
        {
            case Keyboard.LEFT:         return true;
            case Keyboard.RIGHT:        return true;
            case Keyboard.UP:           return true;
            case Keyboard.DOWN:         return true;
            case Keyboard.PAGE_UP:      return true;
            case Keyboard.PAGE_DOWN:    return true;
            case Keyboard.HOME:         return true;
            case Keyboard.END:          return true;
            default:                    return false;
        }
    }
}
}
