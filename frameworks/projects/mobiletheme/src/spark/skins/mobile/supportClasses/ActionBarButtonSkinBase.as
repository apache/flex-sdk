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
 *  Base skin class for ActionBar buttons in mobile applications. To support
 *  overlay modes in ViewNavigator, this base skin is transparent in all states
 *  except for the down state.
 * 
 *  @see spark.components.ActionBar
 *  @see spark.components.supportClasses.ViewNavigatorBase#overlayControls
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
                measuredDefaultWidth = 106;
                measuredDefaultHeight = 86;
                
                break;
            }
            case DPIClassification.DPI_240:
            {
                layoutBorderSize = 1;
                layoutPaddingTop = 9;
                layoutPaddingBottom = 8;
                layoutPaddingLeft = 16;
                layoutPaddingRight = 16;
                measuredDefaultWidth = 81;
                measuredDefaultHeight = 65;
                
                break;
            }
            default:
            {
                // default DPI_160
                layoutBorderSize = 1;
                layoutPaddingTop = 6;
                layoutPaddingBottom = 5;
                layoutPaddingLeft = 10;
                layoutPaddingRight = 10;
                measuredDefaultWidth = 53;
                measuredDefaultHeight = 43;
                
                break;
            }
        }
    }
    
    /**
     * @private
     * Disabled state for ActionBar buttons only applies to label and icon
     */
    override protected function commitDisabled():void
    {
        var alphaValue:Number = (hostComponent.enabled) ? 1 : 0.5
        
        labelDisplay.alpha = alphaValue;
        labelDisplayShadow.alpha = alphaValue;
        
        var icon:DisplayObject = getIconDisplay();
        
        if (icon != null)
            icon.alpha = alphaValue;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     * @private
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // omit super.drawBackground() to drawRect instead
        // only draw chromeColor in down state (transparent hit zone otherwise)
        var isDown:Boolean = (currentState == "down");
        var chromeColor:uint = isDown ? getStyle(fillColorStyleName) : 0;
        var chromeAlpha:Number = isDown ? 1 : 0;
        
        graphics.beginFill(chromeColor, chromeAlpha);
        graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
        graphics.endFill();
    }
}
}