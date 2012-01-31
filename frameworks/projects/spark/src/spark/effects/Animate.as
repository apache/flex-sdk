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
import spark.effects.animation.MotionPath;
import spark.effects.animation.RepeatBehavior;
import spark.effects.easing.IEaser;
import spark.effects.easing.Sine;
import spark.effects.interpolation.IInterpolator;
import spark.effects.supportClasses.AnimateInstance;

use namespace mx_internal;

//--------------------------------------
//  Excluded APIs
//--------------------------------------

// Exclude suspendBackgroundProcessing for now because the Flex 4
// effects depend on the layout validation work that the flag suppresses
[Exclude(name="suspendBackgroundProcessing", kind="property")]


[DefaultProperty("motionPaths")]

/**
 * Dispatched every time the effect updates the target.
 *
 * @eventType mx.events.EffectEvent.EFFECT_UPDATE
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
 * @eventType mx.events.EffectEvent.EFFECT_REPEAT
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="effectRepeat", type="mx.events.EffectEvent")]


/**
 * This Animate effect animates an arbitrary set of properties between values. 
 * Specify the properties and values to animate by setting the <code>motionPaths</code> property. 
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;s:Animate&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:Animate
 *    <b>Properties</b>
 *    id="ID"
 *    disableLayout="false"
 *    easer="{spark.effects.easing.Sine(.5)}"
 *    interpolator="NumberInterpolator"
 *    motionPaths="no default"
 *    repeatBehavior="loop"
 *  /&gt;
 *  </pre>
 *
 *  @see spark.effects.supportClasses.AnimateInstance
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
     *  Constructor. 
     *
     *  @param target The Object to animate with this effect.  
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
    // the list of properties specified in the motionPaths Vector.
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
    private var _motionPaths:Vector.<MotionPath>;
    /**
     * A Vector of MotionPath objects, each of which holds the
     * name of a property being animated and the values that the property
     * takes during the animation. 
     * This Vector takes precedence over
     * any properties declared in subclasses of Animate.
     * For example, if this Array is set directly on a Move effect, 
     * then any properties of the Move effect, such as <code>xFrom</code>, are ignored. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get motionPaths():Vector.<MotionPath>
    {
        return _motionPaths;
    }
    /**
     * @private
     */
    public function set motionPaths(value:Vector.<MotionPath>):void
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
     * The easing behavior for this effect. 
     * This IEaser object is used to convert the elapsed fraction of 
     * the animation into an eased fraction, which is then used to
     * calculate the value at that eased elapsed fraction.
     * 
     * <p>Note that it is possible to have easing at both the effect
     * level and the Keyframe level (where Keyframes hold the values/times
     * used in the MotionPath structures), and these easing behaviors will
     * build on each other. The <code>easer</code> provided
     * here controls the easing of the overall effect, whereas that in the
     * Keyframes controls the easing in any particular interval of the animation.
     * By default, the easing for Animate is non-linear (Sine(.5)), whereas
     * the easing for Keyframes is linear. If you desire an effect with easing
     * at the keyframe level instead, you may prefer to set the easing of the
     * effect to linear and then set the easing specifically on the Keyframes
     * directly.</p>
     * 
     * @default spark.effects.easing.Sine(.5)
     *
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
     * the start and end values of a property. 
     * By default, interpolation is handled
     * by the NumberInterpolator class or, in the case of the start
     * and end values being Arrays or Vectors, by the 
     * MultiValueInterpolator class.
     * Interpolation of other types, or of Numbers that should be interpolated
     * differently, such as <code>uint</code> values that hold color
     * channel information, can be handled by supplying a different
     * interpolator.
     *
     *  @see spark.effects.interpolation.NumberInterpolator
     *  @see spark.effects.interpolation.MultiValueInterpolator
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
    
    [Inspectable(category="General", enumeration="loop,reverse", defaultValue="loop" )]
    
    /**
     * The behavior of a repeating effect, which means an effect
     * with <code>repeatCount</code> equal to either 0 or &gt; 1. This
     * value should be either <code>RepeatBehavior.LOOP</code>, which means the animation
     * repeats in the same order each time, or <code>RepeatBehavior.REVERSE</code>,
     * which means the animation reverses direction on each iteration.
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
    //  disableLayout
    //----------------------------------
    /**
     * @private
     * Storage for the disableLayout property. 
     */
    private var _disableLayout:Boolean = false;
    /**
     * If <code>true</code>, the effect disables layout on its
     * targets' parent containers, setting the containers <code>autoLayout</code>
     * property to false, and also disables any layout constraints on the 
     * target objects. These properties will be restored when the effect
     * finishes.
     * 
     * @default false
     *  
     * @langversion 3.0
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @productversion Flex 4
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
     *  @private 
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
        
        if (motionPaths)
        {
            animateInstance.motionPaths = new Vector.<MotionPath>();
            for (var i:int = 0; i < motionPaths.length; ++i)
                animateInstance.motionPaths[i] = motionPaths[i].clone();
        }
    }
    

    /**
     * @private
     */
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