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
 *  The AnimateTransformScale effect scales a target object
 *  in the x and y directions around the transform center.
 *  A scale of 2.0 means the object has been magnified by a factor of 2, 
 *  and a scale of 0.5 means the object has been reduced by a factor of 2.
 * 
 *  <p>Like all AnimateTransform-based effects, this effect will only work on subclasses
 *  of UIComponent and GraphicElement, as these effects depend on specific
 *  transform functions in those classes. </p>
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;mx:AnimateTransformScale&gt;</code> tag
 *  inherits all of the tag attributes of its of its superclass,
 *  and adds the following tag attributes:</p>
 *  
 *  <pre>
 *  &lt;mx:AnimateTransformScale
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
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */   
public class AnimateTransformScale extends AnimateTransform
{
    include "../core/Version.as";
    
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
     *  The starting scale factor in the y direction.
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
     * The ending scale factor in the y direction.
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
     * The starting scale factor in the x direction.
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
     * The ending scale factor in the x direction.
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
     * The factor by which to scale the object in the x direction.
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
    public var scaleXBy:Number;

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
        addMotionPath("scaleX", scaleXFrom, scaleXTo, scaleXBy);
        addMotionPath("scaleY", scaleYFrom, scaleYTo, scaleYBy);
        super.initInstance(instance);
    }    
}
}