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
import mx.core.mx_internal;

import spark.skins.mobile.supportClasses.MobileSkin;
import spark.skins.mobile160.assets.BeveledBackButton_down;
import spark.skins.mobile160.assets.BeveledBackButton_up;
import spark.skins.mobile240.assets.BeveledBackButton_down;
import spark.skins.mobile240.assets.BeveledBackButton_fill;
import spark.skins.mobile240.assets.BeveledBackButton_up;
import spark.skins.mobile320.assets.BeveledBackButton_down;
import spark.skins.mobile320.assets.BeveledBackButton_up;

use namespace mx_internal;

/**
 *  iOS-styled ActionBar Button skin for use in the navigationContent
 *  skinPart.
 * 
 *  @see spark.components.ActionBar#navigationContent
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class BeveledBackButtonSkin extends ButtonSkin
{
    
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
    public function BeveledBackButtonSkin()
    {
        super();
        
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                // 320
                layoutBorderSize = 0;
                layoutPaddingTop = 0;
                layoutPaddingBottom = 0;
                layoutPaddingLeft = 32;
                layoutPaddingRight = 20;
                measuredDefaultWidth = 116;
                measuredDefaultHeight = 54;
                
                upBorderSkin = spark.skins.mobile320.assets.BeveledBackButton_up;
                downBorderSkin = spark.skins.mobile320.assets.BeveledBackButton_down;
                fillClass = spark.skins.mobile320.assets.BeveledBackButton_fill;
                
                break;
            }
            case DPIClassification.DPI_240:
            {
                // 240
                layoutBorderSize = 0;
                layoutPaddingTop = 0;
                layoutPaddingBottom = 0;
                layoutPaddingLeft = 23;
                layoutPaddingRight = 15;
                measuredDefaultWidth = 87;
                measuredDefaultHeight = 42;
                
                upBorderSkin = spark.skins.mobile240.assets.BeveledBackButton_up;
                downBorderSkin = spark.skins.mobile240.assets.BeveledBackButton_down;
                fillClass = spark.skins.mobile240.assets.BeveledBackButton_fill;
                
                break;
            }
            default:
            {
                // 160
                layoutBorderSize = 0;
                layoutPaddingTop = 0;
                layoutPaddingBottom = 0;
                layoutPaddingLeft = 16;
                layoutPaddingRight = 10;
                measuredDefaultWidth = 58;
                measuredDefaultHeight = 28;
                
                upBorderSkin = spark.skins.mobile160.assets.BeveledBackButton_up;
                downBorderSkin = spark.skins.mobile160.assets.BeveledBackButton_down;
                fillClass = spark.skins.mobile160.assets.BeveledBackButton_fill;
                
                break;
            }
        }
        
        // beveled buttons do not scale down
        minHeight = measuredDefaultHeight;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    private var _fill:DisplayObject;
    
    private var fillClass:Class;
    
    private var colorized:Boolean;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.layoutContents(unscaledWidth, unscaledHeight);
        
        // add separate chromeColor fill graphic as the first layer
        if (!_fill && fillClass)
        {
            _fill = new fillClass();
            addChildAt(_fill, 0);
        }
        
        if (_fill)
        {
            // move to the first layer
            if (getChildIndex(_fill) > 0)
            {
                removeChild(_fill);
                addChildAt(_fill, 0);
            }
            
            setElementSize(_fill, unscaledWidth, unscaledHeight);
        }
    }
    
    /**
     *  @private
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // omit call to super.drawBackground(), apply tint instead and don't draw fill
        var chromeColor:uint = getStyle(fillColorStyleName);
        
        if (colorized || (chromeColor != MobileSkin.MOBILE_THEME_DARK_COLOR))
        {
            // apply tint instead of fill
            applyColorTransform(_fill, MobileSkin.MOBILE_THEME_DARK_COLOR, chromeColor);
            
            // if we restore to original color, unset colorized
            colorized = (chromeColor != MobileSkin.MOBILE_THEME_DARK_COLOR);
        }
    }
}
}