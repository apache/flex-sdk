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
 * properties that make sense for someone wishing to merely scale a target object
 * in 3D around some transform center.
 * 
 * <p>Like all AnimateTransform-based effects, this effect will only work on subclasses
 * of UIComponent and GraphicElement, as these effects depend on specific
 * transform functions in those classes. Also, all of these effects run one single
 * effect instance on any given target at a time, which means that they will
 * share the transform center set by any of the contributing effects.</p>
 */   
public class AnimateTransformScale3D extends AnimateTransformScale
{
    include "../../spark.core.Version.as";

    public function AnimateTransformScale3D(target:Object=null)
    {
        super(target);
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  scaleZFrom
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /**
     * The starting scale factor in the z direction.
     */
    public var scaleZFrom:Number;

    //----------------------------------
    //  scaleZTo
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /**
     * The ending scale factor in the z direction.
     */
    public var scaleZTo:Number;
            
    //----------------------------------
    //  scaleZBy
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /**
     * The factor by which to scale the object in the z direction.
     * This is an optional parameter that can be used instead of one
     * of the other from/to values to specify the delta to add to the
     * from value or to derive the from value by subtracting from the
     * to value.
     */
    public var scaleZBy:Number;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    override protected function initInstance(instance:IEffectInstance):void
    {
        addMotionPath("scaleZ", scaleZFrom, scaleZTo, scaleZBy);
        super.initInstance(instance);
    }    
    
}
}