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
package spark.skins.mobile
{
import flash.display.GradientType;
import flash.display.Graphics;

import mx.core.DPIClassification;
import mx.core.mx_internal;

import spark.components.IconPlacement;
import spark.skins.mobile.assets.ViewMenuItem_down;
import spark.skins.mobile.assets.ViewMenuItem_showsCaret;
import spark.skins.mobile.assets.ViewMenuItem_up;
import spark.skins.mobile.supportClasses.ButtonSkinBase;
import spark.skins.mobile120.assets.ViewMenuItem_down;
import spark.skins.mobile120.assets.ViewMenuItem_showsCaret;
import spark.skins.mobile120.assets.ViewMenuItem_up;
import spark.skins.mobile320.assets.ViewMenuItem_down;
import spark.skins.mobile320.assets.ViewMenuItem_showsCaret;
import spark.skins.mobile320.assets.ViewMenuItem_up;
import spark.skins.mobile480.assets.ViewMenuItem_down;
import spark.skins.mobile480.assets.ViewMenuItem_showsCaret;
import spark.skins.mobile480.assets.ViewMenuItem_up;
import spark.skins.mobile640.assets.ViewMenuItem_down;
import spark.skins.mobile640.assets.ViewMenuItem_showsCaret;
import spark.skins.mobile640.assets.ViewMenuItem_up;


use namespace mx_internal;

/**
 *  Default skin for ViewMenuItem. Supports a label, icon and iconPlacement and draws a background.   
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */ 
public class ViewMenuItemSkin extends ButtonSkin
{
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function ViewMenuItemSkin()
    {
        super();
        
        switch (applicationDPI)
        {
			case DPIClassification.DPI_640:
			{
				
				upBorderSkin = spark.skins.mobile640.assets.ViewMenuItem_up;
				downBorderSkin = spark.skins.mobile640.assets.ViewMenuItem_down;
				showsCaretBorderSkin = spark.skins.mobile640.assets.ViewMenuItem_showsCaret;
				
				layoutGap = 24;
				layoutPaddingLeft = 24;
				layoutPaddingRight = 24;
				layoutPaddingTop = 24;
				layoutPaddingBottom = 24;
				layoutBorderSize = 3;   
				
				break;
			}
			case DPIClassification.DPI_480:
			{   
				// Note provisional may need changes
				upBorderSkin = spark.skins.mobile.assets.ViewMenuItem_up;
				downBorderSkin = spark.skins.mobile.assets.ViewMenuItem_down;
				showsCaretBorderSkin = spark.skins.mobile.assets.ViewMenuItem_showsCaret;
				
				layoutGap = 16;
				layoutPaddingLeft = 16;
				layoutPaddingRight = 16;
				layoutPaddingTop = 16;
				layoutPaddingBottom = 16;
				layoutBorderSize = 2;
				
				break;
				
			}
            case DPIClassification.DPI_320:
            {
                
                upBorderSkin = spark.skins.mobile320.assets.ViewMenuItem_up;
                downBorderSkin = spark.skins.mobile320.assets.ViewMenuItem_down;
                showsCaretBorderSkin = spark.skins.mobile320.assets.ViewMenuItem_showsCaret;
                
                layoutGap = 12;
                layoutPaddingLeft = 12;
                layoutPaddingRight = 12;
                layoutPaddingTop = 12;
                layoutPaddingBottom = 12;
                layoutBorderSize = 2;   
                
                
                break;
            }
			case DPIClassification.DPI_240:
			{   
				upBorderSkin = spark.skins.mobile.assets.ViewMenuItem_up;
				downBorderSkin = spark.skins.mobile.assets.ViewMenuItem_down;
				showsCaretBorderSkin = spark.skins.mobile.assets.ViewMenuItem_showsCaret;
				
				layoutGap = 8;
				layoutPaddingLeft = 8;
				layoutPaddingRight = 8;
				layoutPaddingTop = 8;
				layoutPaddingBottom = 8;
				layoutBorderSize = 1;
				
				break;
				
			}
			case DPIClassification.DPI_120:
			{   
				upBorderSkin = spark.skins.mobile120.assets.ViewMenuItem_up;
				downBorderSkin = spark.skins.mobile120.assets.ViewMenuItem_down;
				showsCaretBorderSkin = spark.skins.mobile120.assets.ViewMenuItem_showsCaret;
				
				layoutGap = 4;
				layoutPaddingLeft = 4;
				layoutPaddingRight = 4;
				layoutPaddingTop = 4;
				layoutPaddingBottom = 4;
				layoutBorderSize = 1;
				
				break;
				
			}
            default:
            {
                upBorderSkin = spark.skins.mobile.assets.ViewMenuItem_up;
                downBorderSkin = spark.skins.mobile.assets.ViewMenuItem_down;
                showsCaretBorderSkin = spark.skins.mobile.assets.ViewMenuItem_showsCaret; 
                
                layoutGap = 6;
                layoutPaddingLeft = 6;
                layoutPaddingRight = 6;
                layoutPaddingTop = 6;
                layoutPaddingBottom = 6;
                layoutBorderSize = 1;
            }
        }
        
    }
    
    /**
     *  Class to use for the border in the showsCaret state.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     *       
     *  @default Button_down
     */ 
    protected var showsCaretBorderSkin:Class;
    
    /**
     *  @private
     */
    override protected function getBorderClassForCurrentState():Class
    {
        var borderClass:Class = super.getBorderClassForCurrentState();
        
        if (currentState == "showsCaret")
            borderClass = showsCaretBorderSkin;  
        
        return borderClass;
    }
    
    /**
     *  @private
     */
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
        var iconPlacement:String = getStyle("iconPlacement");
        useCenterAlignment = (iconPlacement == IconPlacement.LEFT)
            || (iconPlacement == IconPlacement.RIGHT);
        
        super.layoutContents(unscaledWidth, unscaledHeight);
    }
    
    /**
     *  @private
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // omit call to super.drawBackground(), drawRect instead
        
        if (currentState == "showsCaret" || currentState == "down")
        {
            graphics.beginFill(getStyle("focusColor"));
        }
        else
        {
            colorMatrix.createGradientBox(unscaledWidth, 
                unscaledHeight, 
                Math.PI / 2, 0, 0);
            var chromeColor:uint = getStyle("chromeColor");
            
            graphics.beginGradientFill(GradientType.LINEAR,
                [chromeColor, chromeColor],
                [0.9, 0.95],
                [0, 255],
                colorMatrix);
        }
        
        graphics.drawRect(0,0,unscaledWidth,unscaledHeight);
        graphics.endFill();
    }
}
}