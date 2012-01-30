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
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.automation.Automation;
	import mx.automation.IAutomationObjectHelper;
	import mx.automation.delegates.core.UIComponentAutomationImpl;
	import mx.core.EventPriority;
	import mx.core.mx_internal;
	
	import spark.automation.delegates.SparkRichEditableTextAutomationHelper;
	import spark.automation.tabularData.RichEditableTextTabularData;
	import spark.components.RichEditableText;
	
	use namespace mx_internal;
	
	[ResourceBundle("automation")]
	[Mixin]
	/** 
	 * Utility class that facilitates replay of text input and selection.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	public class SparkRichEditableTextAutomationImpl extends  UIComponentAutomationImpl
	{
		include "../../../core/Version.as";
		
		/**
		 *  Registers the delegate class for a component class with automation manager.
		 *  
		 *  @param root DisplayObject object representing the application root. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public static function init(root:DisplayObject):void
		{
			Automation.registerDelegateClass(spark.components.RichEditableText, SparkRichEditableTextAutomationImpl);
		}  
		
		//--------------------------------------------------------------------------
		//
		//  Constructors
		//
		//--------------------------------------------------------------------------
		/**
		 *  @private
		 */
		public function SparkRichEditableTextAutomationImpl(obj:spark.components.RichEditableText)
		{
			super(obj);
			obj.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler,
				false, EventPriority.DEFAULT+1, true );
		}
		
		/**
		 *  @private
		 */
		private function mouseWheelHandler(event:MouseEvent):void
		{
			if( isEventTargetApplicabale(event)  )
				recordAutomatableEvent(event, true);
		}
		/**
		 *  @private
		 */
		private function isEventTargetApplicabale(event:Event):Boolean
		{		
			return (event.target == richEditableText);
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
		protected function get  richEditableText():spark.components.RichEditableText
		{
			return uiComponent as spark.components.RichEditableText;
		}
		
		/**
		 *  @private
		 *  Generic record/replay logic for textfields.
		 */
		private var automationHelper:SparkRichEditableTextAutomationHelper;
		
		//--------------------------------------------------------------------------
		//
		//  Overridden properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  automationValue
		//----------------------------------
		
		/**
		 *  @private
		 */
		override public function get automationValue():Array
		{
			return [ automationName];
		}
		
		
		/**
		 *  @private
		 */
		override public function get automationName():String
		{
			return richEditableText.id || super.automationName ;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override public function replayAutomatableEvent(interaction:Event):Boolean
		{
			
			if (interaction is MouseEvent && interaction.type == MouseEvent.MOUSE_WHEEL)
			{
				// the mouse whell happens on the content group
				var help:IAutomationObjectHelper = Automation.automationObjectHelper;
				help.replayMouseEvent(richEditableText, interaction as MouseEvent);
				return true;
			}
			else
			{
				return ((automationHelper &&
					automationHelper.replayAutomatableEvent(interaction)) ||
					super.replayAutomatableEvent(interaction));
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Method which gets called after the component has been initialized. 
		 *  This can be used to access any sub-components and act on the component.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		override protected function componentInitialized():void
		{
			//we create the helper which does the event handling
			// actually for Gumbo  the helper class is not needed as the text component 
			// is a flex framework object (vs the UITextField which is a flash component for halo)
			// however for the ease of associating the gumbo and halo components, 
			// the event handling is kept in the helper.
			super.componentInitialized();
			automationHelper = new  SparkRichEditableTextAutomationHelper(uiComponent, uiAutomationObject, richEditableText)
		}
		
		/**
		 *  @private
		 *  Prevent duplicate ENTER key recordings. 
		 */
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			;
		}
		
		/**
		 *  @private
		 */
		
		override public function get automationTabularData():Object
		{
			return new RichEditableTextTabularData(richEditableText);
		}
		
		
	}
	
}
