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

package mx.automation.events
{
	import flash.events.Event; 
	
	/**
	 *  The AutomationAirEvent class represents event objects that are dispatched 
	 *  by the AutomationManager. The event is dispatched to indicate the creation
	 *  of a new window in AIR. Too libraries can listen to this, communicate the 
	 *  same to the parent and do the needfult to get the handle of the window
	 *  and associate the same with the id of the window passed.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	public class AutomationAirEvent extends Event
	{
		include "../../core/Version.as";
		
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		
		public static const NEW_AIR_WINDOW:String = "newAirWindow";
		
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *
		 *  @param type The event type; indicates the action that caused the event.
		 *
		 *  @param bubbles Whether the event can bubble up the display list hierarchy.
		 *
		 *  @param cancelable Whether the behavior associated with the event can be prevented.
		 * 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function AutomationAirEvent(type:String = NEW_AIR_WINDOW, 
										   bubbles:Boolean = true,
										   cancelable:Boolean = true,
										   windowId:String = null )
		{
			super(type, bubbles, cancelable);
			this.windowId = windowId;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		public var windowId:String;
		//--------------------------------------------------------------------------
		//
		//  Overridden methods: Event
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override public function clone():Event
		{
			return new AutomationAirEvent(type, bubbles, cancelable,windowId);
		}
	}
	
}
