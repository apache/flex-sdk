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

/**
 * The IAutomationClass interface defines the interface for a component class descriptor.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IAutomationClass
{

    //----------------------------------
    //  name
    //----------------------------------
    /**
     * The class name.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get name():String;

    //----------------------------------
    //  superClassName
    //----------------------------------

    /**
     * The name of the class's superclass.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get superClassName():String;
 
    /**
     * Returns the list of properties this class supports.
     *
     *  @param objForInitialization Object which can be used to find the 
     *  ActionScript type of the properties.
     *
     *  @param forVerification If <code>true</code>, indicates that properties used 
     *  for verification should be included in the return value. 
     *
     *  @param forDescription If <code>true</code>, indicates that properties used 
     *  for object identitication should be included in the return value. 
     *
     *  @return Array containing property descriptions.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getPropertyDescriptors(objForInitialization:Object = null,
                                           forVerification:Boolean = true,
                                           forDescription:Boolean = true):Array;
    
    /**
     *  Returns an <code>IAutomationEventDescriptor</code> object 
     *  for the specified event object.
     *
     * @param event The event for which the descriptor is required.
     * 
     * @param The event descriptor for the event passed if one is available.
     * Otherwise null.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getDescriptorForEvent(
                        event:Event):IAutomationEventDescriptor;

     /**
      *  Returns an <code>IAutomationMethodDescriptorfrom</code> object
      *  from the method's name.
      *
      *  @param methodName The method name for which the descriptor is required.
      *
      *  @return The method descriptor for the name passed if one is available. 
      *          Otherwise, null.
      *  
      *  @langversion 3.0
      *  @playerversion Flash 9
      *  @playerversion AIR 1.1
      *  @productversion Flex 3
      */
    function getDescriptorForMethodByName(
                        methodName:String):IAutomationMethodDescriptor;

     /**
      *  Returns an <code>IAutomationEventDescriptor</code> object from the event's name.
      *
      *  @param eventName The event name for which the descriptor is required.
      *
      *  @return The event descriptor for the name passed if one is available. 
      *          Otherwise null.
      *  
      *  @langversion 3.0
      *  @playerversion Flash 9
      *  @playerversion AIR 1.1
      *  @productversion Flex 3
      */
    function getDescriptorForEventByName(
                        eventName:String):IAutomationEventDescriptor;

    /**
     * An Object containing a map to map a property name to descriptor.
     * The following example uses this property:
     *
     * <pre>var descriptor:IAutomationPropertyDescriptor = map[propertyNameMap];</pre> 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get propertyNameMap():Object;

}

}
