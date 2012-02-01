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
package flex.effects.effectClasses
{
import flash.events.Event;

import flex.component.Panel;
import flex.effects.PropertyValuesHolder;
import flex.graphics.IGraphicElement;

import mx.core.Application;
import mx.core.Container;
import mx.core.IUIComponent;
import mx.events.EffectEvent;
import mx.events.TweenEvent;
import mx.styles.IStyleClient;
    
public class MoveInstance extends AnimateInstance
{
    include "../../core/Version.as";

    public function MoveInstance(target:Object)
    {
        super(target);
        roundValues = true;
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
            else if (propertyChanges && propertyChanges.start["x"] !== undefined)
                xFrom = propertyChanges.start["x"];
            else
                xFrom = getCurrentValue("x");
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
				xTo = (!isNaN(xBy)) ? xFrom + xBy : getCurrentValue("x");
			}
		}

		// Ditto for yFrom, yTo, and yBy.
        if (isNaN(yFrom))
        {
            if (!isNaN(yTo) && !isNaN(yBy))
                yFrom = yTo - yBy;
            else if (propertyChanges && propertyChanges.start["y"] !== undefined)
                yFrom = propertyChanges.start["y"];
            else
                yFrom = getCurrentValue("y");
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
				yTo = (!isNaN(yBy)) ? yFrom + yBy : getCurrentValue("y");
			}
		}

        if (target is IStyleClient)
        {
            var left:* = target.getStyle("left");
            if (left != undefined)
                target.setStyle("left",undefined);
        
            var right:* = target.getStyle("right");
            if (right != undefined)
                target.setStyle("right",undefined);
            
            var top:* = target.getStyle("top");
            if (top != undefined)
                target.setStyle("top",undefined);
            
            var bottom:* = target.getStyle("bottom");
            if (bottom != undefined)
                target.setStyle("bottom",undefined);    

            var hCenter:* = target.getStyle("horizontalCenter");
            if (hCenter != undefined)
                target.setStyle("horizontalCenter",undefined);    

            var vCenter:* = target.getStyle("verticalCenter");
            if (vCenter != undefined)
                target.setStyle("verticalCenter",undefined);    
        }
        
        propertyValuesList = 
            [new PropertyValuesHolder("x", [xFrom, xTo]),
             new PropertyValuesHolder("y", [yFrom, yTo])];
        
        // TODO: These additional pvholder items are a workaround for the
        // current difference between GraphicElement constraints and
        // UIComponent constraints. For components, the constraints
        // side-effect the width/height properties which we can then animate.
        // For GraphicElements, this does not happen, so animations on
        // width/height are ignored when constraints are set.
        // Expect this to change with GraphicElement and UIComponent are
        // more closely aligned in behavior. 
        if (target is IGraphicElement && propertyChanges)
        {
            if (!isNaN(propertyChanges.start["left"]) ||
                !isNaN(propertyChanges.end["left"]))
            {
                var lFrom:Number = !isNaN(propertyChanges.start["left"]) ?
                    propertyChanges.start["left"] : getCurrentValue("left");
                var lTo:Number = !isNaN(propertyChanges.end["left"]) ?
                    propertyChanges.end["left"] : getCurrentValue("left");
                propertyValuesList.push(new PropertyValuesHolder("left", [lFrom, lTo]));
            }
            if (!isNaN(propertyChanges.start["right"]) ||
                !isNaN(propertyChanges.end["right"]))
            {
                var rFrom:Number = !isNaN(propertyChanges.start["right"]) ?
                    propertyChanges.start["right"] : getCurrentValue("right");
                var rTo:Number = !isNaN(propertyChanges.end["right"]) ?
                    propertyChanges.end["right"] : getCurrentValue("right");
                propertyValuesList.push(new PropertyValuesHolder("right", [rFrom, rTo]));
            }
            if (!isNaN(propertyChanges.start["top"]) ||
                !isNaN(propertyChanges.end["top"]))
            {
                var tFrom:Number = !isNaN(propertyChanges.start["top"]) ?
                    propertyChanges.start["top"] : getCurrentValue("top");
                var tTo:Number = !isNaN(propertyChanges.end["top"]) ?
                    propertyChanges.end["top"] : getCurrentValue("top");
                propertyValuesList.push(new PropertyValuesHolder("top", [tFrom, tTo]));
            }
            if (!isNaN(propertyChanges.start["bottom"]) ||
                !isNaN(propertyChanges.end["bottom"]))
            {
                var bFrom:Number = !isNaN(propertyChanges.start["bottom"]) ?
                    propertyChanges.start["bottom"] : getCurrentValue("bottom");
                var bTo:Number = !isNaN(propertyChanges.end["bottom"]) ?
                    propertyChanges.end["bottom"] : getCurrentValue("bottom");
                propertyValuesList.push(new PropertyValuesHolder("bottom", [bFrom, bTo]));
            }
        }

        // TODO (chaase): The Flex3 version of Move had logic for forcing clipping
        // off during the effect. We probalyy need something like this
        // in this version as well, but the implementation is TBD with the
        // new container (Group) and layout management in Flex4
        
        super.play();        
    }

    
}
}