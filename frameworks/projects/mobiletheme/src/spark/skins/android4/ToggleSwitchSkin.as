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
	
	import flash.display.BlendMode;
	import flash.events.Event;
	
	import mx.core.DPIClassification;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	
	import spark.components.ToggleSwitch;
	import spark.components.supportClasses.StyleableTextField;
	import spark.core.SpriteVisualElement;
	import spark.skins.android4.assets.ToggleSwitchBackground;
	import spark.skins.android4.assets.ToggleSwitchThumb_off;
	import spark.skins.mobile.supportClasses.MobileSkin;
	
	
	/**
	 *  ActionScript-based Android 4.x specific skin for the ToggleSwitch control. 
	 *  This class is responsible for most of the 
	 *  graphics drawing, with additional fxg assets.
	 *  
	 *  
	 *  @langversion 3.0
	 *  @playerversion AIR 3
	 *  @productversion Flex 4.6
	 *
	 *  @see spark.components.ToggleSwitch 
	 */
	public class ToggleSwitchSkin extends MobileSkin
	{
		//----------------------------------------------------------------------------------------------
		//
		//  Skin parts
		//
		//----------------------------------------------------------------------------------------------
		
		/**
		 *  The thumb skin part.
		 *  
		 *  @langversion 3.0
		 *  @playerversion AIR 3
		 *  @productversion Flex 4.6
		 */		
		public var thumb:IVisualElement;
		/**
		 *  The track skin part.
		 *  
		 *  @langversion 3.0
		 *  @playerversion AIR 3
		 *  @productversion Flex 4.6
		 */
		public var track:IVisualElement;
		
		//----------------------------------
		//  hostComponent
		//----------------------------------
		
		private var _hostComponent:ToggleSwitch;
		public var selectedLabelDisplay:LabelDisplayComponent;
		
		/**
		 * @copy spark.skins.spark.ApplicationSkin#hostComponent
		 */
		public function get hostComponent():ToggleSwitch
		{
			return _hostComponent;
		}
		
		public function set hostComponent(value:ToggleSwitch):void 
		{
			if (_hostComponent)
				_hostComponent.removeEventListener("thumbPositionChanged", thumbPositionChanged_handler);
			_hostComponent = value;
			if (_hostComponent)
				_hostComponent.addEventListener("thumbPositionChanged", thumbPositionChanged_handler);
		}
		
		//----------------------------------
		//  selectedLabel
		//----------------------------------
		
		private var _selectedLabel:String;
		/**
		 *  The text of the label showing when the component is selected.
		 *  Subclasses can set or override this property to customize the selected label.
		 *  
		 *  @langversion 3.0
		 *  @playerversion AIR 3
		 *  @productversion Flex 4.6
		 */
		protected function get selectedLabel():String 
		{
			return _selectedLabel;
		}
		
		protected function set selectedLabel(value:String):void
		{
			_selectedLabel = value;
		}
		
		//----------------------------------
		//  unselectedLabel
		//----------------------------------
		
		private var _unselectedLabel:String;
		/**
		 *  The text of the label showing when the component is not selected.
		 *  Subclasses can set or override this property to customize the unselected label.
		 * 
		 *  @langversion 3.0
		 *  @playerversion AIR 3
		 *  @productversion Flex 4.6
		 */
		protected function get unselectedLabel():String 
		{
			return _unselectedLabel;
		}
		
		protected function set unselectedLabel(value:String):void
		{
			_unselectedLabel = value;
		}
				
		
		/**
		 *  The contents inside the skin, not including the outline
		 *  stroke
		 */
		private var contents:UIComponent;
		private var switchTrack:Class;
		private var switchOff:Class;
		private var switchOn:Class;
		protected var trackWidth:Number;
		protected var trackHeight:Number;
		protected var layoutThumbWidth:Number;
		protected var layoutThumbHeight:Number;
		private var thumbOn:IVisualElement;
		private var thumbOff:IVisualElement;
		
		public function ToggleSwitchSkin()
		{
			super();
			
			switchTrack = spark.skins.android4.assets.ToggleSwitchBackground;
			switchOn = spark.skins.android4.assets.ToggleSwitchThumb_on;
			switchOff = spark.skins.android4.assets.ToggleSwitchThumb_off;
			
			switch(applicationDPI) 
			{	
				case DPIClassification.DPI_640:
				{
					layoutThumbWidth = 188;
					layoutThumbHeight = 96;
					trackWidth = 388;
					trackHeight = 96;
					break;
				}
				case DPIClassification.DPI_480:
				{
					layoutThumbWidth = 140;
					layoutThumbHeight = 72;
					trackWidth = 291;
					trackHeight = 72;
					break;
				}		
				case DPIClassification.DPI_320:
				{
					layoutThumbWidth = 94;
					layoutThumbHeight = 48;
					trackWidth = 194;
					trackHeight = 48;
					break;
				}
				case DPIClassification.DPI_240:
				{
					layoutThumbWidth = 70;
					layoutThumbHeight = 36;
					trackWidth = 146;
					trackHeight = 36;
					break;
				}
				case DPIClassification.DPI_120:
				{
					layoutThumbWidth = 35;
					layoutThumbHeight = 18;
					trackWidth = 73;
					trackHeight = 18;
					break;
				}
				default:
				{
					layoutThumbWidth = 47;
					layoutThumbHeight = 24;
					trackWidth = 97;
					trackHeight = 24;
					break;
				}
			}
			
			selectedLabel = resourceManager.getString("components","toggleSwitchSelectedLabel");
			unselectedLabel =  resourceManager.getString("components","toggleSwitchUnselectedLabel");
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			contents = new UIComponent();
			contents.blendMode = BlendMode.LAYER;
			addChild(contents);
			drawTrack();
			drawThumbs();
			drawLabel();
		}
		
		override protected function measure():void 
		{
			// The skin must be at least as large as the thumb
			measuredMinWidth = layoutThumbWidth;
			measuredMinHeight = layoutThumbHeight;
			
			// The preferred size will display all label text
			var labelWidth:Number = getElementPreferredWidth(selectedLabelDisplay);
			measuredWidth = layoutThumbWidth + labelWidth;
			measuredHeight = layoutThumbHeight;
		}
		
		override protected function commitCurrentState():void
		{
			toggleSelectionState();
			layoutThumbs();
			layoutLabel();
		}
		
		//The label is called selectedLabelDisplay because the hostComponent expects it
		protected function drawLabel():void
		{
			selectedLabelDisplay = new LabelDisplayComponent();
			selectedLabelDisplay.id = "selectedLabelDisplay";
			selectedLabelDisplay.text = selectedLabel;
			setElementSize(selectedLabelDisplay,thumb.width,thumb.height);
			contents.addChild(selectedLabelDisplay);
		}
		
		//Draw the track behind everything else
		protected function drawTrack():void
		{
			if(track == null)
			{
				track = new switchTrack();
				track.width = trackWidth;
				track.height = trackHeight;
				contents.addChildAt(SpriteVisualElement(track),0);
			}
		}
		
		//Draw both thumbs.  Set skinpart thumb to be thumbOff because default state of the switch is OFF
		protected function drawThumbs():void
		{
			drawThumbOff();
			drawThumbOn();
			if(thumb == null)
			{
				thumb = thumbOff;
			}
		}
		
		//Thumb ON the right side; Thumb OFF is on the left side
		protected function layoutThumbs():void
		{
			setElementPosition(thumbOn,trackWidth/2,0);
			setElementPosition(thumbOff,0,0);
		}
		
		//Label display sould be at the same location as the thumb
		protected function layoutLabel():void
		{
			if(selectedLabelDisplay != null)
			{
				if(currentState.indexOf("AndSelected") != -1)
				{
					setElementPosition(selectedLabelDisplay,trackWidth/2,0);
				}
				else
				{
					setElementPosition(selectedLabelDisplay,0,0);
				}
			}
		}
		
		//Depending on current state, set skinpart thumb accordingly
		protected function toggleSelectionState():void
		{
			if(currentState.indexOf("AndSelected") != -1)
			{
				thumbOn.visible = true;
				thumbOff.visible = false;
				thumb = thumbOn;
				selectedLabelDisplay.text = selectedLabel;
			}
			else
			{
				thumbOff.visible = true;
				thumbOn.visible = false;
				thumb = thumbOff;
				selectedLabelDisplay.text = unselectedLabel;
			}
		}
		
		protected function drawThumbOn():void
		{
			thumbOn = new switchOn();
			thumbOn.width = layoutThumbWidth;
			thumbOn.height = layoutThumbHeight;
			contents.addChildAt(SpriteVisualElement(thumbOn),1);
		}
		
		protected function drawThumbOff():void
		{
			thumbOff = new switchOff();
			thumbOff.width = layoutThumbWidth;
			thumbOff.height = layoutThumbHeight;
			contents.addChildAt(SpriteVisualElement(thumbOff),1);
		}
		
		//Hostcomponent dispatches this event whenever the thumb position changes	
		protected function thumbPositionChanged_handler(event:Event):void
		{
			moveSlidingContent();
		}
		
		//Move the current thumb and label along with the animating content 
		protected function moveSlidingContent():void 
		{
			if (!hostComponent)
				return;
			var x:Number = (track.getLayoutBoundsWidth() - thumb.getLayoutBoundsWidth()) * 
				hostComponent.thumbPosition + track.getLayoutBoundsX();
			var y:Number = thumb.getLayoutBoundsY();
			setElementPosition(thumb, x, y);
			setElementPosition(selectedLabelDisplay, x, y);
		}
	}
}


