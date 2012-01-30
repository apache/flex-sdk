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
	 *  The AutomationFlexNativeEvent class represents event objects that are 
	 *  dispatched as part of a flexnativemenu selection operation.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1 
	 *  @productversion Flex 4
	 */
	public class AutomationFlexNativeMenuEvent extends Event
	{
		include "../../core/Version.as";
		
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Defines the value of the 
		 *  <code>type</code> property of the event object for a <code>menuShow</code> event.
		 *
		 *  <p>The properties of the event object have the following values:</p>
		 *  <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
		 *     <tr><td><code>bubbles</code></td><td><code>false</code></td></tr>
		 *     <tr><td><code>cancelable</code></td><td><code>true</code></td></tr>
		 *     <tr><td><code>args</code></td><td>Array of arguments to the method.</td></tr>
		 *  </table>
		 *
		 *  @eventType menuShow
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public static const MENU_SHOW:String = "menuShow";
		
		/**
		 *  Defines the value of the 
		 *  <code>type</code> property of the event object for a <code>itemClick</code> event.
		 *
		 *  <p>The properties of the event object have the following values:</p>
		 *  <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
		 *     <tr><td><code>bubbles</code></td><td><code>false</code></td></tr>
		 *     <tr><td><code>cancelable</code></td><td><code>true</code></td></tr>
		 *     <tr><td><code>args</code></td><td>Array of arguments to the method.</td></tr>
		 *  </table>
		 *
		 *  @eventType itemClick
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public static const ITEM_CLICK:String = "itemClick";
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *  Normally called by the Flex control and not used in application code.
		 *
		 *  @param type The event type; indicates the action that caused the event.
		 *
		 *  @param bubbles Specifies whether the event can bubble up the display list hierarchy.
		 *
		 *  @param cancelable Specifies whether the behavior associated with the event can be prevented.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function AutomationFlexNativeMenuEvent(type:String, bubbles:Boolean = false,
													  cancelable:Boolean = true,
													  args:String = null)
		{
			super(type, bubbles, cancelable);
			
			this.args = args;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  action
		//----------------------------------
		
		/**
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public var args:String;
		
		
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
			var cloneEvent:AutomationFlexNativeMenuEvent = new AutomationFlexNativeMenuEvent(type, bubbles, cancelable);
			
			cloneEvent.args = this.args;
			
			return cloneEvent;
		}
	}
	
}
