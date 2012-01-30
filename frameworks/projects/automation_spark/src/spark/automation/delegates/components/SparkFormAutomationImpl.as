////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.automation.delegates.components
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.automation.Automation;
	
	import spark.components.Form;
	
	[Mixin]
	/**
	 * 
	 *  Defines the methods and properties required to perform instrumentation for the 
	 *  Form class. 
	 * 
	 *  @see spark.components.Form
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.5
	 *  @productversion Flex 4.5
	 *  
	 */
	public class SparkFormAutomationImpl extends SparkSkinnableContainerAutomationImpl
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
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public static function init(root:DisplayObject):void
		{
			Automation.registerDelegateClass(spark.components.Form, SparkFormAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *  @param obj Form object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function SparkFormAutomationImpl(obj:spark.components.Form)
		{
			super(obj);
			recordClick = true; 
		}
		
		/**
		 *  @private
		 */
		private function get form():spark.components.Form
		{
			return uiComponent as spark.components.Form;
		}
		
		/**
		 *  @private
		 */
		override protected function clickHandler(event:MouseEvent):void
		{
			if(isEventTargetApplicabale(event))
			{
				//var mouseEvent:MouseEvent = new MouseEvent(MouseEvent.CLICK);
				recordAutomatableEvent(event);
			}
		}
		
		/**
		 *  @private
		 */
		private function isEventTargetApplicabale(event:Event):Boolean
		{
			// we decide to continue with the mouse events when they are 
			// on the same container group  
			
			return (event.target == form.skin || event.target == form.contentGroup);
		}
	}
}