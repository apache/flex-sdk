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

package mx.automation.delegates.controls 
{
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.automation.Automation;
	import mx.automation.IAutomationManager;
	import mx.automation.IAutomationObject;
	import mx.automation.delegates.core.UIComponentAutomationImpl;
	import mx.controls.alertClasses.AlertForm;
	import mx.controls.Button;
	import mx.core.EventPriority;
	import mx.core.mx_internal;
	import flash.events.Event;
	import mx.automation.IAutomationObject;
	
	use namespace mx_internal;
	
	[Mixin]
	/**
	 * 
	 *  Defines methods and properties required to perform instrumentation for the AlertForm class. 
	 * 
	 *  @see mx.controls.alertClasses.AlertForm
	 *  
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class AlertFormAutomationImpl extends UIComponentAutomationImpl 
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
			Automation.registerDelegateClass(AlertForm, AlertFormAutomationImpl);
		}   
		
		/**
		 *  Constructor.
		 * @param obj AlertForm object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function AlertFormAutomationImpl(obj:AlertForm)
		{
			alertForm = obj;
			super(obj);
		}
		
		private var alertForm:AlertForm;
		
		/**
		 *  Method which gets called after the component has been initialized. 
		 *  This can be used to access any sub-components and act on the component.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		override protected function componentInitialized():void
		{   
			super.componentInitialized();
			for each(var b:Button in alertForm.buttons)
			{
				// we want to record escape key before alertForm closes the alert
				b.addEventListener(KeyboardEvent.KEY_DOWN, alertKeyDownHandler,
					false, EventPriority.DEFAULT+1, true);
			}
		}
		
		
		/**
		 *  @private
		 */
		private function alertKeyDownHandler(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.ESCAPE)
			{
				// we want to record the escape key as invoked from the button.
				var am:IAutomationManager = Automation.automationManager;
				var delegate:IAutomationObject = event.target as IAutomationObject;
				if(am && delegate)
					am.recordAutomatableEvent(delegate, event);
			}
		}
	}
}