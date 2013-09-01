////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package spark.skins.mobile
{
import flash.display.DisplayObject;

import mx.core.DPIClassification;

import spark.components.Button;
import spark.skins.mobile.supportClasses.MobileSkin;
import spark.skins.mobile120.assets.HSliderTrack;
import spark.skins.mobile160.assets.HSliderTrack;
import spark.skins.mobile240.assets.HSliderTrack;
import spark.skins.mobile320.assets.HSliderTrack;
import spark.skins.mobile480.assets.HSliderTrack;
import spark.skins.mobile640.assets.HSliderTrack;

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
			case DPIClassification.DPI_640:
			{
				// Note provisional may need changes
				trackWidth = 1200;
				trackHeight = 36;
				
				visibleTrackOffset = 40;
				
				trackClass = spark.skins.mobile640.assets.HSliderTrack;
				
				break;
			}
			case DPIClassification.DPI_480:
			{
				// Note provisional may need changes
				trackWidth = 880;
				trackHeight = 26;
				
				visibleTrackOffset = 32;
				
				trackClass = spark.skins.mobile480.assets.HSliderTrack;
				
				break;
			}
            case DPIClassification.DPI_320:
            {
                trackWidth = 600;
                trackHeight = 18;
                
                visibleTrackOffset = 20;
                
                trackClass = spark.skins.mobile320.assets.HSliderTrack;
                
                break;
            }
			case DPIClassification.DPI_240:
			{
				trackWidth = 440;
				trackHeight = 13;
				
				visibleTrackOffset = 16;
				
				trackClass = spark.skins.mobile240.assets.HSliderTrack;
				
				break;
			}
			case DPIClassification.DPI_120:
			{
				trackWidth = 220;
				trackHeight = 7;
				
				visibleTrackOffset = 8;
				
				trackClass = spark.skins.mobile120.assets.HSliderTrack;
				
				break;
			}
            default:
            {
                // default DPI_160
                trackWidth = 300;
                trackHeight = 10;
                
                visibleTrackOffset = 10;
                
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
     *  Specifies the offset from the left and right edge to where
     *  the visible track begins. This should match the offset in the FXG assets.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var visibleTrackOffset:int;
        
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

        var unscaledTrackWidth:int = unscaledWidth - (2 * visibleTrackOffset);
        
        // draw the round rect
        graphics.beginFill(getStyle("chromeColor"), 1);
        graphics.drawRoundRect(visibleTrackOffset, 0,
            unscaledTrackWidth, trackHeight,
            trackHeight, trackHeight);
        graphics.endFill();
    }
}
}