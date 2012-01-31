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
package mx.effects.interpolation
{
/**
 * ArrayInterpolator interpolates each element of start/end array
 * inputs separately, using another internal interpolator to do
 * the per-element interpolation. By default, the per-element
 * interpolation uses <code>NumberInterpolator</code>, but callers
 * can construct ArrayInterpolator with a different interpolator
 * instead.
 */
public class ArrayInterpolator implements IInterpolator
{
    
    /**
     * Constructor. An optional parameter provides a per-element
     * interpolator that will be used for every element of the arrays.
     * If no interpolator is supplied, <code>NumberInterpolator</code>
     * will be used by default.
     */
    public function ArrayInterpolator(value:IInterpolator = null)
    {
        elementInterpolator = value;
    }

    // The internal per-element interpolator
    private var _elementInterpolator:IInterpolator;
    /**
     * The internal interpolator that ArrayInterpolator uses for
     * each element of the input arrays
     */
    public function get elementInterpolator():IInterpolator
    {
        return _elementInterpolator;
    }
    public function set elementInterpolator(value:IInterpolator):void
    {
        _elementInterpolator = value ? 
            value : (NumberInterpolator.getInstance());
    }

    /**
     * Returns the <code>Array</code> type, which is the type of
     * object interpolated by ArrayInterpolator
     */
    public function get interpolatedType():Class
    {
        return Array;
    }

    /**
     * @inheritDoc
     * 
     * Interpolation for ArrayInterpolator consists of running a separate
     * interpolation on each element of the startValue and endValue
     * arrays, returning a new Array that holds those interpolated values.
     */
    public function interpolate(fraction:Number, startValue:*, endValue:*):*
    {
        if (startValue.length != endValue.length)
            throw new Error("Start/end arrays must be of equal length");
        var returnArray:Array = [];
        for (var i:int = 0; i < startValue.length; i++)
            returnArray[i] = _elementInterpolator.interpolate(fraction, 
                startValue[i], endValue[i]);

        return returnArray;
    }
    
}
}