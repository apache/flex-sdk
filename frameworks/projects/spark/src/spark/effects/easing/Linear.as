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
 * Provides easing functionality with three phases during
 * the animation: acceleration, uniform motion, and deceleration.
 * As the animation starts it will accelerate through the period
 * specified by the <code>acceleration</code> parameter, it will
 * then use uniform (linear) motion through the next phase, and
 * will finally decelerate until the end during the period specified
 * by the <code>deceleration</code> parameter.
 * 
 * <p>The easing values for the three phases will be calculated
 * such that the behavior of constant acceleration, linear motion,
 * and constant deceleration will all occur within the specified 
 * duration of the animation.</p>
 * 
 * <p>Strict linear motion can be achieved by setting both
 * acceleration and deceleration to 0. Note that if acceleration or
 * deceleration are not zero, then the motion during the middle
 * phase will not be at the same speed as that of pure
 * linear motion. The middle phase consists of
 * uniform motion, but the speed of that motion is determined by
 * the size of that phase relative to the overall curve.</p>
 */
public class Linear implements IEaser
{
    /**
     * Constructs a Linear instance with optional acceleration and
     * deceleration parameters.
     */
    public function Linear(easeInFraction:Number = 0, easeOutFraction:Number = 0)
    {
        this.easeInFraction = easeInFraction;
        this.easeOutFraction = easeOutFraction;
    }
    
    private static var instance:Linear;
    
    /**
     * Returns the singleton instance of Linear.
     */
    public static function getInstance():Linear
    {
        if (!instance)
            instance = new Linear();

        return instance;
    }

    /**
     * Storage for the _easeInFraction property
     */
    private var _easeInFraction:Number = 0;
    
    /**
     * The percentage an animation will spend accelerating.
     * easeOutFraction and easeInFraction must satisfy the
     * equation <code>easeOutFraction + easeInFraction &lt;= 1</code>
     * where any remaining time in the middle will be spent in 
     * linear interpolation.
     * 
     * @default 0
     */
    public function get easeInFraction():Number
    {
        return _easeInFraction;
    }
    public function set easeInFraction(value:Number):void
    {
        _easeInFraction = value;
    }

    /**
     * Storage for the _easeInFraction property
     */
    private var _easeOutFraction:Number = 0;
    
    /**
     * The percentage an animation will spend decelerating.
     * easeOutFraction and easeInFraction must satisfy the
     * equation <code>easeOutFraction + easeInFraction &lt;= 1</code>
     * where any remaining time in the middle will be spent in 
     * linear interpolation.
     * 
     * @default 0
     */
    public function get easeOutFraction():Number
    {
        return _easeOutFraction;
    }
    public function set easeOutFraction(value:Number):void
    {
        _easeOutFraction = value;
    }


    /**
     * @inheritDoc
     * 
     * Calculates the eased fraction value based on the
     * <code>easeInFraction</code> and <code>easeOutFraction</code> 
     * factors. If <code>fraction</code>
     * is less than <code>easeInFraction</code>, it calculates a value
     * based on accelerating up to the linear phase. If <code>fraction</code>
     * is greater than <code>easeInFraction</code> and less than 
     * <code>(1-easeOutFraction)</code>, it calculates a value based
     * on linear motion between the easing-in and easing-out phases.
     * Otherwise, it calculates a value based on constant deceleration
     * between the linear motion phase and zero.
     * 
     * @param fraction The elapsed fraction of the animation
     * @return The eased fraction of the animation
     */
    public function ease(fraction:Number):Number
    {
        // Handle the trivial case where no easing is requested
        if (easeInFraction == 0 && easeOutFraction == 0)
            return fraction;
            
        var runRate:Number = 1 / (1 - easeInFraction/2 - easeOutFraction/2);
        if (fraction < easeInFraction)
            return fraction * runRate * (fraction / easeInFraction) / 2;
        if (fraction > (1 - easeOutFraction))
        {
            var decTime:Number = fraction - (1 - easeOutFraction);
            var decProportion:Number = decTime / easeOutFraction;
            return runRate * (1 - easeInFraction/2 - easeOutFraction +
                decTime * (2 - decProportion) / 2);
        }
        return runRate * (fraction - easeInFraction/2);
    }
}
}