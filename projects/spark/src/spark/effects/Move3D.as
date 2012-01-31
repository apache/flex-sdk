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
 * properties that make sense for someone wishing to merely move a target object
 * in 3D. An important difference between this TransformMove
 * effect and the previous Move effect is that the x and y property specifications
 * for TransformMove specify not absolute values of the x/y point on the target
 * object, but rather the change in x/y that should occur to the center around
 * which the overall transform is occuring. So if, for example, the 
 * <code>autoCenterTransform</code> property is set, then the from/to/by values
 * in this effect will define how much to move the center of the target, not the 
 * (x,y) of the target.
 * 
 * <p>Like all AnimateTransform-based effects, this effect will only work on subclasses
 * of UIComponent and GraphicElement, as these effects depend on specific
 * transform functions in those classes. Also, all of these effects run one single
 * effect instance on any given target at a time, which means that they will
 * share the transform center set by any of the contributing effects.</p>
 */   
public class AnimateTransformMove3D extends AnimateTransformMove
{
    include "../../mx/core/Version.as";
    
    public function AnimateTransformMove3D(target:Object=null)
    {
        super(target);
        instanceClass = AnimateTransformInstance;
    }
        
    //----------------------------------
    //  zBy
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /** 
     *  Number of pixels by which to modify the z of the component.
     *  Values may be negative.
     */
    public var zBy:Number;
    
    //----------------------------------
    //  zFrom
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /** 
     *  Initial z.
     *  If omitted, Flex uses either the value in the start state,
     *  if the effect is playing in a state transition, or the current
     *  value in the target.
     */
    public var zFrom:Number;

    //----------------------------------
    //  zTo
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /** 
     *  Final z
     *  If omitted, Flex uses either the value in the end state,
     *  if the effect is playing in a state transition, or the current
     *  value in the target.
     */
    public var zTo:Number;

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
        addMotionPath("translationZ", zFrom, zTo, zBy);
        super.initInstance(instance);
    }    
}
}