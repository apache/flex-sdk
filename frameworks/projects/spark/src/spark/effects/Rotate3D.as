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
import mx.effects.IEffectInstance;

import spark.effects.animation.MotionPath;
import spark.effects.supportClasses.AnimateTransformInstance;

/**
 *  The Rotate3D class rotate a target object
 *  in three dimensions around the x, y, or z axes. 
 *  The rotation occurs around the transform center of the target. 
 * 
 *  <p>Like all AnimateTransform-based effects, this effect only works on subclasses
 *  of UIComponent and GraphicElement, as these effects depend on specific
 *  transform functions in those classes. 
 *  Also, transform effects running in parallel on the same target run as a single
 *  effect instance
 *  Therefore, the transform effects share the transform center 
 *  set by any of the contributing effects.</p>
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;mx:Rotate3D&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;mx:Rotate3D
 *    <b>Properties</b>
 *    id="ID"
 *    affectLayout="false"
 *    angleXBy="no default"
 *    angleXFrom="no default"
 *    angleXTo="no default"
 *    angleYBy="no default"
 *    angleYFrom="no default"
 *    angleYTo="no default"
 *    angleZBy="no default"
 *    angleZFrom="no default"
 *    angleZTo="no default"
 *  /&gt;
 *  </pre>
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */       
public class Rotate3D extends AnimateTransform
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
    public function Rotate3D(target:Object=null)
    {
        super(target);
        applyLocalProjection = true;
        instanceClass = AnimateTransformInstance;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  affectLayout
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     *  Specifies whether the parent container of the effect target 
     *  updates its layout based on changes to the effect target
     *  while the effect plays.
     *
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var affectLayout:Boolean = false;
    
    //----------------------------------
    //  angleXFrom
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     *  The starting angle of rotation of the target object around
     *  the x axis, expressed in degrees.
     *  Valid values range from 0 to 360.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var angleXFrom:Number;

    //----------------------------------
    //  angleXTo
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     *  The ending angle of rotation of the target object around
     *  the x axis, expressed in degrees.
     *  Values can be either positive or negative.
     *
     *  <p>If the value of <code>angleTo</code> is less
     *  than the value of <code>angleFrom</code>,
     *  the target rotates in a counterclockwise direction.
     *  Otherwise, it rotates in clockwise direction.
     *  If you want the target to rotate multiple times,
     *  set this value to a large positive or small negative number.</p>
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var angleXTo:Number;
    
    //----------------------------------
    //  angleXBy
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     *  Degrees by which to rotate the target object around the
     *  x axis. Value may be negative.
     *
     *  <p>If the value of <code>angleXBy</code> is negative,
     *  the target rotates in a counterclockwise direction.
     *  Otherwise, it rotates in clockwise direction.
     *  If you want the target to rotate multiple times,
     *  set this value to a large positive or small negative number.</p>
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var angleXBy:Number;
            
    //----------------------------------
    //  angleYFrom
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     *  The starting angle of rotation of the target object around
     *  the y axis, expressed in degrees.
     *  Valid values range from 0 to 360.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var angleYFrom:Number;

    //----------------------------------
    //  angleYTo
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     *  The ending angle of rotation of the target object around
     *  the y axis, expressed in degrees.
     *  Values can be either positive or negative.
     *
     *  <p>If the value of <code>angleTo</code> is less
     *  than the value of <code>angleFrom</code>,
     *  the target rotates in a counterclockwise direction.
     *  Otherwise, it rotates in clockwise direction.
     *  If you want the target to rotate multiple times,
     *  set this value to a large positive or small negative number.</p>
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var angleYTo:Number;
    
    //----------------------------------
    //  angleYBy
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     *  Degrees by which to rotate the target object around the
     *  y axis. Value may be negative.
     *
     *  <p>If the value of <code>angleYBy</code> is negative,
     *  the target rotates in a counterclockwise direction.
     *  Otherwise, it rotates in clockwise direction.
     *  If you want the target to rotate multiple times,
     *  set this value to a large positive or small negative number.</p>
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var angleYBy:Number;

    //----------------------------------
    //  angleXFrom
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     *  The starting angle of rotation of the target object around
     *  the z axis, expressed in degrees.
     *  Valid values range from 0 to 360.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var angleZFrom:Number;

    //----------------------------------
    //  angleZTo
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     *  The ending angle of rotation of the target object around
     *  the z axis, expressed in degrees.
     *  Values can be either positive or negative.
     *
     *  <p>If the value of <code>angleTo</code> is less
     *  than the value of <code>angleFrom</code>,
     *  the target rotates in a counterclockwise direction.
     *  Otherwise, it rotates in clockwise direction.
     *  If you want the target to rotate multiple times,
     *  set this value to a large positive or small negative number.</p>
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var angleZTo:Number;
    
    //----------------------------------
    //  angleZBy
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     *  Degrees by which to rotate the target object around the
     *  z axis. Value may be negative.
     *
     *  <p>If the value of <code>angleZBy</code> is negative,
     *  the target rotates in a counterclockwise direction.
     *  Otherwise, it rotates in clockwise direction.
     *  If you want the target to rotate multiple times,
     *  set this value to a large positive or small negative number.</p>
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var angleZBy:Number;

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
        if(affectLayout)
        {
            addMotionPath("rotationX", angleXFrom, angleXTo, angleXBy);
            addMotionPath("rotationY", angleYFrom, angleYTo, angleYBy);
            addMotionPath("rotationZ", angleZFrom, angleZTo, angleZBy);
        }
        else
        {
            addPostLayoutMotionPath("postLayoutRotationX", angleXFrom, angleXTo, angleXBy);
            addPostLayoutMotionPath("postLayoutRotationY", angleYFrom, angleYTo, angleYBy);
            addPostLayoutMotionPath("postLayoutRotationZ", angleZFrom, angleZTo, angleZBy);
        }
        super.initInstance(instance);
    }    
}
}