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
import spark.skins.mobile160.assets.VScrollThumb;
import spark.skins.mobile240.assets.VScrollThumb;

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
        
        // Depending on density set asset and visible thumb width
        switch (authorDensity)
        {
            case DeviceDensity.PPI_240:
            {
                thumbClass = spark.skins.mobile240.assets.VScrollThumb;
                thumbWidth = 6;
                break;
            }
            default:
            {
                thumbClass = spark.skins.mobile160.assets.VScrollThumb;
                thumbWidth = 4;
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
     *  Specifies the FXG class to use for the thumb.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    protected var thumbClass:Class;
    
    /**
     *  Specifies the DisplayObject to use for the thumb.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    protected var thumbSkin:DisplayObject;
    
    /**
     *  Width of the visible thumb area.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    protected var thumbWidth:int;
    
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    /**
     *  @private
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
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        setElementSize(thumbSkin, unscaledWidth, unscaledHeight);
    }
    
    
    /**
     *  @private
     */
    override protected function beginChromeColorFill(chromeColorGraphics:Graphics):void
    {
        var chromeColor:uint = getChromeColor();
        chromeColorGraphics.beginFill(chromeColor, 1);  
    }
    
    /**
     *  @private
     */
    override protected function drawChromeColor(chromeColorGraphics:Graphics, unscaledWidth:Number, unscaledHeight:Number):void
    {
        chromeColorGraphics.drawRoundRect(0, 0, 
                                          thumbWidth, unscaledHeight, 
                                          thumbWidth, thumbWidth);
    }
    
}
}