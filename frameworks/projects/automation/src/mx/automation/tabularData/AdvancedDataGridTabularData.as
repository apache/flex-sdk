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

package mx.automation.tabularData
{
	
	import mx.automation.Automation; 
	import mx.automation.tabularData.AdvancedListBaseTabularData;
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationTabularData;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	
	/**
	 * @private
	 */
	public class AdvancedDataGridTabularData extends AdvancedListBaseTabularData
	{
		/**
		 *  Constructor
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function AdvancedDataGridTabularData(dg:AdvancedDataGrid)
		{
			
			super(dg);
			this.dg = dg;
		}
		
		/**
		 *  @private
		 */
		private var dg:AdvancedDataGrid;
		
		/**
		 *  @private
		 */
		override public function get numColumns():int
		{
			return dg.columnCount;
		}
		
		
		/**
		 *  @private
		 */
		override public function get columnNames():Array
		{
			//override to provide the column names
			var result:Array = [];
			var n:int = dg.columnCount;
			var columns:Array = dg.columns;
			for (var i:int = 0; i < n; ++i)
			{
				result.push(columns[i].dataField);
			}
			return result;
		}
		
		/**
		 *  @private
		 */
		override public function get firstVisibleRow():int
		{
			var listItems:Array = dg.rendererArray;
			
			if (!dg.headerVisible)
				return super.firstVisibleRow;
			else
				return (listItems[0][0] 
					? dg.itemRendererToIndex(listItems[0][0])
					: 0);
		}
		
		/**
		 *  @private
		 */
		override public function getAutomationValueForData(data:Object):Array
		{
			var ret:Array = [];
			var n:int = dg.columnCount;
			
			//   var listItems:Array = dg.rendererArray;
			for (var i:int = 0; i < n; i++)
			{
				//since visibleData data is only keyed per row
				//and doesn't include renderers for each column
				//we can't optimize by using it
				//var item:IListItemRenderer = visibleData[itemToUID(data)];
				var item:IListItemRenderer;
				
				//if (item == null)
				//{
				var c:AdvancedDataGridColumn = dg.columns[i];
				//   item = dg.listItems[colNo];
				item = dg.getMeasuringRenderer(c, false,c.dataField);
				dg.setupRendererFromData(c, item, data);
				//}
				if(item is IAutomationObject)
					ret.push(IAutomationObject(item).automationValue.join(" | "));
			}
			
			return ret;
		}
		
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		override public function get numRows():int
		{
			if (dg.dataProvider)
				return dg.dataProvider.length;
			
			return super.numRows;
		}
		
		
		
	}
}
