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
	import flash.ui.Keyboard;
	
	import mx.automation.Automation;
	import mx.automation.AutomationIDPart;
	import mx.automation.IAutomationObjectHelper;
	import mx.controls.RadioButton;
	import mx.core.EventPriority;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	
	[Mixin]
	/**
	 * 
	 *  Defines methods and properties required to perform instrumentation for the 
	 *  RadioButton control.
	 * 
	 *  @see mx.controls.RadioButton 
	 *
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class RadioButtonAutomationImpl extends ButtonAutomationImpl 
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
			Automation.registerDelegateClass(RadioButton, RadioButtonAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 * @param obj RadioButton object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function RadioButtonAutomationImpl(obj:RadioButton)
		{
			super(obj);
		}
		
		/**
		 *  @private
		 *  storage for the owner component
		 */
		protected function get radioButton():RadioButton
		{
			return uiComponent as RadioButton;
		}
		
		/**
		 *  @private
		 *  Replays click interactions on the button.
		 *  If the interaction was from the mouse,
		 *  dispatches MOUSE_DOWN, MOUSE_UP, and CLICK.
		 *  If interaction was from the keyboard,
		 *  dispatches KEY_DOWN, KEY_UP.
		 *  Button's KEY_UP handler then dispatches CLICK.
		 *
		 *  @param event ReplayableClickEvent to replay.
		 */
		override public function replayAutomatableEvent(event:Event):Boolean
		{
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			
			if (event is KeyboardEvent)
				return help.replayKeyboardEvent(uiComponent, KeyboardEvent(event));
			else
				return super.replayAutomatableEvent(event);
		}
		
		/**
		 *  @private
		 *  Support the use of keyboard within the group.
		 */
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			switch (event.keyCode)
			{
				case Keyboard.DOWN:
				case Keyboard.UP:
				case Keyboard.LEFT:
				case Keyboard.RIGHT:
					//for form defaults:
				case Keyboard.ENTER:
					recordAutomatableEvent(event);
					break;
			}
		}
		
	}
}