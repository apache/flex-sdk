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

/**
 *  Enumerated type for the LayoutBase <code>getDestinationIndex()</code>
 *  method.
 *  List maps KeyboardEvent.keyCode to NavigationUnit values in its
 *  <code>mapEventToNavigationUnit</code> method.
 * 
 *  @see spark.layouts.LayoutBase#getDestinationIndex
 *  @see spark.components.List#mapEventToNavigationUnit
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public final class NavigationUnit
{
    /**
     *  Don't go to a different item.
     */
    public static const NONE:uint = 0;

    /**
     *  Go to the first item in the container.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const HOME:uint = 1;

    /**
     *  Go to the last item in the container.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const END:uint = 2;

    /**
     *  Go to the destination item by moving in the upward direction.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const UP:uint = 3;

    /**
     *  Go to the destination item by moving in the downward direction.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const DOWN:uint = 4;
    
    /**
     *  Go to the destination item by moving in the left direction.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const LEFT:uint = 5;

    /**
     *  Go to the destination item by moving in the right direction.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const RIGHT:uint = 6;

    /**
     *  Go to the destination item by moving by
     *  one page in the upward direction.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const PAGE_UP:uint = 7;

    /**
     *  Go to the destination item by moving by
     *  one page in the downward direction.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const PAGE_DOWN:uint = 8;

    /**
     *  Go to the destination item by moving by
     *  one page in the left direction.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const PAGE_LEFT:uint = 9;

    /**
     *  Go to the destination item by moving by
     *  one page in the right direction.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const PAGE_RIGHT:uint = 10;
}
}
