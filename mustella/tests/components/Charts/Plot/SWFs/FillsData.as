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
	
	import mx.core.mx_internal;
	import mx.collections.ArrayCollection;
	import mx.graphics.*;
	import mx.charts.ChartItem;
	public class FillsData
	{ 

		public function FillsData() 
		{ 
		}
		
		private static var ge1:GradientEntry = new GradientEntry(0xFFCC66,0,.5);
		private static var ge2:GradientEntry = new GradientEntry(0x000000,.33,.5);
		private static var ge3:GradientEntry = new GradientEntry(0x99FF33,.66,.5);
		
		private static var ge4:GradientEntry = new GradientEntry(0xCC3300,.33,.5);
		private static var ge5:GradientEntry = new GradientEntry(0xFF33FF,.66,.5);

		
		private static var ge6:GradientEntry = new GradientEntry(0x9966CC,0,.5);
		private static var ge7:GradientEntry = new GradientEntry(0x00FFFF,.33,.5);
		private static var ge8:GradientEntry = new GradientEntry(0x003399,.5,.5);
		private static var ge9:GradientEntry = new GradientEntry(0x663300,.66,.5);

		
		public static function getLGFills():Array
		{
		
			var lg1:LinearGradient = new LinearGradient();

			lg1.entries = [ge1,ge2,ge3];
			lg1.rotation = 90;

			var lg2:LinearGradient = new LinearGradient();

			
			lg2.entries = [ge4,ge5];
			lg2.rotation = 180;

			var lg3:LinearGradient = new LinearGradient();

			
			lg3.entries = [ge6,ge7,ge8,ge9];
			lg3.rotation = 270;

			lgfills = [lg1,lg2,lg3];

			return lgfills;
		}
		
		public static function getRGFills():Array
		{
				
			var rg1:RadialGradient = new RadialGradient();

			rg1.entries = [ge1,ge2,ge3];
			rg1.rotation = -90;
			rg1.focalPointRatio = -0.1;

			var rg2:RadialGradient = new RadialGradient();


			rg2.entries = [ge4,ge5];
			rg2.rotation = -180;
			rg2.focalPointRatio = -0.9;

			var rg3:RadialGradient = new RadialGradient();


			rg3.entries = [ge6,ge7,ge8,ge9];
			rg3.rotation = -270;
			rg3.focalPointRatio = 0.5;

			rgfills = [rg1,rg2,rg3];

			return rgfills;
		}
		
		public static function myfillFunction1(element:ChartItem, index:Number):IFill
		{
			var fill:SolidColor;
			if(element.item.close > 32 && element.item.close < 37)
				fill = new SolidColor(0xffff00);
			else if (element.item.close < 32)
				fill = new SolidColor(0xff0000);
			else if (element.item.close >=37)
				fill = new SolidColor(0x00ff00);
				
			return fill;
		}
		
		public static function myfillFunction2(element:ChartItem, index:Number):IFill
		{
			return(new SolidColor(0xff0000));
		}
		public static function myNullfillFunction(element:ChartItem, index:Number):IFill
		{
			return null;
		}
		
		
		[Bindable]
		public static var scfills:Array = [ new SolidColor (0x000000), new SolidColor (0xFF0000), new SolidColor (0x00FF00), 
							new SolidColor (0x0000FF), new SolidColor (0xFF00FF), new SolidColor (0x00FFFF) ];
		[Bindable]
		public static var fills:Array = ['0x333333','0x003399','0xCC3300','0x663300','0xFF33FF','0xCC99FF',
							'0x99FF00','0x003399','0x9966CC','0xFFFF00','0xCCCCCC'];
							
		[Bindable]
		public static var hashfills:Array = ['#cc00ff','#ff0099','#990000','#6666cc','#cccccc','#66ff66','#996666'];
		
		[Bindable]
		public static var stringfills:Array = ['blue','yellow','cyan','green','red','purple'];
		
		[Bindable]
		public static var lgfills:Array;
		
		[Bindable]
		public static var rgfills:Array;
		
		
	}
}
