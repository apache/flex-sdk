
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
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	public class EventDetails
	{
		public var eventType:String;
		public var handlerFunction:Function;
		public var useCapture:Boolean;
		public var priority:int;
		public var useWeekRef:Boolean;
		
		public function EventDetails(type:String, handler:Function,
									 useCapture:Boolean= false,
									 priority:int = 0, useWeekReferance:Boolean= false )
		{
			this.eventType = type;
			this.handlerFunction = handler;
			this.useCapture = useCapture;
			this.priority = priority;
			this.useWeekRef = useWeekReferance;
		}
		
	}
}