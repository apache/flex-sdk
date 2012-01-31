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
package mx.effects.easing
{
/**
 * Provides easing functionality with three phases during
 * the animation: acceleration, constant motion, and deceleration.
 * As the animation starts it will accelerate through the period
 * specified by the <code>acceleration</code> parameter, it will
 * then use constant (linear) motion through the next phase, and
 * will finally decelerate until the end during the period specified
 * by the <code>deceleration</code> parameter.
 * 
 * <p>The easing values for the three phases will be calculated
 * such that the behavior of constant acceleration, linear motion,
 * and constant deceleration will all occur within the specified 
 * duration of the animation.</p>
 * 
 * <p>Note that the linear motion phase in the middle will not
 * return the same values as a <code>Linear</code> unless both
 * acceleration and deceleration are 0. That phase consists of
 * constant motion, but the speed of that motion is determined by
 * the size of that phase.</p>
 */
public class Constant implements IEaser
{
    private var accelerationChanged:Boolean;
 
    /**
     * Storage for the acceleration property
     */
    private var _acceleration:Number;
    /**
     * The percentage at the beginning of an animation that should be 
     * spent accelerating. Acceleration must be a value from 0 (meaning
     * no acceleration phase) to 1 (meaning the entire animation will
     * be spent accelerating). Additionally, the acceleration and
     * deceleration factors together must not be greater than 1.
     * 
     * @default .2
     */
    public function get acceleration():Number
    {
        return _acceleration;
    }
    public function set acceleration(value:Number):void
    {
        _acceleration = value;
        accelerationChanged = true;
    }
    
    /**
     * Storage for the deceleration property
     */
    private var _deceleration:Number;
    /**
     * The percentage at the end of an animation that should be 
     * spent decelerating. Deceleration must be a value from 0 (meaning
     * no deceleration phase) to 1 (meaning the entire animation will
     * be spent decelerating). Additionally, the acceleration and
     * deceleration factors together must not be greater than 1.
     * 
     * @default .2
     */
    public function get deceleration():Number
    {
        return _deceleration;
    }
    public function set deceleration(value:Number):void
    {
        _deceleration = value;
        accelerationChanged = true;
    }
    
    /**
     * Constructs a Constant instance with optional acceleration and
     * deceleration parameters.
     */
    public function Constant(acceleration:Number = .2, deceleration:Number = .2)
    {
        this.acceleration = acceleration;
        this.deceleration = deceleration;
    }
    
    /**
     * @private
     * 
     * Separate step from setting acceleration/deceleration, to ensure that
     * once they have both been set, they both adhere to the (a+d <= 1) rule.
     */
    private function commitAcceleration():void
    {
        accelerationChanged = false;
        if (_acceleration + _deceleration > 1)
        {
            var sum:Number = _acceleration + _deceleration;
            _acceleration /= sum;
            _deceleration /= sum;
            throw new Error("(acceleration + deceleration) must be within range [0,1]");
        }
    }
    
    /**
     * @inheritDoc
     * 
     * Calculates the eased fraction value based on the
     * acceleration and deceleration factors. If <code>fraction</code>
     * is less than <code>acceleration</code>, it calculates a value
     * based on accelerating up to the constant phase. If <code>fraction</code>
     * is greater than <code>acceleration</code> and less than 
     * <code>(1-deceleration)</code>, it calculates a value based
     * on linear motion between the acceleration and deceleration phases.
     * Otherwise, it calculates a value based on constant deceleration
     * between the constant motion phase and zero.
     * 
     * @param fraction The elapsed fraction of the animation
     * @return The eased fraction of the animation
     */
    public function ease(fraction:Number):Number
    {
        if (accelerationChanged)
            commitAcceleration();
        
        var runRate:Number = 1 / (1 - acceleration/2 - deceleration/2);
        if (fraction < acceleration)
            return fraction * runRate * (fraction / acceleration) / 2;
        if (fraction > (1 - deceleration))
        {
            var decTime:Number = fraction - (1 - deceleration);
            var decProportion:Number = decTime / deceleration;
            return runRate * (1 - acceleration/2 - deceleration +
                decTime * (2 - decProportion) / 2);
        }
        return runRate * (fraction - acceleration/2);
    }
    
}
}