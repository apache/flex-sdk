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
	import mx.automation.Automation;
	import mx.automation.IAutomationManager;
	import mx.automation.IAutomationObject;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	import mx.styles.IStyleClient;
	
	[ResourceBundle("automation_agent")]
	
	/**
	 * Base class for codecs, which translate between internal Flex properties 
	 * and automation-friendly ones.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class DefaultPropertyCodec implements IAutomationPropertyCodec
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public function DefaultPropertyCodec()
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		protected var resourceManager:IResourceManager =
			ResourceManager.getInstance();
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */ 
		public function encode(automationManager:IAutomationManager,
							   obj:Object, 
							   pd:IToolPropertyDescriptor,
							   relativeParent:IAutomationObject):Object
		{
			var val:Object = getMemberFromObject(automationManager, obj, pd);
			
			//QTP can't handle NaN although COM can
			//If other testing tools want NaN, then we should extract this to a different codec
			//specific to QTP
			//if (val is Number && isNaN(Number(val)))
			//	return null;
			
			return getValue(automationManager, obj, val, pd);
		}
		
		/**
		 *  @private
		 */ 
		public function decode(automationManager:IAutomationManager,
							   obj:Object, 
							   value:Object,
							   pd:IToolPropertyDescriptor,
							   relativeParent:IAutomationObject):void
		{
			obj[pd.name] = getValue(automationManager, obj, value, pd, true);
		}
		
		/**
		 *  @private
		 */ 
		public function getMemberFromObject(automationManager:IAutomationManager,
											obj:Object, 
											pd:IToolPropertyDescriptor):Object
		{
			var part:Object;
			var component:Object;
			
			if (obj is IAutomationObject)
			{
				part = automationManager.createIDPart(obj as IAutomationObject);
				component = obj;
			}   
			else
			{
				component = obj;
			}
			
			var result:Object = null;
			
			if (part  && pd.name in part)
			{
				result = part[pd.name];
			}
			else if (pd.name in obj)
			{
				result = obj[pd.name];
			}
			else if (component != null)
			{
				if (pd.name in component)
					result = component[pd.name];
				else if (component is IStyleClient)
					result = IStyleClient(component).getStyle(pd.name);
			}
			
			return result;
		}
		
		/**
		 *  @private
		 */ 
		private function getValue(automationManager:IAutomationManager,
								  obj:Object, 
								  val:Object,
								  pd:IToolPropertyDescriptor,
								  useASType:Boolean = false):Object
		{
			if (val == null)
				return null;
			
			var type:String = useASType && pd.asType ? pd.asType : pd.Tooltype;
			
			switch (type)
			{
				case "Boolean":
				case "boolean":
				{
					if (val is Boolean)
						return val;
					val = val ? val.toString().toLowerCase() : "false";
					return val == "true";
				}
				case "String":
				case "string":
				{
					if (val is String)
						return val;
					return val.toString();
				}
				case "int":
				case "uint":
				case "integer":
				{
					
					if (val is int || val is uint)
						return val;
					if (val is Date)
						return val.time;
					if (val is Number)
					{
						var message:String = resourceManager.getString(
							"automation_agent", "precisionLoss", [pd.name]);
						throw new Error(message);
					}
					return parseInt(val.toString());
				}
				case "Number":
				case "decimal":
				{
					if (val is Number)
						return val;
					if (val is Date)
						return val.time;
					return parseFloat(val.toString());
				}
				case "Date":
				case "date":
				{
					if (val is Date)
						return val;
					var num:Number = Date.parse(val.toString());
					return new Date(num);
				}
				default:
				{
					return val;
				}
			}
		}
	}
	
}
