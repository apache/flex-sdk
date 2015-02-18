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

package spark.skins.spark
{
	import flash.display.DisplayObject;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.utils.Timer;
	
	import mx.core.DPIClassification;
	import mx.core.FlexGlobals;
	
	import spark.components.BusyIndicator;
	import spark.skins.ActionScriptSkinBase;
	import spark.skins.spark.assets.BusyIndicator;
	
	public class BusyIndicatorSkin extends ActionScriptSkinBase
	{
		static private const DEFAULT_ROTATION_INTERVAL:Number = 30;
        /**
         *  @private
         */ 
        static private const DEFAULT_MINIMUM_SIZE:Number = 20;
        
		private var busyIndicatorClass:Class;
		private var busyIndicator:DisplayObject;
		private var busyIndicatorBackground:DisplayObject;
		private var busyIndicatorDiameter:Number;
		private var rotationTimer:Timer;
		private var rotationInterval:Number;
		private var rotationSpeed:Number;
        /**
         *  @private
         */   
        private var oldUnscaledHeight:Number;
        
        /**
         *  @private
         */   
        private var oldUnscaledWidth:Number;
        
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
			
			busyIndicatorClass = spark.skins.spark.assets.BusyIndicator;
			rotationInterval = getStyle("rotationInterval");
			if (isNaN(rotationInterval))
				rotationInterval = DEFAULT_ROTATION_INTERVAL;
			if (rotationInterval < 30) //Spokes are at 30 degree angle to each other. 
				rotationInterval = 30;
			rotationSpeed = 60;
			
			//mx:Application does not have an applicationDPI property
			//In that case, use a default value
			var dpi:Number;
			if(FlexGlobals.topLevelApplication.hasOwnProperty("applicationDPI"))
			{
				dpi = FlexGlobals.topLevelApplication["applicationDPI"];
			}
			
			if(dpi)
			{
				switch(dpi) 
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
			else
			{
				busyIndicatorDiameter = 27;
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
			//This layer stays still in the background
			busyIndicatorBackground = new busyIndicatorClass();
			//busyIndicatorBackground.width = busyIndicatorBackground.height = busyIndicatorDiameter;
			addChild(busyIndicatorBackground);
			//This layer rotates in the foreground to give the required effect
			busyIndicator = new busyIndicatorClass();
			busyIndicator.alpha = 0.3;
			//busyIndicator.width = busyIndicator.height = busyIndicatorDiameter;
			addChild(busyIndicator);
		}
		
        /**
         *  @private
         */
        override protected function measure():void
        {
            super.measure();
            
            // Set the default measured size depending on the
            // applicationDPI
			//mx:Application does not have an applicationDPI property
			//In that case, use a default value
			var dpi:Number;
			if(FlexGlobals.topLevelApplication.hasOwnProperty("applicationDPI"))
			{
				dpi = FlexGlobals.topLevelApplication["applicationDPI"];
			}
			if(dpi)
			{
				if (dpi == DPIClassification.DPI_640)
				{
					measuredWidth = 104;
					measuredHeight = 104;
				}
				else if (dpi == DPIClassification.DPI_480)
				{
					measuredWidth = 80;
					measuredHeight = 80;
				}
				else if (dpi == DPIClassification.DPI_320)
				{
					measuredWidth = 52;
					measuredHeight = 52;
				}
				else if (dpi == DPIClassification.DPI_240)
				{
					measuredWidth = 40;
					measuredHeight = 40;
				}
				else if (dpi == DPIClassification.DPI_160)
				{
					measuredWidth = 26;
					measuredHeight = 26;
				}
				else if (dpi == DPIClassification.DPI_120)
				{
					measuredWidth = 20;
					measuredHeight = 20;
				}
				else
				{
					measuredWidth = DEFAULT_MINIMUM_SIZE;
					measuredHeight = DEFAULT_MINIMUM_SIZE;
				}
			}
			else
			{
				measuredWidth = 20;
				measuredHeight = 20;
			}
            
            measuredMinWidth = DEFAULT_MINIMUM_SIZE;
            measuredMinHeight = DEFAULT_MINIMUM_SIZE;
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
            // If the size changed, then create a new spinner.
            if (oldUnscaledWidth != unscaledWidth ||
                oldUnscaledHeight != unscaledHeight)
            {
                var newDiameter:Number;
                
                newDiameter = calculateSpinnerDiameter(unscaledWidth, unscaledHeight);
                busyIndicatorBackground.width = busyIndicatorBackground.height = newDiameter;
                busyIndicator.width = busyIndicator.height = newDiameter;
                
                oldUnscaledWidth = unscaledWidth;
                oldUnscaledHeight = unscaledHeight;
            }
		}
		
        /**
         *   @private
         *
         *   Apply the rules to calculate the spinner diameter from the width
         *   and height.
         *  
         *   @param width new width of this component
         *   @param height new height of this component
         *    
         *   @return true if the spinner's diameter changes, false otherwise.
         */
        private function calculateSpinnerDiameter(width:Number, height:Number):Number
        {
            var diameter:Number = Math.min(width, height);
            diameter = Math.max(DEFAULT_MINIMUM_SIZE, diameter);
            if (diameter % 2 != 0)
                diameter--;
            
            return diameter;
        }
        
		private function colorizeSymbol():void
		{
			super.applyColorTransform(this.busyIndicator, 0x000000, symbolColor);
		}
		
		private function startRotation():void
		{
			rotationTimer = new Timer(rotationSpeed);
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

