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
	
	[ResourceBundle("automation_agent")]
	
	/**
	 * translates between internal Flex asset and automation-friendly version
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class AssetPropertyCodec extends DefaultPropertyCodec
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public function AssetPropertyCodec()
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		override public function encode(automationManager:IAutomationManager,
										obj:Object, 
										pd:IToolPropertyDescriptor,
										relativeParent:IAutomationObject):Object
		{
			var val:Object = getMemberFromObject(automationManager, obj, pd);
			
			if (val != null)
			{
				val = val.toString();
				
				val = stripNoiseFromString("css_", String(val));
				val = stripNoiseFromString("embed_mxml_", String(val));
				val = stripNoiseFromString("embed_as_", String(val));
			}
			
			return val;
		}
		
		protected function stripNoiseFromString(beginPart:String, asset:String):String
		{
			var pos:int = asset.indexOf(beginPart);
			
			if (pos != -1)
			{
				asset = asset.substr(pos + beginPart.length);
				
				var lastUnderscorePos:int = asset.lastIndexOf("_");
				
				if (lastUnderscorePos != -1)
				{
					asset = asset.substr(0, lastUnderscorePos);
				}
			}
			
			return asset;
		}
		
		override public function decode(automationManager:IAutomationManager,
										obj:Object, 
										value:Object,
										pd:IToolPropertyDescriptor,
										relativeParent:IAutomationObject):void
		{
			var message:String = resourceManager.getString(
				"automation_agent", "notSettable");
			throw new Error(message);
		}
	}
	
}
