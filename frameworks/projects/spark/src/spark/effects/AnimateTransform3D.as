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
import flash.utils.Dictionary;

import mx.core.IUIComponent;
import mx.core.mx_internal;
import mx.effects.CompositeEffect;
import mx.effects.Effect;
import mx.effects.IEffectInstance;
import mx.effects.Parallel;
import mx.effects.Sequence;
import mx.events.EffectEvent;
import mx.geom.TransformOffsets;
import mx.styles.IStyleClient;

import spark.core.IGraphicElement;
import spark.effects.supportClasses.AnimateTransformInstance;

use namespace mx_internal;

//--------------------------------------
//  Excluded APIs
//--------------------------------------

/**
 *  The AnimateTransform3D effect extends the abilities of 
 *  the AnimateTransform effect to 3D transform properties. Like
 *  AnimateTransform, this effect is not intended to be used directly,
 *  but instead provides common functionality that is used by its 
 *  subclasses. To get 3D effects, use the subclasses Move3D, Rotate3D,
 *  and Scale3D.
 * 
 *  <p>As with AnimateTransform, there are some properties of this
 *  affect that are shared with all other transform effects that it is
 *  combined with at runtime. In particular, the projection-related properties
 *  <code>applyLocalProjection</code>, <code>removeProjectionWhenComplete</code>,
 *  <code>autoCenterProjection</code>, <code>fieldOfView</code>, 
 *  <code>focalLength</code>, <code>projectionX</code>, and
 *  <code>projectionY</code> are all shared properties. Set these
 *  properties similarly on all 3D effects that are combined in a composite
 *  effect to get predictable results.</p>
 * 
 *  @mxml
 *
 *  <p>The <code>&lt;s:AnimateTransform&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:AnimateTransform
 *    <b>Properties</b>
 *    id="ID"
 *    applyChangesPostLayout="true"
 *    applyLocalProjection="false"
 *    autoCenterProjection="true"
 *    fieldOfView="no default"
 *    focalLength="no default"
 *    projectionX="0"
 *    projectionY="0"
 *    removeLocalProjectionWhenComplete="false"
 *  /&gt;
 *  </pre>
 *
 *  @see spark.effects.supportClasses.AnimateTransformInstance
 *
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */  
public class AnimateTransform3D extends AnimateTransform
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
    public function AnimateTransform3D(target:Object=null)
    {
        super(target);
        instanceClass = AnimateTransformInstance;
        applyChangesPostLayout = true;
    }
    

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  applyChangesPostLayout
    //----------------------------------
    [Inspectable(category="General", enumeration="true,false")]
    /** 
     *  Used by the subclasses of AnimateTransform to specify
     *  whether the effect changes transform values used by the layout 
     *  manager, or whether it changes values used after layout is run.
     *  Because the Flex layout system ignores 3D transformation properties,
     *  this class overrides the <code>AnimateTransform.applyChangesPostLayout</code> property
     *  to set the default value to <code>true</code> for 3D effects.
     *
     *  @default true
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function get applyChangesPostLayout():Boolean
    {
        return super.applyChangesPostLayout;
    }

    private var _applyLocalProjection:Boolean = true;
    /**
     *  If <code>true</code>, the effect creates a perspective projection 
     *  using the other projection-related properties in the effect
     *  and applies it to the target component's parent when it starts playing.
     *  By default, the projection is left on the parent when the effect finishes;
     *  to remove the projection when the effect ends, set 
     *  <code>removeLocalProjectionWhenComplete</code> to <code>true</code>.
     *
     *  @see #removeLocalProjectionWhenComplete
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get applyLocalProjection():Boolean
    {
        return _applyLocalProjection;
    }
    public function set applyLocalProjection(value:Boolean):void
    {
        _applyLocalProjection = value;
    }

    /**
     *  If <code>true</code>, the effect removes the perspective projection 
     *  from the target component's parent when it completes playing.
     *  By default, the perspective projection is retained.
     * 
     *  <p>This property is only used when <code>applyLocalProjection</code>
     *  is set to <code>true</code>.</p>
     *
     *  @see #applyLocalProjection
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var removeLocalProjectionWhenComplete:Boolean = false;

    /**
     *  Set to <code>false</code> to disable a 3D effect from automatically setting 
     *  the projection point to the center of the target. 
     *  You then use the <code>projectionX</code> and <code>projectionY</code> properties 
     *  to explicitly set the projection point 
     *  as the offset of the projection point from the (0, 0) coordinate of the target.
     *
     *  <p>The 3D effects work by mapping a three-dimensional image onto a two-dimensional 
     *  representation for display on a computer screen. 
     *  The projection point defines the center of the field of view, 
     *  and controls how the target is projected from three dimensions onto the screen.</p>
     *
     *  <p>This property is only used when <code>applyLocalProjection</code>
     *  is set to <code>true</code>.</p>
     *
     *  @see #applyLocalProjection
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var autoCenterProjection:Boolean = true;

    /**
     *  Specifies an angle, in degrees between <code>0</code> and <code>180</code>, 
     *  for the field of view in three dimensions. 
     *  This value determines how strong the perspective transformation and distortion apply to
     *  a three-dimensional display object with a non-zero z-coordinate.
     *
     *  <p>A degree close to <code>0</code> means that the screen's two-dimensional x- and y-coordinates are 
     *  roughly the same as the three-dimensional x-, y-, and z-coordinates with little or 
     *  no distortion. In other words, for a small angle, a display object moving down the z axis appears
     *  to stay near the same size and moves little. </p>
     *
     *  <p>A value close to <code>180</code> degrees results in a fisheye lens effect: positions 
     *  with a <code>z</code> value smaller than <code>0</code> are magnified, while positions with a 
     *  <code>z</code> value larger than <code>0</code> are minimized. With a large angle, a display object
     *  moving down the z axis appears to change size quickly and moves a great distance. If the field of view
     *  is set to <code>0</code> or <code>180</code>, nothing is seen on the screen.</p>
     *
     *  <p>This property is only used when <code>applyLocalProjection</code>
     *  is set to <code>true</code>.</p>
     *  
     *  @see #applyLocalProjection
     *  @see flash.geom.PerspectiveProjection
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var fieldOfView:Number;

    /**
     *  The distance between the eye or the viewpoint's origin (0,0,0) 
     *  and the display object located  in the z axis. During the perspective transformation, 
     *  the <code>focalLength</code> is calculated dynamically 
     *  using the angle of the field of view and the stage's aspect ratio (stage width divided by 
     *  stage height).
     *  
     *  <p>This property is only used when <code>applyLocalProjection</code>
     *  is set to <code>true</code>.</p>
     *
     *  @see #applyLocalProjection
     *  @see flash.geom.PerspectiveProjection
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var focalLength:Number;

    /**
     *  Sets the projection point 
     *  as the offset of the projection point in the x direction 
     *  from the (0, 0) coordinate of the target.
     *  By default, when you apply a 3D effect, the effect automatically sets 
     *  the projection point to the center of the target. 
     *  You can set the <code>autoCenterProjection</code> property of the effect 
     *  to <code>false</code> to disable this default, and use the 
     *  <code>projectionX</code> and <code>projectionY</code> properties instead.
     *  
     *  <p>This property is only used when <code>applyLocalProjection</code>
     *  is set to <code>true</code>.</p>
     *
     *  @see #applyLocalProjection
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var projectionX:Number = 0;

    /**
     *  Sets the projection point 
     *  as the offset of the projection point in the y direction 
     *  from the (0, 0) coordinate of the target.
     *  By default, when you apply a 3D effect, the effect automatically sets 
     *  the projection point to the center of the target. 
     *  You can set the <code>autoCenterProjection</code> property of the effect 
     *  to <code>false</code> to disable this default, and use the 
     *  <code>projectionX</code> and <code>projectionY</code> properties instead.
     *  
     *  <p>This property is only used when <code>applyLocalProjection</code>
     *  is set to <code>true</code>.</p>
     *
     *  @see #applyLocalProjection
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var projectionY:Number = 0;
            
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     * 
     * This is where we create the single instance and/or feed extra
     * MotionPath information (from the transform-related effects) into the
     * single transform effect instance.
     */
    override protected function initInstance(instance:IEffectInstance):void
    {
        super.initInstance(instance);

        var transformInstance:AnimateTransformInstance =
            AnimateTransformInstance(instance);

        transformInstance.applyLocalProjection = applyLocalProjection;
        transformInstance.removeLocalProjectionWhenComplete = removeLocalProjectionWhenComplete;
        transformInstance.autoCenterProjection = autoCenterProjection;
        transformInstance.fieldOfView = fieldOfView;
        transformInstance.focalLength = focalLength;
        transformInstance.projectionX = projectionX;
        transformInstance.projectionY = projectionY;
    }

}
}
