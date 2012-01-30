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

package mx.filters
{
    import flash.filters.BitmapFilter;
    
   /**
    *  Interface used by some Spark filters.
    * 
    *  @langversion 3.0
    *  @playerversion Flash 10
    *  @playerversion AIR 1.5
    *  @productversion Flex 4
    */
    public interface IBitmapFilter
    {
       /**
        *  Returns a copy of the filter.
        * 
        *  @return A new BitmapFilter instance with all the same properties as the original BitmapFilter instance.
        * 
        *  @langversion 3.0
        *  @playerversion Flash 10
        *  @playerversion AIR 1.5
        *  @productversion Flex 4
        */
        function clone():BitmapFilter;
    }
}