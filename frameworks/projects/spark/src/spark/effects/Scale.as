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
 * properties that make sense for someone wishing to merely scale a target object
 * in the x and y directions around some transform center.
 * 
 * <p>Like all AnimateTransform-based effects, this effect will only work on subclasses
 * of UIComponent and GraphicElement, as these effects depend on specific
 * transform functions in those classes. Also, all of these effects run one single
 * effect instance on any given target at a time, which means that they will
 * share the transform center set by any of the contributing effects.</p>
 */   
public class AnimateTransformScale extends AnimateTransform
{
    include "../core/Version.as";
    
    public function AnimateTransformScale(target:Object=null)
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
    //  scaleYFrom
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /**
     * The starting scale factor in the y direction.
     */
    public var scaleYFrom:Number;

    //----------------------------------
    //  scaleYTo
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /**
     * The ending scale factor in the y direction.
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
     */
    public var scaleYBy:Number;
    
    //----------------------------------
    //  scaleXFrom
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /**
     * The starting scale factor in the x direction.
     */
    public var scaleXFrom:Number;
    
    //----------------------------------
    //  scaleXTo
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /**
     * The ending scale factor in the x direction.
     */
    public var scaleXTo:Number;

    //----------------------------------
    //  scaleXBy
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /**
     * The factor by which to scale the object in the x direction.
     * This is an optional parameter that can be used instead of one
     * of the other from/to values to specify the delta to add to the
     * from value or to derive the from value by subtracting from the
     * to value.
     */
    public var scaleXBy:Number;

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
        addMotionPath("scaleX", scaleXFrom, scaleXTo, scaleXBy);
        addMotionPath("scaleY", scaleYFrom, scaleYTo, scaleYBy);
        super.initInstance(instance);
    }    
}
}