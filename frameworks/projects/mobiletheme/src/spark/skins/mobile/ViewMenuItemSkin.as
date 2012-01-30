package spark.skins.mobile
{
import flash.display.GradientType;
import flash.display.Graphics;

import mx.core.DPIClassification;
import mx.core.mx_internal;

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
 */ 
public class ViewMenuItemSkin extends ButtonSkin
{
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
                
                layoutBorderSize = 2;
                layoutPaddingBottom = 12;
                
                break;
            }
            case DPIClassification.DPI_240:
            {   
                upBorderSkin = spark.skins.mobile.assets.ViewMenuItem_up;
                downBorderSkin = spark.skins.mobile.assets.ViewMenuItem_down;
                showsCaretBorderSkin = spark.skins.mobile.assets.ViewMenuItem_showsCaret;
                
                layoutBorderSize = 1;
                layoutPaddingBottom = 8;
                
                break;
            
            }
            default:
            {
                upBorderSkin = spark.skins.mobile.assets.ViewMenuItem_up;
                downBorderSkin = spark.skins.mobile.assets.ViewMenuItem_down;
                showsCaretBorderSkin = spark.skins.mobile.assets.ViewMenuItem_showsCaret; 
                
                layoutBorderSize = 1;
                layoutPaddingBottom = 6;
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
   
    override protected function getBorderClassForCurrentState():Class
    {
        var borderClass:Class = super.getBorderClassForCurrentState();
        
        if (currentState == "showsCaret")
            borderClass = showsCaretBorderSkin;  
        
        return borderClass;
    }
     
    override protected function beginChromeColorFill(chromeColorGraphics:Graphics):void
    {
        if (currentState == "showsCaret" || currentState == "down")
        {
            chromeColorGraphics.beginFill(getStyle("focusColor"));
        }
        else
        {
            matrix.createGradientBox(unscaledWidth, 
                                     unscaledHeight, 
                                     Math.PI / 2, 0, 0);
            var chromeColor:uint = getStyle("chromeColor");
            
            chromeColorGraphics.beginGradientFill(GradientType.LINEAR,
                                                  [chromeColor, chromeColor],
                                                  [0.9, 0.95],
                                                  [0, 255],
                                                  matrix);
        }
    }
    
    override protected function drawChromeColor(chromeColorGraphics:Graphics, 
                                                unscaledWidth:Number, unscaledHeight:Number):void
    {
            chromeColorGraphics.drawRect(0,0,unscaledWidth,unscaledHeight);
    }
}
}