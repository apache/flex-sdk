////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.effects.effectClasses
{

import flash.events.Event;
import flash.events.TimerEvent;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.utils.Timer;
import mx.core.mx_internal;
import mx.effects.EffectInstance;
import mx.effects.Tween;

use namespace mx_internal;

/**
 *  The SoundEffectInstance class implements the instance class
 *  for the SoundEffect effect.
 *  Flex creates an instance of this class when it plays a SoundEffect effect;
 *  you do not create one yourself.
 *
 *  @see mx.effects.Fade
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */  
public class SoundEffectInstance extends EffectInstance
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  @param target The Object to animate with this effect.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function SoundEffectInstance(target:Object)
    {
        super(target);
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private.
     */
    private var origVolume:Number;
    
    /**
     *  @private.
     */
    private var origPan:Number;
    
    /**
     *  @private.
     */
    private var volumeTween:Tween;
    
    /**
     *  @private.
     */
    private var panTween:Tween;
    
    /**
     *  @private.
     */
    private var soundDuration:Number;
    
    /**
     *  @private.
     */
    private var tweenCount:int = 0;
    
    /**
     *  @private.
     */
    private var intervalID:Number;
    
    /**
     *  @private.
     */
    private var endOnTweens:Boolean = false;
    
    /**
     *  @private.
     */
    private var pausedPosition:Number;
    
    /**
     *  @private.
     */
    private var resumedPosition:Number = 0;
    
    /**
     *  @private.
     */
    private var pausedTransform:SoundTransform;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  totalDuration
    //----------------------------------

    /**
     *  @private
     */
    private function get totalDuration():Number
    {
        if (useDuration)
        {
            return duration;
        }
        else if (sound == null)
        {
            return 0;
        }
        else
        {
            // Include the number of loops .
            var multiplier:int = loops + 1;
            return sound.length * multiplier;
        }
    }
    
    //----------------------------------
    //  bufferTime
    //----------------------------------

    /** 
     *  The SoundEffect class uses an internal Sound object to control
     *  the MP3 file.
     *  This property specifies the minimum number of milliseconds 
     *  worth of sound data
     *  to hold in the Sound object's buffer.
     *  The Sound object waits until it has at least
     *  this much data before beginning playback,
     *  and before resuming playback after a network stall.
     *  
     *  @default 1000
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var bufferTime:Number = 1000;
    
    //----------------------------------
    //  loops
    //----------------------------------

    /**
     *  The number of times to play the sound in a loop, where a value of 
     *  0 means play the effect once, a value of 1 means play the effect twice, 
     *  and so on. If you repeat the MP3 file, it still uses the setting of the 
     *  <code>useDuration</code> property to determine the playback time.
     *
     *  <p>The <code>duration</code> property takes precedence
     *  over this property. 
     *  If the effect duration is not long enough to play the sound at least once, 
     *  the sound does not loop.</p>
     *
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var loops:int = 0;
    
    //----------------------------------
    //  isLoading
    //----------------------------------

    /**
     *  This property is <code>true</code> if the MP3 has been loaded. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get isLoading():Boolean
    {   
        if (!sound)
            return false;
        
        return source is Class ||
               sound.bytesTotal > 0;
    }
    
    //----------------------------------
    //  panEasingFunction
    //----------------------------------

    /**
     *  The easing function for the pan effect.
     *  This function is used to interpolate between the values
     *  of <code>panFrom</code> and <code>panTo</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var panEasingFunction:Function;
    
    //----------------------------------
    //  panFrom
    //----------------------------------

    /**
     *  Initial pan of the Sound object.
     *  The value can range from -1.0 to 1.0, where -1.0 uses only the left channel,
     *  1.0 uses only the right channel, and 0.0 balances the sound evenly
     *  between the two channels.
     *  
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var panFrom:Number;
    
    //----------------------------------
    //  panTo
    //----------------------------------

    /**
     *  Final pan of the Sound object.
     *  The value can range from -1.0 to 1.0, where -1.0 uses only the left channel,
     *  1.0 uses only the right channel, and 0.0 balances the sound evenly
     *  between the two channels.
     *  
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var panTo:Number;
    
    //----------------------------------
    //  soundChannel
    //----------------------------------

    /**
     *  @private
     *  Storage for the soundChannel property.
     */
    private var _soundChannel:SoundChannel;
    
    /**
     *  The SoundChannel object that the MP3 file has been loaded into. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get soundChannel():SoundChannel
    {   
        return _soundChannel;
    }
    
    //----------------------------------
    //  sound
    //----------------------------------

    /** 
     *  Reference to the internal Sound object. The SoundEffect uses this
     *  instance to play the MP3 file.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var sound:Sound;
    
    //----------------------------------
    //  source
    //----------------------------------

    /** 
     *  @private
     *  Storage for the source property.
     */
    private var _source:Object;

    /**
     *  The URL or class of the MP3 file to play.
     *  If you have already embedded the MP3 file, using the
     *  <code>Embed</code> keyword, you can pass the Class object
     *  of the MP3 file to the <code>source</code> property. 
     *  Otherwise, specify the full URL to the MP3 file.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get source():Object
    {
        return _source;
    }

    /** 
     *  @private
     */
    public function set source(value:Object):void
    {
        _source = value;
    }
    
    //----------------------------------
    //  startTime
    //----------------------------------

    /** 
     *  The initial position in the MP3 file, in milliseconds, 
     *  at which playback should start.
     *
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var startTime:Number = 0;
    
    //----------------------------------
    //  useDuration
    //----------------------------------

    /**
     *  If <code>true</code>, stop the effect
     *  after the time specified by the <code>duration</code> 
     *  property has elapsed.
     *  If <code>false</code>, stop the effect
     *  after the MP3 finishes playing or looping.
     *  
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var useDuration:Boolean = true;
    
    //----------------------------------
    //  volumeEasingFunction
    //----------------------------------

    /**
     *  The easing function for the volume effect.
     *  Use this function to interpolate between the values
     *  of <code>volumeFrom</code> and <code>volumeTo</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var volumeEasingFunction:Function;
    
    //----------------------------------
    //  volumeFrom
    //----------------------------------

    /**
     *  Initial volume of the Sound object.
     *  Value can range from 0.0 to 1.0.
     *  
     *  @default 1.0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var volumeFrom:Number;
    
    //----------------------------------
    //  volumeTo
    //----------------------------------

    /**
     *  Final volume of the Sound object.
     *  Value can range from 0.0 to 1.0.
     *  
     *  @default 1.0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var volumeTo:Number; 
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
        
    /**
     *  @private
     */
    override public function play():void
    {
        // Dispatch an effectStart event from the target.
        super.play();
        
        if (!sound)
            return;
        /*
        if (!isLoading && sound)
            sound.load(new URLRequest(source), bufferTime);
        */
        
        var transform:SoundTransform = new SoundTransform();
        
        if (!isNaN(volumeFrom) || !isNaN(volumeTo))
        {
            if (isNaN(volumeFrom))
                volumeFrom = 1;
            else if (isNaN(volumeTo))
                volumeTo = 1;
                        
            transform.volume = volumeFrom;
                
            volumeTween = new Tween(this, volumeFrom, volumeTo, totalDuration);
            
            if (volumeEasingFunction != null)
                volumeTween.easingFunction = volumeEasingFunction;
            
            volumeTween.setTweenHandlers(onVolumeTweenUpdate,
                                         onVolumeTweenEnd);
            
            tweenCount++;
        }
        
        if (!isNaN(panFrom) || !isNaN(panTo))
        {
            if (isNaN(panFrom))
                panFrom = 0;
            else if (isNaN(panTo))
                panTo = 0;
            
            transform.pan = panFrom;    
                
            panTween = new Tween(this, panFrom, panTo, totalDuration);
            
            if (panEasingFunction != null)
                panTween.easingFunction = panEasingFunction;
            
            panTween.setTweenHandlers(onPanTweenUpdate,
                                      onPanTweenEnd);
            
            tweenCount++;
        }
        
        endOnTweens = (tweenCount > 0);
        
        if (useDuration && !endOnTweens)
        {
            var timer:Timer = new Timer(totalDuration, 1);
            timer.addEventListener(TimerEvent.TIMER, durationEndHandler);
            timer.start();
        }
        
        pausedPosition = NaN; // Clear the paused position
        resumedPosition = startTime;
                
        _soundChannel = sound.play(startTime, loops, transform);
        if (soundChannel)
            soundChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
    }

    /**
     *  @private
     */
    override public function pause():void
    {
        super.pause();
        
        if (volumeTween)
            volumeTween.pause();
        if (panTween)
            panTween.pause();       
        if (soundChannel)
        {
            pausedPosition = soundChannel.position; // Save the paused position
            pausedTransform = soundChannel.soundTransform;
            
            soundChannel.stop();
        }
    }

    /**
     *  @private
     */
    override public function stop():void
    {
        super.stop();

        if (volumeTween)
            volumeTween.stop();
        if (panTween)
            panTween.stop();

        if (soundChannel)
            soundChannel.stop();
    }   
    
    /**
     *  @private
     */
    override public function resume():void
    {
        super.resume();
    
        if (volumeTween)
            volumeTween.resume();
            
        if (panTween)
            panTween.resume();  
        
        resumedPosition += pausedPosition;
        
        if (sound)
        {
            _soundChannel = sound.play(resumedPosition, loops, pausedTransform);
            if (soundChannel)
                soundChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
        }
    }
    
    /**
     *  @private
     */
    override public function end():void
    {
        super.end();
        
        pausedPosition = NaN; // Clear the paused position
        resumedPosition = startTime;
        
        if (volumeTween)
            volumeTween.endTween();
        
        if (panTween)
            panTween.endTween();
    }
        
    /**
     *  @private
     */
    override public function finishEffect():void
    {
        if (soundChannel)
            soundChannel.stop();
        
        super.finishEffect();
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    mx_internal function onVolumeTweenUpdate(value:Object):void
    {
        if (soundChannel)
        {
            // Need to reset the soundTransform object in order
            var copyTransform:SoundTransform = soundChannel.soundTransform;
            copyTransform.volume = Number(value);
            soundChannel.soundTransform = copyTransform;
        }
    }

    /**
     *  @private
     */
    mx_internal function onVolumeTweenEnd(value:Object):void
    {
        onVolumeTweenUpdate(value);
        
        finishTween();
    }
    
    /**
     *  @private
     */
    mx_internal function onPanTweenUpdate(value:Object):void
    {
        if (soundChannel)
        {
            // Need to reset the soundTransform object in order
            var copyTransform:SoundTransform = soundChannel.soundTransform;
            copyTransform.pan = Number(value);
            soundChannel.soundTransform = copyTransform;
        }
    }

    /**
     *  @private
     */
    mx_internal function onPanTweenEnd(value:Object):void
    {
        onPanTweenUpdate(value);
        
        finishTween();
    }
    
    /**
     *  @private
     */
    private function finishTween():void
    {
        if (tweenCount == 0 || --tweenCount == 0)
        {
            if (soundChannel)
                soundChannel.stop();

            finishRepeat(); 
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function durationEndHandler(event:TimerEvent):void
    {
        finishTween();
    }
    
    /**
     *  @private
     */
    private function soundCompleteHandler(event:Event):void
    {       
        dispatchEvent(event);
        // We don't have any tweens, so we need to explicitly 
        // tell the effect that we are finished.
        if (!useDuration && !endOnTweens)
            finishTween();
    }

}

}
