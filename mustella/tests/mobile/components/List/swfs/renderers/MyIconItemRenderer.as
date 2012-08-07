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
    
    import mx.core.mx_internal;
    
    import spark.components.IconItemRenderer;

    use namespace mx_internal;
    
    public class MyIconItemRenderer extends IconItemRenderer
    {
        
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
                graphics.drawRoundRect(0, 0, unscaledWidth, unscaledHeight, 20);
                graphics.endFill();
                
                // Selected and down states have a gradient overlay as well
                // as different separators colors/alphas
                if (selected || down)
                {
                    var colors:Array = [0xFFFFFF, 0xFFFFFF ];
                    var alphas:Array = [.1, .3];
                    var ratios:Array = [0, 255];
                    var matrix:Matrix = new Matrix();
                    
                    // gradient overlay
                    matrix.createGradientBox(unscaledWidth, unscaledHeight, Math.PI / 2, 0, 0 );
                    graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
                    graphics.drawRoundRect(0, 0, unscaledWidth, unscaledHeight / 2, 20);
                    graphics.endFill();
                }
                
        }
        
        override protected function measure():void
        {
            var myMeasuredWidth:Number = 0;
            var myMeasuredHeight:Number = 0;
            var myMeasuredMinWidth:Number = 0;
            var myMeasuredMinHeight:Number = 0;
            
            var hasLabel:Boolean = labelDisplay && labelDisplay.text != "";
            
            var verticalGap:Number = getStyle("verticalGap");
            var paddingWidth:Number = getStyle("paddingLeft") + getStyle("paddingRight");
            var paddingHeight:Number = getStyle("paddingTop") + getStyle("paddingBottom");
            
            var myIconWidth:Number = 0;
            var myIconHeight:Number = 0;
            
            if (iconDisplay)
            {
                myIconWidth = (isNaN(iconWidth) ? getElementPreferredWidth(iconDisplay) : iconWidth);
                myIconHeight = (isNaN(iconHeight) ? getElementPreferredHeight(iconDisplay) : iconHeight);
            }
            
            var labelWidth:Number = 0;
            var labelHeight:Number = 0;
            
            if (hasLabel)
            {
                // reset text if it was truncated before.
                if (labelDisplay.isTruncated)
                    labelDisplay.text = labelText;
                
                labelWidth = getElementPreferredWidth(labelDisplay);
                labelHeight = getElementPreferredHeight(labelDisplay);
            }
            
            myMeasuredWidth = Math.max(labelWidth, myIconWidth);
            myMeasuredHeight = labelHeight + myIconHeight + verticalGap;
            myMeasuredMinHeight = labelHeight + myIconHeight + verticalGap;
            
            myMeasuredWidth += paddingWidth;
            myMeasuredMinWidth += paddingWidth;
            
            myMeasuredHeight += paddingHeight;
            myMeasuredMinHeight += paddingHeight;
            
            // now set the local variables to the member variables.
            measuredWidth = myMeasuredWidth
            measuredHeight = myMeasuredHeight;
            
            measuredMinWidth = myMeasuredMinWidth;
            measuredMinHeight = myMeasuredMinHeight;
        }
        
        override protected function layoutContents(unscaledWidth:Number,
                                                   unscaledHeight:Number):void
        {
            // no need to call super.layoutContents() since we're changing how it happens here
            
            var hasLabel:Boolean = labelDisplay && labelDisplay.text != "";
            
            var paddingLeft:Number   = getStyle("paddingLeft");
            var paddingRight:Number  = getStyle("paddingRight");
            var paddingTop:Number    = getStyle("paddingTop");
            var paddingBottom:Number = getStyle("paddingBottom");
            var verticalGap:Number   = (hasLabel) ? getStyle("verticalGap") : 0;
            
            var iconWidth:Number = 0;
            var iconHeight:Number = 0;
            
            if (iconDisplay)
            {
                // set the icon's position and size
                setElementSize(iconDisplay, this.iconWidth, this.iconHeight);
                
                iconWidth = iconDisplay.getLayoutBoundsWidth();
                iconHeight = iconDisplay.getLayoutBoundsHeight();
                
                setElementPosition(iconDisplay, Math.round(0.5 * (unscaledWidth - iconWidth)), paddingTop);
            }
            
            var labelWidth:Number = 0;
            var labelHeight:Number = 0;
            
            if (hasLabel)
            {
                // reset text if it was truncated before.
                if (labelDisplay.isTruncated)
                    labelDisplay.text = labelText;
                
                // commit styles to make sure it uses updated look
                labelDisplay.commitStyles();
                
                labelWidth = unscaledWidth - paddingLeft - paddingRight;
                labelHeight = getElementPreferredHeight(labelDisplay);
                
                if (labelWidth == 0)
                    setElementSize(labelDisplay, NaN, 0);
                else
                    setElementSize(labelDisplay, labelWidth, labelHeight);
                
                // attempt to truncate text
                labelDisplay.truncateToFit();
                
                setElementPosition(labelDisplay, paddingLeft, paddingTop + iconHeight + verticalGap);
            }
        }

    }
}