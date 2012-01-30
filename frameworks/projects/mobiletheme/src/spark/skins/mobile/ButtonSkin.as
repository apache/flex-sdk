package spark.skins.mobile
{
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.core.UIComponent;
	import mx.utils.ColorUtil;
	
	import spark.components.Button;
	
	public class ButtonSkin extends UIComponent
	{	
		public function ButtonSkin()
		{
			super();
		}
		
		public var hostComponent:Button;
		
		//////////////////////////////////////////
		// Properties
		//////////////////////////////////////////
		
		// currentState
		private var _currentState:String;
		
		override public function get currentState():String
		{
			return _currentState;
		}
		
		override public function set currentState(value:String):void
		{
			if (value == _currentState)
				return;
			
			_currentState = value;
			
			applyFXG();
		}
		
		//////////////////////////////////////////
		// Methods
		//////////////////////////////////////////
		
		override protected function createChildren():void
		{
			// Set up text fields only if we have a hostComponent
			if(hostComponent != null) {
				var tf:TextFormat = new TextFormat;
				
				textField = new TextField();
				textFieldShadow = new TextField();

				tf = setTextFormat(tf);
				
				textField.defaultTextFormat = tf;
				tf.color = 0x000000;
				textFieldShadow.defaultTextFormat = tf;
				textFieldShadow.alpha = .20;
				
				addChild(textField);
				addChild(textFieldShadow);
				
				hostComponent.addEventListener("contentChange", handleContentChange);
			}
			
			applyFXG();
		}

		protected function handleContentChange(event:Event):void {
			updateLabel();
		}
		
		private function updateLabel():void {
			if(hostComponent != null) {
				textField.text = hostComponent.label;
				textFieldShadow.text = hostComponent.label;
				invalidateSize();
			}
		}
		
		override public function styleChanged(styleProp:String):void {
			// TODO: Refactor to check whether styleProp is one of three following value types and update 
			// the styles accordingly:
			// 1) Individual style name (e.g. "fontSize"). 2) "styleName". 3) null. 
			// If 1) reset only individual style. If 2) or 3), reset all styles
			
			// Only deal with text if a hostComponent exists and text fields are not empty
			if(hostComponent != null && textField != null && textFieldShadow != null) {
				var tf:TextFormat = textField.defaultTextFormat;

				tf = setTextFormat(tf);
				
				textField.setTextFormat(tf);
				tf.color = 0x000000;
				textFieldShadow.setTextFormat(tf);
				textFieldShadow.alpha = .20;
			}
			super.styleChanged(styleProp);
		}

		private function setTextFormat(tf:TextFormat):TextFormat {
			tf.align = "center";
			tf.color = getStyle("color");
			tf.font = getStyle("fontFamily");
			tf.size = getStyle("fontSize");
			tf.bold = getStyle("fontWeight") == "bold";
			
			return tf;
		}
		
		private function applyFXG():void {
			if (_currentState == "down") {
				if(bgImg != null) {
					removeChild(bgImg);
				}
				bgImg = new Button_bg_down();
			}
			else {
				if (!(bgImg is Button_bg_up)) {
					if(bgImg != null) {
						removeChild(bgImg);
					}
					bgImg = new Button_bg_up();
				}
			}
			
			if(bgImg != null) {
				addChild(bgImg);
				invalidateDisplayList();
			}
			
			if(_currentState == "disabled") {
				alpha = 0.5;
			}
			else
				alpha = 1;
		}
	
		override protected function commitProperties():void
		{
			updateLabel();
		}
		
		override protected function measure():void
		{
			// TODO: Minimum sizes should come from the embedded graphics.
			measuredWidth = textField.textWidth + 20;
			
			// graphic height
			measuredHeight = 42;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			graphics.clear();
			
			if(bgImg != null) {	
				bgImg.x = bgImg.y = 0.5;
				bgImg.width = unscaledWidth;
				bgImg.height = unscaledHeight;
			}
			
			// Set Text/Text Shadow position and size
			if(textField != null) {
				// Center the label
				textField.width = unscaledWidth;
				textField.height = textField.textHeight + 4;
				textField.y = Math.round((unscaledHeight - textField.height) / 2);
				
				// Center the label shadow
				textFieldShadow.width = unscaledWidth;
				textFieldShadow.height = textFieldShadow.textHeight + 4;
				textFieldShadow.y = textField.y + 1;
				
				// Put the label on top
				setChildIndex(textField, numChildren - 1);
				
				// set label shadow behind main label
				setChildIndex(textFieldShadow, numChildren - 2);
			}
			
			// Draw the gradient background
			matrix.createGradientBox(unscaledWidth - 1, unscaledHeight - 2, Math.PI / 2, 0, 0);
			var chromeColor:uint = getStyle("chromeColor");
			colors[0] = ColorUtil.adjustBrightness2(chromeColor, 20);
			colors[1] = chromeColor;
			colors[2] = ColorUtil.adjustBrightness2(chromeColor, -20);
			
			graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
			
			// Draw the background rectangle within the border, so the corners of the rect don't 
			// spill over into the rounded corners of the Button
			graphics.drawRect(1, 1, unscaledWidth - 1, unscaledHeight - 2);
			graphics.endFill();
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}

		//////////////////////////////////////////
		// Internals
		//////////////////////////////////////////
		
		private var textField:TextField;
		private var textFieldShadow:TextField;
		private var bgImg:DisplayObject;
		private static var matrix:Matrix = new Matrix();
		private static var alphas:Array = [1, 1, 1];
		private static var ratios:Array = [0, 127.5, 255];	
		private static var colors:Array = [];
	}
}