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

package spark.skins.android4.supportClasses
{
	
	import flash.display.DisplayObject;
	
	import mx.core.mx_internal;
	
	import spark.components.supportClasses.StyleableTextField;
	import spark.skins.mobile.supportClasses.MobileSkin;
	
	use namespace mx_internal;
	
	/**
	 *  ActionScript-based skin for text input controls in mobile applications that
	 *  uses a StyleableTextField class for the text display. 
	 * 
	 *  @see spark.components.supportClasses.StyleableTextField
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.5 
	 *  @productversion Flex 4.5
	 */
	public class TextSkinBase extends MobileSkin 
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
		public function TextSkinBase()
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Graphics variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Defines the border.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5 
		 *  @productversion Flex 4.5
		 */  
		
		//--------------------------------------------------------------------------
		//
		//  Layout variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Defines the corner radius.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5 
		 *  @productversion Flex 4.5
		 */  
		
		protected var layoutBorderSize:uint;
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 * 
		 *  Instance of the border graphics.
		 */
		protected var border:DisplayObject;
		
		private var borderVisibleChanged:Boolean = false;
		
		//--------------------------------------------------------------------------
		//
		//  Skin parts
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  textDisplay skin part.
		 */
		public var textDisplay:StyleableTextField;
		
		[Bindable]
		/**
		 *  Bindable promptDisplay skin part. Bindings fire when promptDisplay is
		 *  removed and added for proper updating by the SkinnableTextBase.
		 */
		public var promptDisplay:StyleableTextField;
		
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
			super.createChildren();
			
			if (!textDisplay)
			{
				textDisplay = StyleableTextField(createInFontContext(StyleableTextField));
				textDisplay.styleName = this;
				textDisplay.editable = true;
				textDisplay.useTightTextBounds = false;
				addChild(textDisplay);
			}
		}
		
		/**
		 *  @private 
		 */ 
		protected function createPromptDisplay():StyleableTextField
		{
			var prompt:StyleableTextField = StyleableTextField(createInFontContext(StyleableTextField));
			prompt.styleName = this;
			prompt.editable = false;
			prompt.mouseEnabled = false;
			prompt.useTightTextBounds = false;
			prompt.focusEnabled = false;
			return prompt;
		}
	
		/**
		 *  @private
		 */

		override public function styleChanged(styleProp:String):void
		{
			var allStyles:Boolean = !styleProp || styleProp == "styleName";
			
			if (allStyles || styleProp == "borderVisible")
			{
				borderVisibleChanged = true;
				invalidateProperties();
			}
			
			if (allStyles || styleProp.indexOf("padding") == 0)
			{
				invalidateDisplayList();
			}
			
			super.styleChanged(styleProp);
		}
		
		/**
		 *  @private
		 */
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			
			alpha = currentState.indexOf("disabled") == -1 ? 1 : 0.5;
			
			var showPrompt:Boolean = currentState.indexOf("WithPrompt") >= 0;
			
			if (showPrompt && !promptDisplay)
			{
				promptDisplay = createPromptDisplay();
				addChild(promptDisplay);
			}
			else if (!showPrompt && promptDisplay)
			{
				removeChild(promptDisplay);
				promptDisplay = null;
			}
			
			invalidateDisplayList();
		}   
	}
}