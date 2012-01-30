
package spark.transitions
{
    
/**
 *  The ZoomTransitionMode class defines the constants used for setting 
 *  the style mode of a zoom transition.
 *
 *  @see ZoomViewTransition
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Deprecated(since="4.6")] 
public class ZoomViewTransitionMode
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  The new view zooms in to cover the previous view.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const IN:String = "in";
    
    /**
     * The previous view zooms out to reveal the new view.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const OUT:String = "out";     
}
    
}