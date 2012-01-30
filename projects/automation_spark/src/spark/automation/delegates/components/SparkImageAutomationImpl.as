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
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	import mx.automation.Automation;
	import mx.automation.IAutomationManager;
	import mx.automation.IAutomationObject;
	import mx.core.EventPriority;
	
	import spark.automation.delegates.components.supportClasses.SparkSkinnableComponentAutomationImpl;
	import spark.components.Image;
	
	[Mixin]
	/**
	 * 
	 *  Defines methods and properties required to perform instrumentation for the 
	 *  Image control.
	 * 
	 *  @see spark.components.Image 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.5
	 *  @productversion Flex 4.5
	 *
	 */
	public class SparkImageAutomationImpl extends SparkSkinnableComponentAutomationImpl
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
			Automation.registerDelegateClass(spark.components.Image, SparkImageAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *  @param obj Image object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function SparkImageAutomationImpl(obj:spark.components.Image)
		{
			super(obj);
			obj.addEventListener(MouseEvent.CLICK, mouseClickHandler, false, EventPriority.DEFAULT + 1);
		}
		
		/**
		 *  @private
		 *  storage for the owner component
		 */
		protected function get image():Image
		{
			return uiComponent as Image;
		}
		
		//----------------------------------
		//  recordClick
		//----------------------------------
		private var _recordClick:Boolean = true;
		
		/**
		 * @private
		 */
		override public function get recordClick():Boolean
		{
			return _recordClick;
		}
		
		/**
		 *  @private
		 */
		override public function set recordClick(val:Boolean):void
		{
			/* we don't want to add/remove the event listeners multiple times
			 We are overriding this property here because we want to
			call our own mouseClickHandler*/
			if (_recordClick != val)
			{
				_recordClick = val;
				if (val)
					image.addEventListener(MouseEvent.CLICK, mouseClickHandler);
				else
					image.removeEventListener(MouseEvent.CLICK, mouseClickHandler);
			}
		}
		
		//----------------------------------
		//  automationName
		//----------------------------------
		
		/**
		 *  @private
		 */
		override public function get automationName():String
		{
			if (image.source is String)
				return String(image.source);
			if (image.source is URLRequest)
				return URLRequest(image.source).url;
			
			return super.automationName;
		}
		
		//----------------------------------
		//  automationValue
		//----------------------------------
		
		/**
		 *  @private
		 */
		override public function get automationValue():Array
		{
			if (image.source is String)
				return [ String(image.source) ];
			
			if (image.source is URLRequest)
				return [ URLRequest(image.source).url ];
			
			return null;
		}
		
		/**
		 *  @private
		 */
		 /* We are using our own handler to take care of computing correct automation object. 
		    Otherwise event's target is ImageSkin. We want that to be Image. So we should
		    use target's hostComponent.*/
		private function mouseClickHandler(event:MouseEvent):void
		{
			var am:IAutomationManager = Automation.automationManager;
			if (recordClick && am && am.recording)
			{
				var ao:IAutomationObject = null;
				var o:Object = event.target.hostComponent;
				while (o)
				{
					ao = o as IAutomationObject;
					if (ao)
						break;
					o = o.parent;
				}
				if (ao == uiComponent)
					recordAutomatableEvent(event, false);
			}
		}		
	}
}