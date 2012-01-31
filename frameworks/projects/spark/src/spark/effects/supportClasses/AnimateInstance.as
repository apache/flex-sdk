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

package mx.effects.effectClasses
{
import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.components.Group;
import mx.effects.Animation;
import mx.effects.PropertyValuesHolder;
import mx.effects.easing.IEaser;
import mx.effects.interpolation.IInterpolator;
import mx.events.AnimationEvent;

import mx.core.UIComponent;
import mx.effects.EffectInstance;
import mx.effects.EffectManager;
import mx.styles.IStyleClient;

/**
 * The AnimateInstance class implements the instance class for the
 * Animate effect. Flex creates an instance of this class when
 * it plays a Animate effect; you do not create one yourself.
 */
public class FxAnimateInstance extends EffectInstance
{
    public var animation:Animation;
    
    public function FxAnimateInstance(target:Object)
    {
        super(target);
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    /**
     *  Tracks whether each property of the target is an actual 
     *  property or a style. We determine this dynamically by
     *  simply checking whether the property is 'in' the target.
     *  If not, we check whether it is a valid style, and otherwise
     *  throw an error.
     */
    private var isStyleMap:Object = new Object();
    
    /**
     *  @private.
     *  Used internally to hold the value of the new playhead position
     *  if the tween doesn't currently exist.
     */
    private var _seekTime:Number = 0;

    private var reverseAnimation:Boolean;
    
    private var needsRemoval:Boolean;
    
    //--------------------------------------------------------------------------
    //
    // Properties
    //
    //--------------------------------------------------------------------------

    /**
     * An array of PropertyValuesHolder objects, each of which holds the
     * name of the property being animated and the values that the property
     * will take on during the animation.
     */
    public var propertyValuesList:Array;
    
    /**
     * This flag indicates whether values should be rounded before set on
     * the targets. This can be useful in situations where values resolve to
     * pixel coordinates and snapping to pixels is desired over landing
     * on fractional pixels.
     */
    protected var roundValues:Boolean;

    /**
     * This flag indicates whether the effect changes properties which are
     * potentially related to the various layout constraints that may act
     * on the object. Setting this to true will cause the effect to disable
     * all standard constraints (left, right, top, bottom, horizontalCenter,
     * verticalCenter) for the duration of the animation, and re-enable them
     * when the animation is complete.
     */ 
    protected var affectsConstraints:Boolean;

    /**
     * This flag indicates whether a subclass would like their target to 
     * be automatically kept around during a transition and removed when it
     * finishes. This capability applies specifically to effects like
     * Fade which act on targets that go away at the end of the
     * transition and removes the need to supply a RemoveAction or similar
     * effect to manually keep the item around and remove it when the
     * transition completes. In order to use this capability, subclasses
     * should set this variable to true and also expose the "parent"
     * and "elementHost" properties in their affectedProperties array so 
     * that the effect instance has enough information about the target
     * and container to do the job.
     */
    protected var autoRemoveTarget:Boolean = false;
        
    
    private var _easer:IEaser;    
    public function set easer(value:IEaser):void
    {
        _easer = value;
    }
    public function get easer():IEaser
    {
        return _easer;
    }
    
    private var _interpolator:IInterpolator;
    public function set interpolator(value:IInterpolator):void
    {
        _interpolator = value;
        
    }
    public function get interpolator():IInterpolator
    {
        return _interpolator;
    }
    
    private var _repeatBehavior:String;
    public function set repeatBehavior(value:String):void
    {
        _repeatBehavior = value;
    }
    public function get repeatBehavior():String
    {
        return _repeatBehavior;
    }
            
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function pause():void
    {
        super.pause();
        
        if (animation)
            animation.pause();
    }

    /**
     *  @private
     */
    override public function stop():void
    {
        super.stop();
        
        if (animation)
            animation.stop();
    }   
    
    /**
     *  @private
     */
    override public function resume():void
    {
        super.resume();
    
        if (animation)
            animation.resume();
    }
        
    /**
     *  @private
     */
    override public function reverse():void
    {
        super.reverse();
    
        if (animation)
            animation.reverse();
        
        reverseAnimation = !reverseAnimation;
    }
    
    /**
     *  Advances the effect to the specified position. 
     *
     *  @param playheadTime The position, in milliseconds, between 0
     *  and the value of the <code>duration</code> property.
     */
    public function seek(playheadTime:Number):void
    {
        if (animation)
            animation.seek(playheadTime);
        else
            _seekTime = playheadTime;
    } 
    
    /**
     *  Interrupts an effect that is currently playing,
     *  and immediately jumps to the end of the effect.
     *  Calls the <code>Tween.endTween()</code> method
     *  on the <code>tween</code> property. 
     *  This method implements the method of the superclass. 
     *
     *  <p>If you create a subclass of TweenEffectInstance,
     *  you can optionally override this method.</p>
     *
     *  <p>The effect dispatches the <code>effectEnd</code> event.</p>
     *
     *  @see mx.effects.EffectInstance#end()
     */
    override public function end():void
    {
        // Jump to the end of the animation.
        if (animation)
        {
            animation.end();
            animation = null;
        }
    }
        
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @copy mx.effects.IEffectInstance#startEffect()
     */
    override public function startEffect():void
    {  
        // This method is a copy of that in EffectInstance, but removes
        // the startDelay functionality, as that is handled by the 
        // underlying Animation object for AnimateInstance

        // Also removes EffectManager.effectStarted() to avoid use of
        // mx_internal. New effects are not currently triggerable, so
        // this should not matter
                 
        if (target is UIComponent)
        {
            UIComponent(target).effectStarted(this);
        }        
        play();
    }
    
    /**
     * Starts this effect. Performs any final setup for each property
     * from/to values and starts an Animation that will update that property.
     * 
     * @private
     */
    override public function play():void
    {
        // Do what effects normally do when they start, namely
        // dispatch an 'effectStart' event from the target.
        super.play();
        
        if (!propertyValuesList || propertyValuesList.length == 0)
        {
            // nothing to do; at least schedule the effect to end after
            // the specified duration
            var timer:Timer = new Timer(duration, 1);
            timer.addEventListener(TimerEvent.TIMER, noopAnimationHandler);
            timer.start();
            return;
        }
            
        isStyleMap = new Array(propertyValuesList.length);
        
        if (affectsConstraints)
            disableConstraints();
            
        // These two temporary arrays will hold the values passed into the
        // Animation to be interpolated between during the animation. The order
        // of the values in these arrays must match the order of the property
        // names in the propertyValuesList array, as we will assume during update
        // events that the interpolated values in the array are in that same order.
        var fromVals:Array = [];
        var toVals:Array = [];
        for (var i:int = 0; i < propertyValuesList.length; ++i)
        {
            var holder:PropertyValuesHolder = PropertyValuesHolder(propertyValuesList[i]);
            var property:String = holder.property;
            var propValues:Array = holder.values;
            var fromValue:Object;
            var toValue:Object;
            
            if (!property || (property == ""))
                throw new Error("Illegal property value: " + property);
                 
            if (property in target)
            {
                isStyleMap[property] = false;
            }
            else
            {
                try {
                    target.getStyle(property);
                    isStyleMap[property] = true;
                }
                catch (err:Error)
                {
                    throw new Error("Property " + property + " is neither " +
                        "a property or a style on object " + target + ": " + err);
                }
                // TODO: check to make sure that the throw above won't
                // let the code flow get to here
            }

            // Set any NaN from/to values to the current values in the target
            fromValue = isNaN(propValues[0]) ? getCurrentValue(property) : 
                propValues[0];
            if (!isNaN(propValues[1]))
            {
                toValue = propValues[1];
            }
            else
            {
                if (propertyChanges && 
                    propertyChanges.end[property] !== undefined)
                    toValue = propertyChanges.end[property];
                else
                    toValue = getCurrentValue(property);
            }
            if (propertyValuesList.length > 1)
            {
                fromVals.push(fromValue);
                toVals.push(toValue);
            }
        }
    
        // TODO (chaase): avoid setting up animations on properties whose
        // from/to values are the same. Not worth the cycles, but also want
        // to avoid triggering any side effects when we're not actually changing
        // values    
        if (propertyValuesList.length > 1)
        {
            // Create the single Animation that will interpolate all properties
            // simultaneously by interpolating the elements of the 
            // from/toVals arrays
            animation = new Animation(fromVals, toVals, duration);
        }
        else
        {
            // Only one property; don't bother with the arrays
            animation = new Animation(fromValue, toValue, duration);
        }
        animation.addEventListener(AnimationEvent.ANIMATION_START, startHandler);
        animation.addEventListener(AnimationEvent.ANIMATION_UPDATE, updateHandler);
        animation.addEventListener(AnimationEvent.ANIMATION_REPEAT, repeatHandler);
        animation.addEventListener(AnimationEvent.ANIMATION_END, endHandler);
            
        if (_seekTime > 0)
            animation.seek(_seekTime);
        if (reverseAnimation)
            animation.reverse();
        animation.interpolator = interpolator;
        animation.repeatCount = repeatCount;
        animation.repeatDelay = repeatDelay;
        animation.repeatBehavior = repeatBehavior;
        animation.easer = easer;
        animation.startDelay = startDelay;
                    
        animation.play();
          
        // TODO (chaase): there may be a better way to organize the 
        // animations for each property. For example, we could use 
        // an animation of a single value from 0 to 1 and then update each
        // property based on that elapsed fraction.
    }

    /**
     * Set the values in the given array on the properties held in our
     * propertyValuesList array. This is called by the update and end 
     * functions, which are called by the Animation during the animation.
     */
    private function setVals(value:Object):void
    {
        var holder:PropertyValuesHolder;
        
        if (propertyValuesList.length == 1)
        {
            holder = PropertyValuesHolder(propertyValuesList[0]);
            setValue(holder.property, value);
        }
        else
        {
            var valueArray:Array = value as Array;
            for (var i:int = 0; i < propertyValuesList.length; ++i)
            {
                holder = PropertyValuesHolder(propertyValuesList[i]);
                setValue(holder.property, valueArray[i]);
            }
        }
    }
    
    /**
     * Handles start events from the animation.
     * If you override this method, ensure that you call the super method.
     */
    protected function startHandler(event:AnimationEvent):void
    {
        if (autoRemoveTarget)
            addDisappearingTarget();
        dispatchEvent(event);
    }
    
    /**
     * Handles update events from the animation.
     * If you override this method, ensure that you call the super method.
     */
    protected function updateHandler(event:AnimationEvent):void
    {
        setVals(event.value);
        dispatchEvent(event);
    }
    
    /**
     * Handles repeat events from the animation.
     * If you override this method, ensure that you call the super method.
     */
    protected function repeatHandler(event:AnimationEvent):void
    {
        dispatchEvent(event);
    }
    
    private function noopAnimationHandler(event:TimerEvent):void
    {
        finishEffect();
    }

    /**
     * Handles the end event from the animation. The value here is an Array of
     * values, one for each 'property' in our propertyValuesList.
     * If you override this method, ensure that you call the super method.
     */
    protected function endHandler(event:AnimationEvent):void
    {
        dispatchEvent(event);
        finishEffect();
        if (affectsConstraints)
            reenableConstraints();
        if (autoRemoveTarget)
            removeDisappearingTarget();
    }

    /**
     * Adds a target which is not in the state we are transitioning
     * to. This is the partner of removeDisappearingTarget(), which removes
     * the target when this effect is finished if necessary.
     * Note that if a RemoveAction effect is playing in a CompositeEffect,
     * then the adding/removing is already happening and this function
     * will noop the add.
     */
    private function addDisappearingTarget():void
    {
        needsRemoval = false;
        if (propertyChanges)
        {
            // Check for non-null parent ensures that we won't double-remove
            // items, such as if there is a RemoveAction effect working on
            // the same target
            if ("parent" in target && !target.parent)
            {
                var parentStart:* = propertyChanges.start["parent"];;
                var parentEnd:* = propertyChanges.end["parent"];;
                if (parentStart && !parentEnd)
                {
                    if (parentStart is Group)
                        parentStart.addItem(target);
                    else
                        parentStart.addChild(target);
                    needsRemoval = true;
                }
            }
            else if ("elementHost" in target && !target.elementHost)
            {
                var hostStart:* = propertyChanges.start["elementHost"];
                var hostEnd:* = propertyChanges.end["elementHost"];
                if (hostStart && !hostEnd)
                {
                    hostStart.addItem(target);
                    needsRemoval = true;
                }
            }
        }
    }

    /**
     * Removes a target which is not in the state we are transitioning
     * to. This is the partner of addDisappearingTarget(), which re-adds
     * the target when this effect is played if necessary.
     * Note that if a RemoveAction effect is playing in a CompositeEffect,
     * then the adding/removing is already happening and this function
     * will noop the removal.
     */
    private function removeDisappearingTarget():void
    {
        if (needsRemoval && propertyChanges)
        {
            // Check for non-null parent ensures that we won't double-remove
            // items, such as if there is a RemoveAction effect working on
            // the same target
            if ("parent" in target && target.parent)
            {
                var parentStart:* = propertyChanges.start["parent"];;
                var parentEnd:* = propertyChanges.end["parent"];;
                if (parentStart && !parentEnd)
                {
                    if (parentStart is Group)
                        parentStart.removeItem(target);
                    else
                        parentStart.removeChild(target);
                }
            }
            else if ("elementHost" in target && target.elementHost)
            {
                var hostStart:* = propertyChanges.start["elementHost"];
                var hostEnd:* = propertyChanges.end["elementHost"];
                if (hostStart && !hostEnd)
                    hostStart.removeItem(target);
            }
        }
    }

    private var constraintsHolder:Object;
    
    private function reenableConstraint(name:String):void
    {
        var value:* = constraintsHolder[name];
        if (value !== undefined)
        {
            target.setStyle(name, value);
            delete constraintsHolder[name];
        }
    }
    
    private function reenableConstraints():void
    {
        // Only bother if constraintsHolder is non-null; otherwise
        // there must have been no constraints to worry about
        if (constraintsHolder)
        {
            reenableConstraint("left");
            reenableConstraint("right");
            reenableConstraint("top");
            reenableConstraint("bottom");
            reenableConstraint("horizontalCenter");
            reenableConstraint("verticalCenter");
            reenableConstraint("baseline");
            constraintsHolder = null;
        }
    }
    
    private function disableConstraint(name:String):void
    {
        var value:* = target.getStyle(name);
        if (value !== undefined)
        {
            if (!constraintsHolder)
                constraintsHolder = new Object();
            constraintsHolder[name] = value;
            target.setStyle(name, undefined);
        }        
    }
    private function disableConstraints():void
    {
        if (target is IStyleClient)
        {
            disableConstraint("left");
            disableConstraint("right");
            disableConstraint("top");
            disableConstraint("bottom");
            disableConstraint("verticalCenter");
            disableConstraint("horizontalCenter");
            disableConstraint("baseline");
        }
    }
    /**
     * Utility function to handle situation where values may be queried or
     * set on the target prior to completely setting up the effect's
     * propertyValuesList data values (from which the styleMap is created)
     */
    private function setupStyleMapEntry(property:String):void
    {
        // TODO (chaase): Find a better way to set this up just once
        if (isStyleMap[property] == undefined)
        {
            if (property in target)
            {
                isStyleMap[property] = false;
            }
            else
            {
                try {
                    target.getStyle(property);
                    isStyleMap[property] = true;
                }
                catch (err:Error)
                {
                    throw new Error("Property " + property + " is neither " +
                        "a property or a style on object " + target + ": " + err);
                }
                // TODO: check to make sure that the throw above won't
                // let the code flow get to here
            }            
        }
    }
    
    /**
     *  Utility function that sets the named property on the target to
     *  the given value. Handles setting the property as either a true
     *  property or a style.
     *  @private
     */
    protected function setValue(property:String, value:Object):void
    {
        if (roundValues && (value is Number))
            value = Math.round(Number(value));
        
        // TODO (chaase): Find a better way to set this up just once
        setupStyleMapEntry(property);
        if (!isStyleMap[property])
            target[property] = value;
        else
            target.setStyle(property, value);
    }

    /**
     *  Utility function that gets the value of the named property on 
     *  the target. Handles getting the value of the property as either a true
     *  property or a style.
     *  @private
     */
    protected function getCurrentValue(property:String):*
    {
        // TODO (chaase): Find a better way to set this up just once
        setupStyleMapEntry(property);
        if (!isStyleMap[property])
            return target[property];
        else
            return target.getStyle(property);
    }
}
}