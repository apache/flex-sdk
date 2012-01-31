////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
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
                    if (propertyChanges.end["explicitWidth"] !== undefined &&
                        isNaN(propertyChanges.end["explicitWidth"]) &&
                        !isNaN(propertyChanges.start["explicitWidth"]))
                    {
                        target.explicitWidth = propertyChanges.start["explicitWidth"];
                    }
                    if (propertyChanges.end["explicitHeight"] !== undefined &&
                        isNaN(propertyChanges.end["explicitHeight"]) &&
                        !isNaN(propertyChanges.start["explicitHeight"]))
                    {
                        target.explicitHeight = propertyChanges.start["explicitHeight"];
                    }
                    if (propertyChanges.end["rotation"] !== undefined &&
                        propertyChanges.end["rotation"] == 0 &&
                        propertyChanges.start["rotation"] != 0)
                    {
                        target.rotation = propertyChanges.start["rotation"];
                    }
                    if (propertyChanges.end["x"] !== undefined &&
                        propertyChanges.end["x"] == 0 &&
                        propertyChanges.start["x"] != 0)
                    {
                        target.x = propertyChanges.start["x"];
                    }
                    if (propertyChanges.end["y"] !== undefined &&
                        propertyChanges.end["y"] == 0 &&
                        propertyChanges.start["y"] != 0)
                    {
                        target.y = propertyChanges.start["y"];
                    }
                    if (propertyChanges.end["left"] !== undefined &&
                        propertyChanges.end["left"] === null &&
                        propertyChanges.start["left"] !== null)
                    {
                        target.left = propertyChanges.start["left"];
                    }
                    if (propertyChanges.end["right"] !== undefined &&
                        propertyChanges.end["right"] === null &&
                        propertyChanges.start["right"] !== null)
                    {
                        target.right = propertyChanges.start["right"];
                    }
                    if (propertyChanges.end["top"] !== undefined &&
                        propertyChanges.end["top"] === null &&
                        propertyChanges.start["top"] !== null)
                    {
                        target.top = propertyChanges.start["top"];
                    }
                    if (propertyChanges.end["bottom"] !== undefined &&
                        propertyChanges.end["bottom"] === null &&
                        propertyChanges.start["bottom"] !== null)
                    {
                        target.bottom = propertyChanges.start["bottom"];
                    }
                    if (propertyChanges.end["percentWidth"] !== undefined &&
                        isNaN(propertyChanges.end["percentWidth"]) &&
                        !isNaN(propertyChanges.start["percentWidth"]))
                    {
                        target.percentWidth = propertyChanges.start["percentWidth"];
                    }
                    if (propertyChanges.end["percentHeight"] !== undefined &&
                        isNaN(propertyChanges.end["percentHeight"]) &&
                        !isNaN(propertyChanges.start["percentHeight"]))
                    {
                        target.percentHeight = propertyChanges.start["percentHeight"];
                    }
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