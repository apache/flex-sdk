////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components
{
    
    /**
     *  The ScrollSnappingMode class defines the enumeration values for 
     *  the <code>scrollSnappingMode</code> property of the List and Scroller classes.
     *
     *  @see spark.components.List#scrollSnappingMode
     *  @see spark.components.Scroller#scrollSnappingMode
     *
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public final class ScrollSnappingMode
    {
        /**
         *  Scroll snapping is off.
         *
         *  @langversion 3.0
         *  @playerversion AIR 3
         *  @productversion Flex 4.6
         */
        public static const NONE:String = "none";
        
        /**
         *  Elements are snapped to the left (horizontal) or top (vertical)
         *  edge of the viewport.
         *
         *  @langversion 3.0
         *  @playerversion AIR 3
         *  @productversion Flex 4.6
         */
        public static const LEADING_EDGE:String = "leadingEdge";
        
        /**
         *  Elements are snapped to the center of the viewport.
         *
         *  @langversion 3.0
         *  @playerversion AIR 3
         *  @productversion Flex 4.6
         */
        public static const CENTER:String = "center";
        
        /**
         *  Elements are snapped to the right (horizontal) or bottom (vertical)
         *  edge of the viewport.
         *
         *  @langversion 3.0
         *  @playerversion AIR 3
         *  @productversion Flex 4.6
         */
        public static const TRAILING_EDGE:String = "trailingEdge";
        
    }
}