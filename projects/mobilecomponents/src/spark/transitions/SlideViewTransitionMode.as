
package spark.transitions
{
    
/**
 *  The SlideViewTransitionMode class provides the constants used to specify
 *  the type of a slide transition.
 *
 *  @see SlideViewTransition
 *  
 *  @langversion 3.0
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
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const COVER:String = "cover";
    
    /**
     * The previous view slides away as the new view slides in.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const PUSH:String = "push";
    
    /**
     * The previous view slides away to reveal the new view.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const UNCOVER:String = "uncover";

}
    
}