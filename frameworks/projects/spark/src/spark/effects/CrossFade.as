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
package spark.effects
{
import flash.utils.ByteArray;
   
/**
 * The CrossFade effect performs a bitmap transition effect by running a
 * <i>crossfade</i> between the first and second bitmaps.
 * The crossfade blends the two bitmaps over the duration of the 
 * animation.
 *
 * <p>At any point in the animation, where the 
 * elapsed and eased fraction of the animation is <code>f</code> and the pixel
 * values in the first and second bitmaps are <code>v1</code> and <code>v2</code>, 
 * the resulting pixel value <code>v</code> for any pixel in the image is:</p>
 *
 * <pre>v = v1 &#42; (1 - f) + v2 &#42; f</pre>
 * 
 * <p>The bitmap effect is run by a pixel-shader program
 * that is loaded by the effect. 
 * You can specify a different crossfade behavior by specifying 
 * a pixel-shader program to the <code>shaderByteCode</code> property.
 * That pixel-shader program must meet the requirements defined in the 
 * AnimateTransitionShader effect. </p>
 * 
 * @see spark.effects.AnimateTransitionShader
 * @see spark.effects.AnimateTransitionShader#shaderByteCode
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class CrossFade extends AnimateTransitionShader
{
    [Embed(source="CrossFade.pbj", mimeType="application/octet-stream")]
    private static var CrossFadeShaderClass:Class;
    private static var crossFadeShaderCode:ByteArray = new CrossFadeShaderClass();

    /**
     *  Constructor. 
     *
     *  @param target The Object to animate with this effect.  
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function CrossFade(target:Object=null)
    {
        super(target);
        // Note that we do not need a separate CrossFadeInstance; the only
        // addition that CrossFade adds is specifying the Crossfade
        // Pixel Bender shader. Everything else needed is in the 
        // superclass already.
        shaderByteCode = crossFadeShaderCode;
    }
    
}
}