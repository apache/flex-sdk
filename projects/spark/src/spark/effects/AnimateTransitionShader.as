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
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.IBitmapDrawable;
import flash.display.Shader;
import flash.display.ShaderData;
import flash.display.ShaderInput;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

import mx.effects.effectClasses.FxAnimateShaderTransitionInstance;
import mx.utils.ObjectUtil;

/**
 * This effect animates a transition between two bitmaps,
 * one representing the start state (<code>bitmapFrom</code>), and
 * the other representing the end state (<code>bitmapTo</code>).
 * 
 * <p>The animation is performed by running a Pixel Bender shader,
 * supplied by the <code>shader</code> property,
 * using the two bitmaps as input. If either bitmap is
 * not supplied, that value will be determined dynamically from
 * either the appropriate state of the target in a transition or, 
 * if the effect is not running in a transition, from the 
 * target directly. If
 * the effect is run in a transition and the target object either
 * goes away or comes into existence during that state change,
 * then a fully-transparent bitmap will be used to represent
 * that object when it does not exist.</p>
 */
public class FxAnimateShaderTransition extends FxAnimate
{
    
    public function FxAnimateShaderTransition(target:Object=null)
    {
        super(target);

        instanceClass = FxAnimateShaderTransitionInstance;
    }
    
    /**
     * The bitmap data representing the start state of this effect.
     * If this property is not set, it will be calculated automatically
     * when the effect is played by grabbing a snapshot of the target
     * object, or by using a transparent bitmap if the object does not
     * exist in the start state of a transition.
     */
    public var bitmapFrom:BitmapData;
    
    /**
     * The bitmap data representing the end state of this effect.
     * If this property is not set, it will be calculated automatically
     * when the effect is played by grabbing a snapshot of the target
     * object, or by using a transparent bitmap if the object does not
     * exist in the end state of a transition.
     */
    public var bitmapTo:BitmapData;

    /**
     * The bytecode that a <code>Shader</code> object will use
     * for running the transition between the two bitmaps. This
     * property can be represented as either a ByteArray or as a
     * Class representing a ByteArray (which is what results 
     * when you embed a resource).
     * 
     * <p>The shader can have arbitrary functionality and inputs, but 
     * must, at a minimum, have three <code>image4</code> inputs.
     * The first input, which can be named anything, should go
     * unused by your shader code - it exists only to satisfy the
     * Flash requirement of assigning a filtered object to the
     * first input. Note that inputs that go completely unused in a
     * shader kernel may be optimized out, so your kernel code should
     * at least reference this input to keep it around.</p>
     * 
     * <p>There must be at least two other inputs
     * named <code>from</code> and <code>to</code> and one 
     * <code>float</code> parameter named <code>progress</code>, where
     * <code>from/to</code> are the before/after bitmaps, respectively,
     * and <code>progress</code> is the elapsed fraction of
     * the effect.</p>
     * 
     * <p>Also, there are two optional parameters, <code>width</code>
     * and <code>height</code>, which if they exist in the shader
     * will be automatically set to the width and height for the
     * effect instance target.</p>
     * 
     * <p>See the Pixel Bender Toolkit documentation for more
     * information on writing shaders for Flash.</p>
     * 
     * @example To play an effect that uses a fictional Pixel Bender pbj 
     * file MyShader.pbj, which takes a single <code>direction</code>
     * parameter, the calling code could do this:
     * @example <listing version="3.0">
     *   [Embed(source="MyShader.pbj", mimeType="application/octet-stream")]
     *   private var ShaderCodeClass:Class;
     *   var shaderEffect = new FxAnimateShaderTransition();
     *   shaderEffect.shaderCode = ShaderCodeClass;
     *   shaderEffect.shaderProperties = {direction : 1};</listing>
     * or in MXML code, this:<listing version="3.0">
     *   <FxAnimateShaderTransition 
     *       shaderCode="@Embed(source="MyShader.pbj", mimeType="application/octet-stream")"
     *       shaderProperties="{{direction : 1}}}"/>
     * </listing>
     * 
     * @see flash.display.Shader
     */
    public var shaderCode:Object;
    
    /**
     * A map of parameter name/value pairs that the shader
     * will set its data values to prior to playing. For example,
     * to set a parameter named <code>direction</code> in a
     * shader with a Pixel Bender pbj file in Wipe.pbj, the calling 
     * code could do this:
     * @example <listing version="3.0">
     *   [Embed(source="Wipe.pbj", mimeType="application/octet-stream")]
     *   private var WipeCodeClass:Class;
     *   var shaderEffect = new FxAnimateShaderTransition();
     *   shaderEffect.shaderCode = WipeCodeClass;
     *   shaderEffect.shaderProperties = {direction : 1};</listing>
     */
    public var shaderProperties:Object;
    
    /**
     *  @private
     */
    override public function getAffectedProperties():Array /* of String */
    {
        // We track visible and parent so that we can automatically
        // perform transitions from/to states where the target either
        // does not exist or is not visible
        return ["bitmap", "visible", "parent"];
    }

    override protected function getValueFromTarget(target:Object, property:String):*
    {
        if (property != "bitmap")
            return super.getValueFromTarget(target, property);

        // Return a null bitmap for non-visible targets        
        if (!target.visible || !target.parent)
            return null;

        var bounds:Rectangle = target.getBounds(target);
        var bmData:BitmapData = new BitmapData(bounds.width, bounds.height, true, 0);
        var m:Matrix = new Matrix();
        m.translate(-bounds.x, -bounds.y);
        bmData.draw(IBitmapDrawable(target), m);

        return bmData;
    }

    /**
     *  @private
     */
    override protected function initInstance(instance:IEffectInstance):void
    {
        super.initInstance(instance);
        
        var animateShaderTransitionInstance:FxAnimateShaderTransitionInstance = 
            FxAnimateShaderTransitionInstance(instance);

        animateShaderTransitionInstance.bitmapFrom = bitmapFrom;
        animateShaderTransitionInstance.bitmapTo = bitmapTo;

        // Iterate through the data properties of the original shader, copying
        // each parameter to shaderCopy. Skip the 'input' parameters, as these
        // will be set by the animation and we do not want a reference to the
        // same common objects.
        animateShaderTransitionInstance.shaderCode = 
            (shaderCode is ByteArray) ?
            ByteArray(shaderCode) :
            new shaderCode();
        animateShaderTransitionInstance.shaderProperties = shaderProperties;
    }
}
}