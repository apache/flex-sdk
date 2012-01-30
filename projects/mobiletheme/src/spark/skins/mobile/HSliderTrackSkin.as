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
import spark.skins.mobile160.assets.HSliderTrack;
import spark.skins.mobile240.assets.HSliderTrack;
import spark.skins.mobile320.assets.HSliderTrack;

/**
 *  Actionscript based skin for the HSlider track skin part on mobile applications. 
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class HSliderTrackSkin extends MobileSkin
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
    public function HSliderTrackSkin()
    {
        super();
        
        useChromeColor = true;
        
        // set the right assets and dimensions to use based on the screen density
        switch (authorDensity)
        {
            case DeviceDensity.PPI_320:
            {
                trackWidth = 320;
                trackHeight = 18;
                
                visibleTrackWidth = 280;
                visibleTrackLeftOffset = 20;
                
                trackClass = spark.skins.mobile320.assets.HSliderTrack;
                
                break;
            }
            case DeviceDensity.PPI_240:
            {
                trackWidth = 192;
                trackHeight = 13;

                visibleTrackWidth = 160;
                visibleTrackLeftOffset = 16;
                
                trackClass = spark.skins.mobile240.assets.HSliderTrack;
                
                break;
            }
            default:
            {
                // default PPI160
                trackWidth = 160;
                trackHeight = 10;
                
                visibleTrackWidth = 140;
                visibleTrackLeftOffset = 10;
                
                trackClass = spark.skins.mobile160.assets.HSliderTrack;
                
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
     *  Specifies the FXG class to use for the track image
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var trackClass:Class;
    
    /**
     *  Specifies the DisplayObject for the track image
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var trackSkin:DisplayObject;

    /**
     *  Specifies the track image width
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    protected var trackWidth:int;
    
    /**
     *  Specifies the track image height
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var trackHeight:int;

    /**
     *  Specifies the offset from the left edge to where
     *  the visible track begins
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var visibleTrackLeftOffset:int;
    
    /**
     *  Specifies the width of the actual visible track
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var visibleTrackWidth:int;

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
        trackSkin = new trackClass();
        addChild(trackSkin);
    }
    
    /**
     *  @private 
     */ 
    override protected function measure():void
    {
        measuredWidth = trackWidth;
        measuredHeight = trackHeight;
    }
    
    /**
     *  @private 
     */ 
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        setElementSize(trackSkin, unscaledWidth, unscaledHeight);
        setElementPosition(trackSkin, 0, 0);
    }
    
    /**
     *  @private 
     */ 
    override protected function drawChromeColor(chromeColorGraphics:Graphics, unscaledWidth:Number, unscaledHeight:Number):void
    {        
        var calculatedTrackWidth:int = unscaledWidth - (2 * visibleTrackLeftOffset);
        
        // draw the round rect
        var chromeColor:uint = getChromeColor();
        chromeColorGraphics.beginFill(chromeColor, 1);
        chromeColorGraphics.drawRoundRect(visibleTrackLeftOffset, 0,
                                          calculatedTrackWidth, trackHeight,
                                          trackHeight, trackHeight);
        chromeColorGraphics.endFill();
    }
}
}