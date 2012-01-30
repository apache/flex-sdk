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
	
	[ResourceBundle("automation_agent")]
	
	/**
	 * Translates between internal Flex date range and automation-friendly version
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class DateRangePropertyCodec extends DefaultPropertyCodec
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */ 
		public function DateRangePropertyCodec()
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */ 
		override public function encode(automationManager:IAutomationManager,
										obj:Object, 
										propertyDescriptor:IQTPPropertyDescriptor,
										relativeParent:IAutomationObject):Object
		{
			var val:Object = getMemberFromObject(automationManager, obj, propertyDescriptor);
			var encodedDate:String = "";
			
			if (val)
			{
				if (val is Date)
				{
					encodedDate = (val as Date).toLocaleDateString();
				}
				else if (val is Object)
				{
					if ("rangeStart" in val)
						encodedDate = (val.rangeStart as Date).toLocaleDateString();
					encodedDate += " => "
					if ("rangeEnd" in val)
						encodedDate += (val.rangeEnd as Date).toLocaleDateString();
				}
			}
			
			return encodedDate;
		}
		
		/**
		 *  @private
		 */ 
		override public function decode(automationManager:IAutomationManager,
										obj:Object, 
										value:Object,
										propertyDescriptor:IQTPPropertyDescriptor,
										relativeParent:IAutomationObject):void
		{
			var message:String = resourceManager.getString(
				"automation_agent", "notSettable");
			throw new Error(message);
		}
	}
	
}
