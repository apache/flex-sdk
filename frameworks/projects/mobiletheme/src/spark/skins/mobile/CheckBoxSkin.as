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
import flash.display.Graphics;

import mx.core.DeviceDensity;

import spark.skins.mobile.supportClasses.SelectableButtonSkinBase;
import spark.skins.mobile160.assets.CheckBox_down;
import spark.skins.mobile160.assets.CheckBox_downSymbol;
import spark.skins.mobile160.assets.CheckBox_downSymbolSelected;
import spark.skins.mobile160.assets.CheckBox_up;
import spark.skins.mobile160.assets.CheckBox_upSymbol;
import spark.skins.mobile160.assets.CheckBox_upSymbolSelected;
import spark.skins.mobile240.assets.CheckBox_down;
import spark.skins.mobile240.assets.CheckBox_downSymbol;
import spark.skins.mobile240.assets.CheckBox_downSymbolSelected;
import spark.skins.mobile240.assets.CheckBox_up;
import spark.skins.mobile240.assets.CheckBox_upSymbol;
import spark.skins.mobile240.assets.CheckBox_upSymbolSelected;
import spark.skins.mobile320.assets.CheckBox_down;
import spark.skins.mobile320.assets.CheckBox_downSymbol;
import spark.skins.mobile320.assets.CheckBox_downSymbolSelected;
import spark.skins.mobile320.assets.CheckBox_up;
import spark.skins.mobile320.assets.CheckBox_upSymbol;
import spark.skins.mobile320.assets.CheckBox_upSymbolSelected;

/**
 *  Actionscript based skin for CheckBox on mobile applications. 
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class CheckBoxSkin extends SelectableButtonSkinBase
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    private static const exclusions:Array = ["labelDisplay", "labelDisplayShadow"];
    
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
     */
    public function CheckBoxSkin()
    {
        super();
        
        useChromeColor = true;
        
        layoutPaddingLeft = 0;
        layoutPaddingRight = 0;
        layoutPaddingTop = 0;
        layoutPaddingBottom = 0;
        
        switch (authorDensity)
        {
            case DeviceDensity.PPI_320:
            {
                upIconClass = spark.skins.mobile320.assets.CheckBox_up;
                upSelectedIconClass = spark.skins.mobile320.assets.CheckBox_up;
                downIconClass = spark.skins.mobile320.assets.CheckBox_down;
                downSelectedIconClass = spark.skins.mobile320.assets.CheckBox_down;
                upSymbolIconClass = spark.skins.mobile320.assets.CheckBox_upSymbol;
                upSymbolIconSelectedClass = spark.skins.mobile320.assets.CheckBox_upSymbolSelected;
                downSymbolIconClass = spark.skins.mobile320.assets.CheckBox_downSymbol;
                downSymbolIconSelectedClass = spark.skins.mobile320.assets.CheckBox_downSymbolSelected;
                
                layoutGap = 20;
                layoutMeasuredWidth = 64;
                layoutBorderSize = 4;
                
                break;
            }
            case DeviceDensity.PPI_240:
            {
                upIconClass = spark.skins.mobile240.assets.CheckBox_up;
                upSelectedIconClass = spark.skins.mobile240.assets.CheckBox_up;
                downIconClass = spark.skins.mobile240.assets.CheckBox_down;
                downSelectedIconClass = spark.skins.mobile240.assets.CheckBox_down;
                upSymbolIconClass = spark.skins.mobile240.assets.CheckBox_upSymbol;
                upSymbolIconSelectedClass = spark.skins.mobile240.assets.CheckBox_upSymbolSelected;
                downSymbolIconClass = spark.skins.mobile240.assets.CheckBox_downSymbol;
                downSymbolIconSelectedClass = spark.skins.mobile240.assets.CheckBox_downSymbolSelected;
                
                layoutGap = 15;
                layoutMeasuredWidth = 48;
                layoutBorderSize = 2;
                
                break;
            }
            default:
            {
                // default PPI160
                upIconClass = spark.skins.mobile160.assets.CheckBox_up;
                upSelectedIconClass = spark.skins.mobile160.assets.CheckBox_up;
                downIconClass = spark.skins.mobile160.assets.CheckBox_down;
                downSelectedIconClass = spark.skins.mobile160.assets.CheckBox_down;
                upSymbolIconClass = spark.skins.mobile160.assets.CheckBox_upSymbol;
                upSymbolIconSelectedClass = spark.skins.mobile160.assets.CheckBox_upSymbolSelected;
                downSymbolIconClass = spark.skins.mobile160.assets.CheckBox_downSymbol;
                downSymbolIconSelectedClass = spark.skins.mobile160.assets.CheckBox_downSymbolSelected;
                
                layoutGap = 10;
                layoutMeasuredWidth = 32;
                layoutBorderSize = 2;
                
                break;
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  CheckBox <code>chromeColor</code> is drawn to match the FXG rectangle
     *  shape and position.
     */
    override protected function drawChromeColor(chromeColorGraphics:Graphics, unscaledWidth:Number, unscaledHeight:Number):void
    {
        // get the size and position of iconDisplay
        var currentIcon:DisplayObject = getIconDisplay();
        var widthAdjustment:Number = layoutBorderSize * 2;
        
        chromeColorGraphics.drawRoundRect(currentIcon.x + layoutBorderSize,
            currentIcon.y + layoutBorderSize,
            currentIcon.width - widthAdjustment,
            currentIcon.height - widthAdjustment, layoutBorderSize, layoutBorderSize);
    }
    
    override public function get focusSkinExclusions():Array 
    {
        return exclusions;
    }
}
}