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

package mx.automation.codec 
{
	
	import mx.automation.tool.IToolPropertyDescriptor; 
	import mx.automation.IAutomationManager;
	import mx.automation.IAutomationObject;
	
	/**
	 * Defines the interface for codecs, which translate between internal Flex properties 
	 * and automation-friendly ones.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public interface IAutomationPropertyCodec
	{
		/**
		 * Encodes the value into a form readable by the user.
		 * 
		 * @param automationManager The automationManager object
		 * 
		 * @param obj The object having the property which requires encoding.
		 * 
		 * @param propertyDescriptor The property descriptor object describing the 
		 * 							 property which needs to be encoded.
		 * 
		 * @param relativeParent The parent or automationParent of the component
		 * 					    recording the event.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		function encode(automationManager:IAutomationManager,
						obj:Object, 
						propertyDescriptor:IToolPropertyDescriptor,
						relativeParent:IAutomationObject):Object;
		
		/**
		 * Decodes the value into a form required for the framework to do operations.
		 *  This may involve searching for some data in the dataProvider or a particualr
		 *  child of the container.
		 * 
		 * @param automationManager The automationManager object
		 * 
		 * @param obj The object having the property which needs to be 
		 * 						updated with the new value.
		 * 
		 * @param value The input value for the decoding process.
		 * 
		 * @param propertyDescriptor The property descriptor object describing the 
		 * 							 property which needs to be decoded.
		 * 
		 * @param relativeParent The parent or automationParent of the component
		 * 					    recording the event.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		function decode(automationManager:IAutomationManager,
						obj:Object, 
						value:Object,
						propertyDescriptor:IToolPropertyDescriptor,
						relativeParent:IAutomationObject):void;
		
	}
	
}
