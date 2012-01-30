////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
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
