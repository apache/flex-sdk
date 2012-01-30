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
            case DeviceDensity.PPI_240:
            {
                trackWidth = 240;
                trackHeight = 65;

                trackClass = spark.skins.mobile240.assets.HSliderTrack;
                
                visibleTrackRectLeft = 10;
                visibleTrackRectRight = 11;
                visibleTrackRectTop = 26;
                visibleTrackRectHeight = 13;
                visibleTrackEllipseHeight = 13;
                visibleTrackEllipseWidth = 13;
                
                break;
            }
            default:
            {
                // default PPI160
                trackWidth = 160;
                trackHeight = 40;
                
                trackClass = spark.skins.mobile160.assets.HSliderTrack;
                
                visibleTrackRectLeft = 5;
                visibleTrackRectRight = 5;
                visibleTrackRectTop = 16;
                visibleTrackRectHeight = 9;
                visibleTrackEllipseHeight = 9;
                visibleTrackEllipseWidth = 9;
                
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
     *  Specifies the distance of the actual visible track from the left
     *  of the track image
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private var visibleTrackRectLeft:int;
    
    /**
     *  Specifies the distance of the actual visible track from the right
     *  of the track image
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private var visibleTrackRectRight:int;

    /**
     *  Specifies the distance of the actual visible track from the top
     *  of the track image
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private var visibleTrackRectTop:int;
    
    /**
     *  Specifies the actual visible track Rect height
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private var visibleTrackRectHeight:int;
    
    /**
     *  Specifies the actual visible track Ellipse height (i.e. the
     *  ellipse which provides the rounded ends of the track)
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private var visibleTrackEllipseHeight:int;
    
    /**
     *  Specifies the actual visible track Ellipse width (i.e. the
     *  ellipse which provides the rounded ends of the track)
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private var visibleTrackEllipseWidth:int;
    
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
        
		resizeElement(trackSkin, unscaledWidth, unscaledHeight);
		positionElement(trackSkin, 0, 0);
	}
    
    /**
     *  @private 
     */ 
    override protected function drawChromeColor(chromeColorGraphics:Graphics, unscaledWidth:Number, unscaledHeight:Number):void
    {
        // calculate the track Y location: the visible track is vertically centered as height grows
        var trackY:int = Math.max(visibleTrackRectTop, Math.round(visibleTrackRectTop / trackHeight * unscaledHeight));
        
        // calculated track width: excludes gaps on the left and right
        var trackWidth:int = unscaledWidth - visibleTrackRectLeft - visibleTrackRectRight; 
        
        // draw the round rect
        var chromeColor:uint = getChromeColor();
        chromeColorGraphics.beginFill(chromeColor, 1);
        chromeColorGraphics.drawRoundRect(visibleTrackRectLeft, trackY,
                                          trackWidth, visibleTrackRectHeight,
                                          visibleTrackEllipseWidth, visibleTrackEllipseHeight);
        chromeColorGraphics.endFill();
    }
}
}