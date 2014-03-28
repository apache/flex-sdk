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
	
	import mx.core.DPIClassification;
	
	import spark.skins.android4.assets.CheckBox_up;
	import spark.skins.mobile.supportClasses.SelectableButtonSkinBase;
	
	/**
	 *  ActionScript-based skin for CheckBox components in mobile applications. 
	 * 
	 *  @see spark.components.CheckBox
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.5 
	 *  @productversion Flex 4.5
	 */
	public class CheckBoxSkin extends SelectableButtonSkinBase
	{
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		private static const exclusions:Array = ["labelDisplay", "labelDisplayShadow"];

		//--------------------------------------------------------------------------
		//
		//  Member variables
		//
		//--------------------------------------------------------------------------

		protected var symbolOffsetX:Number;
		protected var symbolOffsetY:Number;
		protected var iconWidth:Number;
		protected var iconHeight:Number;
		protected var symbolWidth:Number;
		protected var symbolHeight:Number;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function CheckBoxSkin()
		{
			super();
			
			layoutPaddingLeft = 0;
			layoutPaddingRight = 0;
			layoutPaddingTop = 0;
			layoutPaddingBottom = 0;
			
			upIconClass = spark.skins.android4.assets.CheckBox_up;
			upSelectedIconClass = spark.skins.android4.assets.CheckBox_upSelected;
			downIconClass = spark.skins.android4.assets.CheckBox_down;
			downSelectedIconClass = spark.skins.android4.assets.CheckBox_downSelected;
			upSymbolIconClass = null;
			upSymbolIconSelectedClass = spark.skins.android4.assets.CheckBox_upSymbolSelected;
			downSymbolIconSelectedClass = spark.skins.android4.assets.CheckBox_downSymbolSelected;
			downSymbolIconClass = null;
					
			switch (applicationDPI)
			{
				case DPIClassification.DPI_640:
				{
					
					layoutGap = 16;
					minWidth = 128;
					minHeight = 128;
					layoutBorderSize = 6;
					iconWidth = 128;
					iconHeight = 128;
					symbolWidth = 64;
					symbolHeight = 64;
					symbolOffsetX = 32;
					symbolOffsetY = 32;
					
					break;
				}
				case DPIClassification.DPI_480:
				{
					
					layoutGap = 12;
					minWidth = 96;
					minHeight = 96;
					layoutBorderSize = 4;
					iconWidth = 96;
					iconHeight = 96;
					symbolWidth = 48;
					symbolHeight = 48;
					symbolOffsetX = 24;
					symbolOffsetY = 24;
					
					break;
				}
				case DPIClassification.DPI_320:
				{
					
					layoutGap = 8;
					minWidth = 64;
					minHeight = 64;
					layoutBorderSize = 3;
					iconWidth = 64;
					iconHeight = 64;
					symbolWidth = 32;
					symbolHeight = 32;
					symbolOffsetX = 16;
					symbolOffsetY = 16;
					
					break;
				}
				case DPIClassification.DPI_240:
				{
					
					layoutGap = 6;
					minWidth = 48;
					minHeight = 48;
					layoutBorderSize = 2;
					iconWidth = 48;
					iconHeight = 48;
					symbolWidth = 24;
					symbolHeight = 24;
					symbolOffsetX = 12;
					symbolOffsetY = 12;
					
					break;
				}
				case DPIClassification.DPI_120:
				{
					
					layoutGap = 3;
					minWidth = 24;
					minHeight = 24;
					layoutBorderSize = 1;
					iconWidth = 24;
					iconHeight = 24;
					symbolWidth = 12;
					symbolHeight = 12;
					symbolOffsetX = 6;
					symbolOffsetY = 6;
					
					break;
				}
				default:
				{
					// default DPI_160
					
					layoutGap = 4;
					minWidth = 32;
					minHeight = 32;
					layoutBorderSize = 2;
					iconWidth = 32;
					iconHeight = 32;
					symbolWidth = 16;
					symbolHeight = 16;
					symbolOffsetX = 8;
					symbolOffsetY = 8;
					
					
					break;
				}
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  CheckBox <code>chromeColor</code> is drawn to match the FXG rectangle
		 *  shape and position.
		 */
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
			// super draws a transparent hit zone
			super.drawBackground(unscaledWidth, unscaledHeight);
			
			// get the size and position of iconDisplay
			var currentIcon:DisplayObject = getIconDisplay();
			var widthAdjustment:Number = layoutBorderSize * 2;
			
			graphics.beginFill(getStyle("chromeColor"));
			graphics.drawRoundRect(currentIcon.x + layoutBorderSize,
				currentIcon.y + layoutBorderSize,
				currentIcon.width - widthAdjustment,
				currentIcon.height - widthAdjustment, layoutBorderSize, layoutBorderSize);
			graphics.endFill();
		}
		
		/**
		 *  List of IDs of items that should be excluded when rendering the focus ring.
		 *  Only items of type DisplayObject or GraphicElement should be excluded. Items
		 *  of other types are ignored.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		override protected function get focusSkinExclusions():Array 
		{
			return exclusions;
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			if(symbolIcon != null)
			{
				symbolIcon.width = symbolWidth;
				symbolIcon.height = symbolHeight;
			}
			var iconDisplay:DisplayObject = getIconDisplay(); 
			if(iconDisplay != null)
			{
				iconDisplay.width = iconWidth;
				iconDisplay.height = iconHeight;
			}
		}
		
		override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.layoutContents(unscaledWidth, unscaledHeight);
			// position the symbols to align with the background "icon"
			if (symbolIcon)
			{
				var currentIcon:DisplayObject = getIconDisplay();
				setElementPosition(symbolIcon, symbolOffsetX, symbolOffsetY);
			}
		}
		
	}
}