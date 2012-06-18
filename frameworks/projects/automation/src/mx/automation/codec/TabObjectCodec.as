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
	
	import mx.automation.AutomationIDPart;
	import mx.automation.Automation;
	import mx.automation.tool.IToolPropertyDescriptor;
	import mx.automation.IAutomationManager;
	import mx.automation.IAutomationObject;
	import mx.automation.codec.AutomationObjectPropertyCodec;
	import mx.containers.TabNavigator; 
	import mx.core.mx_internal;
	import mx.automation.AutomationManager;
	
	use namespace mx_internal;
	
	/**
	 * Translates between internal Flex TabNavigator object and automation-friendly version
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class TabObjectCodec extends AutomationObjectPropertyCodec
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public function TabObjectCodec()
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		
		/**
		 *  This is only used for TabNavigators.  
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */	
		override public function decode(automationManager:IAutomationManager,
										obj:Object, 
										value:Object,
										pd:IToolPropertyDescriptor,
										relativeParent:IAutomationObject):void
		{
			
			if (value == null || value.length == 0)
			{
				obj[pd.name] = null;
			}
			else
			{
				var aoc:IAutomationObject;
				if (relativeParent != null)
				{
					var tabBar:Object = Object(relativeParent).getTabBar();
					aoc = tabBar as IAutomationObject;
				}
				else
				{
					aoc = obj as IAutomationObject;
				}
				
				/*
				for (var i:uint = 0; i < aoc.numAutomationChildren; i++)
				{
				var delegate:IAutomationObject = aoc.getAutomationChildAt(i);
				if (delegate.automationName == value)
				{
				obj[pd.name] = delegate;
				break;
				}
				}
				*/
				
				// we need to replace the above code to replace the getAutomationChildAt
				// and numAutomationChildren with getAutomationChildren to avoid the
				// multiple calcuation of the children.
				var childList:Array = aoc.getAutomationChildren();
				if(childList)
				{
					var n:int  = childList.length;
					for (var i:uint = 0; i < n; i++)
					{
						var delegate:IAutomationObject = childList[i];
						if (delegate.automationName == value)
						{
							obj[pd.name] = delegate;
							break;
						}
					}
				}
			}
		}
	}
	
}
