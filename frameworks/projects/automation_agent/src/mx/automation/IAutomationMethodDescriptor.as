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
 *  The IAutomationMethodDescriptor interface defines the interface for a method descriptor.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IAutomationMethodDescriptor
{
    /**
     *  The name of the method.
     *
     *  @return The method name.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get name():String;

    /**
     *  The return type of the method.
     *
     *  @return The return type. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get returnType():String;

    /**
     *  Returns an Array of argument descriptors for this method.
     *  
     *  @param obj Instance of the IAutomationObject that
     *         supports this method.
     *
     *  @return Array of argument descriptors for this method.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getArgDescriptors(obj:IAutomationObject):Array;

    /**
     *  Encodes an automation event arguments into an Array.
     *  Not all method descriptors support recording.
     *
     *  @param event Automation event that is being recorded.
     *
     *  @return Array of argument descriptors.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function record(target:IAutomationObject, event:Event):Array;

    /**
     *  Decodes an argument array and invokes a method.
     *
     *  @param target Automation object to replay the method on.
     * 
     *  @param args Array of argument values and descriptors to
     *         be used to invoke the method.
     *
     *  @return Whatever the method invoked returns.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function replay(target:IAutomationObject, args:Array):Object;
}

}
