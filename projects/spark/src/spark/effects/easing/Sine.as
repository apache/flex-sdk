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
package flex.effects.easing
{
/**
 * Provides easing functionality using a Sine wave, where the
 * instance is created with a <code>power</code> paramter describing the 
 * behavior of the expression.
 */
public class Sine implements IEaser
{
    /**
     * Storage for the easeIn property
     */
    private var _easeIn:Number;
    /**
     * The percentage of an animation that should be spent accelerating.
     * This factor sets an implicit
     * "easeOut" parameter, equal to (1 - easeIn), so that any time not
     * spent easing in is spent easing out. For example, to have an easing
     * equation that spends half the time easing in and half easing out,
     * set easeIn equal to .5.
     * 
     * @default .5
     */
    public function get easeIn():Number
    {
        return _easeIn;
    }
    public function set easeIn(value:Number):void
    {
        _easeIn = value;
    }
    
    /**
     * Constructs a Sine instance with an optional <code>easeIn</code>
     * parameter.
     */
    public function Sine(easeIn:Number = .5)
    {
        this.easeIn = easeIn;
    }

    /**
     * Performs an easing on the elapsed fraction of an animation
     * using a sine curve calculation.
     * 
     * @param fraction The elapsed fraction of the animation
     * @return The eased fraction of the animation
     */
    public function ease(fraction:Number):Number
    {
        var easeOut:Number = 1 - easeIn;
        
        if (fraction <= easeIn)
            return (1 - Math.cos((fraction/easeIn) * Math.PI/2)) * easeIn;
        else
            return easeIn + Math.sin(((fraction - easeIn)/easeOut) * Math.PI/2) * easeOut;
    }
    
}
}