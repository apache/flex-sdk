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
	import mx.charts.chartClasses.HLOCSeriesBase;
	import mx.core.IFlexDisplayObject;
	import mx.charts.series.items.HLOCSeriesItem;
	
	[Mixin]
	/**
	 * 
	 *  Defines the methods and properties required to perform instrumentation for the 
	 *  CandlestickSeries and HLOCSeries classes. 
	 * 
	 *  @see mx.charts.chartClasses.HLOCSeriesBase
	 *  @see mx.charts.series.CandlestickSeries
	 *  @see mx.charts.series.HLOCSeries
	 *  
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class HLOCSeriesBaseAutomationImpl extends SeriesAutomationImpl 
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
			Automation.registerDelegateClass(HLOCSeriesBase, HLOCSeriesBaseAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *  @param obj HLOCSeriesBase object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function HLOCSeriesBaseAutomationImpl(obj:HLOCSeriesBase)
		{
			super(obj);
			
			hlocSeries = obj;
		}
		
		/**
		 *  @private
		 *  storage for the owner component
		 */
		private var hlocSeries:HLOCSeriesBase;
		
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
			return hlocSeries.openField + ";" + hlocSeries.closeField;
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
			if (item is HLOCSeriesItem)
			{
				var aItem:HLOCSeriesItem = item as HLOCSeriesItem;
				var x:int = aItem.x;
				var y:int = (aItem.open + aItem.close)/2;
				
				var p:Point = new Point(x,y);
				p = hlocSeries.localToGlobal(p);
				p = hlocSeries.owner.globalToLocal(p);
				return p;
			}
			
			return super.getChartItemLocation(item);    
		}
		
	}
	
}