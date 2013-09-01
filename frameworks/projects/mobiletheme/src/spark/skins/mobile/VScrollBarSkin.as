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
import spark.components.VScrollBar;
import spark.skins.mobile.supportClasses.MobileSkin;

use namespace mx_internal;

/**
 *  ActionScript-based skin for VScrollBar components in mobile applications. 
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class VScrollBarSkin extends MobileSkin
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
    public function VScrollBarSkin()
    {
        super();
        
        minHeight = 20;
        thumbSkinClass = VScrollBarThumbSkin;
        var paddingRight:int;
        var paddingVertical:int;
        
        // Depending on density set our measured width
        switch (applicationDPI)
        {
			case DPIClassification.DPI_640:
			{
				minWidth = 24;
				paddingRight = VScrollBarThumbSkin.PADDING_RIGHT_640DPI;
				paddingVertical = VScrollBarThumbSkin.PADDING_VERTICAL_640DPI;
				break;
			}
			case DPIClassification.DPI_480:
			{
				minWidth = 18;
				paddingRight = VScrollBarThumbSkin.PADDING_RIGHT_480DPI;
				paddingVertical = VScrollBarThumbSkin.PADDING_VERTICAL_480DPI;
				break;
			}
            case DPIClassification.DPI_320:
            {
                minWidth = 12;
                paddingRight = VScrollBarThumbSkin.PADDING_RIGHT_320DPI;
                paddingVertical = VScrollBarThumbSkin.PADDING_VERTICAL_320DPI;
                break;
            }
			case DPIClassification.DPI_240:
			{
				minWidth = 9;
				paddingRight = VScrollBarThumbSkin.PADDING_RIGHT_240DPI;
				paddingVertical = VScrollBarThumbSkin.PADDING_VERTICAL_240DPI;
				break;
			}
			case DPIClassification.DPI_120:
			{
				minWidth = 9;
				paddingRight = VScrollBarThumbSkin.PADDING_RIGHT_120DPI;
				paddingVertical = VScrollBarThumbSkin.PADDING_VERTICAL_120DPI;
				break;
			}
            default:
            {
                // default DPI_160
                minWidth = 6;
                paddingRight = VScrollBarThumbSkin.PADDING_RIGHT_DEFAULTDPI;
                paddingVertical = VScrollBarThumbSkin.PADDING_VERTICAL_DEFAULTDPI;
                break;
            }
        }
        
        // The minimum height is set such that, at it's smallest size, the thumb appears
        // as high as it is wide.
        minThumbHeight = (minWidth - paddingRight) + (paddingVertical * 2);   
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /** 
     *  @copy spark.skins.spark.ApplicationSkin#hostComponent
     */
    public var hostComponent:VScrollBar;
    
    /**
     *  Minimum height for the thumb
     */
    protected var minThumbHeight:Number;
    
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
     *  VScrollbar track skin part
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */   
    public var track:Button;
    
    /**
     *  VScrollbar thumb skin part
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
            thumb.minHeight = minThumbHeight; 
            thumb.setStyle("skinClass", thumbSkinClass);
            thumb.width = minWidth;
            thumb.height = minWidth;
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