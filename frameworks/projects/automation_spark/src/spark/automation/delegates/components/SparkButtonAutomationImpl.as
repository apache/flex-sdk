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
	
	import spark.automation.delegates.components.supportClasses.SparkButtonBaseAutomationImpl;
	import spark.components.Button;
	
	use namespace mx_internal;
	
	[Mixin]
	/**
	 * 
	 *  Defines methods and properties required to perform instrumentation for the 
	 *  Button control.
	 * 
	 *  @see spark.components.Button
	 *
	 */
	public class SparkButtonAutomationImpl extends SparkButtonBaseAutomationImpl 
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
		 */
		public static function init(root:DisplayObject):void
		{
			Automation.registerDelegateClass(spark.components.Button, SparkButtonAutomationImpl);
		}   
		
		/**
		 *  Constructor.
		 * @param obj Button object to be automated.     
		 */
		public function SparkButtonAutomationImpl(obj:spark.components.Button)
		{
			super(obj);
			
		}
		
		
	}
	
}