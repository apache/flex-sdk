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
import mx.effects.PropertyValuesHolder;
import mx.effects.interpolation.ColorInterpolator;

import mx.styles.StyleManager;

/**
 * The instance of the Tint effect, which animates a change in
 * color by interpolating the from/to values per color channel
 */
public class FxAnimateColorInstance extends FxAnimateInstance
{
    /**
     * copy mx.effects.Tint#colorFrom
     */
    public var colorFrom:uint;

    /**
     * copy mx.effects.Tint#colorTo
     */
    public var colorTo:uint;

    /**
     * copy mx.effects.Tint#colorPropertyName
     */
    public var colorPropertyName:String;

    public function FxAnimateColorInstance(target:Object)
    {
        super(target);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function play():void
    {
        // The user may have supplied some combination of xFrom, xTo, and xBy.
        // If either xFrom or xTo is not explicitly defined, calculate its
        // value based on the other two values.
        if (colorFrom == StyleManager.NOT_A_COLOR)
        {
            if (propertyChanges && propertyChanges.start[colorPropertyName] !== undefined)
                colorFrom = propertyChanges.start[colorPropertyName];
            else
                colorFrom = getCurrentValue(colorPropertyName);
        }
        if (colorTo == StyleManager.NOT_A_COLOR)
        {
            if (propertyChanges &&
                propertyChanges.end[colorPropertyName] !== undefined)
            {
                colorTo = propertyChanges.end[colorPropertyName];
            }
            else
            {
                colorTo = getCurrentValue(colorPropertyName);
            }
        }
        
        propertyValuesList = 
            [new PropertyValuesHolder(colorPropertyName, [colorFrom, colorTo])];
        interpolator = ColorInterpolator.getInstance();
                
        super.play();        
    }
}
}