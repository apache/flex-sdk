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

use namespace mx_internal;

/**
 *  The ActionScript-based skin used for TextAreaHScrollBarThumb components
 *  in mobile applications.
 * 
 *  @langversion 3.0
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 * 
 */
public class TextAreaHScrollBarThumbSkin extends HScrollBarThumbSkin
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    // These constants are also accessed from HScrollBarSkin
	mx_internal static const PADDING_BOTTOM_640DPI:int = 16;
	mx_internal static const PADDING_HORIZONTAL_640DPI:int = 16;
	mx_internal static const PADDING_BOTTOM_480DPI:int = 12;
	mx_internal static const PADDING_HORIZONTAL_480DPI:int = 12;
    mx_internal static const PADDING_BOTTOM_320DPI:int = 8;
    mx_internal static const PADDING_HORIZONTAL_320DPI:int = 12;
	mx_internal static const PADDING_BOTTOM_240DPI:int = 6;
	mx_internal static const PADDING_HORIZONTAL_240DPI:int = 6;
	mx_internal static const PADDING_BOTTOM_120DPI:int = 3;
	mx_internal static const PADDING_HORIZONTAL_120DPI:int = 3;
    mx_internal static const PADDING_BOTTOM_DEFAULTDPI:int = 4;
    mx_internal static const PADDING_HORIZONTAL_DEFAULTDPI:int = 6;
    
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
    public function TextAreaHScrollBarThumbSkin()
    {
        super();
        
        // Depending on density set padding
        switch (applicationDPI)
        {
			case DPIClassification.DPI_640:
			{
				paddingBottom = PADDING_BOTTOM_640DPI;
				paddingHorizontal = PADDING_HORIZONTAL_640DPI;
				break;
			}
			case DPIClassification.DPI_480:
			{
				paddingBottom = TextAreaHScrollBarThumbSkin.PADDING_BOTTOM_480DPI;
				paddingHorizontal = TextAreaHScrollBarThumbSkin.PADDING_HORIZONTAL_480DPI;
				break;
			}
            case DPIClassification.DPI_320:
            {
                paddingBottom = PADDING_BOTTOM_320DPI;
                paddingHorizontal = PADDING_HORIZONTAL_320DPI;
                break;
            }
			case DPIClassification.DPI_240:
			{
				paddingBottom = PADDING_BOTTOM_240DPI;
				paddingHorizontal = PADDING_HORIZONTAL_240DPI;
				break;
			}
			case DPIClassification.DPI_120:
			{
				paddingBottom = PADDING_BOTTOM_120DPI;
				paddingHorizontal = PADDING_HORIZONTAL_120DPI;
				break;
			}
            default:
            {
                paddingBottom = PADDING_BOTTOM_DEFAULTDPI;
                paddingHorizontal = PADDING_HORIZONTAL_DEFAULTDPI;
                break;
            }
        }
    }
}
}