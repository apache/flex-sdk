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

package mx.charts.events
{

import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.charts.HitData;
import mx.charts.chartClasses.ChartBase;

/**
 * The ChartEvent class represents events that are specific
 * to the chart control, such as when a chart is clicked. This event
 * is only triggered if there are no ChartItem objects underneath the mouse.
 * 
 * @see mx.charts.events.ChartItemEvent
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class ChartEvent extends MouseEvent
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  Indicates that the user clicked the mouse button
     *  over a chart control but not on a chart item.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const CHART_CLICK:String = "chartClick";
    
    /**
     *  Indicates that the user double-clicked
     *  the mouse button over a chart control but not on a chart item.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const CHART_DOUBLE_CLICK:String = "chartDoubleClick";
    

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  @param type The type of the event.
     *
     *  @param triggerEvent The MouseEvent that triggered this ChartEvent.
     *
     *  @param target The chart on which the event was triggered.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function ChartEvent(type:String, triggerEvent:MouseEvent=null, target:ChartBase=null)
    {   
        var relPt:Point;
        if (triggerEvent && triggerEvent.target)
        {
            relPt = target.globalToLocal(triggerEvent.target.localToGlobal(
                new Point(triggerEvent.localX, triggerEvent.localY)));
        }
        else
        {
            if (target)
                relPt = new Point(target.mouseX,target.mouseY);
            else
                relPt = new Point(0,0);
        }
        
        var bubbles:Boolean = true;
        var cancelable:Boolean = false;
        var relatedObject:InteractiveObject = null;
        var ctrlKey:Boolean = false;
        var shiftKey:Boolean = false;
        var altKey:Boolean = false;
        var buttonDown:Boolean = false;
        var delta:int = 0;
            
        if (triggerEvent)
        {
            bubbles = triggerEvent.bubbles;
            cancelable = triggerEvent.cancelable;
            relatedObject = triggerEvent.relatedObject;
            ctrlKey = triggerEvent.ctrlKey;
            altKey = triggerEvent.altKey;
            shiftKey = triggerEvent.shiftKey;
            buttonDown = triggerEvent.buttonDown;
            delta = triggerEvent.delta;
        }
        
            
        super(type, bubbles, cancelable,
              relPt.x, relPt.y, relatedObject,
              ctrlKey, altKey, shiftKey, buttonDown, delta); 
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: Event
    //
    //--------------------------------------------------------------------------

    /** 
     *  @private
     */
    override public function clone():Event
    {
        return new ChartEvent(type, this,ChartBase(this.target));
    }
}

}
