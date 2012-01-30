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

import mx.core.mx_internal;
import mx.utils.ColorUtil;

use namespace mx_internal;

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
    /**
     *  Constructor. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    public function DefaultButtonSkin()
    {
        super();
    }
    
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.drawBackground(unscaledWidth, unscaledHeight);

        // In the down state, the fill shadow is defined in the FXG asset
        if (currentState == "down")
        {
            graphics.beginFill(getStyle("accentColor"));
        }
        else
        {
            var colors:Array = [];
            colorMatrix.createGradientBox(unscaledWidth, unscaledHeight, Math.PI / 2, 0, 0);
            var chromeColor:uint = getStyle("accentColor");
            colors[0] = ColorUtil.adjustBrightness2(chromeColor, 70);
            colors[1] = chromeColor;
            
            graphics.beginGradientFill(GradientType.LINEAR, colors, CHROME_COLOR_ALPHAS, CHROME_COLOR_RATIOS, colorMatrix);
        }
        
        // inset chrome color by BORDER_SIZE
        // bottom line is a shadow
        graphics.drawRoundRect(layoutBorderSize, layoutBorderSize, 
            unscaledWidth - (layoutBorderSize * 2), 
            unscaledHeight - (layoutBorderSize * 2), 
            layoutCornerEllipseSize, layoutCornerEllipseSize);
        graphics.endFill();
    }
}
}