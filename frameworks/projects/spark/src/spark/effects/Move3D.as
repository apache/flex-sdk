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
 *  The Move3D class moves a target object in the x, y, and z dimensions.
 *  The x, y, and z property specifications of the Move3D effect specify 
 *  the change in x, y, and z that should occur to the transform center around
 *  which the overall transform effect occurs. 
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
 *  <p>The <code>&lt;mx:Move3D&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;mx:Move3D
 *    <b>Properties</b>
 *    id="ID"
 *    zBy="no default"
 *    zFrom="no default"
 *    zTo="no default"
 *  /&gt;
 *  </pre>
 *
 *  @see spark.effects.Move
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */   
public class Move3D extends Move
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
    public function Move3D(target:Object=null)
    {
        super(target);
        affectLayout = false;
        applyLocalProjection = true;
        instanceClass = AnimateTransformInstance;
    }
        
    //----------------------------------
    //  zBy
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /** 
     *  Number of pixels by which to modify the z position of the target.
     *  Values may be negative.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var zBy:Number;
    
    //----------------------------------
    //  zFrom
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /** 
     *  Initial z position of the target.
     *  If omitted, Flex uses either the value in the starting view state, 
     *  if the effect is playing in a transition, or the current value of the target.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var zFrom:Number;

    //----------------------------------
    //  zTo
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /** 
     *  Final z position of the target.
     *  If omitted, Flex uses either the value in the starting state, 
     *  if the effect is playing in a state transition, or the current value of the target.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        if(affectLayout)
        {
            addMotionPath("translationZ", zFrom, zTo, zBy);
        }
        else
        {
            addPostLayoutMotionPath("postLayoutTranslationZ", zFrom, zTo, zBy);
        }
        super.initInstance(instance);
    }    
}
}