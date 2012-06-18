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

import flash.events.IEventDispatcher;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

/**
 * The IAutomationObjectHelper interface defines 
 * helper methods for IAutomationObjects.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IAutomationObjectHelper
{
    /**
     *  Creates an id for a given child within a parent.
     *
     *  @param parent Parent of object for which to create and id.
     *
     *  @param child Object for which to create an id.
     *
     *  @param automationNameCallback A user-supplied function used 
     *  to determine the child's <code>automationName</code>.
     *
     *  @param automationIndexCallback A user-supplied function used 
     *  to determine the child's <code>automationIndex</code>.
     *
     *  @return An AutomationIDPart object representing the child within the parent.
     * 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function helpCreateIDPart(parent:IAutomationObject,
                              child:IAutomationObject,
                              automationNameCallback:Function = null,
                              automationIndexCallback:Function = null):AutomationIDPart;
	
	
	/**
	 *  Creates an id for a given child within a parent.
	 *
	 *  @param parent Parent of object for which to create and id.
	 *
	 *  @param child Object for which to create an id.
	 *
	 *  @param properties which needs to be considered for creating the id.
	 *
	 *  @param automationNameCallback A user-supplied function used 
	 *  to determine the child's <code>automationName</code>.
	 *
	 *  @param automationIndexCallback A user-supplied function used 
	 *  to determine the child's <code>automationIndex</code>.
	 *
	 *  @return An AutomationIDPart object representing the child within the parent.
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function helpCreateIDPartWithRequiredProperties(parent:IAutomationObject,
							  child:IAutomationObject,
							  properties:Array,
							  automationNameCallback:Function = null,
							  automationIndexCallback:Function = null):AutomationIDPart;

    /**
     * Returns an Array of children within a parent which match the id.
     *
     * @param parent Parent object under which the id needs to be resolved.
     *
     * @param part AutomationIDPart object representing the child.
     *
     * @return Array of children which match the id of <code>part</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function helpResolveIDPart(parent:IAutomationObject,
                               part:Object):Array;

    /**
     * Dispatches a <code>KeyboardEvent.KEY_DOWN</code> and 
     * <code>KeyboardEvent.KEY_UP</code> event 
     * for the specified KeyboardEvent object.
     * 
     * @param to Event dispatcher.
     *
     * @param event Keyboard event.     
     *
     * @return <code>true</code> if the events were dispatched.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function replayKeyboardEvent(to:IEventDispatcher, event:KeyboardEvent):Boolean;

    /**
     * Dispatches a <code>KeyboardEvent.KEY_DOWN</code> and 
     * <code>KeyboardEvent.KEY_UP</code> event 
     * from the specified IInteractionReplayer, for the specified key, with the
     * specified modifiers.
     * 
     * @param keyCode Key code for key pressed.
     *
     * @param ctrlKey Boolean indicating whether Ctrl key pressed.
     *
     * @param ctrlKey Boolean indicating whether Shift key pressed.
     *
     * @param ctrlKey Boolean indicating whether Alt key pressed.
     *
     * @return <code>true</code> if the events were dispatched.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function replayKeyDownKeyUp(to:IEventDispatcher,
                                keyCode:uint,
                                ctrlKey:Boolean = false,
                                shiftKey:Boolean = false,
                                altKey:Boolean = false):Boolean;
        
    /**
     * Dispatches a MouseEvent while simulating mouse capture.
     *
     * @param target Event dispatcher.
     *
     * @param event Mouse event.
     *
     * @return <code>true</code> if the event was dispatched.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function replayMouseEvent(target:IEventDispatcher, event:MouseEvent):Boolean;

    /**
     * Dispatches a <code>MouseEvent.MOUSE_DOWN</code>, <code>MouseEvent.MOUSE_UP</code>, 
     * and <code>MouseEvent.CLICK</code> from the specified IInteractionReplayer with the 
     * specified modifiers.
     *
     * @param to Event dispatcher.
     *
     * @param sourceEvent Mouse event.
     *
     * @return <code>true</code> if the events were dispatched.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function replayClick(to:IEventDispatcher, sourceEvent:MouseEvent = null):Boolean;

    /**
     * Replays a <code>click</code> event outside of the main drawing area. 
     * use this method to simulate the <code>mouseDownOutside</code> event.
     *
     * @return <code>true</code> if the event was dispatched.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function replayClickOffStage():Boolean;

    /**
     *  Indicates whether recording is taking place, <code>true</code>, 
     *  or not, <code>false</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get recording():Boolean;

    /**
     *  Indicates whether replay is taking place, <code>true</code>, 
     *  or not, <code>false</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get replaying():Boolean;

    /**
     *  Adds a synchronization object to the automation manager.
     *  The automation manager waits until the <code>isComplete</code> method
     *  returns <code>true</code>
     *  before proceeding with the next replay event.
     *  
     *  @param isComplete Function that indicates whether the synchronized
     *  operation is completed.
     * 
     *  @param target If null, all replay is stalled until  
     *  the <code>isComplete</code> method returns <code>true</code>, 
     *  otherwise the automation manager will only wait
     *  if the next operation is on the target.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function addSynchronization(isComplete:Function,
                                target:Object = null):void;

    /**
     *  Determines whether an object is a composite or not.
     *  If an object is not reachable through the automation APIs 
     *  from the top application then it is considered to be a composite.
     *
     *  @param obj The object.
     *
     * @return <code>true</code> if the object is a composite.     
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function isAutomationComposite(obj:IAutomationObject):Boolean;
    
    /**
     *  Returns the parent of the composite object.
     *
     *  @param obj Composite object.
     *
     *  @return The parent IAutomationObject of the composite object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getAutomationComposite(obj:IAutomationObject):IAutomationObject;

}

}
