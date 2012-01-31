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
import mx.effects.AnimationProperty;
import mx.effects.interpolation.RGBInterpolator;
import mx.styles.StyleManager;

/**
 * The instance of the FxAnimateColor effect, which animates a change in
 * color by interpolating the from/to values per color channel
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class FxAnimateColorInstance extends FxAnimateInstance
{
    /**
     * copy mx.effects.FxAnimateColor#colorFrom
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var colorFrom:uint;

    /**
     * copy mx.effects.FxAnimateColor#colorTo
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var colorTo:uint;

    /**
     * copy mx.effects.FxAnimateColor#colorPropertyName
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        
        animationProperties = 
            [ new AnimationProperty(colorPropertyName, colorFrom, colorTo) ];
            
        if (!interpolator)
            interpolator = RGBInterpolator.getInstance();
                
        super.play();        
    }
}
}