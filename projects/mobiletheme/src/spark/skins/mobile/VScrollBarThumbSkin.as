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
import flash.display.Graphics;
import flash.display.JointStyle;
import flash.display.LineScaleMode;

import mx.core.DPIClassification;

import spark.components.Button;
import spark.skins.mobile.supportClasses.MobileSkin;

/**
 *  ActionScript-based skin for the VScrollBar thumb skin part in mobile applications. 
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class VScrollBarThumbSkin extends MobileSkin 
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
     * 
     */
    public function VScrollBarThumbSkin()
    {
        super();
        useChromeColor = true;
        
        // Depending on density set padding
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                paddingRight = 5;
                paddingVertical = 4;
                break;
            }
            case DPIClassification.DPI_240:
            {
                paddingRight = 4;
                paddingVertical = 3;
                break;
            }
            default:
            {
                paddingRight = 3;
                paddingVertical = 2;
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
     *  Padding from the right
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    protected var paddingRight:int;
    
    /**
     *  Vertical padding from top and bottom
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    protected var paddingVertical:int;
    
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------	
    /**
     *  @protected
     */ 
    override protected function beginChromeColorFill(chromeColorGraphics:Graphics):void
    {
        var chromeColor:uint = getChromeColor();
        chromeColorGraphics.beginFill(chromeColor, 1);
        chromeColorGraphics.lineStyle(1, 0x000000, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND);
    }
    
    /**
     *  @protected
     */ 
    override protected function drawChromeColor(chromeColorGraphics:Graphics, unscaledWidth:Number, unscaledHeight:Number):void
    {
        var thumbWidth:Number = unscaledWidth - paddingRight;
        chromeColorGraphics.drawRoundRect(0.5, paddingVertical + 0.5, 
            thumbWidth, unscaledHeight - 2 * paddingVertical, 
            thumbWidth, thumbWidth);
    }
    
}
}