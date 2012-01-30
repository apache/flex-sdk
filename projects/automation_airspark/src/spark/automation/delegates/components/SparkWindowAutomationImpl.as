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

package spark.automation.delegates.components
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.automation.Automation;
	import mx.automation.IAutomationManager2;
	import mx.automation.IAutomationObject;
	
	import spark.components.Window;
	
	
	[Mixin]
	/**
	 * 
	 *  Defines the methods and properties required to perform instrumentation for the 
	 *  Canvas class. 
	 * 
	 *  @see mx.containers.Canvas
	 *  
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	public class SparkWindowAutomationImpl extends SparkSkinnableContainerAutomationImpl
	{
		
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
		 *  @productversion Flex 4
		 */
		public static function init(root:DisplayObject):void
		{
			Automation.registerDelegateClass(spark.components.Window, SparkWindowAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 * @param obj Canvas object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function SparkWindowAutomationImpl(obj:spark.components.Window)
		{
			super(obj);
			obj.showInAutomationHierarchy = true;
			if (obj.menu) // a menu already exists for this window
				menuChangeHandler(null);
			
			obj.addEventListener("menuChanged", menuChangeHandler);
			recordClick = true;
		}
		
		
		/**
		 *  @private
		 */
		public function get window():spark.components.Window
		{
			return  uiComponent as spark.components.Window;
		}
		/**
		 *  @private
		 */
		override public function get automationName():String
		{
			var am:IAutomationManager2 = Automation.automationManager2;
			return am.getAIRWindowUniqueID(window);
		}
		
		/**
		 * @private
		 */ 
		override public function get numAutomationChildren():int
		{    	
			//FlexNativeMenu can also be child of Window. 
			//So this is added if it exists. We are doing this only for Window and
			//WindowedApplication because at present we receive menuChanged
			//event only on these 2 controls if a FlexNativeMenu is there	
			var count:int = super.numAutomationChildren;
			if (window.menu)
				return(count + 1);
			else
				return count;
		}
		
		
		override public function getAutomationChildAt(index:int):IAutomationObject
		{
			//FlexNativeMenu can also be child of Window. 
			//So if it exists, it is considered to be the first child.
			// We are doing this only for Window and
			//WindowedApplication because at present we receive menuChanged
			//event only on these 2 controls if a FlexNativeMenu is there	
			if (window.menu)
			{
				if (index == 0)
					return window.menu as IAutomationObject;
				index = index - 1;
			}
			return super.getAutomationChildAt(index);
		}
		
		/**
		 * @private
		 */
		override public function getAutomationChildren():Array
		{
			var childList:Array = new Array();
			
			// add the menu as the first element
			if (window.menu )
				childList.push(window.menu as IAutomationObject);
			
			var tempList:Array = super.getAutomationChildren();
			if (tempList)
			{
				var n:int = tempList.length;
				for (var i:int = 0; i < n; i++)
				{
					childList.push(tempList[i] as IAutomationObject);
				}
			}
			
			return childList;
		}
		
		//--------------------------------------------------------------------------------
		//
		// Methods
		//
		//--------------------------------------------------------------------------------
		/**
		 * @private
		 */
		private function menuChangeHandler(event:Event):void
		{
			Automation.automationManager2.registerNewFlexNativeMenu(window.menu, window.systemManager as DisplayObject);
			
		}  
		
	}
	
}