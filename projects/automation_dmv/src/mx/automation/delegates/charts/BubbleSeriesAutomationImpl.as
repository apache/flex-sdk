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
	import mx.charts.series.BubbleSeries;
	import mx.core.IFlexDisplayObject;
	import mx.charts.series.items.BubbleSeriesItem;
	
	[Mixin]
	/**
	 * 
	 *  Defines the methods and properties required to perform instrumentation for the 
	 *  BubbleSeries class. 
	 * 
	 *  @see mx.charts.series.BubbleSeries
	 *  
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class BubbleSeriesAutomationImpl extends SeriesAutomationImpl 
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
			Automation.registerDelegateClass(BubbleSeries, BubbleSeriesAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *  @param obj BubbleSeries object to be automated. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function BubbleSeriesAutomationImpl(obj:BubbleSeries)
		{
			super(obj);
			
			bubbleSeries = obj;
		}
		
		/**
		 *  @private
		 */
		private var bubbleSeries:BubbleSeries;
		
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
			if (item is BubbleSeriesItem)
			{
				var aItem:BubbleSeriesItem = item as BubbleSeriesItem;
				var x:int = aItem.x;
				var y:int = aItem.y;
				
				var p:Point = new Point(x,y);
				p = bubbleSeries.localToGlobal(p);
				p = bubbleSeries.owner.globalToLocal(p);
				return p;
			}
			
			return super.getChartItemLocation(item);    
		}
		
	}
	
}