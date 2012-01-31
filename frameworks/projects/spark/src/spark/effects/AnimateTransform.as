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

import mx.core.IUIComponent;
import mx.core.mx_internal;
import mx.effects.Effect;
import mx.effects.IEffectInstance;
import mx.events.EffectEvent;
import mx.geom.TransformOffsets;
import mx.styles.IStyleClient;

import spark.core.IGraphicElement;
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
 *  objects. Transform operations, such s translation, scale, and
 *  rotation, are combined into single operations that act
 *  in parallel to avoid any conflict when modifying overlapping property values. 
 *  This effect works by combining all current transform effects
 *  on a target into one single effect instance for that target.
 * 
 *  <p>The transform is controlled by animating the properties of
 *  translation (<code>translationX</code>, <code>translationY</code>, 
 *  and <code>translationZ</code>), 
 *  rotation (<code>rotationX</code>, <code>rotationY</code>,
 *  and <code>rotationZ</code>), and 
 *  scale (<code>scaleX</code>, <code>scaleY</code>, <code>scaleZ</code>). 
 *  If any of
 *  these properties are not provided in the set of MotionPath objects
 *  for this effect, then it is assumed that these properties can
 *  be derived from the object and are not changing during the course
 *  of this effect.</p>
 * 
 *  <p>Note that the translation properties
 *  (<code>translationX</code>, <code>translationY</code>, 
 *  and <code>translationZ</code>)
 *  specify how much the transform center of the target moves during
 *  the animation, not the absolute locations of the x, y, and z
 *  coordinate of the target. Typically, these mean the same thing
 *  because the transform center of the target is at (0, 0, 0) by default. </p>
 * 
 *  <p>But if you explicitly set the location of the transform center, or set 
 *  the <code>autoCenterTransform</code> property to true, 
 *  the transform center of the target is not (0, 0, 0).</p>
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
 *  defined and implements the <code>transformAround()</code> and 
 *  <code>transformPointToParent()</code> functions.</p>
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;mx:AnimateTransform&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;mx:AnimateTransform
 *    <b>Properties</b>
 *    id="ID"
 *    autoCenterTransform="false"
 *    rotationX="no default"
 *    rotationY="no default"
 *    rotationZ="no default"
 *    scaleX="no default"
 *    scaleY="no default"
 *    scaleZ="no default"
 *    transformX="0"
 *    transformY="0"
 *    transformZ="0"
 *    translationX="no default"
 *    translationY="no default"
 *    translationZ="no default"
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
         "horizontalCenter", "verticalCenter"];
    
    /**
     *  @private
     */
    private static var RELEVANT_STYLES:Array = 
        ["left", "right", "top", "bottom", "horizontalCenter", "verticalCenter"];

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
    /**
     * @private
     */
    static protected var appliedEndValuesPerTarget:Dictionary = new Dictionary(true);
    
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

    // Caches the transform center when start values are captured
    // Ensures same center point used to capture and apply start and
    // end values
    // TODO (chaase): More correct approach might be to animate the 
    // transform center between start and end
    private var transformCenterPerTarget:Dictionary = new Dictionary(true);

    /**
     * @private
     * This flag is set when any of the translationXYZ, rotationXYZ, scaleXYZ
     * motion path properties are set directly
     */
    private var transformPropertiesSet:Boolean = false;

    /**
     * @private
     * This flag is set when any of the post layout translationXYZ, rotationXYZ, scaleXYZ
     * motion path properties are set directly
     */
    private var postLayoutTransformPropertiesSet:Boolean = false;

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
     *  Specifies whether the transform effect occurs
     *  around the center of the target, <code>(width/2, height/2)</code>.
     *  If the flag is not set, the transform center is determined by
     *  the transform center of the object (<code>transformX, transformY,
     *  transformZ</code>) and the <code>transformX, transformY,
     *  transformZ</code> properties in this effect. That is, the
     *  transform center is the transform center of the target object,
     *  where any of the <code>transformX, transformY,
     *  transformZ</code> properties are overriden by those
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
     *  Sets the x coordinate for the transform center, unless overriden
     *  by the <code>autoCenterTransform</code> property.
     * 
     *  <p>If <code>autoCenterTransform</code> is <code>false</code>, the transform
     *  center is determined by the <code>transformX</code>,
     *  <code>transformY</code>, and <code>transformZ</code> properties
     *  of the target object, but each of those properties can be
     *  overriden by setting the respective properties in this effect.</p>
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
     *  Sets the y coordinate for the transform center, unless overriden
     *  by the <code>autoCenterTransform</code> property.
     * 
     *  <p>If <code>autoCenterTransform</code> is <code>false</code>, the transform
     *  center is determined by the <code>transformX</code>,
     *  <code>transformY</code>, and <code>transformZ</code> properties
     *  of the target object, but each of those properties can be
     *  overriden by setting the respective properties in this effect.</p>
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
     *  Sets the z coordinate for the transform center, unless overriden
     *  by the <code>autoCenterTransform</code> property.
     *  
     *  <p>If <code>autoCenterTransform</code> is <code>false</code>, the transform
     *  center is determined by the <code>transformX</code>,
     *  <code>transformY</code>, and <code>transformZ</code> properties
     *  of the target object, but each of those properties can be
     *  overriden by setting the respective properties in this effect.</p>
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

    //----------------------------------
    //  translationX
    //----------------------------------

    /**
     * @private
     * Storage for the translationX property
     */
    private var _translationX:MotionPath;
    /**
     *  The MotionPath object describing the change in <code>x</code> during the effect.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get translationX():MotionPath
    {
        return _translationX;
    }
    public function set translationX(value:MotionPath):void
    {
        _translationX = value;
        if (value)
        {
            transformPropertiesSet = true;
            _translationX.property = "translationX";
        }
    }
    
    //----------------------------------
    //  translationY
    //----------------------------------

    /**
     * @private
     * Storage for the translationY property
     */
    private var _translationY:MotionPath;
    /**
     *  The MotionPath object describing the change in <code>y</code> during the effect.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get translationY():MotionPath
    {
        return _translationY;
    }
    public function set translationY(value:MotionPath):void
    {
        _translationY = value;
        if (value)
        {
            transformPropertiesSet = true;
            _translationY.property = "translationY";
        }
    }
    
    //----------------------------------
    //  translationX
    //----------------------------------

    /**
     * @private
     * Storage for the translationZ property
     */
    private var _translationZ:MotionPath;
    /**
     *  The MotionPath object describing the change in <code>z</code> during the effect.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get translationZ():MotionPath
    {
        return _translationZ;
    }
    public function set translationZ(value:MotionPath):void
    {
        _translationZ = value;
        if (value)
        {
            transformPropertiesSet = true;
            _translationZ.property = "translationZ";
        }
    }
    
    //----------------------------------
    //  rotationX
    //----------------------------------

    /**
     * @private
     * Storage for the rotationX property
     */
    private var _rotationX:MotionPath;
    /**
     *  The MotionPath object describing the change in rotation around the x
     *  axis during the effect.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get rotationX():MotionPath
    {
        return _rotationX;
    }
    public function set rotationX(value:MotionPath):void
    {
        _rotationX = value;
        if (value)
        {
            transformPropertiesSet = true;
            _rotationX.property = "rotationX";
        }
    }
    
    //----------------------------------
    //  rotationY
    //----------------------------------

    /**
     * @private
     * Storage for the rotationY property
     */
    private var _rotationY:MotionPath;
    /**
     *  The MotionPath object describing the change in rotation around the y
     *  axis during the effect.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get rotationY():MotionPath
    {
        return _rotationY;
    }
    public function set rotationY(value:MotionPath):void
    {
        _rotationY = value;
        if (value)
        {
            transformPropertiesSet = true;
            _rotationY.property = "rotationY";
        }
    }
    
    //----------------------------------
    //  rotationZ
    //----------------------------------

    /**
     * @private
     * Storage for the rotationZ property
     */
    private var _rotationZ:MotionPath;
    /**
     *  The MotionPath object describing the change in rotation around the z
     *  axis during the effect.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get rotationZ():MotionPath
    {
        return _rotationZ;
    }
    public function set rotationZ(value:MotionPath):void
    {
        _rotationZ = value;
        if (value)
        {
            transformPropertiesSet = true;
            _rotationZ.property = "rotationZ";
        }
    }
    
    //----------------------------------
    //  scaleX
    //----------------------------------

    /**
     * @private
     * Storage for the scaleX property
     */
    private var _scaleX:MotionPath;
    /**
     *  The MotionPath object describing the change in scale in the x direction
     *  during the effect.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get scaleX():MotionPath
    {
        return _scaleX;
    }
    public function set scaleX(value:MotionPath):void
    {
        _scaleX = value;
        if (value)
        {
            transformPropertiesSet = true;
            _scaleX.property = "scaleX";
        }
    }
    
    //----------------------------------
    //  scaleY
    //----------------------------------

    /**
     * @private
     * Storage for the scaleY property
     */
    private var _scaleY:MotionPath;
    /**
     *  The MotionPath object describing the change in scale in the y direction
     *  during the effect.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get scaleY():MotionPath
    {
        return _scaleY;
    }
    public function set scaleY(value:MotionPath):void
    {
        _scaleY = value;
        if (value)
        {
            transformPropertiesSet = true;
            _scaleY.property = "scaleY";
        }
    }
    
    //----------------------------------
    //  scaleZ
    //----------------------------------

    /**
     * @private
     * Storage for the scaleZ property
     */
    private var _scaleZ:MotionPath;
    /**
     *  The MotionPath object describing the change in scale in the z direction
     *  during the effect.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get scaleZ():MotionPath
    {
        return _scaleZ;
    }
    public function set scaleZ(value:MotionPath):void
    {
        _scaleZ = value;
        if (value)
        {
            transformPropertiesSet = true;
            _scaleZ.property = "scaleZ";
        }
    }


    //----------------------------------
    //  postLayoutTranslationX
    //----------------------------------

    /**
     * @private
     * Storage for the postLayoutTranslationX property
     */
    private var _postLayoutTranslationX:MotionPath;
    /**
     * The MotionPath describing the change in <code>x</code> during the effect
     */
    public function get postLayoutTranslationX():MotionPath
    {
        return _postLayoutTranslationX;
    }
    public function set postLayoutTranslationX(value:MotionPath):void
    {
        _postLayoutTranslationX = value;
        if (value)
        {
            postLayoutTransformPropertiesSet = true;
            _postLayoutTranslationX.property = "postLayoutTranslationX";
        }
    }
    
    //----------------------------------
    //  postLayoutTranslationY
    //----------------------------------

    /**
     * @private
     * Storage for the postLayoutTranslationY property
     */
    private var _postLayoutTranslationY:MotionPath;
    /**
     * The MotionPath describing the change in <code>y</code> during the effect
     */
    public function get postLayoutTranslationY():MotionPath
    {
        return _postLayoutTranslationY;
    }
    public function set postLayoutTranslationY(value:MotionPath):void
    {
        _postLayoutTranslationY = value;
        if (value)
        {
            postLayoutTransformPropertiesSet = true;
            _postLayoutTranslationY.property = "postLayoutTranslationY";
        }
    }
    
    //----------------------------------
    //  postLayoutTranslationX
    //----------------------------------

    /**
     * @private
     * Storage for the postLayoutTranslationZ property
     */
    private var _postLayoutTranslationZ:MotionPath;
    /**
     * The MotionPath describing the change in <code>z</code> during the effect
     */
    public function get postLayoutTranslationZ():MotionPath
    {
        return _postLayoutTranslationZ;
    }
    public function set postLayoutTranslationZ(value:MotionPath):void
    {
        _postLayoutTranslationZ = value;
        if (value)
        {
            postLayoutTransformPropertiesSet = true;
            _postLayoutTranslationZ.property = "postLayoutTranslationZ";
        }
    }
    
    //----------------------------------
    //  postLayoutRotationX
    //----------------------------------

    /**
     * @private
     * Storage for the postLayoutRotationX property
     */
    private var _postLayoutRotationX:MotionPath;
    /**
     * The MotionPath describing the change in postLayoutRotation around the x
     * axis during the effect
     */
    public function get postLayoutRotationX():MotionPath
    {
        return _postLayoutRotationX;
    }
    public function set postLayoutRotationX(value:MotionPath):void
    {
        _postLayoutRotationX = value;
        if (value)
        {
            postLayoutTransformPropertiesSet = true;
            _postLayoutRotationX.property = "postLayoutRotationX";
        }
    }
    
    //----------------------------------
    //  postLayoutRotationY
    //----------------------------------

    /**
     * @private
     * Storage for the postLayoutRotationY property
     */
    private var _postLayoutRotationY:MotionPath;
    /**
     * The MotionPath describing the change in postLayoutRotation around the y
     * axis during the effect
     */
    public function get postLayoutRotationY():MotionPath
    {
        return _postLayoutRotationY;
    }
    public function set postLayoutRotationY(value:MotionPath):void
    {
        _postLayoutRotationY = value;
        if (value)
        {
            postLayoutTransformPropertiesSet = true;
            _postLayoutRotationY.property = "postLayoutRotationY";
        }
    }
    
    //----------------------------------
    //  postLayoutRotationZ
    //----------------------------------

    /**
     * @private
     * Storage for the postLayoutRotationZ property
     */
    private var _postLayoutRotationZ:MotionPath;
    /**
     * The MotionPath describing the change in postLayoutRotation around the z
     * axis during the effect
     */
    public function get postLayoutRotationZ():MotionPath
    {
        return _postLayoutRotationZ;
    }
    public function set postLayoutRotationZ(value:MotionPath):void
    {
        _postLayoutRotationZ = value;
        if (value)
        {
            postLayoutTransformPropertiesSet = true;
            _postLayoutRotationZ.property = "postLayoutRotationZ";
        }
    }
    
    //----------------------------------
    //  postLayoutScaleX
    //----------------------------------

    /**
     * @private
     * Storage for the postLayoutScaleX property
     */
    private var _postLayoutScaleX:MotionPath;
    /**
     * The MotionPath describing the change in postLayoutScale in the x direction
     * during the effect
     */
    public function get postLayoutScaleX():MotionPath
    {
        return _postLayoutScaleX;
    }
    public function set postLayoutScaleX(value:MotionPath):void
    {
        _postLayoutScaleX = value;
        if (value)
        {
            postLayoutTransformPropertiesSet = true;
            _postLayoutScaleX.property = "postLayoutScaleX";
        }
    }
    
    //----------------------------------
    //  postLayoutScaleY
    //----------------------------------

    /**
     * @private
     * Storage for the postLayoutScaleY property
     */
    private var _postLayoutScaleY:MotionPath;
    /**
     * The MotionPath describing the change in postLayoutScale in the y direction
     * during the effect
     */
    public function get postLayoutScaleY():MotionPath
    {
        return _postLayoutScaleY;
    }
    public function set postLayoutScaleY(value:MotionPath):void
    {
        _postLayoutScaleY = value;
        if (value)
        {
            postLayoutTransformPropertiesSet = true;
            _postLayoutScaleY.property = "postLayoutScaleY";
        }
    }
    
    //----------------------------------
    //  postLayoutScaleZ
    //----------------------------------

    /**
     * @private
     * Storage for the postLayoutScaleZ property
     */
    private var _postLayoutScaleZ:MotionPath;
    /**
     * The MotionPath describing the change in postLayoutScale in the z direction
     * during the effect
     */
    public function get postLayoutScaleZ():MotionPath
    {
        return _postLayoutScaleZ;
    }
    public function set postLayoutScaleZ(value:MotionPath):void
    {
        _postLayoutScaleZ = value;
        if (value)
        {
            postLayoutTransformPropertiesSet = true;
            _postLayoutScaleZ.property = "postLayoutScaleZ";
        }
    }



    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Documentation is not currently available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var applyLocalProjection:Boolean = false;
    
    /**
     *  Documentation is not currently available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var removeLocalProjectionWhenComplete:Boolean = false;

    /**
     *  Documentation is not currently available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var autoCenterProjection:Boolean = true;
    /**
     *  Documentation is not currently available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var fieldOfView:Number;
    /**
     *  Documentation is not currently available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var focalLength:Number;
    /**
     *  Documentation is not currently available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var projectionX:Number = 0;
    /**
     *  Documentation is not currently available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var projectionY:Number = 0;
            
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Creates the instance for this effect. Unlike other effects which operate
     *  autonomously, this effect uses only a single effect instance per target.
     *  So all objects of type AnimateTransform, or its subclasses, share this
     *  one global instance. If there is already an instance created for the effect,
     *  the values from the new effect will be inserted as animation values into
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
            // TODO (chaase): should only capture values for targets of this effect.
            // currently no easy way to determine this, since if we are
            // running in a composite effect, that effect will create
            // propertyChange targets for all effect children.
            // Might want to change API of captureValues to specify the
            // targets to iterate through
            // For now, just make sure that we can transform the current target
            // then go ahead and capture values for it
            if (!(target is IUIComponent) && !(target is IGraphicElement))
                continue;

            // cache transform center at captureStartValues time; this will
            // force captureEndValues to use the transform center
            var computedTransformCenter:Vector3D;
            if (!setStartValues && transformCenterPerTarget[target] !== undefined)
            {
                computedTransformCenter = transformCenterPerTarget[target];
            }
            else
            {
                computedTransformCenter = computeTransformCenterForTarget(target);
                if (setStartValues)
                    transformCenterPerTarget[target] = computedTransformCenter;
            }

            valueMap = setStartValues ? propChanges[i].start : propChanges[i].end;
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
            if(postLayoutTransformPropertiesSet && target.offsets == null)
            {
            	target.offsets = new TransformOffsets();
            }
            
            // if the target doesn't have any offsets, there's no need to capture
            // offset values.
            if(target.offsets != null)
            {
            	var offsets:TransformOffsets = target.offsets;
            	valueMap.postLayoutRotationX = offsets.rotationX;
            	valueMap.postLayoutRotationY = offsets.rotationY;
            	valueMap.postLayoutRotationZ = offsets.rotationZ;

            	valueMap.postLayoutScaleX = offsets.scaleX;
            	valueMap.postLayoutScaleY = offsets.scaleY;
            	valueMap.postLayoutScaleZ = offsets.scaleZ;

	            if (valueMap.postLayoutTranslationX === undefined ||
	                valueMap.postLayoutTranslationY === undefined ||
	                valueMap.postLayoutTranslationZ === undefined)
	            {
    	            // TODO (chaase): do we really need this?
	                propChanges[i].stripUnchangedValues = false;

	                computedTransformCenter = 
	                    computeTransformCenterForTarget(target); 
	                target.transformPointToParent(computedTransformCenter, null,
	                    postLayoutPosition);               
	                valueMap.postLayoutTranslationX = postLayoutPosition.x;
	                valueMap.postLayoutTranslationY = postLayoutPosition.y;
	                valueMap.postLayoutTranslationZ = postLayoutPosition.z;
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
                var xformCenter:Vector3D = 
                    (transformCenterPerTarget[target] !== undefined) ?
                    transformCenterPerTarget[target] :
                    computeTransformCenterForTarget(target);
                var tmpScale:Vector3D;
                var tmpPosition:Vector3D;
                var tmpRotation:Vector3D;
                
	    	    var tmpOffsetTranslation:Vector3D;
    	    	var tmpOffsetRotation:Vector3D;
		        var tmpOffsetScale:Vector3D;
		        
		        var currentXFormPositionComputed:Boolean = false;

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

				if(target.offsets != null)
				{
					var offsets:TransformOffsets = target.offsets;
			        if (!isNaN(transitionValues.postLayoutRotationX) ||
			            !isNaN(transitionValues.postLayoutRotationY) || 
			            !isNaN(transitionValues.postLayoutRotationZ))
			        {
			            offsetRotation.x = !isNaN(transitionValues.postLayoutRotationX) ? 
			                transitionValues.postLayoutRotationX : offsets.rotationX;
			            offsetRotation.y = !isNaN(transitionValues.postLayoutRotationY) ? 
			                transitionValues.postLayoutRotationY : offsets.rotationY;
			            offsetRotation.z = !isNaN(transitionValues.postLayoutRotationZ) ? 
			                transitionValues.postLayoutRotationZ : offsets.rotationZ;
			            tmpOffsetRotation = offsetRotation;
			        }
			
			        if (!isNaN(transitionValues.postLayoutScaleX) ||
			            !isNaN(transitionValues.postLayoutScaleY) || 
			            !isNaN(transitionValues.postLayoutScaleZ))
			        {
			            offsetScale.x = !isNaN(transitionValues.postLayoutScaleX) ? 
			                transitionValues.postLayoutScaleX : offsets.scaleX;
			            offsetScale.y = !isNaN(transitionValues.postLayoutScaleY) ? 
			                transitionValues.postLayoutScaleY : offsets.scaleY;
			            offsetScale.z = !isNaN(transitionValues.postLayoutScaleZ) ? 
			                transitionValues.postLayoutScaleZ : offsets.scaleZ;
			            tmpOffsetScale = offsetScale;
			        }
			
					
		            offsetTranslation.x = transitionValues.postLayoutTranslationX; 
		            offsetTranslation.y = transitionValues.postLayoutTranslationY;
		            offsetTranslation.z = transitionValues.postLayoutTranslationZ; 
		            
			        if (isNaN(offsetTranslation.x) ||
			            isNaN(offsetTranslation.y) || 
			            isNaN(offsetTranslation.z))
			        {

	                    if(currentXFormPositionComputed == false)
	                    {
	                    	target.transformPointToParent(xformCenter,
                                xformPosition, postLayoutPosition);
                            currentXFormPositionComputed = true;
	                    }
			            
			            if(isNaN(offsetTranslation.x))
			            	offsetTranslation.x = postLayoutPosition.x;
			            if(isNaN(offsetTranslation.y))
			            	offsetTranslation.y = postLayoutPosition.y;
			            if(isNaN(offsetTranslation.z))
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
            property == "translationZ" || property == "rotationX" ||
            property == "rotationY" || property == "rotationZ" ||
            property == "scaleX" || property == "scaleY" ||
            property == "scaleZ" || 
			property == "postLayoutTranslationX" || property == "postLayoutTranslationY" ||
            property == "postLayoutTranslationZ" || property == "postLayoutRotationX" ||
            property == "postLayoutRotationY" || property == "postLayoutRotationZ" ||
            property == "postLayoutScaleX" || property == "postLayoutScaleY" ||
            property == "postLayoutScaleZ"
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

    protected function addPostLayoutMotionPath(property:String,
        valueFrom:Number = NaN, valueTo:Number = NaN, valueBy:Number = NaN):void
    {
    	if(isNaN(valueFrom) && isNaN(valueTo) && isNaN(valueBy))
    	   return;
    	   
        postLayoutTransformPropertiesSet = true;
    	addMotionPath(property,valueFrom,valueTo,valueBy);
    }
    
    /**
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
            motionPaths = [];
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

			
        if (transformPropertiesSet)
        {
            if (!motionPaths)
                motionPaths = [];
            if (_translationX)
                motionPaths.push(_translationX);
            if (_translationY)
                motionPaths.push(_translationY);
            if (_translationZ)
                motionPaths.push(_translationZ);
            if (_rotationX)
                motionPaths.push(_rotationX);
            if (_rotationY)
                motionPaths.push(_rotationY);
            if (_rotationZ)
                motionPaths.push(_rotationZ);
            if (_scaleX)
                motionPaths.push(_scaleX);
            if (_scaleY)
                motionPaths.push(_scaleY);
            if (_scaleZ)
                motionPaths.push(_scaleZ);
        }
        if (postLayoutTransformPropertiesSet)
        {
            if (!motionPaths)
                motionPaths = [];

	        // there are two ways we can be affecting post-layout values.
	        // first, if the user has explicity asked the motion paths to be post layout by setting the motionPathsAffectLayout
	        // flag.  In that case, we can assume that they need an offsets object if one doesn't already exist.
	        // Second, if we captured post-layout changes from a state change. In that case, we can assume that since values were captured,
	        // offsets must already exist.      
	        if(target.offsets == null)
	            target.offsets = new TransformOffsets();
        
            if (_postLayoutTranslationX)
                motionPaths.push(_postLayoutTranslationX);
            if (_postLayoutTranslationY)
                motionPaths.push(_postLayoutTranslationY);
            if (_postLayoutTranslationZ)
                motionPaths.push(_postLayoutTranslationZ);
            if (_postLayoutRotationX)
                motionPaths.push(_postLayoutRotationX);
            if (_postLayoutRotationY)
                motionPaths.push(_postLayoutRotationY);
            if (_postLayoutRotationZ)
                motionPaths.push(_postLayoutRotationZ);
            if (_postLayoutScaleX)
                motionPaths.push(_postLayoutScaleX);
            if (_postLayoutScaleY)
                motionPaths.push(_postLayoutScaleY);
            if (_postLayoutScaleZ)
                motionPaths.push(_postLayoutScaleZ);
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
                        var kf:KeyFrame = KeyFrame(mp.keyframes[j]);
                        // NaN for the time is used by SimpleMotionPath as a
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

        transformInstance.applyLocalProjection = applyLocalProjection;
        transformInstance.removeLocalProjectionWhenComplete = removeLocalProjectionWhenComplete;
        transformInstance.autoCenterProjection = autoCenterProjection;
        transformInstance.fieldOfView = fieldOfView;
        transformInstance.focalLength = focalLength;
        transformInstance.projectionX = projectionX;
        transformInstance.projectionY = projectionY;


        
        transformInstance.transformCenter = 
            computeTransformCenterForTarget(instance.target);
        
        // Need to hide these properties from the superclass, as they are
        // already handled in our single instance. But restore them afterwards
        // so that they are still available for reuse upon re-playing the effect
        var tmpStartDelay:Number = startDelay;
        startDelay = 0;
        var tmpAnimProps:Array = motionPaths;
        motionPaths = null;
        super.initInstance(instance);
        startDelay = tmpStartDelay;
        motionPaths = tmpAnimProps;
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