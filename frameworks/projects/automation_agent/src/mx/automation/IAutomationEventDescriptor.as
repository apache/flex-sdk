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
import mx.core.mx_internal;
import mx.automation.events.AutomationReplayEvent;

use namespace mx_internal;

/**
 *  The IAutomationEventDescriptor interface defines the interface 
 *  for an event descriptor.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IAutomationEventDescriptor
{
    /**
     *  The name of this event as the agent sees it.
     *  The AutomationManager fills the <code>AutomationRecordEvent.name</code>
     *  property with this name.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get name():String;
     
    /**
     *  The name of the class implementing this event.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get eventClassName():String;
     
    /**
     *  The value of the <code>type</code> property used for this event.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get eventType():String;

    /**
     *  Returns an Array of argument descriptors for this event.
     *  
     *  @param target Instance of the IAutomationObject that
     *  supports this event.
     *
     *  @return Array of argument descriptors for this event.
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getArgDescriptors(target:IAutomationObject):Array;

    /**
     *  Encodes an automation event argument into an Array.
     *
     *  @param target Automation object on which to record the event.
     *
     *  @param event Automation event that is being recorded.
     *
     *  @return Array of property values of the event described by the PropertyDescriptors.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function record(target:IAutomationObject, event:Event):Array;

    /**
     *  Decodes an argument Array and replays the event.
     *
     *  @param target Automation object on which to replay the event.
     * 
     *  @param args Array of argument values to
     *  be used to replay the event.
     *
     *  @return null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function replay(target:IAutomationObject, args:Array):Object;
}

}
