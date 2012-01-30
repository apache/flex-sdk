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

import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.LineScaleMode;

import mx.core.DPIClassification;
import mx.core.mx_internal;

import spark.components.Button;
import spark.skins.mobile.supportClasses.MobileSkin;

use namespace mx_internal;

/**
 *  ActionScript-based skin for the HScrollBar thumb skin part in mobile applications. 
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class HScrollBarThumbSkin extends MobileSkin 
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    // These constants are also accessed from HScrollBarSkin
    mx_internal static const PADDING_BOTTOM_320DPI:int = 5;
    mx_internal static const PADDING_HORIZONTAL_320DPI:int = 4;
    mx_internal static const PADDING_BOTTOM_240DPI:int = 4;
    mx_internal static const PADDING_HORIZONTAL_240DPI:int = 3;
    mx_internal static const PADDING_BOTTOM_DEFAULTDPI:int = 3;
    mx_internal static const PADDING_HORIZONTAL_DEFAULTDPI:int = 2;
    
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
    public function HScrollBarThumbSkin()
    {
        super();
        
        // Depending on density set padding
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                paddingBottom = PADDING_BOTTOM_320DPI;
                paddingHorizontal = PADDING_HORIZONTAL_320DPI;
                break;
            }
            case DPIClassification.DPI_240:
            {
                paddingBottom = PADDING_BOTTOM_240DPI;
                paddingHorizontal = PADDING_HORIZONTAL_240DPI;
                break;
            }
            default:
            {
                paddingBottom = PADDING_BOTTOM_DEFAULTDPI;
                paddingHorizontal = PADDING_HORIZONTAL_DEFAULTDPI;
                break;
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    /** 
     * @copy spark.skins.spark.ApplicationSkin#hostComponent
     */
    public var hostComponent:Button;
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------    
    /**
     *  Padding from bottom.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    protected var paddingBottom:int;
    
    /**
     *  Horizontal padding from left and right.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    protected var paddingHorizontal:int;
    
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.drawBackground(unscaledWidth, unscaledHeight);

        var thumbHeight:Number = unscaledHeight - paddingBottom;
        
        graphics.beginFill(getStyle("chromeColor"), 1);
        graphics.lineStyle(1, 0x000000, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND);
        graphics.drawRoundRect(paddingHorizontal + .5, 0.5, 
            unscaledWidth - 2 * paddingHorizontal, thumbHeight, 
            thumbHeight, thumbHeight);
        
        graphics.endFill();
    }    
}
}