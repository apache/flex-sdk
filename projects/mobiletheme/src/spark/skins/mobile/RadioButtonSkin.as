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
import flash.display.Graphics;

import mx.utils.ColorUtil;

import spark.core.SpriteVisualElement;
import spark.skins.mobile.supportClasses.MobileSkin;
import spark.skins.mobile.supportClasses.SelectableButtonSkinBase;
import spark.skins.mobile160.assets.RadioButton_down;
import spark.skins.mobile160.assets.RadioButton_downSelected;
import spark.skins.mobile160.assets.RadioButton_symbol;
import spark.skins.mobile160.assets.RadioButton_up;
import spark.skins.mobile160.assets.RadioButton_upSelected;
import spark.skins.mobile240.assets.RadioButton_down;
import spark.skins.mobile240.assets.RadioButton_downSelected;
import spark.skins.mobile240.assets.RadioButton_symbol;
import spark.skins.mobile240.assets.RadioButton_up;
import spark.skins.mobile240.assets.RadioButton_upSelected;

/**
 *  Actionscript based skin for RadioButton on mobile applications. 
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
    
    public function RadioButtonSkin()
    {
        super();
        
        useChromeColor = true;
        
        switch (targetDensity)
        {
            case MobileSkin.PPI240:
            {
                upIconClass = spark.skins.mobile240.assets.RadioButton_up;
                upSelectedIconClass = spark.skins.mobile240.assets.RadioButton_upSelected;
                downIconClass = spark.skins.mobile240.assets.RadioButton_down;
                downSelectedIconClass = spark.skins.mobile240.assets.RadioButton_downSelected;
                symbolIconClass = spark.skins.mobile240.assets.RadioButton_symbol;
                
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
                // TODO (jasonsj) 160ppi spec
                // default PPI160
                upIconClass = spark.skins.mobile160.assets.RadioButton_up;
                upSelectedIconClass = spark.skins.mobile160.assets.RadioButton_upSelected;
                downIconClass = spark.skins.mobile160.assets.RadioButton_down;
                downSelectedIconClass = spark.skins.mobile160.assets.RadioButton_downSelected;
                symbolIconClass = spark.skins.mobile160.assets.RadioButton_symbol;
                
                layoutGap = 15;
                layoutPaddingLeft = 15;
                layoutPaddingRight = 15;
                layoutPaddingTop = 15;
                layoutPaddingBottom = 15;
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