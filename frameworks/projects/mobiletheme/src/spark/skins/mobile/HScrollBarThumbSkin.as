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

import spark.components.Button;
import spark.skins.mobile.supportClasses.MobileSkin;

public class HScrollBarThumbSkin extends MobileSkin 
{
    public function HScrollBarThumbSkin()
    {
        super();
    }
    
    public var hostComponent:Button;
    
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        var g:Graphics = graphics;
        
        var chromeColor:uint = getChromeColor();
        g.clear();
        
        // solid chromeColor border, alpha=1
        g.lineStyle(1, chromeColor);
        
        // solid chromeColor fill, alpha=.5
        g.beginFill(chromeColor, 0.5);
        g.drawRoundRect(0.5, 0.5, unscaledWidth, unscaledHeight, unscaledHeight - 1, unscaledHeight - 1);
        g.endFill();
    }
    
}
}