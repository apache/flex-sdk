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

import mx.core.mx_internal;
import mx.events.EffectEvent;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;

import spark.effects.KeyFrame;
import spark.effects.SimpleMotionPath;
import spark.effects.easing.IEaser;
import spark.effects.easing.Linear;
import spark.effects.easing.Sine;
import spark.effects.interpolation.ArrayInterpolator;
import spark.effects.interpolation.IInterpolator;
import spark.effects.interpolation.NumberInterpolator;

use namespace mx_internal;

[DefaultProperty("motionPaths")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[ResourceBundle("sparkEffects")]

/**
 *  The Animation class defines an animation that happens between 
 *  the start and end values of a property over a specified period of time.
 *  The animation can be a change in position, such as performed by
 *  the Move effect; a change in size, as performed by the Resize effect;
 *  a change in visibility, as performed by the Fade effect; or other 
 *  types of animations used by effects or run directly with the Animation class.
 *
 *  <p>This class defines the timing and value parts of the animation. 
 *  Other code, either in effects or in application code, associates the animation
 *  with target objects and properties, such that the animated values produced by
 *  Animation class can then be applied to target objects and properties to actually
 *  cause these objects to animate.</p>
 *
 *  <p>When defining animation effects, you typically create an
 *  instance of the Animate class, or of a subclass of Animate. This creates
 *  an Animation instance in the <code>play()</code> method. The Animation instance
 *  accepts start and end values, a duration, and optional parameters such as
 *  easer and interpolator objects.</p>
 * 
 *  <p>The Animation object calls event listeners at the start and end of the animation,
 *  when the animation repeats, and at regular update intervals during
 *  the animation. These calls pass values which the Animation instance calculated from
 *  the start and end values and the easer and interpolator objects. These
 *  values can then be used to set property values on target objects.</p>
 *
 *  @see spark.effects.Animate
 *  @see spark.effects.supportClasses.AnimateInstance
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
     *  Constructor. 
     *  The optional <code>property</code>, <code>startValue</code>, and 
     *  <code>endValue</code> parameters define a simple
     *  animation with a single MotionPath object with two KeyFrames. 
     *  If either value is non-null,
     *  <code>startValue</code> becomes the <code>value</code> of the
     *  first keyframe, at time=0, and 
     *  <code>endValue</code> becomes the <code>value</code> of 
     *  the second keyframe, at the end of the animation.
     * 
     *  @param duration The length of the animation, in milliseconds.
     *
     *  @param property The property to animate.
     * 
     *  @param startValue The initial value of the property.
     *
     *  @param endValue The final value of the property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function Animation(duration:Number = 500, property:String = null,
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
     *  An Array of the values as of the current frame of the Animation.
     *  The values are stored as map values, using property names as the key.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var currentValue:Object;

    /**
     *  The set of MotionPath objects that define the properties and values
     *  that the Animation will animate over time.
     *
     *  @see spark.effects.MotionPath
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  The IAnimationTarget object notified with all
     *  start, end, repeat, and update events for this animation.
     *  A value of <code>null</code> indicates that there is no target 
     *  to notify.
     * 
     *  @default null
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
     *  The total elapsed time of the animation, including any start delay
     *  and repetitions. For an animation playing through its first cycle,
     *  this value will equal that of <code>cycleTime</code>.
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
     *  If <code>true</code>, the animation is currently playing.
     *  The value is <code>false</code> unless the animation
     *  has been played and not yet stopped (either programmatically or
     *  automatically) or paused.
     *
     *  @default false
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
     *  The length of time, in milliseconds, of the animation,
     *  not counting any repetitions defined by 
     *  the <code>repeatCount</code> property.
     * 
     * @default 500
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var duration:Number = 500;

    //----------------------------------
    //  repeatBehavior
    //----------------------------------
    /**
     * @private
     * Storage for the repeatBehavior property. 
     */
    private var _repeatBehavior:String = RepeatBehavior.LOOP;
    /**
     *  Sets the behavior of a repeating animation.
     *  A repeating animation has the 
     *  <code>repeatCount</code> property set to 0 or to a value greater than 1. 
     *  This value should be either <code>RepeatBehavior.LOOP</code>, 
     *  meaning the animation repeats in the same order each time, or 
     *  <code>RepeatBehavior.REVERSE</code>,
     *  meaning the animation reverses direction for each iteration.
     * 
     *  @default RepeatBehavior.LOOP
     *
     *  @see spark.effects.animation.RepeatBehavior
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
     *  The number of times that this animation repeats. 
     *  A value of 0 means that it repeats indefinitely.
     * 
     *  @default 1
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
     *  The amount of time, in milliseconds, to delay before each repetition cycle
     *  begins. Setting this value to a non-zero number 
     *  ends previous animation cycle exactly at  its end value
     *  However, non-delayed repetitions may skip over that 
     *  value completely as the animation transitions smoothly from being
     *  near the end of one cycle to being past the beginning of the next.
     *  This property must be a value &gt;= 0.
     *
     *  <p>This property is used for the first repetition
     *  after the first animation cycle. 
     *  To delay the first cycle of the animation, use
     *  the <code>startDelay</code> property. </p>
     *
     *  @see #startDelay
     * 
     *  @default 0
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
     *  The amount of time spent waiting before the animation
     *  begins.
     *  This property must be a value &gt;= 0.
     * 
     *  @default 0
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
     *  The interpolator used by the Animation instance to calculate values between
     *  the start and end values of the property. 
     *  By default, the class uses the NumberInterpolator class or, 
     *  in the case of the start and end values being arrays, 
     *  by the ArrayInterpolator class.
     *  Interpolation of other data types, or of Numbers that should be interpolated
     *  differently, such as <code>uint</code> values that hold color
     *  channel information, can be handled by supplying a different
     *  interpolator.
     *
     *  @see spark.effects.interpolation.NumberInterpolator
     *  @see spark.effects.interpolation.ArrayInterpolator
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
     *  The easing behavior for this effect. 
     *  This IEaser object is used to convert the elapsed fraction of the animation 
     *  into an eased fraction, which is then used to calculate 
     *  the value at that eased elapsed fraction. 
     * 
     *  <p>A value of <code>null</code> means no easing is
     *  used, which is equivalent to using a Linear ease, or
     *  <code>animation.easer = Linear.getInstance();</code>.</p>
     * 
     *  @default Sine(.5)
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
    /**
     *  @private
     */
    public function set easer(value:IEaser):void
    {
        if (!value)
        {
            value = Linear.getInstance();
        }
        _easer = value;
    }
    
    // TODO: rethink reversal
    /**
     *  If <code>true</code>, play the animation in reverse.
     *
     *  @default false
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get playReversed():Boolean
    {
        return _invertValues;
    }
    /**
     *  @private
     */
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
     *  Adds a new animation instance to the system. 
     *  All animations run off the same Timer instance, 
     *  so starting any one animation simply adds it onto the
     *  static list of active animations.
     *
     *  @param animation The Animation object.
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
     *  Interrupt the animation, jumps immediately to the end of the animation, 
     *  and invokes the event handler for the <code>effectEnd</code> event on the target.
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
     *  Start the animation. 
     *  If the animation is already playing, it
     *  is stopped first, then played.
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
        
        // Make sure the time values in our motion paths are reasonable
        // SimpleMotionPath objects may be set up with no time values, so
        // we have to fill in those values from the duration when necessary
        var i:int;
        var j:int;
        for (i = 0; i < motionPaths.length; ++i)
        {
            var keyframes:Array = motionPaths[i].keyframes;
            if (isNaN(keyframes[0].time))
                keyframes[0].time = 0;
            // Create an initial (time==0) value if necessary 
            else if (keyframes[0].time > 0)
            {
                keyframes.splice(0, 0, new KeyFrame(0, null));
                keyframes[0].timeFraction = 0;
            }
            for (j = 1; j < keyframes.length; ++j)
            {
                if (isNaN(keyframes[j].time))
                    keyframes[j].time = duration;
            }
        }
        for (i = 0; i < motionPaths.length; ++i)
            motionPaths[i].scaleKeyframes(duration);
        
        if (startDelay > 0)
            addToDelayedAnimations(startDelay);
        else
            start();
    }
    
    /**
     *  Advances the animation to the specified position. 
     *
     *  @param playheadTime The position, in milliseconds, between 0
     *  and the value of the <code>duration</code> property.
     *
     *  @param includeStartDelay Set to <code>true</code> if there is 
     *  a start delay on the effect, as defined by the 
     *  <code>startDelay</code> property.
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
     *  Sets up interpolation for the animation. 
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
     *  Plays the effect in reverse,if the effect is currently playing,
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
     *  Pauses the effect until the <code>resume()</code> method is called.
     *  If <code>stop()</code> is called before <code>resume()</code>, then
     *  the animation cannot be resumed.
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
     *  the <code>end()</code> method. 
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
            _doReverse = false
            _invertValues = false;
            _isPlaying = false;
        }
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
