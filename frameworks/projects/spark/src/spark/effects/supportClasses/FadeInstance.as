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
        // FIXME chaase: clean up this logic and make it simpler to decide whether
        // and object is appearing or disappearing, then set the starting/ending
        // values appropriately. Also, reuse the lazy-evaluation code for
        // animations by supplying NaNs for values to be filled in with
        // state values from propChanges later
        
        // Remember the original value of the target object's alpha
        origAlpha = target.alpha;
        var propChanges:PropertyChanges = propertyChanges;
        
        // If nobody assigned a value, make this a "show" effect.
        if (isNaN(alphaFrom) && isNaN(alphaTo))
        {
            var startAlpha:Number = origAlpha;
            var endAlpha:Number = origAlpha;
            if (propChanges && propChanges.end["alpha"] !== undefined &&
                propChanges.end["alpha"] != propChanges.start["alpha"])
            {
                endAlpha = propChanges.end["alpha"];
            }
            if (propChanges && propChanges.end["visible"] !== undefined &&
                propChanges.end["visible"] != propChanges.start["visible"])
            {
                alphaFrom = propChanges.start["visible"] ? startAlpha : 0;
                alphaTo = propChanges.end["visible"] ? endAlpha : 0;
                // Force target to be visible at effect 
                restoreAlpha = !propChanges.end["visible"];
            }
            else if (propChanges && propChanges.end["parent"] !== undefined &&
                propChanges.end["parent"] != propChanges.start["parent"])
            {
                alphaFrom = propChanges.start["parent"] ? startAlpha : 0;
                alphaTo = propChanges.end["parent"] ? endAlpha : 0;
                restoreAlpha = !propChanges.end["parent"];
                if (alphaFrom == 0)
                {
                    target.alpha = 0;
                    // FIXME (chaase): is Group or is UIComponent?
                    if (target.parent is Group)
                        target.parent.validateNow();
                }
            }
            else
            {
                alphaFrom = startAlpha;
                alphaTo = endAlpha;
            }
        }
        else if (isNaN(alphaFrom))
        {
            // FIXME chaase: why anything but origAlpha here?
            alphaFrom = (alphaTo == 0) ? origAlpha : 0;
        }
        else if (isNaN(alphaTo))
        {
            if (propChanges && propChanges.end["alpha"] !== undefined &&
                propertyChanges.end["alpha"] != propertyChanges.start["alpha"])
            {
                alphaTo = propChanges.end["alpha"];
            }
            else
            {
                // FIXME chaase: why anything but origAlpha here?
                alphaTo = (alphaFrom == 0) ? origAlpha : 0; 
            }
        }
        
        // Extra logic to handle making the object visible if we're supposed
        // to be fading it in
        if ("visible" in target && !target.visible && 
            alphaFrom == 0 && alphaTo != 0 &&
            (!propertyChanges ||
             (propChanges.end["visible"] !== undefined &&
                propChanges.end["visible"] != propChanges.start["visible"])))
        {
            target.alpha = 0;
            target.visible = true;
        }
        // And logic to make the object invisible at the end if we're
        // fading it out
        // FIXME (chaase): simplify logic of which variables we are 
        // side-effecting and what we should reset at the end
        if ("visible" in target && target.visible && 
            alphaFrom != 0 && alphaTo == 0 &&
            propChanges && propChanges.end["visible"] !== undefined &&
            propertyChanges.end["visible"] != propertyChanges.start["visible"])
        {
            makeInvisible = true;
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