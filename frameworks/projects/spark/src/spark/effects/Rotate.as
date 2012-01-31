////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package spark.effects
{
import mx.core.mx_internal;
import mx.effects.IEffectInstance;

import spark.effects.animation.MotionPath;
import spark.effects.supportClasses.AnimateTransformInstance;

use namespace mx_internal;
    
//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="motionPaths", kind="property")]

/**
 *  The Rotate effect rotates a target object
 *  in the x, y plane around the transform center. 
 *
 *  <p>If you specify any two of the angle values (angleFrom, angleTo,
 *  or angleBy), Flex calculates the third.
 *  If you specify all three, Flex ignores the <code>angleBy</code> value.</p>
 * 
 *  <p>Like all AnimateTransform-based effects, this effect will only work on subclasses
 *  of UIComponent and GraphicElement, as these effects depend on specific
 *  transform functions in those classes. </p>
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;s:Rotate&gt;</code> tag
 *  inherits all of the tag attributes of its of its superclass,
 *  and adds the following tag attributes:</p>
 *  
 *  <pre>
 *  &lt;s:Rotate
 *    id="ID"
 *    angleBy="val"
 *    angleFrom="val"
 *    angleTo="val"
 *   /&gt;
 *  </pre>
 *
 *  @includeExample examples/RotateEffectExample.mxml
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */   
public class Rotate extends AnimateTransform
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private static var AFFECTED_PROPERTIES:Array =
        ["rotationZ", "postLayoutRotationZ",
         "width", "height"];

    private static var RELEVANT_STYLES:Array = [];

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
    public function Rotate(target:Object=null)
    {
        super(target);
        instanceClass = AnimateTransformInstance;
        transformEffectSubclass = true;
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
     *  The starting angle of rotation of the target object,
     *  in degrees.
     *  Valid values range from 0 to 360.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var angleFrom:Number;

    //----------------------------------
    //  angleTo
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     *  The ending angle of rotation of the target object,
     *  in degrees.
     *  Values can be either positive or negative.
     *
     *  <p>If the value of <code>angleTo</code> is less
     *  than the value of <code>angleFrom</code>,
     *  the target rotates in a counterclockwise direction.
     *  Otherwise, it rotates in clockwise direction.
     *  If you want the target to rotate multiple times,
     *  set this value to a large positive or small negative number.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var angleTo:Number;
    
    //----------------------------------
    //  angleBy
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     *  Degrees by which to rotate the target object. Value
     *  may be negative.
     *
     *  <p>If the value of <code>angleBy</code> is negative,
     *  the target rotates in a counterclockwise direction.
     *  Otherwise, it rotates in clockwise direction.
     *  If you want the target to rotate multiple times,
     *  set this value to a large positive or small negative number.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var angleBy:Number;
            
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function get relevantStyles():Array /* of String */
    {
        return RELEVANT_STYLES;
    }   

    /**
     *  @private
     */
    override public function getAffectedProperties():Array /* of String */
    {
        return AFFECTED_PROPERTIES;
    }

    // TODO (chaase): Should try to remove this override. At a minimum, we could
    // put the motionPaths creation at the start of initInstance(). Ideally, we'd
    // remove that logic entirely, but there's a need to create motionPaths fresh
    // for every call to create/initInstance() or else multi-instance effects
    // will inherit the one motionPaths object created elsewhere.
    /**
     * @private
     */
    override public function createInstance(target:Object = null):IEffectInstance
    {
        motionPaths = new Vector.<MotionPath>();
        return super.createInstance(target);
    }
    
    /**
     * @private
     */
    override protected function initInstance(instance:IEffectInstance):void
    {
        if (!applyChangesPostLayout)
        {
            addMotionPath("rotationZ", angleFrom, angleTo, angleBy);
        }
        else
        {
            addMotionPath("postLayoutRotationZ", angleFrom, angleTo, angleBy);
        }
        super.initInstance(instance);
    }    
}
}
