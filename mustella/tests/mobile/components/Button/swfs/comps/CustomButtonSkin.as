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
package comps
{
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Graphics;	
	import flash.geom.Matrix;
	
	import mx.utils.ColorUtil;
	
	import spark.skins.mobile.ButtonSkin;
	
	public class CustomButtonSkin extends ButtonSkin
	{
		private static var matrix:Matrix = new Matrix();
		private static const CORNER_ELLIPSE_SIZE:uint = 20;
		
		private static const BOTTOM_BORDER_SHADOW:uint = 1;		

		public function CustomButtonSkin()
		{
			super();
			upBorderSkin = CustomButton_up;
			downBorderSkin = CustomButton_down;
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			
			var downState:Boolean = currentState.indexOf("down") == -1 ? false : true;
			
			var iconD:DisplayObject = getIconDisplay();
			if (iconD)
			{
				if (downState)
				{
					setElementSize(iconD, iconD.width - 10, iconD.height - 10);
				}
				else {
					setElementSize(iconD, iconD.width + 10, iconD.height + 10);
					//iconD.scaleX = iconD.scaleY = 1;
				}
			}
			
		}
	
/*		override protected function drawChromeColor(chromeColorGraphics:Graphics, unscaledWidth:Number, unscaledHeight:Number):void
		{
			// bottom line is a shadow
			chromeColorGraphics.drawRoundRect(1, 1, unscaledWidth, unscaledHeight - BOTTOM_BORDER_SHADOW, CORNER_ELLIPSE_SIZE, CORNER_ELLIPSE_SIZE);
		}		
*/

		

	}
}