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

// AdobePatentID="B998"

package spark.effects
{
import flash.geom.Vector3D;
import flash.utils.Dictionary;

import mx.core.ILayoutElement;
import mx.core.IUIComponent;
import mx.core.mx_internal;
import mx.effects.CompositeEffect;
import mx.effects.Effect;
import mx.effects.IEffectInstance;
import mx.effects.Parallel;
import mx.effects.Sequence;
import mx.events.EffectEvent;
import mx.geom.TransformOffsets;
import mx.styles.IStyleClient;

import spark.core.IGraphicElement;
import spark.effects.animation.Keyframe;
import spark.effects.animation.MotionPath;
import spark.effects.easing.IEaser;
import spark.effects.easing.Linear;
import spark.effects.supportClasses.AnimateTransformInstance;

use namespace mx_internal;

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="repeatCount", kind="property")]
[Exclude(name="repeatBehavior", kind="property")]
[Exclude(name="repeatDelay", kind="property")]

/**
 *  The AnimateTransform effect controls all transform-related animations on target
 *  objects. Transform operations, such as translation, scale, and
 *  rotation, are combined into single operations that act
 *  in parallel to avoid any conflict when modifying overlapping property values. 
 *  This effect works by combining all current transform effects
 *  on a target into one single effect instance for that target. That is, multiple
 *  transform effects within the same Parallel effect are combined (transform
 *  effects within a Sequence run separately).
 * 
 *  <p>While this combination of multiple transform effects happens
 *  internally,
 *  it does force certain constraints that should be considered:</p>
 *
 *  <ul>
 *    <li>The <code>transformCenter</code> for the target object is 
 *      globally applied to all transform effects on that target, so it 
 *      should be set to the same value on all targets.</li>
 *    <li>Transform effects ignore repeat parameters, 
 *      since the effects of any single Transform effect
 *      impact all other Transform effects running on the same target.
 *      Effects can still be repeated by encapsulating them in a 
 *      CompositeEffect.</li>
 *    <li>The subclasses of the AnimateTransform class provide an
 *      easy way for simple manipulations of the transform effect, but for
 *      full control and fine-grained manipulation of the underlying keyframe
 *      times and values, use the AnimateTransform effect directly.</li>
 *  </ul>
 *  
 *  <p>An additional constraint of this effect and its subclasses is that
 *  the target must be of type UIComponent or GraphicElement (or a subclass
 *  of those classes), or any other object which has similarly
 *  defined and implemented <code>transformAround()</code> and 
 *  <code>transformPointToParent()</code> functions.</p>
 *  
 *  <p>This effect is not intended to be used directly, but rather exposes
 *  common functionality used by its subclasses. To use transform effects,
 *  use the subclass effects (Move, Move3D, Scale, Scale3D, Rotate, and 
 *  Rotate3D).</p>
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;s:AnimateTransform&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:AnimateTransform
 *    <b>Properties</b>
 *    id="ID"
 *    applyChangesPostLayout="false"
 *    autoCenterTransform="false"
 *    transformX="0"
 *    transformY="0"
 *    transformZ="0"
 *  /&gt;
 *  </pre>
 *
 *  @see spark.effects.supportClasses.AnimateTransformInstance
 *
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */  
public class AnimateTransform extends Animate
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private static var AFFECTED_PROPERTIES:Array =
        ["translationX", "translationY", "translationZ", 
         "rotationX", "rotationY", "rotationZ", 
         "scaleX", "scaleY", "scaleZ",
         "postLayoutTranslationX","postLayoutTranslationY","postLayoutTranslationZ",
         "postLayoutRotationX","postLayoutRotationY","postLayoutRotationZ",
         "postLayoutScaleX","postLayoutScaleY","postLayoutScaleZ",
         "left", "right", "top", "bottom",
         "horizontalCenter", "verticalCenter", "baseline",
         "width", "height"];
    
    /**
     *  @private
     */
    private static var RELEVANT_STYLES:Array = 
        ["left", "right", "top", "bottom", "horizontalCenter", "verticalCenter", "baseline"];

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

    // By default, the overall AnimateTransform effect (when instantiated by
    // the leaf-node subclasses Move, Move3D, Rotate, etc.) uses Linear easing,
    // but each keyframe pair uses the regular Sine(.5) easing. This mimics the
    // behavior of other effects that just have Sine(.5) easing for their motion.
    private static var linearEaser:Linear = new Linear();
    
    // This variable is used to detect whether the transform effect was created
    // via one of the known subclasses (Move, Move3D, Rotate, etc.) or whether it
    // was created directly (AnimateTransform or AnimateTransform3D). If created
    // directly, assume the developer knows what they're doing and pass the
    // easer onto the effect instance. Otherwise, use the easing approach 
    // described in the comment for linearEaser above.
    mx_internal var transformEffectSubclass:Boolean = false;
    
    // TODO (chaase): consider putting the three per-target maps into one 
    // single structure
    /**
     * @private
     * These maps hold information about whether values have already been applied
     * to a target as a part of the transition start or end process
     */
    static private var appliedStartValuesPerTarget:Dictionary = new Dictionary(true);
    /**
     * @private
     */
    static private var appliedEndValuesPerTarget:Dictionary = new Dictionary(true);

    /**
     * The sharedObjectDepot holds shared transform effect instances on a 
     * per-toplevel-Parallel basis. That is, transform effects running in
     * parallel shares a common effect instance with other effects
     * grouped in the same Parallel tree. Effects running individually, or
     * running inside a Sequence, does not share instances. We manage this
     * by having a map-of-maps inside our sharedObjectDepot. The top-level
     * map manages the per-toplevel-Parallel maps (maps keyd from particular
     * Parallel effects), whose entries are maps that are keyed off of
     * instance targets. The reason for the separate utility class is to
     * simplify managing the map-of-maps; the depot uses a reference counter
     * so that we know, when removing the shared-instance map entries, whether
     * we can remove the top level map for a particular Paralle effect.
     */
    static private var sharedObjectDepot:SharedObjectDepot
         = new SharedObjectDepot();
             
    /**
     * @private
     * Helper structures to hold values used in applyValues()
     */
    private static var scale:Vector3D = new Vector3D();
    private static var rotation:Vector3D = new Vector3D();
    private static var position:Vector3D = new Vector3D();

    private static var offsetRotation:Vector3D = new Vector3D();
    private static var offsetTranslation:Vector3D = new Vector3D();
    private static var offsetScale:Vector3D = new Vector3D();

    private static var xformPosition:Vector3D = new Vector3D();
    private static var postLayoutPosition:Vector3D = new Vector3D();

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  applyChangesPostLayout
    //----------------------------------
    
    private var _applyChangesPostLayout:Boolean = false;
    
    [Inspectable(category="General", enumeration="true,false")]
    /** 
     *  Subclasses of AnimateTransform use this flag to specify
     *  whether the effect changes transform values used by the layout 
     *  manager, or whether it changes values used after layout is run.
     *
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get applyChangesPostLayout():Boolean
    {
        return _applyChangesPostLayout;
    }
    public function set applyChangesPostLayout(value:Boolean):void
    {
        _applyChangesPostLayout = value;
    }
    
    //----------------------------------
    //  autoCenterTransform
    //----------------------------------

    [Inspectable(category="General", defaultValue="false")]

    /**
     *  Specifies whether the transform effect occurs
     *  around the center of the target, <code>(width/2, height/2)</code>
     *  when the effect begins playing.
     *  If the flag is not set, the transform center is determined by
     *  the transform center of the object (<code>transformX, transformY,
     *  transformZ</code>) and the <code>transformX, transformY,
     *  transformZ</code> properties in this effect. That is, the
     *  transform center is the transform center of the target object,
     *  where any of the <code>transformX, transformY,
     *  transformZ</code> properties are overridden by those
     *  values in the effect, if set.
     * 
     *  @default false
     * 
     *  @see mx.core.UIComponent#transformX 
     *  @see mx.core.UIComponent#transformY
     *  @see mx.core.UIComponent#transformZ
     *  @see #transformX
     *  @see #transformY
     *  @see #transformZ
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var autoCenterTransform:Boolean = false;
    
    //----------------------------------
    //  transformX
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /**
     *  Sets the x coordinate for the transform center, unless overridden
     *  by the <code>autoCenterTransform</code> property.
     * 
     *  <p>If <code>autoCenterTransform</code> is <code>false</code>, the transform
     *  center is determined by the <code>transformX</code>,
     *  <code>transformY</code>, and <code>transformZ</code> properties
     *  of the target object, but each of those properties can be
     *  overridden by setting the respective properties in this effect.</p>
     *  
     *  @see mx.core.UIComponent#transformX 
     *  @see #autoCenterTransform
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var transformX:Number;

    //----------------------------------
    //  transformY
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /**
     *  Sets the y coordinate for the transform center, unless overridden
     *  by the <code>autoCenterTransform</code> property.
     * 
     *  <p>If <code>autoCenterTransform</code> is <code>false</code>, the transform
     *  center is determined by the <code>transformX</code>,
     *  <code>transformY</code>, and <code>transformZ</code> properties
     *  of the target object, but each of those properties can be
     *  overridden by setting the respective properties in this effect.</p>
     *  
     *  @see mx.core.UIComponent#transformY
     *  @see #autoCenterTransform
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var transformY:Number;

    //----------------------------------
    //  transformZ
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /**
     *  Sets the z coordinate for the transform center, unless overridden
     *  by the <code>autoCenterTransform</code> property.
     *  
     *  <p>If <code>autoCenterTransform</code> is <code>false</code>, the transform
     *  center is determined by the <code>transformX</code>,
     *  <code>transformY</code>, and <code>transformZ</code> properties
     *  of the target object, but each of those properties can be
     *  overridden by setting the respective properties in this effect.</p>
     *  
     *  @see mx.core.UIComponent#transformZ
     *  @see #autoCenterTransform
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var transformZ:Number;

    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    private function getOwningParallelEffect():Parallel
    {
        var prevParent:Parallel = null;
        var parent:Effect = parentCompositeEffect;
        // Only share instance for children of parallel effects
        while (parent)
        {
            if (parent is Sequence)
                break;
            prevParent = Parallel(parent);
            parent = parent.parentCompositeEffect;
        }
        return prevParent;
    }

    /**
     *  @private
     *  
     *  Creates the instance for this effect. Unlike other effects which operate
     *  autonomously, this effect uses only a single effect instance per target.
     *  So all objects of type AnimateTransform, or its subclasses, share this
     *  one global instance. If there is already an instance created for the effect,
     *  the values from the new effect is inserted as animation values into
     *  the existing instance.
     *
     *  @param target The Object to animate with this effect.  
     *
     *  @return The effect instance object for the effect. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function createInstance(target:Object = null):IEffectInstance
    {       
        if (!target)
            target = this.target;
    
        var parent:Effect = parentCompositeEffect;
        var sharedInstance:IEffectInstance = null;
        var topmostParallel:Parallel = getOwningParallelEffect();
        if (topmostParallel != null)
            sharedInstance = IEffectInstance(
                sharedObjectDepot.getSharedObject(topmostParallel, target));
        if (!sharedInstance)
        {
            var newInstance:IEffectInstance = super.createInstance(target);
            if (topmostParallel)
                sharedObjectDepot.storeSharedObject(topmostParallel, 
                    target, newInstance);
            return newInstance;
        }
        else
        {
            initInstance(sharedInstance);
            // return null to indicate that there is no 'new' instance. This 
            // keeps it from being redundantly added to composite effects
            return null;
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
        // Delete any cached info about the effect instance, such as the
        // shared transform effect instance
        var topmostParallel:Parallel = getOwningParallelEffect();
        if (topmostParallel != null)
            sharedObjectDepot.removeSharedObject(topmostParallel, 
                event.effectInstance.target);
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
                                       setStartValues:Boolean,
                                       targetsToCapture:Array = null):Array
    {
        propChanges = super.captureValues(propChanges, setStartValues, 
            targetsToCapture);
        var valueMap:Object;
        var i:int;
        var n:int;
        var target:Object;      
        
        n = propChanges.length;
        for (i = 0; i < n; i++)
        {
            target = propChanges[i].target;
            if (targetsToCapture == null || targetsToCapture.length == 0 ||
                targetsToCapture.indexOf(target) >= 0)
            {
                // For now, just make sure that we can transform the current target
                // and that the target exists on the display tree, 
                // then go ahead and capture its transform values
                if (!(target is ILayoutElement) || (!target.parent && setStartValues))
                    continue;
    
                valueMap = setStartValues ? propChanges[i].start : propChanges[i].end;

                var computedTransformCenter:Vector3D = 
                    computeTransformCenterForTarget(target, valueMap);
    
                if (valueMap.translationX === undefined ||
                    valueMap.translationY === undefined ||
                    valueMap.translationZ === undefined)
                {
                    // TODO (chaase): do we really need this?
                    propChanges[i].stripUnchangedValues = false;
                    
                    target.transformPointToParent(computedTransformCenter, xformPosition,
                        null);               
                    valueMap.translationX = xformPosition.x;
                    valueMap.translationY = xformPosition.y;
                    valueMap.translationZ = xformPosition.z;
                }
                
                
                // if someone has asked for the motionpaths to affect offsets, 
                // they might not have explcitly defined any offsets.  If that's the case, 
                // we still need to capture default start values, so let's initialize the offsets
                // to a default set anyway.
                if ((applyChangesPostLayout || postLayoutTransformPropertiesSet) && 
                    target.postLayoutTransformOffsets == null)
                {
                    target.postLayoutTransformOffsets = new TransformOffsets();
                }
                
                // if the target doesn't have any offsets, there's no need to capture
                // offset values.
                if (target.postLayoutTransformOffsets != null)
                {
                    var postLayoutTransformOffsets:TransformOffsets = target.postLayoutTransformOffsets;
                    valueMap.postLayoutRotationX = postLayoutTransformOffsets.rotationX;
                    valueMap.postLayoutRotationY = postLayoutTransformOffsets.rotationY;
                    valueMap.postLayoutRotationZ = postLayoutTransformOffsets.rotationZ;
        
                    valueMap.postLayoutScaleX = postLayoutTransformOffsets.scaleX;
                    valueMap.postLayoutScaleY = postLayoutTransformOffsets.scaleY;
                    valueMap.postLayoutScaleZ = postLayoutTransformOffsets.scaleZ;
    
                    if (valueMap.postLayoutTranslationX === undefined ||
                        valueMap.postLayoutTranslationY === undefined ||
                        valueMap.postLayoutTranslationZ === undefined)
                    {
                        // TODO (chaase): do we really need this?
                        propChanges[i].stripUnchangedValues = false;
    
                        target.transformPointToParent(computedTransformCenter, null,
                            postLayoutPosition);               
                        valueMap.postLayoutTranslationX = postLayoutPosition.x;
                        valueMap.postLayoutTranslationY = postLayoutPosition.y;
                        valueMap.postLayoutTranslationZ = postLayoutPosition.z;
                    }
                }
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
    private function computeTransformCenterForTarget(target:Object, 
                                                     valueMap:Object = null):Vector3D    
    {
        var computedTransformCenter:Vector3D;
        
        if (autoCenterTransform)
        {
            var w:Number = (valueMap != null && valueMap["width"] !== undefined) ?
                valueMap["width"] :
                target.width;
            var h:Number = (valueMap != null && valueMap["height"] !== undefined) ?
                valueMap["height"] :
                target.height;
            computedTransformCenter = new Vector3D(w/2, h/2, 0);
        }
        else
        {
            // Always create a transform center, even if we do not override
            // the object's transform XYZ properties. Theoretically, a null transform
            // center should be the same as one that uses the tXYZ properties on
            // the target, but that's not the case currently.
            computedTransformCenter = new Vector3D(target.transformX,
                target.transformY, target.transformZ);
            if (!isNaN(transformX))
                computedTransformCenter.x = transformX; 
            if (!isNaN(transformY))
                computedTransformCenter.y = transformY; 
            if (!isNaN(transformZ))
                computedTransformCenter.z = transformZ;
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
                var effectProps:Array = AFFECTED_PROPERTIES;
                var valueMap:Object = start ? propChanges[i].start : propChanges[i].end;
                var otherValueMap:Object = start ? propChanges[i].end : propChanges[i].start;
                var transitionValues:Object = {
                    rotationX:NaN, rotationY:NaN, rotation:NaN,
                    scaleX:NaN, scaleY:NaN, scaleZ:NaN,
                    translationX:NaN, translationY:NaN, translationZ:NaN
                };
                                        
                // Walk the properties in the target
                m = effectProps.length;
                for (j = 0; j < m; j++)
                {
                    var propName:String = effectProps[j];
                    // Only record and apply values if they change between states
                    // Special case for tx/ty because they may change implicitly due
                    // to transform center changes
                    if (propName in valueMap &&
                        (propName == "translationX" || propName == "translationY" ||
                         propName.indexOf("postLayout") == 0 ||
                         valueMap[propName] != otherValueMap[propName]))
                    {
                        transitionValues[propName] = valueMap[propName];
                    }
                }
                // Now transform it
                var xformCenter:Vector3D = computeTransformCenterForTarget(target, valueMap);
                var tmpScale:Vector3D = null;
                var tmpPosition:Vector3D = null;
                var tmpRotation:Vector3D = null;
                
                var tmpOffsetTranslation:Vector3D = null;
                var tmpOffsetRotation:Vector3D = null;
                var tmpOffsetScale:Vector3D = null;
                
                var currentXFormPositionComputed:Boolean = false;

                if (!isNaN(transitionValues.scaleX) ||
                    !isNaN(transitionValues.scaleY) || 
                    !isNaN(transitionValues.scaleZ))
                {
                    scale.x = !isNaN(transitionValues.scaleX) ?
                        transitionValues.scaleX : target["scaleX"];
                    scale.y = !isNaN(transitionValues.scaleY) ?
                        transitionValues.scaleY : target["scaleY"];
                    scale.z = !isNaN(transitionValues.scaleZ) ?
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
                    target.transformPointToParent(xformCenter,
                        xformPosition, postLayoutPosition);
                    currentXFormPositionComputed = true;
                    if (isNaN(position.x))
                        position.x = xformPosition.x;
                    if (isNaN(position.y))
                        position.y = xformPosition.y;
                    if (isNaN(position.z))
                        position.z = xformPosition.z;
                }

                if (target.postLayoutTransformOffsets != null)
                {
                    offsetRotation.x = !isNaN(transitionValues.postLayoutRotationX) ? 
                        transitionValues.postLayoutRotationX : 0;
                    offsetRotation.y = !isNaN(transitionValues.postLayoutRotationY) ? 
                        transitionValues.postLayoutRotationY : 0;
                    offsetRotation.z = !isNaN(transitionValues.postLayoutRotationZ) ? 
                        transitionValues.postLayoutRotationZ : 0;
                    tmpOffsetRotation = offsetRotation;
                    
                    offsetScale.x = !isNaN(transitionValues.postLayoutScaleX) ? 
                        transitionValues.postLayoutScaleX : 1;
                    offsetScale.y = !isNaN(transitionValues.postLayoutScaleY) ? 
                        transitionValues.postLayoutScaleY : 1;
                    offsetScale.z = !isNaN(transitionValues.postLayoutScaleZ) ? 
                        transitionValues.postLayoutScaleZ : 1;
                    tmpOffsetScale = offsetScale;
                    
                    offsetTranslation.x = transitionValues.postLayoutTranslationX; 
                    offsetTranslation.y = transitionValues.postLayoutTranslationY;
                    offsetTranslation.z = transitionValues.postLayoutTranslationZ; 
                    
                    if (isNaN(offsetTranslation.x) ||
                        isNaN(offsetTranslation.y) || 
                        isNaN(offsetTranslation.z))
                    {

                        if (currentXFormPositionComputed == false)
                        {
                            target.transformPointToParent(xformCenter,
                                xformPosition, postLayoutPosition);
                            currentXFormPositionComputed = true;
                        }
                        
                        if (isNaN(offsetTranslation.x))
                            offsetTranslation.x = postLayoutPosition.x;
                        if (isNaN(offsetTranslation.y))
                            offsetTranslation.y = postLayoutPosition.y;
                        if (isNaN(offsetTranslation.z))
                            offsetTranslation.z = postLayoutPosition.z;
                    }

                    tmpOffsetTranslation  = offsetTranslation;
                }

                target.transformAround(xformCenter, tmpScale, tmpRotation, 
                    position,tmpOffsetScale,tmpOffsetRotation,tmpOffsetTranslation);
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
        super.applyStartValues(propChanges, targets);
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
            super.applyEndValues(propChanges, targets);
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
        // We've already set most of these properties in applyStartValues() or
        // applyEndValues() override; don't set them again here. Skip width/height
        // because they are only used to track the size for autoCenterTransform;
        // we should not apply those values as a side effect of this transform effect
        if (property == "translationX" || property == "translationY" ||
            property == "translationZ" || property == "rotationX" ||
            property == "rotationY" || property == "rotationZ" ||
            property == "scaleX" || property == "scaleY" ||
            property == "scaleZ" || 
            property == "postLayoutTranslationX" || property == "postLayoutTranslationY" ||
            property == "postLayoutTranslationZ" || property == "postLayoutRotationX" ||
            property == "postLayoutRotationY" || property == "postLayoutRotationZ" ||
            property == "postLayoutScaleX" || property == "postLayoutScaleY" ||
            property == "postLayoutScaleZ" || 
            property == "width" || property == "height"
            )
        {
            return;
        }
        else
        {
            super.applyValueToTarget(target, property, value, props);
        }
    }

    /**
     *  @private
     */
    override public function getAffectedProperties():Array /* of String */
    {
        return AFFECTED_PROPERTIES;
    }

    /**
     *  @private
     */
    override public function get relevantStyles():Array /* of String */
    {
        return RELEVANT_STYLES;
    }   

    /**
     * Inserts a keyframe into an existing set of keyframes according to
     * its time. Keyframes are sorted in increasing time order.
     */
    private function insertKeyframe(keyframes:Vector.<Keyframe>, newKF:Keyframe):void
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
     *  @private
     * 
     *  Adds a MotionPath object to the transform effect with the
     *  given parameters. 
     *  If a MotionPath object 
     *  on the same property already exists, adds the keyframes from the
     *  new MotionPath object into the existing MotionPath object, sorted
     *  by the time values.
     *
     *  @param property The name of the property being animated.
     *
     *  @param valueFrom The initial value of the property.
     *  
     *  @param valueTo The final value of the property.
     *  
     *  @param valueBy An optional parameter that specifies the delta with
     *  which to calculate either the from or to values, if one is omitted. 
     */
    mx_internal function addMotionPath(property:String,
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
        mp.keyframes = new <Keyframe>[new Keyframe(0, valueFrom),
            new Keyframe(duration, valueTo, valueBy)];
        // For transform effect subclasses (Move, Move3D, Rotate, etc.), we
        // set the easing on the keyframes and leave the overall effect easing
        // Linear. Otherwise, we end up with artifacts like including the
        // startDelay in the easing because startDelay happens via keyframes
        mp.keyframes[1].easer = easer;
        
        // Finally, integrate this MotionPath in with the existing
        // MotionPath objects, if there are any
        if (motionPaths)
        {
            var n:int = motionPaths.length;
            for (var i:int = 0; i < n; i++)
            {
                var prop:MotionPath = MotionPath(motionPaths[i]);
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
            motionPaths = new Vector.<MotionPath>();
        }
        motionPaths.push(mp);
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
     * Determine whether we are dealing with any post-layout properties
     */
    private function get postLayoutTransformPropertiesSet():Boolean
    {
        if (motionPaths)
            for (var i:int = 0; i < motionPaths.length; ++i)
            {
                if (motionPaths[i].property.indexOf("postLayout", 0) == 0)
                    return true;
            }
        return false;
    }



    /**
     * @private
     * 
     * This is where we create the single instance and/or feed extra
     * MotionPath information (from other transform-related effects) into the
     * single transform effect instance.
     */
    override protected function initInstance(instance:IEffectInstance):void
    {
        var i:int;
        var adjustedDuration:Number = duration;
        var target:Object = instance.target;
        
        var transformInstance:AnimateTransformInstance =
            AnimateTransformInstance(instance);

            
        if (postLayoutTransformPropertiesSet)
        {
            // there are two ways we can be affecting post-layout values.
            // first, if the user has explicity asked the motion paths to be post layout by setting the motionPathsAffectLayout
            // flag.  In that case, we can assume that they need an offsets object if one doesn't already exist.
            // Second, if we captured post-layout changes from a state change. In that case, we can assume that since values were captured,
            // offsets must already exist.      
            if (target.postLayoutTransformOffsets == null)
                target.postLayoutTransformOffsets = new TransformOffsets();
        }
        // Feed startDelay directly into keyframe times
        if (motionPaths)
        {            
            var instanceAnimProps:Array = [];
            for (i = 0; i < motionPaths.length; ++i)
            {
                instanceAnimProps[i] = motionPaths[i].clone();
                var mp:MotionPath = MotionPath(instanceAnimProps[i]);
                if (mp.keyframes)
                {
                    for (var j:int = 0; j < mp.keyframes.length; ++j)
                    {
                        var kf:Keyframe = Keyframe(mp.keyframes[j]);
                        // NaN for the time is used by SimpleMotionPath as a
                        // placeholder for the end time of the effect
                        if (isNaN(kf.time))
                            kf.time = duration;
                        if (startDelay != 0)
                            kf.time += startDelay;
                    }
                    adjustedDuration = Math.max(adjustedDuration, 
                        mp.keyframes[mp.keyframes.length - 1].time);
                }
            }
            var globalStartTime:Number = getGlobalStartTime();
            for (i = 0; i < instanceAnimProps.length; ++i)
                transformInstance.addMotionPath(instanceAnimProps[i], globalStartTime);
        }
        // Tell the instance which properties/styles to check for state
        // transition changes
        var s:String;
        for each (s in getAffectedProperties())
            if (relevantStyles.indexOf(s) < 0)
                transformInstance.affectedProperties[s] = s;
        for each (s in relevantStyles)
            transformInstance.layoutConstraints[s] = s;
            
        // Multiple effects can feed into this one instance, so only init
        // it once    
        if (transformInstance.initialized)
            return;
        transformInstance.initialized = true;

        // Only use transformCenter in instance if not auto-centering
        if (!autoCenterTransform)
            transformInstance.transformCenter = 
                computeTransformCenterForTarget(instance.target);
        transformInstance.autoCenterTransform = autoCenterTransform;
        
        // Need to hide these properties from the superclass, as they are
        // already handled in our single instance. But restore them afterwards
        // so that they are still available for reuse upon re-playing the effect
        var tmpStartDelay:Number = startDelay;
        startDelay = 0;
        var tmpAnimProps:Vector.<MotionPath> = motionPaths;
        motionPaths = null;
        super.initInstance(instance);
        startDelay = tmpStartDelay;
        motionPaths = tmpAnimProps;
        transformInstance.duration = Math.max(duration, adjustedDuration);
        // For transform effect subclasses (Move, Move3D, Rotate, etc.), 
        // override default easer on the instance. We want the overall easing
        // to be Linear, with the Keyframes controlling the per-interval easing
        if (transformEffectSubclass)
            transformInstance.easer = linearEaser;
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
        var parent:Effect = parentCompositeEffect;
        while (parent)
        {
            globalStartTime += parent.startDelay;
            if (parent is Sequence)
            {
                var sequence:Sequence = Sequence(parent);
                for (var i:int = 0; i < sequence.children.length; ++i)
                {
                    var child:Effect = sequence.children[i];
                    if (child == this)
                        break;
                    if (child is CompositeEffect)
                        globalStartTime += CompositeEffect(child).compositeDuration;
                    else
                        globalStartTime += child.startDelay + 
                            (child.duration * child.repeatCount) +
                            (child.repeatDelay + (child.repeatCount - 1));
                }
            }
            parent = parent.parentCompositeEffect;
        }        
        return globalStartTime;
    }

}
}
