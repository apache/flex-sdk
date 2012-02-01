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

import mx.components.FxApplication;
import mx.core.Container;
import mx.core.IUIComponent;
import mx.effects.Animation;
import mx.effects.AnimationProperty;
import mx.events.AnimationEvent;
import mx.events.EffectEvent;
import mx.events.TweenEvent;
import mx.graphics.IGraphicElement;
import mx.styles.IStyleClient;
    
public class FxMoveInstance extends FxAnimateInstance
{
    include "../../core/Version.as";

    public function FxMoveInstance(target:Object)
    {
        super(target);
        affectsConstraints = true;
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------


    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  yBy
    //----------------------------------

    /** 
     *  Number of pixels by which to modify the y of the component.
     *  Values may be negative.
     */
    public var yBy:Number;
    
    //----------------------------------
    //  yFrom
    //----------------------------------

    /** 
     *  Initial y. If omitted, Flex uses the current size.
     */
    public var yFrom:Number;

    //----------------------------------
    //  yTo
    //----------------------------------
    
    
    /** 
     *  Final y, in pixels.
     */
    public var yTo:Number;
    
    //----------------------------------
    //  xBy
    //----------------------------------
    
    /** 
     *  Number of pixels by which to modify the width of the component.
     *  Values may be negative.
     */ 
    public var xBy:Number;

    //----------------------------------
    //  xFrom
    //----------------------------------

    /** 
     *  Initial x. If omitted, Flex uses the current size.
     */
    public var xFrom:Number;

    //----------------------------------
    //  xTo
    //----------------------------------

    /** 
     *  Final x, in pixels.
     */
    public var xTo:Number;
    

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function play():void
    {
		// The user may have supplied some combination of xFrom, xTo, and xBy.
		// If either xFrom or xTo is not explicitly defined, calculate its
		// value based on the other two values.
        if (isNaN(xFrom))
        {
            if (!isNaN(xTo) && !isNaN(xBy))
                xFrom = xTo - xBy;
        }
		if (isNaN(xTo))
		{
			if (isNaN(xBy) &&
				propertyChanges &&
				propertyChanges.end["x"] !== undefined)
			{
				xTo = propertyChanges.end["x"];
			}
			else
			{
				if (!isNaN(xBy) && !isNaN(xFrom))
				    xTo= xFrom + xBy;
			}
		}

		// Ditto for yFrom, yTo, and yBy.
        if (isNaN(yFrom))
        {
            if (!isNaN(yTo) && !isNaN(yBy))
                yFrom = yTo - yBy;
        }
		if (isNaN(yTo))
		{
			if (isNaN(yBy) &&
				propertyChanges &&
				propertyChanges.end["y"] !== undefined)
			{
				yTo = propertyChanges.end["y"];
			}
			else
			{
				if (!isNaN(yBy) && !isNaN(yFrom))
				    yTo = yFrom + yBy;
			}
		}

        animationProperties = 
            [new AnimationProperty("x", xFrom, xTo, xBy),
             new AnimationProperty("y", yFrom, yTo, yBy)];
        
        // TODO (chaase): The Flex3 version of Move had logic for forcing clipping
        // off during the effect. We probably need something like this
        // in this version as well, but the implementation is TBD with the
        // new container (Group) and layout management in Flex4
        
        super.play();        
    }
}
}
