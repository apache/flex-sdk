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
import flash.display.DisplayObject;

import mx.core.DPIClassification;

import spark.skins.mobile.supportClasses.SelectableButtonSkinBase;
import spark.skins.mobile120.assets.CheckBox_down;
import spark.skins.mobile120.assets.CheckBox_downSymbol;
import spark.skins.mobile120.assets.CheckBox_downSymbolSelected;
import spark.skins.mobile120.assets.CheckBox_up;
import spark.skins.mobile120.assets.CheckBox_upSymbol;
import spark.skins.mobile120.assets.CheckBox_upSymbolSelected;
import spark.skins.mobile160.assets.CheckBox_down;
import spark.skins.mobile160.assets.CheckBox_downSymbol;
import spark.skins.mobile160.assets.CheckBox_downSymbolSelected;
import spark.skins.mobile160.assets.CheckBox_up;
import spark.skins.mobile160.assets.CheckBox_upSymbol;
import spark.skins.mobile160.assets.CheckBox_upSymbolSelected;
import spark.skins.mobile240.assets.CheckBox_down;
import spark.skins.mobile240.assets.CheckBox_downSymbol;
import spark.skins.mobile240.assets.CheckBox_downSymbolSelected;
import spark.skins.mobile240.assets.CheckBox_up;
import spark.skins.mobile240.assets.CheckBox_upSymbol;
import spark.skins.mobile240.assets.CheckBox_upSymbolSelected;
import spark.skins.mobile320.assets.CheckBox_down;
import spark.skins.mobile320.assets.CheckBox_downSymbol;
import spark.skins.mobile320.assets.CheckBox_downSymbolSelected;
import spark.skins.mobile320.assets.CheckBox_up;
import spark.skins.mobile320.assets.CheckBox_upSymbol;
import spark.skins.mobile320.assets.CheckBox_upSymbolSelected;
import spark.skins.mobile480.assets.CheckBox_down;
import spark.skins.mobile480.assets.CheckBox_downSymbol;
import spark.skins.mobile480.assets.CheckBox_downSymbolSelected;
import spark.skins.mobile480.assets.CheckBox_up;
import spark.skins.mobile480.assets.CheckBox_upSymbol;
import spark.skins.mobile480.assets.CheckBox_upSymbolSelected;
import spark.skins.mobile640.assets.CheckBox_down;
import spark.skins.mobile640.assets.CheckBox_downSymbol;
import spark.skins.mobile640.assets.CheckBox_downSymbolSelected;
import spark.skins.mobile640.assets.CheckBox_up;
import spark.skins.mobile640.assets.CheckBox_upSymbol;
import spark.skins.mobile640.assets.CheckBox_upSymbolSelected;

