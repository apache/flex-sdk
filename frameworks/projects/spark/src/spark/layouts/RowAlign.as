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

package spark.layout
{

/**
 *  Enumerated type for the TileLayout's <code>rowAlign</code>
 *  property.
 * 
 *  @see TileLayout#rowAlign
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public final class RowAlign
{
    /**
     *  Does not justify the rows.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const TOP:String = "top";

    /**
     *  Justifies the rows by increasing the vertical gap.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const JUSTIFY_USING_GAP:String = "justifyUsingGap";

    /**
     *  Justifies the rows by increasing the row height.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const JUSTIFY_USING_HEIGHT:String = "justifyUsingHeight";
}
}
