
package spark.core
{

/**
 *  The MaskType class defines the possible values for the 
 *  <code>maskType</code> property of the GraphicElement class.
 * 
 *  @see spark.primitives.supportClasses.GraphicElement#maskType
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public final class MaskType
{
    include "../core/Version.as";

    /**
     *  The mask either displays the pixel or does not. 
     *  Strokes and bitmap filters are not used. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const CLIP:String = "clip";

    /**
     *  The mask respects opacity and uses the strokes and bitmap filters of the mask.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ALPHA:String = "alpha";
    
    /**
     *  The mask respects both opacity and RGB color values and 
	 *  uses the strokes and bitmap filters of the mask.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const LUMINOSITY:String = "luminosity";
}

}
