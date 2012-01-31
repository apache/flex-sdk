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

package flex.effects.effectClasses
{
import flex.effects.Animation;
import flex.effects.IAnimationTarget;
import flex.effects.PropertyValuesHolder;
import flex.effects.easing.IEaser;
import flex.effects.interpolation.IInterpolator;

import mx.core.UIComponent;
import mx.effects.EffectInstance;
import mx.effects.EffectManager;

/**
 * The AnimateInstance class implements the instance class for the
 * Animate effect. Flex creates an instance of this class when
 * it plays a Animate effect; you do not create one yourself.
 */
public class AnimateInstance extends EffectInstance implements IAnimationTarget
{
    public var animation:Animation = new Animation();
    
    public function AnimateInstance(target:Object)
    {
        super(target);
        animation.addAnimationTarget(this);
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
    
    public function set easer(value:IEaser):void
    {
        animation.easer = value;
    }
    public function get easer():IEaser
    {
        return animation.easer;
    }
    
    public function set interpolator(value:IInterpolator):void
    {
        animation.interpolator = value;
    }
    public function get interpolator():IInterpolator
    {
        return animation.interpolator;
    }
    
    public function set repeatBehavior(value:String):void
    {
        animation.repeatBehavior = value;
    }
    public function get repeatBehavior():String
    {
        return animation.repeatBehavior;
    }
    
    override public function set duration(value:Number):void
    {
        animation.duration = value;
    }
    override public function get duration():Number
    {
        return animation.duration;
    }
    
    override public function set startDelay(value:int):void
    {
        animation.startDelay = value;
    }
    override public function get startDelay():int
    {
        return animation.startDelay;
    }
    
    override public function set repeatDelay(value:int):void
    {
        animation.repeatDelay = value;
    }
    override public function get repeatDelay():int
    {
        return animation.repeatDelay;
    }
    
    override public function set repeatCount(value:int):void
    {
        animation.repeatCount = value;
    }
    override public function get repeatCount():int
    {
        return animation.repeatCount;
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
            return;
            
        isStyleMap = new Array(propertyValuesList.length);
        
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
            var fromValue:Number;
            var toValue:Number;
            
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
        
        if (propertyValuesList.length > 1)
        {
            // Create the single Animation that will interpolate all properties
            // simultaneously by interpolating the elements of the 
            // from/toVals arrays
            animation.startValue = fromVals;
            animation.endValue = toVals;
        }
        else
        {
            // Only one property; don't bother with the arrays
            animation.startValue = fromValue;
            animation.endValue = toValue;
        }
            
        if (_seekTime > 0)
            animation.seek(_seekTime);
        if (reverseAnimation)
            animation.reverse();
            
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
    
    public function animationStart(animation:Animation, value:Object):void
    {
    }

    /**
     * Handles update events from the animation.
     */
    public function animationUpdate(animation:Animation, value:Object):void
    {
        setVals(value);
    }
    
    public function animationRepeat(animation:Animation, value:Object):void
    {
    }
    
    /**
     * Handles the end event from the animation. The value here is an Array of
     * values, one for each 'property' in our propertyValuesList.
     */
    public function animationEnd(animation:Animation, value:Object):void
    {
        finishEffect();
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
    protected function getCurrentValue(property:String):Number
    {
        if (!isStyleMap[property])
            return target[property];
        else
            return target.getStyle(property);
    }
}
}