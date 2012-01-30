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
	import mx.charts.series.PlotSeries;
	import mx.core.IFlexDisplayObject;
	import mx.charts.series.items.PlotSeriesItem;
	
	[Mixin]
	/**
	 * 
	 *  Defines the methods and properties required to perform instrumentation for the 
	 *  PlotSeries class. 
	 * 
	 *  @see mx.charts.series.PlotSeries
	 *  
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class PlotSeriesAutomationImpl extends SeriesAutomationImpl 
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
			Automation.registerDelegateClass(PlotSeries, PlotSeriesAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *  @param obj PlotSeries object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function PlotSeriesAutomationImpl(obj:PlotSeries)
		{
			super(obj);
			
			plotSeries = obj;
		}
		
		/**
		 *  @private
		 */
		private var plotSeries:PlotSeries;
		
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
			if (plotSeries.xField && plotSeries.yField)
				return String(plotSeries.xField + ";" + plotSeries.yField);
			
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
			if (item is PlotSeriesItem)
			{
				var aItem:PlotSeriesItem = item as PlotSeriesItem;
				var x:int = aItem.x;
				var y:int = aItem.y;
				
				var p:Point = new Point(x,y);
				p = plotSeries.localToGlobal(p);
				p = plotSeries.owner.globalToLocal(p);
				return p;
			}
			
			return super.getChartItemLocation(item);    
		}
		
	}
	
}