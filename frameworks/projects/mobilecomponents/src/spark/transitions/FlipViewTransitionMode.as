
package spark.transitions
{
    
/**
 *  The FlipViewTransitionMode class defines the constants used when hinting
 *  the style mode of a flip transition instance.
 *
 *  @see FlipViewTransition
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Deprecated(since="4.6")] 
public class FlipViewTransitionMode
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  The previous view flips at its center point as the new view is revealed 
     *  on the other side.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const CARD:String = "card";
    
    /**
     * The previous view is transformed away like the face on a rotating cube, as 
     * the new view is revealed as the adjacent face of the cube.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const CUBE:String = "cube";       
}
    
}