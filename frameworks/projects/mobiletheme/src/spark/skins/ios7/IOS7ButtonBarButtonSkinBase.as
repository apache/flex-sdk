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

package spark.skins.ios7
{
	import mx.core.DPIClassification;
	
	import spark.skins.ios7.assets.ButtonBarMiddleButton_down;
	import spark.skins.ios7.assets.ButtonBarMiddleButton_up;
	import spark.skins.mobile.supportClasses.ButtonBarButtonSkinBase;
	
	/**
	 *  iOS7+ specific Button skin base for the Buttons in a ButtonBar.
	 * 
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.5 
	 *  @productversion Flex 4.5
	 */
	public class IOS7ButtonBarButtonSkinBase extends ButtonBarButtonSkinBase
	{
		
		/**
		 *  Class to use for the border in the selected and down state.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5 
		 *  @productversion Flex 4.5
		 */  
		protected var selectedDownBorderSkin:Class;
		
		/**
		 *  Constructor.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5 
		 *  @productversion Flex 4.5
		 */
		public function IOS7ButtonBarButtonSkinBase()
		{
			super();
			
			// set the dimensions to use based on the screen density
			switch (applicationDPI)
			{
				case DPIClassification.DPI_640:
				{
					measuredDefaultHeight = 116;
					measuredDefaultWidth = 400;
					
					break;              
				}
				case DPIClassification.DPI_480:
				{
					measuredDefaultHeight = 88;
					measuredDefaultWidth = 300;
					
					break;
				}
				case DPIClassification.DPI_320:
				{
					measuredDefaultHeight = 58;
					measuredDefaultWidth = 200;
					
					break;              
				}
				case DPIClassification.DPI_240:
				{
					measuredDefaultHeight = 44;
					measuredDefaultWidth = 150;
					
					break;
				}
				case DPIClassification.DPI_120:
				{
					measuredDefaultHeight = 22;
					measuredDefaultWidth = 75;
					
					break;
				}
				default:
				{
					// default DPI_160
					measuredDefaultHeight = 29;
					measuredDefaultWidth = 100;
					
					break;
				}
			}
		}	
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
			//Dont draw background
		}
		
		override protected function getBorderClassForCurrentState():Class
		{
			var isSelected:Boolean = currentState.indexOf("Selected") >= 0;
			var isDown:Boolean = currentState.indexOf("down") >= 0;
			
			if (isSelected && !isDown )
				return selectedBorderSkin;
			else if (isSelected && isDown)
				return selectedDownBorderSkin;
			else if (!isSelected && !isDown)
				return upBorderSkin;
			else 
				return downBorderSkin;
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			var isSelected:Boolean = currentState.indexOf("Selected") >= 0;
			var isDown:Boolean = currentState.indexOf("down") >= 0;
			
			if(xor(isSelected,isDown))
			{
				var highlightColor:uint = getStyle("highlightTextColor");
				labelDisplay.setStyle("color",highlightColor);
			}
			else
			{
				var color:uint = getStyle("color");
				labelDisplay.setStyle("color",color);
			}
			
		}
		
		private function xor(lhs:Boolean, rhs:Boolean):Boolean {
			return !( lhs && rhs ) && ( lhs || rhs );
		}
		
	}
}