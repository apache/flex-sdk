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
package spark.components {
    import flash.display.DisplayObject;
    import flash.events.Event;
    
    import mx.collections.IList;
    import mx.events.FlexEvent;
    import mx.graphics.SolidColor;
    
    import spark.events.ColorChangeEvent;
    import spark.events.DropDownEvent;
    import spark.primitives.Line;
    import spark.utils.ColorPickerUtil;

    /**
     * Dispatched when a color is chosen
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    [Event(name="choose", type="spark.events.ColorChangeEvent")]
    /**
     * Dispatched when a null color is chosen. Useful for removing color.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
	[Event(name="nocolor", type="spark.events.ColorChangeEvent")]
	/**
	 * Dispatched when a color is hovered. Might be usefull in 'preview' situations
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10.1
	 *  @playerversion AIR 2.5
	 *  @productversion Flex 4.5
	 */
    [Event(name="hover", type="spark.events.ColorChangeEvent")]
    /**
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ /**
     *  Subclass DropDownList and make it work like a ColorPicker
     *
     */ /**
     * @author Bogdan Dinu (http://www.badu.ro)
     */ public class ColorPicker extends ComboBox {
        /**
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        [SkinPart(required="true")]
        public var solidColor:SolidColor;
		
		[SkinPart(required="false")]
		public var noColorOrnament:Line;
        /**
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function ColorPicker() {
            super();
			if (!isModelInited)
				loadDefaultPalette();

        }
		/**
		 *  @private
		 */
		private var indexFlag:Boolean = false;

        /**
         * Upon children creation, we're setting the dataprovider to the colors list
         *
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        override protected function childrenCreated():void {
            super.childrenCreated();
            labelFunction = blankLabelFunction;
            labelToItemFunction = colorFunction;
            openOnInput = false;
            addEventListener(Event.CHANGE, onColorChange);
        }

        /**
         * Label function is required to be blank all the time
         *
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        private static function blankLabelFunction(item:Object):String {
            return "";
        }

        /**
         * Converts the value to uint
         *
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        private static function colorFunction(value:String):* {
            return uint(value);
        }

        /**
         * We're dispatching our event, instead of Event.CHANGE
         *
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        private function onColorChange(event:Event):void {
			if(selectedItem === null){
				solidColor.color = getColor(-1);
				if(noColorOrnament)
					noColorOrnament.visible = true;
				dispatchEvent(new ColorChangeEvent(ColorChangeEvent.NO_COLOR,0));
				return;
			}
			var newColor:uint = getColor(selectedIndex);
            if (solidColor) {
                solidColor.color = newColor;
				if(noColorOrnament)
					noColorOrnament.visible = false;
            }
			var ev:ColorChangeEvent = new ColorChangeEvent(ColorChangeEvent.CHOOSE, newColor);
			if(typeof(selectedItem) == "object"){
				ev.colorObject = selectedItem;
			}
			dispatchEvent(ev);
        }

		/**
		 *  @private
		 *  The dataProvider for the ColorPicker control.
		 *  The default dataProvider is an Array that includes all
		 *  the web-safe colors.
		 *
		 */
		override public function set dataProvider(value:IList):void
		{
			super.dataProvider = value;
			
			isModelInited = true;
			
		}

/*        /**
         * We never allow the dataProvider to be set
         *
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
/*
        override public function set dataProvider(value:IList):void {

        }
*/
        /**
         * Initialization of the selected color
         *
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        override protected function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);
            if (instance == solidColor) {
                solidColor.color = selectedColor;
            } else if(instance == textInput){
				textInput.editable = editable;
			} else if(instance == noColorOrnament){
				noColorOrnament.visible = selectedItem === null;
			}
		}

        /**
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        override public function setFocus():void {
            stage.focus = this;
        }

        /**
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        override protected function isOurFocus(target:DisplayObject):Boolean {
            return target === this;
        }

        /**
         * The default behavior is prevented
         *
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        override protected function dropDownController_closeHandler(event:DropDownEvent):void {
            event.preventDefault();
            super.dropDownController_closeHandler(event);
        }

		//----------------------------------
		//  selectedColor
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the selectedColor property.
		 */
		private var _selectedColor:uint = 0x000000;
		
		[Bindable("change")]
		[Bindable("valueCommit")]
		[Inspectable(category="General", defaultValue="0", format="Color")]
		
		/**
		 *  The value of the currently selected color in the
		 *  SwatchPanel object. 
		 *  In the &lt;s:ColorPicker&gt; tag only, you can set this property to 
		 *  a standard string color name, such as "blue".
		 *  If the dataProvider contains an entry for black (0x000000), the
		 *  default value is 0; otherwise, the default value is the color of
		 *  the item at index 0 of the data provider.
		 *
		 *  @helpid 4932
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get selectedColor():uint
		{
			return _selectedColor;
		}
		
		/**
		 *  @private
		 */
		public function set selectedColor(value:uint):void
		{
			if (!indexFlag)
			{
				super.selectedIndex = findColorByName(value);
			}
			else
			{
				indexFlag = false;
			}
			
			if (value != selectedColor)
			{
				_selectedColor = value;
				
				//updateColor(value);
				
				if (solidColor){
					solidColor.color = value;
					dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
				}
				if(noColorOrnament){
					if(selectedIndex < 0){
						noColorOrnament.visible = false;
					} else {
						noColorOrnament.visible = dataProvider.getItemAt(selectedIndex) === null;
					}
				}
			}
			
		}

		//----------------------------------
		//  editable
		//----------------------------------
		
		[Bindable("editableChanged")]
		[Inspectable(category="General", defaultValue="true")]
		
		/**
		 *  @private
		 */
		private var _editable:Boolean = true;
		
		/**
		 *  @private
		 *  Specifies whether the user can type a hexadecimal color value
		 *  in the text box.
		 *
		 *  @default true
		 *  @helpid 4930
		 */
		public function get editable():Boolean
		{
			return _editable;
		}
		
		/**
		 *  @private
		 */
		public function set editable(value:Boolean):void
		{
			_editable = value;
			
			if (textInput)
				textInput.editable = value;
			
			dispatchEvent(new Event("editableChanged"));
		}
		
		//----------------------------------
		//  selectedIndex
		//----------------------------------
		
		[Bindable("change")]
		[Bindable("collectionChange")]
		[Inspectable(defaultValue="0")]
		
		/**
		 *  Index in the dataProvider of the selected item in the
		 *  SwatchPanel object.
		 *  Setting this property sets the selected color to the color that
		 *  corresponds to the index, sets the selected index in the drop-down
		 *  swatch to the <code>selectedIndex</code> property value, 
		 *  and displays the associated label in the text box.
		 *  The default value is the index corresponding to 
		 *  black(0x000000) color if found, else it is 0.
		 *
		 *  @helpid 4931
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		override public function set selectedIndex(value:int):void
		{
			if ((selectedIndex != -1 || !isNaN(selectedColor)) &&
				value != selectedIndex)
			{
				if (value >= 0)
				{
					indexFlag = true;
					selectedColor = getColor(value);
					// Call super in mixed-in DataSelector
					super.selectedIndex = value;
				}
				
				if (solidColor)
					solidColor.color = selectedColor;
				if(noColorOrnament){
					noColorOrnament.visible = dataProvider.getItemAt(value) === null;
				}
			}
		}
		
		//----------------------------------
		//  selectedItem
		//----------------------------------
		
		[Bindable("change")]
		[Bindable("collectionChange")]
		[Inspectable(defaultValue="0")]
		
		/**
		 *  @private
		 *  If the dataProvider is a complex object, this property is a
		 *  reference to the selected item in the SwatchPanel object.
		 *  If the dataProvider is an Array of color values, this
		 *  property is the selected color value.
		 *  If the dataProvider is a complex object, modifying fields of
		 *  this property modifies the dataProvider and its views.
		 *
		 *  <p>If the dataProvider is a complex object, this property is
		 *  read-only. You cannot change its value directly.
		 *  If the dataProvider is an Array of hexadecimal color values,
		 *  you can change this value directly. 
		 *  The default value is undefined for complex dataProviders;
		 *  0 if the dataProvider is an Array of color values.
		 *
		 */
		override public function set selectedItem(value:*):void
		{
			if (value != selectedItem)
			{
				// Call super in mixed-in DataSelector
				super.selectedItem = value;
				
				if (typeof(value) == "object")
					selectedColor = Number(value[colorField]);
				else if (typeof(value) == "number")
					selectedColor = Number(value);
				
				indexFlag = true;
				
				if (solidColor)
					solidColor.color = selectedColor;
			}
		}

		//----------------------------------
		//  colorField
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the colorField property.
		 */
		private var _colorField:String = "color";
		
		[Bindable("colorFieldChanged")]
		[Inspectable(category="Data", defaultValue="color")]
		
		/**
		 *  Name of the field in the objects of the dataProvider Array that
		 *  specifies the hexadecimal values of the colors that the swatch
		 *  panel displays.
		 *
		 *  <p>If the dataProvider objects do not contain a color
		 *  field, set the <code>colorField</code> property to use the correct field name.
		 *  This property is available, but not meaningful, if the
		 *  dataProvider is an Array of hexadecimal color values.</p>
		 *
		 *  @default "color"
		 *  @helpid 4927
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get colorField():String
		{
			return _colorField;
		}
		
		/**
		 *  @private
		 */
		public function set colorField(value:String):void
		{
			_colorField = value;
			
			dispatchEvent(new Event("colorFieldChanged"));
		}

		/**
		 *  @private
		 *  Load Default Palette
		 */
		private function loadDefaultPalette():void
		{
			// Initialize default swatch list
			if (!dataProvider || dataProvider.length < 1)
			{
				dataProvider = ColorPickerUtil.getColorsList();

			}
			//selectedIndex = findColorByName(selectedColor);
		}

		
		/**
		 *  @public
		 *  Find Color by Name
		 */
		public function findColorByName(name:Number):int
		{
			if (name == getColor(selectedIndex))
				return selectedIndex;
			
			var n:int = dataProvider.length;
			for (var i:int = 0; i < dataProvider.length; i++)
			{
				if (name == getColor(i))
					return i;
			}
			
			return -1;
		}
		
		/**
		 *  @public
		 *  Get the color value of a color object or color value
		 */
		public function getColorValue(color:*):uint
		{
			return Number(typeof(color) == "object" && color!=null ? color[colorField] : color);
		}

		/**
		 *  @public
		 *  Get the color name of a color object
		 */
		public function getColorName(color:*):String
		{
			if(typeof(color) == "object"){
				if(color){
					return color[labelField];
				}
				return "";
			}
			return ColorPickerUtil.uint2hex(color as uint);
		}
		
		/**
		 *  @private
		 */
		private var isModelInited:Boolean = false;

		/**
		 *  @private
		 *  Get Color Value
		 */
		private function getColor(location:int):Number
		{
			if (!dataProvider || dataProvider.length < 1 ||
				location < 0 || location >= dataProvider.length)
			{
				return -1;
			}
			var item:* = dataProvider.getItemAt(location);
			if(typeof(item) == "object"){
				return item === null ? -1 : Number(item[colorField]);
			}
			return Number(item);
		}

    }
}
