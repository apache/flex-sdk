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
		useChromeColor = true;
		
		// Depending on density set padding
		switch (applicationDPI)
		{
			case DPIClassification.DPI_320:
			{
				paddingBottom = 5;
				paddingHorizontal = 4;
				break;
			}
			case DPIClassification.DPI_240:
			{
				paddingBottom = 4;
				paddingHorizontal = 3;
				break;
			}
			default:
			{
				paddingBottom = 3;
				paddingHorizontal = 2;
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
	 *  Padding from bottom
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.5
	 *  @productversion Flex 4.5
	 */ 
	protected var paddingBottom:int;

	/**
	 *  Horizontal padding from left and right
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
		var thumbHeight:Number = unscaledHeight - paddingBottom;
		chromeColorGraphics.drawRoundRect(paddingHorizontal + .5, 0.5, 
									      unscaledWidth - 2 * paddingHorizontal, thumbHeight, 
										  thumbHeight, thumbHeight);
	}    
}
}