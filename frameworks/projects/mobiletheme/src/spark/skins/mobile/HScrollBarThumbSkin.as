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

import spark.components.Button;
import spark.skins.mobile.supportClasses.MobileSkin;
import spark.skins.mobile160.assets.HScrollThumb;
import spark.skins.mobile240.assets.HScrollThumb;

public class HScrollBarThumbSkin extends MobileSkin 
{
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
    public function HScrollBarThumbSkin()
    {
        super();
		useChromeColor = true;
		
		// Depending on density set asset and visible thumb height
		switch (authorDensity)
		{
			case DeviceDensity.PPI_240:
			{
				thumbClass = spark.skins.mobile240.assets.HScrollThumb;
				thumbHeight = 6;
				break;
			}
			default:
			{
				thumbClass = spark.skins.mobile160.assets.HScrollThumb;
				thumbHeight = 4;
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
	 *  Specifies the FXG class to use for the thumb
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.5
	 *  @productversion Flex 4.5
	 */    
	public var thumbClass:Class;
	
	/**
	 *  Specifies the DisplayObject to use for the thumb
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.5
	 *  @productversion Flex 4.5
	 */ 
	public var thumbSkin:DisplayObject;

	
	/**
	 *  Height of the visible thumb area
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.5
	 *  @productversion Flex 4.5
	 */ 
	protected var thumbHeight:int;
	
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------
	/**
	 *  @protected
	 */ 
	override protected function createChildren():void
	{
		if (!thumbSkin)
		{
			thumbSkin = new thumbClass();
			addChild(thumbSkin);	
		}
	}
	
	/**
	 *  @protected
	 */ 
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		setElementSize(thumbSkin, unscaledWidth, unscaledHeight);
	}

	/**
	 *  @protected
	 */ 
	override protected function beginChromeColorFill(chromeColorGraphics:Graphics):void
	{
		var chromeColor:uint = getChromeColor();
		chromeColorGraphics.beginFill(chromeColor, 1);
	}
	
	/**
	 *  @protected
	 */ 
    override protected function drawChromeColor(chromeColorGraphics:Graphics, unscaledWidth:Number, unscaledHeight:Number):void
    {
		chromeColorGraphics.drawRoundRect(0, 0, 
									      unscaledWidth, thumbHeight, 
										  thumbHeight, thumbHeight);
	}
    
}
}