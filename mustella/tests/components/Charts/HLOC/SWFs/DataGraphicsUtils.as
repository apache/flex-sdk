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
	import mx.controls.Alert;
	import mx.controls.Label;


	public class DataGraphicsUtils 
	{ 
	
	
		public function DataGraphicsUtils()
		{
		}

		public static function myParseFunction(s:String):Date 
		{ 
	  	  var a:Array = s.split(",");
		  var newDate:Date = new Date(a[0],a[1]-1,a[2]);
		  return newDate;
        	}
	
		public static function DrawShapes(testCaseType:String, chart:Object, elementType:String):void
		{
			var myCanvas:CartesianDataCanvas = new CartesianDataCanvas();
			switch(testCaseType)
			{	
				case "circle":	
				//draw circle
				myCanvas.clear();
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.drawCircle("1", 20,50);
				myCanvas.endFill();			
				break;

				case "line": 
				// draw line
				myCanvas.clear();
				myCanvas.moveTo("0", 200);
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.lineStyle(1, 0x003399, 1.0);
				myCanvas.lineTo("5", 30); 			
				break;

				case "rect":
				//rect with a label(component)
				myCanvas.clear();
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.drawRect("2", 20,"5",10);
				var myLabel:Label = new Label();
				myLabel.text = "Test";
				myCanvas.addChild(myLabel);
				myCanvas.updateDataChild(myLabel, "3", 40);
				myCanvas.endFill();			
				break;

				case "roundedRect":
				//rounded rect
				myCanvas.clear();
				myCanvas.beginFill(0x003399, 1);
				myCanvas.drawRoundedRect("4", 20,"5",10,15);
				myCanvas.endFill();        		
				break;

				case "ellipse":
				//ellipse
				myCanvas.clear();
				myCanvas.beginFill(0xFDCC34, 1);
				myCanvas.drawEllipse("1", 20,"4", 30);
				myCanvas.endFill();			
				break;

				case "curve":
				//curve
				myCanvas.clear();
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.curveTo("2", 25, "5", 30);
				myCanvas.endFill();			
				break;
			}

			switch(elementType)
			{
				case "annotation":
				chart.annotationElements = chart.annotationElements.concat(myCanvas);
				break;

				case "background":
				chart.backgroundElements = chart.backgroundElements.concat(myCanvas);
				break;			
			}
		}
	
		public static function DrawShapesWithNegativeVal(testCaseType:String, chart:Object, elementType:String):void
		{
			var myCanvas:CartesianDataCanvas = new CartesianDataCanvas();
			switch(testCaseType)
			{	
				case "circle":	
				// circle with negative value for radius
				myCanvas.clear();
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.drawCircle("2", 20,-50);
				myCanvas.endFill();
				chart.annotationElements = chart.annotationElements.concat(myCanvas);
				break;

				case "line": 
				// draw line with negative value in line style
				myCanvas.clear();
				myCanvas.moveTo("0", 20);
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.lineStyle(1, 0x003399, -1.0);
				myCanvas.lineTo("5", 30); 
				chart.annotationElements = chart.annotationElements.concat(myCanvas);
				break;

				case "rect":
				//rect with a label(component) with data coordinates that are not present in the chart
				myCanvas.clear();
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.drawRect("2", 200,"5",10);
				var myLabel:Label = new Label();
				myLabel.text = "Test";
				myCanvas.addChild(myLabel);
				myCanvas.updateDataChild(myLabel, "3", 40);
				myCanvas.endFill();
				chart.annotationElements = chart.annotationElements.concat(myCanvas);
				break;

				case "roundedRect":
				//rounded rect
				myCanvas.clear();
				myCanvas.beginFill(0x003399, 1);
				myCanvas.drawRoundedRect("5", 20,"6",10,15);
				myCanvas.endFill();
				chart.annotationElements = chart.annotationElements.concat(myCanvas);
				break;

				case "ellipse":
				//ellipse with negative rounded radius value
				myCanvas.clear();
				myCanvas.beginFill(0xFDCC34, 1);
				myCanvas.drawEllipse("1", 20,"4", -30);
				myCanvas.endFill();
				chart.annotationElements = chart.annotationElements.concat(myCanvas);
				break;

				case "curve":
				//curve 
				myCanvas.clear();
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.curveTo("0", 25, "5", 30);
				myCanvas.endFill();
				chart.annotationElements = chart.annotationElements.concat(myCanvas);
				break;
			}
			switch(elementType)
			{
				case "annotation":
				chart.annotationElements = chart.annotationElements.concat(myCanvas);
				break;

				case "background":
				chart.backgroundElements = chart.backgroundElements.concat(myCanvas);
				break;			
			}
		}

		public static function DrawWithCartesianCanvasValue(testCaseType:String, chart:Object, elementType:String):void
		{
			var myCanvas:CartesianDataCanvas = new CartesianDataCanvas();
			switch(testCaseType)
			{	
				case "circle":	
				// circle with 0 offset in CartesianCanvasValue
				myCanvas.clear();
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.drawCircle(new CartesianCanvasValue("2"), 20,50);
				myCanvas.endFill();			
				break;

				case "line": 
				// draw line 30 offset in CartesianCanvasValue in line style
				myCanvas.clear();
				myCanvas.moveTo("0", 20);
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.lineStyle(1, 0x003399, 1.0);
				myCanvas.lineTo(new CartesianCanvasValue("5", 30), 30); 			
				break;

				case "rect":
				//rect with a label(component) with data coordinates that are not present in the chart
				myCanvas.clear();
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.drawRect(new CartesianCanvasValue("2",5), 20,new CartesianCanvasValue("5",5),10);
				var myLabel:Label = new Label();
				myLabel.text = "Test";
				myCanvas.addChild(myLabel);
				myCanvas.updateDataChild(myLabel, "3", 40);
				myCanvas.endFill();			
				break;

				case "roundedRect":
				//rounded rect
				myCanvas.clear();
				myCanvas.beginFill(0x003399, 1);
				myCanvas.drawRoundedRect(new CartesianCanvasValue("3"), 20,new CartesianCanvasValue("5"),10,15);
				myCanvas.endFill();			
				break;

				case "ellipse":
				//ellipse with negative rounded radius value
				myCanvas.clear();
				myCanvas.beginFill(0xFDCC34, 1);
				myCanvas.drawEllipse(new CartesianCanvasValue("1",10), new CartesianCanvasValue(20,-10), new CartesianCanvasValue("4",10), new CartesianCanvasValue(30, 10));
				myCanvas.endFill();			
				break;

				case "curve":
				//curve 
				myCanvas.clear();
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.curveTo(new CartesianCanvasValue("0", 10), 25, new CartesianCanvasValue("5"), 30);
				myCanvas.endFill();			
				break;
			}
			switch(elementType)
			{
				case "annotation":
				chart.annotationElements = chart.annotationElements.concat(myCanvas);
				break;

				case "background":
				chart.backgroundElements = chart.backgroundElements.concat(myCanvas);
				break;			
			}
		}

		public static function DrawCanvasOnNegativeAxis(testCaseType:String, chart:Object, elementType:String):void
		{
			var myCanvas:CartesianDataCanvas = new CartesianDataCanvas();
			switch(testCaseType)
			{	
				case "circle":	
				// circle with 0 offset in CartesianCanvasValue
				myCanvas.clear();
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.drawCircle(new CartesianCanvasValue("2"), -20,50);
				myCanvas.endFill();
				break;

				case "line": 
				// draw line 30 offset in CartesianCanvasValue in line style
				myCanvas.clear();
				myCanvas.moveTo("0", -20);
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.lineStyle(1, 0x003399, 1.0);
				myCanvas.lineTo(new CartesianCanvasValue("5", 30), -30); 
				break;

				case "rect":
				//rect with a label(component) with data coordinates that are not present in the chart
				myCanvas.clear();
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.drawRect(new CartesianCanvasValue("2",5), -20,new CartesianCanvasValue("5",5),-10);
				var myLabel:Label = new Label();
				myLabel.text = "Test";
				myCanvas.addChild(myLabel);
				myCanvas.updateDataChild(myLabel, "3", -40);
				myCanvas.endFill();
				break;

				case "roundedRect":
				//rounded rect
				myCanvas.clear();
				myCanvas.beginFill(0x003399, 1);
				myCanvas.drawRoundedRect(new CartesianCanvasValue("3"), -20,new CartesianCanvasValue("5"),-10,15);
				myCanvas.endFill();
				break;

				case "ellipse":
				//ellipse with negative rounded radius value
				myCanvas.clear();
				myCanvas.beginFill(0xFDCC34, 1);
				myCanvas.drawEllipse(new CartesianCanvasValue("1",10), new CartesianCanvasValue(-20,-10), new CartesianCanvasValue("4",10), new CartesianCanvasValue(-30, 10));
				myCanvas.endFill();
				break;

				case "curve":
				//curve 
				myCanvas.clear();
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.curveTo(new CartesianCanvasValue("0", 10), -25, new CartesianCanvasValue("5"), -30);
				myCanvas.endFill();
				break;
			}
			switch(elementType)
			{
				case "annotation":
				chart.annotationElements = chart.annotationElements.concat(myCanvas);
				break;

				case "background":
				chart.backgroundElements = chart.backgroundElements.concat(myCanvas);
				break;			
			}
		}



		public static function DrawCanvasWithIncludeInRanges(testCaseType:String, chart:Object, elementType:String):void
		{
			var myCanvas:CartesianDataCanvas = new CartesianDataCanvas();
			switch(testCaseType)
			{	
				case "circle":	
				myCanvas.clear();
				myCanvas.includeInRanges=true;
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.drawCircle("1", 120,50);
				myCanvas.endFill();			
				break;

				case "line": 
				// draw line
				myCanvas.clear();
				myCanvas.includeInRanges=true;
				myCanvas.moveTo("0", 200);
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.lineStyle(1, 0x003399, 1.0);
				myCanvas.lineTo("5", 30); 
				break;

				case "rect":
				//rect with a label(component)
				myCanvas.clear();
				myCanvas.includeInRanges=true;
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.drawRect("2", 120,"5",100);
				var myLabel:Label = new Label();
				myLabel.text = "Test";
				myCanvas.addChild(myLabel);
				myCanvas.updateDataChild(myLabel, "3", 40);
				myCanvas.endFill();
				break;

				case "roundedRect":
				//rounded rect
				myCanvas.clear();
				myCanvas.includeInRanges=true;
				myCanvas.beginFill(0x003399, 1);
				myCanvas.drawRoundedRect("4", 20,"5",10,15);
				myCanvas.endFill();
				break;

				case "ellipse":
				//ellipse
				myCanvas.clear();
				myCanvas.includeInRanges=true;
				myCanvas.beginFill(0xFDCC34, 1);
				myCanvas.drawEllipse("1", 20,"4", 30);
				myCanvas.endFill();
				break;

				case "curve":
				//curve
				myCanvas.clear();
				myCanvas.includeInRanges=true;
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.curveTo("2", 25, "5", 30);
				myCanvas.endFill();
				break;
			}
			switch(elementType)
			{
				case "annotation":
				chart.annotationElements = chart.annotationElements.concat(myCanvas);
				break;

				case "background":
				chart.backgroundElements = chart.backgroundElements.concat(myCanvas);
				break;			
			}
		}

		public static function AddCompWithUpdateDataChild(testCaseType:String, chart:Object, elementType:String):void
		{
			var myCanvas:CartesianDataCanvas = new CartesianDataCanvas();
			var myLabel:Label = new Label();
			
			switch(testCaseType)
			{	
				case "1":
				myCanvas.clear();
				myCanvas.includeInRanges=true;					
				myLabel.text = "Test";
				myCanvas.addChild(myLabel);
				myCanvas.updateDataChild(myLabel, "2", 20, "4", 30, 3, 4);			
				break;

				case "2":
				myCanvas.clear();
				myCanvas.includeInRanges=true;					
				myLabel.text = "Test";
				myCanvas.addChild(myLabel);
				myCanvas.updateDataChild(myLabel, "3", 40, "5", 20, 1, 2);
				break;			

				case "3":
				myCanvas.clear();
				myCanvas.includeInRanges=true;					
				myLabel.text = "Test";
				myCanvas.addChild(myLabel);
				myCanvas.updateDataChild(myLabel, "3", 40, "2", 30, 0, 0);
				break;

				case "4":
				myCanvas.clear();
				myCanvas.includeInRanges=true;					
				myLabel.text = "Test";
				myCanvas.addChild(myLabel);
				myCanvas.updateDataChild(myLabel, "3", 40);
				break;

			}
			switch(elementType)
			{
				case "annotation":
				chart.annotationElements = chart.annotationElements.concat(myCanvas);
				break;

				case "background":
				chart.backgroundElements = chart.backgroundElements.concat(myCanvas);
				break;			
			}
		}

		public static function CanvasOnMultipleAxes(testCaseType:String, chart:Object, elementType:String):void
		{
			var myCanvas:CartesianDataCanvas = new CartesianDataCanvas();
			var myCanvas1:CartesianDataCanvas = new CartesianDataCanvas();
			var myCanvas2:CartesianDataCanvas = new CartesianDataCanvas();
			
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
			
			var closeCol1:ColumnSeries = new ColumnSeries();			
			var openLine:LineSeries = new LineSeries();	
			var highLine:LineSeries = new LineSeries();
			var lowPlot:PlotSeries = new PlotSeries();

			switch(testCaseType)
			{	
				case "axisSet":
				// axis set for canvas				
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
				
				myVerAxisRenderer.axis = myVerV1;
				myVerAxisRenderer.placement = "left";
				arrVerAxisRenderers.push(myVerAxisRenderer); 		
				
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
									
				closeCol1.yField = "close";								
				closeCol1.horizontalAxis = myHorH1;			
				seriesArray.push(closeCol1);
				
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

				myCanvas.clear();
				myCanvas.horizontalAxis = myHorH1;
				myCanvas.verticalAxis = myVerV4;
				myCanvas.includeInRanges=true;
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.drawCircle("Jul", 120,50);
				myCanvas.endFill();	
				
				break;			

				case "axisNotSet":
				// canvas axis when not specified takes primary axes				
				
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
				
				myVerAxisRenderer.axis = myVerV1;
				myVerAxisRenderer.placement = "left";
				arrVerAxisRenderers.push(myVerAxisRenderer); 		
				
				myVerAxisRenderer1.axis = myVerV2;
				myVerAxisRenderer1.placement = "right";
				arrVerAxisRenderers.push(myVerAxisRenderer1); 

				chart.verticalAxis = myVerV1;

				chart.horizontalAxisRenderers = chart.horizontalAxisRenderers.concat(arrHorAxisRenderers);		 	
				chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);
				
				closeCol1.yField = "close";								
				closeCol1.horizontalAxis = myHorH1;			
				seriesArray.push(closeCol1);
				
				openLine.yField = "open";
				openLine.xField = "date"; 
				openLine.horizontalAxis = myHorH2;
				openLine.verticalAxis = myVerV2;
				seriesArray.push(openLine);			

				chart.series = seriesArray;

				myCanvas.clear();
				myCanvas.horizontalAxis = myHorH1;
				myCanvas.verticalAxis = myVerV2;
				myCanvas.includeInRanges=true;
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.drawCircle("Jul", 120,50);
				myCanvas.endFill();

				myCanvas1.clear();
				myCanvas1.includeInRanges=true;
				myCanvas1.moveTo("Jul", 200);
				myCanvas1.beginFill(0xFFCC04, 1);
				myCanvas1.lineStyle(1, 0x003399, 1.0);
				myCanvas1.lineTo("Jun", 30);
				
				break;

				case "multipleCanvas":
				//multiple canvas with multiple axes				
				myHorH1.categoryField = "month";				
				myHorH2.categoryField = "date";						
				chart.horizontalAxis = myHorH1;

				myVerV2.minimum = 20;
				myVerV2.maximum = 170;

				myVerV1.title = "close";
				myVerV2.title = "open";	
				
				myHorAxisRenderer.axis = myHorH2;
				myHorAxisRenderer.placement = "top";		 	
				arrHorAxisRenderers.push(myHorAxisRenderer); 

				myHorAxisRenderer1.axis = myHorH1;
				myHorAxisRenderer1.placement = "bottom";		 	
				arrHorAxisRenderers.push(myHorAxisRenderer1); 
				
				myVerAxisRenderer.axis = myVerV1;
				myVerAxisRenderer.placement = "left";
				arrVerAxisRenderers.push(myVerAxisRenderer); 	
				
				myVerAxisRenderer1.axis = myVerV2;
				myVerAxisRenderer1.placement = "right";
				arrVerAxisRenderers.push(myVerAxisRenderer1); 

				chart.verticalAxis = myVerV1;

				chart.horizontalAxisRenderers = chart.horizontalAxisRenderers.concat(arrHorAxisRenderers);		 	
				chart.verticalAxisRenderers = chart.verticalAxisRenderers.concat(arrVerAxisRenderers);	
								
				closeCol1.yField = "close";								
				closeCol1.horizontalAxis = myHorH1;			
				seriesArray.push(closeCol1);
				
				openLine.yField = "open";
				openLine.xField = "date"; 
				openLine.horizontalAxis = myHorH2;
				openLine.verticalAxis = myVerV2;
				seriesArray.push(openLine);			

				chart.series = seriesArray;

				myCanvas.clear();
				myCanvas.horizontalAxis = myHorH1;
				myCanvas.verticalAxis = myVerV2;
				myCanvas.includeInRanges=true;
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.drawCircle("Nov", 100,50);
				myCanvas.endFill();

				myCanvas1.clear();
				myCanvas1.includeInRanges=true;
				myCanvas.horizontalAxis = myHorH2;
				myCanvas.verticalAxis = myVerV1;
				myCanvas1.moveTo("Jul", 200);
				myCanvas1.beginFill(0xFFCC04, 1);
				myCanvas1.lineStyle(1, 0x003399, 1.0);
				myCanvas1.lineTo("Jun", 30); 
				break;				

			}
			switch(elementType)
			{
				case "annotation":
				chart.annotationElements = chart.annotationElements.concat(myCanvas);
				chart.annotationElements = chart.annotationElements.concat(myCanvas1);
				break;

				case "background":
				chart.backgroundElements = chart.backgroundElements.concat(myCanvas);
				chart.backgroundElements = chart.backgroundElements.concat(myCanvas1);
				break;			
			}
		}


	}
}
