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

package spark.components
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	import spark.components.richTextEditorClasses.RichTextEditorToolBar;
	import spark.events.TextOperationEvent;

	// for asdoc
	[Experimental]
	[Event(name = "change", type = "flash.events.Event")]
	[Style(name = "borderColor", inherit = "no", type = "unit")]
	[Style(name = "focusColor", inherit = "yes", type = "unit")]
	public class RichTextEditor extends Group
	{
		private var _htmlText:String;
		private var _htmlTextChanged:Boolean = false;
		private var _prompt:String = "";
		private var _stylesChanged:Dictionary = new Dictionary;
		private var _text:String;
		private var _textArea:TextArea;
		private var _textFlow:TextFlow;

		public function RichTextEditor()
		{
			super();
			this.textFlow = new TextFlow; //Prevents a stack trace that happends when you try to access the textflow on click.
		}

		[Bindable("change")]
		/**
		 *  The htmlText property is here for convenience. It converts the textFlow to TextConverter.TEXT_FIELD_HTML_FORMAT.
		 */
		public function get htmlText():String
		{
			if (_htmlTextChanged)
			{
				if (text == "")
				{
					_htmlText = "";
				}
				else
				{
					_htmlText = TextConverter.export(textFlow, TextConverter.TEXT_FIELD_HTML_FORMAT, ConversionType.STRING_TYPE) as String;
				}
				_htmlTextChanged = false;
			}
			return _htmlText;
		}

		/**
		 *  The htmlText property is here for convenience. It converts the textFlow to TextConverter.TEXT_FIELD_HTML_FORMAT.
		 */
		public function set htmlText(value:String):void
		{
			if (htmlText != value)
			{
				_htmlText = value;
				if (textFlow)
				{
					textFlow = TextConverter.importToFlow(_htmlText, TextConverter.TEXT_FIELD_HTML_FORMAT);
				}
			}
		}

		/**
		 *  @private
		 */
		public function get prompt():String
		{
			return _prompt;
		}

		/**
		 *  @private
		 */
		public function set prompt(value:String):void
		{
			_prompt = value;
			if (_textArea)
			{
				_textArea.prompt = _prompt;
			}
		}

		/**
		 *  @private
		 */
		public override function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);
			_stylesChanged[styleProp] = getStyle(styleProp);
			this.invalidateDisplayList();
		}

		[Bindable("change")]
		/**
		 *  The text in the textArea
		 */
		public function get text():String
		{
			if (_textArea)
			{
				return _textArea.text;
			}
			else
			{
				return _text;
			}
		}

		/**
		 *  @private
		 */
		public function set text(value:String):void
		{
			_text = value;
			if (_textArea)
			{
				_textArea.text = value;
			}
		}

		[Bindable("change")]
		/**
		 *  The textFlow
		 */
		public function get textFlow():TextFlow
		{
			return _textFlow;
		}

		/**
		 *  @private
		 */
		public function set textFlow(value:TextFlow):void
		{
			_textFlow = value;
			if (_textArea)
			{
				_textArea.textFlow = value;
			}
		}

		/**
		 *  @private
		 */
		protected override function createChildren():void
		{
			super.createChildren();
			var container:VGroup = new VGroup;
			container.percentHeight = 100;
			container.percentWidth = 100;
			this.addElement(container);

			var toolbar:RichTextEditorToolBar = new RichTextEditorToolBar();
			toolbar.percentWidth = 100;
			toolbar.bottom = 6;
			container.addElement(toolbar);

			_textArea = new TextArea();
			_textArea.percentHeight = 100;
			_textArea.percentWidth = 100;
			_textArea.addEventListener(TextOperationEvent.CHANGE, handleChange);
			_textArea.prompt = prompt;
			_textArea.textFlow = textFlow;
			if (_htmlText)
			{
				textFlow = TextConverter.importToFlow(_htmlText, TextConverter.TEXT_FIELD_HTML_FORMAT);
			}
			else if (_text)
			{
				_textArea.text = _text;
			}
			container.addElement(_textArea);

			toolbar.textArea = _textArea;
		}

		/**
		 *  @private
		 */
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if (_textArea)
			{
				for (var key:String in _stylesChanged)
				{
					_textArea.setStyle(key, _stylesChanged[key]);
				}
				_stylesChanged = new Dictionary; //Clear it out
			}
		}

		/**
		 *  @private
		 */
		private function handleChange(e:Event):void
		{
			_htmlTextChanged = true;
			this.dispatchEvent(e);
		}
	}
}
