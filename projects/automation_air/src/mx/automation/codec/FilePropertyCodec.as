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
	
	import flash.filesystem.File;
	
	import mx.automation.IAutomationManager; 
	import mx.automation.IAutomationObject;
	import mx.automation.qtp.IQTPPropertyDescriptor;
	
	/**
	 * Translates between internal Flex color and automation-friendly version
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class FilePropertyCodec extends DefaultPropertyCodec
	{
		/**
		 * Constructor
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function FilePropertyCodec()
		{
			super();
		}
		
		/**
		 * @private
		 */
		override public function encode(automationManager:IAutomationManager,
										obj:Object, 
										propertyDescriptor:IQTPPropertyDescriptor,
										relativeParent:IAutomationObject):Object
		{
			var val:Object = getMemberFromObject(automationManager, obj, propertyDescriptor);
			
			var encodedFileString:String = "";
			
			if (val != null)
			{
				if (val is File)
				{
					encodedFileString = (val as File).nativePath;
				}
			}
			
			return encodedFileString;
		}
		
		/**
		 * @private
		 */
		override public function decode(automationManager:IAutomationManager,
										obj:Object, 
										value:Object,
										propertyDescriptor:IQTPPropertyDescriptor,
										relativeParent:IAutomationObject):void
		{
			var fileObj:File = new File();
			fileObj = fileObj.resolvePath(value as String);
			obj[propertyDescriptor.name] = fileObj;
		}
	}
	
}
