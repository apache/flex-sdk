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

package mx.automation.tool
{

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.system.ApplicationDomain;
import flash.utils.describeType;

import mx.automation.Automation;
import mx.automation.AutomationEventDescriptor;
import mx.automation.IAutomationObject;
import mx.automation.events.AutomationReplayEvent;
import mx.core.mx_internal;
import mx.automation.tool.IToolCodecHelper;

use namespace mx_internal;

/**
 * Method descriptor class.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 4
 */
public class ToolEventDescriptor extends AutomationEventDescriptor
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
     *  @productversion Flex 4
     */
    public function ToolEventDescriptor(name:String,
                                               eventClassName:String,
                                               eventType:String,
                                               args:Array)
    {
        super(name, eventClassName, eventType, args);
    }

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
    
    /**
     *  @private
     */
	private var _eventArgASTypesInitialized:Boolean = false;

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
    override public function record(target:IAutomationObject, event:Event):Array
    {
        var args:Array = getArgDescriptors(target);

		var helper:IToolCodecHelper = ToolAdapter.getCodecHelper();
        return helper.encodeProperties(event, args, target);
    }

    /**
     * @private
     */
    override public function replay(target:IAutomationObject, args:Array):Object
    {
	if(!target)
		return null;
 
        var event:Event = createEvent(target);
        var argDescriptors:Array = getArgDescriptors(target);
		var helper:IToolCodecHelper = ToolAdapter.getCodecHelper();
        helper.decodeProperties(event, args, argDescriptors,
							IAutomationObject(target));
							
        var riEvent:AutomationReplayEvent = new AutomationReplayEvent();
		riEvent.automationObject = target;
		riEvent.replayableEvent = event;
        Automation.automationManager.replayAutomatableEvent(riEvent);

        return null;
    }

}

}
