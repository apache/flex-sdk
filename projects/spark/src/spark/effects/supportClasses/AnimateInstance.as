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

import mx.core.ILayoutElement;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.effects.Animation;
import mx.effects.AnimationProperty;
import mx.effects.EffectInstance;
import mx.effects.interpolation.IEaser;
import mx.effects.interpolation.IInterpolator;
import mx.effects.interpolation.NumberInterpolator;
import mx.events.AnimationEvent;
import mx.layout.LayoutElementFactory;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;
import mx.styles.IStyleClient;

use namespace mx_internal;

//--------------------------------------
//  Other metadata
//--------------------------------------

[ResourceBundle("sparkEffects")]

/**
 * The FxAnimateInstance class implements the instance class for the
 * FxAnimate effect. Flex creates an instance of this class when
 * it plays a FxAnimate effect; you do not create one yourself.
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
    
    /**
     *  @private
     *  Used for accessing localized Error messages.
     */
    private var resourceManager:IResourceManager =
                                    ResourceManager.getInstance();
    
    //--------------------------------------------------------------------------
    //
    // Properties
    //
    //--------------------------------------------------------------------------

    private var _animationProperties:Array;
    /**
     * An array of AnimationProperty objects, each of which holds the
     * name of the property being animated and the values that the property
     * will take on during the animation.
     */
    public function get animationProperties():Array
    {
        return _animationProperties;
    }
    public function set animationProperties(value:Array):void
    {
        // Only set the list to the given value if we have a 
        // null list to begin with. Otherwise, we've already
        // set up the list once and don't need to do it again
        // (for example, in a repeating effect).
        if (!_animationProperties)
            _animationProperties = value;
    }
    
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
     * property in their affectedProperties array so 
     * that the effect instance has enough information about the target
     * and container to do the job.
     */
    protected var autoRemoveTarget:Boolean = false;
        
    public var adjustConstraints:Boolean;    

    public var disableLayout:Boolean;
    
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
            
    //----------------------------------
    //  playReversed
    //----------------------------------

    /**
     *  @private
     */
    override mx_internal function set playReversed(value:Boolean):void
    {
        super.playReversed = value;
        
        if (animation)
            animation.reverse();
        
        reverseAnimation = value;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  playheadTime
    //----------------------------------
    
    /**
     *  @copy mx.effects.IEffectInstance#playheadTime
     */
    override public function get playheadTime():Number 
    {
        if (animation)
            return animation.elapsedTime;
        return 0;
    }

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
    override public function seek(playheadTime:Number):void
    {
        if (animation)
            animation.seek(playheadTime, true);
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

        super.end();
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
        // This override removes EffectManager.effectStarted() to avoid use of
        // mx_internal. New effects are not currently triggerable, so
        // this should not matter
                 
        if (target is UIComponent)
        {
            UIComponent(target).effectStarted(this);
        }

        if (autoRemoveTarget)
            addDisappearingTarget();

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
        super.play();

        if (!animationProperties || animationProperties.length == 0)
        {
            // nothing to do; at least schedule the effect to end after
            // the specified duration
            var timer:Timer = new Timer(duration, 1);
            timer.addEventListener(TimerEvent.TIMER, noopAnimationHandler);
            timer.start();
            return;
        }
            
        isStyleMap = new Array(animationProperties.length);
        
        // These two temporary arrays will hold the values passed into the
        // Animation to be interpolated between during the animation. The order
        // of the values in these arrays must match the order of the property
        // names in the animationProperties array, as we will assume during update
        // events that the interpolated values in the array are in that same order.
        var fromVals:Array = [];
        var toVals:Array = [];
        for (var i:int = 0; i < animationProperties.length; ++i)
        {
            var holder:AnimationProperty = AnimationProperty(animationProperties[i]);
            var property:String = holder.property;
            var fromValue:Object = null;
            var toValue:Object = null;
            
            if (!property || (property == ""))
                throw new Error(resourceManager.getString("sparkEffects", "illegalPropValue", [property]));
                 
            setupStyleMapEntry(property);

            // For any invalid value, set the animating value to null
            // null is a trigger for finalizing the value later on
            fromValue = isValidValue(holder.valueFrom) ? holder.valueFrom : null;
            toValue = isValidValue(holder.valueTo) ? holder.valueTo : null;
            if (toValue === null && propertyChanges && 
                propertyChanges.end[property] !== undefined)
                toValue = propertyChanges.end[property];
            
            if (animationProperties.length > 1)
            {
                fromVals.push(fromValue);
                toVals.push(toValue);
            }
        }
    
        // TODO (chaase): avoid setting up animations on properties whose
        // from/to values are the same. Not worth the cycles, but also want
        // to avoid triggering any side effects when we're not actually changing
        // values    
        if (animationProperties.length > 1)
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
            animation.playReversed = true;
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
     * animationProperties array. This is called by the update and end 
     * functions, which are called by the Animation during the animation.
     */
    protected function applyValues(value:Object):void
    {
        var holder:AnimationProperty;
        
        if (animationProperties.length == 1)
        {
            holder = AnimationProperty(animationProperties[0]);
            setValue(holder.property, value);
        }
        else
        {
            var valueArray:Array = value as Array;
            for (var i:int = 0; i < animationProperties.length; ++i)
            {
                holder = AnimationProperty(animationProperties[i]);
                setValue(holder.property, valueArray[i]);
            }
        }
    }
    
    /**
     * @private
     * 
     * Utility function to determine whether a given value is 'valid',
     * which means it's either a Number and it's not NaN, or it's not
     * a Number and it's not null
     */
    private function isValidValue(value:Object):Boolean
    {
        return ((value is Number && !isNaN(Number(value))) ||
            (!(value is Number) && value !== null));
    }
    
    /**
     * Walk the animationProperties looking for null values. A null indicates
     * that the value should be replaced by the current value or one that
     * is calculated from the other value and a supplied delta value.
     * 
     * @return Boolean whether this call changed any values in the list
     */
    private function finalizeValues():Boolean
    {
        var changedValues:Boolean = false;
        for (var i:int = 0; i < animationProperties.length; ++i)
        {
            var holder:AnimationProperty = 
                AnimationProperty(animationProperties[i]);
            // Note that we use strict equality tests for null, as a simple
            // '0' value for a Number or int would look the same as a null
            // in a simple !value test.
            // Let's hope they've set a reasonable interpolator by now,
            // or otherwise we're just dealing with numbers
            var interp:IInterpolator = 
                interpolator ?
                interpolator :
                NumberInterpolator.getInstance();
            var fromValid:Boolean = isValidValue(holder.valueFrom);
            var toValid:Boolean = isValidValue(holder.valueTo);
            var byValid:Boolean = isValidValue(holder.valueBy);
            if (!fromValid || !toValid)
            {
                if (!fromValid)
                {
                    if (toValid && byValid)
                        holder.valueFrom = interp.decrement(holder.valueTo, holder.valueBy);
                    else
                        holder.valueFrom = getCurrentValue(holder.property);
                    fromValid = isValidValue(holder.valueFrom);
                }
                if (!toValid)
                {
                    if (fromValid && byValid)
                        holder.valueTo = interp.increment(holder.valueFrom, holder.valueBy);
                    else
                        holder.valueTo = getCurrentValue(holder.property);
                }
                changedValues = true;
            }
        }
        return changedValues;
        
    }

    /**
     * Handles start events from the animation.
     * If you override this method, ensure that you call the super method.
     */
    protected function startHandler(event:AnimationEvent):void
    {
        // Wait until the underlying Animation actually starts (after
        // any startDelay) to cache constraints and disable layout. This
        // avoids problems with doing this too early and affecting other
        // effects that are running before this one.
        if (affectsConstraints || adjustConstraints)
            cacheConstraints(affectsConstraints);
        if (disableLayout)
            setupParentLayout(false);
            
        var anim:Animation = Animation(event.target);
        if (finalizeValues())
        {
            var holder:AnimationProperty;
            // Some of the values were updated; must now update
            // the respective values in the Animation
            if (animationProperties.length == 1)
            {
                holder = AnimationProperty(animationProperties[0]);
                if (anim.startValue === null)
                    anim.startValue = holder.valueFrom;
                if (anim.endValue === null)
                    anim.endValue = holder.valueTo;
            }
            else
            {
                var startValues:Array = anim.startValue as Array;
                var endValues:Array = anim.endValue as Array;
                for (var i:int = 0; i < animationProperties.length; ++i)
                {
                    holder = AnimationProperty(animationProperties[i]);
                    if (startValues[i] === null)
                        startValues[i] = holder.valueFrom;
                    if (endValues[i] === null)
                        endValues[i] = holder.valueTo;
                }
            }
        }
        
        // TODO (chaase): Consider putting AnimateInstance (and subclass's) 
        // play() functionality (the setup and playing of the Animation object)
        // into startEffect(), calling play() from here, and not overriding
        // play() at all.
        
        dispatchEvent(event);
    }
    
    /**
     * Handles update events from the animation.
     * If you override this method, ensure that you call the super method.
     */
    protected function updateHandler(event:AnimationEvent):void
    {
        applyValues(event.value);
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
     *  @copy mx.effects.IEffectInstance#finishEffect()
     */
    override public function finishEffect():void
    {
        if (autoRemoveTarget)
            removeDisappearingTarget();
        super.finishEffect();
    }

    /**
     * Handles the end event from the animation. The value here is an Array of
     * values, one for each 'property' in our animationProperties.
     * If you override this method, ensure that you call the super method.
     */
    protected function endHandler(event:AnimationEvent):void
    {
        dispatchEvent(event);
        if (affectsConstraints || adjustConstraints)
            reenableConstraints();
        if (disableLayout)
            setupParentLayout(true);
        finishEffect();
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
                    if (parentStart is IVisualElementContainer)
                        IVisualElementContainer(parentStart).addElement(target as IVisualElement);
                    else
                        parentStart.addChild(target);
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
                    if (parentStart is IVisualElementContainer)
                        IVisualElementContainer(parentStart).removeElement(target as IVisualElement);
                    else
                        parentStart.removeChild(target);
                }
            }
        }
    }

    private var constraintsHolder:Object;
    
    // TODO (chaase): Use IConstraintClient for this
    private function reenableConstraint(name:String):void
    {
        var value:* = constraintsHolder[name];
        if (value !== undefined)
        {
            if (name in target)
                target[name] = value;
            else
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
            if (adjustConstraints)
            {
                var layoutElement:ILayoutElement = LayoutElementFactory.getLayoutElementFor(target);
                var parentW:int = 0;
                var parentH:int = 0;
                var targetX:Number = layoutElement.getLayoutBoundsX();
                var targetY:Number = layoutElement.getLayoutBoundsY();
                var targetW:Number = layoutElement.getLayoutBoundsWidth();
                var targetH:Number = layoutElement.getLayoutBoundsHeight();
                
                // For 'bottom' or 'verticalCenter' we need the parent height
                if (constraintsHolder["bottom"] !== undefined ||
                    constraintsHolder["verticalCenter"] !== undefined)
                {
                    if ("parent" in target && target.parent)
                    {
                        parentH = target.parent.height;
                    }
                }
                
                // For 'right' or 'horizontalCenter' we need the parent width
                if (constraintsHolder["right"] !== undefined ||
                    constraintsHolder["horizontalCenter"] !== undefined)
                {
                    if ("parent" in target && target.parent)
                    {
                        parentW = target.parent.width;
                    }
                }

                if (constraintsHolder["left"] !== undefined)
                    constraintsHolder["left"] = Math.round(targetX);
                if (constraintsHolder["top"] !== undefined)
                    constraintsHolder["top"] = Math.round(targetY);

                // Only bother adjusting 'right' if our target is
                // parented to an object with a positive width
                if (parentW > 0 && constraintsHolder["right"] !== undefined)
                    constraintsHolder["right"] = parentW - targetX - targetW;

                // Only bother adjusting 'bottom' if our target is
                // parented to an object with a positive height
                if (parentH > 0 && constraintsHolder["bottom"] !== undefined)
                    constraintsHolder["bottom"] = parentH - targetY - targetH;

                // Only bother adjusting 'horizontalCenter' if our target is
                // parented to an object with a positive width
                if (parentW > 0 && constraintsHolder["horizontalCenter"] !== undefined)
                {
                    // Layout uses horizontalCenter to calculate position this way
                    // targetX = parentW / 2 - targetW / 2 + horizontalCenter
                    constraintsHolder["horizontalCenter"] = targetX + targetW / 2 - parentW / 2;
                }

                // Only bother adjusting 'verticalCenter' if our target is
                // parented to an object with a positive height
                if (parentH > 0 && constraintsHolder["verticalCenter"] !== undefined)
                {
                    // Layout uses verticalCenter to calculate position this way
                    // targetY = parentH / 2 - targetH / 2 + verticalCenter
                    constraintsHolder["verticalCenter"] = targetY + targetH / 2 - parentH / 2;
                }

                // TODO EGeorgie: add support for 'baseline' constraint, when the new layouts support it.
            }
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
    
    // TODO (chaase): Use IConstraintClient for this
    private function cacheConstraint(name:String, disable:Boolean):void
    {
        var isProperty:Boolean = (name in target);
        var value:*;
        if (isProperty)
            value = target[name];
        else
            value = target.getStyle(name);
        if (!isNaN(value) && value != null)
        {
            if (!constraintsHolder)
                constraintsHolder = new Object();
            constraintsHolder[name] = value;
            if (disable)
            {
                if (isProperty)
                    target[name] = NaN;
                else if (target is IStyleClient)
                    target.setStyle(name, undefined);
            }
        }        
    }
    
    private function cacheConstraints(disable:Boolean):void
    {
        cacheConstraint("left", disable);
        cacheConstraint("right", disable);
        cacheConstraint("top", disable);
        cacheConstraint("bottom", disable);
        cacheConstraint("verticalCenter", disable);
        cacheConstraint("horizontalCenter", disable);
        cacheConstraint("baseline", disable);
    }

    /**
     * Utility function to handle situation where values may be queried or
     * set on the target prior to completely setting up the effect's
     * animationProperties data values (from which the styleMap is created)
     */
    protected function setupStyleMapEntry(property:String):void
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
                    throw new Error(resourceManager.getString("sparkEffects", 
                        "propNotPropOrStyle", [property, target, err])); 
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

    /**
     * Enables or disables autoLayout in the target's container.
     * This is used to disable layout during the course of an animation,
     * and to re-enable it when the animation finishes.
     */
    private function setupParentLayout(enable:Boolean):void
    {
        var parent:* = null;
        if ("parent" in target && target.parent)
        {
            parent = target.parent;
        }
        
        if (parent && ("autoLayout" in parent))
            parent.autoLayout = enable;
    }
}
}
