package spark.automation.delegates.skins.spark
{
	import flash.display.DisplayObject;
	
	import mx.automation.Automation;
	import mx.automation.delegates.core.UITextFieldAutomationImpl;
	import mx.core.mx_internal;
	
	import spark.skins.spark.UITextFieldGridItemRenderer;
	
	use namespace mx_internal;
	
	[Mixin]
	/**
	 * 
	 *  Defines methods and properties required to perform instrumentation for the 
	 *  UITextFieldGridItemRenderer class for spark.
	 * 
	 *  @see spark.skins.spark.UITextFieldGridItemRenderer
	 *
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	public class SparkUITextFieldGridItemRendererAutomationImpl extends UITextFieldAutomationImpl
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
			Automation.registerDelegateClass(spark.skins.spark.UITextFieldGridItemRenderer, SparkUITextFieldGridItemRendererAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 * @param obj UITextFieldGridItemRenderer object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function SparkUITextFieldGridItemRendererAutomationImpl(obj:UITextFieldGridItemRenderer)
		{
			super(obj);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  storage for the owner component
		 */
		protected function get gridItem():spark.skins.spark.UITextFieldGridItemRenderer
		{
			return uiTextField as spark.skins.spark.UITextFieldGridItemRenderer;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  automationName
		//----------------------------------
		
		/**
		 *  @private
		 */
		override public function get automationName():String
		{
			return gridItem.label|| super.automationName;
		}
		
		//----------------------------------
		//  automationValue
		//----------------------------------
		
		/**
		 *  @private
		 */
		override public function get automationValue():Array
		{
			return [automationName];
		}
	}
}