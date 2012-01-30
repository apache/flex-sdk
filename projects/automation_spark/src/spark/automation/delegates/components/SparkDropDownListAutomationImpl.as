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

package spark.automation.delegates.components
{
	import flash.display.DisplayObject;
	
	import mx.automation.Automation;
	import mx.core.mx_internal;
	
	import spark.automation.delegates.components.supportClasses.SparkDropDownListBaseAutomationImpl;
	import spark.components.DropDownList;
	
	use namespace mx_internal;
	
	[Mixin]
	/**
	 * 
	 *  Defines methods and properties required to perform instrumentation for the 
	 *  DropDownList control.
	 * 
	 *  @see spark.components.DropDownList 
	 *
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	public class SparkDropDownListAutomationImpl extends SparkDropDownListBaseAutomationImpl
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
		 *  @productversion Flex 4
		 */
		public static function init(root:DisplayObject):void
		{
			Automation.registerDelegateClass(spark.components.DropDownList, SparkDropDownListAutomationImpl);
		}   
		
		/**
		 *  Constructor.
		 * @param obj DropDownList object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function SparkDropDownListAutomationImpl(obj:spark.components.DropDownList)
		{
			super(obj);
		}
		
		/**
		 *  @private
		 *  storage for the owner component
		 */
		protected function get sparkDropDownList():spark.components.DropDownList
		{
			return uiComponent as spark.components.DropDownList;
			
		}	
		
	}
}
