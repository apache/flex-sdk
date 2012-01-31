////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.effects
{
import flash.geom.Point;
import mx.core.mx_internal;
import spark.effects.animation.Keyframe;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;
import spark.effects.easing.IEaser;
import spark.effects.easing.Power;
import spark.effects.easing.Sine;

use namespace mx_internal;

// TODO (eday): This class is currently intended only for use by Scroller.  It may not
// support all of the functionality of the Effects system.  For example, it does not 
// have an associated AnimatetdInstance-derived class.   


[ExcludeClass]

public class ThrowEffect extends Animate
{
    
    /**
     *  @private
     *  The duration of the overshoot effect when a throw "bounces" against the end of the list.
     */
    private static const THROW_OVERSHOOT_TIME:int = 200;
    
    /**
     *  @private
     *  The duration of the settle effect when a throw "bounces" against the end of the list.
     */
    private static const THROW_SETTLE_TIME:int = 600;
    
    /**
     *  @private
     *  The exponent used in the easer function for the main part of the throw animation.
     *  NOTE: if you change this, you need to re-differentiate the easer
     *  function and use the resulting derivative calculation in createThrowMotionPath. 
     */
    private static const THROW_CURVE_EXPONENT:Number = 3.0;
    
    /**
     *  @private
     *  The exponent used in the easer function for the "overshoot" portion 
     *  of the throw animation.
     */
    private static const OVERSHOOT_CURVE_EXPONENT:Number = 2.0;
    
    /**
     *  @private
     *  The name of the property to be animated for each axis.
     *  Setting to null indicates that there is to be no animation
     *  along that axis. 
     */
    mx_internal var propertyNameX:String = null;
    mx_internal var propertyNameY:String = null;

    /**
     *  @private
     *  The initial velocity of the throw animation.
     */
    mx_internal var startingVelocityX:Number = 0;
    mx_internal var startingVelocityY:Number = 0;

    /**
     *  @private
     *  The starting values for the animated properties.
     */
    mx_internal var startingPositionX:Number = 0;
    mx_internal var startingPositionY:Number = 0;

    /**
     *  @private
     *  The minimum values for the animated properties.
     */
    mx_internal var minPositionX:Number = 0;
    mx_internal var minPositionY:Number = 0;

    /**
     *  @private
     *  The maximum values for the animated properties.
     */
    mx_internal var maxPositionX:Number = 0;
    mx_internal var maxPositionY:Number = 0;

    /**
     *  @private
     *  The rate of deceleration to apply to the velocity.
     */
    mx_internal var decelerationFactor:Number;
    
    /**
     *  @private
     *  The final calculated values for the animated properties.
     */
    mx_internal var finalPosition:Point;
    
    /**
     *  @private
     *  This is a callback that, when installed by the client, will be invoked
     *  with the final position of the throw in case the client needs to alter it
     *  prior to the animation beginning. 
     */
    mx_internal var finalPositionFilterFunction:Function;
    
    /**
     *  @private
     *  Set to true when the effect is only being used to snap an element into position
     *  and the initial velocity is zero.
     */
    mx_internal var isSnapping:Boolean = false;

    /**
     *  @private
     *  The motion paths for X and Y axes
     */
    private var horizontalMP:SimpleMotionPath = null;
    private var verticalMP:SimpleMotionPath = null;
    
    /**
     *  @private
     */
    private function calculateThrowEffectTime(velocityX:Number, velocityY:Number):int
    {
        // This calculates the effect duration based on a deceleration factor that is applied evenly over time.
        // We decay the velocity by the deceleration factor until it is less than 0.01/ms, which is rounded to zero pixels.
        // We want to solve for "time" in this equasion: velocity*(decel^time)-0.01 = 0.
        // Note that we are only calculating an effect duration here.  The actual curve of our throw velocity is determined by 
        // the exponential easing function we use between animation keyframes.
        var throwTimeX:int = velocityX == 0 ? 0 : (Math.log(0.01 / (Math.abs(velocityX)))) / Math.log(decelerationFactor);
        var throwTimeY:int = velocityY == 0 ? 0 : (Math.log(0.01 / (Math.abs(velocityY)))) / Math.log(decelerationFactor);
        
        return Math.max(throwTimeX, throwTimeY);
    }

    /**
     *  @private
     *  Once all the animation variables are set (velocity, position, etc.), call this
     *  function to build the motion paths that describe the throw animation.
     */
    mx_internal function setup():Boolean
    {
        // Set the easer for the overall effect.
        // TODO (eday): eliminate this and fix the curves to compensate.
        var throwEaser:IEaser = new Power(0, THROW_CURVE_EXPONENT);
        this.easer = throwEaser;

        var effectTime:int = calculateThrowEffectTime(startingVelocityX, startingVelocityY);
        var throwEffectMotionPaths:Vector.<MotionPath> = new Vector.<MotionPath>();
        
        isSnapping = false;
        
        var horizontalTime:Number = 0;
        var horizontalFinalPosition:Number = 0;
        horizontalMP = null;
        if (propertyNameX)
        {
            horizontalMP = createThrowMotionPath(
                propertyNameX,
                startingVelocityX,
                startingPositionX,
                minPositionX,
                maxPositionX,
                effectTime);
            
            if (horizontalMP)
            {
                throwEffectMotionPaths.push(horizontalMP);
                horizontalTime = horizontalMP.keyframes[horizontalMP.keyframes.length-1].time;
                horizontalFinalPosition = Number(horizontalMP.keyframes[horizontalMP.keyframes.length-1].value); 
            }
        }

        var verticalTime:Number = 0;
        var verticalFinalPosition:Number = 0;
        verticalMP = null;
        if (propertyNameY)
        {
            verticalMP = createThrowMotionPath(
                propertyNameY,
                startingVelocityY,
                startingPositionY,
                minPositionY,
                maxPositionY,
                effectTime);
            
            if (verticalMP)
            {
                throwEffectMotionPaths.push(verticalMP);
                verticalTime = verticalMP.keyframes[verticalMP.keyframes.length-1].time;
                verticalFinalPosition = Number(verticalMP.keyframes[verticalMP.keyframes.length-1].value);
            }
        }
    
        if (throwEffectMotionPaths.length != 0)
        {
            this.duration = Math.max(horizontalTime, verticalTime);
            this.motionPaths = throwEffectMotionPaths;
            finalPosition = new Point(horizontalFinalPosition, verticalFinalPosition);
            return true;
        }
        return false;
    }
    
    /**
     *  @private
     *  Helper function for getCurrentVelocity.  
     */
    private function getMotionPathCurrentVelocity(mp:MotionPath, currentTime:Number, totalTime:Number):Number
    {
        // Determine the fraction of the effect that has already played.
        var fraction:Number = currentTime / totalTime;
        
        // Now we need to determine the effective velocity at the effect's current position.
        // Here we use a "poor man's" approximation that doesn't require us to know any of the
        // derivative functions associated with the motion path.  We sample the position at two
        // time values very close together and assume the velocity slope is a straight line 
        // between them.  The smaller the distance between the two time values, the closer the 
        // result will be to the "instantaneous" velocity.
        const TINY_DELTA_TIME:Number = 0.00001; 
        var value1:Number = Number(mp.getValue(fraction));
        var value2:Number = Number(mp.getValue(fraction + (TINY_DELTA_TIME / totalTime)));
        return (value2 - value1) / TINY_DELTA_TIME;
    }

    /**
     *  @private
     *  Calculates the current velocities of the in-progress throw animation   
     */
    mx_internal function getCurrentVelocity():Point
    {
        // Get the current position of the existing throw animation
        var effectTime:Number = this.playheadTime;
        
        // It's possible for playheadTime to not be set if we're getting it
        // before the first animation timer call.
        if (isNaN(effectTime))
            effectTime = 0;
        
        var effectDuration:Number = this.duration;
        
        var velX:Number = horizontalMP ? getMotionPathCurrentVelocity(horizontalMP, effectTime, effectDuration) : 0;
        var velY:Number = verticalMP ? getMotionPathCurrentVelocity(verticalMP, effectTime, effectDuration) : 0;
        
        return new Point(velX, velY);
    }
        
    
    /**
     *  @private
     *  A utility function to add a new keyframe to the motion path and return the frame time.  
     */
    private function addKeyframe(motionPath:SimpleMotionPath, time:Number, position:Number, easer:IEaser):Number
    {
        var keyframe:Keyframe = new Keyframe(time, position);
        keyframe.easer = easer;
        motionPath.keyframes.push(keyframe);
        return time;
    }

    /**
     *  @private
     *  This function builds a motion path that reflects the starting conditions (position, velocity)
     *  and exhibits overshoot/settle/snap effects (aka bounce/pull) according to the min/max boundaries.
     */
    private function createThrowMotionPath(propertyName:String, velocity:Number, position:Number, minPosition:Number,
                                           maxPosition:Number, throwEffectTime:Number):SimpleMotionPath
    {
        var motionPath:SimpleMotionPath = new SimpleMotionPath(propertyName);
        motionPath.keyframes = Vector.<Keyframe>([new Keyframe(0, position)]);
        var keyframe:Keyframe = null;
        var nowTime:Number = 0;
        var alignedPosition:Number;
        
        // First, we handle the case where the velocity is zero (finger wasn't significantly moving when lifted).
        // Ordinarily, we do nothing in this case, but if the list is currently scrolled past its end (i.e. "pulled"),
        // we need to have the animation move it back so none of the empty space is visible.
        if (velocity == 0)
        {
            if ((position < minPosition || position > maxPosition))
            {
                // Velocity is zero and we're past the end of the list.  We want the 
                // list to "snap" back to its resting position at the end.  We use a 
                // cubic easer curve so the snap has high initial velocity and 
                // gradually decelerates toward the resting point.
                position = position < minPosition ? minPosition : maxPosition;

                if (finalPositionFilterFunction != null)
                    position = finalPositionFilterFunction(position, propertyName);
                
                nowTime = addKeyframe(motionPath, nowTime + THROW_SETTLE_TIME, position, new Power(0, THROW_CURVE_EXPONENT));
            }
            else
            {
                // See if we need to snap into alignment
                alignedPosition = position;
                if (finalPositionFilterFunction != null)
                    alignedPosition = finalPositionFilterFunction(position, propertyName);
                
                if (alignedPosition == position)
                    return null;

                isSnapping = true;
                nowTime = addKeyframe(motionPath, nowTime + THROW_SETTLE_TIME, alignedPosition, new Power(0, THROW_CURVE_EXPONENT));
            }
        }
        
        // Each iteration of this loop adds one of more keyframes to the motion path and then
        // updates the velocity and position values.  Once the velocity has decayed to zero,
        // the motion path is complete.
        while (velocity != 0.0)
        {
            if ((position < minPosition && velocity > 0) || (position > maxPosition && velocity < 0))
            {
                // We're past the end of the list and the velocity is directed further beyond
                // the end.  In this case we want to overshoot the end of the list and then 
                // settle back to it.
                var settlePosition:Number = position < minPosition ? minPosition : maxPosition;
                
                if (finalPositionFilterFunction != null)
                    settlePosition = finalPositionFilterFunction(settlePosition, propertyName);
                
                // OVERSHOOT_CURVE_EXPONENT is the default initial slope of the easer function we use for the overshoot.  
                // This calculation scales the y axis (distance) of the overshoot so the actual slope matches the velocity.
                var overshootPosition:Number = Math.round(position - 
                    ((velocity / OVERSHOOT_CURVE_EXPONENT) * THROW_OVERSHOOT_TIME));
                
                nowTime = addKeyframe(motionPath, nowTime + THROW_OVERSHOOT_TIME,
                    overshootPosition, new Power(0, OVERSHOOT_CURVE_EXPONENT));
                nowTime = addKeyframe(motionPath, nowTime + THROW_SETTLE_TIME, settlePosition, new Sine(0.25));
                
                // Clear the velocity to indicate that the motion path is complete.
                velocity = 0;
                position = settlePosition;
            }
            else
            {
                // Here we're going to do a "normal" throw.
                
                var effectTime:Number = throwEffectTime;
                
                var minVelocity:Number;
                if (position < minPosition || position > maxPosition)
                {
                    // The throw is starting beyond the end of the list.  We need to enforce a minimum velocity
                    // to make sure the throw makes it all the way back to the end (i.e. doesn't leave any blank area
                    // exposed) and does so within THROW_SETTLE_TIME.  THROW_SETTLE_TIME needs to be consistently
                    // adhered to in all cases where the tension of being beyond the end acts on the scroll position.  
                    
                    // The minimum velocity is that which gets us back to the end position in exactly THROW_SETTLE_TIME milliseconds. 
                    minVelocity = ((position - (position < minPosition ? minPosition : maxPosition)) / 
                        THROW_SETTLE_TIME) * THROW_CURVE_EXPONENT;
                    if (Math.abs(velocity) < Math.abs(minVelocity))
                    {   
                        velocity = minVelocity;
                        effectTime = THROW_SETTLE_TIME;
                    }
                }
                
                // The easer function we use is 1-((1-x)^THROW_CURVE_EXPONENT), which has an initial slope of THROW_CURVE_EXPONENT.
                // The x axis is scaled according to the throw duration we calculated above, so now we need
                // to determine the correct y-axis scaling (i.e. throw distance) such that the initial 
                // slope matches the specified throw velocity.
                var finalPosition:Number = Math.round(position - ((velocity / THROW_CURVE_EXPONENT) * effectTime));
                
                if (finalPosition < minPosition || finalPosition > maxPosition)
                {
                    // The throw is going to hit the end of the list.  In this case we need to clip the 
                    // deceleration curve at the appropriate point.  We want the curve to look exactly as
                    // it would if we were allowing the throw to go beyond the end of the list.  But the 
                    // keyframe we add here will stop exactly at the end.  The subsequent loop iteration
                    // will add keyframes that describe the overshoot & settle behavior.
                    
                    var endPosition:Number = finalPosition < minPosition ? minPosition : maxPosition;
                    
                    // since easing function is f(t) = start + (final - start) * e(t)
                    // e(t) = Math.pow(1 - t/throwEffectTime, 3)
                    // We want to solve for t when e(t) = finalPosition
                    // t = throwEffectTime*(1-(Math.pow(1-((endPosition-position)/(finalVSP-position)),1/3)));
                    var partialTime:Number = 
                        effectTime*(1 - (Math.pow(1 - ((endPosition - position) / (finalPosition - position)), 1 / THROW_CURVE_EXPONENT)));
                    
                    // PartialExponentialCurve creates a portion of the throw easer curve, but scaled up to fill the 
                    // specified duration.
                    nowTime = addKeyframe(motionPath, nowTime + partialTime, endPosition,
                        new PartialExponentialCurve(THROW_CURVE_EXPONENT, partialTime / effectTime));
                    
                    // Set the position just past the end of the list for the next loop iteration.
                    if (finalPosition < minPosition)
                        position = minPosition - 1;
                    if (finalPosition > maxPosition)
                        position = maxPosition + 1;
                    
                    // Set the velocity for the next loop iteration.  Make sure it matches the actual velocity in effect when the 
                    // throw reaches the end of the list.
                    //
                    // The easer function we use for the throw is 1-((1-x)^3), the derivative of which is 3*x^2-6*x+3.
                    // (I used http://www.numberempire.com/derivatives.php to differentiate the easer function).
                    // Since the slope of a curve function at any point x (i.e. f(x)) is the value of the derivative at x (i.e. f'(x)),
                    // we can use this to determine the velocity of the throw at the point it reached the beginning of the bounce.
                    var x:Number = partialTime / effectTime;
                    var y:Number =  3 * Math.pow(x, 2) - 6 * x + 3; // NOTE: This calculation must be matched to the THROW_CURVE_EXPONENT value.
                    velocity = -y * (finalPosition - position) / effectTime; 
                }
                else
                {
                    // This is the simplest case.  The throw both begins and ends on the list (i.e. not past the 
                    // end of the list).  We create a single keyframe and clear the velocity to indicate that the
                    // motion path is complete.
                    // Note that we only use the first 62% of the actual deceleration curve, and stop the motion
                    // path at that point.  That's the point in time at which most throws animations get to within
                    // a single pixel of their final destination.  Since scrolling is done at whole pixel 
                    // boundaries, there's no point in letting the rest of the animation play out, and stopping it 
                    // allows us to release the mouse capture earlier for a better user experience.

                    if (finalPositionFilterFunction != null)
                        finalPosition = finalPositionFilterFunction(finalPosition, propertyName);
                    
                    const CURVE_PORTION:Number = 0.62;
                    nowTime = addKeyframe(
                        motionPath, nowTime + (effectTime*CURVE_PORTION), finalPosition, 
                        new PartialExponentialCurve(THROW_CURVE_EXPONENT, CURVE_PORTION));
                    velocity = 0;
                }
            }
        }
        return motionPath;
    }
    
    
}
}

import spark.effects.easing.EaseInOutBase;

/**
 *  @private
 *  A custom ease-out-only easer class which animates along a specified 
 *  portion of an exponential curve.  
 */
class PartialExponentialCurve extends EaseInOutBase
{
    public function PartialExponentialCurve(exponent:Number, xscale:Number)
    {
        super(0);
        _exponent = exponent;
        _xscale = xscale;
        _ymult = 1 / (1 - Math.pow(1 - _xscale, _exponent));
    }
    
    override protected function easeOut(fraction:Number):Number
    {
        return _ymult * (1 - Math.pow(1 - fraction*_xscale, _exponent)); 
    }
    private var _xscale:Number;
    private var _ymult:Number;
    private var _exponent:Number;
}

