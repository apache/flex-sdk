////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.skins.mobile
{
import mx.core.DPIClassification;

import spark.skins.mobile.assets.TabbedViewNavigatorButtonBarFirstButton_down;
import spark.skins.mobile.assets.TabbedViewNavigatorButtonBarFirstButton_up;
import spark.skins.mobile.supportClasses.TabbedViewNavigatorTabBarTabSkinBase;
import spark.skins.mobile320.assets.TabbedViewNavigatorButtonBarFirstButton_down;
import spark.skins.mobile320.assets.TabbedViewNavigatorButtonBarFirstButton_up;

/**
 *  Skin for the left-most button in the TabbedViewNavigator ButtonBar skin
 *  part.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class TabbedViewNavigatorTabBarFirstTabSkin extends TabbedViewNavigatorTabBarTabSkinBase
{
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function TabbedViewNavigatorTabBarFirstTabSkin()
    {
        super();
        
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                upBorderSkin = spark.skins.mobile320.assets.TabbedViewNavigatorButtonBarFirstButton_up;
                downBorderSkin = spark.skins.mobile320.assets.TabbedViewNavigatorButtonBarFirstButton_down;
                selectedBorderSkin = spark.skins.mobile320.assets.TabbedViewNavigatorButtonBarFirstButton_selected;
                break;
            }
            default:
            {
                upBorderSkin = spark.skins.mobile.assets.TabbedViewNavigatorButtonBarFirstButton_up;
                downBorderSkin = spark.skins.mobile.assets.TabbedViewNavigatorButtonBarFirstButton_down;
                selectedBorderSkin = spark.skins.mobile.assets.TabbedViewNavigatorButtonBarFirstButton_selected;
                break;
            }
        }
    }
}
}