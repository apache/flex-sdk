
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