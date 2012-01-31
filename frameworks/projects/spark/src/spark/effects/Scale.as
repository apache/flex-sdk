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
import mx.core.mx_internal;
import mx.effects.IEffectInstance;

import spark.effects.animation.MotionPath;
import spark.effects.supportClasses.AnimateTransformInstance;

use namespace mx_internal;
    
//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="motionPaths", kind="property")]

/**
 *  The Scale effect scales a target object
 *  in the x and y directions around the transform center.
 *  A scale of 2.0 means the object has been magnified by a factor of 2, 
 *  and a scale of 0.5 means the object has been reduced by a factor of 2.
 *  A scale value of 0.0 is invalid.
 * 
 *  <p>Like all AnimateTransform-based effects, this effect will only work on subclasses
 *  of UIComponent and GraphicElement, as these effects depend on specific
 *  transform functions in those classes. </p>
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;s:Scale&gt;</code> tag
 *  inherits all of the tag attributes of its of its superclass,
 *  and adds the following tag attributes:</p>
 *  
 *  <pre>
 *  &lt;s:Scale
 *    id="ID"
 *    scaleXBy="val"
 *    scaleXFrom="val"
 *    scaleXTo="val"
 *    scaleYBy="val"
 *    scaleYFrom="val"
 *    scaleYTo="val"
 *   /&gt;
 *  </pre>
 *
 *  @includeExample examples/ScaleEffectExample.mxml
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */   
public class Scale extends AnimateTransform
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
        ["scaleX", "scaleY",
         "postLayoutScaleX","postLayoutScaleY",
         "width", "height"];

    private static var RELEVANT_STYLES:Array = [];

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
    public function Scale(target:Object=null)
    {
        super(target);
        instanceClass = AnimateTransformInstance;
        transformEffectSubclass = true;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  scaleYFrom
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /**
     *  The starting scale factor in the y direction.
     *  A scale value of 0.0 is invalid.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var scaleYFrom:Number;

    //----------------------------------
    //  scaleYTo
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /**
     *  The ending scale factor in the y direction.
     *  A scale value of 0.0 is invalid.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var scaleYTo:Number;
            
    //----------------------------------
    //  scaleYBy
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /**
     * The factor by which to scale the object in the y direction.
     * This is an optional parameter that can be used instead of one
     * of the other from/to values to specify the delta to add to the
     * from value or to derive the from value by subtracting from the
     * to value.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var scaleYBy:Number;
    
    //----------------------------------
    //  scaleXFrom
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /**
     *  The starting scale factor in the x direction.
     *  A scale value of 0.0 is invalid.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var scaleXFrom:Number;
    
    //----------------------------------
    //  scaleXTo
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /**
     *  The ending scale factor in the x direction.
     *  A scale value of 0.0 is invalid.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var scaleXTo:Number;

    //----------------------------------
    //  scaleXBy
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /**
     *  The factor by which to scale the object in the x direction.
     *  This is an optional parameter that can be used instead of one
     *  of the other from/to values to specify the delta to add to the
     *  from value or to derive the from value by subtracting from the
     *  to value.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var scaleXBy:Number;

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function get relevantStyles():Array /* of String */
    {
        return RELEVANT_STYLES;
    }   

    /**
     *  @private
     */
    override public function getAffectedProperties():Array /* of String */
    {
        return AFFECTED_PROPERTIES;
    }

    // TODO (chaase): Should try to remove this override. At a minimum, we could
    // put the motionPaths creation at the start of initInstance(). Ideally, we'd
    // remove that logic entirely, but there's a need to create motionPaths fresh
    // for every call to create/initInstance() or else multi-instance effects
    // will inherit the one motionPaths object created elsewhere.
    /**
     * @private
     */
    override public function createInstance(target:Object = null):IEffectInstance
    {
        motionPaths = new Vector.<MotionPath>();
        return super.createInstance(target);
    }

    /**
     * @private
     */
    override protected function initInstance(instance:IEffectInstance):void
    {
        var xProp:String = applyChangesPostLayout ? "postLayoutScaleX" : "scaleX";
        var yProp:String = applyChangesPostLayout ? "postLayoutScaleY" : "scaleY";
        
        addMotionPath(xProp, scaleXFrom, scaleXTo, scaleXBy);
        addMotionPath(yProp, scaleYFrom, scaleYTo, scaleYBy);
        
        super.initInstance(instance);
    }    
}
}
