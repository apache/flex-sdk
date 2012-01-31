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
 * Provides easing functionality using a Sine function and a
 * parameter that specifies how much time to spend easing in
 * and out.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class Sine extends EaseInOut
{    
    /**
     * Constructs a Sine instance with an optional 
     * <code>easeInFraction</code> parameter.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function Sine(easeInFraction:Number = .5)
    {
        super(easeInFraction);
    }

    /**
     * @inheritDoc
     * 
     * The easeIn calculation for Sine is equal to 
     * <code>1 - cos(fraction*PI/2)</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function easeIn(fraction:Number):Number
    {
        return 1 - Math.cos(fraction * Math.PI/2);
    }
    
    /**
     * @inheritDoc
     * 
     * The easeOut calculation for Sine is equal to 
     * <code>sin(fraction*PI/2)</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function easeOut(fraction:Number):Number
    {
        return Math.sin(fraction * Math.PI/2);
    }    
}
}