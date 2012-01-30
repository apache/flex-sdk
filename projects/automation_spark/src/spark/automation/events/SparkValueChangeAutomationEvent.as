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

package spark.automation.events
{
	
	import flash.events.Event;
	
	public class SparkValueChangeAutomationEvent extends Event
	{
		
		include "../../core/Version.as";
		
		
		public static const CHANGE:String = "change";
		
		public function SparkValueChangeAutomationEvent(type:String, bubbles:Boolean = false,
														cancelable:Boolean = false,value:Number= -1)
		{
			super(type, bubbles, cancelable);
			this.value = value;
			
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  change
		//----------------------------------
		
		/**
		 *  Indicates the new value
		 */
		public var value:Number;
		
		
		
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
			return new SparkValueChangeAutomationEvent(type, bubbles, cancelable,value
			);
		}
	}
	
}
