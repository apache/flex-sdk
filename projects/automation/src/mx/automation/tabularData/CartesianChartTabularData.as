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

package mx.automation.tabularData
{
	
	
	import mx.automation.AutomationManager;
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationTabularData;
	import mx.charts.chartClasses.CartesianChart;
	import mx.charts.chartClasses.Series;
	import mx.core.mx_internal;
	import mx.automation.Automation;
	
	use namespace mx_internal;
	
	/**
	 *  @private
	 */
	public class CartesianChartTabularData
		implements IAutomationTabularData
	{
		
		private var chart:CartesianChart;
		private var delegate:IAutomationObject;
		private var maxItems:int = 0;
		
		
		/**
		 *  Constructor
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function CartesianChartTabularData(delegate:IAutomationObject)
		{
			super();
			
			this.delegate = delegate;
			this.chart = delegate as CartesianChart;
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get firstVisibleRow():int
		{
			return 0;
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get lastVisibleRow():int
		{
			return chart.series.length -1;
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get numRows():int
		{
			return chart.series.length;
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get numColumns():int
		{
			maxItems = 0;
			// code modified to avoid the usage of numAutomationChildren and 
			// getAutomationChildAt in a loop
			var childList:Array  = delegate.getAutomationChildren();
			var n:int = childList.length;
			//for(var i:int = 0; i < delegate.numAutomationChildren; ++i)
			for (var i:int = 0; i < n; ++i)
			{
				//var child:IAutomationObject = delegate.getAutomationChildAt(i);
				var child:IAutomationObject = childList[i];
				if (child && (child is Series))
				{
					var series:Object = child;
					var items:Array = series.items;
					if (maxItems < items.length)
						maxItems = items.length
				}	
				
			}
			return maxItems;
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get columnNames():Array
		{
			var names:Array = [];
			maxItems = numColumns;
			for (var i:int = 0; i < maxItems; ++i)
				names.push(i);		
			
			return names;
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function getValues(start:uint = 0, end:uint = 0):Array
		{
			var _values:Array = [];
			var longestRow:int = 0;
			var i:int;
			var j:int;
			// code modified to avoid the usage of numAutomationChildren and 
			// getAutomationChildAt in a loop
			var childList:Array  = delegate.getAutomationChildren();
			var n:int = childList.length;
			end = end>n?n:end;
			for (i = start; i <= end; ++i)
			{
				//var child:IAutomationObject = delegate.getAutomationChildAt(i);
				var child:IAutomationObject = childList[i];
				var childValues:Array = [];
				if (child && (child is Series))
				{
					var series:Object = child;
					var seriesContainer:IAutomationObject = series as IAutomationObject;
					var tabularData:IAutomationTabularData = 
						seriesContainer.automationTabularData as IAutomationTabularData;
					var items:Array = series.items;
					var n2:int  = items.length;
					for (j = 0; j < n2; ++j)
					{
						var values:Array = tabularData.getAutomationValueForData(items[j]);
						childValues.push(values.join("|"));
					}	
					_values.push(childValues);
					if (longestRow < n2)
						longestRow = n2;
				}
			}
			
			// normalize the grid so all rows have the same number of columns
			var n1:int =  _values.length;
			for (i = 0; i < n1; i++)
			{
				for (j = _values[i].length; j < longestRow; j++)
				{
					_values[i].push("");
				}
			}
			return _values;
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function getAutomationValueForData(data:Object):Array
		{
			return [];
		}
	}
}
