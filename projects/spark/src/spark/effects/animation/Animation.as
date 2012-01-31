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
package spark.effects.animation
{
import __AS3__.vec.Vector;

import flash.events.TimerEvent;
import flash.utils.Dictionary;
import flash.utils.Timer;
import flash.utils.getTimer;

import mx.events.EffectEvent;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;

import spark.effects.SimpleMotionPath;
import spark.effects.easing.IEaser;
import spark.effects.easing.Linear;
import spark.effects.easing.Sine;
import spark.effects.interpolation.ArrayInterpolator;
import spark.effects.interpolation.IInterpolator;
import spark.effects.interpolation.NumberInterpolator;

[DefaultProperty("motionPaths")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[ResourceBundle("sparkEffects")]

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
 *  @see mx.effects.effectClasses.AnimateInstance
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public final class Animation
{
    /**
     * TODOs:
     * - seek? reverse?
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */

    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class Constants
    //
    //--------------------------------------------------------------------------

    private static const TIMER_RESOLUTION:Number = 10;
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * Constructs an Animation object. The optional <code>property</code>,
     * <code>startValue</code>, and 
     * <code>endValue</code> parameters are short-cuts for setting up a simple
     * animation with a single MotionPath object with two KeyFrames. If either
     * value is non-null,
     * <code>startValue</code> will become the <code>value</code> of the
     * first keyframe of <code>motionPaths</code>, at time 0, and 
     * <code>endValue</code> will become the <code>value</code> of 
     * the second keyframe, at time 1.
     * 
     * @param duration The length of time, in milliseconds, that the animation
     * will run
     * @param property The property being animated
     * @param startValue The initial value that the animation starts at
     * @param endValue The final value that the animation ends on
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function Animation(duration:Number = 0, property:String = null,
        startValue:Object = null, endValue:Object = null)
    {
        this.duration = duration;
        if (property != null && (startValue !== null || endValue !== null))
            motionPaths = [new SimpleMotionPath(property, startValue, endValue, duration)];
    }
    

    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------


    /**
     * @private
     * 
     * The time being used in the current frame calculations. This time is
     * shared by all active animations.
     */
    private static var intervalTime:Number = NaN;

    // A single Timer object runs all animations in the process
    private static var activeAnimations:Array = [];
    private static var timer:Timer = null;

    private var arrayMode:Boolean;
    // TODO: more efficient way to store/remove these than in an array?
    // Dictionary, perhaps (although that may be unordered and less
    // efficient to access)
    private var id:int = -1;
    // TODO: re-think this variable in seeking
    private var _doSeek:Boolean = false;
    private var _isPlaying:Boolean = false;
    // TODO: rethink how we do reversing
    private var _doReverse:Boolean = false;
    private var _invertValues:Boolean = false;
    // Original start time of animation
    private var startTime:Number;
    // Time when the current cycle started
    private var cycleStartTime:Number;
    // Track number of times repeated for use by repeatCount logic
    private var numRepeats:int;
    // The amount of time that the animation should delay before
    // starting. This is set to a non-negative number only when
    // an Animation is paused during its startDelay phase
    private var delayTime:Number = -1;
    private static var defaultEaser:IEaser = new Sine(.5); 
    private static var delayedStartAnims:Vector.<Animation> =
        new Vector.<Animation>();
    private static var delayedStartTimes:Dictionary = new Dictionary();
    
    /**
     *  @private
     *  Used for accessing localized Error messages.
     */
    private var resourceManager:IResourceManager =
                                    ResourceManager.getInstance();
    
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    /**
     * This array holds the values as of the current frame of the Animation.
     * The values are stored as map values, using property names as the key.
     */
    public var currentValue:Object;

    /**
     * The set of MotionPath objects that define the properties and values
     * that the Animation will animate over time
     */
    public var motionPaths:Array;
    
    //----------------------------------
    //  animationTarget
    //----------------------------------
    /**
     * @private
     * Storage for the animationTarget property. 
     */
    private var _animationTarget:IAnimationTarget = null;
    /**
     * The IAnimationTarget object that will be notified with all
     * start, end, repeat, and update events for this animation.
     * A value of null indicates that there is no target that will
     * be notified with these events.
     * 
     * @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get animationTarget():IAnimationTarget
    {
        return _animationTarget;
    }
    public function set animationTarget(value:IAnimationTarget):void
    {
        _animationTarget = value;
    }
    
    //----------------------------------
    //  playheadTime
    //----------------------------------
    /**
     * @private
     * Storage for the animationTarget property. 
     */
    private var _playheadTime:Number;
    /**
     * The total elapsed time of the Animation, including any startDelay
     * and repetitions. For an Animation playing through its first cycle,
     * this value will equal that of <code>cycleTime</code>/
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get playheadTime():Number
    {
        return _playheadTime;
    }
    public function set playheadTime(value:Number):void
    {
        seek(value, true);
    }
    /**
     * This variable indicates whether the animation is currently
     * running or not. The value is <code>false</code> unless the animation
     * has been played and not yet stopped (either programmatically or
     * automatically) or paused.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get isPlaying():Boolean
    {
        return _isPlaying;
    }
    
    /**
     * The length of time, in milliseconds, that this animation will run,
     * not counting any repetitions by use of <code>repeatCount</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var duration:Number;

    //----------------------------------
    //  repeatBehavior
    //----------------------------------
    /**
     * @private
     * Storage for the repeatBehavior property. 
     */
    private var _repeatBehavior:String = RepeatBehavior.LOOP;
    /**
     * Sets the behavior of a repeating animation (an animation
     * with <code>repeatCount</code> equal to either 0 or >1). This
     * value should be either <code>RepeatBehavior.LOOP</code>, where the animation
     * will repeat in the same order each time, or 
     * <code>RepeatBehavior.REVERSE</code>,
     * where the animation will reverse direction each iteration.
     * 
     * @param value A String describing the behavior, either
     * RepeatBehavior.LOOP or RepeatBehavior.REVERSE
     * 
     * @default RepeatBehavior.LOOP
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    private var _repeatCount:int = 1;
    /**
     * Number of times that this animation will repeat. A value of
     * 0 means that it will repeat indefinitely.
     * 
     * @param value Number of repetitions for this animation, with 0 being
     * an infinitely repeating animation. This value must be >= 0.
     * 
     * @default 1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function set repeatCount(value:int):void
    {
        _repeatCount = value;
    }
    public function get repeatCount():int
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var interpolator:IInterpolator = null;
    
    //----------------------------------
    //  cycleTime
    //----------------------------------

    private var _cycleTime:Number = 0;
    /**
     *  @private
     *  The current millisecond position in the current cycle animation.
     *  This value is between 0 and <code>duration</code>.
     *  An animation 'cycle' is defined as a single repetition of the animation,
     *  where the <code>repeatCount</code> property defines the number of
     *  cycles that will be played.
     *  Use the seek() method to change the position of the animation.
     */
    public function get cycleTime():Number
    {
        return _cycleTime;
    }

    
    //----------------------------------
    //  cycleFraction
    //----------------------------------

    private var _cycleFraction:Number;
    /**
     *  @private
     *  The current fraction elapsed in the animation, after easing
     *  has been applied. This value is between 0 and 1.
     *  An animation 'cycle' is defined as a single repetition of the animation,
     *  where the <code>repeatCount</code> property defines the number of
     *  cycles that will be played.
     */
    public function get cycleFraction():Number
    {
        return _cycleFraction;
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
     * eased elapsed fraction every time an animation event occurs. A value
     * of <code>null</code> will be interpreted as meaning no easing is
     * desired, which is equivalent to using a Linear ease, or
     * <code>animation.easer = Linear.getInstance();</code>.
     * 
     * @default Sine(.5)
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    private static function addAnimation(animation:Animation):void
    {
        animation.id = activeAnimations.length;
        
        activeAnimations.push(animation);
        
        if (!timer)
        {
            Timeline.pulse();
            timer = new Timer(TIMER_RESOLUTION);
            timer.addEventListener(TimerEvent.TIMER, timerHandler);
            timer.start();
        }
        
        intervalTime = Timeline.currentTime;

        animation.startTime = animation.cycleStartTime = intervalTime;
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
            intervalTime = NaN;
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
        intervalTime = Timeline.pulse();
        
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
        while (delayedStartAnims.length > 0)
        {
            // This loop will either start() an animation, which removes it
            // from delayedStartAnims, or it will break out. In either case,
            // we only check against the first item in the list each time
            // through because any previous iteration will have removed the
            // item that was at index 0
            var anim:Animation = Animation(delayedStartAnims[0]);
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
            
            var currentTime:Number = intervalTime - cycleStartTime;
            _playheadTime = intervalTime - startTime;
            if (currentTime >= duration && 
                (repeatCount == 0 || numRepeats < repeatCount))
            {
                // TODO (chaase): this assumes we've only gone through one cycle since
                // last time...
                if (repeatCount != 0)
                    if (!_doSeek)
                        numRepeats++;
                    else
                        numRepeats = 1 + currentTime / (duration + repeatDelay);
                if (repeatDelay == 0) {
                    cycleStartTime += duration;
                    currentTime = intervalTime - cycleStartTime;
                    if (repeatBehavior == RepeatBehavior.REVERSE)
                        _invertValues = !_invertValues;
                    repeated = true;
                }
                else
                {
                    if (_doSeek)
                    {
                        _cycleTime = currentTime % (duration + repeatDelay);
                        if (_cycleTime > duration)
                            _cycleTime = duration; // must be in repeatDelay phase
                        calculateValue(_cycleTime);
                        sendUpdateEvent();
                        return false;
                    }
                    else
                    {
                        // repeatDelay: send out a final update for this cycle with the
                        // end value, then schedule a timer to wake up and
                        // start the next cycle
                        _cycleTime = duration;
                        calculateValue(_cycleTime);
                        sendUpdateEvent();
                        removeAnimation(this);
                        var delayTimer:Timer = new Timer(repeatDelay, 1);
                        delayTimer.addEventListener(TimerEvent.TIMER, repeat);
                        delayTimer.start();
                        return false;
                    }
                }
            }
            _cycleTime = currentTime;
            
            calculateValue(currentTime);

            if (currentTime >= duration)
            {
                end();
                animationEnded = true;
            }
            else
            {
                sendUpdateEvent();
                if (repeated)
                    sendAnimationEvent(EffectEvent.EFFECT_REPEAT);
            }
        }
        return animationEnded;
    }
    
    /**
     * Utility function for dispatching an update event to the 
     * animationTarget. This is a separate function for performance
     * reasons; don't want to bother switching on the event type for the
     * common case of update events.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    private function sendUpdateEvent():void
    {
        if (_animationTarget)
            _animationTarget.animationUpdate(this);
    }

    /**
     * Utility function for dispatching a specified event to
     * the animationTarget.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    private function sendAnimationEvent(eventType:String):void
    {
        if (_animationTarget)
            switch (eventType) {
                case EffectEvent.EFFECT_START:
                    _animationTarget.animationStart(this);
                    break;
                case EffectEvent.EFFECT_END:
                    _animationTarget.animationEnd(this);
                    break;
                case EffectEvent.EFFECT_REPEAT:
                    _animationTarget.animationRepeat(this);
                    break;
                case EffectEvent.EFFECT_UPDATE:
                    // here for completeness; usually handled in sendUpdateEvent
                    _animationTarget.animationUpdate(this);
                    break;
            }
    }
    
    /**
     * @private
     * 
     * Calculates all values for this animation for the elapsed time
     */
    private function calculateValue(currentTime:Number):void
    {
        var i:int;
        
        currentValue = new Object();
        if (duration == 0)
        {
            for (i = 0; i < motionPaths.length; ++i)
                currentValue[motionPaths[i].property] = motionPaths[i].
                    keyframes[motionPaths[i].keyframes.length - 1].value;
            return;
        }
    
        if (_invertValues)
            currentTime = duration - currentTime;
    
        _cycleFraction = easer.ease(currentTime/duration);

        if (motionPaths)
            for (i = 0; i < motionPaths.length; ++i)
                currentValue[motionPaths[i].property] = 
                    motionPaths[i].getValue(_cycleFraction);
    }

    /**
     * Remove this animation from the list of pending animations,
     * as appropriate
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function end():void
    {
        if (id >= 0 || duration == 0)
        {
            // TODO (chaase): Check whether we already send out a final
            // UPDATE event with the end value; if so, this dup should be
            // removed
            // TODO (chaase): this will snap paused and startDelayed animations
            // to their end values. Seems correct, but should check this.
            calculateValue(duration);
            
            sendUpdateEvent();
            sendAnimationEvent(EffectEvent.EFFECT_END);
        }

        // The rest of what we need to do is handled by the stop() function
        stop();
    }
    
    private function addToDelayedAnimations(timeToDelay:Number):void
    {
        // Run timer if it's not currently running
        if (!timer)
        {
            Timeline.pulse();
            timer = new Timer(TIMER_RESOLUTION);
            timer.addEventListener(TimerEvent.TIMER, timerHandler);
            timer.start();
        }
        var animStartTime:int = Timeline.currentTime + timeToDelay;
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

    /**
     * Start the animation. If the animation is already playing, it
     * will be stopped first, then played.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function play():void
    {
        // stop an already-playing animation first
        stop();
        
        if (startDelay > 0)
            addToDelayedAnimations(startDelay);
        else
            start();
    }
    
    /**
     *  Advances the animation effect to the specified position. 
     *
     *  @param playheadTime The position, in milliseconds, between 0
     *  and the value of the <code>duration</code> property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function seek(playheadTime:Number, includeStartDelay:Boolean = false):void
    {
        // Set value between 0 and duration
        //playheadTime = Math.min(Math.max(playheadTime, 0), duration);
        
        // Reset the start time
        // TODO (chaase): Redundant for cases that set this again below
        // Should only do this for playing animation, as the stopped animations
        // do it for themselves
        startTime = cycleStartTime = intervalTime - playheadTime;
        _doSeek = true;
        
        if (!_isPlaying)
        {
            intervalTime = Timeline.currentTime;
            // TODO: comments...
            if (includeStartDelay && startDelay > 0)
            {
                if (delayedStartTimes[this])
                {
                    // TODO (chaase): refactor removal/addition into utility functions
                    // Still sleeping - reduce the delay time by the seek time
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
                    var postDelaySeekTime:Number = playheadTime - startDelay;
                    if (postDelaySeekTime < 0)
                    {
                        animPendingTime = intervalTime + (startDelay - playheadTime);
                        // add it back into the array in the proper order
                        var insertIndex:int = -1;
                        for (i = 0; i < delayedStartAnims.length; ++i)
                        {
                            if (animPendingTime < delayedStartTimes[delayedStartAnims[i]])
                            {
                                insertIndex = i;
                                break;
                            }
                        }
                        if (insertIndex >= 0)
                            delayedStartAnims.splice(insertIndex, 0, this);
                        else
                            delayedStartAnims.push(this);
                        delayedStartTimes[this] = animPendingTime;
                        return;
                    }
                    else
                    {
                        // reduce seek time by startTime; we will go ahead and
                        // seek into the now-playing animation by that much
                        playheadTime -= startDelay;
                        start();
                        startTime = cycleStartTime = intervalTime - playheadTime;
                        doInterval();
                        _doSeek = false;
                        return;
                    }
                }
            }
            // start/end values only valid after animation starts 
            sendAnimationEvent(EffectEvent.EFFECT_START);
            setupInterpolation();
            startTime = cycleStartTime = intervalTime - playheadTime;
        }
        doInterval();
        _doSeek = false;
    }

    /**
     * Sets up interpolation for the animation. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    private function setupInterpolation():void
    {
        if (interpolator && motionPaths)
            for (var i:int = 0; i < motionPaths.length; ++i)
                motionPaths[i].interpolator = interpolator;
    }
 
    /**
     *  Plays the effect in reverse,
     *  starting from the current position of the effect.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function reverse():void
    {
        if (_isPlaying)
        {
            _doReverse = false;
            seek(duration - _cycleTime);
            _invertValues = !_invertValues;
        }
        else
        {
            _doReverse = !_doReverse;
        }
    }
    
    /**
     * Pauses the effect until the <code>resume()</code> method is called.
     * If <code>stop()</code> is called before <code>resume()</code>, then
     * the animation cannot be resumed.
     * 
     * @see resume()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function pause():void
    {
        var animPendingTime:Number = delayedStartTimes[this];
        if (!isNaN(animPendingTime))
        {
            delayTime = animPendingTime - Timeline.currentTime;
            removeFromDelayedAnimations();
        }
        _isPlaying = false;
    }

    /**
     *  Stops the animation, ending it without dispatching an event or calling
     *  the Animation's <code>end()</code> function. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function resume():void
    {
        _isPlaying = true;

        if (delayTime >= 0)
        {
            addToDelayedAnimations(delayTime);
        }
        else
        {
            cycleStartTime = intervalTime - _cycleTime;
            startTime = intervalTime - _playheadTime;
            if (_doReverse)
            {
                reverse();
                _doReverse = false;
            }
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
        if (repeatBehavior == RepeatBehavior.REVERSE)
            _invertValues = !_invertValues;
        calculateValue(0);
        // TODO (chaase): Make sure we're not already sending out an UPDATE
        // event with this value
        sendUpdateEvent();
        sendAnimationEvent(EffectEvent.EFFECT_REPEAT);
        Animation.addAnimation(this);
    }
    
    /**
     * Called by play() or by a Timer, if startDelay is nonzero. This
     * method initializes any necessary default state and adds the animation
     * to the list of active animations, which starts it actually running.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    private function start(event:TimerEvent = null):void
    {
        // actualStartTime accounts for overrun in desired startDelay
        var actualStartTime:int = 0;
        
        // TODO (chaase): call removal utility instead of this code
        // Make sure to remove any references on the delayed lists
        for (var i:int = 0; i < delayedStartAnims.length; ++i)
        {
            if (this == delayedStartAnims[i])
            {
                var animStartTime:int = int(delayedStartTimes[this]);
                var overrun:int = Timeline.currentTime - animStartTime;
                if (overrun > 0)
                    actualStartTime = Math.min(overrun, duration);
                delete delayedStartTimes[this];
                delayedStartAnims.splice(i, 1);
                break;
            }
        }
        numRepeats = 1;
        sendAnimationEvent(EffectEvent.EFFECT_START);
        
        // start/end values may be changed by Animate (set dynamically),
        // so now we set up our interpolator based on the real values
        setupInterpolation();
        
        calculateValue(0);

        if (duration == 0)
        {
            id = -1; // use -1 to indicate that this animation was never added
            end();
        }
        else
        {
            // TODO (chaase): Make sure we're not already sending out an
            // UPDATE event with this start value
            sendUpdateEvent();
            Animation.addAnimation(this);
            _isPlaying = true;
            if (actualStartTime > 0)
                seek(actualStartTime);
        }
    }

}
}
