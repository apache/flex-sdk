////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.effects  
{
import mx.core.mx_internal;
import spark.effects.easing.IEaser;
import spark.effects.interpolation.IInterpolator;
import spark.effects.interpolation.NumberInterpolator;
import spark.effects.easing.Sine;

use namespace mx_internal;

[DefaultProperty("keyframes")]

/**
 * This class holds information on a property to be animated
 * and the values that the property should animate between.
 * 
 * <p>The 'path' of values that the property will take on during
 * the animation is specified as a set of keyframes, each of which
 * specifies the value at a particular time during the animation.
 * Values in between keyframes are calculated by interpolating
 * between the values of the bounding keyframes.</p>
 * 
 * @see KeyFrame
 */
public class MotionPath
{
    include "../../spark/core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * Constructor. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function MotionPath(property:String = null)
    {
        this.property = property;
    }

    //--------------------------------------------------------------------------
    //
    // Properties
    //
    //--------------------------------------------------------------------------

    /**
     * The name of the property to be animated.
     */
    public var property:String;
     
    /**
     * The interpolator determines how in-between values in an animation
     * are calculated. By default, MotionPath assumes that the values are
     * of type Number and can calculate in-between Number values automatically.
     * If MotionPath is given keyframes with non-Number values, or if the
     * desired behavior should use a different approach to interpolation
     * (such as per-channel color interpolation), then an interpolator
     * should be supplied.
     */
    public var interpolator:IInterpolator = NumberInterpolator.getInstance();
    
    [Inspectable(category="General", arrayType="spark.effects.KeyFrame")]
    /**
     * A sequence of KeyFrame objects that represent the time/value pairs
     * that the property should take on during the animation. Each successive
     * pair of keyframes controls the animation during the time interval
     * between them, with the optional <code>easer</code> and <code>valueBy</code>
     * properties of the later keyframe used to help determine the behavior
     * during that interval. The sequence of keyframes must be sorted in 
     * order of increasing time values.
     * 
     * <p>Animations will always start at time 0 and will last for a duration
     * equal to the time value in the final keyframe. If no keyframe at time 0
     * is provided, that keyframe will be implicit, using the value of the
     * target property at the time the animation begins. Because keyframes
     * explicitly define the times involved in an animation, the duration for
     * an effect using keyframes will be set according to the maximum time
     * of the final keyframe of all MotionPaths in the effect.
     * For example, if an effect has keyframes
     * at times 0, 500, 1000, and 2000, then the effective duration of that
     * effect will be 2000, regardless of any duration value set on the
     * effect itself. Because the final keyframe determines the duration, there
     * must always be a final keyframe in any MotionPath. That is, 
     * it is implicit that the time in the final keyframe is the 
     * duration of the MotionPath.</p>
     * 
     * <p>Any keyframe may leave its <code>value</code> undefined (either unset, set to 
     * <code>null</code>, or set to <code>NaN</code>), in which case the
     * value will be determined dynamically when the animation starts.
     * Any such undefined value will be determined as follows: (1) if it
     * is the first keyframe, it will be calculated from the next keyframe
     * if that keyframe has both a <code>value</code> and <code>valueBy</code>,
     * as the difference of those values, otherwise it will get the
     * current value of the property on the target, (2) if it is the final
     * keyframe and the animation is running in a transition, it will 
     * use the value in the state being transitioned to, (3) otherwise,
     * any keyframe will calculate its unset value by using the previous
     * keyframe's value, adding the current keyframe's <code>valueBy</code>
     * to it, if <code>valueBy</code> is set.</p>
     * 
     * @see KeyFrame
     */
    public var keyframes:Array;
    

    /**
     * Returns a copy of this MotionPath object, including copies
     * of each keyframe
     */
    public function clone():MotionPath
    {
        var mp:MotionPath = new MotionPath(property);
        mp.interpolator = interpolator;
        if (keyframes !== null)
        {
            mp.keyframes = [];
            for (var i:int = 0; i < keyframes.length; ++i)
                mp.keyframes[i] = keyframes[i].clone();
        }
        return mp;
    }

    /**
     * @private
     * 
     * Calculates the <code>timeFraction</code> values for
     * each KeyFrame in a MotionPath KeyFrame sequence.
     * To calculate these values, the time on each KeyFrame
     * is divided by the supplied <code>duration</code> parameter.
     * 
     * @param duration the duration of the animation that the
     * keyframes should be scaled against.
     */
    mx_internal function scaleKeyframes(duration:Number):void
    {
        var n:int = keyframes.length;
        for (var i:int; i < n; ++i)
        {
            var kf:KeyFrame = keyframes[i];
            // TODO (chaase): Must be some way to allow callers
            // to supply timeFraction, but currently we clobber it
            // with this operation. But if we choose to clobber it
            // only if it's not set already, then it only works the
            // first time through, since an Effect will retain its
            // MotionPaty, which retains its KeyFrames, etc.
            kf.mx_internal::timeFraction = kf.time / duration;
        }
    }
    
    /**
     * Calculates and returns an interpolated value, given the elapsed
     * time fraction. The function determines the keyframe interval
     * that the fraction falls within and then interpolates within
     * that interval between the values of the bounding keyframes on that
     * interval.
     */
    public function getValue(fraction:Number):Object
    {
        if (!keyframes)
            return null;
        var n:int = keyframes.length;
        if (n == 2 && keyframes[1].timeFraction == 1)
        {
            // The common case where we are just animating from/to, as in the
            // case of an AnimationProperty
            var easedF:Number = (keyframes[1].easer) ? 
                keyframes[1].easer.ease(fraction) : 
                fraction;
            return interpolator.interpolate(easedF, keyframes[0].value,
                keyframes[1].value);
        }
        // if timeFraction on first keyframe is not set, call scaleKeyframes
        // should not generally happen, but if getValue() is called before
        // an owning effect is played, then timeFractions were not set
        if (isNaN(keyframes[0].timeFraction))
            scaleKeyframes(keyframes[keyframes.length-1].time);
        var prevT:Number = 0;
        var prevValue:Object = keyframes[0].value;
        for (var i:int = 1; i < n; ++i)
        {
            var kf:KeyFrame = keyframes[i];
            if (fraction >= prevT && fraction < kf.timeFraction)
            {
                var t:Number = (fraction - prevT) / (kf.timeFraction - prevT);
                var easedT:Number = (kf.easer) ? kf.easer.ease(t) : t;
                return interpolator.interpolate(easedT, prevValue, kf.value);
            }
            prevT = kf.timeFraction;
            prevValue = kf.value;
        }
        // Must be at the end of the animation
        return keyframes[n-1].value;
    }

}
}