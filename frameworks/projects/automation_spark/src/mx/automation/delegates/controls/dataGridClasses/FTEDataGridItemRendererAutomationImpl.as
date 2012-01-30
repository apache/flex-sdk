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

package mx.automation.delegates.controls.dataGridClasses
{
	import flash.display.DisplayObject;
	
	import mx.automation.Automation;
	import mx.automation.delegates.core.UIFTETextFieldAutomationImpl;
	import mx.controls.dataGridClasses.FTEDataGridItemRenderer;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	
	[Mixin]
	/**
	 * 
	 *  Defines methods and properties required to perform instrumentation for the 
	 *  FTEDataGridItemRenderer class.
	 * 
	 *  @see mx.controls.dataGridClasses.FTEDataGridItemRenderer 
	 *
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	public class FTEDataGridItemRendererAutomationImpl extends UIFTETextFieldAutomationImpl
	{
		
		include "../../../../core/Version.as";
		
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
			Automation.registerDelegateClass(FTEDataGridItemRenderer, FTEDataGridItemRendererAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 * @param obj FTEDataGridItemRenderer object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function FTEDataGridItemRendererAutomationImpl(obj:FTEDataGridItemRenderer)
		{
			super(obj);
		}
		
		/**
		 *  @private
		 */
		protected function get itemRenderer():FTEDataGridItemRenderer
		{
			return uiFTETextField as FTEDataGridItemRenderer;
		}
	}
}