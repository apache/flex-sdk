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

import mx.effects.effectClasses.PropertyChanges;
import mx.events.FlexEvent;
import mx.managers.LayoutManager;

import spark.components.Group;
import spark.effects.animation.Animation;
import spark.effects.animation.Keyframe;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;
import spark.primitives.supportClasses.GraphicElement;

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
                if (fadeIn)
                {
                    if (isNaN(alphaFrom))
                        alphaFrom = 0;
                    if (alphaFrom == 0)
                        target.alpha = 0;
                    alphaTo = toValue;
                    if ("visible" in target)
                        target.visible = true;
                }
                else if (isNaN(alphaTo)) // fade out
                {
                    alphaTo = 0;
                    restoreAlpha = true;
                    origAlpha = propertyChanges.end["alpha"] !== undefined ?
                        propertyChanges.end["alpha"] :
                        target.alpha;
                    if (visibleChange)
                        makeInvisible = true;
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