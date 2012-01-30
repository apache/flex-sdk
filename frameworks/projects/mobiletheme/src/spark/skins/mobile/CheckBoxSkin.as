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

import spark.skins.mobile.supportClasses.MobileSkin;
import spark.skins.mobile.supportClasses.SelectableButtonSkinBase;
import spark.skins.mobile160.assets.CheckBox_down;
import spark.skins.mobile160.assets.CheckBox_symbol;
import spark.skins.mobile160.assets.CheckBox_up;
import spark.skins.mobile240.assets.CheckBox_down;
import spark.skins.mobile240.assets.CheckBox_symbol;
import spark.skins.mobile240.assets.CheckBox_up;

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
    
    public function CheckBoxSkin()
    {
        super();
        
        useChromeColor = true;
        
        switch (targetDensity)
        {
            case MobileSkin.PPI240:
            {
                upIconClass = spark.skins.mobile240.assets.CheckBox_up;
                upSelectedIconClass = spark.skins.mobile240.assets.CheckBox_up;
                downIconClass = spark.skins.mobile240.assets.CheckBox_down;
                downSelectedIconClass = spark.skins.mobile240.assets.CheckBox_down;
                symbolIconClass = spark.skins.mobile240.assets.CheckBox_symbol;
                
                layoutGap = 15;
                layoutPaddingLeft = 15;
                layoutPaddingRight = 15;
                layoutPaddingTop = 15;
                layoutPaddingBottom = 15;
                layoutMeasuredWidth = 48;
                
                break;
            }
            default:
            {
                // TODO (jasonsj): 160ppi XD spec
                // default PPI160
                upIconClass = spark.skins.mobile160.assets.CheckBox_up; 
                upSelectedIconClass = spark.skins.mobile160.assets.CheckBox_up;
                downIconClass = spark.skins.mobile160.assets.CheckBox_down;
                downSelectedIconClass = spark.skins.mobile160.assets.CheckBox_down;
                symbolIconClass = spark.skins.mobile160.assets.CheckBox_symbol;
                
                layoutGap = 15;
                layoutPaddingLeft = 15;
                layoutPaddingRight = 15;
                layoutPaddingTop = 15;
                layoutPaddingBottom = 15;
                layoutMeasuredWidth = 48;
                
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
        // TODO (jasonsj): layout variables for chrome color shape
        chromeColorGraphics.drawRoundRect(currentIcon.x + 2, currentIcon.y + 2, currentIcon.width - 4, currentIcon.height - 4, 4, 4);
    }
    
    override public function get focusSkinExclusions():Array 
    {
        return exclusions;
    }
}
}