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

import mx.effects.IEffectInstance;

import spark.effects.supportClasses.AnimateTransformInstance;

/**
 * This class is a utility wrapper around the AnimateTransform effect, exposing the
 * properties that make sense for someone wishing to merely move a target object
 * in the x and y directions. An important difference between this TransformMove
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
public class AnimateTransformMove extends AnimateTransform
{
    include "../core/Version.as";

    public function AnimateTransformMove(target:Object=null)
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
    //  yBy
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /** 
     *  Number of pixels by which to modify the y of the component.
     *  Values may be negative.
     */
    public var yBy:Number;
    
    //----------------------------------
    //  yFrom
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /** 
     *  Initial y, in pixels.
     *  If omitted, Flex uses either the value in the start state,
     *  if the effect is playing in a state transition, or the current
     *  value in the target.
     */
    public var yFrom:Number;

    //----------------------------------
    //  yTo
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /** 
     *  Final y, in pixels.
     *  If omitted, Flex uses either the value in the end state,
     *  if the effect is playing in a state transition, or the current
     *  value in the target.
     */
    public var yTo:Number;
            
    //----------------------------------
    //  xBy
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /** 
     *  Number of pixels by which to modify the x of the component.
     *  Values may be negative.
     */
    public var xBy:Number;

    //----------------------------------
    //  xFrom
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /** 
     *  Initial x, in pixels.
     *  If omitted, Flex uses either the value in the starting state,
     *  if the effect is playing in a state transition, or the current
     *  value in the target.
     */
    public var xFrom:Number;
    
    //----------------------------------
    //  xTo
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /** 
     *  Final x, in pixels.
     *  If omitted, Flex uses either the value in the starting state,
     *  if the effect is playing in a state transition, or the current
     *  value in the target.
     */
    public var xTo:Number;

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    // TODO: Can we remove this override? It exists only to create motionPaths,
    // which we should be able to do somewhere else
    /**
     * @private
     */
    override public function createInstance(target:Object = null):IEffectInstance
    {
        motionPaths = [];
        return super.createInstance(target);
    }

    /**
     * @private
     */
    override protected function initInstance(instance:IEffectInstance):void
    {
        addMotionPath("translationX", xFrom, xTo, xBy);
        addMotionPath("translationY", yFrom, yTo, yBy);
        super.initInstance(instance);
    }    
}
}