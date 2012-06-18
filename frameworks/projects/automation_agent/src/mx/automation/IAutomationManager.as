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

package mx.automation
{

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.IEventDispatcher;

import mx.automation.events.AutomationRecordEvent;
import mx.automation.events.AutomationReplayEvent;

/**
 *  The IAutomationManager interface defines the interface expected 
 *  from an AutomationManager object by the automation module.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IAutomationManager 
        extends IEventDispatcher
{
    /**
     *  Returns the next parent that is visible within the automation hierarchy.
     *
     *  @param obj Automation object.
     *
     *  @param parentToStopAt Parent of the given automation object.
     *
     *  @param ignoreShowInHierarchy Boolean that determines whether object is ignored 
     *  within the automation hierarchy. The default value is <code>false</code>.    
     *
     *  @return Nearest parent of the object visible within the automation 
     *          hierarchy.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getParent(obj:IAutomationObject, 
                       parentToStopAt:IAutomationObject = null,
                       ignoreShowInHierarchy:Boolean = false):IAutomationObject;
        
    /**
     *  Returns all children of this object that are visible within the testing
     *  hierarchy and meet the criteria in the automation part.  
     *  If a child is not visible within the hierarchy, this method
     *  returns the children of the invisible child.
     *  
     *  @param obj Object for which to get the children.
     * 
     *  @param part Criteria of which children to return.
     * 
     *  @param ignoreShowInHierarchy Boolean that determines whether object is ignored 
     *  within the automation hierarchy. The default value is <code>false</code>.    
     *
     *  @return Array of children matching the criteria.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getChildrenFromIDPart(obj:IAutomationObject,
                                   part:AutomationIDPart = null,
                                   ignoreShowInHierarchy:Boolean = false):Array;

    /**
     *  Returns all children of this object that are visible within the testing
     *  hierarchy. If a child is not visible within the hierarchy, 
     *  returns the children of the invisible child.
     *  
     *  @param obj Object for which to get the children.
     *
     *  @param ignoreShowInHierarchy
     * 
     *  @param ignoreShowInHierarchy Boolean that determines whether object is ignored 
     *  within the automation hierarchy. The default value is <code>false</code>.    
     *
     *  @return Array of children.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getChildren(obj:IAutomationObject,
                         ignoreShowInHierarchy:Boolean = false):Array;
    
    /**
     *  Returns the text to display as the description for the object.
     *  
     *  @param obj Automation object.
     * 
     *  @return Text description of the Automation object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getAutomationName(obj:IAutomationObject):String;

    /**
     *  Returns the text to display as the type of the object.
     *
     *  @param obj Automation object.
     * 
     *  @return Type of the object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getAutomationClassName(obj:IAutomationObject):String;

    /**
     *  Returns the values for a set of properties.
     *
     *  @param obj Object for which to get the properties.
     * 
     *  @param names Names of the properties to evaluate on the object.
     * 
     *  @param forVerification If <code>true</code>, only include verification properties.
     * 
     *  @param forDescription If <code>true</code>, only include description properties.
     * 
     *  @return Array of objects that contain each property value and descriptor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getProperties(obj:IAutomationObject, 
                           names:Array = null, 
                           forVerification:Boolean = true, 
                           forDescription:Boolean = true):Array;
    
    /**
     * Returns the object implementing the IAutomationTabularData interface through which
     * the tabular data can be obtained.
     *
     *  @param obj An IAutomationObject.
     * 
     *  @return An object implementing the IAutomationTabularData interface. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getTabularData(obj:IAutomationObject):IAutomationTabularData;

    /**
     *  Indicates whether recording is taking place.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get recording():Boolean;

    /**
     *  Indicates whether replay is taking place.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get replaying():Boolean;

    /**
     *  Sets the automation manager to record mode.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function beginRecording():void;

    /**
     *  Takes the automation manager out of record mode.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function endRecording():void;

    /**
     *  Returns the automation object under the given coordinate.
     *
     *  @param x The x coordinate.
     * 
     *  @param y The y coordinate.
     * 
     *  @return Automation object at that point.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */    
    function getElementFromPoint(x:int, y:int):IAutomationObject;

    /**
     *  The display rectangle enclosing the DisplayObject.
     *
     *  @param obj DisplayObject whose rectangle is desired.
     *
     *  @return An array of four integers: top, left, width and height.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getRectangle(obj:DisplayObject):Array;

    /**
     *  Returns <code>true</code> if an object and all of its parents are visible.
     *  
     *  @param obj DisplayObject.
     *
     *  @return <code>true</code> if an object and all of its parents are visible.
     * 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function isVisible(obj:DisplayObject):Boolean;

    /**
     *  Resolves an id to an automation object.
     *
     *  @param rid Automation id of the automation object.
     *
     *  @param currentParent Current parent of the automation object.
     * 
     *  @return IAutomationObject which matches with the <code>rid</code>. 
     *  If no object 
     *  is found or multiple objects are found, this method throws an exception.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function resolveIDToSingleObject(rid:AutomationID, 
                                     currentParent:IAutomationObject = null):IAutomationObject;

    /**
     *  Resolves an id to automation objects.
     *  
     *  @param rid Automation id of the automation object.
     *
     *  @param currentParent Current parent of the automation object.
     * 
     *  @return An Array containing all the objects matching the <code>rid</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function resolveID(rid:AutomationID, 
                       currentParent:IAutomationObject = null):Array;
            
    /**
     *  Resolves an id part to an automation object within the parent.
     *
     *  @param parent Parent of the automation object.
     *
     *  @param part id part of the automation object.
     *
     *  @return IAutomationObject which matches with the <code>part</code>. 
     *  If no object 
     *  is found or multiple objects are found, throw an exception.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function resolveIDPartToSingleObject(parent:IAutomationObject,
                                         part:AutomationIDPart):IAutomationObject;
    
    /**
     *  Resolves an id part to an Array of automation objects.
     * 
     *  @param parent Parent of the automation object.
     *
     *  @param part id part of the automation object.
     *
     *  @return Array of automation objects which match <code>part</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function resolveIDPart(parent:IAutomationObject,
                           part:AutomationIDPart):Array;

    /**
     *  Returns an id for the given object that can be used 
     *  with the <code>resolveID()</code> method.
     *
     *  @param obj Automation object.
     *
     *  @param relativeToParent Parent of the automation object.
     *  
     *  @return AutomationID object which represents the Automation object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function createID(obj:IAutomationObject, 
                      relativeToParent:IAutomationObject = null):AutomationID;

    /**
     *  Returns an id part for the given object that can be used in the <code>resolveIDPart()</code> method.
     * 
     *  @param obj The automation object.
     *
     *  @param parent Parent of the automation object.
     *  
     *  @return AutomationIDPart object which represents the Automation object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function createIDPart(obj:IAutomationObject, 
                          parent:IAutomationObject = null):AutomationIDPart;

    /**
     *  Indicates whether an automation object should be visible within
     *  the hierarchy.
     *
     *  @param obj The automation object.
     * 
     *  @return <code>true</code> if the object should be shown within the
     *  automation hierarchy.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function showInHierarchy(obj:IAutomationObject):Boolean;

    /**
     *  @private
     */
    function set automationEnvironment(env:Object):void;

    /**
     *  The automation environment for this automation manager.
     *  The automation environment provides information about the
     *  objects and properties of testable components needed for communicating
     *  with agent tools.
     *
     *  <p>The value of this property must implement the IAutomationEnvironment interface.</p>
     *
     *  @see mx.automation.IAutomationEnvironment
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get automationEnvironment():Object;

    /**
     *  Increments the cache counter. The automation mechanism  
     *  caches both an object's properties and its children. The cache
     *  exists for both performance reasons, and so that an objects state
     *  prior to a recording can be captured. Each call to the 
     *  <code>incrementCacheCounter()</code> method
     *  increments a counter and each call to the 
     *  <code>decrementCacheCounter()</code> method 
     *  decrements the cache counter. When the counter reaches zero the
     *  cache is cleared. 
     *
     *  <p>It's important that testing tools only use the
     *  cache when they are certain that the state of the Flex application
     *  is frozen and the user cannot interact with it. For example,
     *  when an automation event is recorded, a testing tool might need to make
     *  several calls to  the <code>getChildren()</code> method or the
     * <code>getProperties()</code> method to create a testing
     *  script line. To do this, it would wrap all the calls up in 
     *  start/stop cache calls.</p>
     *
     *  <p>Internally, the AutomationManager forcibly clears the cache
     *  before an end-user interaction that might trigger an automation
     *  event. It then increments the cache counter and decrements the
     *  counter after the automation event is dispatched. Testing tools can
     *  prevent the count from reaching zero by calling the <code>incrementCacheCounter()</code> 
     *  method in their record handler.</p>
     *
     *  @return the current cache counter.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function incrementCacheCounter():int;

    /**
     *  Decrement the cache counter. The cache is cleared when
     *  the count reaches zero.
     *
     *  @param clearNow If <code>true</code>, clear the cache regardless of the cache counter.
     * 
     *  @return Current cache counter.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function decrementCacheCounter(clearNow:Boolean = false):int;


    /**
     * Tests if the provided target needs to wait until a previous
     * operation completes.
     * 
     * @param target Target to check for synchronization or
     * <code>null</code> to synchronize on any running operations.
     * 
     * @return <code>true</code> if synchronization is complete, <code>false</code> otherwise.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function isSynchronized(target:IAutomationObject):Boolean;

    /**
     *  Records the event.
     *
     *  @param recorder The automation object on which the event is to be recorded.
     *
     *  @param event The actual event which needs to be recorded. 
     *
     *  @param cacheable Controls the caching of the event that is recorded. 
     *  During a mouse-down, mouse-up sequence, the automation mechanism tries to record the most 
     *  important or suitable event rather than all the events. 
     *
     *  For example, if you have a List control which has a button in its item renderer. 
     *  When the user clicks on the button, the automation mechanism only records 
     *  the <code>click</code> event for the button, but ignores the <code>select</code> event 
     *  generated from the List control.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function recordAutomatableEvent(recorder:IAutomationObject, event:Event,
                                    cacheable:Boolean = false):void;
    
    /**
     *  Replays the specified event. A component author should call 
     *  the <code>super.replayAutomatableEvent()</code> method 
     *  in case default replay behavior has been defined in a superclass.
     *
     *  @param event Event to replay.
     *
     *  @return <code>true</code> if the replay was successful. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function replayAutomatableEvent(event:AutomationReplayEvent):Boolean;
    
    
     /**
     *  Records the  custom event.
     *
     *  @param recordEvent -  The AutomationRecordEvent that specifies that it is a custom evnet; the type is customRecord.
     *
     *  For example, if you want to record a custom event without writing a delegate and providing the details
     *  in an environment file, you can use this interface to record the custom event. You should listen to
     *  the AutomationPlaybackEvent, handle the replay, and prevent the default on the AutomationPlaybackEvent.
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function recordCustomAutomationEvent(customEvent:AutomationRecordEvent):Boolean;

}

}