import flash.events.Event;

import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.components.supportClasses.StyleableTextField;
import spark.core.IDisplayText;

use namespace mx_internal;

/**
 *  @private
 *  Component combining two labels to create the effect of text and its drop
 *  shadow. The component can be used with advanced style selectors and the
 *  styles "color", "textShadowColor", and "textShadowAlpha". Based off of
 *  ActionBar.TitleDisplayComponent. These two should eventually be factored.
 */
class LabelDisplayComponent extends UIComponent implements IDisplayText
{
	public var shadowYOffset:Number = 0;
	private var labelChanged:Boolean = false;
	private var labelDisplay:StyleableTextField;
	private var labelDisplayShadow:StyleableTextField;
	private var _text:String;
	
	public function LabelDisplayComponent() 
	{
		super();
		_text = "";
	}
	
	override public function get baselinePosition():Number 
	{
		return labelDisplay.baselinePosition;
	}
	
	override protected function createChildren():void 
	{
		super.createChildren();
		
		labelDisplay = StyleableTextField(createInFontContext(StyleableTextField));
		labelDisplay.styleName = this;
		labelDisplay.editable = false;
		labelDisplay.selectable = false;
		labelDisplay.multiline = false;
		labelDisplay.wordWrap = false;
		labelDisplay.addEventListener(FlexEvent.VALUE_COMMIT,
			labelDisplay_valueCommitHandler);
		
		labelDisplayShadow = StyleableTextField(createInFontContext(StyleableTextField));
		labelDisplayShadow.styleName = this;
		labelDisplayShadow.colorName = "textShadowColor";
		labelDisplayShadow.editable = false;
		labelDisplayShadow.selectable = false;
		labelDisplayShadow.multiline = false;
		labelDisplayShadow.wordWrap = false;
		
		addChild(labelDisplayShadow);
		addChild(labelDisplay);
	}
	
