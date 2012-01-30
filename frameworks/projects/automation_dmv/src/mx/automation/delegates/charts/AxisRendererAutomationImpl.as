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

package mx.automation.delegates.charts 
{
	import flash.display.DisplayObject;
	
	import mx.automation.Automation;
	import mx.automation.AutomationIDPart;
	import mx.automation.tabularData.AxisRendererTabularData;
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationObjectHelper;
	import mx.automation.IAutomationTabularData;
	import mx.automation.delegates.core.UIComponentAutomationImpl;
	import mx.charts.AxisRenderer;
	
	
	
	[Mixin]
	/**
	 * 
	 *  Defines the methods and properties required to perform instrumentation for the 
	 *  AxisRenderer class.
	 * 
	 *  @see mx.charts.AxisRenderer
	 *  
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class AxisRendererAutomationImpl extends UIComponentAutomationImpl 
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
		 *  @productversion Flex 3
		 */
		public static function init(root:DisplayObject):void
		{
			Automation.registerDelegateClass(AxisRenderer, AxisRendererAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *  @param obj AxisRenderer object to be automated. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function AxisRendererAutomationImpl(obj:AxisRenderer)
		{
			super(obj);
			
			axisRenderer = obj;
		}
		
		/**
		 *  @private
		 */
		private var axisRenderer:AxisRenderer;
		
		/**
		 *  @private
		 */
		override public function get automationTabularData():Object
		{
			return new AxisRendererTabularData(uiAutomationObject);
		}
		
	}
	
}
