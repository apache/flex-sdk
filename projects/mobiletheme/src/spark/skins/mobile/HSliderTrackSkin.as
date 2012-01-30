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

import mx.core.DPIClassification;

import spark.components.Button;
import spark.skins.mobile.supportClasses.MobileSkin;
import spark.skins.mobile160.assets.HSliderTrack;
import spark.skins.mobile240.assets.HSliderTrack;
import spark.skins.mobile320.assets.HSliderTrack;

/**
 *  ActionScript-based skin for the HSlider track skin part in mobile applications. 
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
        
        // set the right assets and dimensions to use based on the screen density
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                trackWidth = 640;
                trackHeight = 18;
                
                visibleTrackWidth = 280;
                visibleTrackLeftOffset = 20;
                
                trackClass = spark.skins.mobile320.assets.HSliderTrack;
                
                break;
            }
            case DPIClassification.DPI_240:
            {
                trackWidth = 768;
                trackHeight = 13;
                
                visibleTrackWidth = 160;
                visibleTrackLeftOffset = 16;
                
                trackClass = spark.skins.mobile240.assets.HSliderTrack;
                
                break;
            }
            default:
            {
                // default PPI160
                trackWidth = 640;
                trackHeight = 10;
                
                visibleTrackWidth = 300;
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
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.layoutContents(unscaledWidth, unscaledHeight);
        
        setElementSize(trackSkin, unscaledWidth, unscaledHeight);
        setElementPosition(trackSkin, 0, 0);
    }
    
    /**
     *  @private 
     */ 
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {        
        super.drawBackground(unscaledWidth, unscaledHeight);

        var calculatedTrackWidth:int = unscaledWidth - (2 * visibleTrackLeftOffset);
        
        // draw the round rect
        graphics.beginFill(getStyle("chromeColor"), 1);
        graphics.drawRoundRect(visibleTrackLeftOffset, 0,
            calculatedTrackWidth, trackHeight,
            trackHeight, trackHeight);
        graphics.endFill();
    }
}
}