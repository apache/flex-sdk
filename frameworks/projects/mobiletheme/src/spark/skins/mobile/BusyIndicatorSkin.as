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

package spark.skins.mobile
{
	
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import mx.core.DPIClassification;
	import mx.core.mx_internal;
	
	import spark.components.BusyIndicator;
	import spark.skins.mobile.supportClasses.MobileSkin;
	
	public class BusyIndicatorSkin extends MobileSkin
	{
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */ 
		static private const DEFAULT_ROTATION_INTERVAL:Number = 50;
		
		/**
		 *  @private
		 */ 
		static private const DEFAULT_MINIMUM_SIZE:Number = 20;
		
		/**
		 *  @private
		 */ 
		static private const RADIANS_PER_DEGREE:Number = Math.PI / 180;
		
		public function BusyIndicatorSkin()
		{
			super();
			alpha = 0.60;       // default alpha
            // component changes state when removed but it doesn't get validated in time
            addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler,false,0,true);
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
		 */   
		private var rotationTimer:Timer;
		
		/**
		 *  @private
		 * 
		 *  Current rotation of this component in degrees.
		 */   
		private var currentRotation:Number = 0;
		
		/**
		 *  @private
		 * 
		 *  Diameter of the spinner for this component.
		 */ 
		private var spinnerDiameter:int;
		
		/**
		 *  @private
		 * 
		 *  Cached value of the spoke color.
		 */ 
		private var spokeColor:uint;
		
		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);
			
			var allStyles:Boolean = !styleProp || styleProp == "styleName";
			
			// Check for skin/icon changes here.
			// We could only throw out any skins that change,
			// but since dynamic re-skinning is uncommon, we'll take
			// the simpler approach of throwing out all skins.
			if (allStyles || styleProp == "rotationInterval")
			{
				// Update the timer if the rotation interval has changed.
				if (isRotating())
				{
					stopRotation();
					startRotation();
				}
			}
			
			if (allStyles || styleProp == "symbolColor")
			{
				updateSpinner(spinnerDiameter);
			}
		}
		
		override protected function measure():void
		{
            // Set the default measured size depending on the
            // applicationDPI
            if (applicationDPI == DPIClassification.DPI_640)
            {
                measuredWidth = 104;
                measuredHeight = 104;
            }
            else if (applicationDPI == DPIClassification.DPI_480)
            {
                measuredWidth = 80;
                measuredHeight = 80;
            }
            else if (applicationDPI == DPIClassification.DPI_320)
            {
                measuredWidth = 52;
                measuredHeight = 52;
            }
            else if (applicationDPI == DPIClassification.DPI_240)
            {
                measuredWidth = 40;
                measuredHeight = 40;
            }
            else if (applicationDPI == DPIClassification.DPI_160)
            {
                measuredWidth = 26;
                measuredHeight = 26;
            }
            else if (applicationDPI == DPIClassification.DPI_120)
            {
                measuredWidth = 20;
                measuredHeight = 20;
            }
            else
            {
                measuredWidth = DEFAULT_MINIMUM_SIZE;
                measuredHeight = DEFAULT_MINIMUM_SIZE;
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
			invalidateSize();
			invalidateDisplayList();
		}
		
		/**
		 *  @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number,
													  unscaledHeight:Number):void
		{
			//super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// If the size changed, then create a new spinner.
			if (oldUnscaledWidth != unscaledWidth ||
				oldUnscaledHeight != unscaledHeight)
			{
				var newDiameter:Number;
				
				newDiameter = calculateSpinnerDiameter(unscaledWidth, unscaledHeight);
				updateSpinner(newDiameter);
				
				oldUnscaledWidth = unscaledWidth;
				oldUnscaledHeight = unscaledHeight;
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
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
		
		override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
		{
			measuredHeight = unscaledHeight;
			measuredWidth = unscaledWidth;
		}
		
		/**
		 *   @private
		 * 
		 *   Update the spinner properties and redraw.
		 */
		private function updateSpinner(diameter:Number):void
		{
			var isRotating:Boolean = isRotating();
			
			if (isRotating)
				stopRotation();
			
			spinnerDiameter = diameter;
			spokeColor = getStyle("symbolColor");
			
			mx_internal::drawSpinner();
			
			if (isRotating)
				startRotation();
		}
		
		/**
		 *  @private
		 * 
		 *  Draw the spinner using the graphics property of this component.
		 */ 
		mx_internal function drawSpinner():void 
		{
			var g:Graphics = graphics;
			var spinnerRadius:int = spinnerDiameter / 2;
			var spinnerWidth:int = spinnerDiameter;
			var spokeHeight:Number = spinnerDiameter / 3.7;
			var insideDiameter:Number = spinnerDiameter - (spokeHeight * 2); 
			var spokeWidth:Number = insideDiameter / 5;
			var eHeight:Number = spokeWidth / 2;
			var spinnerPadding:Number = 0;
			
			// Undocumented styles to modified the spokeWidth
			// and spokeHeight.
			//        if (getStyle("spokeWidth") !== undefined)
			//        {
			//            spokeWidth = getStyle("spokeWidth");
			//            eHeight = spokeWidth / 2;
			//        }
			//        
			//        if (getStyle("spokeHeight") !== undefined)
			//            spokeHeight = getStyle("spokeHeight");
			//        
			//        // spinnerPadding is the padding between the outside
			//        // edge of the circle and the edge of a spoke. 
			//        if (getStyle("spinnerPadding") !== undefined)
			//            spinnerPadding = getStyle("spinnerPadding");
			//
			//        trace("spoke height = " + spokeHeight);
			//        trace("spoke width = " + spokeWidth);
			//        trace("center = " + center);
			
			g.clear();
			
			// 1
			drawSpoke(0.20, currentRotation + 300, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
			
			// 2
			drawSpoke(0.25, currentRotation + 330, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
			
			// 3
			drawSpoke(0.30, currentRotation, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
			
			// 4
			drawSpoke(0.35, currentRotation + 30, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
			
			// 5
			drawSpoke(0.40, currentRotation + 60, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
			
			// 6
			drawSpoke(0.45, currentRotation + 90, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
			
			// 7
			drawSpoke(0.50, currentRotation + 120, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
			
			// 8
			drawSpoke(0.60, currentRotation + 150, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
			
			// 9
			drawSpoke(0.70, currentRotation + 180, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
			
			// 10
			drawSpoke(0.80, currentRotation + 210, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
			
			// 11
			drawSpoke(0.90, currentRotation + 240, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
			
			// 12
			drawSpoke(1.0, currentRotation + 270, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
		}
		
		
		/**
		 *  @private
		 * 
		 *  @param spokeAlpha: alpha value of the spoke.
		 *  @param spokeWidth: width of the spoke in points.
		 *  @param spokeHeight: the lenght of the spoke in pixels.
		 *  @param spokeColor: the color of the spoke.
		 *  @param spinnerRadius: radius of the spinner.
		 *  @param eHeight: estimated height of the rounded end of the spinner.
		 *  @param spinnerPadding: number of pixels between the outside
		 *  radius of the spinner and the spokes. This is used to make 
		 *  spinners with skinny spokes look better by moving them
		 *  closer to the center of the spinner.
		 */ 
		private function drawSpoke(spokeAlpha:Number, degrees:int,
								   spokeWidth:Number, 
								   spokeHeight:Number, 
								   spokeColor:uint, 
								   spinnerRadius:Number, 
								   eHeight:Number,
								   spinnerPadding:Number):void
		{
			var g:Graphics = graphics;
			
			g.lineStyle(spokeWidth, spokeColor, spokeAlpha, false, LineScaleMode.NORMAL, CapsStyle.ROUND);
			var outsidePoint:Point = calculatePointOnCircle(spinnerRadius, spinnerRadius - eHeight - spinnerPadding, degrees);
			var insidePoint:Point = calculatePointOnCircle(spinnerRadius, spinnerRadius - spokeHeight + eHeight - spinnerPadding, degrees);
			g.moveTo(outsidePoint.x, outsidePoint.y);
			g.lineTo(insidePoint.x,  insidePoint.y);
			
		}
		
		/**
		 *  @private
		 */ 
		private function calculatePointOnCircle(center:Number, radius:Number, degrees:Number):Point
		{
			var point:Point = new Point();
			var radians:Number = degrees * RADIANS_PER_DEGREE;
			point.x = center + radius * Math.cos(radians);
			point.y = center + radius * Math.sin(radians);
			
			return point;
		}
		
		/**
		 *  @private
		 */
		private function startRotation():void
		{
			if (!rotationTimer)
			{
				var rotationInterval:Number = getStyle("rotationInterval");
				if (isNaN(rotationInterval))
					rotationInterval = DEFAULT_ROTATION_INTERVAL;
				
				if (rotationInterval < 16.6)
					rotationInterval = 16.6;
				
				rotationTimer = new Timer(rotationInterval);
			}
			
			if (!rotationTimer.hasEventListener(TimerEvent.TIMER))
			{
				rotationTimer.addEventListener(TimerEvent.TIMER, timerHandler);
				rotationTimer.start();
			}
			
		}
		
		/**
		 *  @private
		 */
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
		 */
		private function isRotating():Boolean
		{
			return rotationTimer != null;
		}
		
		/**
		 *  @private
		 * 
		 *  Rotate the spinner once for each timer event.
		 */
		private function timerHandler(event:TimerEvent):void
		{
			currentRotation += 30;
			if (currentRotation >= 360)
				currentRotation = 0;
			
			mx_internal::drawSpinner();
			event.updateAfterEvent();
		}
		
        /**
         *  @private
         */
        private function removedFromStageHandler(event:Event):void
        {
            stopRotation();
        }
        

	}
}