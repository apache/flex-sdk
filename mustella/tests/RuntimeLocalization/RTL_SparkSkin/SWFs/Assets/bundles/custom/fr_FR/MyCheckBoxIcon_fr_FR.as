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

package
{

import flash.display.GradientType;
import flash.display.Graphics;
import mx.skins.Border;
import mx.styles.StyleManager;
import mx.utils.ColorUtil;

/**
 *  The skin for all the states of the icon in a CheckBox.
 */
public class MyCheckBoxIcon_fr_FR extends Border
{
    //include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private static var cache:Object = {};
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Several colors used for drawing are calculated from the base colors
     *  of the component (themeColor, borderColor and fillColors).
     *  Since these calculations can be a bit expensive,
     *  we calculate once per color set and cache the results.
     */
    private static function calcDerivedStyles(themeColor:uint,
                                              borderColor:uint,
                                              fillColor0:uint,
                                              fillColor1:uint):Object
    {
        var key:String = HaloColors.getCacheKey(themeColor, borderColor,
                                                fillColor0, fillColor1);
        
        if (!cache[key])
        {
            var o:Object = cache[key] = {};
            
            // Cross-component styles.
            HaloColors.addHaloColors(o, themeColor, fillColor0, fillColor1);
            
            // CheckBox-specific styles.
            o.borderColorDrk1 = ColorUtil.adjustBrightness2(borderColor, -50);
        }
        
        return cache[key];
    }
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
    public function MyCheckBoxIcon_fr_FR()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  measuredWidth
    //----------------------------------
    
    /**
     *  @private
     */    
    override public function get measuredWidth():Number
    {
        return 14;
    }
    
    //----------------------------------
    //  measuredHeight
    //----------------------------------
    
    /**
     *  @private
     */        
    override public function get measuredHeight():Number
    {
        return 14;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function updateDisplayList(w:Number, h:Number):void
    {
        super.updateDisplayList(w, h);

        // User-defined styles
        var borderColor:uint = getStyle("borderColor");
        var fillAlphas:Array = getStyle("fillAlphas");
        var fillColors:Array = getStyle("fillColors");
        StyleManager.getColorNames(fillColors);
        var highlightAlphas:Array = getStyle("highlightAlphas");        
        var themeColor:uint = getStyle("themeColor");
        
        // Placeholder styles stub  
        var checkColor:uint = 0x2B333C;// added style prop
        
        // Derived styles
        var derStyles:Object = calcDerivedStyles(themeColor, borderColor, 
                                                 fillColors[0], fillColors[1]);
        
        var borderColorDrk1:Number =
            ColorUtil.adjustBrightness2(borderColor, -50);
        
        var themeColorDrk1:Number =
            ColorUtil.adjustBrightness2(themeColor, -25);
        
        var bDrawCheck:Boolean = false;
        
        var upFillColors:Array;
        var upFillAlphas:Array;
        
        var overFillColors:Array;
        var overFillAlphas:Array;
        
        var disFillColors:Array;
        var disFillAlphas:Array;

        var g:Graphics = graphics;
        
        g.clear();
        
        switch (name)
        {
            case "upIcon":
            {
                upFillColors = [ fillColors[0], fillColors[1] ];
                upFillAlphas = [ fillAlphas[0], fillAlphas[1] ];

                // border
                drawRoundRect(
                    0, 0, w, h, 0,
                    [ borderColor, borderColorDrk1 ], 1,
                    verticalGradientMatrix(0, 0, w, h ),
                    GradientType.LINEAR, null, 
                    { x: 1, y: 1, w: w - 2, h: h - 2, r: 0 });
 

                // box fill
                drawRoundRect(
                    1, 1, w - 2, h - 2, 0,
                    upFillColors, upFillAlphas,
                    verticalGradientMatrix(1, 1, w - 2, h - 2)); 

                // top highlight
                drawRoundRect(
                    1, 1, w - 2, (h - 2) / 2, 0,
                    [ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
                    verticalGradientMatrix(1, 1, w - 2, (h - 2) / 2)); 


                break;
            }
                
            case "overIcon":
            {
                if (fillColors.length > 2)
                    overFillColors = [ fillColors[2], fillColors[3] ];
                else
                    overFillColors = [ fillColors[0], fillColors[1] ];

                if (fillAlphas.length > 2)
                    overFillAlphas = [ fillAlphas[2], fillAlphas[3] ];
                else
                    overFillAlphas = [ fillAlphas[0], fillAlphas[1] ];

                // border
                drawRoundRect(
                    0, 0, w, h, 0,
                    [ themeColor, themeColorDrk1 ], 1,
                    verticalGradientMatrix(0, 0, w, h),
                    GradientType.LINEAR, null, 
                    { x: 1, y: 1, w: w - 2, h: h - 2, r: 0 }); 
                
                // box fill
                drawRoundRect(
                    1, 1, w - 2, h - 2, 0,
                    overFillColors, overFillAlphas,
                    verticalGradientMatrix(1, 1, w - 2, h - 2));

                // top highlight
                drawRoundRect(
                    1, 1, w - 2, (h - 2) / 2, 0,
                    [ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
                    verticalGradientMatrix(1, 1, w - 2, (h - 2) / 2)); 

                break;
            }

            case "downIcon":
            {               
                // border
                drawRoundRect(
                    0, 0, w, h, 0,
                    [ themeColor, themeColorDrk1 ], 1,
                    verticalGradientMatrix(0, 0, w, h)); 
                
                // box fill
                drawRoundRect(
                    1, 1, w - 2, h - 2, 0,
                    [ derStyles.fillColorPress1,
                    derStyles.fillColorPress2 ], 1,
                    verticalGradientMatrix(1, 1, w - 2, h - 2)); 
                            
                // top highlight
                drawRoundRect(
                    1, 1, w - 2, (h - 2) / 2, 0,
                    [ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
                    verticalGradientMatrix(1, 1, w - 2, (h - 2) / 2));

                break;
            }

            case "disabledIcon":
            {
                disFillColors = [ fillColors[0], fillColors[1] ];
                disFillAlphas = [ Math.max(0, fillAlphas[0] - 15),
                                  Math.max(0, fillAlphas[1] - 15) ];

                // border
                drawRoundRect(
                    0, 0, w, h, 0,
                    [ borderColor, borderColorDrk1 ], 0.5,
                    verticalGradientMatrix(0, 0, w, h),
                    GradientType.LINEAR, null, 
                    { x: 1, y: 1, w: w - 2, h: h - 2, r: 0 }); 

                // box fill
                drawRoundRect(
                    1, 1, w - 2, h - 2, 0,
                    disFillColors, disFillAlphas,
                    verticalGradientMatrix(1, 1, w - 2, h - 2)); 

                break;
            }
                        
            case "selectedUpIcon":
            {
                bDrawCheck = true;
                
                upFillColors = [ fillColors[0], fillColors[1] ];
                upFillAlphas = [ fillAlphas[0], fillAlphas[1] ];

                // border
                drawRoundRect(
                    0, 0, w, h, 0,
                    [ borderColor, borderColorDrk1 ], 1,
                    verticalGradientMatrix(0, 0, w, h),
                    GradientType.LINEAR, null, 
                    { x: 1, y: 1, w: w - 2, h: h - 2, r: 0 }); 

                // box fill
                drawRoundRect(
                    1, 1, w - 2, h - 2, 0,
                    upFillColors, upFillAlphas,
                    verticalGradientMatrix(1, 1, w - 2, h - 2)); 

                // top highlight
                drawRoundRect(
                    1, 1, w - 2, (h - 2) / 2, 0,
                    [ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
                    verticalGradientMatrix(1, 1, w - 2, (h - 2) / 2));

                break;
            }

            case "selectedOverIcon":
            {
                bDrawCheck = true;
                
                if (fillColors.length > 2)
                    overFillColors = [ fillColors[2], fillColors[3] ];
                else
                    overFillColors = [ fillColors[0], fillColors[1] ];

                if (fillAlphas.length > 2)
                    overFillAlphas = [ fillAlphas[2], fillAlphas[3] ];
                else
                    overFillAlphas = [ fillAlphas[0], fillAlphas[1] ];

                // border
                drawRoundRect(
                    0, 0, w, h, 0,
                    [ themeColor, themeColorDrk1 ], 1,
                    verticalGradientMatrix(0, 0, w, h),
                    GradientType.LINEAR, null,
                    { x: 1, y: 1, w: w - 2, h: h - 2, r: 0 }); 

                // box fill
                drawRoundRect(
                    1, 1, w - 2, h - 2, 0,
                    overFillColors, overFillAlphas,
                    verticalGradientMatrix(1, 1, w - 2, h - 2)); 

                // top highlight
                drawRoundRect(
                    1, 1, w - 2, (h - 2) / 2, 0,
                    [ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
                    verticalGradientMatrix(1, 1, w - 2, (h - 2) / 2)); 
                
                break;
            }

            case "selectedDownIcon":
            {
                bDrawCheck = true;
                
                // border
                drawRoundRect(
                    0, 0, w, h, 0,
                    [ themeColor, themeColorDrk1 ], 1,
                    verticalGradientMatrix(0, 0, w, h)); 
                
                // box fill
                drawRoundRect(
                    1, 1, w - 2, h - 2, 0,
                    [ derStyles.fillColorPress1,
                    derStyles.fillColorPress2 ], 1,
                    verticalGradientMatrix(1, 1, w - 2, h - 2)); 
                            
                // top highlight
                drawRoundRect(
                    1, 1, w - 2, (h - 2) / 2, 0,
                    [ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
                    verticalGradientMatrix(1, 1, w - 2, (h - 2) / 2)); 

                break;
            }

            case "selectedDisabledIcon":
            {
                bDrawCheck = true;
                checkColor = 0x999999;
                
                disFillColors = [ fillColors[0], fillColors[1] ];
                disFillAlphas = [ Math.max( 0, fillAlphas[0] - 0.15),
                                  Math.max( 0, fillAlphas[1] - 0.15) ];

                // border
                drawRoundRect(
                    0, 0, w, h, 0,
                    [ borderColor, borderColorDrk1 ], 0.5,
                    verticalGradientMatrix(0, 0, w, h),
                    GradientType.LINEAR, null, 
                    { x: 1, y: 1, w: w - 2, h: h - 2, r: 0 }); 

                // box fill
                drawRoundRect(
                    1, 1, w - 2, h - 2, 0,
                    disFillColors, disFillAlphas,
                    verticalGradientMatrix(1, 1, w - 2, h - 2)); 

                break;
            }
        }
        
        // Draw the checkmark symbol.
        if (bDrawCheck)
        {
            /*
                g.beginFill(checkColor);
                g.moveTo(3, 5);
                g.lineTo(5, 10);
                g.lineTo(7, 10);
                g.lineTo(12, 2);
                g.lineTo(13, 1);
                g.lineTo(11, 1);
                g.lineTo(6.5, 7);
                g.lineTo(5, 5);
                g.lineTo(3, 5);
                g.endFill();
            */
            g.beginFill(checkColor);
            g.moveTo(11,5);
            g.lineTo(9,10);
            g.lineTo(7, 10);
            g.lineTo(2, 2);
            g.lineTo(1, 1);
            g.lineTo(3, 1);
            g.lineTo(7.5, 7);
            g.lineTo(9, 5);
            g.lineTo(5, 5);
            g.endFill();
        }
    }
}

}