	override protected function commitProperties():void 
	{
		super.commitProperties();
		
		if (labelChanged)
		{
			labelDisplay.text = text;
			invalidateSize();
			invalidateDisplayList();
			labelChanged = false;
		}
	}
	
	override protected function measure():void 
	{
		if (labelDisplay.isTruncated)
			labelDisplay.text = text;
		labelDisplay.commitStyles();
		measuredWidth = labelDisplay.getPreferredBoundsWidth();
		measuredHeight = labelDisplay.getPreferredBoundsHeight();
	}
	
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
	{
		if (labelDisplay.isTruncated)
			labelDisplay.text = text;
		labelDisplay.commitStyles();
		
		var labelHeight:Number = labelDisplay.getPreferredBoundsHeight();
		var labelY:Number = (unscaledHeight - labelHeight) / 2;
		
		var labelWidth:Number = Math.min(unscaledWidth, labelDisplay.getPreferredBoundsWidth());
		var labelX:Number = (unscaledWidth - labelWidth) / 2;
		
		labelDisplay.setLayoutBoundsSize(labelWidth, labelHeight);
		labelDisplay.setLayoutBoundsPosition(labelX, labelY);
		
		labelDisplay.truncateToFit();
		
		labelDisplayShadow.commitStyles();
		labelDisplayShadow.setLayoutBoundsSize(labelWidth, labelHeight);
		labelDisplayShadow.setLayoutBoundsPosition(labelX, labelY + shadowYOffset);
		
		labelDisplayShadow.alpha = getStyle("textShadowAlpha");
		
		// unless the label was truncated, labelDisplayShadow.text was set in
		// the value commit handler
		if (labelDisplay.isTruncated)
			labelDisplayShadow.text = labelDisplay.text;
	}
	
	private function labelDisplay_valueCommitHandler(event:Event):void 
	{
		labelDisplayShadow.text = labelDisplay.text;
	}
	
	public function get text():String 
	{
		return _text;
	}
	
	public function set text(value:String):void 
	{
		_text = value;
		labelChanged = true;
		invalidateProperties();
	}
	
	public function get isTruncated():Boolean 
	{
		return labelDisplay.isTruncated;
	}
	
	public function showShadow(value:Boolean):void 
	{
		labelDisplayShadow.visible = value;
	}
}