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
import flash.display.DisplayObject;
import flash.display.GradientType;
import flash.geom.ColorTransform;
import flash.geom.Matrix;

import mx.utils.ColorUtil;

/**
 *  Base skin class for ActionBar buttons. Adds flat-look button border and
 *  background color.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class ActionBarButtonSkinBase extends ButtonSkin
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    public function ActionBarButtonSkinBase()
    {
        super();
        paddingTop = 8;
        paddingBottom = 8;
        paddingLeft = 16;
        paddingRight = 16;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    private static var matrix:Matrix = new Matrix();
    
    // Used for gradient background
    private static const alphas:Array = [1, 1, 1];
    private static const ratios:Array = [0, 127.5, 255];
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    override protected function measure():void
    {
        super.measure();
        
        // 81x64 (+1 width for FXG separators)
        measuredMinWidth = Math.max(81, measuredMinWidth);
        measuredMinHeight =  Math.max(65, measuredMinHeight);
        measuredWidth = Math.max(81, measuredWidth);
        measuredHeight =  Math.max(65, measuredHeight);
    }
    
    override protected function layoutBorder(bgImg:DisplayObject, unscaledWidth:Number, unscaledHeight:Number):void
    {
        // extend 1px outside measured width to overlap highlight borders
        resizePart(bgImg, unscaledWidth + 1, unscaledHeight);
        positionPart(bgImg, 0, 0);
    }
    
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        drawBackgroundOffset(0, unscaledWidth, unscaledHeight);
    }
    
    protected function drawBackgroundOffset(xOffset:Number, backgroundWidth:Number, backgroundHeight:Number):void
    {
        var colors:Array = [];
        
        graphics.clear();
        
        // Draw the gradient background
        matrix.createGradientBox(backgroundWidth, backgroundHeight, Math.PI / 2, 0, 0);
        var chromeColor:uint = getStyle("chromeColor");
        colors[0] = ColorUtil.adjustBrightness2(chromeColor, 20);
        colors[1] = chromeColor;
        colors[2] = ColorUtil.adjustBrightness2(chromeColor, -20);
        
        graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
        
        // adjust for separator
        graphics.drawRect(xOffset, 0, backgroundWidth, backgroundHeight);
        graphics.endFill();
    }
}
}