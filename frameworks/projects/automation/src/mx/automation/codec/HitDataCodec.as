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

package mx.automation.codec
{
	
	import mx.automation.tool.IToolPropertyDescriptor;
	import mx.automation.IAutomationManager;
	import mx.automation.IAutomationObject;
	import mx.charts.HitData; 
	import mx.charts.chartClasses.Series;
	
	import mx.core.IFlexDisplayObject;
	import mx.core.mx_internal;
	import mx.charts.ChartItem;
	import mx.charts.chartClasses.IChartElement;
	
	use namespace mx_internal;
	
	/**
	 * translates between internal Flex HitData and automation-friendly version
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class HitDataCodec extends DefaultPropertyCodec
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public function HitDataCodec()
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		override public function encode(automationManager:IAutomationManager,
										obj:Object, 
										propertyDescriptor:IToolPropertyDescriptor,
										relativeParent:IAutomationObject):Object
		{
			var val:Object = getMemberFromObject(automationManager, obj, propertyDescriptor);
			var encodedID:int;
			
			if (val)
			{
				if (val is HitData)
				{
					encodedID = (val as HitData).chartItem.index;
				}
			}
			
			return encodedID;
		}
		
		override public function decode(automationManager:IAutomationManager,
										obj:Object, 
										value:Object,
										propertyDescriptor:IToolPropertyDescriptor,
										relativeParent:IAutomationObject):void
		{
			if (relativeParent is Series)
			{
				var series:Object = relativeParent;
				var items:Array = series.items;
				var n:int = items.length;
				for (var i:int = 0; i < n; ++i)
				{
					if (items[i] is ChartItem)
					{
						var chartItem:ChartItem = items[i] as ChartItem;
						if (chartItem.index == value)
						{
							obj[propertyDescriptor.name] = 
								new HitData(0, 0, 0, 0, chartItem);
							break;
						}
					}
				}
			}
		}
	}
	
}
