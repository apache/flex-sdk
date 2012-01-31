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

import mx.effects.interpolation.IEaser;
import mx.effects.effectClasses.FxAnimateFilterInstance;

import mx.core.mx_internal;
import mx.effects.Effect;
import mx.effects.IEffectInstance;
import mx.events.EffectEvent;
import mx.filters.IBitmapFilter;
import mx.styles.IStyleClient;

use namespace mx_internal;

/**
 * This effect applies an IBitmapFilter instance and allows you to animate
 * an arbitrary set of properties of the filter between values, as specified
 * by the propertyValuesList. 
 * 
 * Example usage is as follows:
 * 
 * @example Using the AnimateFilter effect to animate a hypothetical FishEye
 * shader's radius from 0 to 50.
 * 
 * <listing version="3.0">
 * var button:Button = new Button();
 * var shader:ShaderFilter = new ShaderFilter(new FishEyeLens());
 * var anim:AnimateFilter = new AnimateFilter(button, shader);
 * anim.propertyValuesList = [new PropertyValuesHolder("radius", [0,50])];
 * anim.play();
 * </listing>
 */
public class FxAnimateFilter extends FxAnimate
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     */
    public function FxAnimateFilter(target:Object = null, filter:IBitmapFilter = null)
    {
        super(target);
        instanceClass = FxAnimateFilterInstance;
        this.bitmapFilter = filter;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  bitmapFilter
    //----------------------------------
    
    /**
     *  IBitmapFilter instance to apply and animate.
     */
    public var bitmapFilter:IBitmapFilter;
    
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */ 
    override public function getAffectedProperties():Array /* of String */
    {
        return [];
    }
    
    
    /**
     *  @private
     */
    override protected function initInstance(instance:IEffectInstance):void
    {
        super.initInstance(instance);
        var animateInstance:FxAnimateFilterInstance = instance as FxAnimateFilterInstance;
        animateInstance.bitmapFilter = bitmapFilter;
    }
}
}