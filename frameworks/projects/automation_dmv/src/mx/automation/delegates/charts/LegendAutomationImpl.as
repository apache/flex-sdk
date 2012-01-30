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
	import flash.events.Event; 
	import flash.events.MouseEvent;
	
	import mx.automation.Automation;
	import mx.automation.IAutomationObjectHelper;
	import mx.automation.delegates.core.UIComponentAutomationImpl;
	import mx.charts.Legend;
	import mx.charts.events.LegendMouseEvent;
	
	[Mixin]
	/**
	 * 
	 *  Defines the methods and properties required to perform instrumentation for the 
	 *  Legend class. 
	 * 
	 *  @see mx.charts.Legend
	 *  
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class LegendAutomationImpl extends UIComponentAutomationImpl 
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
			Automation.registerDelegateClass(Legend, LegendAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *  @param obj Legend object to be automated. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function LegendAutomationImpl(obj:Legend)
		{
			super(obj);
			
			legend = obj;
			
			legend.addEventListener(LegendMouseEvent.ITEM_CLICK, recordAutomatableEvent, false, 0, true);
		}
		
		/**
		 *  @private
		 *  storage for the owner component
		 */
		private var legend:Legend;
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override public function replayAutomatableEvent(event:Event):Boolean
		{
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			var ev:MouseEvent;
			
			if (event is LegendMouseEvent)
			{
				var legendEvent:LegendMouseEvent = event as LegendMouseEvent;
				if (event.type == LegendMouseEvent.ITEM_CLICK)
				{
					ev = new MouseEvent(MouseEvent.CLICK);
					ev.localX = legendEvent.item.x + legendEvent.item.width/2;
					ev.localY = legendEvent.item.y + legendEvent.item.height/2;
					return help.replayClick(legendEvent.item, ev);
				}
			}
			
			return super.replayAutomatableEvent(event);
		}
		
	}
	
}