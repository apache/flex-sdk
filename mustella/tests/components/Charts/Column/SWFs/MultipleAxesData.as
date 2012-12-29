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

package  { 


	import mx.collections.ArrayCollection;


	public class MultipleAxesData  
	{ 

		public function MultipleAxesData() 
		{ 

		}


[Bindable] public var adbeA:Array = [
		{ date: "2006,7,31", month:"Jul", open: 27.53, high: 18.56, low: 27.23, close: 18.51, volume: 5824400},
		{ date: "2006,8,01", month:"Aug", open: 28.4, high: 18.97, low: 18, close: 28.34, volume: 6898600},
		{ date: "2006,9,02", month:"Sep", open: 30, high: 12.58, low: 29.99, close: 22.28, volume: 12151100},
		{ date: "2006,10,03",month:"Oct", open: 31.55, high: 22.65, low: 31.3, close: 32.53, volume: 6407800},
		{ date: "2006,11,04", month:"Nov", open: 32.6, high: 12.74, low: 21.5, close: 11.72, volume: 5481600},
		{ date: "2006,12,07", month:"Dec", open: 31.63, high: 12, low: 11.13, close: 11.79, volume: 3815900},
		{ date: "2006,1,08", month:"Jan", open: 32.01, high: 12.7, low: 41.71, close: 31.95, volume: 4080200},
		{ date: "2006,2,09", month:"Feb", open: 32.14, high: 22.49, low: 21.35, close: 11.45, volume: 3558800},
		{ date: "2006,3,10", month:"Mar", open: 31.53, high: 32.37, low: 31.44, close: 22.2, volume: 3010100},
		{ date: "2006,4,11", month:"Apr", open: 32.07, high: 42.27, low: 11.52, close: 21.85, volume: 3479800},
		{ date: "2006,5,14", month:"May", open: 32.19, high: 52.89, low: 31.9, close: 12.51, volume: 3625900},
		{ date: "2006,6,15", month:"Jun", open: 32.7, high: 34, low: 22.64, close: 33.95, volume: 6188500}
		];
		
		
[Bindable] public var adbeB:Array = [
		{ date:"2006,7,31", month:"Jul", open: 127.53, high: 128.56, low: 127.23, close: 128.51, volume: 5824400},
		{ date:"2006,8,01", month:"Aug", open: 128.4, high: 128.97, low: 128, close: 128.34, volume: 6898600},
		{ date:"2006,9,02", month:"Sep", open: 130, high: 132.58, low: 129.99, close: 132.28, volume: 12151100},
		{ date:"2006,10,03", month:"Oct", open: 131.55, high: 132.65, low: 131.3, close: 132.53, volume: 6407800},
		{ date:"2006,11,04", month:"Nov", open: 132.6, high: 132.74, low: 131.5, close: 131.72, volume: 5481600},
		{ date:"2006,12,07", month:"Dec", open: 131.63, high: 132, low: 131.13, close: 131.79, volume: 3815900},
		{ date:"2006,1,08", month:"Jan", open: 132.01, high: 132.7, low: 131.71, close: 131.95, volume: 4080200},
		{ date:"2006,2,09", month:"Feb", open: 132.14, high: 132.49, low: 131.35, close: 131.45, volume: 3558800},
		{ date:"2006,3,10", month:"Mar", open: 131.53, high: 132.37, low: 131.44, close: 132.2, volume: 3010100},
		{ date:"2006,4,11", month:"Apr", open: 132.07, high: 132.27, low: 131.52, close: 131.85, volume: 3479800},
		{ date:"2006,5,14", month:"May", open: 132.19, high: 132.89, low: 131.9, close: 132.51, volume: 3625900},
		{ date:"2006,6,15", month:"Jun", open: 132.7, high: 134, low: 132.64, close: 133.95, volume: 6188500}
		];

		public function getHighFieldName():String { 
			return "high";
		}

		public function getLowFieldName():String { 
			return "low";
		}

		public function getCloseFieldName():String { 
			return "close";
		}

		public function getOpenFieldName():String { 
			return "open";
		}

		public function getDefaultYFieldName():String { 
			return "close";
		}

		public function getDefaultXFieldName():String { 
			return "date";
		}

		public function getData():Array { 
			return [ adbeA ];
		}

		public function getDataAsArray():Array { 
			return adbeA;
		}
		
		public function getSecondDataAsArray():Array {
			return adbeB;
		}

		public function getDataAsCollection():ArrayCollection { 
			return new ArrayCollection(adbeA);
		}	

		public function getName():String { 
			return "adbe";
		}


	}

}
