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
import spark.components.VScrollBar;
import spark.skins.mobile.supportClasses.MobileSkin;


public class VScrollBarSkin extends MobileSkin
{
    public function VScrollBarSkin()
    {
        super();
        
        useChromeColor = true;
        
        switch (targetDensity)
        {
            case MobileSkin.PPI240:
            {
                layoutMeasuredWidth = 8;
                layoutMeasuredHeight = 40;
                
                break;
            }
            default:
            {
                // default PPI160
                layoutMeasuredWidth = 6;
                layoutMeasuredHeight = 26;
                
                break;
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    public var hostComponent:VScrollBar;
    
    //--------------------------------------------------------------------------
    //
    //  Skin parts 
    //
    //--------------------------------------------------------------------------
    public var track:Button;
    
    public var thumb:Button;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    override protected function createChildren():void
    {
        // Create our skin parts: track and thumb.
        track = new Button();
        track.setStyle("skinClass", spark.skins.mobile.VScrollBarTrackSkin);
        track.width = layoutMeasuredWidth;
        track.height = layoutMeasuredHeight;
        addChild(track);
        
        thumb = new Button();
        thumb.setStyle("skinClass", spark.skins.mobile.VScrollBarThumbSkin);
        thumb.width = layoutMeasuredWidth;
        thumb.height = layoutMeasuredWidth;
        addChild(thumb);
    }

    override protected function measure():void
    {
        measuredWidth = layoutMeasuredWidth;
        measuredHeight = layoutMeasuredHeight;
    }

    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        resizeElement(track, unscaledWidth, unscaledHeight);
    }
}
}