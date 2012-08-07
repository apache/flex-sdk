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
    import flash.display.GradientType;
    import flash.geom.Matrix;
    import flash.text.TextLineMetrics;
    
    import mx.core.UITextField;
    import mx.core.mx_internal;
    
    import spark.components.DataGroup;
    import renderers.InstrumentedLabelItemRenderer;
    import spark.components.supportClasses.StyleableTextField;
    
    use namespace mx_internal;
    
    /**
    * 
    * This subclass copies the drawBackground and layoutContents methods of LabelItemRenderer
    * and tweaks them from there to get rid fo the separater and position the text in the 
    * horizontal center of the renderer.
    * 
    */
    public class MyLabelItemRenderer extends InstrumentedLabelItemRenderer
    {
        public function MyLabelItemRenderer()
        {
            super();
        }
        
        /**
        * Copy the LabelItemRenderer implementation but tweak it to remove the separator
        */
        override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void 
        {
            // figure out backgroundColor
            var backgroundColor:*;
            var downColor:* = getStyle("downColor");
            var drawBackground:Boolean = true;
            
            if (down && downColor !== undefined)
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
            else if (showsCaret)
            {
                backgroundColor = getStyle("selectionColor");
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
            graphics.beginFill(backgroundColor, drawBackground ? 1 : 0);
            graphics.lineStyle();
            graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
            graphics.endFill();
            
            var topSeparatorColor:uint;
            var topSeparatorAlpha:Number;
            var bottomSeparatorColor:uint;
            var bottomSeparatorAlpha:Number;
            
            // Selected and down states have a gradient overlay as well
            // as different separators colors/alphas
            if (selected || down)
            {
                var colors:Array = [0x000000, 0x000000 ];
                var alphas:Array = [.2, .1];
                var ratios:Array = [0, 255];
                var matrix:Matrix = new Matrix();
                
                // gradient overlay
                matrix.createGradientBox(unscaledWidth, unscaledHeight, Math.PI / 2, 0, 0 );
                graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
                graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
                graphics.endFill();
            }
            
            // separators are a highlight on the top and shadow on the bottom
            topSeparatorColor = 0xFFFFFF;
            topSeparatorAlpha = .3;
            bottomSeparatorColor = 0x000000;
            bottomSeparatorAlpha = .3;
            
            
            var dataGroup:DataGroup = parent as DataGroup;
            var isLast:Boolean = (dataGroup && (itemIndex == dataGroup.numElements - 1));
            
            
            // draw separators
            // Don't draw separators in this simple subclass
        }
        
        /**
        * Copy the LabelItemRenderer implementation, but tweak it to horizontally center
        * the label.
        */
        override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
        {
            if (!labelDisplay)
                return;
            
            var paddingLeft:Number   = getStyle("paddingLeft"); 
            var paddingRight:Number  = getStyle("paddingRight");
            var paddingTop:Number    = getStyle("paddingTop");
            var paddingBottom:Number = getStyle("paddingBottom");
            var verticalAlign:String = getStyle("verticalAlign");
            
            var viewWidth:Number  = unscaledWidth  - paddingLeft - paddingRight;
            var viewHeight:Number = unscaledHeight - paddingTop  - paddingBottom;
            
            var vAlign:Number;
            if (verticalAlign == "top")
                vAlign = 0;
            else if (verticalAlign == "bottom")
                vAlign = 1;
            else // if (verticalAlign == "middle")
                vAlign = 0.5;
            
            // measure the label component
            // text should take up the rest of the space width-wise, but only let it take up
            // its measured textHeight so we can position it later based on verticalAlign
            var labelWidth:Number = Math.max(viewWidth, 0);	
            var labelHeight:Number = 0;
            
            if (label != "")
            {
                labelDisplay.commitStyles();
                
                // reset text if it was truncated before.
                if (labelDisplay.isTruncated)
                    labelDisplay.text = label;
                
                labelHeight = getElementPreferredHeight(labelDisplay);
            }
            
            setElementSize(labelDisplay, labelWidth, labelHeight);    
            
            // center horizontally
            var labelX:Number = Math.round(viewWidth/2);
            
            // We want to center using the "real" ascent
            var labelY:Number = Math.round(vAlign * (viewHeight - labelHeight))  + paddingTop;
            setElementPosition(labelDisplay, labelX, labelY); 
            
            // attempt to truncate the text now that we have its official width
            labelDisplay.truncateToFit();

        }
        
    }
}