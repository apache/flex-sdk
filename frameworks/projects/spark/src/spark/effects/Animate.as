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
package spark.effects
{

import mx.core.mx_internal;
import mx.effects.Effect;
import mx.effects.IEffectInstance;
import mx.events.EffectEvent;

import spark.effects.animation.Animation;
import spark.effects.animation.RepeatBehavior;
import spark.effects.easing.IEaser;
import spark.effects.easing.Sine;
import spark.effects.interpolation.IInterpolator;
import spark.effects.supportClasses.AnimateInstance;

use namespace mx_internal;

[DefaultProperty("motionPaths")]

/**
 * Dispatched every time the effect updates the target.
 *
 * @eventType spark.events.EffectEvent.EFFECT_UPDATE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="effectUpdate", type="mx.events.EffectEvent")]

/**
 * Dispatched when the effect begins a new repetition, for
 * any effect that is repeated more than once.
 * Flex also dispatches an <code>effectUpdate</code> event 
 * for the effect at the same time.
 *
 * @eventType spark.events.EffectEvent.EFFECT_REPEAT
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="effectRepeat", type="mx.events.EffectEvent")]


/**
 * This effect animates an arbitrary set of properties between values, as specified
 * in the <code>motionPaths</code> array. Example usage is as follows:
 * 
 * @example Using the Animate effect to move a button from (100, 100)
 * to (200, 150):
 * <listing version="3.0">
 * var button:Button = new Button();
 * var anim:Animate = new Animate(button);
 * anim.motionPaths = [
 *     new SimpleMotionPath("x", 100, 200),
 *     new SimpleMotionPath("y", 100, 150)];
 * anim.play();
 * </listing>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class Animate extends Effect
{
    include "../core/Version.as";

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
    public function Animate(target:Object = null)
    {
        super(target);
          
        instanceClass = AnimateInstance;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    // Cached version of the affected properties. By default, we simply return
    // the list of properties specified in the motionPaths array.
    // Subclasses should override getAffectedProperties() if they wish to 
    // specify a different set.
    private var affectedProperties:Array = null;

    // Cached default easer. We only need one of these, so we cache this static
    // object to be reused by any Animate instances that do not specify
    // a custom easer.
    private static var defaultEaser:IEaser = new Sine(.5); 

    // Used to optimize event dispatching: only send out updated events if
    // there is someone listening
    private var numUpdateListeners:int = 0;
    

    //--------------------------------------------------------------------------
    //
    // Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  motionPaths
    //----------------------------------
    /**
     * @private
     * Storage for the motionPaths property. 
     */
    private var _motionPaths:Array;
    [Inspectable(category="General", arrayType="spark.effects.MotionPath")]
    /**
     * An array of MotionPath objects, each of which holds the
     * name of the property being animated and the values that the property
     * will take on during the animation. This array takes precedence over
     * any helper properties that may be declared in subclasses of Animate.
     * For example, if this array is set directly on an Move object, 
     * then any helper values such as <code>xFrom</code> will be ignored. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get motionPaths():Array
    {
        return _motionPaths;
    }
    /**
     * @private
     */
    public function set motionPaths(value:Array):void
    {
        _motionPaths = value;
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
     * The easing behavior for this effect. This IEaser
     * object will be used to convert the elapsed fraction of 
     * the animation into an eased fraction, which will then be used to
     * calculate the value at that eased elapsed fraction.
     * 
     * @default spark.effects.easing.Sine(.5)
     * @see spark.effects.easing.Sine
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
     * @private
     */
    public function set easer(value:IEaser):void
    {
        _easer = value;
    }
    
    //----------------------------------
    //  interpolator
    //----------------------------------
    /**
     * @private
     * Storage for the interpolator property. 
     */
    private var _interpolator:IInterpolator = null;
    /**
     * The interpolator used by this effect to calculate values between
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
    public function get interpolator():IInterpolator
    {
        return _interpolator;
    }
    /**
     * @private
     */
    public function set interpolator(value:IInterpolator):void
    {
        _interpolator = value;
    }

    //----------------------------------
    //  repeatBehavior
    //----------------------------------
    /**
     * @private
     * Storage for the repeatBehavior property. 
     */
    private var _repeatBehavior:String = RepeatBehavior.LOOP;
    /**
     * The behavior of a repeating effect (an effect
     * with <code>repeatCount</code> equal to either 0 or >1). This
     * value should be either <code>RepeatBehavior.LOOP</code>, where the animation
     * will repeat in the same order each time, or <code>RepeatBehavior.REVERSE</code>,
     * where the animation will reverse direction each iteration.
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
    /**
     * @private
     */
    public function set repeatBehavior(value:String):void
    {
        _repeatBehavior = value;
    }
    
    //----------------------------------
    //  disableConstraints
    //----------------------------------
    /**
     * @private
     * Storage for the disableConstraints property. 
     */
    private var _disableConstraints:Boolean = false;
    /**
     * This property indicates whether the effect should disable constraints on its
     * targets while the effect is running. If set to true, the effect
     * will disable any constraints that are set for the duration of the effect
     * and then re-enable those same constraints when the effect finishes.
     * 
     * @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get disableConstraints():Boolean
    {
        return _disableConstraints;
    }
    /**
     * @private
     */
    public function set disableConstraints(value:Boolean):void
    {
        _disableConstraints = value;
    }
    
    //----------------------------------
    //  disableLayout
    //----------------------------------
    /**
     * @private
     * Storage for the disableLayout property. 
     */
    private var _disableLayout:Boolean = false;
    /**
     * This property indicates whether the effect should disable layout on its
     * targets' parents while the effect is running. If set to true, the effect
     * will set the parent containers' <code>autoLayout</code> property to 
     * false for the duration of the effect. Note that other events may
     * occur in those containers that force layout to happen anyway.
     * 
     * @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get disableLayout():Boolean
    {
        return _disableLayout;
    }
    /**
     * @private
     */
    public function set disableLayout(value:Boolean):void
    {
        _disableLayout = value;
    }
    
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    /**
     * By default, the affected properties are the same as those specified
     * in the <code>motionPaths</code> array. If subclasses affect
     * or track a different set of properties, they should override this
     * method.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function getAffectedProperties():Array /* of String */
    {
        if (!affectedProperties)
        {
            if (motionPaths)
            {
                affectedProperties = new Array(motionPaths.length);
                for (var i:int = 0; i < motionPaths.length; ++i)
                {
                    var effectHolder:MotionPath = MotionPath(motionPaths[i]);
                    affectedProperties[i] = effectHolder.property;
                }
            }
            else
            {
                affectedProperties = [];
            }
        }
        return affectedProperties;
    }

    /**
     * @private
     */
    override protected function initInstance(instance:IEffectInstance):void
    {
        super.initInstance(instance);
        
        var animateInstance:AnimateInstance = AnimateInstance(instance);

        animateInstance.addEventListener(EffectEvent.EFFECT_REPEAT, animationEventHandler);
        // Optimization: don't bother listening for update events if we don't have
        // any listeners for that event
        if (numUpdateListeners > 0)
            animateInstance.addEventListener(EffectEvent.EFFECT_UPDATE, animationEventHandler);

        if (easer)
            animateInstance.easer = easer;
            
        if (interpolator)
            animateInstance.interpolator = interpolator;
        
        if (isNaN(repeatCount))
            animateInstance.repeatCount = repeatCount;
            
        animateInstance.repeatBehavior = repeatBehavior;
        animateInstance.disableLayout = disableLayout;
        animateInstance.disableConstraints = disableConstraints;
        
        if (motionPaths)
        {
            animateInstance.motionPaths = [];
            for (var i:int = 0; i < motionPaths.length; ++i)
                animateInstance.motionPaths[i] = motionPaths[i].clone();
        }
    }

    override protected function applyValueToTarget(target:Object, property:String, 
                                          value:*, props:Object):void
    {
        if (property in target)
        {
            // The "property in target" test only tells if the property exists
            // in the target, but does not distinguish between read-only and
            // read-write properties. Put a try/catch around the setter and 
            // ignore any errors.
            try
            {
                target[property] = value;
            }
            catch(e:Error)
            {
                // Ignore errors
            }
        }
    }

    /**
     * @private
     * Track number of listeners to update event for optimization purposes
     */
    override public function addEventListener(type:String, listener:Function, 
        useCapture:Boolean=false, priority:int=0, 
        useWeakReference:Boolean=false):void
    {
        super.addEventListener(type, listener, useCapture, priority, 
            useWeakReference);
        if (type == EffectEvent.EFFECT_UPDATE)
            ++numUpdateListeners;
    }
    
    /**
     * @private
     * Track number of listeners to update event for optimization purposes
     */
    override public function removeEventListener(type:String, listener:Function, 
        useCapture:Boolean=false):void
    {
        super.removeEventListener(type, listener, useCapture);
        if (type == EffectEvent.EFFECT_UPDATE)
            --numUpdateListeners;
    }
    
    /**
     * @private
     * Called when the AnimateInstance object dispatches an EffectEvent.
     *
     * @param event An event object of type EffectEvent.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    private function animationEventHandler(event:EffectEvent):void
    {
        dispatchEvent(event);
    }
}
}