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
 * The IInterpolator interface is used by classes that calculate
 * values for the Animation class. The Animation class
 * can handle parametric interpolation between Number values and
 * arrays of Number values, but it cannot handle different types
 * of interpolation, or interpolation between different types of
 * values. Implementors of this interface can provide arbitrary
 * interpolation capabilities so that Animations can be created between
 * arbitrary values.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public interface IInterpolator
{
    /**
     * Returns the type that an implementor can handle
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get interpolatedType():Class;
    
    /**
     * Given an elapsed fraction of an animation between 0 and 1,
     * and start and end values, this function returns some value
     * based on whatever interpolation the implementor chooses to
     * provide.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function interpolate(fraction:Number,
        startValue:Object, endValue:Object):Object;   

    /**
     * Given a base value and a value to add to it, this function
     * returns the result of that increment operation. For example,
     * if the objects are simple Numbers, the result would be
     * <code>Number(baseValue) + Number(incrementValue)</code>.
     * This function is called by the animation system when it
     * needs to dynamically calculate a value given some starting
     * value and a 'by' value that should be added to it, both of
     * which are of type Object and cannot simply be added together.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function increment(baseValue:Object, incrementValue:Object):Object;

    /**
     * Given a base value and a value to subtract from it, this function
     * returns the result of that decrement operation. For example,
     * if the objects are simple Numbers, the result would be
     * <code>Number(baseValue) - Number(incrementValue)</code>.
     * This function is called by the animation system when it
     * needs to dynamically calculate a value given some ending
     * value and a 'by' value that should be subtracted from it, both of
     * which are of type Object and cannot simply be subtracted.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function decrement(baseValue:Object, decrementValue:Object):Object;
}
}