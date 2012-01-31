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
package spark.effects.supportClasses
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

import spark.effects.AnimateShaderTransition;
import spark.effects.SimpleMotionPath;
import spark.effects.animation.Animation;
    
/**
 *  The AnimateShaderTransitionInstance class implements the instance class for the
 *  AnimateShaderTransition effect. Flex creates an instance of this class when
 *  it plays a AnimateShaderTransition effect; you do not create one yourself.
 *
 *  @see spark.effects.AnimateShaderTransition
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class AnimateShaderTransitionInstance extends AnimateInstance
{
    include "../../core/Version.as";

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
    public function AnimateShaderTransitionInstance(target:Object)
    {
        super(target);
        // Automatically keep disappearing targets around during this effect
        autoRemoveTarget = true;
    }

    /**
     *  @copy spark.effects.AnimateShaderTransition#bitmapFrom
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var bitmapFrom:BitmapData;
    
    /**
     *  @copy spark.effects.AnimateShaderTransition#bitmapTo
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var bitmapTo:BitmapData;

    /**
     *  @copy spark.effects.AnimateShaderTransition#shaderCode
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var shaderCode:ByteArray;
    
    /**
     *  @copy spark.effects.AnimateShaderTransition#shaderProperties
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var shaderProperties:Object;

    /**
     * The Shader that is created using the <code>shaderCode</code>
     * property as the underlying byte code. Each instance needs its
     * own separate Shader, but can share the byte code. When each instance
     * is played, create the Shader that the instance uses.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
                (propertyChanges.start["visible"] == false ||
                 propertyChanges.start["parent"] == null))
                if (bitmapTo)                    
                    bitmapFrom = new BitmapData(bitmapTo.width, bitmapTo.height, true, 0);
                else
                    bitmapFrom = new BitmapData(1, 1, true, 0);
        if (!bitmapTo)
            if (propertyChanges &&
                (propertyChanges.end["visible"] == false ||
                 propertyChanges.end["parent"] == null))
                if (bitmapFrom)                    
                    bitmapTo = new BitmapData(bitmapFrom.width, bitmapFrom.height, true, 0);
                else
                    bitmapTo = new BitmapData(1, 1, true, 0);
        
        // Last-ditch effort - if we don't have bitmaps yet, then just grab a 
        // snapshot of the current target
        if (!bitmapFrom)
            bitmapFrom = AnimateShaderTransition.getSnapshot(target);
        if (!bitmapTo)
            bitmapTo = AnimateShaderTransition.getSnapshot(target);

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
            
            motionPaths = [
                new SimpleMotionPath("progress", 0, 1, duration)
            ];
            // auto-set width/height if exposed in shader
            if ("width" in shader.data)
                shader.data.width.value = [bitmapFrom.width];
            if ("height" in shader.data)
                shader.data.height.value = [bitmapFrom.height];
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
        }
            
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
        shader.data.progress.value = [value];
        target.filters = [shaderFilter];
    }

    /**
     * @private
     */
    override public function animationStart(animation:Animation):void
    {
        super.animationStart(animation);
        // Note that we don't want the old filters active on the target
        // during the animation; these filters will already be accounted
        // for when we take a bitmap snapshot of the object. Applying
        // the same filters during the animation will effectively double
        // their impact. So we simply record what the filters are, so that
        // we can replace them when we're done, and then use only our
        // shader filter during the animation.
        oldFilters  = target.filters;
    }    
    /**
     * @private
     */
    override public function animationEnd(animation:Animation):void
    {
        target.filters = oldFilters;
        oldFilters = null;
        super.animationEnd(animation);
    }

    /**
     * Unlike Animate's getValue we return the value of the property requested
     * from the filter associated with our effect instance rather than 
     * the effect target.
     *  
     * @private
     */
    override protected function getCurrentValue(property:String):*
    {
        return shader[property];
    }

    /**
     * Override FXAnimate's setupStyleMapEntry to avoid the need to 
     * validate our properties against the 'target' (since we actually
     * set properties on our associated filter instance).
     *  
     * @private
     */
    override protected function setupStyleMapEntry(property:String):void
    {
    }
}
}