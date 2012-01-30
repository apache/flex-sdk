package spark.skins.mobile
{
import flash.display.Graphics;

import mx.core.mx_internal;

import spark.skins.mobile.assets.ViewMenuItem_down;
import spark.skins.mobile.assets.ViewMenuItem_showsCaret;
import spark.skins.mobile.assets.ViewMenuItem_up;
import spark.skins.mobile.supportClasses.ButtonSkinBase;

use namespace mx_internal;

/**
 *  Default skin for ViewMenuItem. Supports a label, icon and iconPlacement and draws a background.   
 */ 
public class ViewMenuItemSkin extends ButtonSkin
{
    public function ViewMenuItemSkin()
    {
        super();
        
        upBorderSkin = ViewMenuItem_up;
        downBorderSkin = ViewMenuItem_down;
        showsCaretBorderSkin = ViewMenuItem_showsCaret; 
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
     
    override protected function drawChromeColor(chromeColorGraphics:Graphics, unscaledWidth:Number, unscaledHeight:Number):void
    {
        // Don't do anything. The fxg files contain the background
    }
}
}