////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.effects
{
import flash.geom.Vector3D;
import flash.utils.Dictionary;

import mx.core.mx_internal;
import mx.effects.Effect;
import spark.effects.Animate;
import mx.effects.IEffectInstance;
import mx.events.EffectEvent;
import mx.styles.IStyleClient;

import spark.effects.effectClasses.AnimateTransformInstance;

use namespace mx_internal;

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="repeatCount", kind="property")]
[Exclude(name="repeatBehavior", kind="property")]
[Exclude(name="repeatDelay", kind="property")]

/**
 * This effect controls all transform-related animations on target
 * objects. Transform operations, e.g., translation, scale, and
 * rotation, must be combined into single operations that act
 * together in order to avoid clobbering overlapping values. Therefore,
 * this effect works by combining all current transform effects
 * (AnimateTransform and any subclasses) on a particular target into one 
 * single global instance for that target.
 * 
 * <p>The transform is controlled by animating the properties of
 * translation (translationX, translationY, and translationZ), 
 * rotation (rotationX, rotationY,
 * and rotationZ), and scale (scaleX, scaleY, scaleZ). If any of
 * these properties are not provided in the set of MotionPath objects
 * for this effect, then it is assumed that these properties can
 * be derived from the object and are not changing during the course
 * of this effect.</p>
 * 
 * <p>It is important to note that the translation properties
 * (translationX, translationY, and translationZ)
 * specify how much the transformCenter moves during
 * the animation, not the absolute locations of the x, y, and z
 * coordinate of the target object. Typically, these mean the same thing
 * because the transformCenter of the object is at (0, 0). But if 
 * the <code>autoCenterTransform</code> property is set, this changes.
 * For example, an object doing a simple rotation around its center will 
 * have different (x, y) coordinates at the start and end, even though
 * the center of the object has not been translated. By specifying
 * that translationX/Y/Z act on the transformCenter instead, we can
 * correctly specify an animation with rotation only and no translation
 * and get the desired result.</p>
 * 
 * <p>This combination of multiple transform effects happens
 * internally and the caller of the effects need not be aware of it,
 * but it does force certain constraints that should be considered:
 * (1) the transformCenter for the target object (either set on the object
 * itself or set indirectly through the <code>autoCenterTransform</code>
 * or <code>transformX</code>, <code>transformY</code>, 
 * or <code>transformZ</code> properties in this effect) will be
 * globally applied to all transform effects on that target, so they
 * should all use the same values, (2) these transform effects ignore
 * repeat parameters, since the effects of any single Transform effect
 * will impact all other Transform effects running on the same target
 * (effects can still be repeated by encapsulating them in 
 * CompositeEffects which repeat), (3) the subclasses of AnimateTransform provide an
 * easy way for simple manipulations of the transform effect, but for
 * full control and fine-grained manipulation of the underlying keyframe
 * times and values, use the AnimateTransform effect directly.</p>
 * 
 * An additional constraint of this effect and its subclasses is that
 * the target must be of type UIComponent or GraphicElement (or a subclass
 * of those classes), or any other object which has similarly
 * defined and implemented <code>transformAround()</code> and 
 * <code>transformPointToParent()</code> functions.
 */  
