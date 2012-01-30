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
	import mx.charts.series.LineSeries;
	import mx.core.IFlexDisplayObject;
	import mx.charts.series.items.LineSeriesItem;
	
	[Mixin]
	/**
	 * 
	 *  Defines the methods and properties required to perform instrumentation for the 
	 *  LineSeries class. 
	 * 
	 *  @see mx.charts.series.LineSeries
	 *  
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class LineSeriesAutomationImpl extends SeriesAutomationImpl 
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
			Automation.registerDelegateClass(LineSeries, LineSeriesAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *  @param obj LineSeries object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function LineSeriesAutomationImpl(obj:LineSeries)
		{
			super(obj);
			
			lineSeries = obj;
		}
		
		
		/**
		 *  @private
		 */
		private var lineSeries:LineSeries;
		
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
			var name:Array = [] ;
			if (lineSeries.xField)
				name.push(lineSeries.xField);
			if (lineSeries.yField)
				name.push(lineSeries.yField);
			
			if (name.length)
				return name.join("|");
			
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
			if (item is LineSeriesItem)
			{
				var aItem:LineSeriesItem = item as LineSeriesItem;
				
				// chart edge points are not getting picked without -1.
				// (dataRegion containment check fails)
				var x:int = aItem.x-1;
				var y:int = aItem.y;
				
				var p:Point = new Point(x,y);
				p = lineSeries.localToGlobal(p);
				p = lineSeries.owner.globalToLocal(p);
				return p;
			}
			
			return super.getChartItemLocation(item);    
		}
		
	}
	
}