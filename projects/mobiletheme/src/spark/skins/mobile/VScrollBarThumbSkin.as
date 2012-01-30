package spark.skins.mobile
{

import flash.display.Graphics;

import spark.components.Button;
import spark.skins.MobileSkin;

public class VScrollBarThumbSkin extends MobileSkin {
    
    public function VScrollBarThumbSkin()
    {
        super();
    }
    
    public var hostComponent:Button;
    
    override public function getExplicitOrMeasuredWidth():Number
    {
        return 8;
    }
    
    override public function getExplicitOrMeasuredHeight():Number
    {
        return 8;
    }
    
    override protected function measure():void
    {
        hostComponent.measuredWidth = 8;
        hostComponent.measuredHeight = 8;   
    }
    
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        var g:Graphics = graphics;
        
        g.clear();
        g.beginFill(0, 0.25);
        g.drawRoundRect(0, 0, unscaledWidth, unscaledHeight, 8, 8);
        g.endFill();
    }
    
}
}