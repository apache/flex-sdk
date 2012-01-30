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

import mx.core.DPIClassification;

import spark.skins.mobile.supportClasses.SelectableButtonSkinBase;
import spark.skins.mobile160.assets.RadioButton_down;
import spark.skins.mobile160.assets.RadioButton_symbol;
import spark.skins.mobile160.assets.RadioButton_symbolSelected;
import spark.skins.mobile160.assets.RadioButton_up;
import spark.skins.mobile240.assets.RadioButton_down;
import spark.skins.mobile240.assets.RadioButton_symbol;
import spark.skins.mobile240.assets.RadioButton_symbolSelected;
import spark.skins.mobile240.assets.RadioButton_up;
import spark.skins.mobile320.assets.RadioButton_down;
import spark.skins.mobile320.assets.RadioButton_symbol;
import spark.skins.mobile320.assets.RadioButton_symbolSelected;
import spark.skins.mobile320.assets.RadioButton_up;

/**
 *  ActionScript-based skin for RadioButton controls in mobile applications. 
 * 
 * @see spark.components.RadioButton
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class RadioButtonSkin extends SelectableButtonSkinBase
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    static private const exclusions:Array = ["labelDisplay", "labelDisplayShadow"];
    
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
    public function RadioButtonSkin()
    {
        super();
        
        useChromeColor = true;
        
        layoutPaddingLeft = 0;
        layoutPaddingRight = 0;
        layoutPaddingTop = 0;
        layoutPaddingBottom = 0;
        
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                upIconClass = spark.skins.mobile320.assets.RadioButton_up;
                upSelectedIconClass = spark.skins.mobile320.assets.RadioButton_up;
                downIconClass = spark.skins.mobile320.assets.RadioButton_down;
                downSelectedIconClass = spark.skins.mobile320.assets.RadioButton_down;
                upSymbolIconClass = spark.skins.mobile320.assets.RadioButton_symbol;
                downSymbolIconClass = spark.skins.mobile320.assets.RadioButton_symbol;
                upSymbolIconSelectedClass = spark.skins.mobile320.assets.RadioButton_symbolSelected;
                downSymbolIconSelectedClass = spark.skins.mobile320.assets.RadioButton_symbolSelected;
                
                layoutGap = 20;
                layoutMeasuredWidth = 64;
                
                break;
            }
            case DPIClassification.DPI_240:
            {
                upIconClass = spark.skins.mobile240.assets.RadioButton_up;
                upSelectedIconClass = spark.skins.mobile240.assets.RadioButton_up;
                downIconClass = spark.skins.mobile240.assets.RadioButton_down;
                downSelectedIconClass = spark.skins.mobile240.assets.RadioButton_down;
                upSymbolIconClass = spark.skins.mobile240.assets.RadioButton_symbol;
                downSymbolIconClass = spark.skins.mobile240.assets.RadioButton_symbol;
                upSymbolIconSelectedClass = spark.skins.mobile240.assets.RadioButton_symbolSelected;
                downSymbolIconSelectedClass = spark.skins.mobile240.assets.RadioButton_symbolSelected;
                
                layoutGap = 15;
                layoutMeasuredWidth = 48;
                
                break;
            }
            default:
            {
                upIconClass = spark.skins.mobile160.assets.RadioButton_up;
                upSelectedIconClass = spark.skins.mobile160.assets.RadioButton_up;
                downIconClass = spark.skins.mobile160.assets.RadioButton_down;
                downSelectedIconClass = spark.skins.mobile160.assets.RadioButton_down;
                upSymbolIconClass = spark.skins.mobile160.assets.RadioButton_symbol;
                downSymbolIconClass = spark.skins.mobile160.assets.RadioButton_symbol;
                upSymbolIconSelectedClass = spark.skins.mobile160.assets.RadioButton_symbolSelected;
                downSymbolIconSelectedClass = spark.skins.mobile160.assets.RadioButton_symbolSelected;
                
                layoutGap = 10;
                layoutMeasuredWidth = 32;
                
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
     *  RadioButton <code>chromeColor</code> is drawn to match the FXG ellipse
     *  shape and position.
     */
    override protected function drawChromeColor(chromeColorGraphics:Graphics, unscaledWidth:Number, unscaledHeight:Number):void
    {
        // get the size and position of iconDisplay
        var currentIcon:DisplayObject = getIconDisplay();
        chromeColorGraphics.drawEllipse(currentIcon.x + 1, currentIcon.y + 1, currentIcon.width - 2, currentIcon.height - 2);
    }
    
    override public function get focusSkinExclusions():Array 
    {
        return exclusions;
    }
}
}