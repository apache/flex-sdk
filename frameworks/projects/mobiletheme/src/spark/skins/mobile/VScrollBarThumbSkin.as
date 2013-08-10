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

import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.LineScaleMode;

import mx.core.DPIClassification;
import mx.core.mx_internal;
use namespace mx_internal;

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
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    // These constants are also accessed from VScrollBarSkin
	mx_internal static const PADDING_RIGHT_640DPI:int = 10;
	mx_internal static const PADDING_VERTICAL_640DPI:int = 8;
	mx_internal static const PADDING_RIGHT_480DPI:int = 8;
	mx_internal static const PADDING_VERTICAL_480DPI:int = 6;
    mx_internal static const PADDING_RIGHT_320DPI:int = 5;
    mx_internal static const PADDING_VERTICAL_320DPI:int = 4;
	mx_internal static const PADDING_RIGHT_240DPI:int = 4;
	mx_internal static const PADDING_VERTICAL_240DPI:int = 3;
	mx_internal static const PADDING_RIGHT_120DPI:int = 2;
	mx_internal static const PADDING_VERTICAL_120DPI:int = 1;
    mx_internal static const PADDING_RIGHT_DEFAULTDPI:int = 3;
    mx_internal static const PADDING_VERTICAL_DEFAULTDPI:int = 2;
    
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
        
        // Depending on density set padding
        switch (applicationDPI)
        {
			case DPIClassification.DPI_480:
			{
				minWidth = 19;
				paddingRight = VScrollBarThumbSkin.PADDING_RIGHT_480DPI;
				paddingVertical = VScrollBarThumbSkin.PADDING_VERTICAL_480DPI;
				break;
			}
            case DPIClassification.DPI_320:
            {
                paddingRight = PADDING_RIGHT_320DPI;
                paddingVertical = PADDING_VERTICAL_320DPI;
                break;
            }
            case DPIClassification.DPI_240:
            {
                paddingRight = PADDING_RIGHT_240DPI;
                paddingVertical = PADDING_VERTICAL_240DPI;
                break;
            }
            default:
            {
                paddingRight = PADDING_RIGHT_DEFAULTDPI;
                paddingVertical = PADDING_VERTICAL_DEFAULTDPI;
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
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.drawBackground(unscaledWidth, unscaledHeight);

        var thumbWidth:Number = unscaledWidth - paddingRight;
        
        graphics.beginFill(getStyle("chromeColor"), 1);
        graphics.lineStyle(1, 0x000000, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND);
        graphics.drawRoundRect(0.5, paddingVertical + 0.5, 
            thumbWidth, unscaledHeight - 2 * paddingVertical, 
            thumbWidth, thumbWidth);
        
        graphics.endFill();
    }
    
}
}