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
import flash.geom.Vector3D;

import mx.core.IUIComponent;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.effects.Effect;

import spark.effects.Animate;
import spark.effects.KeyFrame;
import spark.effects.MotionPath;
import spark.effects.animation.Animation;
import spark.effects.easing.IEaser;
import spark.effects.easing.Linear;

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
    public var applyLocalProjection:Boolean = true;    
    /**
     *  @private
     */
    public var autoCenterProjection:Boolean = true;
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
     *  Default transform center used in the transform calculations when
     *  transformCenter is null.
     */
    private static var defaultTransformCenter:Vector3D = new Vector3D();

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
     *  around this point. If the point is not supplied, then the center
     *  of the target object is used.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        if (motionPaths)
        {
            var i:int;
            var j:int;
            var prop:MotionPath;
            var n:int = motionPaths.length;
            if (newEffectStartTime < instanceStartTime)
            {
                var deltaStartTime:Number = instanceStartTime - newEffectStartTime;
                for (i = 0; i < n; i++)
                {
                    prop = MotionPath(motionPaths[i]);
                    for (j = 0; j < prop.keyframes.length; j++)
                        prop.keyframes[j].time += deltaStartTime;
                }
                instanceStartTime = newEffectStartTime;
            }
            for (i = 0; i < n; i++)
            {
                prop = MotionPath(motionPaths[i]);
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
            motionPaths = [];
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
        motionPaths.push(newMotionPath);
    }
    
   /**
     *  Documentation is not currently available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function initProjection():void
    {
        if(applyLocalProjection)
        {
            // TODO (rfrishbe): need to check for IUIComponent?
            var parent:UIComponent = target.parent;
            
            if(parent != null)
            {                    
                originalProjection = parent.$transform.perspectiveProjection;
                var p:PerspectiveProjection = new PerspectiveProjection();
                if(!isNaN(fieldOfView))
                    p.fieldOfView = fieldOfView;
                if(!isNaN(focalLength))
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
                 
                parent.$transform.perspectiveProjection = p;        
            }
        }       
        
    }
    
   /**
     *  Documentation is not currently available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function removeProjection():void
    {
        if(applyLocalProjection && removeLocalProjectionWhenComplete)
        {
            // TODO (rfrishbe): need to check for IUIComponent? 
            // as well if checking for IVisualElement?
            var parent:DisplayObject= target.parent as DisplayObject;
            
            if(parent is UIComponent)
            {
                (parent as UIComponent).$transform.perspectiveProjection = originalProjection;
            }
            else if (parent != null)
            {
                parent.transform.perspectiveProjection = originalProjection;
            }
        }
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
        
        if (propertyChanges)
        {
            for (var s:String in propertyChanges.end)
                if (TRANSFORM_PROPERTIES.indexOf(s) >= 0 &&
                    propertyChanges.end[s] !== undefined &&
                    propertyChanges.start[s] != propertyChanges.end[s])
                {
                    autoProps[s] = s;
                }
        } 
        if (motionPaths)
        {
            var i:int;
            var j:int;
            var adjustXY:Boolean = transformCenter &&
                (transformCenter.x != 0 || transformCenter.y != 0);
            for (i = 0; i < motionPaths.length; ++i)
            {
                // don't auto-animate properties already explicitly animated
                var animProp:MotionPath = motionPaths[i];
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
            mp.scaleKeyframes(duration);
            if (!motionPaths)
                motionPaths = [];
            motionPaths.push(mp);
        }
        // TODO (chaase): We probably need to advertise percentWidth/Height
        // in the affected properties/styles arrays; we don't pick these up
        // in the transition propertyChanges automatically otherwise 
        if (propertyChanges && !disableConstraints)
        {
            setupConstraintAnimation("left");
            setupConstraintAnimation("right");
            setupConstraintAnimation("top");
            setupConstraintAnimation("bottom");
            setupConstraintAnimation("percentWidth");
            setupConstraintAnimation("percentHeight");
            setupConstraintAnimation("horizontalCenter");
            setupConstraintAnimation("verticalCenter");
            // TODO (chaase): also deal with baseline when it works in BasicLayout
        }
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
	            var xformCenter:Vector3D = (transformCenter) ? 
	                transformCenter : 
	                defaultTransformCenter;
	            target.transformPointToParent(xformCenter,
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
	            xformCenter  = (transformCenter) ? 
	                transformCenter : 
	                defaultTransformCenter;
	            target.transformPointToParent(xformCenter,
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
	        	return (target.offsets == null)? 0:target.offsets.rotationX;
	        case "postLayoutRotationY":
	        	return (target.offsets == null)? 0:target.offsets.rotationY;
	        case "postLayoutRotationZ":
	        	return (target.offsets == null)? 0:target.offsets.rotationZ;
	        case "postLayoutScaleX":
	        	return (target.offsets == null)? 1:target.offsets.scaleX;
	        case "postLayoutScaleY":
	        	return (target.offsets == null)? 1:target.offsets.scaleY;
	        case "postLayoutScaleZ":
	        	return (target.offsets == null)? 1:target.offsets.scaleZ;
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

		if(target.offsets != null)
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
		}
		
        target.transformAround(transformCenter, tmpScale, tmpRotation, 
            tmpPosition,tmpOffsetScale,tmpOffsetRotation,tmpOffsetTranslation);
    }

}
}