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

package spark.effects.interpolation
{
import mx.styles.StyleManager;
import mx.utils.HSBColor;

/**
 * The HSBInterpolator class provides HSB-space interpolation between
 * RGB <code>uint</code> start and end values. Interpolation is done by treating
 * the start and end values as integers with color channel information in
 * the least-significant 3 bytes, converting these to HSB values, and
 * interpolating linearly for each of the h (hue), s (saturation),
 * and b (brightness) parameters.
 * 
 * <p>Because this interpolator may perform more calculations than a
 * typical interpolator that is simply interpolating a given type,
 * specifically to convert the RGB start and end values, this
 * interpolator provides the option of supplying start/end values
 * to the constructor. If start/end RGB values are provided, then
 * the conversions of these values is calculated once, up front,
 * and need not be done at every future call to the interpolate()
 * method during the animation.</p>
 * 
 * @see mx.utils.HSBColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class HSBInterpolator implements IInterpolator
{   
    private static var theInstance:HSBInterpolator;
    private var startHSB:HSBColor;
    private var endHSB:HSBColor;
    
    /**
     * Constructs an HSBInterpolator instance. Optional parameters for
     * start and end RGB values help optimize runtime performance by
     * performing RGB-HSB conversions at construction time, instead of
     * dynamically with every call to interpolate()
     * 
     * @param startRGB the starting color, as an unsigned integer RGB value
     * @param endRGB the ending color, as an unsigned integer RGB value
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function HSBInterpolator(startRGB:uint = StyleManager.NOT_A_COLOR, 
        endRGB:uint = StyleManager.NOT_A_COLOR)
    {
        super();
        if (startRGB != StyleManager.NOT_A_COLOR)
            startHSB = HSBColor.RGBtoHSB(startRGB);
        if (endRGB != StyleManager.NOT_A_COLOR)
            endHSB = HSBColor.RGBtoHSB(endRGB);
    }
   
    /**
     * Returns the singleton of this class. Note that the singleton
     * of HSBInterpolator may be less useful than separate instances
     * of the class, since separate instances can take advantage of
     * pre-calculating the RGB-HSB conversions for the start/end colors.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static function getInstance():HSBInterpolator
    {
        if (!theInstance)
            theInstance = new HSBInterpolator();
        return theInstance;
    }
    
    /**
     * Returns the <code>uint</code> type, which is the type of
     * object interpolated by ColorInterpolator
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get interpolatedType():Class
    {
        return uint;
    }

    /**
     * @inheritDoc
     * 
     * The interpolation for HSBInterpolator takes the form of parametric
     * calculations on each of the three values h (hue), s (saturation),
     * and b (brightness) of HSB colors derived from the start and end colors
     * specified in RGB space.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function interpolate(fraction:Number, startValue:Object, 
        endValue:Object):Object
    {
        var start:HSBColor = startHSB;
        var end:HSBColor = endHSB;
        // If we have not converted start/end values at construction time, 
        // do so now
        if (!start)
            start = HSBColor.RGBtoHSB(uint(startValue));
        if (!end)
            end = HSBColor.RGBtoHSB(uint(endValue));
        var startH:Number = start.hue;
        var endH:Number = end.hue;
        var deltaH:Number;
        var deltaS:Number = end.saturation - start.saturation;
        var deltaB:Number = end.brightness - start.brightness;
        if (isNaN(startH) || isNaN(endH))
            deltaH = 0;
        else
        {
            deltaH = endH - startH;
            if (Math.abs(deltaH) > 180)
            {
                if (startH < endH)
                    startH += 360;
                else
                    endH += 360;
                deltaH = endH - startH;
            }
        }
        var saturation:Number = start.saturation +
            deltaS * fraction;
        var brightness:Number = start.brightness +
            deltaB * fraction;
        var hue:Number;
        if (isNaN(startH))
            hue = endH;
        else if (isNaN(endH))
            hue = startH;
        else
            hue = startH + deltaH * fraction;
        var rgb:uint = HSBColor.HSBtoRGB(hue, saturation, brightness);
        return rgb;
    }

    /**
     * @private
     * 
     * Utility function called by increment() and decrement()
     */
    private function combine(baseValue:uint, deltaValue:uint,
        increment:Boolean):Object
    {
        var start:HSBColor = HSBColor.RGBtoHSB(baseValue);
        var delta:HSBColor = HSBColor.RGBtoHSB(deltaValue);
        var newH:Number, newS:Number, newB:Number;
        if (increment)
        {
            newH = (start.hue + delta.hue) % 360;
            newS = Math.min(start.saturation + delta.saturation, 1);
            newB = Math.min(start.brightness + delta.brightness, 1);
        }
        else
        {
            newH = (start.hue + delta.hue) % 360;
            newS = Math.max(start.saturation - delta.saturation, 0);
            newB = Math.max(start.brightness - delta.brightness, 0);
        }
        return HSBColor.HSBtoRGB(newH, newS, newB);
    }

    /**
     * @inheritDoc
     * 
     * <p>This function returns the result of the two RGB values added
     * together in HSB space. Each value will be converted to HSB space
     * first and then each component (hue, saturation, and brightness)
     * will be treated individually. The saturation and brightness
     * components will be clamped to lie within [0-1] and the hue degrees
     * will be modulated by 360 to li within [0,360).</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function increment(baseValue:Object, incrementValue:Object):Object
    {
        return combine(uint(baseValue), uint(incrementValue), true);
    }

    /**
     * @inheritDoc
     * 
     * <p>This function returns the result of the two RGB values added
     * together in HSB space. Each value will be converted to HSB space
     * first and then each component (hue, saturation, and brightness)
     * will be treated individually. The saturation and brightness
     * components will be clamped to lie within [0-1] and the hue degrees
     * will be modulated by 360 to lie within [0,360).</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
   public function decrement(baseValue:Object, decrementValue:Object):Object
   {
        return combine(uint(baseValue), uint(decrementValue), false);
   }

}
}