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

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.system.ApplicationDomain;
import flash.utils.describeType;
import mx.automation.events.AutomationReplayEvent;
import mx.core.mx_internal;

use namespace mx_internal;

/**
 * Method descriptor class.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class AutomationEventDescriptor implements IAutomationEventDescriptor
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    /**
     *  Constructor
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function AutomationEventDescriptor(name:String,
                                               eventClassName:String,
                                               eventType:String,
                                               args:Array)
    {
        super();

        _name = name;
        _eventClassName = eventClassName;
        _eventType = eventType;
        _args = args;
    }

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var _args:Array;
    
    /**
     *  @private
     */
	private var _eventArgASTypesInitialized:Boolean = false;

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  name
	//----------------------------------

    /**
     *  @private
     */
    private var _name:String;

	/**
	 * @private
	 */
    public function get name():String
    {
        return _name;
    }

	//----------------------------------
	//  eventClassName
	//----------------------------------

    /**
     *  @private
     */
    private var _eventClassName:String;

	/**
	 * @private
	 */
    public function get eventClassName():String
    {
        return _eventClassName;
    }
    
	//----------------------------------
	//  eventType
	//----------------------------------

    /**
     *  @private
     */
    private var _eventType:String;

	/**
	 * @private
	 */
    public function get eventType():String
    {
        return _eventType;
    }
    
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
    public function record(target:IAutomationObject, event:Event):Array
    {
        var propertyDescriptors:Array = getArgDescriptors(target);
        
        var result:Array = [];
        var consecutiveDefaultValueCount:Number = 0;
        for (var i:int = 0; i < propertyDescriptors.length; i++)
        {
            var val:Object = event[propertyDescriptors[i].name];
            
            if(val is IAutomationObject)
            	val = IAutomationObject(val).automationValue

			var isDefaultValueNull:Boolean = propertyDescriptors[i].defaultValue == "null";

            consecutiveDefaultValueCount = (!(val == null && isDefaultValueNull) &&
            								(propertyDescriptors[i].defaultValue == null || 
                                             val == null ||
                                             propertyDescriptors[i].defaultValue != val.toString())
                                            ? 0
                                            : consecutiveDefaultValueCount + 1);

            result.push(val);
        }

        result.splice(result.length - consecutiveDefaultValueCount, 
                      consecutiveDefaultValueCount);

        return result;
    }
    
    /**
	 * @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function replay(target:IAutomationObject, args:Array):Object
    {
        var event:Event = createEvent(target);
        
        var argDescriptors:Array = getArgDescriptors(target);
		
		// set event properties
		for (var argNo:int = 0; argNo < args.length; ++argNo)
			event[argDescriptors[argNo].name] = args[argNo];
        
        var riEvent:AutomationReplayEvent = new AutomationReplayEvent();
		riEvent.automationObject = target;
		riEvent.replayableEvent = event;
        Automation.automationManager.replayAutomatableEvent(riEvent);

        return null;
    }

	/**
	 * @inheritDoc
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
    public function getArgDescriptors(obj:IAutomationObject):Array
    {
        if (!_eventArgASTypesInitialized && obj != null)
        {
            _eventArgASTypesInitialized = true;
            
            var eventClass:Class = 
            		AutomationClass.getDefinitionFromObjectDomain(obj, _eventClassName);
            var dt:XML = describeType(eventClass);
            AutomationClass.fillInASTypesFromProperties(dt, _args);
        }

        return _args;
    }

    /**
     *  Creates an event based on the class and type described in this
     *  descriptor.
     *  
     *  @param Object An object in whose applicationDomain the required event class
     *                exists. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function createEvent(obj:Object):Event
    {
		var eventClass:Class = 
			AutomationClass.getDefinitionFromObjectDomain(obj, _eventClassName);
		
		return (eventClass == KeyboardEvent 
                ? new KeyboardEvent(KeyboardEvent.KEY_DOWN) 
                : (eventClass == FocusEvent && 
                   _eventType == FocusEvent.KEY_FOCUS_CHANGE
                   // this event is not like the other children.  it needs
                   // to be cancelable.  this should be generalized at some point
                   // because other children may need this attention too.
                   ? new eventClass(_eventType, true, true)
                   : new eventClass(_eventType)));
    }
}

}