/**
 *  ActionScript-based skin for CheckBox components in mobile applications. 
 * 
 *  @see spark.components.CheckBox
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class CheckBoxSkin extends SelectableButtonSkinBase
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    private static const exclusions:Array = ["labelDisplay", "labelDisplayShadow"];
    
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
     */
    public function CheckBoxSkin()
    {
        super();
        
        layoutPaddingLeft = 0;
        layoutPaddingRight = 0;
        layoutPaddingTop = 0;
        layoutPaddingBottom = 0;
        
        switch (applicationDPI)
        {
			case DPIClassification.DPI_640:
			{
				upIconClass = spark.skins.mobile640.assets.CheckBox_up;
				upSelectedIconClass = spark.skins.mobile640.assets.CheckBox_up;
				downIconClass = spark.skins.mobile640.assets.CheckBox_down;
				downSelectedIconClass = spark.skins.mobile640.assets.CheckBox_down;
				upSymbolIconClass = spark.skins.mobile640.assets.CheckBox_upSymbol;
				upSymbolIconSelectedClass = spark.skins.mobile640.assets.CheckBox_upSymbolSelected;
				downSymbolIconClass = spark.skins.mobile640.assets.CheckBox_downSymbol;
				downSymbolIconSelectedClass = spark.skins.mobile640.assets.CheckBox_downSymbolSelected;
				
				layoutGap = 40;
				minWidth = 128;
				minHeight = 128;
				layoutBorderSize = 4;
				
				break;
			}
			case DPIClassification.DPI_480:
			{
				// Note provisional may need changes
				upIconClass = spark.skins.mobile480.assets.CheckBox_up;
				upSelectedIconClass = spark.skins.mobile480.assets.CheckBox_up;
				downIconClass = spark.skins.mobile480.assets.CheckBox_down;
				downSelectedIconClass = spark.skins.mobile480.assets.CheckBox_down;
				upSymbolIconClass = spark.skins.mobile480.assets.CheckBox_upSymbol;
				upSymbolIconSelectedClass = spark.skins.mobile480.assets.CheckBox_upSymbolSelected;
				downSymbolIconClass = spark.skins.mobile480.assets.CheckBox_downSymbol;
				downSymbolIconSelectedClass = spark.skins.mobile480.assets.CheckBox_downSymbolSelected;
				
				layoutGap = 30;
				minWidth = 96;
				minHeight = 96;
				layoutBorderSize = 3;
				
				break;
			}
            case DPIClassification.DPI_320:
            {
                upIconClass = spark.skins.mobile320.assets.CheckBox_up;
                upSelectedIconClass = spark.skins.mobile320.assets.CheckBox_up;
                downIconClass = spark.skins.mobile320.assets.CheckBox_down;
                downSelectedIconClass = spark.skins.mobile320.assets.CheckBox_down;
                upSymbolIconClass = spark.skins.mobile320.assets.CheckBox_upSymbol;
                upSymbolIconSelectedClass = spark.skins.mobile320.assets.CheckBox_upSymbolSelected;
                downSymbolIconClass = spark.skins.mobile320.assets.CheckBox_downSymbol;
                downSymbolIconSelectedClass = spark.skins.mobile320.assets.CheckBox_downSymbolSelected;
                 
                layoutGap = 20;
                minWidth = 64;
                minHeight = 64;
                layoutBorderSize = 3;
                
                break;
            }
            case DPIClassification.DPI_240:
            {
                upIconClass = spark.skins.mobile240.assets.CheckBox_up;
                upSelectedIconClass = spark.skins.mobile240.assets.CheckBox_up;
                downIconClass = spark.skins.mobile240.assets.CheckBox_down;
                downSelectedIconClass = spark.skins.mobile240.assets.CheckBox_down;
                upSymbolIconClass = spark.skins.mobile240.assets.CheckBox_upSymbol;
                upSymbolIconSelectedClass = spark.skins.mobile240.assets.CheckBox_upSymbolSelected;
                downSymbolIconClass = spark.skins.mobile240.assets.CheckBox_downSymbol;
                downSymbolIconSelectedClass = spark.skins.mobile240.assets.CheckBox_downSymbolSelected;
                
                layoutGap = 15;
                minWidth = 48;
                minHeight = 48;
                layoutBorderSize = 2;
                
                break;
            }
			case DPIClassification.DPI_120:
			{
				upIconClass = spark.skins.mobile120.assets.CheckBox_up;
				upSelectedIconClass = spark.skins.mobile120.assets.CheckBox_up;
				downIconClass = spark.skins.mobile120.assets.CheckBox_down;
				downSelectedIconClass = spark.skins.mobile120.assets.CheckBox_down;
				upSymbolIconClass = spark.skins.mobile120.assets.CheckBox_upSymbol;
				upSymbolIconSelectedClass = spark.skins.mobile120.assets.CheckBox_upSymbolSelected;
				downSymbolIconClass = spark.skins.mobile120.assets.CheckBox_downSymbol;
				downSymbolIconSelectedClass = spark.skins.mobile120.assets.CheckBox_downSymbolSelected;
				
				layoutGap = 8;
				minWidth = 24;
				minHeight = 24;
				layoutBorderSize = 1;
				
				break;
			}
            default:
            {
                // default DPI_160
                upIconClass = spark.skins.mobile160.assets.CheckBox_up;
                upSelectedIconClass = spark.skins.mobile160.assets.CheckBox_up;
                downIconClass = spark.skins.mobile160.assets.CheckBox_down;
                downSelectedIconClass = spark.skins.mobile160.assets.CheckBox_down;
                upSymbolIconClass = spark.skins.mobile160.assets.CheckBox_upSymbol;
                upSymbolIconSelectedClass = spark.skins.mobile160.assets.CheckBox_upSymbolSelected;
                downSymbolIconClass = spark.skins.mobile160.assets.CheckBox_downSymbol;
                downSymbolIconSelectedClass = spark.skins.mobile160.assets.CheckBox_downSymbolSelected;
                
                layoutGap = 10;
                minWidth = 32;
                minHeight = 32;
                layoutBorderSize = 2;
                
                break;
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  CheckBox <code>chromeColor</code> is drawn to match the FXG rectangle
     *  shape and position.
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // super draws a transparent hit zone
        super.drawBackground(unscaledWidth, unscaledHeight);

        // get the size and position of iconDisplay
        var currentIcon:DisplayObject = getIconDisplay();
        var widthAdjustment:Number = layoutBorderSize * 2;
        
        graphics.beginFill(getStyle("chromeColor"));
        graphics.drawRoundRect(currentIcon.x + layoutBorderSize,
            currentIcon.y + layoutBorderSize,
            currentIcon.width - widthAdjustment,
            currentIcon.height - widthAdjustment, layoutBorderSize, layoutBorderSize);
        graphics.endFill();
    }
    
    /**
     *  List of IDs of items that should be excluded when rendering the focus ring.
     *  Only items of type DisplayObject or GraphicElement should be excluded. Items
     *  of other types are ignored.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override protected function get focusSkinExclusions():Array 
    {
        return exclusions;
    }
}
}