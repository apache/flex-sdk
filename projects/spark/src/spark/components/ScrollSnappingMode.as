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
     *  Values for the <code>scrollSnappingMode</code> property of the
     *  List and Scroller classes
     *
     */
    public final class ScrollSnappingMode
    {
        /**
         *  Scroll snapping is off
         *
         */
        public static const NONE:String = "none";
        
        /**
         *  Elements are snapped to the left (horizontal) or top (vertical)
         *  edge of the viewport.
         *
         */
        public static const LEADING_EDGE:String = "leadingEdge";
        
        /**
         *  Elements are snapped to the center of the viewport.
         *
         */
        public static const CENTER:String = "center";
        
        /**
         *  Elements are snapped to the right (horizontal) or bottom (vertical)
         *  edge of the viewport.
         *
         */
        public static const TRAILING_EDGE:String = "trailingEdge";
        
    }
}