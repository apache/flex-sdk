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
    
    /**
     *  @private
     *  Used internally to track when the effect is paused
     */
    private var isPaused:Boolean = false;
    
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
        * - if the playheadTime is still in the currently playing effects
        * just set the appropriate playheadTime in that effect
        * - if the playheadTime puts the sequence into a later
        * child effect, end the currently playing child effect,
        * play and end the intervening ones,
        * start the ones that should be active and set their
        * playheadTime appropriately
        * - else the playheadTime puts the sequence into an earlier child
        * effect. Set the playhead time to 0 in the currently playing child
        * effect and stop it. Play/stop earlier child effects until we get
        * to the one we should be playing. Play it and set playheadTime
        * appropriately
        */
        var i:int, j:int, k:int, l:int;
        var compositeDur:Number = Sequence(effect).compositeDuration;
        var firstCycleDur:Number = compositeDur + startDelay + repeatDelay;
        var laterCycleDur:Number = compositeDur + repeatDelay;
        // totalDur is only sensible/used when repeatCount != 0
        var totalDur:Number = firstCycleDur + laterCycleDur * (repeatCount - 1);
        var iterationPlayheadTime:Number;
        if (value <= firstCycleDur)
        {
            iterationPlayheadTime = Math.min(value - startDelay, compositeDur);
            playCount = 1;
        }
        else
        {
            if (value >= totalDur && repeatCount != 0)
            {
                iterationPlayheadTime = compositeDur;
                playCount = repeatCount;
            }
            else
            {
                var valueAfterFirstCycle:Number = value - firstCycleDur;
                iterationPlayheadTime = valueAfterFirstCycle % laterCycleDur;
                iterationPlayheadTime = Math.min(iterationPlayheadTime, compositeDur);
                playCount = 1 + valueAfterFirstCycle / laterCycleDur;
            }
        }
        
        if (activeEffectQueue && activeEffectQueue.length  > 0)
        {
            // cumulativeDuration is the duration of child effects in this
            // iteration thus far as we walk through the set of child effects
            var cumulativeDuration:Number = 0;
            
            // Step through the child effects in the sequence until we find the
            // set that the requested playheadTime is in
            var activeLength:Number = activeEffectQueue.length;
            for (i = 0; i < activeLength; ++i)
            {
                var setToCompare:int = playReversed ? (activeLength - 1 - i) : i;
                // temp holder for instances that we fast-forward or rewind
                var childEffectInstances:Array;
                // start/end times of current child effect we're looking at
                var startTime:Number = cumulativeDuration;
                var endTime:Number = cumulativeDuration + childSets[setToCompare][0].actualDuration;
                cumulativeDuration = endTime;
                
                // If iterationPlayheadTime is in between the start and end time for this
                // effect, this must be the one we need to seek into
                if (startTime <= iterationPlayheadTime && iterationPlayheadTime <= endTime)
                {
                    // seting endEffectCalled to true keeps the next effect from
                    // being started when we cause one to end. We'll start effects
                    // manually when seeking, instead.
                    endEffectCalled = true;

                    // We're already playing the effect we should seek into
                    if (currentSetIndex == setToCompare)
                    {
                        // Since we're already playing the right effect, just seek
                        for (j = 0; j < currentSet.length; j++)
                            currentSet[j].playheadTime = (iterationPlayheadTime - startTime);
                    }
                    else if (setToCompare < currentSetIndex)
                    {
                        if (playReversed)
                        {
                            // We're currently playing a child effect later than the one we
                            // should seek into. First, rewind and stop the current effect
                            for (j = 0; j < currentSet.length; j++)
                                currentSet[j].end();
                            // Next, play(), then stop() the previous effects back to
                            // the one we want. This will cause these effects to set
                            // values for their target properties at the start
                            // of their animations, which is what we want when seeking
                            // backwards
                            // Next, play/end all child effects before the one we want
                            // This will set the animated properties to their end values.
                            for (j = currentSetIndex - 1; j > setToCompare; --j)
                            {
                                childEffectInstances = activeEffectQueue[j];
                                for (k = 0; k < childEffectInstances.length; k++)
                                {
                                    if (playReversed)
                                        childEffectInstances[k].playReversed = true;
                                    childEffectInstances[k].play();
                                    childEffectInstances[k].end();
                                }
                            }
                        }
                        else
                        {
                            // We're currently playing a child effect later than the one we
                            // should seek into. First, rewind and stop the current effect
                            for (j = 0; j < currentSet.length; j++)
                            {
                                currentSet[j].playheadTime = 0;
                                currentSet[j].stop();
                            }
                            // Next, play(), then stop() the previous effects back to
                            // the one we want. This will cause these effects to set
                            // values for their target properties at the start
                            // of their animations, which is what we want when seeking
                           // backwards
                            for (j = currentSetIndex - 1; j > setToCompare; --j)
                            {
                                childEffectInstances = activeEffectQueue[j];
                                for (k = 0; k < childEffectInstances.length; k++)
                                {
                                    childEffectInstances[k].play();
                                    childEffectInstances[k].stop();
                                }
                            }
                        }
                        // Now, play the right effect and seek into it
                        currentSetIndex = setToCompare;
                        playCurrentChildSet();
                        for (k = 0; k < currentSet.length; k++)
                        {
                            currentSet[k].playheadTime = (iterationPlayheadTime - startTime);
                            if (isPaused)
                                currentSet[k].pause();
                        }
                        //break;
                    }
                    else // setToCompare > currentSetIndex
                    {
                        if (playReversed)
                        {
                            // We're currently playing a child effect later than the one we
                            // should seek into. First, rewind and stop the current effect
                            for (j = 0; j < currentSet.length; j++)
                            {
                                currentSet[j].playheadTime = 0;
                                currentSet[j].stop();
                            }
                            // Next, play/end all child effects before the one we want
                            // This will set the animated properties to their end values.
                            for (k = currentSetIndex + 1; k < setToCompare; k++)
                            {
                                childEffectInstances = activeEffectQueue[k];                          
                                for (l = 0; l < childEffectInstances.length; l++)
                                {
                                    childEffectInstances[l].playheadTime = 0;
                                    childEffectInstances[l].stop();
                                }
                            }                            
                        }
                        else
                        {
                            // We need to seek into a child effect later than the
                            // one we're currently playing. First, end the current effect.
                            var currentEffectInstances:Array = currentSet.concat();
                            for (j = 0; j < currentEffectInstances.length; j++)
                                currentEffectInstances[j].end();
                            
                            // Next, play/end all child effects before the one we want
                            // This will set the animated properties to their end values.
                            for (k = currentSetIndex + 1; k < setToCompare; k++)
                            {
                                childEffectInstances = activeEffectQueue[k];                          
                                for (l = 0; l < childEffectInstances.length; l++)
                                {
                                    childEffectInstances[l].play();
                                    childEffectInstances[l].end();
                                }
                            }
                        }
                        // Finally, set the current child effect and seek into it
                        currentSetIndex = setToCompare;
                        playCurrentChildSet();
                        for (k = 0; k < currentSet.length; k++)
                        {
                            currentSet[k].playheadTime = (iterationPlayheadTime - startTime);
                            if (isPaused)
                                currentSet[k].pause();
                        }
                    }
                    endEffectCalled = false;
                    
                    // We're done, break out of the loop
                    break;
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
        isPaused = false;

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
        isPaused = true;
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
        isPaused = false;
        
        if (activeEffectQueue && activeEffectQueue.length > 0)
        {
            var queueCopy:Array = activeEffectQueue.concat();
            activeEffectQueue = null;
            
            // Call stop on the currently playing set
            var currentInstances:Array = queueCopy[currentSetIndex];
            if (currentInstances)
            {
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
        isPaused = false;
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
        isPaused = false;
        
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
