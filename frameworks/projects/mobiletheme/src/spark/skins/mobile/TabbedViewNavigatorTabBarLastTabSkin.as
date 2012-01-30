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

import spark.skins.mobile.assets.TabbedViewNavigatorButtonBarLastButton_down;
import spark.skins.mobile.assets.TabbedViewNavigatorButtonBarLastButton_up;
import spark.skins.mobile.supportClasses.TabbedViewNavigatorTabBarTabSkinBase;
import spark.skins.mobile320.assets.TabbedViewNavigatorButtonBarLastButton_down;
import spark.skins.mobile320.assets.TabbedViewNavigatorButtonBarLastButton_up;

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
            case DPIClassification.DPI_320:
            {
                upBorderSkin = spark.skins.mobile320.assets.TabbedViewNavigatorButtonBarLastButton_up;
                downBorderSkin = spark.skins.mobile320.assets.TabbedViewNavigatorButtonBarLastButton_down;
                selectedBorderSkin = spark.skins.mobile320.assets.TabbedViewNavigatorButtonBarLastButton_selected;
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