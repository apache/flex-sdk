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
 * The Interpolator interface is used by classes that calculate
 * intermediate values for the Animation class. The Animation class
 * can handle parametric interpolation between Number values and
 * arrays of Number values, but it cannot handle different types
 * of interpolation, or interpolation between different types of
 * values. Implementors of this interface can provide arbitrary
 * interpolation capabilities so that Animations can be created between
 * arbitrary values.
 */
public interface IInterpolator
{
    /**
     * Returns the type that an implementor can handle
     */
    function get interpolatedType():Class;
    
    /**
     * Given an elapsed fraction of an animation between 0 and 1,
     * and start and end values, this function returns some value
     * based on whatever interpolation the implementor chooses to
     * provide.
     */
    function interpolate(fraction:Number,
        startValue:*, endValue:*):*;   
}
}