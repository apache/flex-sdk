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
package  {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.Shape;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Point;
import flash.system.Capabilities;
import flash.text.TextField;
import flash.utils.Timer;

import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.mx_internal;
import mx.graphics.SolidColor;
import mx.graphics.SolidColorStroke;
import mx.utils.GetTimerUtil;

import spark.components.Group;
import spark.components.Scroller;
import spark.core.SpriteVisualElement;
import spark.primitives.Ellipse;
import spark.primitives.Path;

use namespace mx_internal;

/**
 *  Exposes some helper methods that are useful for testing touch scrolling
 *  on a mobile device.  These methods can be used in a standalone application 
 *  to reproduce or demonstrate a bug and is also used in the SimulateMouseGesture
 *  Mustella test step.
 *
 * Example usage 1 - recording events:
 * 
 * <s:actionContent>
 *      <s:Button label="enable" click="TouchScrollingUtil.enableMouseEventTracking(target)" />
 *      <s:Button label="disable" click="TouchScrollingUtil.disableMouseEventTracking(target)" />
 *      <s:Button label="write" click="TouchScrollingUtil.writeFileToDisk('/sdcard/Flex/QA/List/mouseEvents.txt',
 *          TouchScrollingUtil.getEventsAsMXMLString(TouchScrollingUtil.recordedMouseEvents));" />
 * </s:actionContent>
 * 
 * Example usage 2 - playing back events:
 * 
 * <s:actionContent>
 *     <s:Button label="play" click="TouchScrollingUtil.simulateTouchScrollFrameBased(target, eventsArray)" />
 * </s:actionContent>
 * 
 */
public class TouchScrollingUtil
{

/**
 * The name of the event that is fired when all mouse events have been fired
 */
public static const SIMULATION_COMPLETE:String = "simulationComplete";

/**
 * Keeps track of all the mouse events that have fired while tracking was enabled
 */
public static var recordedMouseEvents:Array = new Array();

/**
 * Controls whether to trace out extra debug information, for example tracing 
 * out information about every mouse event as it is dispatched. 
 */
public static var enableVerboseTraceOuput:Boolean = true;

/**
 * Dispatches a series of MouseEvents that simulate how a user scrolls
 * using touch scrolling on a mobile device.
 * 
 * @param actualTarget - the target component to scroll
 * 
 * @param events - An array of mouse events to dispatch. 
 * 
 * Use this for realistic simulation as you have complete control over the
 * type, location, and time of each event.
 * 
 * These events should be defined as an array of objects in this form:
 * 
 *   <fx:Object type="mouseDown" localX="150" localY="150" fakeTimeValue="0" />
 *   <fx:Object type="mouseMove" localX="149" localY="149" fakeTimeValue="16" />
 *   ...
 *   <fx:Object type="mouseUp" localX="100" localY="100" fakeTimeValue="343" />
 * 
 * If this property is not null then it takes precedence over any
 * dragX/dragY values that might also be defined.
 * 
 * TODO: Possible Enhancement: Allow each individual mouse event entry to specify its own
 *       waitEvent before continuing on to the next.  This would allow for more control
 *       over when the events are fired, but may not be of any value.
 * 
 * TODO: Possible Enhancement: Fully support sequences that go outside the bounds of the target.
 *
 * @param dragXFrom - the x coordinate of the target to start the drag motion
 * @param dragYFrom - the y coordinate of the target to start the drag motion
 * @param dragXTo - the x coordinate of the target to end the drag motion
 * @param dragYTo - the y coordinate of the target to end the drag motion
 * @param delay - the time between events when an events array isn't defined
 * 
 */
public static function simulateTouchScroll(actualTarget:Object,
                                           events:Array,
                                           recordedDPI:Number = NaN,
                                           dragXFrom:Number = NaN, dragYFrom:Number = NaN, 
                                           dragXTo:Number = NaN, dragYTo:Number = NaN, 
                                           delay:Number = 17):void 
{
    // reset the index into the event list
    var eventIndex:int = 0;
    
    // if a specific event sequence wasn't provided, then create one
    if (events == null)
        events = createEventsArray(dragXFrom, dragYFrom, dragXTo, dragYTo, delay);
    
    // shove the target into each element of the events array
    for (var j:int = 0; j < events.length; j++)
        events[j].target = actualTarget;
    
    // setup the timer based firing
    var eventTimer:Timer = new Timer(1);
        
    // the method that loops through the events to fire
    var tickerFunction:Function = function(e:TimerEvent):void 
    {
        if (eventIndex >= events.length)
        {
            // all mouse events have been fired at this point
            
            // turn off fake time
            GetTimerUtil.fakeTimeValue = undefined;
            
            // turn mouse event thinning back on
            Scroller.dragEventThinning = true;
            
            // signal that this test step is ready for completion
            actualTarget.dispatchEvent(new Event(SIMULATION_COMPLETE));
            
            // stop the timer loop
            eventTimer.stop();
            eventTimer.removeEventListener(TimerEvent.TIMER, tickerFunction);
            return;
        }
        
        // trace details on the event we are firing
        traceLog("Dispatching MouseEvent:",
            events[eventIndex].type,
            events[eventIndex].localX,
            events[eventIndex].localY,
            events[eventIndex].fakeTimeValue);
        
        // update the fake time
        GetTimerUtil.fakeTimeValue = events[eventIndex].fakeTimeValue;
        
        
        // turn off mouse event thinning 
        // ----
        // Late in the 4.5 release the runtime changed their  behavior on Android that 
        // fired too many mouseMove events making Flex sluggish on drag scrolls. We 
        // put logic in the SDK to thin out excess events and this logic is 
        // non-deterministic so we need to turn that logic off in Mustella.
        // ----
        // TODO: This is a dependency on the SDK and a possible risk for automation 
        //       not following the same code path as a user.
        //       We're stuck with it for now until the runtime allows us more control
        //       over the mouse event firing rate.
        // ----
        // See http://bugs.adobe.com/jira/browse/SDK-29188 for a full explanation
        //
        Scroller.dragEventThinning = false;
        
        // scale the localX/localY co-ordinates if requested
        var adjustedLocalX:Number = scaleByDPIRatio(events[eventIndex].localX, recordedDPI);
        var adjustedLocalY:Number = scaleByDPIRatio(events[eventIndex].localY, recordedDPI);
        
        // fire the next event
        dispatchMouseEvent(events[eventIndex].target,
                           events[eventIndex].type,
                           adjustedLocalX,
                           adjustedLocalY);
        
        // update the timer delay to be the difference between time values of the next and current events
        if (eventIndex + 1 < events.length)
        {
            var nextTimeValue:int = events[eventIndex + 1].fakeTimeValue;
            var currTimeValue:int = events[eventIndex].fakeTimeValue;
            
            eventTimer.delay = (nextTimeValue - currTimeValue);
            traceLog('timer is now', eventTimer.delay);
        }
        
        // move on to the next event
        eventIndex++;
    };
    
    // start firing the mouse events
    eventTimer.addEventListener(TimerEvent.TIMER, tickerFunction);
    eventTimer.start();
    
}

/**
 * Similar to simulateTouchScroll(), but used in Mustella so it's not based
 * on a timer but rather fires off a couple mouse events per enterFrame.
 * 
 * @see simulateTouchScroll()
 */
public static function simulateTouchScrollFrameBased(actualTarget:Object,
                                           events:Array,
                                           recordedDPI:Number = NaN,
                                           dragXFrom:Number = NaN, dragYFrom:Number = NaN, 
                                           dragXTo:Number = NaN, dragYTo:Number = NaN, 
                                           delay:Number = 17):void
{
    // reset the index into the event list
    var eventIndex:int = 0;
    
    // if a specific event sequence wasn't provided, then create one
    if (events == null)
        events = createEventsArray(dragXFrom, dragYFrom, dragXTo, dragYTo, delay);
    
    // shove the target into each element of the events array
    for (var j:int = 0; j < events.length; j++)
        events[j].target = actualTarget;
    
    // the method that loops through the events to fire
    var tickerFunction:Function = function(e:Event):void 
    {
        // fire a few mouse events per enterFrame
        var numEventsPerEnterFrame:int = 3;
        for (var i:int = 0; i < numEventsPerEnterFrame; i++)
        {
            if (eventIndex >= events.length)
            {
                // all mouse events have been fired at this point
                
                // turn off fake time
                GetTimerUtil.fakeTimeValue = undefined;
                
                // turn mouse event thinning back on
                Scroller.dragEventThinning = true;
                
                // signal that this test step is ready for completion
                actualTarget.dispatchEvent(new Event(SIMULATION_COMPLETE));
                
                // remove the enterFrame listener
                actualTarget.removeEventListener("enterFrame", tickerFunction)
                return;
            }
            
            // trace details on the event we are firing
            traceLog("Dispatching MouseEvent:",
                events[eventIndex].type,
                events[eventIndex].localX,
                events[eventIndex].localY,
                events[eventIndex].fakeTimeValue);
            
            // update the fake time
            GetTimerUtil.fakeTimeValue = events[eventIndex].fakeTimeValue;
            
            // turn off mouse event thinning 
            // ----
            // Late in the 4.5 release the runtime changed their  behavior on Android that 
            // fired too many mouseMove events making Flex sluggish on drag scrolls. We 
            // put logic in the SDK to thin out excess events and this logic is 
            // non-deterministic so we need to turn that logic off in Mustella.
            // ----
            // TODO: This is a dependency on the SDK and a possible risk for automation 
            //       not following the same code path as a user.
            //       We're stuck with it for now until the runtime allows us more control
            //       over the mouse event firing rate.
            // ----
            // See http://bugs.adobe.com/jira/browse/SDK-29188 for a full explanation
            //
            Scroller.dragEventThinning = false;
            
            // scale the localX/localY co-ordinates if requested
            var adjustedLocalX:Number = scaleByDPIRatio(events[eventIndex].localX, recordedDPI);
            var adjustedLocalY:Number = scaleByDPIRatio(events[eventIndex].localY, recordedDPI);
            
            trace(adjustedLocalX, adjustedLocalY);
            
            // fire the next event
            dispatchMouseEvent(events[eventIndex].target,
                               events[eventIndex].type,
                               adjustedLocalX,
                               adjustedLocalY);
            
            // move on to the next event
            eventIndex++;
        }
    }

    // start firing the mouse events
    actualTarget.addEventListener("enterFrame", tickerFunction);
    
}

/**
 * This takes an x/y value and scales it by the current device's exact DPI over the recorded
 * device's exact dpi.
 * 
 * This allows support for recording a mouseEvent sequence at one DPI and have it scale automatically
 * on different DPIs to maintain the same physical distance scrolled (in inches).
 */
private static function scaleByDPIRatio(value:Number, recordedDPI:Number):Number 
{
    if (!isNaN(recordedDPI))
        return Math.round(value * (Capabilities.screenDPI / recordedDPI));
    else
        return value;
}

/**
 * TODO: This is an untyped version of MouseEventEntry in Mustella.
 */
private static function createMouseEventEntry(type:String, localX:Number, localY:Number, fakeTimeValue:Number):Object
{
    var mouseEventEntry:Object = new Object();
    mouseEventEntry.type = type;
    mouseEventEntry.localX = localX;
    mouseEventEntry.localY = localY;
    mouseEventEntry.fakeTimeValue = fakeTimeValue;
    return mouseEventEntry;
}

/** 
 * Creates a sequence of mouse events to perform the requested drag scroll
 */
private static function createEventsArray(dragXFrom:Number, dragYFrom:Number, dragXTo:Number, dragYTo:Number, delay:Number):Array
{
    var arr:Array = new Array();
    
    var deltaX:Number = isNaN(dragXFrom - dragXTo) ? 0 : dragXFrom - dragXTo;
    var deltaY:Number = isNaN(dragYFrom - dragYTo) ? 0 : dragYFrom - dragYTo;
    var numSteps:Number = 6;
    
    var chunkX:Number = deltaX / numSteps;
    var chunkY:Number = deltaY / numSteps;
    
    // first need a move, rollOver, over, mouseDown at the start position
    arr.push(createMouseEventEntry(MouseEvent.MOUSE_MOVE, dragXFrom, dragYFrom, arr.length * delay));
    arr.push(createMouseEventEntry(MouseEvent.ROLL_OVER,  dragXFrom, dragYFrom, arr.length * delay));
    arr.push(createMouseEventEntry(MouseEvent.MOUSE_OVER, dragXFrom, dragYFrom, arr.length * delay));
    arr.push(createMouseEventEntry(MouseEvent.MOUSE_DOWN, dragXFrom, dragYFrom, arr.length * delay));
    
    for (var i:int = 0; i < numSteps; i++)
    {
        // then a couple mouseMoves along the way
        arr.push(createMouseEventEntry(MouseEvent.MOUSE_MOVE, 
                                       Math.round(dragXFrom - (chunkX * i)),
                                       Math.round(dragYFrom - (chunkY * i)),
                                       arr.length * delay));
    }
    
    // then a few mouseMoves near/at the end to take away any potential 
    // velocity so we guarantee a drag instead of a throw
    arr.push(createMouseEventEntry(MouseEvent.MOUSE_MOVE, dragXTo, dragYTo, arr.length * delay));
    arr.push(createMouseEventEntry(MouseEvent.MOUSE_MOVE, dragXTo, dragYTo, arr.length * delay));
    arr.push(createMouseEventEntry(MouseEvent.MOUSE_MOVE, dragXTo, dragYTo, arr.length * delay));
    arr.push(createMouseEventEntry(MouseEvent.MOUSE_MOVE, dragXTo, dragYTo, arr.length * delay));
    
    // then a mouseMove at the destination
    arr.push(createMouseEventEntry(MouseEvent.MOUSE_MOVE, dragXTo, dragYTo, arr.length * delay));
    
    // finally a mouseUp at the destination
    arr.push(createMouseEventEntry(MouseEvent.MOUSE_UP, dragXTo, dragYTo, arr.length * delay));
    
    return arr;
}
    
/**
 * Fires a mouseEvent of the given type and location on the target.
 * 
 * This method inspired by DispatchMouseClickEvent and tweaked to be 
 * a static method available outside of Mustella too. This means a few 
 * more optional parameters.
 */
public static function dispatchMouseEvent(actualTarget:Object, 
                                          type:String, 
                                          localX:Number = NaN, 
                                          localY:Number = NaN, 
                                          stageX:Number = NaN, 
                                          stageY:Number = NaN,
                                          ctrlKey:Boolean = false, 
                                          shiftKey:Boolean = false, 
                                          delta:Number = 0,
                                          relatedObject:Object = null):void
{
    var event:MouseEvent = new MouseEvent(type, true); // all mouse events bubble
    event.ctrlKey = ctrlKey;
    event.shiftKey = shiftKey;
    event.buttonDown = type == "mouseDown";
    event.delta = delta;
    if (relatedObject && relatedObject.length > 0)
    {
        // SEJS: Removing Mustella specific context stuff for now so this static method
        // is available outside of Mustella too. TODO: Look into refactoring to allow this support
        //
        //event.relatedObject = InteractiveObject(context.stringToObject(relatedObject));
    }
    
    var stagePt:Point;
    if (!isNaN(localX) && !isNaN(localY))
    {
        stagePt = actualTarget.localToGlobal(new Point(localX, localY));
    }
    else if (!isNaN(stageX) && !isNaN(stageY))
    {
        stagePt = new Point(stageX, stageY);
    }
    else
    {
        stagePt = actualTarget.localToGlobal(new Point(0, 0));
    }
    // SEJS: Removing Mustella specific context stuff for now so this static method
    // is available outside of Mustella too. TODO: Look into refactoring to allow this support
    //
    // This class was inspired by DispatchMouseClickEvent, but in a mobile sense we don't care
    // about other sandboxes for now so we can hopefully remove this mustella context sensitive code
    //
    //root[mouseX] = stagePt.x;
    //root[mouseY] = stagePt.y;
    //UnitTester.setMouseXY(stagePt);
    //
    //if (root["topLevelSystemManager"] != root)
    //{
    //    root["topLevelSystemManager"][mouseX] = stagePt.x;
    //    root["topLevelSystemManager"][mouseY] = stagePt.y;
    //}
    
    if (actualTarget is DisplayObjectContainer && actualTarget.stage != null)
    {
        var targets:Array = actualTarget.stage.getObjectsUnderPoint(stagePt);
        // SEJS: Removing Mustella specific context stuff for now so this static method
        // is available outside of Mustella too. TODO: Look into refactoring to allow this support
        //
        // This class was inspired by DispatchMouseClickEvent, but in a mobile sense we don't care
        // about other sandboxes for now so we can hopefully remove this mustella context sensitive code
        //
        //var arr:Array = UnitTester.getObjectsUnderPoint(DisplayObject(actualTarget), stagePt);
        //targets = targets.concat(arr);
        
        for (var i:int = targets.length - 1; i >= 0; i--)
        {
            if (targets[i] is InteractiveObject)
            {
                if (targets[i] is TextField && !targets[i].selectable)
                {
                    actualTarget = targets[i].parent;
                    break;
                }
                
                if (InteractiveObject(targets[i]).mouseEnabled)
                {
                    actualTarget = targets[i];
                    break;
                }
            }
            else if (targets[i] is Shape)
            {
                // Looks like getObjectsUnderPoint() returns a Shape for FXG elements.
                // Here we assume that if we see a Shape like this then we check its parent 
                // DisplayObjectContainer to see if it has mouseEnabled true 
                // FIXME: Talk to BriFN and AleFN to see if this is the right fix and get it into DispatchMouseEvent/DispatchMouseClickEvent and here.  is this a player bug?
                var shapeParent:DisplayObjectContainer = (targets[i] as Shape).parent;
                if (shapeParent.mouseEnabled)
                {
                    actualTarget = targets[i];
                    break;
                }
            }
            else
            {
                try
                {
                    actualTarget = targets[i].parent;
                    while (actualTarget)
                    {
                        if (actualTarget is InteractiveObject)
                        {
                            if (InteractiveObject(actualTarget).mouseEnabled)
                            {
                                break;
                            }
                        }
                        actualTarget = actualTarget.parent;
                    }
                    if (actualTarget)
                        break;
                }
                catch (e:Error)
                {
                    trace('error');
                    if (actualTarget)
                        break;
                }
            }
        }
    }
    
    // Examine parent chain for "mouseChildren" set to false:
    try
    {
        var parent:DisplayObjectContainer = actualTarget.parent;
        while (parent)
        {
            if (!parent.mouseChildren){
                trace('mouseChildren step: set actualTarget to parent:', parent);                
                actualTarget = parent;
            }
            parent = parent.parent;
        }
    }
    catch (e1:Error)
    {
    }
    
    var localPt:Point = actualTarget.globalToLocal(stagePt);
    event.localX = localPt.x;
    event.localY = localPt.y;
    
    if (actualTarget is TextField)
    {
        if (type == "mouseDown")
        {
            var charIndex:int = actualTarget.getCharIndexAtPoint(event.localX, event.localY);
            actualTarget.setSelection(charIndex + 1, charIndex + 1);
        }
    }
    
    try
    {
        actualTarget.dispatchEvent(event);
    }
    catch (e2:Error)
    {
        trace("Error: Exception thrown in TouchScrollingUtil.dispatchMouseEvent()");
        // SEJS: Removing Mustella specific context stuff for now so this static method
        // is available outside of Mustella too. TODO: Look into refactoring to allow this support
        //
        //TestOutput.logResult("Exception thrown in DispatchMouseClickEvent.");
        //testResult.doFail (e2.getStackTrace());	
        return;
    }
}

/** placeholder for the function closure so the listener can be removed later */ 
private static var traceFunctionHolder:Function = null;

/** placeholder for the function closure so the listener can be removed later */
private static var enterFunctionHolder:Function = null;

/**
 * Traces all of the relevant mouse events that happen on the target.  You can access an array of
 * these events via the recordedMoueEvents static property.
 * 
 * @param target - the component to track mouse events on
 * @param showEnterFrameEvents - set this to true to show when enterFrames are being fired within the sequence
 */
public static function enableMouseEventTracking(target:DisplayObject, showEnterFrameEvents:Boolean = false):void 
{
    // closure for tracing mouse events
    var traceMouseEvents:Function = function (event:MouseEvent):void
    {
        // convert the stage value to be relative to the main target
        var stagePt:Point = event.target.localToGlobal(new Point(event.localX, event.localY));
        var targetPt:Point = target.globalToLocal(stagePt);
        
        var newEvent:Object = new Object();
        newEvent.target = target;
        newEvent.type = event.type;
        newEvent.localX = targetPt.x;
        newEvent.localY = targetPt.y;
        newEvent.fakeTimeValue = flash.utils.getTimer();

        // track this event
        recordedMouseEvents.push(newEvent);
        
        // trace the event
        trace(newEvent.type, newEvent.localX, newEvent.localY, newEvent.fakeTimeValue);
    }
    
    // closure for tracing enterFrame events
    var traceEnterFrameEvents:Function = function (event:Event):void 
    {
        if (showEnterFrameEvents)
            trace(event.type);
    }
    
    // throw the closures into the static placeholders so they can be removed later
    traceFunctionHolder = traceMouseEvents;
    enterFunctionHolder = traceEnterFrameEvents;
    
    // listen to enterFrame and all mouse events (use a higher priority than Scroller)
    // TODO: Containers seem to need a different useCapture value than elements
    if (target is IVisualElementContainer)
    {
        target.addEventListener(MouseEvent.CLICK, traceFunctionHolder, true, 1);
        target.addEventListener(MouseEvent.CONTEXT_MENU, traceFunctionHolder, true, 1);
        target.addEventListener(MouseEvent.DOUBLE_CLICK, traceFunctionHolder, true, 1);
        target.addEventListener(MouseEvent.MIDDLE_CLICK, traceFunctionHolder, true, 1);
        target.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, traceFunctionHolder, true, 1);
        target.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, traceFunctionHolder, true, 1);
        target.addEventListener(MouseEvent.MOUSE_DOWN, traceFunctionHolder, true, 1);
        target.addEventListener(MouseEvent.MOUSE_MOVE, traceFunctionHolder, true, 1);
        target.addEventListener(MouseEvent.MOUSE_OUT, traceFunctionHolder, true, 1);
        target.addEventListener(MouseEvent.MOUSE_OVER, traceFunctionHolder, true, 1);
        target.addEventListener(MouseEvent.MOUSE_UP, traceFunctionHolder, true, 1);
        target.addEventListener(MouseEvent.MOUSE_WHEEL, traceFunctionHolder, true, 1);
        target.addEventListener(MouseEvent.RIGHT_CLICK, traceFunctionHolder, true, 1);
        target.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, traceFunctionHolder, true, 1);
        target.addEventListener(MouseEvent.RIGHT_MOUSE_UP, traceFunctionHolder, true, 1);
        target.addEventListener(MouseEvent.ROLL_OUT, traceFunctionHolder, true, 1);
        target.addEventListener(MouseEvent.ROLL_OVER, traceFunctionHolder, true, 1);
    } 
    else 
    {
        target.addEventListener(MouseEvent.CLICK, traceFunctionHolder, false, 1);
        target.addEventListener(MouseEvent.CONTEXT_MENU, traceFunctionHolder, false, 1);
        target.addEventListener(MouseEvent.DOUBLE_CLICK, traceFunctionHolder, false, 1);
        target.addEventListener(MouseEvent.MIDDLE_CLICK, traceFunctionHolder, false, 1);
        target.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, traceFunctionHolder, false, 1);
        target.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, traceFunctionHolder, false, 1);
        target.addEventListener(MouseEvent.MOUSE_DOWN, traceFunctionHolder, false, 1);
        target.addEventListener(MouseEvent.MOUSE_MOVE, traceFunctionHolder, false, 1);
        target.addEventListener(MouseEvent.MOUSE_OUT, traceFunctionHolder, false, 1);
        target.addEventListener(MouseEvent.MOUSE_OVER, traceFunctionHolder, false, 1);
        target.addEventListener(MouseEvent.MOUSE_UP, traceFunctionHolder, false, 1);
        target.addEventListener(MouseEvent.MOUSE_WHEEL, traceFunctionHolder, false, 1);
        target.addEventListener(MouseEvent.RIGHT_CLICK, traceFunctionHolder, false, 1);
        target.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, traceFunctionHolder, false, 1);
        target.addEventListener(MouseEvent.RIGHT_MOUSE_UP, traceFunctionHolder, false, 1);
        target.addEventListener(MouseEvent.ROLL_OUT, traceFunctionHolder, false, 1);
        target.addEventListener(MouseEvent.ROLL_OVER, traceFunctionHolder, false, 1); 
    }
    
    target.addEventListener(Event.ENTER_FRAME, enterFunctionHolder);
    
}

