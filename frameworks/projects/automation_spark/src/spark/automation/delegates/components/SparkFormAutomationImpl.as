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
	import flash.events.MouseEvent;
	
	import mx.automation.Automation;
	
	import spark.components.Form;
	
	[Mixin]
	/**
	 * 
	 *  Defines the methods and properties required to perform instrumentation for the 
	 *  Form class. 
	 * 
	 *  @see spark.components.Form
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.5
	 *  @productversion Flex 4.5
	 *  
	 */
	public class SparkFormAutomationImpl extends SparkSkinnableContainerAutomationImpl
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
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public static function init(root:DisplayObject):void
		{
			Automation.registerDelegateClass(spark.components.Form, SparkFormAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *  @param obj Form object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function SparkFormAutomationImpl(obj:spark.components.Form)
		{
			super(obj);
			recordClick = true; 
		}
		
		/**
		 *  @private
		 */
		private function get form():spark.components.Form
		{
			return uiComponent as spark.components.Form;
		}
		
		/**
		 *  @private
		 */
		override protected function clickHandler(event:MouseEvent):void
		{
			if(isEventTargetApplicabale(event))
			{
				//var mouseEvent:MouseEvent = new MouseEvent(MouseEvent.CLICK);
				recordAutomatableEvent(event);
			}
		}
		
		/**
		 *  @private
		 */
		private function isEventTargetApplicabale(event:Event):Boolean
		{
			// we decide to continue with the mouse events when they are 
			// on the same container group  
			
			return (event.target == form.skin || event.target == form.contentGroup);
		}
	}
}