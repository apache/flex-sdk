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
import flash.geom.Point;

/**
 *  The IAutomationManager interface defines the interface expected 
 *  from an AutomationManager object by the automation module.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 4
 */
public interface IAutomationManager2 
        extends IAutomationManager
{
   
    /**
     *  The automation environment for this automation manager.
     *  The automation environment provides information about the
     *  objects and properties of testable components needed for communicating
     *  with agent tools.
     *
     *  The value of this property must implement the IAutomationEnvironment interface.
     *
     *  @see mx.automation.IAutomationEnvironment
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
    function set automationEnvironmentString(env:String):void;
	
	/**
	 *  Marshalling Support(for tool): The tool class which is responsible for handling 
	 *  the automation environment.
	 *  
	 *  @param className Complete qualified class name of the class in the tool that handles automation.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	function set automationEnvironmentHandlingClassName(className:String):void;
	
	/**
	 *  Marshalling Support(for tool): Returns unique ID of the application considering 
	 *  the hierarchy using the SWFLoader information and the application name.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	function getUniqueApplicationID():String;
	
	/**
	 *  Marshalling Support(for tool): Returns name of the application from the part id.
	 * 
	 *  @param objectID AutomationIDPart from which the application name is obtained. 
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
   	function getApplicationNameFromAutomationIDPart(objectID:AutomationIDPart):String;
   
	/**
	 *  Marshalling Support(for tool): Returns true if the passed object is a pop up.
	 *  
	 *  @param obj IAutomationObject
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	function isObjectPopUp(obj:IAutomationObject):Boolean;
    // passed objectlist contain the objects which has applicationName which obtained for 
   	// identifying them uniquely in case of the marshalled application.
   	// this method can be used to indetify the top application when there are multiple application
   	// at the same point, get element from point.
	/**
	 *  Marshalling Support(for tool): Returns the index of top visible object among the passed array of objects.
	 *  This can be used by tools to identify the topmost Application object when there are 
	 *  multiple objects from different applications, which belong to different ApplicationDomain or
	 *  different SecurityDomain, under the mouse. 
	 * 
	 *  @param objectList Array of objects
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
   	function getTopApplicationIndex(objectList:Array):int;
    
	/**
	 *  Marshalling Support(for tool): Adds the passed EventDetails objects to the probable 
	 *  parent applications in the current ApplicationDomain.
	 *  AutomationManager identifies the parent applications in the current ApplicationDomain
	 *  which are responsible to listen to the events from children and adds appropriate listeners
	 *  obtained from the passed objects.
	 * 
	 *  @param eventDetailsArray Array of EventDetails objects.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
   	function addEventListenersToAllParentApplications(eventDetailsArray:Array):void;
	
	/**
	 *  Marshalling Support(for tool): Adds the passed EventDetails objects to the probable 
	 *  child applications in the current ApplicationDomain.
	 *  AutomationManager identifies the child applications in the current ApplicationDomain
	 *  as and when the application is loaded, and adds appropriate listeners
	 *  obtained from the passed objects.
	 * 
	 *  @param eventDetailsArray Array of EventDetails objects.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
   	function addEventListenersToAllChildApplications(eventDetailsArray:Array):void;
	
	/**
	 *  Marshalling Support(for tool): Dispatches event to parent applications.
	 * 
	 *  @param event Event to be dispatched.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
   	function dispatchToParent(event:Event):void;
	
	/**
	 *  Marshalling Support(for tool): Dispatches event to all children.
	 * 
	 *  @param event Event to be dispatched.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	function dispatchToAllChildren(event:Event):void;


	// these methods are for delegates to communicate to automation Manager
	/**
	 *  Marshalling Support(for delegates): Stores the drag proxy to enable
	 *  inter-application drag-drop.DragProxy created in one application should be 
	 *  accessible by another application if required. 
	 *  
	 *  @param DragProxy object
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */	
	function storeDragProxy(dragProxy:Object):void; // used by dragmanagerAutomationImpl
	
	/**
	 *  Marshalling Support(for delegates):Returns the number of pop up children of the 
	 *  top level application. All pop up objects created in an application are added as 
	 *  pop up children to the top level application of its ApplicationDomain. 
	 *  
	 *  @return Number of pop up children
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	function getPopUpChildrenCount():Number;
	
	/**
	 *  Marshalling Support(for delegates):Returns array of pop up objects of the top level application.
	 *  All pop up objects created in an application are added as 
	 *  pop up children to the top level application of its ApplicationDomain. 
	 * 
	 *  @return Array of pop up children
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	function getPopUpChildren():Array;
  
	/**
	 *  Marshalling Support(for delegates):Returns array of pop up objects of the root application.
	 *  All pop up objects created in an application are added as 
	 *  pop up children to the top level application of its ApplicationDomain. 
	 *  
	 *  @param index at which the object is to be retrieved 
	 * 
	 *  @return IAutomationObject at the given index
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	function getPopUpChildObject(index:int):IAutomationObject;
   	
	/**
	 *  Marshalling Support(for delegates): When a new application is added, application delegate
	 *  registers itself so that appropriate listeners are added to that in order to support 
	 *  Marshalling.
	 * 
	 *  @param DisplayObject Application object to be registered. 
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	function registerNewApplication(application:DisplayObject):void
   	
	/**
	 *  AIR Support(for delegates): When a new window is added, WindowedApplication delegate registers
	 *  the new window object so that a unique id is created for that window.
	 * 
	 *  @param newWindow Window object to be registered. 
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	function registerNewWindow(newWindow:DisplayObject):void
   	
	/**
	 *  AIR Support(for delegates): When a FlexNativeMenu is added to a component, its delegate
	 *  registers the new FlexNativeMenu object and creates a delegate.
	 *  
	 *  @param menu FlexNativeMenu object to be registered.
	 * 
	 *  @param sm SystemManager of the component in which FlexNativeMenu is added.  
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	function registerNewFlexNativeMenu(menu:Object, sm:DisplayObject):void
   	
	/**
	 *  AIR support(for tool): Returns the unique id of the window object.
	 *  
	 *  @param DisplayObject window whose id is to required.
	 * 
	 *  @return String 
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	function getAIRWindowUniqueID(newWindow:DisplayObject):String;
   	
	/**
	 *  AIR support(for tool): Returns the window with the passed id.
	 * 
	 *  @param windowId id of the window
	 *  
	 *  @return Window with passed id.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	function getAIRWindow(windowId:String):DisplayObject;
   	
	/**
	 *  AIR support(for tool): Returns the automation object under the given coordinate in a window.
	 *
	 *  @param x The x coordinate.
	 * 
	 *  @param y The y coordinate.
	 *  
	 *  @param windowId The window on which the object is to be identified.
	 * 
	 *  @return Automation object at that point.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	function getElementFromPoint2(x:int, y:int,windowId:String ):IAutomationObject;
   	
	/**
	 *  AIR support(for tool): Returns the unique ID of window from the object ID.
	 *  Object ID has application ID and window ID.
	 * 
	 *  @param objectID The object ID from which unique ID of the window is to be obtained.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	function getAIRWindowUniqueIDFromObjectIDString(objectId:String ):String;
   	
	/**
	 *  AIR support(for tool): Returns the unique ID of window from the automation ID part.
	 *  Automation ID part has application ID and window ID.
	 * 
	 *  @param objectIdPart The AutomationIDPart from which unique ID of the window is to be obtained.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	function getAIRWindowUniqueIDFromAutomationIDPart(objectIdPart:AutomationIDPart):String;
   	
	/**
	 *  AIR support(for tool): Used by Flex application loaded from AIR application, 
	 *  to get the start point of main AIR application in screen coordinates
	 *  
	 *  @param windowId
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	function getStartPointInScreenCoordinates(windowId:String):Point;
}   

}
