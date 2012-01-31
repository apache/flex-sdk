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
import mx.core.mx_internal;
import mx.effects.IEffectInstance;

import spark.effects.supportClasses.AnimateTransformInstance;

use namespace mx_internal;

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="motionPaths", kind="property")]

/**
 *  The Scale3D class scales a target object
 *  in three dimensions around the transform center.
 *  A scale of 2.0 means the object has been magnified by a factor of 2, 
 *  and a scale of 0.5 means the object has been reduced by a factor of 2.
 *  A scale value of 0.0 is invalid.
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
 *  <p>The <code>&lt;mx:Scale3D&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;mx:Scale3D
 *    <b>Properties</b>
 *    id="ID"
 *    applyChangesPostLayout="true"
 *    scaleZBy="no default"
 *    scaleZFrom="no default"
 *    scaleZTo="no default"
 *  /&gt;
 *  </pre>
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */   
public class Scale3D extends Scale
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
    public function Scale3D(target:Object=null)
    {
        super(target);
        applyLocalProjection = true;
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
    [Inspectable(category="General")]
    /** 
     *  @copy AnimateTransform#applyChangesPostLayout
     *  The default value for this property is true for 3D effects,
     *  because the Flex layout system ignores 3D transformation properties.
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

    //----------------------------------
    //  scaleZFrom
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /**
     *  The starting scale factor in the z direction.
     *  A scale value of 0.0 is invalid.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var scaleZFrom:Number;

    //----------------------------------
    //  scaleZTo
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /**
     *  The ending scale factor in the z direction.
     *  A scale value of 0.0 is invalid.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var scaleZTo:Number;
            
    //----------------------------------
    //  scaleZBy
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /**
     *  The factor by which to scale the object in the z direction.
     *  This is an optional parameter that can be used instead of one
     *  of the other from/to values to specify the delta to add to the
     *  from value or to derive the from value by subtracting from the
     *  to value.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        if (!applyChangesPostLayout)
        {
           addMotionPath("scaleZ", scaleZFrom, scaleZTo, scaleZBy);
        }
        else
        {
            addPostLayoutMotionPath("postLayoutScaleZ", scaleZFrom, scaleZTo, scaleZBy);
        }
        super.initInstance(instance);
    }    
    
}
}