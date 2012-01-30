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
import flash.display.GradientType;
import flash.display.Graphics;

import mx.core.DPIClassification;
import mx.core.mx_internal;

import spark.components.IconPlacement;
import spark.skins.mobile.assets.ViewMenuItem_down;
import spark.skins.mobile.assets.ViewMenuItem_showsCaret;
import spark.skins.mobile.assets.ViewMenuItem_up;
import spark.skins.mobile.supportClasses.ButtonSkinBase;
import spark.skins.mobile320.assets.ViewMenuItem_down;
import spark.skins.mobile320.assets.ViewMenuItem_showsCaret;
import spark.skins.mobile320.assets.ViewMenuItem_up;

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