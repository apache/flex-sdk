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
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent; 
	import flash.ui.Keyboard;
	import mx.automation.Automation;
	import mx.controls.ButtonBar;
	import mx.core.mx_internal;
	import mx.core.EventPriority;
	
	use namespace mx_internal;
	
	[Mixin]
	/**
	 * 
	 *  Defines methods and properties required to perform instrumentation for the 
	 *  ButtonBar control.
	 * 
	 *  @see mx.controls.ButtonBar 
	 *
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class ButtonBarAutomationImpl extends NavBarAutomationImpl 
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
			Automation.registerDelegateClass(ButtonBar, ButtonBarAutomationImpl);
		}   
		
		/**
		 *  Constructor.
		 * @param obj ButtonBar object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function ButtonBarAutomationImpl(obj:ButtonBar)
		{
			super(obj);
		}
		
		/**
		 *  @private
		 *  storage for the owner component
		 */
		protected function get buttonBar():ButtonBar
		{
			return uiComponent as ButtonBar;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override public function recordAutomatableEvent(
			event:Event, cacheable:Boolean = false):void
		{
			if (buttonBar.simulatedClickTriggerEvent == null ||
				buttonBar.simulatedClickTriggerEvent is MouseEvent)
			{
				super.recordAutomatableEvent(event, cacheable);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override protected function keyDownHandler(event:KeyboardEvent):void 
		{
			switch (event.keyCode)
			{
				case Keyboard.DOWN:
				case Keyboard.RIGHT:
				case Keyboard.UP:
				case Keyboard.LEFT:
					recordAutomatableEvent(event);
					break;  
			}
		}
		
	}
}
