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

import spark.skins.mobile.assets.TabbedViewNavigatorButtonBarLastButton_down;
import spark.skins.mobile.assets.TabbedViewNavigatorButtonBarLastButton_up;
import spark.skins.mobile.supportClasses.TabbedViewNavigatorTabBarTabSkinBase;
import spark.skins.mobile120.assets.TabbedViewNavigatorButtonBarLastButton_down;
import spark.skins.mobile120.assets.TabbedViewNavigatorButtonBarLastButton_up;
import spark.skins.mobile320.assets.TabbedViewNavigatorButtonBarLastButton_down;
import spark.skins.mobile320.assets.TabbedViewNavigatorButtonBarLastButton_up;
import spark.skins.mobile480.assets.TabbedViewNavigatorButtonBarLastButton_down;
import spark.skins.mobile480.assets.TabbedViewNavigatorButtonBarLastButton_up;
import spark.skins.mobile640.assets.TabbedViewNavigatorButtonBarLastButton_down;
import spark.skins.mobile640.assets.TabbedViewNavigatorButtonBarLastButton_up;

/**
 *  Skin for used for middle and the right-most ButtonBarButton in the 
 *  TabbedViewNavigator ButtonBar skin.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class TabbedViewNavigatorTabBarLastTabSkin extends TabbedViewNavigatorTabBarTabSkinBase
{
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function TabbedViewNavigatorTabBarLastTabSkin()
    {
        super();
        
        switch (applicationDPI)
        {
			case DPIClassification.DPI_640:
			{
				upBorderSkin = spark.skins.mobile640.assets.TabbedViewNavigatorButtonBarLastButton_up;
				downBorderSkin = spark.skins.mobile640.assets.TabbedViewNavigatorButtonBarLastButton_down;
				selectedBorderSkin = spark.skins.mobile640.assets.TabbedViewNavigatorButtonBarLastButton_selected;
				break;
			}
			case DPIClassification.DPI_480:
			{
				upBorderSkin = spark.skins.mobile480.assets.TabbedViewNavigatorButtonBarLastButton_up;
				downBorderSkin = spark.skins.mobile480.assets.TabbedViewNavigatorButtonBarLastButton_down;
				selectedBorderSkin = spark.skins.mobile480.assets.TabbedViewNavigatorButtonBarLastButton_selected;
				break;
			}
			case DPIClassification.DPI_320:
			{
				upBorderSkin = spark.skins.mobile320.assets.TabbedViewNavigatorButtonBarLastButton_up;
				downBorderSkin = spark.skins.mobile320.assets.TabbedViewNavigatorButtonBarLastButton_down;
				selectedBorderSkin = spark.skins.mobile320.assets.TabbedViewNavigatorButtonBarLastButton_selected;
				break;
			}
			case DPIClassification.DPI_120:
			{
				upBorderSkin = spark.skins.mobile120.assets.TabbedViewNavigatorButtonBarLastButton_up;
				downBorderSkin = spark.skins.mobile120.assets.TabbedViewNavigatorButtonBarLastButton_down;
				selectedBorderSkin = spark.skins.mobile120.assets.TabbedViewNavigatorButtonBarLastButton_selected;
				break;
			}
            default:
            {
                upBorderSkin = spark.skins.mobile.assets.TabbedViewNavigatorButtonBarLastButton_up;
                downBorderSkin = spark.skins.mobile.assets.TabbedViewNavigatorButtonBarLastButton_down;
                selectedBorderSkin = spark.skins.mobile.assets.TabbedViewNavigatorButtonBarLastButton_selected;
                break;
            }
        }
    }
}
}