/**
 * Removes the mouse and enterFrame event listeners from the target.
 */
public static function disableMouseEventTracking(target:DisplayObject):void 
{
    if (target is IVisualElementContainer)
    {
        target.removeEventListener(MouseEvent.CLICK, traceFunctionHolder, true);
        target.removeEventListener(MouseEvent.CONTEXT_MENU, traceFunctionHolder, true);
        target.removeEventListener(MouseEvent.DOUBLE_CLICK, traceFunctionHolder, true);
        target.removeEventListener(MouseEvent.MIDDLE_CLICK, traceFunctionHolder, true);
        target.removeEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, traceFunctionHolder, true);
        target.removeEventListener(MouseEvent.MIDDLE_MOUSE_UP, traceFunctionHolder, true);
        target.removeEventListener(MouseEvent.MOUSE_DOWN, traceFunctionHolder, true);
        target.removeEventListener(MouseEvent.MOUSE_MOVE, traceFunctionHolder, true);
        target.removeEventListener(MouseEvent.MOUSE_OUT, traceFunctionHolder, true);
        target.removeEventListener(MouseEvent.MOUSE_OVER, traceFunctionHolder, true);
        target.removeEventListener(MouseEvent.MOUSE_UP, traceFunctionHolder, true);
        target.removeEventListener(MouseEvent.MOUSE_WHEEL, traceFunctionHolder, true);
        target.removeEventListener(MouseEvent.RIGHT_CLICK, traceFunctionHolder, true);
        target.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, traceFunctionHolder, true);
        target.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, traceFunctionHolder, true);
        target.removeEventListener(MouseEvent.ROLL_OUT, traceFunctionHolder, true);
        target.removeEventListener(MouseEvent.ROLL_OVER, traceFunctionHolder, true);
    }
    else
    {        
        target.removeEventListener(MouseEvent.CLICK, traceFunctionHolder, false);
        target.removeEventListener(MouseEvent.CONTEXT_MENU, traceFunctionHolder, false);
        target.removeEventListener(MouseEvent.DOUBLE_CLICK, traceFunctionHolder, false);
        target.removeEventListener(MouseEvent.MIDDLE_CLICK, traceFunctionHolder, false);
        target.removeEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, traceFunctionHolder, false);
        target.removeEventListener(MouseEvent.MIDDLE_MOUSE_UP, traceFunctionHolder, false);
        target.removeEventListener(MouseEvent.MOUSE_DOWN, traceFunctionHolder, false);
        target.removeEventListener(MouseEvent.MOUSE_MOVE, traceFunctionHolder, false);
        target.removeEventListener(MouseEvent.MOUSE_OUT, traceFunctionHolder, false);
        target.removeEventListener(MouseEvent.MOUSE_OVER, traceFunctionHolder, false);
        target.removeEventListener(MouseEvent.MOUSE_UP, traceFunctionHolder, false);
        target.removeEventListener(MouseEvent.MOUSE_WHEEL, traceFunctionHolder, false);
        target.removeEventListener(MouseEvent.RIGHT_CLICK, traceFunctionHolder, false);
        target.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, traceFunctionHolder, false);
        target.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, traceFunctionHolder, false);
        target.removeEventListener(MouseEvent.ROLL_OUT, traceFunctionHolder, false);
        target.removeEventListener(MouseEvent.ROLL_OVER, traceFunctionHolder, false);
    }
        
    target.removeEventListener(Event.ENTER_FRAME, enterFunctionHolder);
}

