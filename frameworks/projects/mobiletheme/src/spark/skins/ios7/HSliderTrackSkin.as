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
	import flash.display.DisplayObject;
	
	import mx.core.DPIClassification;
	
	import spark.components.Button;
	import spark.skins.ios7.assets.HSliderTrack;
	import spark.skins.mobile.supportClasses.MobileSkin;
	
	/**
	 *  ActionScript-based skin for the HSlider track skin part in mobile applications. 
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.5 
	 *  @productversion Flex 4.5
	 */
	public class HSliderTrackSkin extends MobileSkin
	{
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
		 * 
		 */
		public function HSliderTrackSkin()
		{
			super();
			
			trackClass = spark.skins.ios7.assets.HSliderTrack;
			
			// set the right dimensions to use based on the screen density
			switch (applicationDPI)
			{
				case DPIClassification.DPI_640:
				{
					trackWidth = 1200;
					trackHeight = 8;
					
					visibleTrackOffset = 48;
					
					break;
				}
				case DPIClassification.DPI_480:
				{
					trackWidth = 900;
					trackHeight = 6;
					
					visibleTrackOffset = 38;
					
					break;
				}
				case DPIClassification.DPI_320:
				{
					trackWidth = 600;
					trackHeight = 4;
					
					visibleTrackOffset = 24;
					
					break;
				}
				case DPIClassification.DPI_240:
				{
					trackWidth = 450;
					trackHeight = 3;
					
					visibleTrackOffset = 18;
					
					break;
				}
				case DPIClassification.DPI_120:
				{
					trackWidth = 225;
					trackHeight = 2;
					
					visibleTrackOffset = 9;
					
					break;
				}
				default:
				{
					// default DPI_160
					trackWidth = 300;
					trackHeight = 2;
					
					visibleTrackOffset = 12;
					
					break;
				}
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		/** 
		 * @copy spark.skins.spark.ApplicationSkin#hostComponent
		 */
		public var hostComponent:Button;
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Specifies the FXG class to use for the track image
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		protected var trackClass:Class;
		
		/**
		 *  Specifies the DisplayObject for the track image
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		protected var trackSkin:DisplayObject;
		
		/**
		 *  Specifies the track image width
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */    
		protected var trackWidth:int;
		
		/**
		 *  Specifies the track image height
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		protected var trackHeight:int;
		
		/**
		 *  Specifies the offset from the left and right edge to where
		 *  the visible track begins. This should match the offset in the FXG assets.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public var visibleTrackOffset:int;
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private 
		 */ 
		override protected function createChildren():void
		{
			trackSkin = new trackClass();
			addChild(trackSkin);
		}
		
		/**
		 *  @private 
		 */ 
		override protected function measure():void
		{
			measuredWidth = trackWidth;
			measuredHeight = trackHeight;
		}
		
		/**
		 *  @private 
		 */ 
		override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.layoutContents(unscaledWidth, unscaledHeight);
			
			var unscaledTrackWidth:int = unscaledWidth - (2 * visibleTrackOffset);
			setElementSize(trackSkin, unscaledTrackWidth, unscaledHeight);
			setElementPosition(trackSkin, visibleTrackOffset, 0);
		}
		
	}
}