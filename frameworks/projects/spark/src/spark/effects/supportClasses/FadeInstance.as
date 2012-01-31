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

package spark.effects.supportClasses
{
import flash.events.Event;

import mx.core.mx_internal;
import mx.effects.effectClasses.PropertyChanges;
import mx.events.FlexEvent;
import mx.managers.LayoutManager;

import spark.components.Group;
import spark.effects.animation.Animation;
import spark.effects.animation.Keyframe;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;
import spark.primitives.supportClasses.GraphicElement;

use namespace mx_internal;

/**
 *  The FadeInstance class implements the instance class
 *  for the Fade effect.
 *  Flex creates an instance of this class when it plays a Fade
 *  effect; you do not create one yourself.
 *
 *  @see spark.effects.Fade
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */  
public class FadeInstance extends AnimateInstance
{
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
    public function FadeInstance(target:Object)
    {
        super(target);
        
        // Automatically keep disappearing targets around during this effect
        autoRemoveTarget = true;
    }
    
    /** 
     *  @private
     *  The original transparency level.
     */
    private var origAlpha:Number = NaN;
    
    private var makeInvisible:Boolean;
    
    /** 
     *  @private
     */
    private var restoreAlpha:Boolean;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  alphaFrom
    //----------------------------------

    /** 
     *  @copy spark.effects.Fade#alphaFrom
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var alphaFrom:Number;
    
    //----------------------------------
    //  alphaTo
    //----------------------------------

    /** 
     *  @copy spark.effects.Fade#alphaTo
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var alphaTo:Number;

    /**
     *  @private
     */
    override public function play():void
    {
        var fromValue:Number = alphaFrom;
        var toValue:Number = alphaTo;
        if (propertyChanges)
        {
            if (isNaN(fromValue))
                fromValue = 
                    (propertyChanges.start["alpha"] !== undefined) ?
                    propertyChanges.start["alpha"] : target.alpha; 
            if (isNaN(toValue))
                toValue = 
                    (propertyChanges.end["alpha"] !== undefined) ?
                    propertyChanges.end["alpha"] : target.alpha; 
            var visibleChange:Boolean = 
                propertyChanges.end["visible"] !== undefined &&
                propertyChanges.end["visible"] != propertyChanges.start["visible"];
            var parentChange:Boolean = 
                propertyChanges.end["parent"] !== undefined &&
                propertyChanges.end["parent"] != propertyChanges.start["parent"];
            if (visibleChange || parentChange)
            {
                var fadeIn:Boolean = (visibleChange && propertyChanges.end["visible"]) ||
                    (parentChange && propertyChanges.end["parent"]);
                if (playReversed)
                    fadeIn = !fadeIn;
                if (fadeIn)
                {
                    if (isNaN(alphaFrom))
                        alphaFrom = !(playReversed) ? 0 : toValue;
                    if (alphaFrom == 0)
                        target.alpha = 0;
                    alphaTo = !playReversed ? toValue : 0;
                    if ("visible" in target)
                        target.visible = true;
                }
                else if (isNaN(alphaTo)) // fade out
                {
                    restoreAlpha = true;
                    origAlpha = propertyChanges.end["alpha"] !== undefined ?
                        propertyChanges.end["alpha"] :
                        target.alpha;
                    if (visibleChange)
                        makeInvisible = true;
                    if (!playReversed)
                    {
                        alphaTo = 0;
                    }
                    else
                    {
                        if (isNaN(alphaFrom))
                        {
                            target.alpha = 0;
                            alphaFrom = 0;
                        }
                        alphaTo = 1;
                    }
                }
            }
        }
        if ("visible" in target && !target.visible)
        {
            // Extra logic to handle making the object visible if we're supposed
            // to be fading it in 
            if (isNaN(fromValue))
                fromValue = target.alpha;
            if (isNaN(toValue))
                toValue = target.alpha;
            if (fromValue == 0 && toValue != 0)
            {
                target.alpha = 0;
                target.visible = true;
            }
        }
            
        motionPaths = new <MotionPath>[new MotionPath("alpha")];
        motionPaths[0].keyframes = new <Keyframe>[new Keyframe(0, alphaFrom), 
            new Keyframe(duration, alphaTo)];
        
        super.play();
    }
    
    /**
     *  Handle any cleanup from this effect, such as setting the target to
     *  be visible (or not) or removed (or not). 
     *  @private
     */
    override public function finishEffect():void
    {
        // Call super function first so we don't clobber resetting the alpha.
        super.finishEffect();    

        if (restoreAlpha)
            target.alpha = origAlpha;

        if (makeInvisible)
            target.visible = false;
    }
}
}