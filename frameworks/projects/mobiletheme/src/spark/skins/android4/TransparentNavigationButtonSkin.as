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
import flash.display.Graphics;

import mx.core.DPIClassification;
import mx.core.mx_internal;

import spark.skins.mobile.assets.TransparentNavigationButton_down;
import spark.skins.mobile.assets.TransparentNavigationButton_up;
import spark.skins.mobile.supportClasses.ActionBarButtonSkinBase;
import spark.skins.mobile.supportClasses.MobileSkin;
import spark.skins.mobile320.assets.TransparentNavigationButton_down;
import spark.skins.mobile320.assets.TransparentNavigationButton_up;
import spark.skins.mobile480.assets.TransparentNavigationButton_down;
import spark.skins.mobile480.assets.TransparentNavigationButton_up;
import spark.skins.mobile640.assets.TransparentNavigationButton_down;
import spark.skins.mobile640.assets.TransparentNavigationButton_up;

use namespace mx_internal;

/**
 *  The default skin class for buttons in the navigation area of the Spark ActionBar component 
 *  in mobile applications.  
 * 
 *  @langversion 3.0
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class TransparentNavigationButtonSkin extends ActionBarButtonSkinBase
{   
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    /**
     *  Constructor.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     * 
     */
    public function TransparentNavigationButtonSkin()
    {
        super();
        
        switch (applicationDPI)
        {
			case DPIClassification.DPI_640:
			{
				upBorderSkin = spark.skins.mobile640.assets.TransparentActionButton_up;
				downBorderSkin = spark.skins.mobile640.assets.TransparentActionButton_down;
				
				break;
			}
			case DPIClassification.DPI_480:
			{
				upBorderSkin = spark.skins.mobile480.assets.TransparentActionButton_up;
				downBorderSkin = spark.skins.mobile480.assets.TransparentActionButton_down;
				
				break;
			}
            case DPIClassification.DPI_320:
            {
                upBorderSkin = spark.skins.mobile320.assets.TransparentNavigationButton_up;
                downBorderSkin = spark.skins.mobile320.assets.TransparentNavigationButton_down;
                
                break;
            }
            default:
            {
                upBorderSkin = spark.skins.mobile.assets.TransparentNavigationButton_up;
                downBorderSkin = spark.skins.mobile.assets.TransparentNavigationButton_down;
                
                break;
            }
        }
    }
    
    override mx_internal function layoutBorder(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // trailing vertical separator is outside the right bounds of the button
        setElementSize(border, unscaledWidth + layoutBorderSize, unscaledHeight);
        setElementPosition(border, 0, 0);
    }
}
}