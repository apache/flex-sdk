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

import spark.skins.mobile.supportClasses.ButtonBarButtonSkinBase;
import spark.skins.mobile160.assets.ButtonBarFirstButton_down;
import spark.skins.mobile160.assets.ButtonBarFirstButton_selected;
import spark.skins.mobile160.assets.ButtonBarFirstButton_up;
import spark.skins.mobile240.assets.ButtonBarFirstButton_down;
import spark.skins.mobile240.assets.ButtonBarFirstButton_selected;
import spark.skins.mobile240.assets.ButtonBarFirstButton_up;
import spark.skins.mobile320.assets.ButtonBarFirstButton_down;
import spark.skins.mobile320.assets.ButtonBarFirstButton_selected;
import spark.skins.mobile320.assets.ButtonBarFirstButton_up;

/**
 *  Button skin for the first Button in a ButtonBar.
 * 
 *  @see spark.components.ButtonBar#firstButton
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class ButtonBarFirstButtonSkin extends ButtonBarButtonSkinBase
{
    /**
     *  Constructor.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    public function ButtonBarFirstButtonSkin()
    {
        super();
        
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320: 
            {
                upBorderSkin = spark.skins.mobile320.assets.ButtonBarFirstButton_up;
                downBorderSkin = spark.skins.mobile320.assets.ButtonBarFirstButton_down;
                selectedBorderSkin = spark.skins.mobile320.assets.ButtonBarFirstButton_selected;
                
                cornerRadius = 12;
                
                break;
            }
            case DPIClassification.DPI_240:
            {
                upBorderSkin = spark.skins.mobile240.assets.ButtonBarFirstButton_up;
                downBorderSkin = spark.skins.mobile240.assets.ButtonBarFirstButton_down;
                selectedBorderSkin = spark.skins.mobile240.assets.ButtonBarFirstButton_selected;
                
                cornerRadius = 8;
                
                break;
            }
            default:
            {
                // default DPI_160
                upBorderSkin = spark.skins.mobile160.assets.ButtonBarFirstButton_up;
                downBorderSkin = spark.skins.mobile160.assets.ButtonBarFirstButton_down;
                selectedBorderSkin = spark.skins.mobile160.assets.ButtonBarFirstButton_selected;
                
                cornerRadius = 6;
                
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
        // omit super.drawBackground() to drawRoundRectComplex instead
        // draw a rounded rect with rounded corners on the left side only
        graphics.beginFill(getStyle("chromeColor"));
        graphics.drawRoundRectComplex(0, 0, unscaledWidth, unscaledHeight, cornerRadius, 0, cornerRadius, 0);
        graphics.endFill();
    }
}
}