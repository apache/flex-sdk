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
    import mx.graphics.SolidColor;

    import spark.events.ColorChangeEvent;
    import spark.events.DropDownEvent;
    import spark.utils.ColorPickerUtil;

    /**
     * Dispatched when a color is choosed
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    [Event(name="choose", type="spark.events.ColorChangeEvent")]
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

        /**
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function ColorPicker() {
            super();
        }

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
            var util:ColorPickerUtil = new ColorPickerUtil();
            super.dataProvider = ColorPickerUtil.getColorsList();
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
            if (solidColor) {
                solidColor.color = selectedItem;
                dispatchEvent(new ColorChangeEvent(ColorChangeEvent.CHOOSE, selectedItem));
            }
        }

        /**
         * We never allow the dataProvider to be set
         *
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        override public function set dataProvider(value:IList):void {

        }

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
                solidColor.color = selectedItem;
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

        /**
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        override public function set selectedItem(value:*):void {
            super.selectedItem = value;
            if (solidColor) {
                solidColor.color = value;
            }
        }

        /**
         * Duplicate of selectedItem property, just for naming to be right
         *
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function set selectedColor(value:uint):void {
            selectedItem = value;
        }

        public function get selectedColor():uint {
            return selectedItem;
        }
    }
}
