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

import spark.effects.supportClasses.AnimateTransformInstance;

/**
 * This class is a utility wrapper around the AnimateTransform effect, exposing the
 * properties that make sense for someone wishing to merely rotate a target object
 * in 3D, around the x, y, or z axes, based around some transform center. 
 * 
 * <p>Like all AnimateTransform-based effects, this effect will only work on subclasses
 * of UIComponent and GraphicElement, as these effects depend on specific
 * transform functions in those classes. Also, all of these effects run one single
 * effect instance on any given target at a time, which means that they will
 * share the transform center set by any of the contributing effects.</p>
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
     * Constructor.
     *
     * @param target The Object to animate with this effect.
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
     * whether or not this effect should animate the target directly or its post layout transform offsets. 
     */
    public var affectLayout:Boolean = false;
    
    //----------------------------------
    //  angleXFrom
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     * The starting angle of rotation of the target object around
     * the x axis, expressed in degrees.
     * Valid values range from 0 to 360.
     */
    public var angleXFrom:Number;

    //----------------------------------
    //  angleXTo
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     * The ending angle of rotation of the target object around
     * the x axis, expressed in degrees.
     * Values can be either positive or negative.
     *
     * <p>If the value of <code>angleTo</code> is less
     * than the value of <code>angleFrom</code>,
     * the target rotates in a counterclockwise direction.
     * Otherwise, it rotates in clockwise direction.
     * If you want the target to rotate multiple times,
     * set this value to a large positive or small negative number.</p>
     */
    public var angleXTo:Number;
    
    //----------------------------------
    //  angleXBy
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     * Degrees by which to rotate the target object around the
     * x axis. Value may be negative.
     *
     * <p>If the value of <code>angleXBy</code> is negative,
     * the target rotates in a counterclockwise direction.
     * Otherwise, it rotates in clockwise direction.
     * If you want the target to rotate multiple times,
     * set this value to a large positive or small negative number.</p>
     */
    public var angleXBy:Number;
            
    //----------------------------------
    //  angleYFrom
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     * The starting angle of rotation of the target object around
     * the y axis, expressed in degrees.
     * Valid values range from 0 to 360.
     */
    public var angleYFrom:Number;

    //----------------------------------
    //  angleYTo
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     * The ending angle of rotation of the target object around
     * the y axis, expressed in degrees.
     * Values can be either positive or negative.
     *
     * <p>If the value of <code>angleTo</code> is less
     * than the value of <code>angleFrom</code>,
     * the target rotates in a counterclockwise direction.
     * Otherwise, it rotates in clockwise direction.
     * If you want the target to rotate multiple times,
     * set this value to a large positive or small negative number.</p>
     */
    public var angleYTo:Number;
    
    //----------------------------------
    //  angleYBy
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     * Degrees by which to rotate the target object around the
     * y axis. Value may be negative.
     *
     * <p>If the value of <code>angleYBy</code> is negative,
     * the target rotates in a counterclockwise direction.
     * Otherwise, it rotates in clockwise direction.
     * If you want the target to rotate multiple times,
     * set this value to a large positive or small negative number.</p>
     */
    public var angleYBy:Number;

    //----------------------------------
    //  angleXFrom
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     * The starting angle of rotation of the target object around
     * the z axis, expressed in degrees.
     * Valid values range from 0 to 360.
     */
    public var angleZFrom:Number;

    //----------------------------------
    //  angleZTo
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     * The ending angle of rotation of the target object around
     * the z axis, expressed in degrees.
     * Values can be either positive or negative.
     *
     * <p>If the value of <code>angleTo</code> is less
     * than the value of <code>angleFrom</code>,
     * the target rotates in a counterclockwise direction.
     * Otherwise, it rotates in clockwise direction.
     * If you want the target to rotate multiple times,
     * set this value to a large positive or small negative number.</p>
     */
    public var angleZTo:Number;
    
    //----------------------------------
    //  angleZBy
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     * Degrees by which to rotate the target object around the
     * z axis. Value may be negative.
     *
     * <p>If the value of <code>angleZBy</code> is negative,
     * the target rotates in a counterclockwise direction.
     * Otherwise, it rotates in clockwise direction.
     * If you want the target to rotate multiple times,
     * set this value to a large positive or small negative number.</p>
     */
    public var angleZBy:Number;

                        
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