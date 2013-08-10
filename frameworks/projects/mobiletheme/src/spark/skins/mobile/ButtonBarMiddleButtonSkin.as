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
import mx.core.DPIClassification;

import spark.skins.mobile.supportClasses.ButtonBarButtonSkinBase;
import spark.skins.mobile120.assets.ButtonBarMiddleButton_down;
import spark.skins.mobile120.assets.ButtonBarMiddleButton_selected;
import spark.skins.mobile120.assets.ButtonBarMiddleButton_up;
import spark.skins.mobile160.assets.ButtonBarMiddleButton_down;
import spark.skins.mobile160.assets.ButtonBarMiddleButton_selected;
import spark.skins.mobile160.assets.ButtonBarMiddleButton_up;
import spark.skins.mobile240.assets.ButtonBarMiddleButton_down;
import spark.skins.mobile240.assets.ButtonBarMiddleButton_selected;
import spark.skins.mobile240.assets.ButtonBarMiddleButton_up;
import spark.skins.mobile320.assets.ButtonBarMiddleButton_down;
import spark.skins.mobile320.assets.ButtonBarMiddleButton_selected;
import spark.skins.mobile320.assets.ButtonBarMiddleButton_up;
import spark.skins.mobile480.assets.ButtonBarMiddleButton_down;
import spark.skins.mobile480.assets.ButtonBarMiddleButton_selected;
import spark.skins.mobile480.assets.ButtonBarMiddleButton_up;
import spark.skins.mobile640.assets.ButtonBarMiddleButton_down;
import spark.skins.mobile640.assets.ButtonBarMiddleButton_selected;
import spark.skins.mobile640.assets.ButtonBarMiddleButton_up;

/**
 *  Button skin for middle Buttons in a ButtonBar.
 * 
 *  @see spark.components.ButtonBar#middleButton
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class ButtonBarMiddleButtonSkin extends ButtonBarButtonSkinBase
{
    /**
     *  Constructor.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    public function ButtonBarMiddleButtonSkin()
    {
        super();
        
        switch (applicationDPI)
        {
			case DPIClassification.DPI_640: 
			{
				upBorderSkin = spark.skins.mobile640.assets.ButtonBarMiddleButton_up;
				downBorderSkin = spark.skins.mobile640.assets.ButtonBarMiddleButton_down;
				selectedBorderSkin = spark.skins.mobile640.assets.ButtonBarMiddleButton_selected;
				
				break;
			}
			case DPIClassification.DPI_480:
			{
				upBorderSkin = spark.skins.mobile480.assets.ButtonBarFirstButton_up;
				downBorderSkin = spark.skins.mobile480.assets.ButtonBarFirstButton_down;
				selectedBorderSkin = spark.skins.mobile480.assets.ButtonBarFirstButton_selected;

				break;
			}
            case DPIClassification.DPI_320: 
            {
                upBorderSkin = spark.skins.mobile320.assets.ButtonBarMiddleButton_up;
                downBorderSkin = spark.skins.mobile320.assets.ButtonBarMiddleButton_down;
                selectedBorderSkin = spark.skins.mobile320.assets.ButtonBarMiddleButton_selected;
                
                break;
            }
			case DPIClassification.DPI_240:
			{
				upBorderSkin = spark.skins.mobile240.assets.ButtonBarMiddleButton_up;
				downBorderSkin = spark.skins.mobile240.assets.ButtonBarMiddleButton_down;
				selectedBorderSkin = spark.skins.mobile240.assets.ButtonBarMiddleButton_selected;
				
				break;
			}
			case DPIClassification.DPI_120:
			{
				upBorderSkin = spark.skins.mobile120.assets.ButtonBarMiddleButton_up;
				downBorderSkin = spark.skins.mobile120.assets.ButtonBarMiddleButton_down;
				selectedBorderSkin = spark.skins.mobile120.assets.ButtonBarMiddleButton_selected;
				
				break;
			}
            default:
            {
                // default DPI_160
                upBorderSkin = spark.skins.mobile160.assets.ButtonBarMiddleButton_up;
                downBorderSkin = spark.skins.mobile160.assets.ButtonBarMiddleButton_down;
                selectedBorderSkin = spark.skins.mobile160.assets.ButtonBarMiddleButton_selected;

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
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // omit super.drawBackground() to drawRect instead
        // draw a rounded rect with rounded corners on the left side only
        graphics.beginFill(getStyle("chromeColor"));
        graphics.drawRoundRect(0, 0, unscaledWidth, unscaledHeight, 0, 0);
        graphics.endFill();
    }
}
}