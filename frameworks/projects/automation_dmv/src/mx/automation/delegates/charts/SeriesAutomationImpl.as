////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package mx.automation.delegates.charts 
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import mx.automation.Automation;
	import mx.automation.AutomationIDPart;
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationObjectHelper;
	import mx.automation.IAutomationTabularData;
	import mx.automation.delegates.core.UIComponentAutomationImpl;
	import mx.charts.chartClasses.Series;
	import mx.charts.events.ChartItemEvent;
	import mx.core.EventPriority;
	import mx.charts.ChartItem;
	import mx.automation.tabularData.ChartSeriesTabularData;
	
	[Mixin]
	/**
	 * 
	 *  Defines the methods and properties required to perform instrumentation for the 
	 *  Series base class. 
	 * 
	 *  @see mx.charts.chartClasses.Series
	 *  
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class SeriesAutomationImpl extends UIComponentAutomationImpl 
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
			Automation.registerDelegateClass(Series, SeriesAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *  @param obj Series object to be automated.      
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function SeriesAutomationImpl(obj:Series)
		{
			super(obj);
			
			series = obj;
		}
		
		/**
		 *  @private
		 */
		private var series:Series;
		
		//--------------------------------------------------------------------------
		//
		//  Overridden properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override public function get automationName():String
		{
			return (series.displayName || super.automationName);
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		protected function getChartItemLocation(item:ChartItem):Point
		{
			return null;
		}
		
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
			
			if (event is ChartItemEvent)
			{
				var chartEvent:ChartItemEvent = event as ChartItemEvent;
				if (!chartEvent.hitData)
					return false;
				var p:Point = getChartItemLocation(chartEvent.hitData.chartItem);
				if (!p)
					return false;
				if (event.type == ChartItemEvent.ITEM_CLICK)
				{
					// the following call fails in FocusManager. Hence we use a work-around.
					// return help.replayClick(chartEvent.hitData.chartItem.itemRenderer as DisplayObject);
					ev = new MouseEvent(MouseEvent.CLICK);
					ev.localX = p.x;
					ev.localY = p.y;
					return help.replayClick(series.owner, ev);
				}
				else if (event.type == ChartItemEvent.ITEM_ROLL_OVER || event.type == ChartItemEvent.ITEM_ROLL_OUT)
				{
					// the following call fails in FocusManager. Hence we use a work-around.
					// return help.replayClick(chartEvent.hitData.chartItem.itemRenderer as DisplayObject);
					ev = new MouseEvent(MouseEvent.MOUSE_MOVE);
					ev.localX = p.x;
					ev.localY = p.y;
					return help.replayMouseEvent(series.owner, ev);
				}
				else if (event.type == ChartItemEvent.ITEM_DOUBLE_CLICK)
				{
					// the following call fails in FocusManager. Hence we use a work-around.
					// return help.replayClick(chartEvent.hitData.chartItem.itemRenderer as DisplayObject);
					ev = new MouseEvent(MouseEvent.DOUBLE_CLICK);
					ev.localX = p.x;
					ev.localY = p.y;
					return help.replayMouseEvent(series, ev);
				}
			}
			
			return super.replayAutomatableEvent(event);
		}
		
		/**
		 *  @private
		 */
		override public function get automationTabularData():Object
		{
			return new ChartSeriesTabularData(series);
		}
		
	}
	
}