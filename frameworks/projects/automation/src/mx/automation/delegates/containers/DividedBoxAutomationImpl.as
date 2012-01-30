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

package mx.automation.delegates.containers 
{
	import flash.display.DisplayObject;
	import flash.events.Event; 
	
	import mx.automation.Automation;
	import mx.automation.delegates.core.ContainerAutomationImpl;
	import mx.containers.DividedBox;
	import mx.core.mx_internal;
	import mx.events.DividerEvent;
	
	use namespace mx_internal;
	
	[Mixin]
	/**
	 * 
	 *  Defines the methods and properties required to perform instrumentation for the 
	 *  DividedBox class. 
	 * 
	 *  @see mx.containers.DividedBox
	 *  
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class DividedBoxAutomationImpl extends ContainerAutomationImpl 
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
			Automation.registerDelegateClass(DividedBox, DividedBoxAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 * @param obj DividedBox object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function DividedBoxAutomationImpl(obj:DividedBox)
		{
			super(obj);
			
			obj.addEventListener(DividerEvent.DIVIDER_RELEASE, recordAutomatableEvent, false, 0, true);
		}
		
		/**
		 *  @private
		 *  storage for the owner component
		 */
		protected function get dBox():DividedBox
		{
			return uiComponent as DividedBox;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Replay methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Replays <code>DIVIDER_RELEASE</code> events by dispatching 
		 *  a <code>DIVIDER_PRESS</code> event, moving the divider in question,
		 *  and dispatching a <code>DIVIDER_RELEASE</code> event.
		 *  
		 *  @param interaction The event to replay.
		 *  
		 *  @return <code>true</code> if the replay was successful. Otherwise, returns <code>false</code>.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		override public function replayAutomatableEvent(interaction:Event):Boolean
		{
			if (interaction is DividerEvent)
			{
				var dividerInteraction:DividerEvent = DividerEvent(interaction);
				
				// dispatch a pressed event (in case anyone was listening)
				var pressedEvent:DividerEvent = 
					new DividerEvent(DividerEvent.DIVIDER_PRESS);
				pressedEvent.dividerIndex = dividerInteraction.dividerIndex;
				dBox.dispatchEvent(pressedEvent);
				
				// dispatch a dragged event (in case anyone was listening)
				var draggedEvent:DividerEvent = 
					new DividerEvent(DividerEvent.DIVIDER_DRAG);
				draggedEvent.dividerIndex = dividerInteraction.dividerIndex;
				draggedEvent.delta = dividerInteraction.delta / 2;
				dBox.dispatchEvent(draggedEvent);
				
				// move the divider
				dBox.moveDivider(dividerInteraction.dividerIndex,
					dividerInteraction.delta);
				
				dBox.validateNow();
				// dispatch a released event (the same one that was recorded)
				dBox.dispatchEvent(interaction);
				
				return true;
			}
			return super.replayAutomatableEvent(interaction);
		}
		
	}
	
}
