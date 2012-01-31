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
 *  The Wipe effect performs a bitmap transition effect by running a
 *  directional wipe between the first and second bitmaps.
 *  This wipe exposes the second bitmap over the course of the 
 *  animation in a direction indicated by the <code>direction</code>
 *  property.
 * 
 *  <p>The underlying bitmap effect is run by a pixel-shader program
 *  that is loaded by the effect. If you want to use 
 *  a different Wipe behavior, you can specify a custom pixel-shader program 
 *  as long as it adheres to the following constraints: 
 *  obey the constraints specified for the <code>shaderByteCode</code>
 *  property of AnimateTransitionShader class, and supply three additional
 *  parameters. The extra parameters required by the Wipe shader 
 *  are an int <code>direction</code> parameter, 
 *  whose values mean the same as the related String properties
 *  in the Wipe class, and floating point parameters
 *  <code>imageWidth</code> and <code>imageHeight</code>. All of these
 *  parameters are set on the shader when the effect starts playing,
 *  so the parameters need to exist and do something appropriate in
 *  order for the effect to function correctly.</p>
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;s:Wipe&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:Wipe
 *    <b>Properties</b>
 *    id="ID"
 *    direction="right"
 *  /&gt;
 *  </pre>
 *  
 *  @see spark.effects.WipeDirection
 *  @see spark.effects.AnimateTransitionShader
 *  @see spark.effects.AnimateTransitionShader#shaderByteCode
 *  @see spark.effects.supportClasses.WipeInstance
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class Wipe extends AnimateTransitionShader
{
    [Embed(source="Wipe.pbj", mimeType="application/octet-stream")]
    private static var WipeShaderClass:Class;
    private static var wipeShaderCode:ByteArray = new WipeShaderClass();
    
    
    [Inspectable(enumeration="left,right,up,down", defaultValue="right")]
    /**
     *  The direction that the wipe moves during the animation: 
     *  <code>WipeDirection.RIGHT</code>, <code>WipeDirection.LEFT</code>, 
     *  <code>WipeDirection.UP</code>, or <code>WipeDirection.DOWN</code>. 
     *
     *  @default WipeDirection.RIGHT
     *
     *  @see WipeDirection#RIGHT
     *  @see WipeDirection#UP
     *  @see WipeDirection#LEFT
     *  @see WipeDirection#DOWN
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var direction:String = WipeDirection.RIGHT;
    
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
    public function Wipe(target:Object=null)
    {
        super(target);
        instanceClass = WipeInstance;
        shaderByteCode = wipeShaderCode;
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