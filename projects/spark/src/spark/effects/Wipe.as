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
import flash.display.Shader;
import flash.utils.ByteArray;
import mx.effects.IEffectInstance;
import spark.effects.supportClasses.WipeInstance;

/**
 * This class performs a bitmap transition effect by running a
 * directional 'wipe' between the first and second bitmaps.
 * This wipe exposes the second bitmap over the course of the 
 * animation in a direction indicated by the <code>direction</code>
 * property.
 * 
 * <p>The underlying bitmap effect is run by a Pixel Bender shader 
 * that is loaded by the effect. There is no need to supply a shader
 * to this effect since it uses its own by default. However, if
 * a different Wipe behavior is desired, a different shader may be
 * supplied, as long as it adheres to the following constraints: 
 * obey the constraints specified for the <code>shaderCode</code>
 * property of AnimateShaderTransition, and supply three additional
 * parameters. The extra parameters required by the Wipe shader 
 * are an int <code>direction</code> parameter, 
 * whose values mean the same as the related String properties
 * in the Wipe class, and floating point parameters
 * <code>imageWidth</code> and <code>imageHeight</code>. All of these
 * parameters will be set on the shader when the effect starts playing,
 * so the parameters need to exist and do something appropriate in
 * order for the effect to function correctly.</p>
 * 
 * @see mx.effects.AnimateShaderTransition#shaderCode
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class Wipe extends AnimateShaderTransition
{
    [Embed(source="Wipe.pbj", mimeType="application/octet-stream")]
    private static var WipeShaderClass:Class;
    private static var wipeShaderCode:ByteArray = new WipeShaderClass();
    
    
    [Inspectable(enumeration="left,right,up,down", defaultValue="right")]
    /**
     * The direction that the wipe will move during the animation, 
     * one of RIGHT, LEFT, UP, or DOWN. Other values will result in
     * undefined behavior. If no direction is supplied, a default
     * of RIGHT will be assumed;
     * @see WipeDirection#RIGHT
     * @see WipeDirection#UP
     * @see WipeDirection#LEFT
     * @see WipeDirection#DOWN
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var direction:String = WipeDirection.RIGHT;
    
    public function Wipe(target:Object=null)
    {
        super(target);
        instanceClass = WipeInstance;
        shaderCode = wipeShaderCode;
    }

    /**
     *  @private
     */
    override protected function initInstance(instance:IEffectInstance):void
    {
        super.initInstance(instance);
        
        var wipeInstance:WipeInstance = WipeInstance(instance);
        wipeInstance.direction = direction;
    }
    
}
}