/**
 * Returns a String representation of the given array of events as MouseEventEntry tags
 * 
 * Example: <MouseEventEntry type="mouseMove" localX="8" localY="0" fakeTimeValue="21515" />
 */
public static function getEventsAsMXMLString(events:Array):String 
{
    var output:String = "";
    for each (var e:Object in events)
        output += '<MouseEventEntry type="' + e.type + '" localX="' + e.localX + '" localY="' + e.localY + '" fakeTimeValue="' + e.fakeTimeValue + '" />\n';
    return output;
}

/**
 * Returns a visual representation of the given sequence of mouse events.
 */
public static function getEventsAsPath(events:Array, recordedDPI:Number = NaN):Group
{
    // create a new group to hold the path and circles
    var g:Group = new Group();
    g.mouseEnabled = false;
    
    var p:Path = new Path();
    p.stroke = new SolidColorStroke(0xFFFF00, 3);
    p.data = "";
    g.addElement(p);
    
    // add a point to the path for each event
    for (var i:int = 0; i < events.length; i++)
    {
        var e:Object = events[i];
        
        // scale the co-ordinates if DPI scaling is requested
        var adjustedLocalX:Number = scaleByDPIRatio(e.localX, recordedDPI);
        var adjustedLocalY:Number = scaleByDPIRatio(e.localY, recordedDPI);
        
        if (i == 0)
            p.data += "M " + adjustedLocalX + " " + adjustedLocalY + " ";
        else
            p.data += "L " + adjustedLocalX + " " + adjustedLocalY + " ";
        
        if (e.type == MouseEvent.MOUSE_DOWN)
        {
            // draw a mouse down circle (green)
            var downCircle:Ellipse = createCircle(10, 0x00FF00);
            downCircle.x = adjustedLocalX - downCircle.width / 2;
            downCircle.y = adjustedLocalY - downCircle.height / 2;
            
            g.addElement(downCircle);
        }
        
        if (e.type == MouseEvent.MOUSE_UP)
        {
            // draw a mouse up circle (red)
            var upCircle:Ellipse = createCircle(10, 0xFF0000);
            upCircle.x = adjustedLocalX - upCircle.width / 2;
            upCircle.y = adjustedLocalY - upCircle.height / 2;
            
            g.addElement(upCircle);
        }
    }
    
    return g;
}

