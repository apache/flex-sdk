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

package mx.automation.codec
{
	
	import mx.automation.qtp.IQTPPropertyDescriptor;
	import mx.automation.IAutomationManager;
	import mx.automation.IAutomationObject;
	
	/**
	 * Translates between internal Flex ScrollEvent detail and automation-friendly version
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class ScrollDetailPropertyCodec extends DefaultPropertyCodec
	{
		/**
		 *  Constructor
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */ 
		public function ScrollDetailPropertyCodec()
		{
			super();
		}
		
		/**
		 *  @private
		 */ 
		override public function encode(automationManager:IAutomationManager,
										obj:Object, 
										pd:IQTPPropertyDescriptor,
										relativeParent:IAutomationObject):Object
		{
			var val:int = 0;
			
			if (!("detail" in obj))
				return val;
			
			switch (obj["detail"])
			{
				//ScrollEvent.detail 
				case "atBottom" : 
					return 1;
				case "atLeft" : 
					return 2;
				case "atRight" : 
					return 3;
				case "atTop" : 
					return 4;
				case "lineDown" : 
					return 5;
				case "lineLeft" : 
					return 6;
				case "lineRight" : 
					return 7;
				case "lineUp" : 
					return 8;
				case "pageDown" : 
					return 9;
				case "pageLeft" : 
					return 10;
				case "pageRight" : 
					return 11;
				case "pageUp" : 
					return 12;
				case "thumbPosition" : 
					return 13;
				case "thumbTrack" : 
					return 14;
			}
			
			return val;
		}
		
		/**
		 *  @private
		 */ 
		override public function decode(automationManager:IAutomationManager,
										obj:Object, 
										value:Object,
										pd:IQTPPropertyDescriptor,
										relativeParent:IAutomationObject):void
		{
			var details:Array = 
				[
					"atBottom", "atLeft", "atRight", "atTop", "lineDown",
					"lineLeft", "lineRight", "lineUp", "pageDown",
					"pageLeft", "pageRight", "pageUp", "thumbPosition",
					"thumbTrack",
				];
			
			if ("detail" in obj && value > 0 && value <= details.length)
				obj["detail"] = details[uint(value)-1];
		}
	}
	
}
