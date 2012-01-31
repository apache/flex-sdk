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

package spark.effects.supportClasses
{
import flash.display.DisplayObject;
import flash.geom.PerspectiveProjection;
import flash.geom.Point;
import flash.geom.Transform;
import flash.geom.Vector3D;

import mx.core.UIComponent;
import mx.core.mx_internal;

import spark.components.Group;
import spark.effects.animation.Animation;
import spark.effects.animation.Keyframe;
import spark.effects.animation.MotionPath;
import spark.effects.easing.IEaser;
import spark.effects.easing.Linear;
import spark.effects.easing.Sine;

use namespace mx_internal;

/**
 *  The AnimateTransformInstance class implements the instance class for the
 *  AnimateTransform effect. Flex creates an instance of this class when
 *  it plays a AnimateTransform effect; you do not create one yourself.
 *
 *  @see spark.effects.AnimateTransform
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class AnimateTransformInstance extends AnimateInstance
{
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
     *  @private
     */
    public var applyLocalProjection:Boolean = false;    
    /**
     *  @private
     */
    public var autoCenterProjection:Boolean = false;
    /**
     *  @private
     */
    public var removeLocalProjectionWhenComplete:Boolean = false;
    /**
     *  @private
     */
    public var fieldOfView:Number;
    /**
     *  @private
     */
    public var focalLength:Number;
    /**
     *  @private
     */
    public var projectionX:Number = 0;
    /**
     *  @private
     */
    public var projectionY:Number = 0;

    /**
     *  @private
     */
    public var removeLocalPerspectiveOnEnd:Boolean = false;

    /**
     *  @private
     */
    protected var originalProjection:PerspectiveProjection;


    /**
     *  @private
     */
    private static var TRANSFORM_PROPERTIES:Array =
        ["translationX", "translationY", "translationZ", 
         "rotationX", "rotationY", "rotationZ", 
         "scaleX", "scaleY", "scaleZ",
        "postLayoutTranslationX", "postLayoutTranslationY", "postLayoutTranslationZ", 
         "postLayoutRotationX", "postLayoutRotationY", "postLayoutRotationZ", 
         "postLayoutScaleX", "postLayoutScaleY", "postLayoutScaleZ"];

    /**
     *  Flag to indicate that this single instance of the transform-related
     *  effects has already started and should not be started again. If there
     *  are several transform effects running in the same effect tree, as children
     *  of a CompositeEffect, then they all run as part of a single instance which
     *  is started when the first transform effect is played. The remainder
     *  of the transform-related effects should not be separately started, since
     *  their animation data is already handled through the single instance.
     */
    private var started:Boolean = false;

    /**
     *  @private
     *  
     *  The time that the single transform effect instance will start, relative
     *  to the top-most Effect in the effect containment hierarchy. This time
     *  is used to compare against the start time of new effects adding their
     *  MotionPath data to this single instance to make sure that all keyframes
     *  are positioned correctly relative to each other.
     */
    private var instanceStartTime:Number = 0;

    /**
     *  Utility map used in applyValues()
     */
    private var currentValues:Object = {rotationX:NaN, rotationY:NaN, rotationZ:NaN,
                                        scaleX:NaN, scaleY:NaN, scaleZ:NaN,
                                        translationX:NaN, translationY:NaN, translationZ:NaN,
                                        postLayoutRotationX:NaN, postLayoutRotationY:NaN, postLayoutRotationZ:NaN,
                                        postLayoutScaleX:NaN, postLayoutScaleY:NaN, postLayoutScaleZ:NaN,
                                        postLayoutTranslationX:NaN, postLayoutTranslationY:NaN, postLayoutTranslationZ:NaN};
    
    /**
     *  Utility structures used in applyValues()
     */
    private static var scale:Vector3D = new Vector3D();
    private static var rotation:Vector3D = new Vector3D();
    private static var position:Vector3D = new Vector3D();

    private static var offsetRotation:Vector3D = new Vector3D();
    private static var offsetTranslation:Vector3D = new Vector3D();
    private static var offsetScale:Vector3D = new Vector3D();

    private var prevWidth:Number, prevHeight:Number;

    /**
     * These maps hold the properties and layout constraints used to
     * set up automatic property animations based on state changes. They
     * are populated when the effect instance is set up according to 
     * the properties/constraints affected by each transform effect.
     */
    mx_internal var layoutConstraints:Object = new Object();
    mx_internal var affectedProperties:Object = new Object();
    

    //--------------------------------------------------------------------------
    //
    // Properties
    //
    //--------------------------------------------------------------------------

    /**
     *  If <code>true</code>, this single instance of the transform-related effects
     *  has already been initialized. This property is used by AnimateTransform to 
     *  prevent duplicate initialization of the instance when there are multiple
     *  transform effects feeding into this single instance.
     *
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var initialized:Boolean = false;
    
    /**
     *  The center around which the transformations in this effect
     *  occur. In particular, rotations rotate around this point,
     *  translations move this point, and scales scale centered
     *  around this point. This property will be ignored if 
     *  <code>autoCenterTransform</code> is true. If <code>autoCenterTransform</code>
     *  is false and <code>transformCenter</code> is not supplied, then the center
     *  of the target object is used.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var transformCenter:Vector3D;

    /**
     *  If <code>autoCenterTransform</code> is <code>true</code>, the transform
     *  center is recalculated as the effect progresses, updating to
     *  any changes in the width and height of the object. If the
     *  property is <code>false</code>, the <code>transformCenter</code> property
     *  is used instead.
     * 
     *  @copy spark.effects.AnimateTransform#animateTransform
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var autoCenterTransform:Boolean;

    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     * 
     * This function is overridden to prevent starting the single instance more
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
     * Insert a new keyframe into an existing keyframe Vector. Keyframes are sorted by
     * time, so the new keyframe must be inserted in the proper place according to its
     * time value and the startDelay time passed in
     */
    private function insertKeyframe(keyframes:Vector.<Keyframe>, 
        newKF:Keyframe, startDelay:Number = 0, first:Boolean = false):void
    {
        newKF.time += startDelay;
        for (var i:int = 0; i < keyframes.length; i++)
        {
            if (keyframes[i].time >= newKF.time)
            {
                // a new keyframe at the same time as an existing one
                // will get shifted briefly in time. This allows,
                // for example, multiple effects to be combined correctly
                // where one ends at the same time the next begins. We want the
                // first interval to use the values in the old keyframe at that
                // time, and the next interval to start from the values in the
                // new keyframe.
                // The direction of shift depends on whether this is the first
                // keyframe in a sequence (shift it forward, because it must be starting
                // *after* any existing effects) or not (shift it backward, because it must
                // end *before* any existing effects.
                if (keyframes[i].time == newKF.time)
                {
                    if (first)
                    {
                        newKF.time += .01;
                        keyframes.splice(i+1, 0, newKF);
                    }
                    else
                    {
                        newKF.time -= .01;
                        keyframes.splice(i, 0, newKF);
                    }
                }
                else
                {
                    keyframes.splice(i, 0, newKF);
                }
                return;
            }
        }
        // new keyframe must happen after last existing keyframe time
        keyframes.push(newKF);
    }
    
    /**
     *  Adds a MotionPath object to the set of MotionPath objects in this instance, 
     *  with the start time relative to the outermost parent effect. 
     *  If there is already a MotionPath object for this effect instance that 
     *  is acting on the same property as the new MotionPath object, 
     *  then the keyframes of the new MotionPath are simply added to the existing MotionPath. 
     *
     *  @param newMotionPath New MotionPath object.
     *
     *  @param newEffectStartTime Start time, in milliseconds, of the new MotionPath object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function addMotionPath(newMotionPath:MotionPath, newEffectStartTime:Number = 0):void
    {
        var added:Boolean = false;
        if (motionPaths)
        {
            var i:int;
            var j:int;
            var mp:MotionPath;
            var n:int = motionPaths.length;
            if (newEffectStartTime < instanceStartTime)
            {
                var deltaStartTime:Number = instanceStartTime - newEffectStartTime;
                for (i = 0; i < n; i++)
                {
                    mp = MotionPath(motionPaths[i]);
                    for (j = 0; j < mp.keyframes.length; j++)
                        mp.keyframes[j].time += deltaStartTime;
                }
                instanceStartTime = newEffectStartTime;
            }
            for (i = 0; i < n; i++)
            {
                mp = MotionPath(motionPaths[i]);
                if (mp.property == newMotionPath.property)
                {
                    // add mp's keyframes here
                    for (j = 0; j < newMotionPath.keyframes.length; j++)
                    {
                        insertKeyframe(mp.keyframes, newMotionPath.keyframes[j], 
                            (newEffectStartTime - instanceStartTime), (j == 0));
                    }
                    added = true;
                    break;
                }
            }
        }
        else
        {
            motionPaths = new Vector.<MotionPath>();
            instanceStartTime = newEffectStartTime;
        }
        if (!added)
        {
            // MotionPath on mp.property does not exist yet; add it
            if (newEffectStartTime > instanceStartTime)
            {
                for (j = 0; j < newMotionPath.keyframes.length; j++)
                    newMotionPath.keyframes[j].time += 
                        (newEffectStartTime - instanceStartTime);
            }
            motionPaths.push(newMotionPath);
        }
        // Now adjust the duration if new final time of any keyframe sequence
        // is greater than our current duration
        n = motionPaths.length;
        for (i = 0; i < n; i++)
        {
            mp = MotionPath(motionPaths[i]);
            var kf:Keyframe = mp.keyframes[mp.keyframes.length-1];
            if (!isNaN(kf.time))
                duration = Math.max(duration, kf.time);
        }
    }
    
   /**
     *  @private
     *  Set up the projection that will be used during the effect
     */
    private function initProjection():void
    {
        if (applyLocalProjection)
        {
            var parent:DisplayObject = target.parent;
            
            if (parent != null)
            {                    
                var parentTransform:Transform =
                    (parent is UIComponent) ?
                    UIComponent(parent).$transform :
                    parent.transform;
                originalProjection = parentTransform.perspectiveProjection;
                var p:PerspectiveProjection = new PerspectiveProjection();
                if (!isNaN(fieldOfView))
                    p.fieldOfView = fieldOfView;
                if (!isNaN(focalLength))
                    p.focalLength = focalLength;
                
                var projectionPoint:Point;
                // Get the location in local coordinates and then get
                // that location in the parent's coordinate system
                if (autoCenterProjection)
                    projectionPoint = new Point(target.getLayoutBoundsWidth(false)/2,
                        target.getLayoutBoundsHeight(false)/2);
                else
                    projectionPoint = new Point(projectionX, projectionY);
                projectionPoint = target.localToGlobal(projectionPoint);
                p.projectionCenter = parent.globalToLocal(projectionPoint);
                 
                parentTransform.perspectiveProjection = p;        
            }
        }       
        
    }
    
    /**
     *  @private
     *  Restore the projection to what it was before the effect
     *  started. 
     */
    private function removeProjection():void
    {
        if (applyLocalProjection && removeLocalProjectionWhenComplete)
        {
            var parent:DisplayObject= target.parent as DisplayObject;
            
            if (parent != null)
            {
                var parentTransform:Transform =
                    (parent is UIComponent) ?
                    UIComponent(parent).$transform :
                    parent.transform;
                parentTransform.perspectiveProjection = originalProjection;
            }
        }
    }

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
        var s:String;
        
        if (propertyChanges)
        {
            // autoProps holds the properties that we want to automatically
            // create animations for. Only do this for properties that
            // are directly related to this effect instance (affectedProperties)
            // and which change between states (propertyChanges values).
            // Skip width/height because these are only used to calculate
            // autoCenterTransform; we don't want to animate those values as
            // a side effect of a transform effect.
            for (s in propertyChanges.end)
                if (affectedProperties[s] !== undefined &&
                    propertyChanges.end[s] !== undefined &&
                    propertyChanges.start[s] !== undefined)
                {
                    if (s != "width" && s!= "height" &&
                        (s == "postLayoutTranslationX" ||
                         s == "postLayoutTranslationY" ||
                         s == "postLayoutTranslationZ" ||
                         propertyChanges.start[s] != propertyChanges.end[s]))
                    {
                        autoProps[s] = s;
                    }
                }
            if (autoProps["postLayoutTranslationZ"] === undefined && motionPaths != null)
            {
                var has3DRotation:Boolean = false;
                var has2DMove:Boolean = false;
                for (var p:int = 0; p < motionPaths.length; ++p)
                {
                    var propName:String = motionPaths[p].property;
                    if (!has3DRotation &&
                        (propName == "postLayoutRotationX" ||
                         propName == "postLayoutRotationY"))
                    {
                        has3DRotation = true;
                        if (has2DMove)
                            break;
                    }
                    else if (!has2DMove &&
                        (propName == "translationX" ||
                         propName == "translationY"))
                    {
                        has2DMove = true;
                        if (has3DRotation)
                            break;
                    }
                }
                if (has3DRotation && has2DMove)
                    autoProps["postLayoutTranslationZ"] = "postLayoutTranslationZ";
            }
        }
        if (motionPaths)
        {
            var i:int;
            var j:int;
            updateTransformCenter();
            var adjustXY:Boolean = (transformCenter.x != 0 || transformCenter.y != 0);
            for (i = 0; i < motionPaths.length; ++i)
            {
                // don't auto-animate properties already explicitly animated
                var animProp:MotionPath = motionPaths[i];
                delete autoProps[animProp.property];
                // also, adjust for tx/ty with non-default transform center
                if (adjustXY && 
                    (animProp.property == "translationX" || 
                     animProp.property == "translationY" ||
                     animProp.property == "postLayoutTranslationX" ||
                     animProp.property == "postLayoutTranslationY"))
                {
                    for (j = 0; j < animProp.keyframes.length; ++j)
                    {
                        var kf:Keyframe = animProp.keyframes[j];
                        if (isValidValue(kf.value))
                        {
                            if (animProp.property == "translationX" ||
                                animProp.property == "postLayoutTranslationX")
                            {
                                kf.value += transformCenter.x;
                            }
                            else // animProp.property == translationY || postLayoutTranslationY
                            {
                                kf.value += transformCenter.y;
                            }
                        }
                    }
                }
            }
        }
        for (s in autoProps)
        {
            if (!motionPaths)
                motionPaths = new Vector.<MotionPath>();
            var autoPropsEaser:IEaser;
            if (!autoPropsEaser)
            {
                // Attempt to use the same easer used in the existing keyframes. Assume that
                // The first set of keyframes ends with the same easing that is applied elsewhere
                // in this motion path. If that doesn't work, use Linear because we will already
                // be easing the overall effect with the easer property
                if (motionPaths.length > 0 &&
                    motionPaths[0] && motionPaths[0].keyframes && 
                    motionPaths[0].keyframes.length > 0 &&
                    motionPaths[0].keyframes[motionPaths[0].keyframes.length-1])
                {
                    autoPropsEaser = motionPaths[0].keyframes[motionPaths[0].keyframes.length-1].easer;
                }
                else
                {
                    autoPropsEaser = new Linear();
                }
            }
            var mp:MotionPath = new MotionPath(s);
            var mpDone:Boolean = false;
            if (s.indexOf("postLayoutTranslation") == 0)
            {
                // Special-case postLayoutTranslation: use any existing pre-layout values
                var preLayoutProp:String = (s == "postLayoutTranslationX") ? 
                    "translationX" :
                    (s == "postLayoutTranslationY") ?
                    "translationY" :
                    "translationZ";
                for (var k:int = 0; k < motionPaths.length; ++k)
                {
                    var preLayoutMP:MotionPath = motionPaths[k];
                    if (preLayoutMP.property == preLayoutProp)
                    {
                        mp.keyframes = new Vector.<Keyframe>(preLayoutMP.keyframes.length);
                        for (var m:int = 0; m < mp.keyframes.length; ++m)
                        {
                            mp.keyframes[m] = preLayoutMP.keyframes[m].clone();
                        }
                        mpDone = true;
                        break;
                    }
                }
            }
            if (!mpDone)
            {
                mp.keyframes = new <Keyframe>[new Keyframe(0, null), 
                    new Keyframe(duration, null)];
                mp.keyframes[1].easer = autoPropsEaser;
                mp.scaleKeyframes(duration);
            }
            motionPaths.push(mp);
        }
        if (propertyChanges && !disableLayout)
            // automatically animate layout constraints affected by this
            // effect instance if we are in a transition
            for (s in layoutConstraints)
                setupConstraintAnimation(s);
        super.play();
    }

    /**
     * @private
     * 
     */
    override public function animationStart(animation:Animation):void
    {
        initProjection();
        super.animationStart(animation);
    }
    
    /**
     * @private
     * 
     */
    override public function animationEnd(animation:Animation):void
    {
        started = false;
        removeProjection();
        super.animationEnd(animation);
    }

    /**
     * @private
     * Ensures that transformCenter has proper values for use in transform
     * calculations
     */
    private function updateTransformCenter():void
    {
        if (!transformCenter)
            transformCenter = new Vector3D(target.transformX,
                target.transformY, target.transformZ);
        if (autoCenterTransform)
        {
            transformCenter.x = target.width / 2;
            transformCenter.y = target.height / 2;
            transformCenter.z = 0;
        }
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
        switch(property)
        {
            case "translationX":
            case "translationY":
            case "translationZ":
            {
                var position:Vector3D = new Vector3D();
                updateTransformCenter();
                target.transformPointToParent(transformCenter,
                    position, null);
                if (property == "translationX")
                    return position.x;               
                if (property == "translationY")
                    return position.y;               
                if (property == "translationZ")
                    return position.z;
                break;
            }            
            case "postLayoutTranslationX":
            case "postLayoutTranslationY":
            case "postLayoutTranslationZ":
            {
                var postLayoutPosition:Vector3D = new Vector3D();
                updateTransformCenter();
                target.transformPointToParent(transformCenter,
                    null, postLayoutPosition);
                if (property == "postLayoutTranslationX")
                    return postLayoutPosition.x;               
                if (property == "postLayoutTranslationY")
                    return postLayoutPosition.y;               
                if (property == "postLayoutTranslationZ")
                    return postLayoutPosition.z;
                break;
            }
            case "postLayoutRotationX":
                return (target.postLayoutTransformOffsets == null)? 
                    0 :
                    target.postLayoutTransformOffsets.rotationX;
            case "postLayoutRotationY":
                return (target.postLayoutTransformOffsets == null)? 
                    0 :
                    target.postLayoutTransformOffsets.rotationY;
            case "postLayoutRotationZ":
                return (target.postLayoutTransformOffsets == null)? 
                    0 :
                    target.postLayoutTransformOffsets.rotationZ;
            case "postLayoutScaleX":
                return (target.postLayoutTransformOffsets == null)? 
                    1 :
                    target.postLayoutTransformOffsets.scaleX;
            case "postLayoutScaleY":
                return (target.postLayoutTransformOffsets == null)? 
                    1 :
                    target.postLayoutTransformOffsets.scaleY;
            case "postLayoutScaleZ":
                return (target.postLayoutTransformOffsets == null)? 
                    1 :
                    target.postLayoutTransformOffsets.scaleZ;
            default:
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
        
        var tmpOffsetTranslation:Vector3D;
        var tmpOffsetRotation:Vector3D;
        var tmpOffsetScale:Vector3D;
        
        // We override this function because we want to apply all values
        // simultaneously to perform our composite transform operation
        for (var i:int = 0; i < motionPaths.length; ++i)
        {
            // Collect all transform-related values in currentValues, but
            // pass any other values, like constraints, to setValue()
            if (currentValues[motionPaths[i].property] !== undefined)
                currentValues[motionPaths[i].property] = 
                    anim.currentValue[motionPaths[i].property];
            else
                setValue(motionPaths[i].property, 
                    anim.currentValue[motionPaths[i].property]);
        }
        if (autoCenterTransform)
        {
            if (!disableLayout && target.parent is Group)
                target.parent.validateNow();
            if (target.width != prevWidth || target.height != prevHeight)
            {
                prevWidth = target.width;
                prevHeight = target.height;
                updateTransformCenter();
            }
        }
        if (!isNaN(currentValues.scaleX) ||
            !isNaN(currentValues.scaleY) || 
            !isNaN(currentValues.scaleZ))
        {
            scale.x = !isNaN(currentValues.scaleX) ?
                currentValues.scaleX : target["scaleX"];
            scale.y = !isNaN(currentValues.scaleY) ?
                currentValues.scaleY : target["scaleY"];
            scale.z = !isNaN(currentValues.scaleZ) ?
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

        if (target.postLayoutTransformOffsets != null)
        {
            if (!isNaN(currentValues.postLayoutRotationX) ||
                !isNaN(currentValues.postLayoutRotationY) || 
                !isNaN(currentValues.postLayoutRotationZ))
            {
                offsetRotation.x = !isNaN(currentValues.postLayoutRotationX) ? 
                    currentValues.postLayoutRotationX : getCurrentValue("postLayoutRotationX");
                offsetRotation.y = !isNaN(currentValues.postLayoutRotationY) ? 
                    currentValues.postLayoutRotationY : getCurrentValue("postLayoutRotationY");
                offsetRotation.z = !isNaN(currentValues.postLayoutRotationZ) ? 
                    currentValues.postLayoutRotationZ : getCurrentValue("postLayoutRotationZ");
                tmpOffsetRotation = offsetRotation;
            }
    
            if (!isNaN(currentValues.postLayoutScaleX) ||
                !isNaN(currentValues.postLayoutScaleY) || 
                !isNaN(currentValues.postLayoutScaleZ))
            {
                offsetScale.x = !isNaN(currentValues.postLayoutScaleX) ? 
                    currentValues.postLayoutScaleX : getCurrentValue("postLayoutScaleX");
                offsetScale.y = !isNaN(currentValues.postLayoutScaleY) ? 
                    currentValues.postLayoutScaleY : getCurrentValue("postLayoutScaleY");
                offsetScale.z = !isNaN(currentValues.postLayoutScaleZ) ? 
                    currentValues.postLayoutScaleZ : getCurrentValue("postLayoutScaleZ");
                tmpOffsetScale = offsetScale;
            }
    
            if (!isNaN(currentValues.postLayoutTranslationX) ||
                !isNaN(currentValues.postLayoutTranslationY) || 
                !isNaN(currentValues.postLayoutTranslationZ))
            {
                offsetTranslation.x = !isNaN(currentValues.postLayoutTranslationX) ? 
                    currentValues.postLayoutTranslationX : getCurrentValue("postLayoutTranslationX");
                offsetTranslation.y = !isNaN(currentValues.postLayoutTranslationY) ? 
                    currentValues.postLayoutTranslationY : getCurrentValue("postLayoutTranslationY");
                offsetTranslation.z = !isNaN(currentValues.postLayoutTranslationZ) ? 
                    currentValues.postLayoutTranslationZ : getCurrentValue("postLayoutTranslationZ");
                tmpOffsetTranslation  = offsetTranslation;
            }
            else
            {
                tmpOffsetTranslation = tmpPosition;
            }
        }
        target.transformAround(transformCenter, tmpScale, tmpRotation, 
            tmpPosition,tmpOffsetScale,tmpOffsetRotation,tmpOffsetTranslation);
    }

}
}