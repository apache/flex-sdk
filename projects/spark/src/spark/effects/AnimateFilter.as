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

import mx.effects.fxEasing.IEaser;
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
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private static var AFFECTED_PROPERTIES:Array = [ "filters" ];
    
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
     * By default, the affected properties are the same as those specified
     * in the <code>propertyValuesList</code> array. If subclasses affect
     * or track a different set of properties, they should override this
     * method.
     */ 
    override public function getAffectedProperties():Array /* of String */
    {
        return AFFECTED_PROPERTIES;
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