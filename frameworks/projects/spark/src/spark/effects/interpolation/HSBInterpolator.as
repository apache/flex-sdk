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
 *  The HSBInterpolator class provides Hue, Saturation, and Brightness (HSB) 
 *  color interpolation between RGB <code>uint</code> start and end values. 
 *  Interpolation is done by treating
 *  the start and end values as integers with RGB color channel information in
 *  the least-significant 3 bytes, converting these to HSB values, and
 *  interpolating linearly for each of the h (hue), s (saturation),
 *  and b (brightness) parameters.
 * 
 *  <p>Because this interpolator may perform more calculations than a
 *  typical interpolator that is simply interpolating a given type,
 *  specifically to convert the RGB start and end values, this
 *  interpolator provides the option of supplying start and end values
 *  to the constructor. If you specify the start and end RGB values, then
 *  the conversions of these values is calculated once, 
 *  and does not need to be done at every future call to 
 *  the <code>interpolate()</code> method during the animation.</p>
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
     *  Constructor.
     *
     *  The optional parameters for <code>startRGB</code> and 
     *  <code>endRGB</code> help to optimize runtime performance by
     *  performing RGB to HSB conversions at construction time, instead of
     *  dynamically with every call to the <code>interpolate()</code> method.
     * 
     *  @param startRGB The starting color, as an unsigned integer RGB value.
     *
     *  @param endRGB The ending color, as an unsigned integer RGB value.
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
            startHSB = HSBColor.convertRGBtoHSB(startRGB);
        if (endRGB != StyleManager.NOT_A_COLOR)
            endHSB = HSBColor.convertRGBtoHSB(endRGB);
    }
   
    /**
     *  Returns the singleton of this class. 
     *
     *  <p>Note that the singleton
     *  of the HSBInterpolator class might be less useful than separate instances
     *  of the class because separate instances can take advantage of
     *  precalculating the RGB to HSB conversions for the start and end colors.</p>
     *
     *  @return The singleton of the HSBInterpolator class.
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
     *  The interpolation for the HSBInterpolator class takes the form of parametric
     *  calculations on each of the three values h (hue), s (saturation),
     *  and b (brightness) of HSB colors derived from the start and end RGB colors.
     *
     *  @param fraction The fraction elapsed of the 
     *  animation, between 0.0 and 1.0.
     *
     *  @param startValue The start value of the interpolation.
     *
     *  @param endValue The end value of the interpolation.
     *
     *  @return The interpolated value.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function interpolate(fraction:Number, startValue:Object, 
        endValue:Object):Object
    {
        if (fraction == 0)
            return startValue;
        else if (fraction == 1)
            return endValue;
        var start:HSBColor = startHSB;
        var end:HSBColor = endHSB;
        // If we have not converted start/end values at construction time, 
        // do so now
        if (!start)
            start = HSBColor.convertRGBtoHSB(uint(startValue));
        if (!end)
            end = HSBColor.convertRGBtoHSB(uint(endValue));
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
        var rgb:uint = HSBColor.convertHSBtoRGB(hue, saturation, brightness);
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
        var start:HSBColor = HSBColor.convertRGBtoHSB(baseValue);
        var delta:HSBColor = HSBColor.convertRGBtoHSB(deltaValue);
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
        return HSBColor.convertHSBtoRGB(newH, newS, newB);
    }

    /**
     *  Returns the result of the two RGB values added
     *  together as HSB colors. Each value is converted to an HSB color
     *  first, and then each component (hue, saturation, and brightness)
     *  will be treated individually. 
     *  The saturation and brightness
     *  components are clamped to lie between 0 and 1, and the hue degrees
     *  are modulated by 360 to lie between 0 and 360.
     *
     *  @param baseValue The start value of the interpolation.
     *
     *  @param incrementValue The change to apply to the <code>baseValue</code>.
     *
     *  @return The interpolated value.
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
     *  Returns the result of the two RGB values added
     *  together as HSB colors. Each value is converted to an HSB color
     *  first, and then each component (hue, saturation, and brightness)
     *  is treated individually. 
     *  The saturation and brightness
     *  components are clamped to lie between 0 and 1, and the hue degrees
     *  are modulated by 360 to lie between 0 and 360.
     *
     *  @param baseValue The start value of the interpolation.
     *
     *  @param decrementValue The change to apply to the <code>baseValue</code>.
     *
     *  @return The interpolated value.
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