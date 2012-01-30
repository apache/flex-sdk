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
import flash.display.Graphics;

import mx.core.DPIClassification;

import spark.skins.mobile160.assets.ButtonBarMiddleButton_down;
import spark.skins.mobile160.assets.ButtonBarMiddleButton_selected;
import spark.skins.mobile160.assets.ButtonBarMiddleButton_up;
import spark.skins.mobile240.assets.ButtonBarMiddleButton_down;
import spark.skins.mobile240.assets.ButtonBarMiddleButton_selected;
import spark.skins.mobile240.assets.ButtonBarMiddleButton_up;
import spark.skins.mobile320.assets.ButtonBarMiddleButton_down;
import spark.skins.mobile320.assets.ButtonBarMiddleButton_selected;
import spark.skins.mobile320.assets.ButtonBarMiddleButton_up;
import spark.skins.mobile.supportClasses.ButtonBarButtonSkinBase;

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
        
        useChromeColor = true;
        
        switch (applicationDPI)
        {
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
            default:
            {
                // default PPI160
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
    override protected function beginChromeColorFill(chromeColorGraphics:Graphics):void
    {
        var chromeColor:uint = getChromeColor();
        chromeColorGraphics.beginFill(getChromeColor());
    }
    
    /**
     *  @private
     */
    override protected function drawChromeColor(chromeColorGraphics:Graphics, unscaledWidth:Number, unscaledHeight:Number):void
    {
        // draw a rounded rect with rounded corners on the left side only
        chromeColorGraphics.drawRoundRect(0, 0, unscaledWidth, unscaledHeight, 0, 0);
        chromeColorGraphics.endFill();
    }
}
}