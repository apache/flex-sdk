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
package assets
{
	import spark.components.calendarClasses.DateSelectorDisplayMode;
	
	public class DSConstants
	{
		//public static const pauseTime:int = 500;
		
		//For displayMode testing
		//public static const normalDate:Date = new Date(2011,7,15,3,28);
		//public static const amDate:Date = new Date('2011/7/9 2:00 AM');
		//public static const pmDate:Date = new Date('2011/5/9 3:00 PM');

		public static const today:Date = new Date(2011, 8, 8, 10, 34, 30);
		
		//public static const maxDate:Date = new Date(2111,12,31,13,30);
		//public static const minDate:Date = new Date(1911,1,1,13,30);
		
		//public static const date_exceedMax:Date = new Date(2112,12,31,14,30);
		//public static const date_exceedMin:Date = new Date(1910,1,1,11,30);
		
		//public static const maxDate_Date:Date = new Date(2111,12,31); 
		//public static const minDate_Date:Date = new Date(1911,1,1);
		
		//public static const date_exceedMax_Date:Date = new Date(2112,12,31);
		//public static const date_exceedMin_Date:Date = new Date(1910,1,1);
		
		//For testing change spinner lists and orther spinner lists retain the original value
		//The originalDate is new Date(2011,5,10,13,30);
		//public static const changeYMDate:Date = new Date(2012,3,10,13,30);
		//public static const changeYDDate:Date = new Date(2012,5,13,13,30);
		//public static const changeMDDate:Date = new Date(2011,2,2,13,30);
		//public static const changeHDate:Date = new Date(2011,5,10,11,30);
		//public static const changeMinDate:Date = new Date(2011,5,10,13,50);
		//public static const changeHourMinMerDate:Date = new Date(2011,5,10,9,15);
		//public static const changeMerDate:Date = new Date(2011,5,10,9,30);
		
		//For testing event dispatched when programatically change the spinner lists
		//The originalDate is new Date(2011,5,10,13,30);
		//public static const changeYDate:Date = new Date(2012,5,10,13,30);
		//public static const changeMDate:Date = new Date(2011,1,10,13,30);
		//public static const changeDDate:Date = new Date(2011,5,1,13,30);
		
		//public static const changeYMDate:Date = new Date(2010,12,10,13,30);
		//public static const changeYDDate:Date = new Date(2010,5,3,13,30);
		//public static const changeHDate:Date = new Date(2007,11,24,13,30);
		//public static const changeMinDate:Date = new Date(2011,5,10,13,30);
		//public static const changeHMDate:Date = new Date(2011,5,10,13,30);
		
		//For testing changing spinner list in different order. The original date is new Date(2011,5,10,13,30)
		//public static const orderDDate:Date = new Date(2011,6,10,13,30);
		//public static const orderDTDate:Date = new Date(2011,6,10,10,30);
		//public static const orderDTDDate:Date = new Date(2011,6,15,10,30);
		//public static const orderDTDTDate:Date = new Date(2011,6,15,16,30);
		
		//For large range min/max Date  --- DATE mode
		public static const  minDLarge:Date = new Date ( -(360*365*24*60*60*1000) ) ; 
		public static const  maxDLarge:Date = new Date (9999, 11, 31) ; 
			
		// For large range min/max Date -- DATE_AND_TIME mode 
		public static const  minDdetail:Date = new Date ( -(360*365*24*60*60*1000)) ; 
		public static const  maxDdetail:Date = new Date (9999, 11, 31,15,30) ; 
				
		//For test invalid date
		public static const d1:Date = new Date ( 1999,5,31, 12, 30 );
		public static const d2:Date = new Date ( 1999,2,28, 12, 30 );
		public static const d3:Date = new Date ( 1999,3,31, 12, 30 );
		public static const d4:Date = new Date ( 2000,2,29, 12, 30 );
		public static const d5:Date = new Date ( 2000,3,31, 12, 30 );
		public static const minD2:Date = new Date ( 2000,1,31, 12, 30 );
		public static const maxD2:Date = new Date ( 2000,2,31, 12, 30 );
		
		
		public function DSConstants(){
		}
		
	}
	
}
