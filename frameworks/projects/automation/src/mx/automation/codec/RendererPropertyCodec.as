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
	import mx.automation.Automation;
	import mx.automation.AutomationClass;
	import mx.automation.AutomationIDPart;
	import mx.automation.IAutomationClass;
	import mx.automation.IAutomationManager;
	import mx.automation.IAutomationObject;
	import mx.automation.tool.IToolPropertyDescriptor;
	
	[ResourceBundle("automation_agent")]
	
	/**
	 *  Translates between internal Flex component and automation-friendly version
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class RendererPropertyCodec extends AutomationObjectPropertyCodec
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public function RendererPropertyCodec()
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override public function encode(automationManager:IAutomationManager,
										obj:Object, 
										pd:IToolPropertyDescriptor,
										relativeParent:IAutomationObject):Object
		{
			var val:Object = getMemberFromObject(automationManager, obj, pd);
			
			var delegate:IAutomationObject = val as IAutomationObject;
			if (delegate)
			{
				var part:AutomationIDPart = automationManager.createIDPart(delegate);
				val = part.automationName;
				var automationClass:IAutomationClass;
				if (relativeParent)
					automationClass = automationManager.automationEnvironment.getAutomationClassByInstance(relativeParent);
				if (automationClass)
				{
					var propertyNameMap:Object = automationClass.propertyNameMap;
					if (propertyNameMap["enableIndexBasedSelection"])
						val = part.automationIndex;
				}
			}
			
			if (!val && !(val is int))
				val = "";
			
			return val;
		}
		
		/**
		 * @private
		 */
		override public function decode(automationManager:IAutomationManager,
										obj:Object, 
										value:Object,
										pd:IToolPropertyDescriptor,
										relativeParent:IAutomationObject):void
		{
			if ((!value) || value.length == 0)
			{
				obj[pd.name] = null;
			}
			else
			{
				var aoc:IAutomationObject = 
					(relativeParent != null ? relativeParent : obj as IAutomationObject);
				
				var part:AutomationIDPart = new AutomationIDPart();
				// If we have any descriptive programming element
				// in the value string use that property.
				// If it is a normal string assume it to be automationName
				var text:String = String(value);
				var separatorPos:int = text.indexOf(":=");
				var items:Array = [];
				if(separatorPos != -1)
					items = text.split(":=");
				
				if(items.length == 2)
					part[items[0]] = items[1]; 
				else
					part.automationName = text;
				
				var ao:Array = automationManager.resolveIDPart(aoc, part);
				var n:int = ao.length;
				var delegate:IAutomationObject = (ao[0] as IAutomationObject);
				if (delegate)
					obj[pd.name] = delegate;
				else
					obj[pd.name] = ao[0];
				
				if (n > 1)
				{
					var message:String = resourceManager.getString(
						"automation_agent", "matchesMsg",[ ao.length,
							part.toString().replace(/\n/, ' ')]) + ":\n";
					
					for (var i:int = 0; i < n; i++)
					{
						message += AutomationClass.getClassName(ao[i]) + 
							"(" + ao[i].automationName + ")\n";
					}
					
					Automation.automationDebugTracer.traceMessage("RenderPropertyCodec","decode",message);
				}
				
				// we couldnot find the itemRenderer in the visible area
				// set itemString property if it is available so that the
				// delegate can handle this.
				if (n == 0)
				{
					if (obj.hasOwnProperty("itemAutomationValue"))
						obj["itemAutomationValue"] = text;
				}
			}
		}
	}
	
}
