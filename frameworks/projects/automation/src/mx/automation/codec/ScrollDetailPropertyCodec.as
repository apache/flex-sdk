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
	 * Translates between internal Flex ScrollEvent detail and automation-friendly version
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class ScrollDetailPropertyCodec extends DefaultPropertyCodec
	{
		/**
		 *  Constructor
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */ 
		public function ScrollDetailPropertyCodec()
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
			
			if (!("detail" in obj))
				return val;
			
			switch (obj["detail"])
			{
				//ScrollEvent.detail 
				case "atBottom" : 
					return 1;
				case "atLeft" : 
					return 2;
				case "atRight" : 
					return 3;
				case "atTop" : 
					return 4;
				case "lineDown" : 
					return 5;
				case "lineLeft" : 
					return 6;
				case "lineRight" : 
					return 7;
				case "lineUp" : 
					return 8;
				case "pageDown" : 
					return 9;
				case "pageLeft" : 
					return 10;
				case "pageRight" : 
					return 11;
				case "pageUp" : 
					return 12;
				case "thumbPosition" : 
					return 13;
				case "thumbTrack" : 
					return 14;
			}
			
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
			var details:Array = 
				[
					"atBottom", "atLeft", "atRight", "atTop", "lineDown",
					"lineLeft", "lineRight", "lineUp", "pageDown",
					"pageLeft", "pageRight", "pageUp", "thumbPosition",
					"thumbTrack",
				];
			
			if ("detail" in obj && value > 0 && value <= details.length)
				obj["detail"] = details[uint(value)-1];
		}
	}
	
}