/**
 * Returns a circle of the given radius and fill color
 */
private static function createCircle(radius:Number, fillColor:uint):Ellipse 
{
    var c:Ellipse = new Ellipse();
    c.width = radius;
    c.height = radius;
    var solidColor:SolidColor = new SolidColor(fillColor);
    c.fill = solidColor;
    return c;
}

/**
 * Writes the given content string to the disk at location fileName.
 * 
 * Useful for writing sequences of mouse events to disk on the phone and
 * transferring that off of the device.
 * 
 * Sample usage:
 * 
 * writeFileToDisk('/sdcard/Flex/QA/List/mouseEvents.txt', 
 *                 TouchScrollingUtil.getEventsAsMXMLString(TouchScrollingUtil.recordedMouseEvents));
 */
public static function writeFileToDisk(fileName:String, content:String):void
{
    var file:File = new File (fileName);
    var fileStream:FileStream = new FileStream();
    
    fileStream.open(file, FileMode.WRITE);
    fileStream.writeUTF(content);
    fileStream.close();
}

/**
 * Basically just calls trace(), but only does so if the verbose flag
 * is set to true.  This helps us avoid inflating the log with hundreds
 * of extra trace statements while running in Mustella.
 */
private static function traceLog(... rest):void
{
    // don't trace this message if debugging isn't enabled
    if (!enableVerboseTraceOuput)
        return;
    
    // format the output the same way trace() does with a space
    // in between each piece of the rest array
    
    var output:String = "";
    var i:int = 0;
    const restLength:int = rest.length;
    
    for (i = 0; i < restLength; i++)
    {
        output += rest[i];
        if (i < restLength - 1)
            output += " ";
    }
    
    trace(output);
}

}

}

