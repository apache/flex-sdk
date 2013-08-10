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

import mx.core.DPIClassification;
import mx.core.mx_internal;

import spark.components.Button;
import spark.components.HScrollBar;
import spark.skins.mobile.supportClasses.MobileSkin;

use namespace mx_internal;

/**
 *  ActionScript-based skin for HScrollBar components in mobile applications. 
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class HScrollBarSkin extends MobileSkin 
{   
    //--------------------------------------------------------------------------
    //
    //  Variables
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
    public function HScrollBarSkin()
    {
        super();
        
        minWidth = 20;
        thumbSkinClass = HScrollBarThumbSkin;
        var paddingBottom:int;
        var paddingHorizontal:int;
        
        // Depending on density set our measured height
        switch (applicationDPI)
        {
			case DPIClassification.DPI_640:
			{
				minHeight = 24;   
				paddingBottom = HScrollBarThumbSkin.PADDING_BOTTOM_640DPI;
				paddingHorizontal = HScrollBarThumbSkin.PADDING_HORIZONTAL_640DPI;
				break;
			}
			case DPIClassification.DPI_480:
			{
				minHeight = 18;   
				paddingBottom = HScrollBarThumbSkin.PADDING_BOTTOM_480DPI;
				paddingHorizontal = HScrollBarThumbSkin.PADDING_HORIZONTAL_480DPI;
				break;
			}
            case DPIClassification.DPI_320:
            {
                minHeight = 12;   
                paddingBottom = HScrollBarThumbSkin.PADDING_BOTTOM_320DPI;
                paddingHorizontal = HScrollBarThumbSkin.PADDING_HORIZONTAL_320DPI;
                break;
            }
			case DPIClassification.DPI_240:
			{
				minHeight = 9;   
				paddingBottom = HScrollBarThumbSkin.PADDING_BOTTOM_240DPI;
				paddingHorizontal = HScrollBarThumbSkin.PADDING_HORIZONTAL_240DPI;
				break;
			}
			case DPIClassification.DPI_120:
			{
				minHeight = 5;   
				paddingBottom = HScrollBarThumbSkin.PADDING_BOTTOM_120DPI;
				paddingHorizontal = HScrollBarThumbSkin.PADDING_HORIZONTAL_120DPI;
				break;
			}
            default:
            {
                // default DPI_160
                minHeight = 6;              
                paddingBottom = HScrollBarThumbSkin.PADDING_BOTTOM_DEFAULTDPI;
                paddingHorizontal = HScrollBarThumbSkin.PADDING_HORIZONTAL_DEFAULTDPI;
                break;
            }
        }
        
        // The minimum width is set such that, at it's smallest size, the thumb appears
        // as wide as it is high.
        minThumbWidth = (minHeight - paddingBottom) + (paddingHorizontal * 2);   
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    /** 
     *  @copy spark.skins.spark.ApplicationSkin#hostComponent
     */
    public var hostComponent:HScrollBar;
    
    /**
     *  Minimum width for the thumb 
     */
    protected var minThumbWidth:Number;
    
    /**
     *  Skin to use for the thumb Button skin part
     */
    protected var thumbSkinClass:Class;
    
    //--------------------------------------------------------------------------
    //
    //  Skin parts 
    //
    //--------------------------------------------------------------------------
    /**
     *  HScrollbar track skin part.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */  
    public var track:Button;
    
    /**
     *  HScrollbar thumb skin part.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */  
    public var thumb:Button;
    
    
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
        // Create our skin parts if necessary: track and thumb.
        if (!track)
        {
            // We don't want a visible track so we set the skin to MobileSkin
            track = new Button();
            track.setStyle("skinClass", spark.skins.mobile.supportClasses.MobileSkin);
            track.width = minWidth;
            track.height = minHeight;
            addChild(track);
        }
        
        if (!thumb)
        {
            thumb = new Button();
            thumb.minWidth = minThumbWidth;
            thumb.setStyle("skinClass", thumbSkinClass);
            thumb.width = minHeight;
            thumb.height = minHeight;
            addChild(thumb);
        }
    }
    
    /**
     *  @private 
     */
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.layoutContents(unscaledWidth, unscaledHeight);
        
        setElementSize(track, unscaledWidth, unscaledHeight);
    }
}
}