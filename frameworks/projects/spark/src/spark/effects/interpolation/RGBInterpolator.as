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
package flex.effects.interpolation
{
/**
 * The ColorInterpolator class provides RGB-space interpolation between
 * <code>uint</code> start and end values. Interpolation is done by treating
 * the start and end values as integers with color channel information in
 * the least-significant 3 bytes, interpolating each of those channels
 * separately.
 */
public class ColorInterpolator implements IInterpolator
{   
    private static var theInstance:ColorInterpolator;
    
    public function ColorInterpolator()
    {
        super();
    }
   
    /**
     * Returns the singleton of this class. Since all ColorInterpolators
     * have the same behavior, there is no need for more than one instance.
     */
    public static function getInstance():ColorInterpolator
    {
        if (!theInstance)
            theInstance = new ColorInterpolator();
        return theInstance;
    }
    
    /**
     * Returns the <code>uint</code> type, which is the type of
     * object interpolated by ColorInterpolator
     */
    public function get interpolatedType():Class
    {
        return uint;
    }

    /**
     * @inheritDoc
     * 
     * The interpolation for ColorInterpolator takes the form of parametric
     * calculations on each of the bottom three bytes of 
     * <code>startValue</code> and <code>endValue</code>. This interpolates
     * each color channel separately if the start and end values represent
     * RGB colors.
     */
    public function interpolate(fraction:Number, startValue:*, endValue:*):*
    {
        var startR:int;
        var startG:int;
        var startB:int;
        var endR:int;
        var endG:int;
        var endB:int;
        var deltaR:int;
        var deltaG:int;
        var deltaB:int;
        fraction = Math.min(1, Math.max(0, fraction));
        startR = (uint(startValue) & 0xff0000) >> 16;
        startG = (uint(startValue) & 0xff00) >> 8;
        startB = uint(startValue) & 0xff;
        endR = (uint(endValue) & 0xff0000) >> 16;
        endG = (uint(endValue) & 0xff00) >> 8;
        endB = uint(endValue) & 0xff;
        deltaR = endR - startR;
        deltaG = endG - startG;
        deltaB = endB - startB;
        var newR:uint = startR + deltaR * fraction;
        var newG:uint = startG + deltaG * fraction;
        var newB:uint = startB + deltaB * fraction;
        return newR << 16 | newG << 8 | newB;
    }

}
}