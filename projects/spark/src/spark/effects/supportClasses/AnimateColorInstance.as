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
package flex.effects.effectClasses
{
import flex.effects.PropertyValuesHolder;
import flex.effects.interpolation.ColorInterpolator;

/**
 * The instance of the Tint effect, which animates a change in
 * color by interpolating the from/to values per color channel
 */
public class TintInstance extends AnimateInstance
{
    /**
     * copy flex.effects.Tint#colorFrom
     */
    public var colorFrom:uint;

    /**
     * copy flex.effects.Tint#colorTo
     */
    public var colorTo:uint;

    /**
     * copy flex.effects.Tint#colorPropertyName
     */
    public var colorPropertyName:String;

    public function TintInstance(target:Object)
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
        if (isNaN(colorFrom))
        {
            if (propertyChanges && propertyChanges.start[colorPropertyName] !== undefined)
                colorFrom = propertyChanges.start[colorPropertyName];
            else
                colorFrom = getCurrentValue(colorPropertyName);
        }
        if (isNaN(colorTo))
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