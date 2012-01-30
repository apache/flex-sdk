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