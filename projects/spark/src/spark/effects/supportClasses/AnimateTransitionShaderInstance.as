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
package mx.effects.effectClasses
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shader;
import flash.display.ShaderJob;
import flash.events.ShaderEvent;
import flash.filters.ShaderFilter;
import flash.utils.ByteArray;

import mx.containers.Panel;
import mx.core.Application;
import mx.core.UIComponent;
import mx.effects.PropertyValuesHolder;
import mx.events.AnimationEvent;
    
public class FxAnimateShaderTransitionInstance extends FxAnimateInstance
{
    include "../../core/Version.as";

    public function FxAnimateShaderTransitionInstance(target:Object)
    {
        super(target);
        // Automatically keep disappearing targets around during this effect
        autoRemoveTarget = true;
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
     * for running the transition between the two bitmaps. 
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
    public var shaderCode:ByteArray;
    
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
     *   shaderEffect.shaderProperties = {direction:1};</listing>
     */
    public var shaderProperties:Object;

    /**
     * The Shader that is created using the <code>shaderCode</code>
     * property as the underlying bytecode. Each instance needs its
     * own separate Shader, but can share the bytecode. When each instance
     * is played, we create the Shader that the instance will use.
     */
    protected var shader:Shader;    


    /**
     * @private
     * Cache the filters set on the target when the effect begins.
     * We will assign our own filters during the effect, so we should
     * restore the old filters when we're done
     */
    private var oldFilters:Array;
        
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     * The filter wrapped around the instance's <code>shader</code>
     * property. This filter is assigned to the <code>filters</code>
     * property of the target object with every update during the animation,
     * so that animated updates to the underlying shader are reflected
     * in the filter applied to the display object that the user sees.
     */
    protected var shaderFilter:ShaderFilter;
    
    /**
     *  @private
     */
    override public function play():void
    {
        // TODO (chaase): Should take the 'from' snapshot on the
        // fly, in case the object has changed since the overall
        // effect (composite, etc) started much earlier and the
        // object has changed since propertyChanges was initialized 
        if (!bitmapFrom)
            if (propertyChanges &&
                propertyChanges.start["bitmap"] !== undefined)
            {
                bitmapFrom = propertyChanges.start["bitmap"];
            }
        if (!bitmapTo)
            if (propertyChanges &&
                propertyChanges.end["bitmap"] !== undefined)
            {
                bitmapTo = propertyChanges.end["bitmap"];
            }
        if (!bitmapFrom)
            if (propertyChanges &&
                (propertyChanges.start["visible"] == false) ||
                (propertyChanges.start["parent"] == null))
                if (bitmapTo)                    
                    bitmapFrom = new BitmapData(bitmapTo.width, bitmapTo.height, true, 0);
                else
                    bitmapFrom = new BitmapData(1, 1, true, 0);
        if (!bitmapTo)
            if (propertyChanges &&
                (propertyChanges.end["visible"] == false) ||
                (propertyChanges.end["parent"] == null))
                if (bitmapFrom)                    
                    bitmapTo = new BitmapData(bitmapFrom.width, bitmapFrom.height, true, 0);
                else
                    bitmapTo = new BitmapData(1, 1, true, 0);
        
        // Fix up the visibility if it's becoming visible
        if (propertyChanges &&
            !propertyChanges.start["visible"] &&
            propertyChanges.end["visible"])
        {
            target.visible = true;
        }
        shader = new Shader(shaderCode);
        if (shader.data)
        {
            shader.data.from.input = bitmapFrom;
            shader.data.to.input = bitmapTo;
            
            propertyValuesList = [
                new PropertyValuesHolder("progress", [0,1])
            ];
        }
        // auto-set width/height if exposed in shader
        if ("width" in shader.data)
            shader.data.width.value = [target.width];
        if ("height" in shader.data)
            shader.data.height.value = [target.height];
            
        if (shaderProperties)
        {
            for (var prop:String in shaderProperties)
            {
                var value:Object = shaderProperties[prop];
                shader.data[prop].value = (value is Array) ?
                    value :
                    [value];
            }
        }
        shaderFilter = new ShaderFilter(shader);
        super.play();
    }    
    
    /**
     * Unlike Animate's setValue we assign the new value to the filter
     * associated with our effect instance rather than the target of 
     * the effect. 
     *  
     * @private
     */
    override protected function setValue(property:String, value:Object):void
    {
        if (roundValues && (value is Number))
            value = Math.round(Number(value));
            
        shader.data.progress.value = [value];
        target.filters = [shaderFilter];
    }

    override protected function startHandler(event:AnimationEvent):void
    {
        // Note that we don't want the old filters active on the target
        // during the animation; these filters will already be accounted
        // for when we take a bitmap snapshot of the object. Applying
        // the same filters during the animation will effectively double
        // their impact. So we simply record what the filters are, so that
        // we can replace them when we're done, and then use only our
        // shader filter during the animation.
        oldFilters  = target.filters;
        
    }    
    override protected function endHandler(event:AnimationEvent):void
    {
        target.filters = oldFilters;
        oldFilters = null;
        super.endHandler(event);
    }

    /**
     * Unlike FxAnimate's getValue we return the value of the property requested
     * from the filter associated with our effect instance rather than 
     * the effect target.
     *  
     * @private
     */
    override protected function getCurrentValue(property:String):*
    {
        return shader[property];
    }
}
}