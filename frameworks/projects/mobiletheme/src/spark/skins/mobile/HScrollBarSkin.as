package spark.skins.mobile
{

import spark.components.Button;
import spark.components.HScrollBar;
import spark.skins.MobileSkin;


public class HScrollBarSkin extends MobileSkin {
    
    public function HScrollBarSkin()
    {
        super();
    }
    
    //////////////////////////////////////////
    // Properties
    //////////////////////////////////////////
    
    public var hostComponent:HScrollBar;
    
    // Skin parts
    public var track:Button;
    public var thumb:Button;
    
    //////////////////////////////////////////
    // Methods
    //////////////////////////////////////////
     
    override protected function createChildren():void
    {
        // Create our skin parts: track and thumb.
        track = new Button();
        track.setStyle("skinClass", spark.skins.mobile.HScrollBarTrackSkin);
        addChild(track);
        thumb = new Button();
        thumb.setStyle("skinClass", spark.skins.mobile.HScrollBarThumbSkin);
        addChild(thumb);
    }
    
    override public function getExplicitOrMeasuredWidth():Number
    {
        return 40;
    }
    
    override public function getExplicitOrMeasuredHeight():Number
    {
        return 8; // !!
    }
    
    override protected function measure():void
    {
        // !! should use something better here
        hostComponent.measuredWidth = 40;
        hostComponent.measuredHeight = 8;   
    }
    
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        track.width = unscaledWidth;
        track.height = unscaledHeight;
    }
}
}