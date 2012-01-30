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
    
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.effects.Effect;
import mx.effects.EffectInstance;
import mx.effects.IEffectInstance;
import mx.effects.Sequence;
import mx.effects.Tween;

use namespace mx_internal;

/**
 *  The SequenceInstance class implements the instance class 
 *  for the Sequence effect.
 *  Flex creates an instance of this class when it plays a Sequence effect;
 *  you do not create one yourself.
 *
 *  @see mx.effects.Sequence
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */  
public class SequenceInstance extends CompositeEffectInstance
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
     *  @param target This argument is ignored for Sequence effects.
     *  It is included only for consistency with other types of effects.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function SequenceInstance(target:Object)
    {
        super(target);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var activeChildCount:Number;
    
    /**
     *  @private
     *  Used internally to store the sum of all previously playing effects.
     */
    private var currentInstanceDuration:Number = 0; 
    
    /**
     *  @private
     *  Used internally to track the set of effect instances
     *  that the Sequence is currently playing.
     */
    private var currentSet:Array;
    
    /**
     *  @private
     *  Used internally to track the index number of the current set
     *  of playing effect instances
     */
    private var currentSetIndex:int = -1;
                
    /**
     *  @private 
     */
    private var startTime:Number = 0;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  durationWithoutRepeat
    //----------------------------------

    /**
     *  @private
     */
    override mx_internal function get durationWithoutRepeat():Number
    {
        var _duration:Number = 0;
        
        var n:int = childSets.length;
        for (var i:int = 0; i < n; i++)
        {
            var instances:Array = childSets[i];
            _duration += instances[0].actualDuration;
        }
        
        return _duration;
    }

    /**
     * @inheritDoc
     * 
     * In a Sequence effect, <code>playheadTime</code> determines 
     * which child effect should be the active one and sets the 
     * appropriate <code>playheadTime</code> in that effect.
     * Previous effects in the sequence will be ended (if playing) or 
     * skipped (if not yet started but <code>playheadTime</code> is past the time
     * when they would have ended). Note that 'skipping' a child effect may
     * entail playing it with zero duration to avoid side-effects that may
     * occur from not playing the effect at all.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function set playheadTime(value:Number):void
    {
        var prevPlayheadTime:Number = playheadTime;
        // Seek in the SequenceInstance itself, which advances the
        // Tween timer running on the effect
        super.playheadTime = value;
        /*
        * Behavior of this command depends on what state we're in:
        * - if we're in a startDelay, then cut down the playheadTime by
        * the amount of time we have left to sleep
        * - if the playheadTime doesn't get us past the startDelay, then
        * reduce the amount of startDelay appropriately and return
        * - if the playheadTime is greater than the current playheadTime
        *   - if the playheadTime puts the sequence into a different
        *   child effect, end the currently playing child effect,
        *   play intervening ones with no duration (or skip?),
        *   and start the ones that should be active and set their
        *   playheadTime appropriately
        *   - if the playheadTime is still in the currently playing effects
        *   just set the appropriate playheadTime in that effect
        * - else the playheadTime is less than the current time
        *   - if the playheadTime is still in the currently playing effect
        *   just set the appropriate playheadTime in the current effect
        *   - else end the currently playing effect and start over from
        *   the beginning (playing effects with no duration or skipping,
        *   then playing and setting the appropriate playheadTime for 
        *   the correct child effect)
        */
        var compositeDur:Number = Sequence(effect).compositeDuration;
        var firstCycleDur:Number = compositeDur + startDelay + repeatDelay;
        var laterCycleDur:Number = compositeDur + repeatDelay;
        // totalDur is only sensible/used when repeatCount != 0
        var totalDur:Number = firstCycleDur + laterCycleDur * (repeatCount - 1);
        var childPlayheadTime:Number;
        if (value <= firstCycleDur)
        {
            childPlayheadTime = Math.min(value - startDelay, compositeDur);
            playCount = 1;
        }
        else
        {
            if (value >= totalDur && repeatCount != 0)
            {
                childPlayheadTime = compositeDur;
                playCount = repeatCount;
            }
            else
            {
                var valueAfterFirstCycle:Number = value - firstCycleDur;
                childPlayheadTime = valueAfterFirstCycle % laterCycleDur;
                childPlayheadTime = Math.min(childPlayheadTime, compositeDur);
                playCount = 1 + valueAfterFirstCycle / laterCycleDur;
            }
        }
        
        if (childPlayheadTime < prevPlayheadTime)
        {
            // FIXME (chaase): Handle seeking back in time
            // idea: Maybe once we get playing a sequence in reverse
            // working perfectly, seeking back in time should essentially 
            // 'play' (with zero duration) the child effects in reverse until
            // we get to the proper effect for the seek time
        }
        else
        {
            // figure out if desired time is in currently playing effects
            // if so, just seek them to the time
            // else, end them, skip later effects, and play/seek the
            // appropriate child effects
            if (activeEffectQueue && activeEffectQueue.length > 0)
            {
                // If we end up skipping past all child effects, then 
                // finish this Sequence effect when we're done
                var finishWhenDone:Boolean = repeatCount == 0 ? 
                    false :
                    value >= totalDur;
                var cumulativeDuration:Number = 0;
                for (var i:int = 0; i < activeEffectQueue.length; ++i)
                {
                    var instances:Array = childSets[i];
                    var startTime:Number = cumulativeDuration;
                    var endTime:Number = cumulativeDuration + 
                        instances[0].actualDuration;
                    if (childPlayheadTime < endTime)
                    {
                        finishWhenDone = false;
                        // These are the effects that should be active
                        // simply seek to the right time in the effect
                        if (currentSetIndex != i)
                        {
                            currentSetIndex = i;
                            playCurrentChildSet();
                        }
                        for (var k:int = 0; k < instances.length; k++)
                            instances[k].playheadTime = (childPlayheadTime - startTime);
                        break;
                        // otherwise, skip to the next instance
                    }
                    else
                    {
                        // setting endEffectCalled works around a side-effect
                        // of the onEffectEnd() handler where it will
                        // automatically launch the next child effect
                        endEffectCalled = true;

                        // if we're seeking past the currently playing
                        // instance, end it
                        if (currentSetIndex == i)
                        {
                            for (var j:int = 0; j < instances.length; j++)
                                instances[j].end();
                        }
                        else
                        {
                            // more child effects to go: set up currentSet vars
                            // to point to the appropriate ones
                            currentSetIndex = i;
                            var nextInstances:Array = activeEffectQueue[currentSetIndex];                                
                            currentSet = [];
                            var childEffect:EffectInstance;
                            for (var l:int = 0; l < nextInstances.length; l++)
                            {
                                childEffect = nextInstances[l];                                    
                                currentSet.push(childEffect);
                            }
                            // Skip past effects by playing them with no duration
                            for (l = 0; l < instances.length; l++)
                                instances[l].playWithNoDuration();
                        }
                        endEffectCalled = false;
                    }
                    cumulativeDuration = endTime;
                }
                if (finishWhenDone)
                {
                    finishRepeat();
                    currentSetIndex = -1;
                }
                    
            }
        }
    }

    
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
        // Create a new queue.
        activeEffectQueue = [];

        // Start at the beginning or the end
        // depending if we are playing backwards.
        currentSetIndex = playReversed ? childSets.length : -1;
        
        var n:int;
        var i:int;
        var m:int;
        var j:int;
        
        // Each childSets contains an instance of an effect for each target.
        // Flatten these instances into the effectQueue.
        // Put a null object between each effect so that the sequence knows
        // when to stop and wait for the previous instances to finish. 
        n = childSets.length;
        for (i = 0; i < n; i++)
        {
            var instances:Array = childSets[i];
            activeEffectQueue.push(instances);
        }
                
        // Dispatch an effectStart event from the target.
        super.play();

        startTime = Tween.intervalTime;
        
        if (activeEffectQueue.length == 0)
        {
             finishRepeat();
             return;
        }

        playNextChildSet();
    }
    
    /**
     *  @private
     */
    override public function pause():void
    {   
        super.pause();
        
        if (currentSet && currentSet.length > 0)
        {
            var n:int = currentSet.length;
            for (var i:int = 0; i < n; i++)
            {
                currentSet[i].pause();
            }
        }
    }

    /**
     *  @private
     */
    override public function stop():void
    {
        if (activeEffectQueue && activeEffectQueue.length > 0)
        {
            var queueCopy:Array = activeEffectQueue.concat();
            activeEffectQueue = null;
            
            // Call stop on the currently playing set
            if (currentInstances)
            {
                var currentInstances:Array = queueCopy[currentSetIndex];
                var currentCount:int = currentInstances.length;
                
                for (var i:int = 0; i < currentCount; i++)
                    currentInstances[i].stop();
            }

            // For instances that have yet to run, we will delete them
            // without dispatching events.
            // (Another alternative would have been add them into
            // currentInstances and currentSet, then just stop them
            // along with the others. In this case, they would have
            // dispatched effectEnd events).
            var n:int = queueCopy.length;
            for (var j:int = currentSetIndex + 1; j < n; j++)
            {
                var waitingInstances:Array = queueCopy[j];
                var m:int = waitingInstances.length;
                
                for (var k:int = 0; k < m; k++)
                {
                    var instance:IEffectInstance = waitingInstances[k];
                    instance.effect.deleteInstance(instance);
                }
            }
        }
        
        super.stop();
    }   

    /**
     *  @private
     */
    override public function resume():void
    {
        super.resume();
        
        if (currentSet && currentSet.length > 0)
        {
            var n:int = currentSet.length;
            for (var i:int = 0; i < n; i++)
            {
                currentSet[i].resume();
            }
        }
    }
                
    /**
     *  @private
     */
    override public function reverse():void
    {
        super.reverse();
        
        if (currentSet && currentSet.length > 0)
        {
            // PlayNextChildSet handles the logic of playing previously completed effects
            var n:int = currentSet.length;
            for (var i:int = 0; i < n; i++)
            {
                currentSet[i].reverse();
            }
        }
    }
    
    /**
     *  Interrupts any effects that are currently playing, skips over
     *  any effects that haven't started playing, and jumps immediately
     *  to the end of the composite effect.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function end():void
    {
        endEffectCalled = true;
        
        // activeEffectQueue are all effects to play
        // currentSetIndex is where we want to start
        // if play() hasn't been called on us yet (b/c of startDelay), 
        // activeEffectQueue will have nothing in it.  In this case,
        // we leave the component in it's current state, rather than 
        // call .playWithNoDuration() on all the effects that haven't 
        // been run (or even added to the activeEffectQueue yet)
        if (activeEffectQueue && activeEffectQueue.length > 0)
        {
            var queueCopy:Array = activeEffectQueue.concat();
            activeEffectQueue = null;
            
            // Call end on the currently playing set
            var currentInstances:Array = queueCopy[currentSetIndex];
            if (currentInstances)
            {
                var currentCount:int = currentInstances.length;                
                for (var i:int = 0; i < currentCount; i++)
                {
                    currentInstances[i].end();
                }
            }
            
            var n:int = queueCopy.length;
            for (var j:int = currentSetIndex + 1; j < n; j++)
            {
                var waitingInstances:Array = queueCopy[j];
                var m:int = waitingInstances.length;
                
                for (var k:int = 0; k < m; k++)
                {
                    EffectInstance(waitingInstances[k]).playWithNoDuration();
                }
            }
        }
        
        super.end();
    }

    /**
    *  Each time a child effect of SequenceInstance finishes, 
    *  Flex calls the <code>onEffectEnd()</code> method.
    *  For SequenceInstance, it plays the next effect.
    *  This method implements the method of the superclass.
    *
    *  @param childEffect The child effect.
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    override protected function onEffectEnd(childEffect:IEffectInstance):void
    {
        // Each child effect notifies us when it is finished.
        // Remove the notifying child from childSets,
        // so that the end() method doesn't call it.
        // When the last child notifies us that it's finished,
        // notify our listener that we're finished.
        // Resume the background processing that was suspended earlier
        if (Object(childEffect).suspendBackgroundProcessing)
            UIComponent.resumeBackgroundProcessing();
        
        for (var i:int = 0; i < currentSet.length; i++)
        {
            if (childEffect == currentSet[i])
            {
                currentSet.splice(i, 1);
                break;
            }
        }   
        
        // See endEffect, above.
        if (endEffectCalled)
            return; 
        
        if (currentSet.length == 0)
        {
            if (false == playNextChildSet())
                finishRepeat();
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    private function playCurrentChildSet():void
    {
        var childEffect:EffectInstance;
        var instances:Array = activeEffectQueue[currentSetIndex];
        
        currentSet = [];
        
        for (var i:int = 0; i < instances.length; i++)
        {
            childEffect = instances[i];
            
            currentSet.push(childEffect);
            childEffect.playReversed = playReversed;
            // Block all layout, responses from web services, and other
            // background processing until the effect finishes executing.
            if (childEffect.suspendBackgroundProcessing)
                UIComponent.suspendBackgroundProcessing();  
            childEffect.startEffect();
        }
        
        currentInstanceDuration += childEffect.actualDuration;
        
    }
    
    /**
     *  @private
     */
    private function playNextChildSet(offset:Number = 0):Boolean
    {
        if (!playReversed)
        {
            if (!activeEffectQueue ||
                currentSetIndex++ >= activeEffectQueue.length - 1)
            {
                return false;
            }
        }
        else
        {
            if (currentSetIndex-- <= 0)
                return false;
        }
    
        playCurrentChildSet();
        
        return true;
    }
}

}
