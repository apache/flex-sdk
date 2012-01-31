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
    //  alphaFrom
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

    //----------------------------------
    //  affectVisibility
    //----------------------------------

    /** 
     *  @copy spark.effects.Fade#affectVisibility
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var affectVisibility:Boolean;

    /**
     *  @private
     */
    override public function play():void
    {
        // Remember the original value of the target object's alpha
        origAlpha = target.alpha;
        var propChanges:PropertyChanges = propertyChanges;
        
        // If nobody assigned a value, make this a "show" effect.
        if (isNaN(alphaFrom) && isNaN(alphaTo))
        {   
            if (propChanges && propChanges.end["alpha"] !== undefined &&
                propChanges.end["alpha"] != propChanges.start["alpha"])
            {
                alphaFrom = origAlpha;
                alphaTo = propChanges.end["alpha"];
            }
            else if (propChanges && propChanges.end["visible"] !== undefined &&
                propChanges.end["visible"] != propChanges.start["visible"])
            {
                alphaFrom = propChanges.start["visible"] ? origAlpha : 0;
                alphaTo = propChanges.end["visible"] ? origAlpha : 0;
                // Force target to be visible at effect start
                restoreAlpha = true;
            }
            else if (propChanges && propChanges.end["parent"] !== undefined &&
                propChanges.end["parent"] != propChanges.start["parent"])
            {
                alphaFrom = propChanges.start["parent"] ? origAlpha : 0;
                alphaTo = propChanges.end["parent"] ? origAlpha : 0;
                restoreAlpha = true;
                if (alphaFrom == 0)
                {
                    target.alpha = 0;
                    // TODO: is Group or is UIComponent?
                    if (target.parent is Group)
                        target.parent.validateNow();
                }
            }
            else
            {
                alphaFrom = 0;
                alphaTo = origAlpha;
            }
        }
        else if (isNaN(alphaFrom))
        {
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
                alphaTo = (alphaFrom == 0) ? origAlpha : 0; 
            }
        }
        
        // Extra logic to handle making the object visible if we're supposed
        // to be fading it in
        if ("visible" in target && !target.visible && 
            alphaFrom == 0 && alphaTo != 0 &&
            ((propChanges && propChanges.end["visible"] !== undefined &&
              propertyChanges.end["visible"] != propertyChanges.start["visible"]) ||
             affectVisibility))
        {
            target.alpha = 0;
            target.visible = true;
        }
        // And logic to make the object invisible at the end if we're
        // fading it out
        // TODO (chaase): simplify logic of which variables we are 
        // side-effecting and what we should reset at the end
        if ("visible" in target && target.visible && 
            alphaFrom != 0 && alphaTo == 0 &&
            ((propChanges && propChanges.end["visible"] !== undefined &&
              propertyChanges.end["visible"] != propertyChanges.start["visible"]) ||
             affectVisibility))
        {
            makeInvisible = true;
        }
        
        motionPaths = new <MotionPath>[
            new SimpleMotionPath("alpha",alphaFrom, alphaTo, duration)];
        
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