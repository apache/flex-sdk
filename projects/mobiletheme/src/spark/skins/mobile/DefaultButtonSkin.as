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

/**
 *  Emphasized button uses accentColor instead of chromeColor. 
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class DefaultButtonSkin extends ButtonSkin
{
    public function DefaultButtonSkin()
    {
        super();
    }
    
    override protected function beginChromeColorFill(chromeColorGraphics:Graphics):void
    {
        // solid color fill for selectable buttons
        chromeColorGraphics.beginFill(getStyle("accentColor"));
    }
}
}