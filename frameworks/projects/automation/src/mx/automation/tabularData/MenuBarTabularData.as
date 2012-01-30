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
package mx.automation.tabularData
{
	
	import mx.automation.AutomationManager;
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationTabularData;
	import mx.controls.MenuBar;
	import mx.core.mx_internal;
	import mx.automation.Automation;
	
	use namespace mx_internal;
	
	/**
	 *  @private
	 */
	public class MenuBarTabularData
		implements IAutomationTabularData
	{
		
		private var menuBar:MenuBar;
		private var delegate:IAutomationObject;
		
		/**
		 *  @private
		 */
		public function MenuBarTabularData(delegate:IAutomationObject)
		{
			super();
			
			this.delegate = delegate;
			this.menuBar = delegate as MenuBar;
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get firstVisibleRow():int
		{
			return 0;
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get lastVisibleRow():int
		{
			return delegate.numAutomationChildren-1;
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get numRows():int
		{
			return delegate.numAutomationChildren;
		}
		
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get numColumns():int
		{
			return 1;
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get columnNames():Array
		{
			return ["MenuItems"];
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function getValues(start:uint = 0, end:uint = 0):Array
		{
			var _values:Array = [];
			var i:int;
			
			// code modified to avoid the usage of numAutomationChildren and 
			// getAutomationChildAt in a loop
			var childList:Array  = delegate.getAutomationChildren();
			if (childList)
			{
				end  = end > childList.length ? childList.length : end;
				
				for (i = start; i <= end; ++i)
				{
					//var values:Array = delegate.getAutomationChildAt(i).automationValue;
					var values:Array = childList[i]?childList[i].automationValue:null;
					if (values)
						_values.push([ values.join("|") ]);
				}
				
			}
			return _values;
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function getAutomationValueForData(data:Object):Array
		{
			return [];
		}
	}
}
