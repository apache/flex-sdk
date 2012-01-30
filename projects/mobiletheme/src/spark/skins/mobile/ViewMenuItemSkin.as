package spark.skins.mobile
{
import flash.display.Graphics;

import spark.skins.mobile.supportClasses.ButtonSkinBase;

/**
 *  Default skin for ViewMenuItem. Supports a label, icon and iconPlacement and draws a background.   
 */ 
public class ViewMenuItemSkin extends ButtonSkinBase
{
    public function ViewMenuItemSkin()
    {
        super();
    }
    
    /**
     *  @private
     */  
    override protected function commitCurrentState():void
    {
        super.commitCurrentState();       
        invalidateDisplayList();    
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        // Draw the background
        graphics.clear();
        
        // No border. The ViewMenuLayout will draw separators
        graphics.lineStyle(0,0,0);
        
        // TODO (jszeto) Need to figure out which styles are supported
        var bgColor:uint = getStyle("backgroundColor");
        var bgAlpha:Number = 1
        
        if (currentState == "down")
        {
            bgColor = getStyle("selectionColor");
        }
        else if (currentState == "showsCaret")
        {
            bgColor = 0xCC6600;
        }
        else
        {
            bgAlpha = getStyle("backgroundAlpha");
        }
        
        graphics.beginFill(bgColor, bgAlpha);
        graphics.drawRect(0,0,unscaledWidth, unscaledHeight);
        graphics.endFill();
    }
}
}