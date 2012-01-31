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

package spark.effects.effectClasses
{
import flash.geom.Vector3D;

import mx.core.mx_internal;
import spark.effects.animation.Animation;
import spark.effects.AnimationProperty;
import mx.effects.Effect;
import spark.effects.Animate;
import spark.effects.supportClasses.AnimateInstance;
import spark.effects.easing.IEaser;
import spark.effects.easing.Linear;

import spark.effects.KeyFrame;
import spark.effects.MotionPath;

use namespace mx_internal;

/**
 * The instance of the AnimateTransform effect
 */
public class AnimateTransformInstance extends AnimateInstance
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * Constructor
     */
    public function AnimateTransformInstance(target:Object)
    {
        super(target);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     * Flag to indicate that this single instance of the transform-related
     * effects has already started and should not be started again. If there
     * are several transform effects running in the same effect tree, as children
     * of a CompositeEffect, then they all run as part of a single instance which
     * is started when the first transform effect is played. The remainder
     * of the transform-related effects should not be separately started, since
     * their animation data is already handled through the single instance.
     */
    private var started:Boolean = false;

    /**
     * @private
     * 
     * The time that the single transform effect instance will start, relative
     * to the top-most Effect in the effect containment hierarchy. This time
     * is used to compare against the start time of new effects adding their
     * MotionPath data to this single instance to make sure that all keyframes
     * are positioned correctly relative to each other.
     */
    private var instanceStartTime:Number = 0;

    /**
     * Default transform center used in the transform calculations when
     * transformCenter is null.
     */
    private static var defaultTransformCenter:Vector3D = new Vector3D();

    /**
     * Utility map used in applyValues()
     */
    private var currentValues:Object = {rotationX:NaN, rotationY:NaN, rotation:NaN,
                                        scaleX:NaN, scaleY:NaN, scaleZ:NaN,
                                        _rotationX:NaN, _rotationY:NaN, _rotationZ:NaN,
                                        _scaleX:NaN, _scaleY:NaN, _scaleZ:NaN };
    
    /**
     * Utility structures used in applyValues()
     */
    private static var scale:Vector3D = new Vector3D();
    private static var rotation:Vector3D = new Vector3D();
    private static var position:Vector3D = new Vector3D();

    //--------------------------------------------------------------------------
    //
    // Properties
    //
    //--------------------------------------------------------------------------

    /**
     * Flag to indicate that this single instance of the transform-related effects
     * has already been initialized. This flag is used by AnimateTransform to 
     * prevent duplicate initialization of the instance when there are multiple
     * transform effects feeding into this single instance.
     */
    public var initialized:Boolean = false;
    
    /**
     * The center around which the transformations in this effect
     * occur. In particular, rotations will rotate around this point,
     * translations will move this point, and scales will scale centered
     * around this point. If the point is not supplied, then the center
     * of the target object is assumed.
     */
    public var transformCenter:Vector3D;

    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     * 
     * This function is overriden to prevent starting the single instance more
     * than once. It will be called whenever any of the transform effects are
     * played, but it should only actually start the instance the first time.
     */
    override public function startEffect():void
    {
        if (!started)
        {
            started = true;
            super.startEffect();
        }
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
     * Insert a new keyframe into an existing keyframe array. Keyframes are sorted by
     * time, so the new keyframe must be inserted in the proper place according to its
     * time value and the startDelay time passed in
     */
    private function insertKeyframe(keyframes:Array, newKF:KeyFrame, startDelay:Number = 0):void
    {
        newKF.time += startDelay;
        for (var i:int = 0; i < keyframes.length; i++)
        {
            if (keyframes[i].time >= newKF.time)
            {
                if (keyframes[i].time > newKF.time)
                {
                    keyframes.splice(i, 0, newKF);
                    return;
                }
                else
                {
                    // don't have duplicate keyframes; combine them instead
                    // by using any valid values in newKF
                    if (newKF.easer)
                        keyframes[i].easer = newKF.easer;
                    if (isValidValue(newKF.value))
                        keyframes[i].value = newKF.value;
                    if (isValidValue(newKF.valueBy))
                        keyframes[i].valueBy = newKF.valueBy;
                    return;
                }
            }
        }
        // new keyframe must happen after last existing keyframe time
        keyframes.push(newKF);
    }
    
    /**
     * Adds the given MotionPath to the set of MotionPaths in this instance, with
     * the start time relative to the outermost parent effect.
     * If there is already a MotionPath object for this effect instance that
     * is acting on the same property as the new MotionPath, then the keyframes
     * of the new MotionPath are simply added to the existing MotionPath.
     */
    public function addMotionPath(newMotionPath:MotionPath, newEffectStartTime:Number = 0):void
    {
        if (animationProperties)
        {
            var i:int;
            var j:int;
            var prop:MotionPath;
            var n:int = animationProperties.length;
            if (newEffectStartTime < instanceStartTime)
            {
                var deltaStartTime:Number = instanceStartTime - newEffectStartTime;
                for (i = 0; i < n; i++)
                {
                    prop = MotionPath(animationProperties[i]);
                    for (j = 0; j < prop.keyframes.length; j++)
                        prop.keyframes[j].time += deltaStartTime;
                }
                instanceStartTime = newEffectStartTime;
            }
            for (i = 0; i < n; i++)
            {
                prop = MotionPath(animationProperties[i]);
                if (prop.property == newMotionPath.property)
                {
                    // add mp's keyframes here
                    for (j = 0; j < newMotionPath.keyframes.length; j++)
                    {
                        insertKeyframe(prop.keyframes, newMotionPath.keyframes[j], 
                            (newEffectStartTime - instanceStartTime));
                    }
                    return;
                }
            }
        }
        else
        {
            animationProperties = [];
            // TODO (chaase): too early to reset instanceStartTime - might use
            // it below
            instanceStartTime = newEffectStartTime;
        }
        // MotionPath on mp.property does not exist yet; add it
        if (newEffectStartTime > instanceStartTime)
        {
            for (j = 0; j < newMotionPath.keyframes.length; j++)
                newMotionPath.keyframes[j].time += 
                    (newEffectStartTime - instanceStartTime);
        }
        animationProperties.push(newMotionPath);
    }
    
    // TODO (chaase): This probably belongs at the AnimateTransform level,
    // and make sure that it only kicks in when AnimateTransform is used
    // explicitly; Someone performing a Move may not also want to
    // automatically animate the rotation properties.
    /**
     * @private
     * 
     * The main reason for this override is to handle automatically animating
     * properties which may not have been explicitly called out as keyframes
     * on the effect.
     */
    override public function play():void
    {
        var autoProps:Object = new Object();
        var transformProps:Array = effect.getAffectedProperties();
        
        if (propertyChanges)
        {
            for (var s:String in propertyChanges.end)
                if (transformProps.indexOf(s) >= 0)
                    autoProps[s] = s;
        } 
        if (animationProperties)
        {
            var i:int;
            var j:int;
            var adjustXY:Boolean = transformCenter &&
                (transformCenter.x != 0 || transformCenter.y != 0);
            for (i = 0; i < animationProperties.length; ++i)
            {
                // don't auto-animate properties already explicitly animated
                var animProp:MotionPath = animationProperties[i];
                delete autoProps[animProp.property];
                // also, adjust for tx/ty with non-default transform center
                if (adjustXY && 
                    (animProp.property == "translationX" || 
                     animProp.property == "translationY"))
                {
                    for (j = 0; j < animProp.keyframes.length; ++j)
                    {
                        var kf:KeyFrame = animProp.keyframes[j];
                        if (animProp.property == "translationX")
                            kf.value += transformCenter.x;
                        else
                            kf.value += transformCenter.y;
                    }
                }
            }
        }
        for (s in autoProps)
        {
            var mp:MotionPath = new MotionPath(s);
            mp.keyframes = [new KeyFrame(0, null), new KeyFrame(duration, null)];
            mp.mx_internal::scaleKeyframes(duration);
            if (!animationProperties)
                animationProperties = [];
            animationProperties.push(mp);
        } 
        super.play();
    }

    /**
     * @private
     * 
     * The superclass version of getCurrentValue() will only get values that
     * actually exist on the target (as properties or styles). But we need to
     * be able to get the translationXYZ values, which are fake values that
     * we derive from the transform-related properties of the target.
     * So we override this function to calculate and return the translation
     * values appropriately. 
     */
    override protected function getCurrentValue(property:String):*
    {
        // TODO (chaase): we're recalculating the transform for every 
        // component of the translation. We should store/retrieve the
        // translation property as a structure instead of separate values
        if (property == "translationX" || property == "translationY" || 
            property == "translationZ")
        {
            var position:Vector3D = new Vector3D();
            var postLayoutPosition:Vector3D = new Vector3D();
            var xformCenter:Vector3D = (transformCenter) ? 
                transformCenter : 
                defaultTransformCenter;
            target.transformPointToParent(xformCenter,
                position, postLayoutPosition);
            if (property == "translationX")
                return position.x;               
            if (property == "translationY")
                return position.y;               
            if (property == "translationZ")
                return position.z;
        }
        else
        {
            return super.getCurrentValue(property);
        }
    }

    /**
     * @private
     * 
     * We need to override this function because we need to apply all
     * transform-related properties together, not one-by-one, which would be
     * the case if we let the superclass handle this or just overrode
     * setValue().
     */
    override protected function applyValues(anim:Animation):void
    {
        var tmpScale:Vector3D;
        var tmpPosition:Vector3D;
        var tmpRotation:Vector3D;
        
        // We override this function because we want to apply all values
        // simultaneously to perform our composite transform operation
        for (var i:int = 0; i < animationProperties.length; ++i)
        {
            var holder:MotionPath = MotionPath(animationProperties[i]);
            currentValues[holder.property] = anim.currentValue[i];
        }
        if (!isNaN(currentValues.scaleX) ||
            !isNaN(currentValues.scaleY) || 
            !isNaN(currentValues.scaleZ))
        {
            scale.x = !isNaN(currentValues.scaleX) ?
                currentValues.scaleX : target["scaleX"];
            scale.y = !isNaN(currentValues.scaleY) ?
                currentValues.scaleY : target["scaleY"];
            scale.z = !isNaN(currentValues.scaleY) ?
                currentValues.scaleZ : target["scaleZ"];
            tmpScale = scale;
        }

        if (!isNaN(currentValues.rotationX) ||
            !isNaN(currentValues.rotationY) || 
            !isNaN(currentValues.rotationZ))
        {
            rotation.x = !isNaN(currentValues.rotationX) ? 
                currentValues.rotationX : getCurrentValue("rotationX");
            rotation.y = !isNaN(currentValues.rotationY) ? 
                currentValues.rotationY : getCurrentValue("rotationY");
            rotation.z = !isNaN(currentValues.rotationZ) ? 
                currentValues.rotationZ : getCurrentValue("rotationZ");
            tmpRotation = rotation;
        }
        
        position.x = !isNaN(currentValues.translationX) ? 
            currentValues.translationX : 
            getCurrentValue("translationX");
        position.y = !isNaN(currentValues.translationY) ? 
            currentValues.translationY : 
            getCurrentValue("translationY");
        position.z = !isNaN(currentValues.translationZ) ? 
            currentValues.translationZ : 
            getCurrentValue("translationZ");
        tmpPosition = position;

        target.transformAround(transformCenter, tmpScale, tmpRotation, 
            tmpPosition);
    }

}
}