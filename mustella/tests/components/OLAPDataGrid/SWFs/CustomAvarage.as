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
package
{
	import mx.olap.IOLAPCustomAggregator;

	public class CustomAvarage implements IOLAPCustomAggregator
	{
		public function CustomAvarage()
		{
			//TODO: implement function
		}

		public function computeBegin(dataField:String):Object
		{
			//TODO: implement function
			return { sales:0, revenue:0 } ;
		}
		
		public function computeLoop(data:Object, dataField:String, value:Object):void
		{
			//TODO: implement function
			data.sales += value.sales;
			data.revenue += value.revenue;
		}
		
		public function computeEnd(data:Object, dataField:String):Number
		{
			//TODO: implement function
			return data.revenue/data.sales;
		}
		
		public function computeObjectBegin(value:Object):Object
		{
			//TODO: implement function
			return {sales:value.sales, revenue:value.revenue};
		}
		
		public function computeObjectLoop(value:Object, newValue:Object):void
		{
			//TODO: implement function
			value.sales += newValue.sales;
			value.revenue += newValue.revenue;
		}
		
		public function computeObjectEnd(value:Object, dataField:String):Number
		{
			//TODO: implement function
			var avg:Number = value.revenue/value.sales;
			avg = Math.round(avg*1000);
			avg = avg/1000;
			return avg;
		}
		
	}
}