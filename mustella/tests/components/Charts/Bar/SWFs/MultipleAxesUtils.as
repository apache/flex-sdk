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
	import mx.charts.*;
	import mx.charts.series.*;
	import mx.charts.series.items.*;
	import mx.charts.chartClasses.*;
	import mx.charts.renderers.*;
	import mx.charts.*;
	import mx.core.ClassFactory;
	import mx.graphics.*;		


	public class MultipleAxesUtils 
	{ 	
		public function MultipleAxesUtils()
		{
		}

		public static function myParseFunction(s:String):Date 
		{ 
		  var a:Array = s.split(",");
		  var newDate:Date = new Date(a[0],a[1]-1,a[2]);
		  return newDate;
		}

		private static function myLabelFunction(axis: IAxisRenderer, label: String):String
		{
			var num:Number;
			num = int(label);     	
			num = num*10;     	
			return num.toString();
		}

		public static function AxisRenderers(testCaseType:String, chart:Object):void
		{
			var arrHorAxisRenderers:Array = new Array();
			var arrVerAxisRenderers:Array = new Array();
					
			var seriesArray:Array = new Array();		
			
			var myHorH1:CategoryAxis = new CategoryAxis();
			var myHorH2:CategoryAxis = new CategoryAxis();
			
			var myVerV1:LinearAxis = new LinearAxis();
			var myVerV2:LinearAxis = new LinearAxis();
			var myVerV3:LinearAxis = new LinearAxis();
			var myVerV4:LinearAxis = new LinearAxis();
			
			var myHorAxisRenderer: AxisRenderer = new AxisRenderer();
			var myHorAxisRenderer1: AxisRenderer = new AxisRenderer();
			
			var myVerAxisRenderer: AxisRenderer = new AxisRenderer();
			var myVerAxisRenderer1: AxisRenderer = new AxisRenderer();
			var myVerAxisRenderer2: AxisRenderer = new AxisRenderer();
			var myVerAxisRenderer3: AxisRenderer = new AxisRenderer();
			
			var closeBar:BarSeries = new BarSeries();
			var openBar:BarSeries = new BarSeries();	
			var highBar:BarSeries = new BarSeries();
			var lowBar:BarSeries = new BarSeries();
			
			
			switch(testCaseType)
			{	
				case "noAxisSpecified":	
				
					myHorH1.categoryField = "month";			
					chart.verticalAxis = myHorH1;

					closeBar.xField = "close";
					closeBar.yField = "month";						
					seriesArray.push(closeBar);

					openBar.xField = "open";
					openBar.yField = "month"; 			
					seriesArray.push(openBar);	

					highBar.xField = "high";
					highBar.yField = "month";					
					seriesArray.push(highBar);

					lowBar.xField = "low";
					lowBar.yField = "month";			
					seriesArray.push(lowBar);	

					chart.series = seriesArray;			
					break;

				case "axisAtSeries":
				
					myHorH1.categoryField = "month";				
					myHorH2.categoryField = "date";					

					chart.verticalAxis = myHorH1;								

					myVerV2.minimum = 20;
					myVerV2.maximum = 170;

					myHorAxisRenderer.axis = myHorH2;
					myHorAxisRenderer.placement = "right";		 	
					arrHorAxisRenderers.push(myHorAxisRenderer); 		 

					chart.horizontalAxis = myVerV1;

					myVerAxisRenderer1.axis = myVerV2;
					myVerAxisRenderer1.placement = "bottom";
					arrVerAxisRenderers.push(myVerAxisRenderer1); 

					chart.horizontalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrHorAxisRenderers);	

					closeBar.xField = "close";					
					closeBar.verticalAxis = myHorH2;
					seriesArray.push(closeBar);

					openBar.xField = "open";					
					openBar.verticalAxis = myHorH2;
					seriesArray.push(openBar);	

					highBar.xField = "high";						
					highBar.horizontalAxis = myVerV2;
					seriesArray.push(highBar);	

					lowBar.xField = "low";						
					seriesArray.push(lowBar);		

					chart.series = seriesArray;				
					break;

				case "noAxisRenderers":		
				
					myHorH1.categoryField = "month";								
					chart.verticalAxis = myHorH1;

					myVerV2.minimum = 20;
					myVerV2.maximum = 170;						

					chart.horizontalAxis = myVerV1;

					closeBar.xField = "close";						
					seriesArray.push(closeBar);

					openBar.xField = "open";											
					seriesArray.push(openBar);

					highBar.xField = "high";						
					seriesArray.push(highBar);

					lowBar.xField = "low";			
					seriesArray.push(lowBar);		

					chart.series = seriesArray;	
					break;
				
				
				case "axisRendererWithPlacement":
					
					myHorH1.categoryField = "month";
					myHorH2.categoryField = "date";

					chart.verticalAxis = myHorH1;					

					myVerV2.minimum = 20;
					myVerV2.maximum = 170;

					myVerV1.title = "close";
					myVerV2.title = "open";
					myVerV3.title = "high";
					myVerV4.title = "low";

					myHorAxisRenderer.axis = myHorH2;
					myHorAxisRenderer.placement = "right";		 	
					arrHorAxisRenderers.push(myHorAxisRenderer); 

					myVerAxisRenderer1.axis = myVerV2;
					myVerAxisRenderer1.placement = "top";
					arrVerAxisRenderers.push(myVerAxisRenderer1); 

					myVerAxisRenderer2.axis = myVerV3;
					myVerAxisRenderer2.placement = "top";
					arrVerAxisRenderers.push(myVerAxisRenderer2);

					myVerAxisRenderer3.axis = myVerV4;
					myVerAxisRenderer3.placement = "bottom";
					arrVerAxisRenderers.push(myVerAxisRenderer3);

					chart.horizontalAxis = myVerV1;

					chart.horizontalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrHorAxisRenderers);	

					closeBar.xField = "close";								
					closeBar.verticalAxis = myHorH1;			
					seriesArray.push(closeBar);

					openBar.xField = "open";					
					openBar.verticalAxis = myHorH2;
					openBar.horizontalAxis = myVerV2;
					seriesArray.push(openBar);	

					highBar.xField = "high";						
					highBar.verticalAxis = myHorH1;
					highBar.horizontalAxis = myVerV3;
					seriesArray.push(highBar);	

					lowBar.xField = "low";		
					lowBar.verticalAxis = myVerV4;	
					seriesArray.push(lowBar);		

					chart.series = seriesArray;			
					break;
			}
		}

		public static function axisTest(testCaseType:String, chart:Object):void
		{
			var arrHorAxisRenderers:Array = new Array();
			var arrVerAxisRenderers:Array = new Array();
			
			var seriesArray:Array = new Array();			
			var myHorH1:CategoryAxis = new CategoryAxis();
			var myHorH2:CategoryAxis = new CategoryAxis();
			var myHorH11:DateTimeAxis = new DateTimeAxis();
			
			var myVerV1:LinearAxis = new LinearAxis();						
			var myVerV2:LinearAxis = new LinearAxis();
			var myVerV3:LinearAxis = new LinearAxis();
			var myVerV4:LinearAxis = new LinearAxis();
			var myVerV21:LogAxis = new LogAxis();	
			
			var myHorAxisRenderer: AxisRenderer = new AxisRenderer();
			var myHorAxisRenderer1: AxisRenderer = new AxisRenderer();

			var myVerAxisRenderer: AxisRenderer = new AxisRenderer();
			var myVerAxisRenderer1: AxisRenderer = new AxisRenderer();
			var myVerAxisRenderer2: AxisRenderer = new AxisRenderer();
			var myVerAxisRenderer3: AxisRenderer = new AxisRenderer();
			
			var closeBar:BarSeries = new BarSeries();
			var openBar:BarSeries = new BarSeries();
			var highBar:BarSeries = new BarSeries();
			var lowBar:BarSeries = new BarSeries();
			
			
			switch(testCaseType)
			{	
				case "setAxis":
				
					myHorH1.categoryField = "month";				
					myHorH2.categoryField = "date";					
					chart.verticalAxis = myHorH1;

					myVerV2.title = "Open";
					myVerV2.minimum = 20;
					myVerV2.maximum = 170;						

					chart.verticalAxis = myVerV1;

					closeBar.xField = "close";						
					seriesArray.push(closeBar);

					openBar.xField = "open";			 	
					openBar.dataTransform.setAxis(CartesianTransform.HORIZONTAL_AXIS, myVerV2);
					seriesArray.push(openBar);	

					highBar.xField = "high";						
					seriesArray.push(highBar);	

					lowBar.xField = "low";			
					seriesArray.push(lowBar);		

					chart.series = seriesArray;	
					break;

				case "validHorVerAxis":
							
					myHorH1.categoryField = "month";	
					myHorH2.categoryField = "date";					
					
					chart.verticalAxis = myHorH1;

					myVerV2.minimum = 20;
					myVerV2.maximum = 170;

					myVerV1.title = "close";
					myVerV2.title = "open";
					myVerV3.title = "high";
					myVerV4.title = "low";

					myHorAxisRenderer.axis = myHorH2;
					myHorAxisRenderer.placement = "right";		 	
					arrHorAxisRenderers.push(myHorAxisRenderer); 

					myHorAxisRenderer1.axis = myHorH1;
					myHorAxisRenderer1.placement = "left";		 	
					arrHorAxisRenderers.push(myHorAxisRenderer1); 				

					myVerAxisRenderer1.axis = myVerV2;
					myVerAxisRenderer1.placement = "bottom";
					arrVerAxisRenderers.push(myVerAxisRenderer1); 

					myVerAxisRenderer2.axis = myVerV3;
					myVerAxisRenderer2.placement = "top";
					arrVerAxisRenderers.push(myVerAxisRenderer2);

					myVerAxisRenderer3.axis = myVerV4;
					myVerAxisRenderer3.placement = "bottom";
					arrVerAxisRenderers.push(myVerAxisRenderer3);

					chart.horizontalAxis = myVerV1;

					chart.horizontalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrHorAxisRenderers);		 	

					closeBar.xField = "close";								
					closeBar.verticalAxis = myHorH1;			
					seriesArray.push(closeBar);

					openBar.xField = "open";					
					openBar.verticalAxis = myHorH2;
					openBar.horizontalAxis = myVerV2;
					seriesArray.push(openBar);	

					highBar.xField = "high";						
					highBar.verticalAxis = myHorH1;
					highBar.horizontalAxis = myVerV3;
					seriesArray.push(highBar);	

					lowBar.xField = "low";		
					lowBar.horizontalAxis = myVerV4;	
					seriesArray.push(lowBar);		

					chart.series = seriesArray;			
					break;


				case "diffAxisType":
					//test with all types of axis(log, dateTime)

					myHorH11.dataUnits = "days";
					myHorH11.labelUnits = "days";
					myHorH11.parseFunction = myParseFunction;
					myHorH11.displayLocalTime = true;

					chart.verticalAxis = myHorH11;								

					myVerV21.minimum = 10;
					myVerV21.maximum = 10000;
					myVerV21.title = "log axis";
					myVerV21.interval = 10;

					myVerV1.title = "close";
					myVerV3.title = "high";
					myVerV4.title = "low";

					myVerAxisRenderer1.axis = myVerV21;
					myVerAxisRenderer1.placement = "right";
					arrVerAxisRenderers.push(myVerAxisRenderer1); 

					chart.horizontalAxis = myVerV1;

					chart.horizontalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrHorAxisRenderers);		 	

					closeBar.xField = "close";
					closeBar.yField = "date";
					closeBar.verticalAxis = myHorH11;			
					seriesArray.push(closeBar);

					openBar.xField = "open";
					openBar.yField = "date";
					openBar.horizontalAxis = myVerV21;
					seriesArray.push(openBar);	

					chart.series = seriesArray;			
					break;

				case "disabledDays":
					//disabled days and ranges				
					myHorH11.dataUnits = "days";
					myHorH11.labelUnits = "days";
					myHorH11.parseFunction = myParseFunction;
					myHorH11.displayLocalTime = true;
					myHorH11.disabledDays = [0];

					chart.verticalAxis = myHorH11;								

					myVerV21.minimum = 10;
					myVerV21.maximum = 10000;
					myVerV21.title = "log axis";
					myVerV21.interval = 10;

					myVerV1.title = "close";
					myVerV3.title = "high";
					myVerV4.title = "low";

					myVerAxisRenderer1.axis = myVerV21;
					myVerAxisRenderer1.placement = "right";
					arrVerAxisRenderers.push(myVerAxisRenderer1); 

					chart.horizontalAxis = myVerV1;

					chart.horizontalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrHorAxisRenderers);		 	

					closeBar.xField = "close";
					closeBar.yField = "date";
					closeBar.verticalAxis = myHorH11;			
					seriesArray.push(closeBar);

					openBar.xField = "open";
					openBar.yField = "date";
					openBar.horizontalAxis = myVerV21;				
					seriesArray.push(openBar);	

					chart.series = seriesArray;		
					break;
				
			}
		}


		public static function placementTest(testCaseType:String, chart:Object):void
		{
			var arrHorAxisRenderers:Array = new Array();
			var arrVerAxisRenderers:Array = new Array();
			var seriesArray:Array = new Array();
			
			var myHorH1:CategoryAxis = new CategoryAxis();
			var myHorH2:CategoryAxis = new CategoryAxis();
			
			var myVerV1:LinearAxis = new LinearAxis();						
			var myVerV2:LinearAxis = new LinearAxis();
			var myVerV3:LinearAxis = new LinearAxis();
			var myVerV4:LinearAxis = new LinearAxis();
			
			var myHorAxisRenderer: AxisRenderer = new AxisRenderer();
			var myHorAxisRenderer1: AxisRenderer = new AxisRenderer();

			var myVerAxisRenderer: AxisRenderer = new AxisRenderer();
			var myVerAxisRenderer1: AxisRenderer = new AxisRenderer();
			var myVerAxisRenderer2: AxisRenderer = new AxisRenderer();
			var myVerAxisRenderer3: AxisRenderer = new AxisRenderer();

			var closeBar:BarSeries = new BarSeries();
			var openBar:BarSeries = new BarSeries();
			var highBar:BarSeries = new BarSeries();
			var lowBar:BarSeries = new BarSeries();			
			
			switch(testCaseType)
			{	
				case "multipleLeftAndTop":				
					myHorH1.categoryField = "month";	
					myHorH2.categoryField = "date";
										
					chart.verticalAxis = myHorH1;

					myVerV2.minimum = 20;
					myVerV2.maximum = 170;

					myVerV1.title = "close";
					myVerV2.title = "open";
					myVerV3.title = "high";
					myVerV4.title = "low";

					myHorAxisRenderer.axis = myHorH2;
					myHorAxisRenderer.placement = "right";		 	
					arrHorAxisRenderers.push(myHorAxisRenderer); 

					myVerAxisRenderer1.axis = myVerV2;
					myVerAxisRenderer1.placement = "bottom";
					arrVerAxisRenderers.push(myVerAxisRenderer1); 

					myVerAxisRenderer2.axis = myVerV3;
					myVerAxisRenderer2.placement = "top";
					arrVerAxisRenderers.push(myVerAxisRenderer2);

					myVerAxisRenderer3.axis = myVerV4;
					myVerAxisRenderer3.placement = "bottom";
					arrVerAxisRenderers.push(myVerAxisRenderer3);

					chart.horizontalAxis = myVerV1;

					chart.horizontalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrHorAxisRenderers);	

					closeBar.xField = "close";								
					closeBar.verticalAxis = myHorH1;			
					seriesArray.push(closeBar);

					openBar.xField = "open";					
					openBar.verticalAxis = myHorH2;
					openBar.horizontalAxis = myVerV2;
					seriesArray.push(openBar);	

					highBar.xField = "high";						
					highBar.verticalAxis = myHorH1;
					highBar.horizontalAxis = myVerV3;
					seriesArray.push(highBar);

					lowBar.xField = "low";		
					lowBar.horizontalAxis = myVerV4;	
					seriesArray.push(lowBar);		

					chart.series = seriesArray;				
					break;

				case "multipleBottomAndRight":				
				
					myHorH1.categoryField = "month";
					myHorH2.categoryField = "date";					
										
					chart.verticalAxis = myHorH1;

					myVerV2.minimum = 20;
					myVerV2.maximum = 170;

					myVerV1.title = "close";
					myVerV2.title = "open";
					myVerV3.title = "high";
					myVerV4.title = "low";

					myHorAxisRenderer.axis = myHorH2;
					myHorAxisRenderer.placement = "right";		 	
					arrHorAxisRenderers.push(myHorAxisRenderer); 

					myVerAxisRenderer1.axis = myVerV2;
					myVerAxisRenderer1.placement = "top";
					arrVerAxisRenderers.push(myVerAxisRenderer1); 

					myVerAxisRenderer2.axis = myVerV3;
					myVerAxisRenderer2.placement = "bottom";
					arrVerAxisRenderers.push(myVerAxisRenderer2);

					myVerAxisRenderer3.axis = myVerV4;
					myVerAxisRenderer3.placement = "bottom";
					arrVerAxisRenderers.push(myVerAxisRenderer3);

					chart.horizontalAxis = myVerV1;

					chart.horizontalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrHorAxisRenderers);		 	

					closeBar.xField = "close";								
					closeBar.verticalAxis = myHorH1;			
					seriesArray.push(closeBar);

					openBar.xField = "open";
					openBar.verticalAxis = myHorH2;
					openBar.horizontalAxis = myVerV2;
					seriesArray.push(openBar);				

					highBar.xField = "high";						
					highBar.verticalAxis = myHorH1;
					highBar.horizontalAxis = myVerV3;
					seriesArray.push(highBar);					

					lowBar.xField = "low";		
					lowBar.horizontalAxis = myVerV4;	
					seriesArray.push(lowBar);		

					chart.series = seriesArray;				
					break;

				case "noVerPlacementSpecified":
				
					myHorH1.categoryField = "month";
					myHorH2.categoryField = "date";
											
					chart.verticalAxis = myHorH1;

					myVerV2.minimum = 20;
					myVerV2.maximum = 170;

					myVerV1.title = "close";
					myVerV2.title = "open";
					myVerV3.title = "high";
					myVerV4.title = "low";

					myHorAxisRenderer.axis = myHorH2;
					myHorAxisRenderer.placement = "bottom";		 	
					arrHorAxisRenderers.push(myHorAxisRenderer); 

					myVerAxisRenderer1.axis = myVerV2;				
					arrVerAxisRenderers.push(myVerAxisRenderer1); 

					myVerAxisRenderer2.axis = myVerV3;				
					arrVerAxisRenderers.push(myVerAxisRenderer2);

					myVerAxisRenderer3.axis = myVerV4;				
					arrVerAxisRenderers.push(myVerAxisRenderer3);

					chart.horizontalAxis = myVerV1;

					chart.horizontalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrHorAxisRenderers);	

					closeBar.xField = "close";								
					closeBar.verticalAxis = myHorH1;			
					seriesArray.push(closeBar);

					openBar.xField = "open";
					openBar.yField = "date"; 
					openBar.verticalAxis = myHorH2;
					openBar.horizontalAxis = myVerV2;
					seriesArray.push(openBar);	

					highBar.xField = "high";						
					highBar.verticalAxis = myHorH1;
					highBar.horizontalAxis = myVerV3;
					seriesArray.push(highBar);		

					lowBar.xField = "low";		
					lowBar.horizontalAxis = myVerV4;	
					seriesArray.push(lowBar);		

					chart.series = seriesArray;				
					break;

				case "noPlacementSpecified":				
			
					myHorH1.categoryField = "month";
					myHorH2.categoryField = "date";
											
					chart.verticalAxis = myHorH1;

					myVerV2.minimum = 20;
					myVerV2.maximum = 170;

					myVerV1.title = "close";
					myVerV2.title = "open";
					myVerV3.title = "high";
					myVerV4.title = "low";

					myHorAxisRenderer.axis = myHorH2;					 	
					arrHorAxisRenderers.push(myHorAxisRenderer);					

					myVerAxisRenderer1.axis = myVerV2;				
					arrVerAxisRenderers.push(myVerAxisRenderer1); 

					myVerAxisRenderer2.axis = myVerV3;				
					arrVerAxisRenderers.push(myVerAxisRenderer2);

					myVerAxisRenderer3.axis = myVerV4;				
					arrVerAxisRenderers.push(myVerAxisRenderer3);

					chart.horizontalAxis = myVerV1;

					chart.horizontalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrHorAxisRenderers);		

					closeBar.xField = "close";								
					closeBar.verticalAxis = myHorH1;			
					seriesArray.push(closeBar);

					openBar.xField = "open";					
					openBar.verticalAxis = myHorH2;
					openBar.horizontalAxis = myVerV2;
					seriesArray.push(openBar);	

					highBar.xField = "high";						
					highBar.verticalAxis = myHorH1;
					highBar.horizontalAxis = myVerV3;
					seriesArray.push(highBar);	

					lowBar.xField = "low";		
					lowBar.verticalAxis = myVerV4;	
					seriesArray.push(lowBar);		

					chart.series = seriesArray;				
					break;

			}
		}

		public static function axisAndRendererTests(testCaseType:String, chart:Object):void
		{		
			var arrHorAxisRenderers:Array = new Array();
			var arrVerAxisRenderers:Array = new Array();
			var seriesArray:Array = new Array();

			var myHorH1:CategoryAxis = new CategoryAxis();
			var myHorH2:CategoryAxis = new CategoryAxis();

			var myVerV1:LinearAxis = new LinearAxis();						
			var myVerV2:LinearAxis = new LinearAxis();
			var myVerV3:LinearAxis = new LinearAxis();
			var myVerV4:LinearAxis = new LinearAxis();

			var myHorAxisRenderer: AxisRenderer = new AxisRenderer();
			var myHorAxisRenderer1: AxisRenderer = new AxisRenderer();

			var myVerAxisRenderer: AxisRenderer = new AxisRenderer();
			var myVerAxisRenderer1: AxisRenderer = new AxisRenderer();
			var myVerAxisRenderer2: AxisRenderer = new AxisRenderer();
			var myVerAxisRenderer3: AxisRenderer = new AxisRenderer();

			var closeBar:BarSeries = new BarSeries();
			var openBar:BarSeries = new BarSeries();
			var highBar:BarSeries = new BarSeries();
			var lowBar:BarSeries = new BarSeries();
			
			switch(testCaseType)
			{	
				case "sameAxisOnDiffRenderers":						
					myHorH1.categoryField = "month";
					myHorH2.categoryField = "date";				

					chart.verticalAxis = myHorH1;				

					myVerV2.minimum = 20;
					myVerV2.maximum = 170;

					myVerV1.title = "close";
					myVerV2.title = "open";
					myVerV3.title = "high";			

					myHorAxisRenderer.axis = myHorH2;
					myHorAxisRenderer.placement = "left";		 	
					arrHorAxisRenderers.push(myHorAxisRenderer); 				

					myVerAxisRenderer.axis = myVerV2;
					myVerAxisRenderer.placement = "bottom";
					arrVerAxisRenderers.push(myVerAxisRenderer);			

					myVerAxisRenderer2.axis = myVerV3;
					myVerAxisRenderer2.placement = "bottom";
					arrVerAxisRenderers.push(myVerAxisRenderer2);

					myVerAxisRenderer3.axis = myVerV3;
					myVerAxisRenderer3.placement = "top";
					arrVerAxisRenderers.push(myVerAxisRenderer3);

					chart.horizontalAxis = myVerV1;

					chart.horizontalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrHorAxisRenderers);		 	

					closeBar.xField = "close";								
					closeBar.verticalAxis = myHorH2;			
					seriesArray.push(closeBar);

					openBar.xField = "open";						
					openBar.horizontalAxis = myVerV2;
					seriesArray.push(openBar);				

					highBar.xField = "high";				
					highBar.horizontalAxis = myVerV3;
					seriesArray.push(highBar);					

					lowBar.xField = "low";						
					seriesArray.push(lowBar);	
					chart.series = seriesArray;				
					break;

				case "sameRendererWithDiffAxis":
				
					myHorH1.categoryField = "month";
					chart.verticalAxis = myHorH1;

					myVerV2.minimum = 20;
					myVerV2.maximum = 170;

					myVerV1.title = "close";
					myVerV2.title = "open";
					myVerV3.title = "high";

					myHorAxisRenderer1.axis = myHorH1;
					myHorAxisRenderer1.placement = "right";		 	
					arrHorAxisRenderers.push(myHorAxisRenderer1);

					myVerAxisRenderer1.axis = myVerV2;
					myVerAxisRenderer1.placement = "top";
					arrVerAxisRenderers.push(myVerAxisRenderer1); 

					myVerAxisRenderer2.axis = myVerV3;
					myVerAxisRenderer2.placement = "top";
					arrVerAxisRenderers.push(myVerAxisRenderer2);

					myVerAxisRenderer3.axis = myVerV3;
					myVerAxisRenderer3.placement = "bottom";
					arrVerAxisRenderers.push(myVerAxisRenderer3);

					chart.horizontalAxis = myVerV1;

					chart.horizontalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrHorAxisRenderers);		 	

					closeBar.xField = "close";								
					closeBar.verticalAxis = myHorH1;			
					seriesArray.push(closeBar);

					openBar.xField = "open";						
					openBar.horizontalAxis = myVerV2;
					seriesArray.push(openBar);				

					highBar.xField = "high";				
					highBar.horizontalAxis = myVerV3;
					seriesArray.push(highBar);					

					lowBar.xField = "low";						
					seriesArray.push(lowBar);	
					chart.series = seriesArray;				
					break;
			}
		}


		public static function setChartPadding(testCaseType:String, chart:Object):void
		{
			switch(testCaseType)
			{	
				case "paddingTop1":
					setMultipleAxis(chart);				
					chart.setStyle("paddingTop", 20);				
					break;

				case "paddingTop2":				
					setMultipleAxis(chart);				
					chart.setStyle("paddingTop", 50);				
					break;

				case "paddingBottom1":				
					setMultipleAxis(chart);				
					chart.setStyle("paddingBottom", 10);				
					break;

				case "paddingBottom2":				
					setMultipleAxis(chart);				
					chart.setStyle("paddingBottom", 60);				
					break;
					
				case "paddingRight1":				
					setMultipleAxis(chart);				
					chart.setStyle("paddingRight", 10);				
					break;

				case "paddingRight2":				
					setMultipleAxis(chart);				
					chart.setStyle("paddingRight", 50);				
					break;

				case "paddingLeft1":				
					setMultipleAxis(chart);				
					chart.setStyle("paddingLeft", 10);				
					break;

				case "paddingLeft2":				
					setMultipleAxis(chart);				
					chart.setStyle("paddingLeft", 50);				
					break;				
			}
		}

		public static function setChartGutter(testCaseType:String, chart:Object):void
		{
			switch(testCaseType)
			{	
				case "gutterTop1":
					setMultipleAxis(chart);				
					chart.setStyle("gutterTop", 20);				
					break;

				case "gutterTop2":				
					setMultipleAxis(chart);				
					chart.setStyle("gutterTop", 50);				
					break;

				case "gutterBottom1":				
					setMultipleAxis(chart);				
					chart.setStyle("gutterBottom", 10);				
					break;

				case "gutterBottom2":				
					setMultipleAxis(chart);				
					chart.setStyle("gutterBottom", 60);				
					break;
					
				case "gutterRight1":				
					setMultipleAxis(chart);				
					chart.setStyle("gutterRight", 10);				
					break;

				case "gutterRight2":				
					setMultipleAxis(chart);				
					chart.setStyle("gutterRight", 70);				
					break;

				case "gutterLeft1":				
					setMultipleAxis(chart);				
					chart.setStyle("gutterLeft", 10);				
					break;

				case "gutterLeft2":				
					setMultipleAxis(chart);				
					chart.setStyle("gutterLeft", 70);				
					break;
			}
		}

		public static function setLabelFunction(testCaseType:String, chart:Object):void
		{
			var arrHorAxisRenderers:Array = new Array();
			var arrVerAxisRenderers:Array = new Array();
			var seriesArray:Array = new Array();
			
			var myHorH1:CategoryAxis = new CategoryAxis();
			var myHorH2:CategoryAxis = new CategoryAxis();
			
			var myVerV1:LinearAxis = new LinearAxis();						
			var myVerV2:LinearAxis = new LinearAxis();
			var myVerV3:LinearAxis = new LinearAxis();
			var myVerV4:LinearAxis = new LinearAxis();

			var myHorAxisRenderer: AxisRenderer = new AxisRenderer();
			var myHorAxisRenderer1: AxisRenderer = new AxisRenderer();

			var myVerAxisRenderer: AxisRenderer = new AxisRenderer();
			var myVerAxisRenderer1: AxisRenderer = new AxisRenderer();
			var myVerAxisRenderer2: AxisRenderer = new AxisRenderer();
			var myVerAxisRenderer3: AxisRenderer = new AxisRenderer();

			var closeBar:BarSeries = new BarSeries();
			var openBar:BarSeries = new BarSeries();
			var highBar:BarSeries = new BarSeries();
			var lowBar:BarSeries = new BarSeries();
			
			switch(testCaseType)
			{	
				case "validLabelFunction":				
					myHorH1.categoryField = "month";
					myHorH2.categoryField = "date";
									
					chart.verticalAxis = myHorH1;

					myVerV2.minimum = 20;
					myVerV2.maximum = 170;

					myVerV1.title = "close";
					myVerV2.title = "open";
					myVerV3.title = "high";
					myVerV4.title = "low";

					myHorAxisRenderer.axis = myHorH2;
					myHorAxisRenderer.placement = "right";		 	
					arrHorAxisRenderers.push(myHorAxisRenderer); 

					myVerAxisRenderer1.axis = myVerV2;
					myVerAxisRenderer1.placement = "top";
					arrVerAxisRenderers.push(myVerAxisRenderer1); 

					myVerAxisRenderer2.axis = myVerV3;
					myVerAxisRenderer2.placement = "bottom";
					arrVerAxisRenderers.push(myVerAxisRenderer2);

					myVerAxisRenderer3.axis = myVerV4;
					myVerAxisRenderer3.placement = "bottom";
					myVerAxisRenderer3.labelFunction = myLabelFunction;
					arrVerAxisRenderers.push(myVerAxisRenderer3);

					chart.horizontalAxis = myVerV1;

					chart.horizontalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrHorAxisRenderers);		 	

					closeBar.xField = "close";								
					closeBar.verticalAxis = myHorH1;			
					seriesArray.push(closeBar);

					openBar.xField = "open";					
					openBar.verticalAxis = myHorH2;
					openBar.horizontalAxis = myVerV2;
					seriesArray.push(openBar);				

					highBar.xField = "high";						
					highBar.verticalAxis = myHorH1;
					highBar.horizontalAxis = myVerV3;
					seriesArray.push(highBar);					

					lowBar.xField = "low";		
					lowBar.horizontalAxis = myVerV4;	
					seriesArray.push(lowBar);		

					chart.series = seriesArray;				
					break;

				case "labelFnDiffAxisType":		

					var myHorH11:DateTimeAxis = new DateTimeAxis();
					myHorH11.dataUnits = "days";
					myHorH11.labelUnits = "days";
					myHorH11.parseFunction = myParseFunction;
					myHorH11.displayLocalTime = true;

					chart.verticalAxis = myHorH11;	

					var myVerV21:LogAxis = new LogAxis();				
					myVerV21.minimum = 10;
					myVerV21.maximum = 10000;
					myVerV21.title = "log axis";
					myVerV21.interval = 10;

					myVerV1.title = "close";
					myVerV3.title = "high";
					myVerV4.title = "low";				

					myVerAxisRenderer1.axis = myVerV21;
					myVerAxisRenderer1.placement = "right";
					myVerAxisRenderer1.labelFunction = myLabelFunction;
					arrVerAxisRenderers.push(myVerAxisRenderer1); 

					chart.horizontalAxis = myVerV1;

					chart.horizontalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrHorAxisRenderers);		 	

					closeBar.xField = "close";	
					closeBar.yField = "date";
					closeBar.verticalAxis = myHorH11;			
					seriesArray.push(closeBar);

					openBar.xField = "open";	
					openBar.yField = "date";
					openBar.horizontalAxis = myVerV1;
					seriesArray.push(openBar);

					chart.series = seriesArray;						
					break;

				case "labelFnOnDeprecatedProperty":		
				
					chart.verticalAxisRenderer.labelFunction = myLabelFunction;
					closeBar.xField = "close";						
					seriesArray.push(closeBar);
					chart.series = seriesArray;	
					break;
			}	
		}


		private static function setMultipleAxis(chart:Object):void
		{
			var arrHorAxisRenderers:Array = new Array();
			var arrVerAxisRenderers:Array = new Array();
			var seriesArray:Array = new Array();

			var myHorH1:CategoryAxis = new CategoryAxis();
			//var myHorH2:DateTimeAxis = new DateTimeAxis();			
			var myHorH2:CategoryAxis = new CategoryAxis();
			
			var myVerV1:LinearAxis = new LinearAxis();						
			var myVerV2:LinearAxis = new LinearAxis();
			var myVerV3:LinearAxis = new LinearAxis();
			var myVerV4:LinearAxis = new LinearAxis();			
			
			var myHorAxisRenderer: AxisRenderer = new AxisRenderer();
			var myHorAxisRenderer1: AxisRenderer = new AxisRenderer();

			var myVerAxisRenderer: AxisRenderer = new AxisRenderer();
			var myVerAxisRenderer1: AxisRenderer = new AxisRenderer();
			var myVerAxisRenderer2: AxisRenderer = new AxisRenderer();
			var myVerAxisRenderer3: AxisRenderer = new AxisRenderer();

			var closeBar:BarSeries = new BarSeries();
			var openBar:BarSeries = new BarSeries();
			var highBar:BarSeries = new BarSeries();
			var lowBar:BarSeries = new BarSeries();
			
			myHorH1.categoryField = "month";	
			myHorH2.categoryField = "date";
			/*myHorH2.dataUnits = "days";
			myHorH2.labelUnits = "days";
			myHorH2.parseFunction = myParseFunction;
			myHorH2.displayLocalTime = true;*/
			
			chart.verticalAxis = myHorH1;

			myVerV2.minimum = 20;
			myVerV2.maximum = 170;

			myVerV1.title = "close";
			myVerV2.title = "open";
			myVerV3.title = "high";
			myVerV4.title = "low";

			myHorAxisRenderer.axis = myHorH2;
			myHorAxisRenderer.placement = "left";		 	
			arrHorAxisRenderers.push(myHorAxisRenderer); 

			myVerAxisRenderer1.axis = myVerV2;
			myVerAxisRenderer1.placement = "bottom";
			arrVerAxisRenderers.push(myVerAxisRenderer1); 

			myVerAxisRenderer2.axis = myVerV3;
			myVerAxisRenderer2.placement = "top";
			arrVerAxisRenderers.push(myVerAxisRenderer2);

			myVerAxisRenderer3.axis = myVerV4;
			myVerAxisRenderer3.placement = "top";
			arrVerAxisRenderers.push(myVerAxisRenderer3);

			chart.horizontalAxis = myVerV1;

			chart.horizontalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);		 	
			chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrHorAxisRenderers);		 	

			closeBar.xField = "close";								
			closeBar.verticalAxis = myHorH1;			
			seriesArray.push(closeBar);

			openBar.xField = "open";
			//openBar.yField = "date"; 
			openBar.verticalAxis = myHorH2;
			openBar.horizontalAxis = myVerV1;
			seriesArray.push(openBar);				

			highBar.xField = "high";						
			highBar.verticalAxis = myHorH1;
			highBar.horizontalAxis = myVerV3;
			seriesArray.push(highBar);					

			lowBar.xField = "low";		
			lowBar.horizontalAxis = myVerV4;	
			seriesArray.push(lowBar);		

			chart.series = seriesArray;
		}
	}
}