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

/**
 *  The IAutomationEnvironment interface provides information about the
 *  objects and properties of automatable components needed for communicating
 *  with agents.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IAutomationEnvironment
{

    /**
     *  Returns the automation class corresponding to the given object.
     *
     *  @param obj  Instance of the delegate of a testable object.
     * 
     *  @return Automation class for <code>obj</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getAutomationClassByInstance(obj:IAutomationObject):IAutomationClass;


    /**
     *  Returns the automation class for the given name.
     *
     *  @param Name A class name that corresponds to the value of 
     *  the <code>AutomationClass.name</code> property.
     * 
     *  @return Automation class corresponding to the given name,
     *  or <code>null</code> if none was found.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getAutomationClassByName(automationClass:String):IAutomationClass;
}

}
