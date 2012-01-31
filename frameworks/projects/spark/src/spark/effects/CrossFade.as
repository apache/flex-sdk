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
package mx.effects
{
import flash.utils.ByteArray;
   
/**
 * This class performs a bitmap transition effect by running a
 * 'crossfade' between the first and second bitmaps.
 * The crossfade blends the two over the course of the 
 * animation such that, at any point in the animation, where the 
 * elapsed and eased fraction of the animation is f and the pixel
 * values in the first and second bitmaps are v1 and v2, the resulting
 * pixel value v for any pixel in the image will be
 * <code>v = v1 * (1 - f) + v2 * f</code>.
 * 
 * <p>The underlying bitmap effect is run by a Pixel Bender shader 
 * that is loaded by the effect. There is no need to supply a shader
 * to this effect since it uses its own by default. However, if
 * a different Crossfade behavior is desired, a different shader may be
 * supplied, as long as it adheres to the constraints specified 
 * for the <code>shaderCode</code> property of FxAnimateBitmap.</p>
 * 
 * @see mx.effects.FxAnimateShaderTransition#shaderCode
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class FxCrossFade extends FxAnimateShaderTransition
{
    [Embed(source="FxCrossFade.pbj", mimeType="application/octet-stream")]
    private static var CrossFadeShaderClass:Class;
    private static var crossFadeShaderCode:ByteArray = new CrossFadeShaderClass();

    public function FxCrossFade(target:Object=null)
    {
        super(target);
        // Note that we do not need a separate FxCrossFadeInstance; the only
        // addition that FxCrossFade adds is specifying the Crossfade
        // Pixel Bender shader. Everything else needed is in the 
        // superclass already.
        shaderCode = crossFadeShaderCode;
    }
    
}
}