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
package mx.effects
{
import __AS3__.vec.Vector;

import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Dictionary;
import flash.utils.Timer;
import flash.utils.getTimer;

import mx.effects.interpolation.ArrayInterpolator;
import mx.effects.interpolation.IEaser;
import mx.effects.interpolation.IInterpolator;
import mx.effects.interpolation.Linear;
import mx.effects.interpolation.NumberArrayInterpolator;
import mx.effects.interpolation.NumberInterpolator;
import mx.effects.interpolation.Sine;
import mx.events.AnimationEvent;

/**
 * Dispatched when the animation starts. The first 
 * <code>animationUpdate</code> event is dispatched at the 
 * same time.
 *
 * @eventType mx.events.AnimationEvent.ANIMATION_START
 */
[Event(name="animationStart", type="mx.events.AnimationEvent")]

/**
 * Dispatched every time the animation updates the target.
 *
 * @eventType mx.events.AnimationEvent.ANIMATION_UPDATE
 */
[Event(name="animationUpdate", type="mx.events.AnimationEvent")]

/**
 * Dispatched when the animation begins a new repetition, for
 * any effect that is repeated more than once.
 * An <code>animationUpdate</code> event is also dispatched 
 * at the same time.
 *
 * @eventType mx.events.AnimationEvent.ANIMATION_REPEAT
 */
[Event(name="animationRepeat", type="mx.events.AnimationEvent")]

/**
 * Dispatched when the effect ends. An <code>animationUpdate</code> event 
 * is also dispatched at the same time. A repeating animation dispatches 
 * this event only after the final repetition.
 *
 * @eventType mx.events.AnimationEvent.ANIMATION_END
 */
[Event(name="animationEnd", type="mx.events.AnimationEvent")]

/**
 * The Animation class defines an animation that happens between 
 * start and end values over a specified period of time.
 * The animation can be a change in position, such as performed by
 * the Move effect; a change in size, as performed by the Resize effect;
 * a change in visibility, as performed by the Fade effect; or other 
 * types of animations used by effects or run directly with Animation.
 * This class defines the timing and value parts of the animation; other
 * code, either in effects or in application code, associate the animation
 * with objects and properties, such that the animated values produced by
 * Animation can then be applied to target objects and properties to actually
 * cause these objects to animate.
 *
 * <p>When defining animation effects, developers typically create an
 * instance of the Animate class, or some subclass thereof, which creates
 * an Animation in the <code>play()</code> method. The Animation instance
 * accepts start and end values, a duration, and optional parameters such as
 * easer and interpolator objects.</p>
 * 
 * <p>The Animation object calls listeners and the start and end of the animation,
 * as well as when the animation repeats and at regular update intervals during
 * the animation. These calls pass values which Animation calculated from
 * the start and end values and the easer and interpolator objects. These
 * values can then be used to set property values on target objects.</p>
 *
 *  @see mx.effects.Animate
 *  @see mx.effects.effectClasses.FxAnimateInstance
 */
public class Animation extends EventDispatcher
{
    /**
     * TODOs:
     * - seek? reverse?
     */

    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * Constructs an Animation object.
     * 
     * @param startValue The initial value that the animation starts at
     * @param endValue The final value that the animation ends on
     * @param duration The length of time, in milliseconds, that the animation
     * will run
     */
    public function Animation(startValue:Object=null, endValue:Object=null, 
                                  duration:Number=-1)
    {
        this.duration = duration;
        this.startValue = startValue;
        this.endValue = endValue;
        if (!isNaN(duration) && duration != -1)
            this.duration = duration;
        if (startValue is Array)
            arrayMode = true;
    }
    

    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    public static const LOOP:String = "loop";
    public static const REVERSE:String = "reverse";

    // A single Timer object runs all animations in the process
    private static var activeAnimations:Array = [];
    private static var timer:Timer = null;
    private static var minRequestedResolution:Number;

    private var arrayMode:Boolean;
    // TODO: more efficient way to store/remove these than in an array?
    // Dictionary, perhaps (although that may be unordered and less
    // efficient to access)
    private var id:int;
    // TODO: re-think this variable in seeking
    private var _doSeek:Boolean = false;
    private var _isPlaying:Boolean = false;
    // TODO: rethink how we do reversing
    private var _doReverse:Boolean = false;
    private var _invertValues:Boolean = false;
    // Track when the current cycle started to compute elapsedTime
    // and current fraction
    private var startTime:Number;
    // Track number of times repeated for use by repeatCount logic
    private var numRepeats:Number;

    private var easingFunction:Function;
    private static var defaultEaser:IEaser = new Sine(.5); 
    private static var delayedStartAnims:Vector.<Animation> =
        new Vector.<Animation>();
    private static var delayedStartTimes:Dictionary = new Dictionary();
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    /**
     * This variable indicates whether the animation is currently
     * running or not. The value is <code>false</code> unless the animation
     * has been played and not yet stopped (either programmatically or
     * automatically) or paused.
     */
    public function get isPlaying():Boolean
    {
        return _isPlaying;
    }
    
    /**
     * The value that the animation will produce at the beginning of the
     * animation. Values during the animation are calculated using the
     * <code>startValue</code> and <code>endValue</code>. This value
     * can be any arbitray object, but this type must be the same as
     * that for <code>endValue</code>, and types that are not Number
     * or Arrays of Number can only be handled if an <code>interpolator</code>
     * is supplied to the Animation to handle calculating intermediate
     * values.
     * 
     * @see #interpolator
     */
    public var startValue:Object;

    /**
     * The value that the animation will produce at the beginning of the
     * animation. Values during the animation are calculated using the
     * <code>startValue</code> and <code>endValue</code>. This value
     * can be any arbitray object, but this type must be the same as
     * that for <code>endValue</code>, and types that are not Number
     * or Arrays of Number can only be handled if an <code>interpolator</code>
     * is supplied to the Animation to handle calculating intermediate
     * values.
     * 
     * @see #interpolator
     */
    public var endValue:Object;

    /**
     * The length of time, in milliseconds, that this animation will run,
     * not counting any repetitions by use of <code>repeatCount</code>.
     */
    public var duration:Number;

    //----------------------------------
    //  repeatBehavior
    //----------------------------------
    /**
     * @private
     * Storage for the repeatDelay property. 
     */
    private var _repeatBehavior:String = LOOP;
    /**
     * Sets the behavior of a repeating animation (an animation
     * with <code>repeatCount</code> equal to either 0 or >1). This
     * value should be either <code>LOOP</code>, where the animation
     * will repeat in the same order each time, or <code>REVERSE</code>,
     * where the animation will reverse direction each iteration.
     * 
     * @param value A String describing the behavior, either
     * Animation.LOOP or Animation.REVERSE
     * 
     * @default LOOP
     */
    public function get repeatBehavior():String
    {
        return _repeatBehavior;
    }
    public function set repeatBehavior(value:String):void
    {
        _repeatBehavior = value;
    }

    //----------------------------------
    //  repeatCount
    //----------------------------------
    
    /**
     * @private
     * Storage for the repeatCount property. 
     */
    private var _repeatCount:Number = 1;
    /**
     * Number of times that this animation will repeat. A value of
     * 0 means that it will repeat indefinitely. Only integer values are
     * supported, with fractional values rounded up to the next higher integer.
     * 
     * @param value Number of repetitions for this animation, with 0 being
     * an infinitely repeating animation. This value must be a positive 
     * number.
     * 
     * @default 1
     */
    public function set repeatCount(value:Number):void
    {
        _repeatCount = value;
    }
    public function get repeatCount():Number
    {
        return _repeatCount;
    }
    
    //----------------------------------
    //  repeatDelay
    //----------------------------------

    /**
     * @private
     * Storage for the repeatDelay property. 
     */
    private var _repeatDelay:Number = 0;
    /**
     * The amount of time spent waiting before each repetition cycle
     * begins. Setting this value to a non-zero number will have the
     * side effect that the previous animation cycle will end exactly at 
     * its end value, whereas non-delayed repetitions may skip over that 
     * value completely as the animation transitions smoothly from being
     * near the end of one cycle to being past the beginning of the next.
     *
     * @param value Amount of time, in milliseconds, to wait before beginning
     * each new cycle. This parameter is used starting with the first repetition,
     * not the first cycle. For a delay before the initial start, use
     * the <code>startDelay</code> property. Must be a value >= 0.
     * @see #startDelay
     * 
     * @default 0
     */
    public function set repeatDelay(value:Number):void
    {
        _repeatDelay = value;
    }
    public function get repeatDelay():Number
    {
        return _repeatDelay;
    }
    
    /**
     * @private
     * Storage for the startDelay property. 
     */
    private var _startDelay:Number = 0;
    /**
     * The amount of time spent waiting before the animation
     * begins.
     *
     * @param value Amount of time, in milliseconds, to wait before beginning
     * the animation. Must be a value >= 0.
     * 
     * @default 0
     */
    public function set startDelay(value:Number):void
    {
        _startDelay = value;
    }
    public function get startDelay():Number
    {
        return _startDelay;
    }

    //----------------------------------
    //  intervalTime
    //----------------------------------

    /**
     * @private
     * Storage for the repeatDelay property. 
     */
    private static var _intervalTime:Number = NaN;
    /**
     * The time being used in the current frame calculations. This time is
     * shared by all active animations.
     */
    public static function get intervalTime():Number
    {
        return _intervalTime;
    }

    //----------------------------------
    //  interpolator
    //----------------------------------

    /**
     * The interpolator used by Animation to calculate values between
     * the start and end values. By default, interpolation is handled
     * by <code>NumberInterpolator</code> or, in the case of the start
     * and end values being arrays, by <code>NumberArrayInterpolator</code>.
     * Interpolation of other types, or of Numbers that should be interpolated
     * differently, such as <code>uint</code> values that hold color
     * channel information, can be handled by supplying a different
     * <code>interpolator</code>.
     */
    public var interpolator:IInterpolator = null;

    //----------------------------------
    //  resolution
    //----------------------------------

    /**
     * @private
     * Storage for the resolution property. This variable is static
     * because all animations in the system share the same Timer, which
     * uses this single resolution.
     */
    private static var _resolution:Number = 10;
    /**
     * The maximum time between timing events, in milliseconds. It is
     * possible that the underlying timing mechanism may not be able to
     * achieve the rate requested by <code>resolution</code>. Since
     * all Animation objects run off the same underlying timer, 
     * they will all be serviced with the lowest <code>resolution</code>
     * requested.
     * 
     * @default 10
     */
    public function get resolution():Number
    {
        return _resolution;
    }
    public function set resolution(value:Number):void
    {
        if (isNaN(minRequestedResolution) || value < minRequestedResolution)
        {
            _resolution = value;
            if (timer)
                timer.delay = _resolution;
            minRequestedResolution = value;
        }
    }
    
    //----------------------------------
    //  elapsedTime
    //----------------------------------

    private var _elapsedTime:Number = 0;
    /**
     *  @private
     *  The current millisecond position in the animation.
     *  This value is between 0 and <code>duration</code>.
     *  Use the seek() method to change the position of the animation.
     */
    public function get elapsedTime():Number
    {
        return _elapsedTime;
    }

    
    //----------------------------------
    //  elapsedFraction
    //----------------------------------

    private var _elapsedFraction:Number;
    /**
     *  @private
     *  The current fraction elapsed in the animation, after easing
     *  has been applied. This value is between 0 and 1.
     */
    public function get elapsedFraction():Number
    {
        return _elapsedFraction;
    }

    //----------------------------------
    //  easer
    //----------------------------------

    /**
     * @private
     * Storage for the easer property.
     */
    private var _easer:IEaser = defaultEaser;
    /**
     * Sets the easing behavior for this Animation. This IEaser
     * object will be used to convert the elapsed fraction of 
     * the animation into an eased fraction, which will then be used to
     * calculate the value at that fraction.
     * 
     * @param value The IEaser object which will be used to calculate the
     * eased elapsed fraction every time a animation event occurs. A value
     * of <code>null</code> will be interpreted as meaning no easing is
     * desired, which is equivalent to using a Linear ease, or
     * <code>animation.easer = Linear.getInstance();</code>.
     * 
     * @default Sine(.5)
     */
    public function get easer():IEaser
    {
        return _easer;
    }
    public function set easer(value:IEaser):void
    {
        if (!value)
        {
            value = Linear.getInstance();
        }
        _easer = value;
    }
    
    // TODO: rethink reversal
    public function get playReversed():Boolean
    {
        return _invertValues;
    }
    public function set playReversed(value:Boolean):void
    {
        _invertValues = value;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     * Adds a new animation to the system. All animations run off the same
     * single Timer, so starting any one animation simply adds it onto the
     * static list of active animations.
     */
    private static function addAnimation(animation:Animation):void
    {
        animation.id = activeAnimations.length;
        
        activeAnimations.push(animation);
        
        if (!timer)
        {
            Timeline.pulse();
            timer = new Timer(_resolution);
            timer.addEventListener(TimerEvent.TIMER, timerHandler);
            timer.start();
        }
        
        _intervalTime = Timeline.currentTime;

        animation.startTime = _intervalTime;
    }

    private static function removeAnimationAt(index:int):void
    {
        if (index >= 0 && index < activeAnimations.length)
        {
            activeAnimations.splice(index, 1);
                    
            var n:int = activeAnimations.length;
            for (var i:int = index; i < n; i++)
            {
                var curAnimation:Animation = Animation(activeAnimations[i]);
                curAnimation.id--;
            }
        }
        // If no more animations running or pending, stop the timer
        if (timer && activeAnimations.length == 0 && delayedStartAnims.length == 0)
        {
            _intervalTime = NaN;
            timer.reset();
            timer = null;
        }
    }

    /**
     *  @private
     */
    private static function removeAnimation(animation:Animation):void
    {
        removeAnimationAt(animation.id);
    }
    
    private static function timerHandler(event:TimerEvent):void
    {
        var oldTime:Number = intervalTime;
        _intervalTime = Timeline.pulse();
        
        var n:int = activeAnimations.length;
        var i:int = 0;
        
        while (i < activeAnimations.length)
        {
            // only increment index into array if no animation was stopped
            // as a result to call to doInterval(). Stopped animations
            // will be removed from the array and everything after them
            // shifts down
            var incrementIndex:Boolean = true;
            var animation:Animation = Animation(activeAnimations[i]);
            if (animation)
                incrementIndex = !animation.doInterval();
            if (incrementIndex)
                ++i;
        }
        
        // Check to see whether it's time to start any delayed animations
        for (i = 0; i < delayedStartAnims.length; ++i)
        {
            var anim:Animation = Animation(delayedStartAnims[i]);
            var animStartTime:Number = delayedStartTimes[anim];
            // Keep starting animations unless our sorted lists return
            // animations that start past the current time
            if (animStartTime < Timeline.currentTime)
                anim.start();
            else
                break;
        }
        event.updateAfterEvent();
    }

    /**
     * @private
     * 
     * Calculates the time and elapsed fraction, then gets the
     * appropriate interpolated value at that fraction, then sends out
     * the animation event to all listeners.
     *  
     * Returns true if the animation has ended.
     */
    private function doInterval():Boolean
    {
        var animationEnded:Boolean = false;
        var repeated:Boolean = false;
                
        if (_isPlaying || _doSeek)
        {
            
            var currentTime:Number = intervalTime - startTime;
            if (currentTime >= duration && 
                (repeatCount == 0 || numRepeats < repeatCount))
            {
                // TODO (chaase): this assumes we've only gone through one cycle since
                // last time...
                if (repeatCount != 0)
                    numRepeats++;
                if (repeatDelay == 0) {
                    startTime += duration;
                    currentTime = intervalTime - startTime;
                    if (repeatBehavior == REVERSE)
                        _invertValues = !_invertValues;
                    repeated = true;
                }
                else
                {
                    // repeatDelay: send out a final update for this cycle with the
                    // end value, then schedule a timer to wake up and
                    // start the next cycle
                    _elapsedTime = duration;
                    var repeatValue:Object = getCurrentValue(_elapsedTime);
                    sendAnimationEvent(AnimationEvent.ANIMATION_UPDATE, repeatValue);
                    removeAnimation(this);
                    var delayTimer:Timer = new Timer(repeatDelay, 1);
                    delayTimer.addEventListener(TimerEvent.TIMER, repeat);
                    delayTimer.start();
                    return false;
                }
            }
            _elapsedTime = currentTime;
            
            var currentValue:Object = getCurrentValue(currentTime);

            if (currentTime >= duration && !_doSeek)
            {
                end();
                animationEnded = true;
            }
            else
            {
                sendAnimationEvent(AnimationEvent.ANIMATION_UPDATE, currentValue);
                if (repeated)
                    sendAnimationEvent(AnimationEvent.ANIMATION_REPEAT, currentValue);
            }
            
            _doSeek = false;
        }
        return animationEnded;
    }
    
    /**
     * Utility function for dispatching a specified AnimationEvent.
     */
    private function sendAnimationEvent(eventType:String, value:Object):void
    {
        var event:AnimationEvent = new AnimationEvent(eventType);
        event.value = value;                
        event.animation = this;
        dispatchEvent(event);                
    }

    /**
     * @private
     * 
     * Calculates and returns the appropriate value give the elapsed time
     * of the animation
     */
    private function getCurrentValue(currentTime:Number):Object
    {
        if (duration == 0)
        {
            return endValue;
        }
    
        if (_invertValues)
            currentTime = duration - currentTime;
    
        _elapsedFraction = easer.ease(currentTime/duration);

        return interpolator.interpolate(_elapsedFraction, startValue, endValue);
    }

    /**
     * Remove this animation from the list of pending animations,
     * as appropriate
     */
    private function removeFromDelayedAnimations():void
    {
        if (delayedStartTimes[this])
        {
            var animPendingTime:int = delayedStartTimes[this];
            for (var i:int = 0; i < delayedStartAnims.length; ++i)
            {
                if (delayedStartAnims[i] == this)
                {
                    delayedStartAnims.splice(i, 1);
                    break;
                }
            }
            delete delayedStartTimes[this];
        }
    }

    /**
     *  Interrupt the animation, jump immediately to the end of the animation, 
     *  and send out ending notifications
     */
    public function end():void
    {
        // TODO (chaase): Check whether we already send out a final
        // UPDATE event with the end value; if so, this dup should be
        // removed
        // TODO (chaase): this will snap paused and startDelayed animations
        // to their end values. Seems correct, but should check this.
        var value:Object = getCurrentValue(duration);
        
        sendAnimationEvent(AnimationEvent.ANIMATION_UPDATE, value);
        sendAnimationEvent(AnimationEvent.ANIMATION_END, value);

        // The rest of what we need to do is handled by the stop() function
        stop();
    }

    /**
     * Start the animation
     */
    public function play():void
    {
        setupInterpolation();
        if (startDelay > 0)
        {
            // Run timer if it's not currently running
            if (!timer)
            {
                Timeline.pulse();
                timer = new Timer(_resolution);
                timer.addEventListener(TimerEvent.TIMER, timerHandler);
                timer.start();
            }
            var animStartTime:int = Timeline.currentTime + startDelay;
            var insertIndex:int = -1;
            for (var i:int = 0; i < delayedStartAnims.length; ++i)
            {
                var timeAtIndex:int = 
                    delayedStartTimes[delayedStartAnims[i]];
                if (animStartTime < timeAtIndex)
                {
                    insertIndex = i;
                    break;
                }
            }
            if (insertIndex >= 0)
                delayedStartAnims.splice(insertIndex, 0, this);
            else
                delayedStartAnims.push(this);
            delayedStartTimes[this] = animStartTime;
        }
        else
        {
            start();
        }
    }
    
    /**
     *  Advances the animation effect to the specified position. 
     *
     *  @param playheadTime The position, in milliseconds, between 0
     *  and the value of the <code>duration</code> property.
     */ 
    public function seek(playheadTime:Number):void
    {
        // Set value between 0 and duration
        //playheadTime = Math.min(Math.max(playheadTime, 0), duration);
        
        var clockTime:Number = intervalTime;
        
        // Reset the start time
        startTime = clockTime - playheadTime;
        
        _doSeek = true;
        
        if (!_isPlaying)
        {
            setupInterpolation();
            _intervalTime = Timeline.currentTime;
            startTime = _intervalTime - playheadTime;
            doInterval();
        }
    }

    /**
     * Sets up interpolation for the animation. If there is no interpolator
     * set on the animation, then it figures out whether it should use
     * NumberInterpolator or NumberArrayInterpolator, based on whether the
     * start/end values are arrays or not. Also, if the start/end values
     * are arrays but the supplied interpolator does not interpolate
     * Arrays, then it sets up an ArrayInterpolator that uses the supplied
     * interpolator for each element.
     */
    private function setupInterpolation():void
    {
        if (!interpolator) {
            if (startValue is Number && endValue is Number)
                // Better: default to use actual start/end values instead
                // of running an Interpolator on our internal Animation's result
                interpolator = NumberInterpolator.getInstance();
            else if (startValue is Array && endValue is Array)
            {
                // One more try - are they Arrays of Numbers?
                var startArray:Array = startValue as Array;
                var endArray:Array = endValue as Array;
                for (var i:int = 0; i < startArray.length; ++i)
                {
                    if (isNaN(startArray[i]))
                    {
                        throw new Error("startValue array contains non-Numbers: " +
                                        "must supply Interpolator to Animation");
                        return;
                    }
                }                        
                for (i = 0; i < endArray.length; ++i)
                {
                    if (isNaN(endArray[i]))
                    {
                        throw new Error("endValue array contains non-Numbers: " +
                                        "must supply Interpolator to Animation");
                        return;
                    }
                }
                // Must be Arrays of Numbers
                interpolator = NumberArrayInterpolator.getInstance();
            }
        }
        else
        {
            // If they've given us an interpolator, but it doesn't
            // interpolate arrays and our start/end values are arrays,
            // then we will assume that they want to use that interpolator
            // for the elements of the arrays, and we will use 
            // ArrayInterpolator for the overall arrays.
            if (arrayMode && (interpolator.interpolatedType != Array))
                interpolator = new ArrayInterpolator(interpolator);
        }
    }
 
    /**
     *  Plays the effect in reverse,
     *  starting from the current position of the effect.
     */
    public function reverse():void
    {
        if (_isPlaying)
        {
            _doReverse = false;
            seek(duration - _elapsedTime);
            _invertValues = !_invertValues;
        }
        else
        {
            _doReverse = !_doReverse;
        }
    }
    
    /**
     * Pauses the effect until the <code>resume()</code> method is called.
     * 
     * @see resume()
     */
    public function pause():void
    {
        _isPlaying = false;
    }

    /**
     *  Stops the animation, ending it without dispatching an event or calling
     *  the Animation's <code>end()</code> function. 
     */
    public function stop():void
    {
        removeFromDelayedAnimations();
        // If animation has been added, id >= 0
        // but if duration = 0, this might not be the case.
        if (id >= 0)
        {
            Animation.removeAnimationAt(id);
            id = -1;
        }        
        _doReverse = false
        _invertValues = false;
        _isPlaying = false;
    }
    
    /**
     *  Resumes the effect after it has been paused 
     *  by a call to the <code>pause()</code> method. 
     */
    public function resume():void
    {
        _isPlaying = true;
        
        startTime = intervalTime - _elapsedTime;
        if (_doReverse)
        {
            reverse();
            _doReverse = false;
        }
    }
    

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     * 
     * Called by a Timer after repeatDelay has elapsed for a given
     * repetition cycle. This causes the animation to send out an initial 
     * value at the starting point, just as if the animation were just starting
     * out.
     */
    private function repeat(event:TimerEvent = null):void
    {
        if (repeatBehavior == REVERSE)
            _invertValues = !_invertValues;
        var repeatValue:Object = getCurrentValue(0);
        // TODO (chaase): Make sure we're not already sending out an UPDATE
        // event with this value
        sendAnimationEvent(AnimationEvent.ANIMATION_UPDATE, repeatValue);
        sendAnimationEvent(AnimationEvent.ANIMATION_REPEAT, repeatValue);
        Animation.addAnimation(this);
    }
    
    /**
     * Called by play() or by a Timer, if startDelay is nonzero. This
     * method initializes any necessary default state and adds the animation
     * to the list of active animations, which starts it actually running.
     */
    private function start(event:TimerEvent = null):void
    {
        // TODO (chaase): call removal utility instead of this code
        // Make sure to remove any references on the delayed lists
        for (var i:int = 0; i < delayedStartAnims.length; ++i)
        {
            if (this == delayedStartAnims[i])
            {
                delete delayedStartTimes[this];
                delayedStartAnims.splice(i, 1);
                break;
            }
        }
        numRepeats = 1;
        var value:Object = getCurrentValue(0);
        sendAnimationEvent(AnimationEvent.ANIMATION_START, value);

        if (duration == 0)
        {
            id = -1; // use -1 to indicate that this animation was never added
            end();
        }
        else
        {
            // TODO (chaase): Make sure we're not already sending out an
            // UPDATE event with this start value
            sendAnimationEvent(AnimationEvent.ANIMATION_UPDATE, value);
            Animation.addAnimation(this);
            _isPlaying = true;
        }
    }

}
}