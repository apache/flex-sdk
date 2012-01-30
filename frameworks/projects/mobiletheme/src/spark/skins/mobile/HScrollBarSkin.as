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

import spark.components.Button;
import spark.components.HScrollBar;
import spark.skins.mobile.supportClasses.MobileSkin;


public class HScrollBarSkin extends MobileSkin 
{
    
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
        measuredWidth = 40;
        measuredHeight = 8;
    }
    
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        resizePart(track, unscaledWidth, unscaledHeight);
    }
}
}