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
	 * Translates between internal Flex keyModifiers and automation-friendly ones.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class KeyModifierPropertyCodec extends DefaultPropertyCodec
	{
		/**
		 *  Constructor
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */ 
		public function KeyModifierPropertyCodec()
		{
			super();
		}
		
		/**
		 *  @private
		 */ 
		override public function encode(automationManager:IAutomationManager,
										obj:Object, 
										pd:IToolPropertyDescriptor,
										relativeParent:IAutomationObject):Object
		{
			var val:int = 0;
			
			if ("ctrlKey" in obj && Boolean(obj["ctrlKey"]))
				val |= (1 << 0);
			
			if ("shiftKey" in obj && Boolean(obj["shiftKey"]))
				val |= (1 << 1);
			
			if ("altKey" in obj && Boolean(obj["altKey"]))
				val |= (1 << 2);
			
			return val;
		}
		
		/**
		 *  @private
		 */ 
		override public function decode(automationManager:IAutomationManager,
										obj:Object, 
										value:Object,
										pd:IToolPropertyDescriptor,
										relativeParent:IAutomationObject):void
		{
			if ("ctrlKey" in obj)
				obj["ctrlKey"] = (uint(value) & (1 << 0)) != 0;
			
			if ("shiftKey" in obj)
				obj["shiftKey"] = (uint(value) & (1 << 1)) != 0;
			
			if ("altKey" in obj)
				obj["altKey"] = (uint(value) & (1 << 2)) != 0;
		}
	}
	
}
