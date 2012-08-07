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
package {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.utils.Timer;

import mx.core.mx_internal;
import mx.utils.GetTimerUtil;

use namespace mx_internal;

/**
 *  Instead of a property, we use an event so the MXML compiler 
 *  will compile the valueExpression string into ActionScript for us
 */
[Event(name="valueExpression", type="flash.events.Event")]

[DefaultProperty("value")] 

/**
 * The test step that fakes a sequence of mouse events that correspond to a drag or throw scroll.
 * 
 * The default waitEvent is simulationComplete which fires after all mouse events have been fired.
 * However when doing drag or throw scrolls you typically want to wait for the touchInteractionEnd
 * event that fires after the scroll is completed and all related effects have completed
 * 
 * TODO: Code review from BriFN
 * 
 * https://zerowing.corp.adobe.com/display/flexsdk/SimulateMouseGesture
 * 
 * MXML attributes:
 *  target
 *  value (default property)
 *  recordedDPI
 *  dragXFrom
 *  dragYFrom
 *  dragXTo
 *  dragYTo
 */
public class SimulateMouseGesture extends TestStep
{

/**
 *  @private
 */
override public function execute(root:DisplayObject, context:UnitTester, testCase:TestCase, testResult:TestResult):Boolean
{
    this.root = root;
    this.context = context;
    this.testCase = testCase;
    this.testResult = testResult;
    
    UnitTester.blockFocusEvents = false;
    
    var actualTarget:Object = context.stringToObject(target);
    if (!actualTarget)
    {
        testResult.doFail("Target " + target + " not found");
        UnitTester.blockFocusEvents = true;
        return false;
    }
    
    // make sure we have a wait target
    if (waitTarget == null)
        waitTarget = target;

    // listen for when to finish this test step which is either
    // after the given waitEvent, or if that isn't specified then 
    // after SIMULATION_COMPLETE which is fired after 
    // each event in the list is fired.
    if (waitEvent == null)
        waitEvent = TouchScrollingUtil.SIMULATION_COMPLETE;

    // setup the waitEvent listener
    trace("SimulateMouseGesture will wait for", waitEvent);
    actualTarget.addEventListener(waitEvent, waitEventHandler);
    
    // if this step defines a valueExpression then pull the events array from that
    try
    {
        if (hasEventListener("valueExpression"))
        {
            context.resetValue();
            dispatchEvent(new RunCodeEvent("valueExpression", root["document"], context, testCase, testResult));
            value = context.value as Array;
            if (!context.valueChanged)
                TestOutput.logResult("WARNING: value was not set by valueExpression.  'value=' missing from expression?");
        }
    }
    catch (e:Error)
    {
        TestOutput.logResult("Exception thrown evaluating value expression.");
        testResult.doFail (e.getStackTrace());	
        return false;
    }
    
    try 
    {
        // When no array of mouseEvents is provided then one is created based on dragXFrom/dragXTo/etc.
        // This delay is the amount of fake time in between each of those generated events.
        // 
        // This was once a default of 17, but was increased to 45 based on some changes Eric made
        // I dont think I ever figured out why it was needed, but it doesn't really matter for this
        // convenience case with no events array defined.
        var delay:Number = 45;
        
        // The dragXFrom/dragYFrom/dragXTo/dragYTo convenience properties are typed as Object 
        // so they can be expressed as an integer or as a percentage.
        // If a percentage was requested then adjust these values by the width of the target
        
        // TODO: Fix documentation on the convenience properties
        
        var actualDragXFrom:Number = Number(dragXFrom);
        var actualDragYFrom:Number = Number(dragYFrom);
        var actualDragXTo:Number = Number(dragXTo);
        var actualDragYTo:Number = Number(dragYTo);
        
        // dragXFrom was not an obvious number so treat it as a percentage string
        if (isNaN(actualDragXFrom))
            actualDragXFrom = Math.round(actualTarget.width * getPercentage(dragXFrom));
        
        // dragYFrom was not an obvious number so treat it as a percentage string
        if (isNaN(actualDragYFrom))
            actualDragYFrom = Math.round(actualTarget.height * getPercentage(dragYFrom));
        
        // dragXTo was not an obvious number so treat it as a percentage string
        if (isNaN(actualDragXTo))
            actualDragXTo = Math.round(actualTarget.width * getPercentage(dragXTo));
        
        // dragYTo was not an obvious number so treat it as a percentage string
        if (isNaN(actualDragYTo))
            actualDragYTo = Math.round(actualTarget.height * getPercentage(dragYTo));
        
        // TouchScrollingUtil provides two ways of simulating an array of events.  One is timer-based the other is frame-based.
        // When running in Mustella we must use the frame-based option.
        TouchScrollingUtil.simulateTouchScrollFrameBased(actualTarget, value, recordedDPI, 
                                                         actualDragXFrom, actualDragYFrom, actualDragXTo, actualDragYTo, delay);
    } 
    catch (e:Error) 
    {
        TestOutput.logResult("Exception thrown in SimulateMouseGesture.");
        testResult.doFail(e.getStackTrace());	
    }
    
    UnitTester.blockFocusEvents = true;
    
    // this test step always has a waitEvent so execute() should return false
    return false;
}

/** TODO */
private function getPercentage(o:Object):Number
{
    var s:String = String(o);
    return Number((String(s)).split("%")[0]) / 100;
}

/**
 *  Call the normal stepComplete() and null out the value to avoid memory leaks.
 */
override protected function waitEventHandler(event:Event):void
{    
    // finish the test step
    stepComplete();
    
    // clean up the array
    value = null;
}

/**
 *  The object that receives the event
 */
public var target:String;

/**
 *  The value to drag scroll from in the x direction.
 */
public var dragXFrom:Object = null;

/**
 *  The value to drag scroll from in the y direction.
 */
public var dragYFrom:Object = null;

/**
 *  The value to drag scroll to in the x direction.
 */
public var dragXTo:Object = null;

/**
 *  The value to drag scroll to in the y direction.
 */
public var dragYTo:Object = null;
    
/**
 * An array of MouseEventEntry objects that represent a sequence of mouse events to dispatch.
 * Use this for realistic simulation since you can control the sequence of, type, location, 
 * and time of each event.
 * 
 * These events should be defined as an array of MouseEventEntry objects in this form:
 * 
 *   <MouseEventEntry type="mouseDown" localX="150" localY="150" fakeTimeValue="0" />
 *   <MouseEventEntry type="mouseMove" localX="149" localY="149" fakeTimeValue="16" />
 *   ...
 *   <MouseEventEntry type="mouseUp" localX="100" localY="100" fakeTimeValue="343" />
 * 
 * If this property is not null then it takes precedence over any
 * dragX/dragY values that might also be defined.
 * 
 * This is the default property.
 */
public var value:Array = null;

/**
 * When this value is set to something other than NaN then the localX/localY properties
 * on each of the MouseEventEntry objects will get scaled by a dpi factor.
 * 
 * That factor is the exact DPI of the running device divided by the exact value of the
 * DPI that the sequence was recorded on.
 * 
 * This allows this tag to simulate drags/throws over a physical distance (inches)
 * rather than over a number of pixels.
 * 
 * If you want the test to scroll the exact same number of pixels on every device it runs
 * on (say 30 pixels) then don't set the recordedDPI property.
 * 
 * If you want the test to scroll by a physical distance (say 1.5 inches) then set the recordedDPI
 * to the value of Capabilities.screenDPI of the device you used to record/author this sequence
 * of events.
 */
public  var recordedDPI:Number = NaN;

/**
 *  customize string representation
 */
override public function toString():String
{
	var s:String = "SimulateMouseGesture: target = ";
	s += target;
    
    if (value != null)
        s += ", value = " + value.length + " MouseEventEntry";
    else
        s += ", value = null";
    
    s += ", recordedDPI = " + recordedDPI;
    s += ", dragXFrom = " + dragXFrom;
    s += ", dragYFrom = " + dragYFrom;
    s += ", dragXTo = " + dragXTo;
    s += ", dragYTo = " + dragYTo;
	return s;
}
}

}
