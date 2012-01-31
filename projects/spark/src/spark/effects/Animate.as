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
package mx.effects
{

import flash.sampler.getInvocationCount;

import mx.core.mx_internal;
import mx.effects.effectClasses.FxAnimateInstance;
import mx.effects.interpolation.IEaser;
import mx.effects.interpolation.IInterpolator;
import mx.effects.interpolation.NumberInterpolator;
import mx.effects.interpolation.Sine;
import mx.events.AnimationEvent;
import mx.events.EffectEvent;
import mx.styles.IStyleClient;

use namespace mx_internal;

[DefaultProperty("animationProperties")]

/**
 * Dispatched when the effect starts, which corresponds to a 
 * call to the <code>AnimateInstance.startHandler()</code> method.
 * Flex also dispatches the first <code>animationUpdate</code> event 
 * for the effect at the same time.
 *
 * <p>The <code>Effect.effectStart</code> event is dispatched 
 * before the <code>animationStart</code> event.</p>
 *
 * @eventType mx.events.AnimationEvent.ANIMATION_START
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="animationStart", type="mx.events.AnimationEvent")]

/**
 * Dispatched every time the effect updates the target.
 * This event corresponds to a call to 
 * the <code>AnimateInstance.updateHandler()</code> method.
 *
 * @eventType mx.events.AnimationEvent.ANIMATION_UPDATE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="animationUpdate", type="mx.events.AnimationEvent")]

/**
 * Dispatched when the effect begins a new repetition, for
 * any effect that is repeated more than once.
 * This event corresponds to a call to 
 * the <code>AnimateInstance.repeatHandler()</code> method.
 * Flex also dispatches an <code>animationUpdate</code> event 
 * for the effect at the same time.
 *
 * @eventType mx.events.AnimationEvent.ANIMATION_REPEAT
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="animationRepeat", type="mx.events.AnimationEvent")]

/**
 * Dispatched when the effect ends.
 * This event corresponds to a call to 
 * the <code>AnimateInstance.endHandler()</code> method.
 * Flex also dispatches an <code>animationUpdate</code> event 
 * for the effect at the same time.
 *
 * <p>This event occurs just before an <code>effectEnd</code> event.
 * A repeating effect dispatches this event only after the 
 * final repetition.</p>
 *
 * @eventType mx.events.AnimationEvent.ANIMATION_END
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="animationEnd", type="mx.events.AnimationEvent")]

/**
 * This effect animates an arbitrary set of properties between values, as specified
 * in the <code>animationProperties</code> array. Example usage is as follows:
 * 
 * @example Using the FxAnimate effect to move a button from (100, 100)
 * to (200, 150):
 * <listing version="3.0">
 * var button:Button = new Button();
 * var anim:FxAnimate = new FxAnimate(button);
 * anim.animationProperties = [
 *     new AnimationProperty("x", 100, 200),
 *     new AnimationProperty("y", 100, 150)];
 * anim.play();
 * </listing>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class FxAnimate extends Effect
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
    public function FxAnimate(target:Object = null)
    {
        super(target);
          
        instanceClass = FxAnimateInstance;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    // Cached version of the affected properties. By default, we simply return
    // the list of properties specified in the animationProperties array.
    // Subclasses should override getAffectedProperties() if they wish to 
    // specify a different set.
    private var affectedProperties:Array = null;

    // Cached default easer. We only need one of these, so we cache this static
    // object to be reused by any Animate instances that do not specify
    // a custom easer.
    private static var defaultEaser:IEaser = new Sine(.5); 

    //--------------------------------------------------------------------------
    //
    // Properties
    //
    //--------------------------------------------------------------------------

    /**
     * An array of AnimationProperty objects, each of which holds the
     * name of the property being animated and the values that the property
     * will take on during the animation. This array takes precedence over
     * any helper properties that may be declared in subclasses of FxAnimate.
     * For example, if this array is set directly on an FxMove object, 
     * then any helper values such as <code>xFrom</code> will be ignored. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var animationProperties:Array;
    
    /**
     * The easing behavior for this effect. This IEaser
     * object will be used to convert the elapsed fraction of 
     * the animation into an eased fraction, which will then be used to
     * calculate the value at that eased elapsed fraction.
     * 
     * @default mx.effects.fxEasing.Sine(.5)
     * @see mx.effects.fxEasing.Sine
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var easer:IEaser = defaultEaser;
    
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
    public var interpolator:IInterpolator = null;

    /**
     * The behavior of a repeating effect (an effect
     * with <code>repeatCount</code> equal to either 0 or >1). This
     * value should be either <code>Animation.LOOP</code>, where the animation
     * will repeat in the same order each time, or <code>Animation.REVERSE</code>,
     * where the animation will reverse direction each iteration.
     * 
     * @default Animation.LOOP
     * @see mx.effects.Animation#repeatBehavior
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var repeatBehavior:String = Animation.LOOP;
    
    /**
     * This flag indicates whether the layout constraints (left, right, top,
     * and bottom) should be adjusted when the effect ends, based on where
     * the target has been positioned by the effect. This behavior can
     * be useful for effects that change the position or size of a component
     * during the course of running the effect, and when the desired result
     * is that the target object stays in the resulting position without
     * adjusting to the original constraints. For example, a Rotate effect
     * run on a target with left/top constraints might otherwise be moved
     * to the original constraint position, which has a different effect
     * than rotating around a specified rotation center. 
     * 
     * <p>The default value
     * is <code>false</code>, which means that the original constraints will
     * be obeyed. To adjust the constraints based on the effect result,
     * set this property to <code>true</code>.</p>
     * 
     * @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var adjustConstraints:Boolean = false;

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
    public var disableLayout:Boolean = false;

    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    /**
     * By default, the affected properties are the same as those specified
     * in the <code>animationProperties</code> array. If subclasses affect
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
            if (animationProperties)
            {
                affectedProperties = new Array(animationProperties.length);
                for (var i:int = 0; i < animationProperties.length; ++i)
                {
                    var effectHolder:AnimationProperty = AnimationProperty(animationProperties[i]);
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
        
        var animateInstance:FxAnimateInstance = FxAnimateInstance(instance);

        animateInstance.addEventListener(AnimationEvent.ANIMATION_START, animationEventHandler);
        animateInstance.addEventListener(AnimationEvent.ANIMATION_UPDATE, animationEventHandler);
        animateInstance.addEventListener(AnimationEvent.ANIMATION_REPEAT, animationEventHandler);
        animateInstance.addEventListener(AnimationEvent.ANIMATION_END, animationEventHandler);

        if (easer)
            animateInstance.easer = easer;
            
        if (interpolator)
            animateInstance.interpolator = interpolator;
        
        if (isNaN(repeatCount))
            animateInstance.repeatCount = repeatCount;
            
        animateInstance.repeatBehavior = repeatBehavior;
        animateInstance.adjustConstraints = adjustConstraints;
        animateInstance.disableLayout = disableLayout;
        
        // Deep-copy the animationProperties into the instance
        if (animationProperties != null)
        {
            animateInstance.animationProperties = new Array(animationProperties.length);
            var i:int, j:int;
            for (i = 0; i < animationProperties.length; ++i)
            {
                var prop:AnimationProperty = AnimationProperty(animationProperties[i]);
                animateInstance.animationProperties[i] = new AnimationProperty(
                    prop.property, prop.valueFrom, prop.valueTo, prop.valueBy);
            }
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
     * Called when the Animate dispatches an AnimationEvent.
     * If you override this method, ensure that you call the super method.
     *
     * @param event An event object of type AnimationEvent.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function animationEventHandler(event:AnimationEvent):void
    {
        dispatchEvent(event);
    }
}
}