public class AnimateTransform extends Animate
{
    include "../../mx/core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * Constructor.
     */
    public function AnimateTransform(target:Object=null)
    {
        super(target);
        instanceClass = AnimateTransformInstance;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    // TODO (chaase): Is weak Dictionary sufficient to hold these values and then
    // dispense with them appropriately? What if we get interrupted before we
    // clear the map?
    /**
     * @private
     * 
     * Stores the single instance for the current transform effect on a given target.
     * There can be only one instance per target at any given time, so we store
     * that instance in the map and insert new effect values into it before playing
     * it, rather than creating new instances for each new effect. The instance
     * is cleared out when the effect is played because we cannot add new information
     * to the effect after it has already been started.
     */
    static protected var transformInstancePerTarget:Dictionary = new Dictionary(true);

    // TODO (chaase): consider putting the three per-target maps into one 
    // single structure
    /**
     * @private
     * These maps hold information about whether values have already been applied
     * to a target as a part of the 
     */
    static protected var appliedStartValuesPerTarget:Dictionary = new Dictionary(true);
    static protected var appliedEndValuesPerTarget:Dictionary = new Dictionary(true);
    
    /**
     * @private
     * Helper structures to hold values used in applyValues()
     */
    private static var scale:Vector3D = new Vector3D();
    private static var rotation:Vector3D = new Vector3D();
    private static var position:Vector3D = new Vector3D();

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  autoCenterTransform
    //----------------------------------

    [Inspectable(category="General", defaultValue="false")]

    /**
     * This flag controls whether the transform effect will occur
     * around the center of the target, <code>(width/2, height/2)</code>.
     * If the flag is not set, the transform center is determined by
     * the transform center of the object (<code>transformX, transformY,
     * transformZ</code>) and the <code>transformX, transformY,
     * transformZ</code> properties in this effect. That is, the
     * transform center is the transform center of the target object,
     * where any of the <code>transformX, transformY,
     * transformZ</code> properties are overriden by those
     * values in the effect, if set.
     * 
     * @default false
     * @see mx.core.UIComponent#transformX 
     * @see mx.core.UIComponent#transformY
     * @see mx.core.UIComponent#transformZ
     * @see #transformX
     * @see #transformY
     * @see #transformZ
     */
    public var autoCenterTransform:Boolean = false;
    
    //----------------------------------
    //  transformX
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /**
     * Sets the x coordinate for the transform center, unless overriden
     * by the <code>autoCenterTransform</code> property.
     * 
     * <p>If <code>autoCenterTransform</code> is not true, the transform
     * center will be determined by the <code>transformX</code>,
     * <code>transformY</code>, and <code>transformZ</code> properties
     * of the target object, but each of those properties can be
     * overriden by setting the respective properties in this effect.</p>
     * 
     * @see mx.core.UIComponent#transformX 
     * @see #autoCenterTransform
     */
    public var transformX:Number;

    //----------------------------------
    //  transformY
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /**
     * Sets the y coordinate for the transform center, unless overriden
     * by the <code>autoCenterTransform</code> property.
     * 
     * <p>If <code>autoCenterTransform</code> is not true, the transform
     * center will be determined by the <code>transformX</code>,
     * <code>transformY</code>, and <code>transformZ</code> properties
     * of the target object, but each of those properties can be
     * overriden by setting the respective properties in this effect.</p>
     * 
     * @see mx.core.UIComponent#transformY
     * @see #autoCenterTransform
     */
    public var transformY:Number;

    //----------------------------------
    //  transformZ
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /**
     * Sets the z coordinate for the transform center, unless overriden
     * by the <code>autoCenterTransform</code> property.
     * 
     * <p>If <code>autoCenterTransform</code> is not true, the transform
     * center will be determined by the <code>transformX</code>,
     * <code>transformY</code>, and <code>transformZ</code> properties
     * of the target object, but each of those properties can be
     * overriden by setting the respective properties in this effect.</p>
     * 
     * @see mx.core.UIComponent#transformZ
     * @see #autoCenterTransform
     */
    public var transformZ:Number;

    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    /**
     * Creates the instance for this effect. Unlike other effects which operate
     * autonomously, this effect uses only a single effect instance per target.
     * So all objects of type AnimateTransform or its subclasses will share this
     * one global instance. If there is already an instance created for the effect,
     * the values from the new effect will be inserted as animation values into
     * the existing instance.
     */
    override public function createInstance(target:Object = null):IEffectInstance
    {       
        if (!target)
            target = this.target;
    
        if (!transformInstancePerTarget[target])
        {
            // TODO (chaase): need to clear out this entry once the effect
            // starts (stops?) because we don't want it hanging around for
            // future runs
            var newInstance:IEffectInstance = super.createInstance(target);
            transformInstancePerTarget[target] = newInstance;
            return newInstance;
        }
        else
        {
            var instance:AnimateTransformInstance = 
                AnimateTransformInstance(transformInstancePerTarget[target]);
            initInstance(instance);
            return instance;
        }
    }
    
    /**
     * @private
     * 
     * We handle this event in order to remove the single effect instance per
     * target. We cannot correctly add values to a playing effect, so we only
     * allow combining values into the single instance before that instance
     * begins.
     */ 
    override protected function effectStartHandler(event:EffectEvent):void
    {
        super.effectStartHandler(event);
        delete transformInstancePerTarget[event.effectInstance.target];
        delete appliedStartValuesPerTarget[event.effectInstance.target];
        delete appliedEndValuesPerTarget[event.effectInstance.target];
    }
    
    /**
     * @private
     * Used internally to grab the values of the relevant properties. Note
     * that some properties are fake - translationX, translationY, 
     * and translationZ do not exist on the targets,
     * but are manufactured from a combination of the object position
     * and the transform center.
     */
    override mx_internal function captureValues(propChanges:Array,
                                       setStartValues:Boolean):Array
    {
        propChanges = super.captureValues(propChanges,setStartValues);
        var valueMap:Object;
        var i:int;
        var n:int;
        var target:Object;      
        
        n = propChanges.length;
        for (i = 0; i < n; i++)
        {
            target = propChanges[i].target;
            valueMap = setStartValues ? propChanges[i].start : propChanges[i].end;
            if (targets.indexOf(target) >= 0 &&
                (valueMap.translationX === undefined ||
                 valueMap.translationY === undefined ||
                 valueMap.translationZ === undefined))
            {
                // TODO (chaase): do we really need this?
                propChanges[i].stripUnchangedValues = false;
                
                var computedTransformCenter:Vector3D = 
                    computeTransformCenterForTarget(target); 
                var position:Vector3D = new Vector3D();
                target.transformPointToParent(computedTransformCenter, position,
                    new Vector3D());               
                valueMap.translationX = position.x;
                valueMap.translationY = position.y;
                valueMap.translationZ = position.z;
            }
        }
        return propChanges;
    }

    /**
     * @private
     * 
     * Calculates the transformCenter used by the effect instance for this
     * target. The center is calculated as:
     * - if autoCenterTransform, center around the target's x/y center
     * - else if none of transformX, transformY, transformZ are set on the
     * effect, return null. This will result in the effect simply using
     * the target's transform center
     * - else get the transformXYZ properties in the target and override
     * these values by the effects transformXYZ properties
     */
    private function computeTransformCenterForTarget(target:Object):Vector3D    
    {
        var computedTransformCenter:Vector3D;
        
        if (autoCenterTransform)
        {
            computedTransformCenter = new Vector3D(target.width/2,target.height/2,0);
        }
        else
        {
            if(!isNaN(transformX) || !isNaN(transformY) || !isNaN(transformZ))
            {
                computedTransformCenter = new Vector3D(target.transformX,
                    target.transformY, target.transformZ);
                if(!isNaN(transformX))
                    computedTransformCenter.x = transformX; 
                if(!isNaN(transformY))
                    computedTransformCenter.y = transformY; 
                if(!isNaN(transformZ))
                    computedTransformCenter.z = transformZ; 
            }
        }       
        return computedTransformCenter;
    }

    /**
     * @private
     * 
     * Utility function called by applyStartValues() and 
     * applyEndValues(). We override these functions from Effect
     * because we need to apply all transform-related properties
     * at the same time, rather than one by one, because they are
     * all interdependent.
     */
    private function applyValues(propChanges:Array, targets:Array, 
        start:Boolean):void
    {
        var appliedValuesPerTarget:Dictionary = 
            start ?
            appliedStartValuesPerTarget :
            appliedEndValuesPerTarget;
        var n:int = propChanges.length;
        for (var i:int = 0; i < n; i++)
        {
            var m:int;
            var j:int;

            var target:Object = propChanges[i].target;
            var apply:Boolean = false;
            
            if (appliedValuesPerTarget[target])
                continue;
            
            m = targets.length;
            for (j = 0; j < m; j++)
            {
                if (targets[j] == target)
                {   
                    apply = filterInstance(propChanges, target);
                    break;
                }
            }
            
            if (apply)
            {
                var effectProps:Array = relevantProperties;
                var valueMap:Object = start ? propChanges[i].start : propChanges[i].end;
                var transitionValues:Object = {
                    rotationX:NaN, rotationY:NaN, rotation:NaN,
                    scaleX:NaN, scaleY:NaN, scaleZ:NaN,
                    translationX:NaN, translationY:NaN, translationZ:NaN
                };
                                        
                // Walk the properties in the target
                m = effectProps.length;
                for (j = 0; j < m; j++)
                {
                    if (effectProps[j] in valueMap)
                    {
                        transitionValues[effectProps[j]] = valueMap[effectProps[j]];
                    }
                }
                // Now transform it
                var xformCenter:Vector3D = computeTransformCenterForTarget(target);
                var tmpScale:Vector3D;
                var tmpPosition:Vector3D;
                var tmpRotation:Vector3D;
                if (!isNaN(transitionValues.scaleX) ||
                    !isNaN(transitionValues.scaleY) || 
                    !isNaN(transitionValues.scaleZ))
                {
                    scale.x = !isNaN(transitionValues.scaleX) ?
                        transitionValues.scaleX : target["scaleX"];
                    scale.y = !isNaN(transitionValues.scaleY) ?
                        transitionValues.scaleY : target["scaleY"];
                    scale.z = !isNaN(transitionValues.scaleY) ?
                        transitionValues.scaleZ : target["scaleZ"];
                    tmpScale = scale;
                }
        
                if (!isNaN(transitionValues.rotationX) ||
                    !isNaN(transitionValues.rotationY) || 
                    !isNaN(transitionValues.rotationZ))
                {
                    rotation.x = !isNaN(transitionValues.rotationX) ? 
                        transitionValues.rotationX : target["rotationX"];
                    rotation.y = !isNaN(transitionValues.rotationY) ? 
                        transitionValues.rotationY : target["rotationY"];
                    rotation.z = !isNaN(transitionValues.rotationZ) ? 
                        transitionValues.rotationZ : target["rotationZ"];
                    tmpRotation = rotation;
                }
                
                position.x = transitionValues.translationX; 
                position.y = transitionValues.translationY; 
                position.z = transitionValues.translationZ;
                if (isNaN(position.x) || isNaN(position.y) || isNaN(position.z))
                {
                    var xformPosition:Vector3D = new Vector3D();
                    var postLayoutPosition:Vector3D = new Vector3D();
                    target.transformPointToParent(xformCenter,
                        xformPosition, postLayoutPosition);
                    if (isNaN(position.x))
                        position.x = xformPosition.x;
                    if (isNaN(position.y))
                        position.y = xformPosition.y;
                    if (isNaN(position.z))
                        position.z = xformPosition.z;
                }
                target.transformAround(xformCenter, tmpScale, tmpRotation, 
                    position);
                appliedValuesPerTarget[target] = true;
            }
        }
    }
    
    /**
     * @private
     * 
     * Applies the start values found in the array of PropertyChanges
     * to the relevant targets. Overriding because we need to set
     * transform-related properties together, not one-by-one.
     */
    mx_internal override function applyStartValues(propChanges:Array,
                                    targets:Array):void
    {
        applyValues(propChanges, targets, true);                
        super.mx_internal::applyStartValues(propChanges, targets);
    }

    /**
     * @private
     * 
     * Applies the end values found in the array of PropertyChanges
     * to the relevant targets. Overriding because we need to set
     * transform-related properties together, not one-by-one.
     */
    mx_internal override function applyEndValues(propChanges:Array,
                                    targets:Array):void
    {
        // For now, only new Flex4 effects will apply end values when transitions
        // are over, to preserve the previous behavior of Flex3 effects
        if (applyTransitionEndProperties)
        {
            applyValues(propChanges, targets, false);
            super.mx_internal::applyEndValues(propChanges, targets);
        }
    }

    /**
     * @private
     * 
     * Called by Effect.applyStartValues() and Effect.applyEndValues(). Overriding
     * to noop some property setting
     */
    override protected function applyValueToTarget(target:Object, property:String, 
                                          value:*, props:Object):void
    {
        // We've already set these properties in applyStartValues() or
        // applyEndValues() override; don't set them again here
        if (property == "translationX" || property == "translationY" ||
            property == "translationY" || property == "rotationX" ||
            property == "rotationY" || property == "rotationZ" ||
            property == "scaleX" || property == "scaleY" ||
            property == "scaleZ")
        {
            return;
        }
        else
        {
            super.applyValueToTarget(target, property, value, props);
        }
    }

    override public function getAffectedProperties():Array /* of String */
    {
        return ["translationX", "translationY", "translationZ", 
            "rotationX", "rotationY", "rotationZ", 
            "scaleX", "scaleY", "scaleZ"];
    }

    /**
     * Inserts a keyframe into an existing set of keyframes according to
     * its time. Keyframes are sorted in increasing time order.
     */
    private function insertKeyframe(keyframes:Array, newKF:KeyFrame):void
    {
        for (var i:int = 0; i < keyframes.length; i++)
        {
            if (keyframes[i].time > newKF.time)
            {
                keyframes.splice(i, 0, newKF);
                return;
            }
        }
        keyframes.push(newKF);
    }
    
    /**
     * Adds a MotionPath object to the transform effect with the
     * given parameters. If a MotionPath
     * on the same property already exists, adds the keyframes from the
     * new MotionPath object into the existing MotionPath object, sorted
     * by the time values.
     */
    protected function addMotionPath(property:String,
        valueFrom:Number = NaN, valueTo:Number = NaN, valueBy:Number = NaN):void
    {
        // First, nail down the from value with to/by, if possible
        if (isNaN(valueFrom))
        {
            if (!isNaN(valueTo) && !isNaN(valueBy))
                valueFrom = valueTo - valueBy;
        }
        // Now create a MotionPath from the result
        var mp:MotionPath = new MotionPath(property);
        mp.keyframes = [new KeyFrame(0, valueFrom),
            new KeyFrame(duration, valueTo, valueBy)];

        // Finally, integrate this MotionPath in with the existing
        // MotionPath objects, if there are any
        if (animationProperties)
        {
            var n:int = animationProperties.length;
            for (var i:int = 0; i < n; i++)
            {
                var prop:MotionPath = MotionPath(animationProperties[i]);
                if (prop.property == mp.property)
                {
                    for (var j:int = 0; j < mp.keyframes.length; j++)
                    {
                        insertKeyframe(prop.keyframes, mp.keyframes[j]);
                    }
                    return;
                }
            }
        }
        else
        {
            animationProperties = [];
        }
        animationProperties.push(mp);
    }

    // TODO (chaase): This function appears in multiple places. Maybe
    // put it in some util class instead?
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
     * @private
     * 
     * This is where we create the single instance and/or feed extra
     * MotionPath information (from othe transform-related effects) into the
     * single transform effect instance.
     */
    override protected function initInstance(instance:IEffectInstance):void
    {
        var i:int;
        
        var target:Object = instance.target;
        
        var transformInstance:AnimateTransformInstance =
            AnimateTransformInstance(instance);
        
        // Feed startDelay directly into keyframe times
        if (animationProperties)
        {            
            var instanceAnimProps:Array = [];
            for (i = 0; i < animationProperties.length; ++i)
            {
                instanceAnimProps[i] = animationProperties[i].clone();
                var mp:MotionPath = MotionPath(instanceAnimProps[i]);
                if (mp.keyframes)
                {
                    for (var j:int = 0; j < mp.keyframes.length; ++j)
                    {
                        var kf:KeyFrame = KeyFrame(mp.keyframes[j]);
                        // NaN for the time is used by AnimationProperty as a
                        // placeholder for the end time of the effect
                        if (isNaN(kf.time))
                            kf.time = duration;
                        if (startDelay != 0)
                            kf.time += startDelay;
                    }
                }
            }
            var globalStartTime:Number = getGlobalStartTime();
            for (i = 0; i < instanceAnimProps.length; ++i)
                transformInstance.addMotionPath(instanceAnimProps[i], globalStartTime);
        }
        // Multiple effects can feed into this one instance, so only init
        // it once    
        if (transformInstance.initialized)
            return;
        transformInstance.initialized = true;
        
        transformInstance.transformCenter = 
            computeTransformCenterForTarget(instance.target);
        
        // Need to hide these properties from the superclass, as they are
        // already handled in our single instance. But restore them afterwards
        // so that they are still available for reuse upon re-playing the effect
        var tmpStartDelay:Number = startDelay;
        startDelay = 0;
        var tmpAnimProps:Array = animationProperties;
        animationProperties = null;
        super.initInstance(instance);
        startDelay = tmpStartDelay;
        animationProperties = tmpAnimProps;
    }

    /**
     * @private
     * 
     * Utility method used by subclasses which returns the time, 
     * in milliseconds, when this effect starts, relative to
     * the outermost CompositeEffect. This value does not include the 
     * <code>startDelay</code> on the effect itself (which should be figured
     * into the effect's start time locally), but does include that delay
     * on any parent effects. This global start time is needed by AnimateTransform
     * and subclass effects which need to calculate the times in their keyframes
     * according to when they happen relative to each other (because of the 
     * single-instance-per-target nature of this effect).
     */
    private function getGlobalStartTime():Number
    {
        var globalStartTime:Number = 0;
        var parent:Effect = mx_internal::parentCompositeEffect;
        while (parent)
        {
            globalStartTime += parent.startDelay;
            parent = parent.mx_internal::parentCompositeEffect;
        }        
        return globalStartTime;
    }

}
}