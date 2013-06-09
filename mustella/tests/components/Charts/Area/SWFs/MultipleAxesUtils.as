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
			var myHorH2:DateTimeAxis = new DateTimeAxis();
			
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
			
			var closeArea1:AreaSeries = new AreaSeries();
			var openLine:LineSeries = new LineSeries();	
			var highLine:LineSeries = new LineSeries();
			var lowPlot:PlotSeries = new PlotSeries();
			
			
			switch(testCaseType)
			{	
				case "noAxisSpecified":	
				
					myHorH1.categoryField = "month";			
					chart.horizontalAxis = myHorH1;

					closeArea1.yField = "close";
					closeArea1.xField = "month";						
					seriesArray.push(closeArea1);

					openLine.yField = "open";
					openLine.xField = "month"; 			
					seriesArray.push(openLine);	

					highLine.yField = "high";
					highLine.xField = "month";					
					seriesArray.push(highLine);

					lowPlot.yField = "low";
					lowPlot.xField = "month";			
					seriesArray.push(lowPlot);	

					chart.series = seriesArray;			
					break;

				case "axisAtSeries":
				
					myHorH1.categoryField = "month";				

					myHorH2.dataUnits = "days";
					myHorH2.labelUnits = "days";
					myHorH2.parseFunction = myParseFunction;
					myHorH2.displayLocalTime = true;

					chart.horizontalAxis = myHorH1;								

					myVerV2.minimum = 20;
					myVerV2.maximum = 170;

					myHorAxisRenderer.axis = myHorH2;
					myHorAxisRenderer.placement = "top";		 	
					arrHorAxisRenderers.push(myHorAxisRenderer); 		 

					chart.verticalAxis = myVerV1;

					myVerAxisRenderer1.axis = myVerV2;
					myVerAxisRenderer1.placement = "right";
					arrVerAxisRenderers.push(myVerAxisRenderer1); 

					chart.horizontalAxisRenderers = chart.horizontalAxisRenderers.concat(arrHorAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);	

					closeArea1.yField = "close";							
					seriesArray.push(closeArea1);

					openLine.yField = "open";
					openLine.xField = "date"; 
					openLine.horizontalAxis = myHorH2;
					seriesArray.push(openLine);	

					highLine.yField = "high";						
					highLine.verticalAxis = myVerV2;
					seriesArray.push(highLine);	

					lowPlot.yField = "low";						
					seriesArray.push(lowPlot);		

					chart.series = seriesArray;				
					break;

				case "noAxisRenderers":		
				
					myHorH1.categoryField = "month";								
					chart.horizontalAxis = myHorH1;

					myVerV2.minimum = 20;
					myVerV2.maximum = 170;						

					chart.verticalAxis = myVerV1;

					closeArea1.yField = "close";						
					seriesArray.push(closeArea1);

					openLine.yField = "open";
					openLine.xField = "date"; 						
					seriesArray.push(openLine);

					highLine.yField = "high";						
					seriesArray.push(highLine);

					lowPlot.yField = "low";			
					seriesArray.push(lowPlot);		

					chart.series = seriesArray;	
					break;
				
				
				case "axisRendererWithPlacement":
					
					myHorH1.categoryField = "month";

					myHorH2.dataUnits = "days";
					myHorH2.labelUnits = "days";
					myHorH2.parseFunction = myParseFunction;
					myHorH2.displayLocalTime = true;

					chart.horizontalAxis = myHorH1;					

					myVerV2.minimum = 20;
					myVerV2.maximum = 170;

					myVerV1.title = "close";
					myVerV2.title = "open";
					myVerV3.title = "high";
					myVerV4.title = "low";

					myHorAxisRenderer.axis = myHorH2;
					myHorAxisRenderer.placement = "top";		 	
					arrHorAxisRenderers.push(myHorAxisRenderer); 

					myVerAxisRenderer1.axis = myVerV2;
					myVerAxisRenderer1.placement = "right";
					arrVerAxisRenderers.push(myVerAxisRenderer1); 

					myVerAxisRenderer2.axis = myVerV3;
					myVerAxisRenderer2.placement = "right";
					arrVerAxisRenderers.push(myVerAxisRenderer2);

					myVerAxisRenderer3.axis = myVerV4;
					myVerAxisRenderer3.placement = "left";
					arrVerAxisRenderers.push(myVerAxisRenderer3);

					chart.verticalAxis = myVerV1;

					chart.horizontalAxisRenderers = chart.horizontalAxisRenderers.concat(arrHorAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);	

					closeArea1.yField = "close";								
					closeArea1.horizontalAxis = myHorH1;			
					seriesArray.push(closeArea1);

					openLine.yField = "open";
					openLine.xField = "date"; 
					openLine.horizontalAxis = myHorH2;
					openLine.verticalAxis = myVerV2;
					seriesArray.push(openLine);	

					highLine.yField = "high";						
					highLine.horizontalAxis = myHorH1;
					highLine.verticalAxis = myVerV3;
					seriesArray.push(highLine);	

					lowPlot.yField = "low";		
					lowPlot.verticalAxis = myVerV4;	
					seriesArray.push(lowPlot);		

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
			
			var closeArea1:AreaSeries = new AreaSeries();
			var openLine:LineSeries = new LineSeries();
			var highLine:LineSeries = new LineSeries();
			var lowPlot:PlotSeries = new PlotSeries();
			
			
			switch(testCaseType)
			{	
				case "setAxis":
				
					myHorH1.categoryField = "month";				
					myHorH2.categoryField = "date";						
					chart.horizontalAxis = myHorH1;

					myVerV2.title = "Open";
					myVerV2.minimum = 20;
					myVerV2.maximum = 170;						

					chart.verticalAxis = myVerV1;

					closeArea1.yField = "close";						
					seriesArray.push(closeArea1);

					openLine.yField = "open";			 	
					openLine.dataTransform.setAxis(CartesianTransform.VERTICAL_AXIS, myVerV2);
					seriesArray.push(openLine);	

					highLine.yField = "high";						
					seriesArray.push(highLine);	

					lowPlot.yField = "low";			
					seriesArray.push(lowPlot);		

					chart.series = seriesArray;	
					break;

				case "validHorVerAxis":
							
					myHorH1.categoryField = "month";		
					myHorH2.categoryField = "date";						
					chart.horizontalAxis = myHorH1;

					myVerV2.minimum = 20;
					myVerV2.maximum = 170;

					myVerV1.title = "close";
					myVerV2.title = "open";
					myVerV3.title = "high";
					myVerV4.title = "low";

					myHorAxisRenderer.axis = myHorH2;
					myHorAxisRenderer.placement = "top";		 	
					arrHorAxisRenderers.push(myHorAxisRenderer); 

					myHorAxisRenderer1.axis = myHorH1;
					myHorAxisRenderer1.placement = "bottom";		 	
					arrHorAxisRenderers.push(myHorAxisRenderer1); 				

					myVerAxisRenderer1.axis = myVerV2;
					myVerAxisRenderer1.placement = "right";
					arrVerAxisRenderers.push(myVerAxisRenderer1); 

					myVerAxisRenderer2.axis = myVerV3;
					myVerAxisRenderer2.placement = "right";
					arrVerAxisRenderers.push(myVerAxisRenderer2);

					myVerAxisRenderer3.axis = myVerV4;
					myVerAxisRenderer3.placement = "left";
					arrVerAxisRenderers.push(myVerAxisRenderer3);

					chart.verticalAxis = myVerV1;

					chart.horizontalAxisRenderers = chart.horizontalAxisRenderers.concat(arrHorAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);		 	

					closeArea1.yField = "close";								
					closeArea1.horizontalAxis = myHorH1;			
					seriesArray.push(closeArea1);

					openLine.yField = "open";
					openLine.xField = "date"; 
					openLine.horizontalAxis = myHorH2;
					openLine.verticalAxis = myVerV2;
					seriesArray.push(openLine);	

					highLine.yField = "high";						
					highLine.horizontalAxis = myHorH1;
					highLine.verticalAxis = myVerV3;
					seriesArray.push(highLine);	

					lowPlot.yField = "low";		
					lowPlot.verticalAxis = myVerV4;	
					seriesArray.push(lowPlot);		

					chart.series = seriesArray;			
					break;


				case "diffAxisType":
					//test with all types of axis(log, dateTime)

					myHorH11.dataUnits = "days";
					myHorH11.labelUnits = "days";
					myHorH11.parseFunction = myParseFunction;
					myHorH11.displayLocalTime = true;

					chart.horizontalAxis = myHorH11;								

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

					chart.verticalAxis = myVerV1;

					chart.horizontalAxisRenderers = chart.horizontalAxisRenderers.concat(arrHorAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);		 	

					closeArea1.yField = "close";
					closeArea1.xField = "date";
					closeArea1.horizontalAxis = myHorH11;			
					seriesArray.push(closeArea1);

					openLine.yField = "open";
					openLine.xField = "date";
					openLine.verticalAxis = myVerV21;
					seriesArray.push(openLine);	

					chart.series = seriesArray;			
					break;

				case "disabledDays":
					//disabled days and ranges				
					myHorH11.dataUnits = "days";
					myHorH11.labelUnits = "days";
					myHorH11.parseFunction = myParseFunction;
					myHorH11.displayLocalTime = true;
					myHorH11.disabledDays = [0];

					chart.horizontalAxis = myHorH11;								

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

					chart.verticalAxis = myVerV1;

					chart.horizontalAxisRenderers = chart.horizontalAxisRenderers.concat(arrHorAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);		 	

					closeArea1.yField = "close";
					closeArea1.xField = "date";
					closeArea1.horizontalAxis = myHorH11;			
					seriesArray.push(closeArea1);

					openLine.yField = "open";
					openLine.xField = "date";
					openLine.verticalAxis = myVerV21;				
					seriesArray.push(openLine);	

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
			var myHorH2:DateTimeAxis = new DateTimeAxis();
			
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

			var closeArea1:AreaSeries = new AreaSeries();
			var openLine:LineSeries = new LineSeries();
			var highLine:LineSeries = new LineSeries();
			var lowPlot:PlotSeries = new PlotSeries();			
			
			switch(testCaseType)
			{	
				case "multipleLeftAndTop":				
					myHorH1.categoryField = "month";	

					myHorH2.dataUnits = "days";
					myHorH2.labelUnits = "days";
					myHorH2.parseFunction = myParseFunction;
					myHorH2.displayLocalTime = true;					
					chart.horizontalAxis = myHorH1;

					myVerV2.minimum = 20;
					myVerV2.maximum = 170;

					myVerV1.title = "close";
					myVerV2.title = "open";
					myVerV3.title = "high";
					myVerV4.title = "low";

					myHorAxisRenderer.axis = myHorH2;
					myHorAxisRenderer.placement = "top";		 	
					arrHorAxisRenderers.push(myHorAxisRenderer); 

					myVerAxisRenderer1.axis = myVerV2;
					myVerAxisRenderer1.placement = "left";
					arrVerAxisRenderers.push(myVerAxisRenderer1); 

					myVerAxisRenderer2.axis = myVerV3;
					myVerAxisRenderer2.placement = "left";
					arrVerAxisRenderers.push(myVerAxisRenderer2);

					myVerAxisRenderer3.axis = myVerV4;
					myVerAxisRenderer3.placement = "left";
					arrVerAxisRenderers.push(myVerAxisRenderer3);

					chart.verticalAxis = myVerV1;

					chart.horizontalAxisRenderers = chart.horizontalAxisRenderers.concat(arrHorAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);	

					closeArea1.yField = "close";								
					closeArea1.horizontalAxis = myHorH1;			
					seriesArray.push(closeArea1);

					openLine.yField = "open";
					openLine.xField = "date"; 
					openLine.horizontalAxis = myHorH2;
					openLine.verticalAxis = myVerV2;
					seriesArray.push(openLine);	

					highLine.yField = "high";						
					highLine.horizontalAxis = myHorH1;
					highLine.verticalAxis = myVerV3;
					seriesArray.push(highLine);

					lowPlot.yField = "low";		
					lowPlot.verticalAxis = myVerV4;	
					seriesArray.push(lowPlot);		

					chart.series = seriesArray;				
					break;

				case "multipleBottomAndRight":				
				
					myHorH1.categoryField = "month";

					myHorH2.dataUnits = "days";
					myHorH2.labelUnits = "days";
					myHorH2.parseFunction = myParseFunction;
					myHorH2.displayLocalTime = true;						
					chart.horizontalAxis = myHorH1;

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
					myVerAxisRenderer1.placement = "right";
					arrVerAxisRenderers.push(myVerAxisRenderer1); 

					myVerAxisRenderer2.axis = myVerV3;
					myVerAxisRenderer2.placement = "right";
					arrVerAxisRenderers.push(myVerAxisRenderer2);

					myVerAxisRenderer3.axis = myVerV4;
					myVerAxisRenderer3.placement = "right";
					arrVerAxisRenderers.push(myVerAxisRenderer3);

					chart.verticalAxis = myVerV1;

					chart.horizontalAxisRenderers = chart.horizontalAxisRenderers.concat(arrHorAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);		 	

					closeArea1.yField = "close";								
					closeArea1.horizontalAxis = myHorH1;			
					seriesArray.push(closeArea1);

					openLine.yField = "open";
					openLine.xField = "date"; 
					openLine.horizontalAxis = myHorH2;
					openLine.verticalAxis = myVerV2;
					seriesArray.push(openLine);				

					highLine.yField = "high";						
					highLine.horizontalAxis = myHorH1;
					highLine.verticalAxis = myVerV3;
					seriesArray.push(highLine);					

					lowPlot.yField = "low";		
					lowPlot.verticalAxis = myVerV4;	
					seriesArray.push(lowPlot);		

					chart.series = seriesArray;				
					break;

				case "noVerPlacementSpecified":
				
					myHorH1.categoryField = "month";				
					myHorH2.dataUnits = "days";
					myHorH2.labelUnits = "days";
					myHorH2.parseFunction = myParseFunction;
					myHorH2.displayLocalTime = true;						
					chart.horizontalAxis = myHorH1;

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

					chart.verticalAxis = myVerV1;

					chart.horizontalAxisRenderers = chart.horizontalAxisRenderers.concat(arrHorAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);	

					closeArea1.yField = "close";								
					closeArea1.horizontalAxis = myHorH1;			
					seriesArray.push(closeArea1);

					openLine.yField = "open";
					openLine.xField = "date"; 
					openLine.horizontalAxis = myHorH2;
					openLine.verticalAxis = myVerV2;
					seriesArray.push(openLine);	

					highLine.yField = "high";						
					highLine.horizontalAxis = myHorH1;
					highLine.verticalAxis = myVerV3;
					seriesArray.push(highLine);		

					lowPlot.yField = "low";		
					lowPlot.verticalAxis = myVerV4;	
					seriesArray.push(lowPlot);		

					chart.series = seriesArray;				
					break;

				case "noPlacementSpecified":				
			
					myHorH1.categoryField = "month";				
					myHorH2.dataUnits = "days";
					myHorH2.labelUnits = "days";
					myHorH2.parseFunction = myParseFunction;
					myHorH2.displayLocalTime = true;						
					chart.horizontalAxis = myHorH1;

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

					chart.verticalAxis = myVerV1;

					chart.horizontalAxisRenderers = chart.horizontalAxisRenderers.concat(arrHorAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);		

					closeArea1.yField = "close";								
					closeArea1.horizontalAxis = myHorH1;			
					seriesArray.push(closeArea1);

					openLine.yField = "open";
					openLine.xField = "date"; 
					openLine.horizontalAxis = myHorH2;
					openLine.verticalAxis = myVerV2;
					seriesArray.push(openLine);	

					highLine.yField = "high";						
					highLine.horizontalAxis = myHorH1;
					highLine.verticalAxis = myVerV3;
					seriesArray.push(highLine);	

					lowPlot.yField = "low";		
					lowPlot.verticalAxis = myVerV4;	
					seriesArray.push(lowPlot);		

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
			var myHorH2:DateTimeAxis = new DateTimeAxis();

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

			var closeArea1:AreaSeries = new AreaSeries();
			var openLine:LineSeries = new LineSeries();
			var highLine:LineSeries = new LineSeries();
			var lowPlot:PlotSeries = new PlotSeries();
			
			switch(testCaseType)
			{	
				case "sameAxisOnDiffRenderers":						
					myHorH1.categoryField = "month";

					myHorH2.dataUnits = "days";
					myHorH2.labelUnits = "days";
                    myHorH2.minimum = new Date(2007, 6, 20);
                    myHorH2.maximum = new Date(2007, 6, 20);
					myHorH2.parseFunction = myParseFunction;
					myHorH2.displayLocalTime = true;

					chart.horizontalAxis = myHorH1;				

					myVerV2.minimum = 20;
					myVerV2.maximum = 170;

					myVerV1.title = "close";
					myVerV2.title = "open";
					myVerV3.title = "high";			

					myHorAxisRenderer.axis = myHorH2;
					myHorAxisRenderer.placement = "top";		 	
					arrHorAxisRenderers.push(myHorAxisRenderer); 				

					myVerAxisRenderer.axis = myVerV2;
					myVerAxisRenderer.placement = "right";
					arrVerAxisRenderers.push(myVerAxisRenderer);			

					myVerAxisRenderer2.axis = myVerV3;
					myVerAxisRenderer2.placement = "right";
					arrVerAxisRenderers.push(myVerAxisRenderer2);

					myVerAxisRenderer3.axis = myVerV3;
					myVerAxisRenderer3.placement = "right";
					arrVerAxisRenderers.push(myVerAxisRenderer3);

					chart.verticalAxis = myVerV1;

					chart.horizontalAxisRenderers = chart.horizontalAxisRenderers.concat(arrHorAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);		 	

					closeArea1.yField = "close";								
					closeArea1.horizontalAxis = myHorH1;			
					seriesArray.push(closeArea1);

					openLine.yField = "open";						
					openLine.verticalAxis = myVerV2;
					seriesArray.push(openLine);				

					highLine.yField = "high";				
					highLine.verticalAxis = myVerV3;
					seriesArray.push(highLine);					

					lowPlot.yField = "low";						
					seriesArray.push(lowPlot);	
					chart.series = seriesArray;				
					break;

				case "sameRendererWithDiffAxis":
				
					myHorH1.categoryField = "month";
					chart.horizontalAxis = myHorH1;

					myVerV2.minimum = 20;
					myVerV2.maximum = 170;

					myVerV1.title = "close";
					myVerV2.title = "open";
					myVerV3.title = "high";

					myHorAxisRenderer1.axis = myHorH1;
					myHorAxisRenderer1.placement = "top";		 	
					arrHorAxisRenderers.push(myHorAxisRenderer1);

					myVerAxisRenderer1.axis = myVerV2;
					myVerAxisRenderer1.placement = "left";
					arrVerAxisRenderers.push(myVerAxisRenderer1); 

					myVerAxisRenderer2.axis = myVerV3;
					myVerAxisRenderer2.placement = "right";
					arrVerAxisRenderers.push(myVerAxisRenderer2);

					myVerAxisRenderer3.axis = myVerV3;
					myVerAxisRenderer3.placement = "right";
					arrVerAxisRenderers.push(myVerAxisRenderer3);

					chart.verticalAxis = myVerV1;

					chart.horizontalAxisRenderers = chart.horizontalAxisRenderers.concat(arrHorAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);		 	

					closeArea1.yField = "close";								
					closeArea1.horizontalAxis = myHorH1;			
					seriesArray.push(closeArea1);

					openLine.yField = "open";						
					openLine.verticalAxis = myVerV2;
					seriesArray.push(openLine);				

					highLine.yField = "high";				
					highLine.verticalAxis = myVerV3;
					seriesArray.push(highLine);					

					lowPlot.yField = "low";						
					seriesArray.push(lowPlot);	
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
			var myHorH2:DateTimeAxis = new DateTimeAxis();
			
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

			var closeArea1:AreaSeries = new AreaSeries();
			var openLine:LineSeries = new LineSeries();
			var highLine:LineSeries = new LineSeries();
			var lowPlot:PlotSeries = new PlotSeries();
			
			switch(testCaseType)
			{	
				case "validLabelFunction":				
					myHorH1.categoryField = "month";				
					myHorH2.dataUnits = "days";
					myHorH2.labelUnits = "days";
					myHorH2.parseFunction = myParseFunction;
					myHorH2.displayLocalTime = true;						
					chart.horizontalAxis = myHorH1;

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
					myVerAxisRenderer1.placement = "right";
					arrVerAxisRenderers.push(myVerAxisRenderer1); 

					myVerAxisRenderer2.axis = myVerV3;
					myVerAxisRenderer2.placement = "right";
					arrVerAxisRenderers.push(myVerAxisRenderer2);

					myVerAxisRenderer3.axis = myVerV4;
					myVerAxisRenderer3.placement = "left";
					myVerAxisRenderer3.labelFunction = myLabelFunction;
					arrVerAxisRenderers.push(myVerAxisRenderer3);

					chart.verticalAxis = myVerV1;

					chart.horizontalAxisRenderers = chart.horizontalAxisRenderers.concat(arrHorAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);		 	

					closeArea1.yField = "close";								
					closeArea1.horizontalAxis = myHorH1;			
					seriesArray.push(closeArea1);

					openLine.yField = "open";
					openLine.xField = "date"; 
					openLine.horizontalAxis = myHorH2;
					openLine.verticalAxis = myVerV2;
					seriesArray.push(openLine);				

					highLine.yField = "high";						
					highLine.horizontalAxis = myHorH1;
					highLine.verticalAxis = myVerV3;
					seriesArray.push(highLine);					

					lowPlot.yField = "low";		
					lowPlot.verticalAxis = myVerV4;	
					seriesArray.push(lowPlot);		

					chart.series = seriesArray;				
					break;

				case "labelFnDiffAxisType":		

					var myHorH11:DateTimeAxis = new DateTimeAxis();
					myHorH11.dataUnits = "days";
					myHorH11.labelUnits = "days";
					myHorH11.parseFunction = myParseFunction;
					myHorH11.displayLocalTime = true;

					chart.horizontalAxis = myHorH11;	

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

					chart.verticalAxis = myVerV1;

					chart.horizontalAxisRenderers = chart.horizontalAxisRenderers.concat(arrHorAxisRenderers);		 	
					chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);		 	

					closeArea1.yField = "close";	
					closeArea1.xField = "date";
					closeArea1.horizontalAxis = myHorH11;			
					seriesArray.push(closeArea1);

					openLine.yField = "open";	
					openLine.xField = "date";
					openLine.verticalAxis = myVerV1;
					seriesArray.push(openLine);

					chart.series = seriesArray;						
					break;

				case "labelFnOnDeprecatedProperty":		
				
					chart.verticalAxisRenderer.labelFunction = myLabelFunction;
					closeArea1.yField = "close";						
					seriesArray.push(closeArea1);
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
			var myHorH2:DateTimeAxis = new DateTimeAxis();			
			
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

			var closeArea1:AreaSeries = new AreaSeries();
			var openLine:LineSeries = new LineSeries();
			var highLine:LineSeries = new LineSeries();
			var lowPlot:PlotSeries = new PlotSeries();
			
			myHorH1.categoryField = "month";			
			myHorH2.dataUnits = "days";
			myHorH2.labelUnits = "days";
			myHorH2.parseFunction = myParseFunction;
			myHorH2.displayLocalTime = true;					
			chart.horizontalAxis = myHorH1;

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
			myVerAxisRenderer1.placement = "right";
			arrVerAxisRenderers.push(myVerAxisRenderer1); 

			myVerAxisRenderer2.axis = myVerV3;
			myVerAxisRenderer2.placement = "right";
			arrVerAxisRenderers.push(myVerAxisRenderer2);

			myVerAxisRenderer3.axis = myVerV4;
			myVerAxisRenderer3.placement = "right";
			arrVerAxisRenderers.push(myVerAxisRenderer3);

			chart.verticalAxis = myVerV1;

			chart.horizontalAxisRenderers = chart.horizontalAxisRenderers.concat(arrHorAxisRenderers);		 	
			chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);		 	

			closeArea1.yField = "close";								
			closeArea1.horizontalAxis = myHorH1;			
			seriesArray.push(closeArea1);

			openLine.yField = "open";
			openLine.xField = "date"; 
			openLine.horizontalAxis = myHorH2;
			openLine.verticalAxis = myVerV2;
			seriesArray.push(openLine);				

			highLine.yField = "high";						
			highLine.horizontalAxis = myHorH1;
			highLine.verticalAxis = myVerV3;
			seriesArray.push(highLine);					

			lowPlot.yField = "low";		
			lowPlot.verticalAxis = myVerV4;	
			seriesArray.push(lowPlot);		

			chart.series = seriesArray;
		}
	}
}