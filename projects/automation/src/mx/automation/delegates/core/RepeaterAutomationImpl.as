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
package mx.automation.delegates.core 
{
	import flash.display.DisplayObject;
	
	import mx.automation.Automation;
	import mx.automation.AutomationIDPart; 
	import mx.automation.tabularData.ContainerTabularData;
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationObjectHelper;
	import mx.automation.delegates.core.UIComponentAutomationImpl;
	import mx.core.mx_internal;
	import mx.core.Repeater;
	
	use namespace mx_internal;
	
	[Mixin]
	/**
	 * 
	 *  Defines the methods and properties required to perform instrumentation for the 
	 *  Repeater class. 
	 * 
	 *  @see mx.core.Repeater
	 *  
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class RepeaterAutomationImpl extends UIComponentAutomationImpl 
	{
		include "../../../core/Version.as";
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Registers the delegate class for a component class with automation manager.
		 *  
		 *  @param root The SystemManger of the application.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public static function init(root:DisplayObject):void
		{
			Automation.registerDelegateClass(Repeater, RepeaterAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 * @param obj Repeater object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function RepeaterAutomationImpl(obj:Repeater)
		{
			super(obj);
		}
		
		/**
		 *  @private
		 *  storage for the owner component
		 */
		protected function get repeater():Repeater
		{
			return uiComponent as Repeater;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  automationValue
		//----------------------------------
		
		/**
		 *  @private
		 */
		override public function get automationValue():Array
		{
			var result:Array = [];
			
			var components:Array = repeater.createdComponents;
			if (components)
			{
				var n:int = components.length;
				for (var i:int = 0; i < n; i++)
				{
					var delegate:IAutomationObject =
						(components[i] as IAutomationObject);
					if (delegate)
						result.push(delegate.automationValue);
				}
			}
			return result;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  itemAutomationNameFunction
		//----------------------------------
		
		[Bindable]
		
		/**
		 *  @private
		 */
		mx_internal var itemAutomationNameFunction:Function = getItemAutomationValue;
		
		
		/**
		 *  @private
		 */
		public function getItemAutomationValue(item:IAutomationObject):String
		{
			return getItemAutomationNameOrValueHelper(item, false);
		}
		
		/**
		 *  @private
		 */
		public function getItemAutomationName(item:IAutomationObject):String
		{
			return getItemAutomationNameOrValueHelper(item, true);
		}
		
		/**
		 *  @private
		 */
		private function getItemAutomationNameOrValueHelper(item:IAutomationObject,
															useName:Boolean):String
		{
			var components:Array = repeater.createdComponents;
			// Find this component's 'row'.
			var n:int = components.length;
			for (var i:int = 0; i < n; i++)
			{
				if (components[i] == item)
					break;
			}
			
			var row:int = i / repeater.childDescriptors.length;
			var result:Array = [];
			
			var s:String = (useName
				? item.automationName
				: item.automationValue.join(" | "));
			
			var beginIndex:int = row * repeater.childDescriptors.length;
			var endIndex:int = beginIndex + repeater.childDescriptors.length;
			for (var col:int = beginIndex; col < endIndex; ++col)
			{
				result.push(col == i && repeater.childDescriptors.length > 1
					? "*" + s + "*"
					: s);
			}
			return result.join(" | ");
		}
		
		/**
		 *  @private
		 */
		public function getItemAutomationIndex(item:IAutomationObject):String
		{
			var components:Array = repeater.createdComponents;
			//find this component's 'row'
			var n:int = components.length;
			for (var i:int = 0; i < n; i++)
			{
				if (components[i] == item)
					return ("index:" + i.toString());
			}
			return "index:-1";
		}
		
		/**
		 *  @private
		 */
		override public function createAutomationIDPart(child:IAutomationObject):Object
		{ 
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			return help.helpCreateIDPart(uiAutomationObject, child, itemAutomationNameFunction, 
				getItemAutomationIndex);
		}
		
		/**
		 *  @private
		 */
		override public function createAutomationIDPartWithRequiredProperties(child:IAutomationObject, properties:Array):Object
		{
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			return help.helpCreateIDPartWithRequiredProperties(uiAutomationObject, child,properties,itemAutomationNameFunction, 
				getItemAutomationIndex);
		}
		
		
		/**
		 *  @private
		 */
		override public function resolveAutomationIDPart(criteria:Object):Array
		{
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			return help.helpResolveIDPart(uiAutomationObject, criteria);
		}
		
		//----------------------------------
		//  numAutomationChildren
		//----------------------------------
		
		/**
		 *  @private
		 */
		override public function get numAutomationChildren():int
		{
			var components:Array = repeater.createdComponents;
			return components ? components.length : 0;
		}
		
		/**
		 *  @private
		 */
		override public function getAutomationChildAt(index:int):IAutomationObject
		{
			var o:Object = repeater.createdComponents[index];
			return o as IAutomationObject;
		}
		
		
		
		/**
		 * @private
		 */
		override public function getAutomationChildren():Array
		{
			return repeater.createdComponents;
		}
		
		//----------------------------------
		//  automationTabularData
		//----------------------------------
		
		/**
		 *  An array of all components within this repeater
		 *  found in the automation hierarchy.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		override public function get automationTabularData():Object
		{
			return new ContainerTabularData(uiAutomationObject);
		}
		
	}
	
}
