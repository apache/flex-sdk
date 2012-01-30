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
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import mx.automation.Automation;
	import mx.charts.ChartItem;
	import mx.charts.series.BarSeries;
	import mx.core.IFlexDisplayObject;
	import mx.charts.series.items.BarSeriesItem;
	
	[Mixin]
	/**
	 *  
	 *  Defines the methods and properties required to perform instrumentation for the 
	 *  BarSeries class. 
	 * 
	 *  @see mx.charts.series.BarSeries
	 *  
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class BarSeriesAutomationImpl extends SeriesAutomationImpl 
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
			Automation.registerDelegateClass(BarSeries, BarSeriesAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *  @param obj BarSeries object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function BarSeriesAutomationImpl(obj:BarSeries)
		{
			super(obj);
			
			barSeries = obj;
		}
		
		/**
		 * @private
		 */
		private var barSeries:BarSeries;
		
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
			if(barSeries.xField && barSeries.yField)
				return String(barSeries.xField + ";" + barSeries.yField);
			
			return super.automationName;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override protected function getChartItemLocation(item:ChartItem):Point
		{
			if (item is BarSeriesItem)
			{
				var bItem:BarSeriesItem = item as BarSeriesItem;
				var renderer:DisplayObject = bItem.itemRenderer as DisplayObject;
				var xp:int = renderer.x + renderer.width/2;
				var yp:int = renderer.y + renderer.height/2;            
				var p:Point = new Point(xp, yp);
				p = barSeries.localToGlobal(p);
				p = barSeries.owner.globalToLocal(p);
				return p;
			}
			
			return super.getChartItemLocation(item);
		}
		
	}
	
}