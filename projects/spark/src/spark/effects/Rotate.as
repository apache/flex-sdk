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

import spark.effects.effectClasses.AnimateTransformInstance;
    
/**
 * This class is a utility wrapper around the AnimateTransform effect, exposing the
 * properties that make sense for someone wishing to merely rotate a target object
 * in the xy plane around some transform center. 
 * 
 * <p>Like all AnimateTransform-based effects, this effect will only work on subclasses
 * of UIComponent and GraphicElement, as these effects depend on specific
 * transform functions in those classes. Also, all of these effects run one single
 * effect instance on any given target at a time, which means that they will
 * share the transform center set by any of the contributing effects.</p>
 */   
public class AnimateTransformRotate extends AnimateTransform
{
    include "../../mx/core/Version.as";

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
    public function AnimateTransformRotate(target:Object=null)
    {
        super(target);
        instanceClass = AnimateTransformInstance;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  angleFrom
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     * The starting angle of rotation of the target object,
     * expressed in degrees.
     * Valid values range from 0 to 360.
     */
    public var angleFrom:Number;

    //----------------------------------
    //  angleTo
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     * The ending angle of rotation of the target object,
     * expressed in degrees.
     * Values can be either positive or negative.
     *
     * <p>If the value of <code>angleTo</code> is less
     * than the value of <code>angleFrom</code>,
     * the target rotates in a counterclockwise direction.
     * Otherwise, it rotates in clockwise direction.
     * If you want the target to rotate multiple times,
     * set this value to a large positive or small negative number.</p>
     */
    public var angleTo:Number;
    
    //----------------------------------
    //  angleBy
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     * Degrees by which to rotate the target object. Value
     * may be negative.
     *
     * <p>If the value of <code>angleBy</code> is negative,
     * the target rotates in a counterclockwise direction.
     * Otherwise, it rotates in clockwise direction.
     * If you want the target to rotate multiple times,
     * set this value to a large positive or small negative number.</p>
     */
    public var angleBy:Number;
            
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    // TODO: Can we remove this override? It exists only to create animationProperties,
    // which we should be able to do somewhere else
    /**
     * @private
     */
    override public function createInstance(target:Object = null):IEffectInstance
    {
        animationProperties = [];
        return super.createInstance(target);
    }
    
    /**
     * @private
     */
    override protected function initInstance(instance:IEffectInstance):void
    {
        addMotionPath("rotationZ", angleFrom, angleTo, angleBy);
        super.initInstance(instance);
    }    
}
}