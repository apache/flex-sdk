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
/**
 *  The IInterpolator interface is implemented by classes that calculate
 *  values for the Animation class. The Animation class
 *  can handle parametric interpolation between Number values and
 *  arrays of Number values, but it cannot handle different types
 *  of interpolation, or interpolation between different types of
 *  values. Implementors of this interface can provide arbitrary
 *  interpolation capabilities so that Animations can be created between
 *  arbitrary values.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public interface IInterpolator
{
    /**
     *  Given an elapsed fraction of an animation, between 0.0 and 1.0,
     *  and start and end values to interpolate, return the interpolated value.
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
    function interpolate(fraction:Number,
        startValue:Object, endValue:Object):Object;   

    /**
     *  Given a base value and a value to add to it, 
     *  return the result of that operation. 
     *  For example, if the objects are simple Numbers, the result is a 
     *  <code>Number(baseValue) + Number(incrementValue)</code>.
     *  This method is called by the animation system when it
     *  needs to dynamically calculate a value given some starting
     *  value and a 'by' value that should be added to it. Both of
     *  the arguments are of type Object and cannot simply be added together.
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
    function increment(baseValue:Object, incrementValue:Object):Object;

    /**
     *  Given a base value and a value to subtract from it, 
     *  return the result of that decrement operation. For example,
     *  if the objects are simple Numbers, the result would be
     *  <code>Number(baseValue) - Number(incrementValue)</code>.
     *  This function is called by the animation system when it
     *  needs to dynamically calculate a value given some ending
     *  value and a 'by' value that should be subtracted from it. Both of
     *  the arguments are of type Object and cannot simply be added together.
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
    function decrement(baseValue:Object, decrementValue:Object):Object;
}
}