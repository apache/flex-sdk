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
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	import spark.components.HSlider;
	import spark.skins.ios7.assets.HSliderTrack_filled;
	import spark.skins.mobile.supportClasses.HSliderDataTip;
	import spark.skins.mobile.supportClasses.MobileSkin;
	
	/**
	 *  Android 4.x specific ActionScript-based skin for HSlider controls in mobile applications.
	 * 
	 *  <p>The base Flex implementation creates an HSlider with fixed height
	 *  and variable width with a fixed-size thumb. As the height of the
	 *  HSlider component increases, the vertical dimensions of the visible HSlider remain
	 *  the same, and the HSlider stays vertically centered.</p>
	 * 
	 *  <p>The thumb and track implementations can be customized by subclassing
	 *  this skin class and overriding the thumbSkinClass, trackSkinClass,
	 *  and/or dataTipClass variables as necessary.</p>
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.5 
	 *  @productversion Flex 4.5
	 */
	public class HSliderSkin extends MobileSkin
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
		public function HSliderSkin()
		{
			super();
			
			thumbSkinClass = spark.skins.ios7.HSliderThumbSkin;
			trackSkinClass = spark.skins.ios7.HSliderTrackSkin;
			filledTrackSkinClass = spark.skins.ios7.assets.HSliderTrack_filled;
			dataTipClass = spark.skins.mobile.supportClasses.HSliderDataTip;
			
			blendMode = BlendMode.LAYER;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		/** 
		 *  @copy spark.skins.spark.ApplicationSkin#hostComponent
		 */
		private var _hostComponent:HSlider;
		
		/**
		 * @copy spark.skins.spark.ApplicationSkin#hostComponent
		 */
		public function get hostComponent():HSlider
		{
			return _hostComponent;
		}
		
		public function set hostComponent(value:HSlider):void 
		{
			if (_hostComponent)
			{
				_hostComponent.removeEventListener(Event.CHANGE, thumbPositionChanged_handler);
				_hostComponent.removeEventListener(FlexEvent.VALUE_COMMIT, thumbPositionChanged_handler);
			}
			_hostComponent = value;
			if (_hostComponent)
			{
				_hostComponent.addEventListener(Event.CHANGE, thumbPositionChanged_handler);
				_hostComponent.addEventListener(FlexEvent.VALUE_COMMIT, thumbPositionChanged_handler);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Skin parts 
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  HSlider track skin part
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5 
		 *  @productversion Flex 4.5
		 */    
		public var track:Button;
		
		/**
		 *  HSlider track skin part that
		 *  depicts area that is filled
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5 
		 *  @productversion Flex 4.5
		 */    
		public var filledTrack:DisplayObject;
		
		/**
		 *  HSlider thumb skin part
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5 
		 *  @productversion Flex 4.5
		 */    
		public var thumb:Button;
		
		/**
		 *  HSlider dataTip class factory
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5 
		 *  @productversion Flex 4.5
		 */    
		public var dataTip:IFactory;
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Specifies the skin class that will be used for the HSlider thumb.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5 
		 *  @productversion Flex 4.5 
		 */    
		protected var thumbSkinClass:Class;
		
		/**
		 *  Specifies the skin class that will be used for the HSlider track.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5 
		 *  @productversion Flex 4.5 
		 */    
		protected var trackSkinClass:Class;
		/**
		 *  Specifies the skin class that will be used for the HSlider track's
		 *  filled area.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5 
		 *  @productversion Flex 4.5 
		 */    
		protected var filledTrackSkinClass:Class;
		
		/**
		 *  Specifies the class that will be used for the HSlider datatip.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5 
		 *  @productversion Flex 4.5 
		 */    
		protected var dataTipClass:Class;
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private 
		 */ 
		override protected function commitCurrentState():void
		{
			if (currentState == "disabled")
				alpha = 0.5;
			else if (currentState == "normal")
				alpha = 1;
		}    
		
		/**
		 *  @private 
		 */ 
		override protected function createChildren():void
		{
			// Create our skin parts: track and thumb
			track = new Button();
			track.setStyle("skinClass", trackSkinClass);
			addChild(track);
			
			filledTrack = new filledTrackSkinClass();
			addChild(filledTrack);
			
			thumb = new Button();
			thumb.setStyle("skinClass", thumbSkinClass);
			addChild(thumb);
			
			// Set up the class factory for the dataTip
			dataTip = new ClassFactory();
			ClassFactory(dataTip).generator = dataTipClass;
		}
		
		/**
		 *  @private 
		 *  The HSliderSkin width will be no less than the width of the thumb skin.
		 *  The HSliderSkin height will be no less than the greater of the heights of
		 *  the thumb and track skins.
		 */ 
		override protected function measure():void
		{
			measuredWidth = track.getPreferredBoundsWidth();
			measuredHeight = Math.max(track.getPreferredBoundsHeight(), thumb.getPreferredBoundsHeight());
			
			measuredMinHeight = Math.max(track.getPreferredBoundsHeight(), thumb.getPreferredBoundsHeight());
			measuredMinWidth = thumb.getPreferredBoundsWidth();
		}
		
		/**
		 *  @private
		 */ 
		override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.layoutContents(unscaledWidth, unscaledHeight);
			
			// minimum height is no smaller than the larger of the thumb or track
			var calculatedSkinHeight:int = Math.max(Math.max(thumb.getPreferredBoundsHeight(), track.getPreferredBoundsHeight()),
				unscaledHeight);
			
			// minimum width is no smaller than the thumb
			var calculatedSkinWidth:int = Math.max(thumb.getPreferredBoundsWidth(),
				unscaledWidth);
			
			// once we know the skin height, center the thumb and track
			thumb.y = Math.max(Math.round((calculatedSkinHeight - thumb.getPreferredBoundsHeight()) / 2), 0);
			var calculatedTrackY:int = Math.max(Math.round((calculatedSkinHeight - track.getPreferredBoundsHeight()) / 2), 0);
			
			// size and position
			setElementSize(thumb, thumb.getPreferredBoundsWidth(), thumb.getPreferredBoundsHeight()); // thumb does NOT scale
			setElementSize(track, calculatedSkinWidth, track.getPreferredBoundsHeight()); // note track is NOT scaled vertically
			setElementPosition(track, 0, calculatedTrackY);
			
			//Set size and position of filled area based on thumb's current location
			var filledTrackWidth:Number = thumb.getLayoutBoundsX();
			setElementSize(filledTrack, filledTrackWidth, track.getPreferredBoundsHeight()); // note track is NOT scaled vertically
			setElementPosition(filledTrack, track.x + HSliderTrackSkin(track.skin).visibleTrackOffset  , calculatedTrackY);
		}
		
		private function thumbPositionChanged_handler(event:Event):void
		{
			//Just trigger a redraw so that the filled area of the track updates itself
			invalidateDisplayList();
		}
		
	}
}