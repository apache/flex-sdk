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

package mx.effects.effectClasses
{
import flash.events.Event;

import mx.components.Group;
import mx.effects.Animation;
import mx.effects.PropertyValuesHolder;
import mx.events.AnimationEvent;
import mx.events.FlexEvent;
import mx.graphics.graphicsClasses.GraphicElement;
import mx.managers.LayoutManager;
    
public class FxFadeInstance extends FxAnimateInstance
{
    public function FxFadeInstance(target:Object)
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
     *  Initial transparency level between 0.0 and 1.0, 
     *  where 0.0 means transparent and 1.0 means fully opaque. 
     */
    public var alphaFrom:Number;
    
    //----------------------------------
    //  alphaFrom
    //----------------------------------

    /** 
     *  Final transparency level between 0.0 and 1.0, 
     *  where 0.0 means transparent and 1.0 means fully opaque.
     */
    public var alphaTo:Number;

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
            if (propChanges && propChanges.end["alpha"] !== undefined)
            {
                alphaFrom = origAlpha;
                alphaTo = propChanges.end["alpha"];
            }
            else if (propChanges && propChanges.end["visible"] !== undefined)
            {
                alphaFrom = propChanges.start["visible"] ? origAlpha : 0;
                alphaTo = propChanges.end["visible"] ? origAlpha : 0;
                // Force target to be visible at effect start
                restoreAlpha = true;
            }
            else if (propChanges && propChanges.end["parent"] !== undefined)
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
            if (propChanges && propChanges.end["alpha"] !== undefined)
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
            propChanges && propChanges.end["visible"] !== undefined)
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
            propChanges && propChanges.end["visible"] !== undefined)
        {
            makeInvisible = true;
        }
        
        propertyValuesList = 
            [new PropertyValuesHolder("alpha", [alphaFrom, alphaTo])];
        
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