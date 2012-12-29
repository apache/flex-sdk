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
	import mx.controls.Label;


	public class DataGraphicsUtils 
	{ 	
		public function DataGraphicsUtils()
		{
		}
	
		public static function DrawShapesWithTotalValSet(testCaseType:String, chart:Object, elementType:String):void
		{
			var myCanvas:PolarDataCanvas = new PolarDataCanvas();
			switch(testCaseType)
			{	
				case "circle":	
				//draw circle
				myCanvas.clear();
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.drawCircle(0,40,50);
	       			myCanvas.endFill();			
				break;

				case "line": 
				// draw line
				myCanvas.clear();
				myCanvas.moveTo(0, 10);
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.lineStyle(1, 0x003399, 1.0);
				myCanvas.lineTo(20, 80); 		
				break;

				case "rect":
				//rect with a label(component)
				myCanvas.clear();
				myCanvas.beginFill(0x003399, 1);
				myCanvas.drawRect(20, 120,30,150);
				var myLabel:Label = new Label();
				myLabel.text = "Test";
				myCanvas.addChild(myLabel);
				myCanvas.updateDataChild(myLabel, 30,50);
				myCanvas.endFill();		
				break;

				case "roundedRect":
				//rounded rect
				myCanvas.clear();
				myCanvas.beginFill(0x003399, 1);
				myCanvas.drawRoundedRect(20, 60,30,80,15);
				myCanvas.endFill();    		
				break;

				case "ellipse":
				//ellipse
				myCanvas.clear();
				myCanvas.beginFill(0xFDCC34, 1);
				myCanvas.drawEllipse(20, 60,30,80);
				myCanvas.endFill();		
				break;

				case "curve":
				//curve
				myCanvas.clear();
	       	 		myCanvas.beginFill(0xFFCC04, 1);
	          		myCanvas.curveTo(20, 6,10,20);
	           		myCanvas.endFill();			
				break;
			}
			myCanvas.totalValue=1000;
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
		
		public static function DrawShapesWithTotalValNotSet(testCaseType:String, chart:Object, elementType:String):void
		{
			var myCanvas:PolarDataCanvas = new PolarDataCanvas();
			switch(testCaseType)
			{	
				case "circle":	
				//draw circle
				myCanvas.clear();
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.drawCircle(0,40,50);
				myCanvas.endFill();			
				break;

				case "line": 
				// draw line
				myCanvas.clear();
				myCanvas.moveTo(0, 10);
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.lineStyle(1, 0x003399, 1.0);
				myCanvas.lineTo(20, 80); 		
				break;

				case "rect":
				//rect with a label(component)
				myCanvas.clear();
				myCanvas.beginFill(0x003399, 1);
				myCanvas.drawRect(20, 120,30,150);
				var myLabel:Label = new Label();
				myLabel.text = "Test";
				myCanvas.addChild(myLabel);
				myCanvas.updateDataChild(myLabel, 30,50);
				myCanvas.endFill();		
				break;

				case "roundedRect":
				//rounded rect
				myCanvas.clear();
				myCanvas.beginFill(0x003399, 1);
				myCanvas.drawRoundedRect(20, 60,30,80,15);
				myCanvas.endFill();    		
				break;

				case "ellipse":
				//ellipse
				myCanvas.clear();
				myCanvas.beginFill(0xFDCC34, 1);
				myCanvas.drawEllipse(20, 60,30,80);
				myCanvas.endFill();		
				break;

				case "curve":
				//curve
				myCanvas.clear();
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.curveTo(20, 6,10,20);
				myCanvas.endFill();			
				break;
			}
			myCanvas.includeInRanges = true;
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
			var myCanvas:PolarDataCanvas = new PolarDataCanvas();
			switch(testCaseType)
			{	
				case "circle":	
				//draw circle
				myCanvas.clear();
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.drawCircle(0,40,-50);
				myCanvas.endFill();			
				break;

				case "line": 
				// draw line
				myCanvas.clear();
				myCanvas.moveTo(0, 10);
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.lineStyle(1, 0x003399, -1.0);
				myCanvas.lineTo(20, 80); 		
				break;

				case "rect":
				//rect with a label(component)
				myCanvas.clear();
				myCanvas.beginFill(0x003399, 1);
				myCanvas.drawRect(20, 120,30,-150);
				var myLabel:Label = new Label();
				myLabel.text = "Test";
				myCanvas.addChild(myLabel);
				myCanvas.updateDataChild(myLabel, 30,50);
				myCanvas.endFill();		
				break;

				case "roundedRect":
				//rounded rect
				myCanvas.clear();
				myCanvas.beginFill(0x003399, 1);
				myCanvas.drawRoundedRect(20, 60,30,80,-15);
				myCanvas.endFill();    		
				break;

				case "ellipse":
				//ellipse
				myCanvas.clear();
				myCanvas.beginFill(0xFDCC34, 1);
				myCanvas.drawEllipse(20, 60,-30,80);
				myCanvas.endFill();		
				break;

				case "curve":
				//curve
				myCanvas.clear();
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.curveTo(20, 6,10,-20);
				myCanvas.endFill();			
				break;
			}
			myCanvas.totalValue=1000;
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
			var myCanvas:PolarDataCanvas = new PolarDataCanvas();
			switch(testCaseType)
			{	
				case "circle":	
				//draw circle
				myCanvas.clear();
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.drawCircle(0,40,50);
				myCanvas.endFill();			
				break;

				case "line": 
				// draw line
				myCanvas.clear();
				myCanvas.moveTo(0, 10);
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.lineStyle(1, 0x003399, 1.0);
				myCanvas.lineTo(20, 80); 		
				break;

				case "rect":
				//rect with a label(component)
				myCanvas.clear();
				myCanvas.beginFill(0x003399, 1);
				myCanvas.drawRect(20, 120,30,150);
				var myLabel:Label = new Label();
				myLabel.text = "Test";
				myCanvas.addChild(myLabel);
				myCanvas.updateDataChild(myLabel, 30,50);
				myCanvas.endFill();		
				break;

				case "roundedRect":
				//rounded rect
				myCanvas.clear();
				myCanvas.beginFill(0x003399, 1);
				myCanvas.drawRoundedRect(20, 60,30,80,15);
				myCanvas.endFill();    		
				break;

				case "ellipse":
				//ellipse
				myCanvas.clear();
				myCanvas.beginFill(0xFDCC34, 1);
				myCanvas.drawEllipse(20, 60,30,80);
				myCanvas.endFill();		
				break;

				case "curve":
				//curve
				myCanvas.clear();
				myCanvas.beginFill(0xFFCC04, 1);
				myCanvas.curveTo(20, 6,10,20);
				myCanvas.endFill();			
				break;
			}
			myCanvas.totalValue=1000;
			myCanvas.includeInRanges = true;
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
			var myCanvas:PolarDataCanvas = new PolarDataCanvas();
			var myLabel:Label = new Label();
			
			switch(testCaseType)
			{	
				case "1":
				myCanvas.clear();									
				myLabel.text = "Test";
				myCanvas.addChild(myLabel);
				myCanvas.updateDataChild(myLabel,  30,50, "4", 30, 3, 4);			
				break;

				case "2":
				myCanvas.clear();							
				myLabel.text = "Test";
				myCanvas.addChild(myLabel);
				myCanvas.updateDataChild(myLabel,  30,50, "5", 20, 1, 2);
				break;			

				case "3":
				myCanvas.clear();								
				myLabel.text = "Test";
				myCanvas.addChild(myLabel);
				myCanvas.updateDataChild(myLabel, 30,50, "2", 30, 0, 0);
				break;

				case "4":
				myCanvas.clear();								
				myLabel.text = "Test";
				myCanvas.addChild(myLabel);
				myCanvas.updateDataChild(myLabel, 30,50);
				break;

			}
			myCanvas.totalValue=1000;
			myCanvas.includeInRanges=true;
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
	
		public static function CanvasWithRadialAndAngularAxisSet(chart:Object):void
		{
			var myCanvas:PolarDataCanvas = new PolarDataCanvas();
			var arr:Array = new Array();
			var myLabel:Label = new Label();
			
			var pie1:PieSeries = new PieSeries();	
			pie1.field = "close";
			arr.push(pie1);

			var pie2:PieSeries = new PieSeries();	
			pie2.field = "open";
			arr.push(pie2);

			var pie3:PieSeries = new PieSeries();	
			pie3.field = "high";
			arr.push(pie3);		
			
			chart.series = arr;
			
			var myRadialAxis:LinearAxis = new LinearAxis();
			var myAngularAxis:LinearAxis = new LinearAxis();
			
			myRadialAxis.maximum = 100;
			myAngularAxis.maximum = 100;
			
			chart.radialAxis = myRadialAxis;
			pie3.angularAxis = myAngularAxis;			
			
			myCanvas.clear();
			myCanvas.beginFill(0xFFCC04, 1);
			myCanvas.drawCircle(0,40,50);
			myCanvas.endFill();	
			chart.annotationElements = chart.annotationElements.concat(myCanvas);				
		}

	}
}
