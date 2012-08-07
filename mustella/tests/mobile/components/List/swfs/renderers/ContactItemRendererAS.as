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
package renderers
{
    import mx.core.UITextField;
    import mx.core.mx_internal;
    
    use namespace mx_internal;
    
    import spark.components.LabelItemRenderer;
    import flash.geom.Matrix;
    
    /**
    * 
    * TODO... clean this up and make sure its optimized
    * and make sure RyaFN reviews it
    */
    public class ContactItemRendererAS extends LabelItemRenderer
    {
        
        /**
        * This keeps track of whether the current renderer is a heading 
        * like for "A", "B", etc.
        */
        private var isHeading:Boolean = false;
        
        public function ContactItemRendererAS()
        {
            super();
            this.setStyle("fontSize", 32);
        }
        
        override public function set data(value:Object):void
        {
            super.data = value;
            
            if (data == null)
                return;
            
            var string:String = data as String;
            
            // strings that are only a character long are assumed to be headings
            if (string.length == 1)
                isHeading = true;
            else
                isHeading = false;
        }
        
        override protected function measure():void
        {
            super.measure();
            
            if (labelDisplay)
            {
                // reset text if it was truncated before.
                if (labelDisplay.isTruncated)
                    labelDisplay.text = label;
                
                // commit styles so our text measurement is accurate
                labelDisplay.commitStyles();
                
                // Text respects padding right, left, top, and bottom
                measuredWidth = labelDisplay.textWidth + UITextField.TEXT_WIDTH_PADDING;
                measuredWidth += getStyle("paddingLeft") + getStyle("paddingRight");
                
                measuredHeight = labelDisplay.textHeight + UITextField.TEXT_HEIGHT_PADDING;
                measuredHeight += getStyle("paddingTop") + getStyle("paddingBottom");
            }
            
            // minimum height of 70 pixels
            var minimumHeight:Number = 70;
            
            measuredHeight = Math.max(measuredHeight, minimumHeight); 
            // TODO: SHouldn't this come from LabelItemRenderer.minHeight?  
            // Answer from RyaFN: 
            //
            //well for DPI reasons, yeah
            //but it can't grab it from minHeight
            //minheight is still zero
            //thats basically the line change i think we should make for DPI reasons
            //something like:
            // measuredHeight = Math.max(measuredHeight, getStyle("minClickableHeight"))
            // TODO: Still tho... why does minHeight have to be 0?
            
            measuredMinWidth = 0;
            measuredMinHeight = minimumHeight;
            
            if (isHeading)
            {
                measuredHeight = labelDisplay.textHeight;
                measuredMinHeight = measuredHeight;
            }
        }
        
        override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void 
        {
            // figure out which padding to use
            if (isHeading)
            {
                this.setStyle("paddingTop", 0);
                this.setStyle("paddingBottom", 0);
            } else 
            {
                this.setStyle("paddingTop", 10);
                this.setStyle("paddingBottom", 10);
            }
            
            // then call super
            super.layoutContents(unscaledWidth, unscaledHeight);
            
            // then set the htmlText
            var stringArray:Array = (data as String).split(" ");
            var text:String = "<b>" + stringArray[0] + "</b>"
            
            if (stringArray[1] != null && stringArray[1] != undefined)
                text += " " + stringArray[1];   
            
            labelDisplay.htmlText = text;
        }
        
        override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
        {
            // figure out backgroundColor
            var backgroundColor:uint;
            var drawBackground:Boolean = true;
            var downColor:* = getStyle("downColor");
            
            if (isHeading)
            {
                backgroundColor = 0xFF0000;
            }
            else if (down && downColor !== undefined)
            {
                backgroundColor = downColor;
            }
            else if (selected)
            {
                backgroundColor = getStyle("selectionColor");
            }
            else if (hovered)
            {
                backgroundColor = getStyle("rollOverColor");
            }
            else
            {
                var alternatingColors:Array;
                var alternatingColorsStyle:Object = getStyle("alternatingItemColors");
                
                if (alternatingColorsStyle)
                    alternatingColors = (alternatingColorsStyle is Array) ? (alternatingColorsStyle as Array) : [alternatingColorsStyle];
                
                if (alternatingColors && alternatingColors.length > 0)
                {
                    // translate these colors into uints
                    styleManager.getColorNames(alternatingColors);
                    
                    backgroundColor = alternatingColors[itemIndex % alternatingColors.length];
                }
                else
                {
                    // don't draw background if it is the contentBackgroundColor. The
                    // list skin handles the background drawing for us. 
                    drawBackground = false;
                }
            }
            
            // draw backgroundColor
            // the reason why we draw it in the case of drawBackground == 0 is for
            // mouse hit testing purposes
            // TODO: ignore caret for now
            graphics.beginFill(backgroundColor, drawBackground ? 1 : 0);
            graphics.lineStyle();
            graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
            graphics.endFill();
            
            if (backgroundColor == 0xFF0000){
                // draw the gradient too
                var colArray:Array = [0x909faa, 0xb8c1c8]; // your colors
                var alpArray:Array = [100, 100]; // your alphas
                var sprArray:Array = [0, 0xFF]; // gradient spread
                
                var myMatrix:Matrix = new Matrix();
                myMatrix.rotate(Math.PI / 2);
                
                graphics.beginGradientFill("linear", colArray, alpArray, sprArray, myMatrix);  
                graphics.lineStyle();
                graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
                graphics.endFill();
            }
            
            // draw the separator
            graphics.lineStyle(1, 0xe0e0e0);
            graphics.moveTo(0, unscaledHeight);
            graphics.lineTo(unscaledWidth, unscaledHeight);
        }
    }
}