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
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.SoftKeyboardEvent;
	import flash.system.Capabilities;
	
	import mx.core.DPIClassification;
	import mx.core.EventPriority;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	import mx.utils.Platform;
	
	import spark.components.TextInput;
	import spark.components.supportClasses.StyleableTextField;
	import spark.skins.ios7.supportClasses.TextSkinBase;
	
	use namespace mx_internal;
	
	/**
	 *  ActionScript-based skin for TextInput controls in mobile applications. 
	 * 
	 * @see spark.components.TextInput
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.5 
	 *  @productversion Flex 4.5
	 */
	public class TextInputSkin extends TextSkinBase 
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
		 */
		public function TextInputSkin()
		{
			super();
			
			// on iOS, make adjustments for native text rendering
			_isIOS = Platform.isIOS;
			
			switch (applicationDPI)
			{
				case DPIClassification.DPI_640:
				{
					measuredDefaultWidth = 1200;
					measuredDefaultHeight = 132;
					layoutBorderSize = 3;
					roundheight = 24;
					break;
				}
				case DPIClassification.DPI_480:
				{

					measuredDefaultWidth = 880;
					measuredDefaultHeight = 100;
					layoutBorderSize = 2;
					roundheight = 18;			
					break;
				}
				case DPIClassification.DPI_320:
				{
					measuredDefaultWidth = 600;
					measuredDefaultHeight = 66;
					layoutBorderSize = 1.5;
					roundheight = 14;			
					break;
				}
				case DPIClassification.DPI_240:
				{
					measuredDefaultWidth = 440;
					measuredDefaultHeight = 50;
					layoutBorderSize = 1;
					roundheight = 10;
					break;
				}
				case DPIClassification.DPI_120:
				{
					measuredDefaultWidth = 220;
					measuredDefaultHeight = 25;
					layoutBorderSize = .5;
					roundheight = 5;				
					break;
				}
				default:
				{
					measuredDefaultWidth = 300;
					measuredDefaultHeight = 33;
					layoutBorderSize = .5;
					roundheight = 7; 
					break;
				}
			}
			addEventListener(FocusEvent.FOCUS_IN, focusChangeHandler);
			addEventListener(FocusEvent.FOCUS_OUT, focusChangeHandler);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		protected var isFocused:Boolean = false;
		
		protected var roundheight:uint;
		
		/** 
		 *  @copy spark.skins.spark.ApplicationSkin#hostComponent
		 */
		public var hostComponent:TextInput;  // SkinnableComponent will populate
			
		/**
		 *  @private
		 */
		private var _isIOS:Boolean;
		
		/**
		 *  @private
		 */
		private var _isEditing:Boolean;
		
		/**
		 *  @private
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			textDisplay.addEventListener("editableChanged", editableChangedHandler);
			textDisplay.addEventListener(FlexEvent.VALUE_COMMIT, valueCommitHandler);
			
			// remove hit area improvements on iOS when editing
			if (_isIOS)
			{
				textDisplay.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, textDisplay_softKeyboardActivatingHandler, false, EventPriority.DEFAULT_HANDLER);
				textDisplay.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, textDisplay_softKeyboardDeactivateHandler);
			}
		}
		
		/**
		 *  @private
		 */
		override protected function measure():void
		{
			super.measure();
			
			var paddingLeft:Number = getStyle("paddingLeft");
			var paddingRight:Number = getStyle("paddingRight");
			var paddingTop:Number = getStyle("paddingTop");
			var paddingBottom:Number = getStyle("paddingBottom");
			var textHeight:Number = getStyle("fontSize") as Number;
			
			if (textDisplay)
			{
				// temporarily change text for measurement
				var oldText:String = textDisplay.text;
				
				// commit styles so we can get a valid textHeight
				textDisplay.text = "Wj";
				textDisplay.commitStyles();
				
				textHeight = textDisplay.measuredTextSize.y;
				textDisplay.text = oldText;
			}
			
			// width is based on maxChars (if set)
			if (hostComponent && hostComponent.maxChars)
			{
				// Grab the fontSize and subtract 2 as the pixel value for each character.
				// This is just an approximation, but it appears to be a reasonable one
				// for most input and most font.
				var characterWidth:int = Math.max(1, (getStyle("fontSize") - 2));
				measuredWidth =  (characterWidth * hostComponent.maxChars) + 
					paddingLeft + paddingRight + StyleableTextField.TEXT_WIDTH_PADDING;
			}
			
			measuredHeight = paddingTop + textHeight + paddingBottom;
		}
		
		/**
		 *  @private
		 */
		override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.layoutContents(unscaledWidth, unscaledHeight);
			
			// position & size border
			if (border)
			{
				setElementSize(border, unscaledWidth, unscaledHeight);
				setElementPosition(border, 0, 0);
			}
			
			// position & size the text
			var paddingLeft:Number = getStyle("paddingLeft");
			var paddingRight:Number = getStyle("paddingRight");
			var paddingTop:Number = getStyle("paddingTop");
			var paddingBottom:Number = getStyle("paddingBottom");
			
			var unscaledTextWidth:Number = unscaledWidth - paddingLeft - paddingRight;
			var unscaledTextHeight:Number = unscaledHeight - paddingTop - paddingBottom;
			
			// default vertical positioning is centered
			var textHeight:Number = getElementPreferredHeight(textDisplay);
			var textY:Number = Math.round(0.5 * (unscaledTextHeight - textHeight)) + paddingTop;
			
			// On iOS the TextField top and bottom edges are bounded by the padding.
			// On all other platforms, the height of the textDisplay is
			// textHeight + paddingBottom to increase hitArea on bottom.
			// Note: We don't move the Y position upwards because TextField
			// has way to set vertical positioning.
			// Note: iOS is a special case due to the clear button provided by the
			// native text control used while editing.
			var adjustedTextHeight:Number = (_isIOS && _isEditing) ? textHeight : textHeight + paddingBottom;
			
			if (textDisplay)
			{
				// We're going to do a few tricks to try to increase the size of our hitArea to make it 
				// easier for users to select text or put the caret in a certain spot.  To do that, 
				// rather than set textDisplay.x=paddingLeft,  we are going to set 
				// textDisplay.leftMargin = paddingLeft.  In addition, we're going to size the height 
				// of the textDisplay larger than just the size of the text inside to increase the hitArea
				// on the bottom.  We'll also assign textDisplay.rightMargin = paddingRight to increase the 
				// the hitArea on the right.  Unfortunately, there's no way to increase the hitArea on the top
				// just yet, but these three tricks definitely help out with regards to user experience.  
				// See http://bugs.adobe.com/jira/browse/SDK-29406 and http://bugs.adobe.com/jira/browse/SDK-29405
				
				// set leftMargin, rightMargin to increase the hitArea.  Need to set it before calling commitStyles().
				var marginChanged:Boolean = ((textDisplay.leftMargin != paddingLeft) || 
					(textDisplay.rightMargin != paddingRight));
				
				textDisplay.leftMargin = paddingLeft;
				textDisplay.rightMargin = paddingRight;
				
				// need to force a styleChanged() after setting leftMargin, rightMargin if they 
				// changed values.  Then we can validate the styles through commitStyles()
				if (marginChanged)
					textDisplay.styleChanged(null);
				textDisplay.commitStyles();
				
				setElementSize(textDisplay, unscaledWidth, adjustedTextHeight);
				
				// set x=0 since we're using textDisplay.leftMargin = paddingLeft
				setElementPosition(textDisplay, 0, textY);
			}
			
			if (promptDisplay)
			{
				promptDisplay.commitStyles();
				setElementSize(promptDisplay, unscaledTextWidth, adjustedTextHeight);
				setElementPosition(promptDisplay, paddingLeft, textY);
			}
		}
		
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.drawBackground(unscaledWidth, unscaledHeight);
			
			var contentBackgroundColor:uint = getStyle("contentBackgroundColor");
			var contentBackgroundAlpha:Number = getStyle("contentBackgroundAlpha");	
			//change border color and thickness when in focus
			var borderColor:uint = isFocused ? getStyle("focusColor") : getStyle("borderColor");
			var borderWidth:uint = layoutBorderSize * 2;
			if (isNaN(contentBackgroundAlpha))
			{
				contentBackgroundAlpha = 1;
			}        
			if (getStyle("contentBackgroundBorder") == "roundedrect")
			{		
				graphics.lineStyle(layoutBorderSize, borderColor, 1, true);
				graphics.beginFill(contentBackgroundColor, contentBackgroundAlpha);
				graphics.drawRoundRectComplex(layoutBorderSize, layoutBorderSize, unscaledWidth - borderWidth, unscaledHeight - borderWidth, roundheight, roundheight, roundheight, roundheight);
				graphics.endFill();
			}
			if (getStyle("contentBackgroundBorder") == "rectangle")
			{
				
				//rectangle border and background
				graphics.lineStyle(layoutBorderSize, borderColor, 1);
				graphics.beginFill(contentBackgroundColor, contentBackgroundAlpha);
				graphics.drawRect(layoutBorderSize, layoutBorderSize, unscaledWidth - borderWidth, unscaledHeight - borderWidth);
				graphics.endFill();
			}
			else if (getStyle("contentBackgroundBorder") == "none")
			{
				
				//rectangle border and background
				graphics.beginFill(contentBackgroundColor, contentBackgroundAlpha);
				graphics.drawRect(0, 0, unscaledWidth - borderWidth, unscaledHeight - borderWidth);
				graphics.endFill();
			}
		}
		
		/**
		 *  @private
		 */
		private function editableChangedHandler(event:Event):void
		{
			invalidateDisplayList();
		}
		
		/**
		 *  @private
		 *  The text changed in some way.
		 * 
		 *  Dynamic fields (ie !editable) with no text measure with width=0 and height=0.
		 *  If the text changed, need to remeasure the text to get the correct height so it
		 *  will be laid out correctly.
		 */
		private function valueCommitHandler(event:Event):void
		{
			if (textDisplay && !textDisplay.editable)
				invalidateDisplayList();
		}
		
		/**
		 *  @private
		 */
		private function textDisplay_softKeyboardActivatingHandler(event:SoftKeyboardEvent):void
		{
			if (event.isDefaultPrevented())
				return;
			
			_isEditing = true;
			invalidateDisplayList();
		}
		
		/**
		 *  @private
		 */
		private function textDisplay_softKeyboardDeactivateHandler(event:SoftKeyboardEvent):void
		{
			_isEditing = false;
			invalidateDisplayList();
		}
		
		private function focusChangeHandler(event:FocusEvent):void
		{
			isFocused = event.type == FocusEvent.FOCUS_IN;
			invalidateDisplayList();		
		}
	}
}