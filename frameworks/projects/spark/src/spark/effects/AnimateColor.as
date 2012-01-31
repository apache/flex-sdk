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
package flex.effects
{
import flex.effects.effectClasses.TintInstance;

import mx.effects.IEffectInstance;

/**
 * This effect animates a change in color over time, interpolating
 * between given from/to color values on a per-channel basis.
 */
public class Tint extends Animate
{
    /**
     * The starting color
     */
    public var colorFrom:uint;
    
    /**
     * The ending color
     */
    public var colorTo:uint;
    
    /**
     * The name of the color property on the target object affected
     * by this animation.
     * 
     * @default "color"
     */
    public var colorPropertyName:String = "color";
    
    /**
     * Constructs a Tint effect with an optional target object
     */
    public function Tint(target:Object=null)
    {
        super(target);
        instanceClass = TintInstance;
    }

    /**
     * @inheritDoc
     */
    override protected function initInstance(instance:IEffectInstance):void
    {
        super.initInstance(instance);
        
        var tintInstance:TintInstance = TintInstance(instance);
        tintInstance.colorFrom = colorFrom;
        tintInstance.colorTo = colorTo;
        tintInstance.colorPropertyName = colorPropertyName;
    }
}
}