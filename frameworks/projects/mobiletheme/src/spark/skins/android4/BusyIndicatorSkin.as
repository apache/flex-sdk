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

package spark.skins.android4
{
	import flash.display.DisplayObject;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.utils.Timer;
	import mx.core.DPIClassification;
	import spark.skins.android4.assets.BusyIndicator;
	import spark.skins.mobile.supportClasses.MobileSkin;
	
	import spark.components.BusyIndicator;
	
	public class BusyIndicatorSkin extends MobileSkin
	{
		static private const DEFAULT_ROTATION_INTERVAL:Number = 50;
		private var busyIndicatorClass:Class;
		private var busyIndicator:DisplayObject;
		private var busyIndicatorDiameter:Number;
		private var rotationTimer:Timer;
		private var rotationInterval:Number;
		/**
		 *  @private
		 * 
		 *  Current rotation of this component in degrees.
		 */   
		private var currentRotation:Number = 0;
		private var symbolColor:uint;
		private var symbolColorChanged:Boolean = false;		
		
		public function BusyIndicatorSkin()
		{
			super();
			
			busyIndicatorClass = spark.skins.android4.assets.BusyIndicator;
			rotationInterval = getStyle("rotationInterval");
			if (isNaN(rotationInterval))
				rotationInterval = DEFAULT_ROTATION_INTERVAL;
			if (rotationInterval < 16.6)
				rotationInterval = 16.6;
			
			switch(applicationDPI) 
			{	
				case DPIClassification.DPI_640:
				{
					busyIndicatorDiameter = 144;
					break;
				}
				case DPIClassification.DPI_480:
				{
					busyIndicatorDiameter = 108;
					break;
				}		
				case DPIClassification.DPI_320:
				{
					busyIndicatorDiameter = 72;
					break;
				}
				case DPIClassification.DPI_240:
				{
					busyIndicatorDiameter = 54;
					break;
				}
				case DPIClassification.DPI_120:
				{
					busyIndicatorDiameter = 27;
					break;
				}
				default://160 DPI
				{
					busyIndicatorDiameter = 36;
					break;
				}
			}
		}
		
		private var _hostComponent:spark.components.BusyIndicator;
		
		public function get hostComponent():spark.components.BusyIndicator
		{
			return _hostComponent;
		}
		
		public function set hostComponent(value:spark.components.BusyIndicator):void 
		{
			_hostComponent = value;
		}
		
		override protected function createChildren():void
		{
			busyIndicator = new busyIndicatorClass();
			busyIndicator.width = busyIndicator.height = busyIndicatorDiameter;
			addChild(busyIndicator);
		}
		
		override protected function measure():void
		{
			measuredWidth = busyIndicatorDiameter;
			measuredHeight = busyIndicatorDiameter;
			
			measuredMinHeight = busyIndicatorDiameter;
			measuredMinWidth = busyIndicatorDiameter
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			if(currentState == "rotatingState")
			{
				startRotation();
			}
			else
			{
				stopRotation();
			}
		}
		
		override public function styleChanged(styleProp:String):void
		{
			var allStyles:Boolean = !styleProp || styleProp == "styleName";
			
			if (allStyles || styleProp == "symbolColor")
			{
				symbolColor = getStyle("symbolColor");
				symbolColorChanged = true;
				invalidateDisplayList();
			}
			super.styleChanged(styleProp);
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			if(symbolColorChanged)
			{
				colorizeSymbol();	
				symbolColorChanged = false;
			}
		}
		
		private function colorizeSymbol():void
		{
			super.applyColorTransform(this.busyIndicator, 0x000000, symbolColor);
		}		
		
		private function startRotation():void
		{
			rotationTimer = new Timer(rotationInterval);
			if (!rotationTimer.hasEventListener(TimerEvent.TIMER))
			{
				rotationTimer.addEventListener(TimerEvent.TIMER, timerHandler);
				rotationTimer.start();
			}
		}
		
		private function stopRotation():void
		{
			if (rotationTimer)
			{
				rotationTimer.removeEventListener(TimerEvent.TIMER, timerHandler);
				rotationTimer.stop();
				rotationTimer = null;
			}
		}
		
		/**
		 *  @private
		 * 
		 *  Rotate the spinner once for each timer event.
		 */
		private function timerHandler(event:TimerEvent):void
		{
			currentRotation += rotationInterval;
			if (currentRotation >= 360)
				currentRotation = 0;
			
			rotate(busyIndicator,currentRotation,width/2,height/2);
			event.updateAfterEvent();
		}
		
		private var rotationMatrix:Matrix; 
		private function rotate(obj:DisplayObject, angle:Number, aroundX:Number, aroundY:Number):void
		{
			rotationMatrix = new Matrix();
			rotationMatrix.translate(-aroundX,-aroundY);
			rotationMatrix.rotate(Math.PI*angle/180);
			rotationMatrix.translate(aroundX,aroundY);
			obj.transform.matrix = rotationMatrix;
		}
		
	}
}