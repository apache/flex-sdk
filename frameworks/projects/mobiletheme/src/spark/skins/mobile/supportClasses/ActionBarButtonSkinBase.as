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

import mx.core.DPIClassification;
import mx.core.mx_internal;
import mx.utils.ColorUtil;

import spark.skins.mobile.ActionBarSkin;
import spark.skins.mobile.ButtonSkin;

use namespace mx_internal;

/**
 *  Base skin class for ActionBar buttons in mobile applications. Adds flat-look button border and
 *  background color.
 * 
 * @see spark.components.ActionBar
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
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    /**
     *  Constructor.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     * 
     */
    public function ActionBarButtonSkinBase()
    {
        super();
        
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                layoutBorderSize = 1;
                layoutPaddingTop = 12;
                layoutPaddingBottom = 10;
                layoutPaddingLeft = 20;
                layoutPaddingRight = 20;
                layoutMeasuredWidth = 106;
                layoutMeasuredHeight = 86;
                
                break;
            }
            case DPIClassification.DPI_240:
            {
                layoutBorderSize = 1;
                layoutPaddingTop = 9;
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
                layoutPaddingTop = 6;
                layoutPaddingBottom = 5;
                layoutPaddingLeft = 10;
                layoutPaddingRight = 10;
                layoutMeasuredWidth = 53;
                layoutMeasuredHeight = 43;
                
                break;
            }
        }
    }
    
    /**
     * @private
     * Disabled state for ActionBar buttons only applies to label and icon
     */
    override protected function commitDisabled(isDisabled:Boolean):void
    {
        labelDisplay.alpha = (isDisabled) ? 0.5 : 1;
        labelDisplayShadow.alpha = (isDisabled) ? 0.5 : 1;
        
        var icon:DisplayObject = getIconDisplay();
        
        if (icon != null)
            icon.alpha = (isDisabled) ? 0.5 : 1;
    }
    
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();
        
        measuredMinWidth = Math.max(layoutMeasuredWidth, measuredMinWidth);
        measuredMinHeight =  Math.max(layoutMeasuredHeight, measuredMinHeight);
        measuredWidth = Math.max(layoutMeasuredWidth, measuredWidth);
        measuredHeight =  Math.max(layoutMeasuredHeight, measuredHeight);
    }
    
    override protected function beginChromeColorFill(chromeColorGraphics:Graphics):void
    {
        var chromeColor:uint = getChromeColor();
        
        // solid color fill in down state
        if (currentState == "down")
        {
            chromeColorGraphics.beginFill(chromeColor);
            return;
        }
        
        var colors:Array = [];
        
        // FIXME (jasonsj): overlayMode alpha on background only or entire ActionBar?
        var backgroundAlphas:Array = [1, 1];
        
        // Draw the gradient background
        matrix.createGradientBox(unscaledWidth - layoutBorderSize, unscaledHeight, Math.PI / 2, 0, 0);
        colors[0] = ColorUtil.adjustBrightness2(chromeColor, 20);
        colors[1] = chromeColor;
        
        chromeColorGraphics.beginGradientFill(GradientType.LINEAR, colors, backgroundAlphas, ActionBarSkin.ACTIONBAR_CHROME_COLOR_RATIOS, matrix);
    }
    
    override protected function drawChromeColor(chromeColorGraphics:Graphics, unscaledWidth:Number, unscaledHeight:Number):void
    {
        chromeColorGraphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
    }
}
}