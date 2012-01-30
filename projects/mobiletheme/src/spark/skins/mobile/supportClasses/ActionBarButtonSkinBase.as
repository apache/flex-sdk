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

package spark.skins.mobile.supportClasses
{
import flash.display.DisplayObject;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.geom.Matrix;

import mx.core.DeviceDensity;
import mx.utils.ColorUtil;

import spark.skins.mobile.ButtonSkin;

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
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    private static var matrix:Matrix = new Matrix();
    
    // Used for gradient background
    private static const alphas:Array = [1, 1, 1];
    
    private static const ratios:Array = [0, 127.5, 255];
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    public function ActionBarButtonSkinBase()
    {
        super();
        
        switch (authorDensity)
        {
            case DeviceDensity.PPI_240:
            {
                layoutBorderSize = 1;
                layoutPaddingTop = 8;
                layoutPaddingBottom = 8;
                layoutPaddingLeft = 16;
                layoutPaddingRight = 16;
                layoutMeasuredWidth = 81;
                layoutMeasuredHeight = 65;
                
                break;
            }
            default:
            {
                // default PPI160
                layoutBorderSize = 1;
                layoutPaddingTop = 7
                layoutPaddingBottom = 7;
                layoutPaddingLeft = 10;
                layoutPaddingRight = 10;
                layoutMeasuredWidth = 55;
                layoutMeasuredHeight = 44;
                
                break;
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    override protected function measure():void
    {
        super.measure();
        
        measuredMinWidth = Math.max(layoutMeasuredWidth, measuredMinWidth);
        measuredMinHeight =  Math.max(layoutMeasuredHeight, measuredMinHeight);
        measuredWidth = Math.max(layoutMeasuredWidth, measuredWidth);
        measuredHeight =  Math.max(layoutMeasuredHeight, measuredHeight);
    }
    
    override protected function layoutBorder(bgImg:DisplayObject, unscaledWidth:Number, unscaledHeight:Number):void
    {
        // extend 1px outside measured width to overlap highlight borders
        resizeElement(bgImg, unscaledWidth + layoutBorderSize, unscaledHeight);
        positionElement(bgImg, 0, 0);
    }
    
    override protected function drawChromeColor(chromeColorGraphics:Graphics, unscaledWidth:Number, unscaledHeight:Number):void
    {
        drawBackgroundOffset(chromeColorGraphics, 0, unscaledWidth, unscaledHeight);
    }
    
    protected function drawBackgroundOffset(chromeColorGraphics:Graphics, xOffset:Number, backgroundWidth:Number, backgroundHeight:Number):void
    {
        var colors:Array = [];
        
        // Draw the gradient background
        matrix.createGradientBox(backgroundWidth, backgroundHeight, Math.PI / 2, 0, 0);
        var chromeColor:uint = getChromeColor();
        colors[0] = ColorUtil.adjustBrightness2(chromeColor, 20);
        colors[1] = chromeColor;
        colors[2] = ColorUtil.adjustBrightness2(chromeColor, -20);
        
        chromeColorGraphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
        
        // adjust for separator
        chromeColorGraphics.drawRect(xOffset, 0, backgroundWidth, backgroundHeight);
        chromeColorGraphics.endFill();
    }
}
}