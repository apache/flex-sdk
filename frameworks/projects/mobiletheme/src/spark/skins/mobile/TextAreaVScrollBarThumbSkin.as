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
public class TextAreaVScrollBarThumbSkin extends VScrollBarThumbSkin
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    // These constants are also accessed from TextAreaVScrollBarSkin
	mx_internal static const PADDING_RIGHT_640DPI:int = 16;
	mx_internal static const PADDING_VERTICAL_640DPI:int = 24;
	mx_internal static const PADDING_RIGHT_480DPI:int = 12;
	mx_internal static const PADDING_VERTICAL_480DPI:int = 18;
	mx_internal static const PADDING_RIGHT_320DPI:int = 8;
    mx_internal static const PADDING_VERTICAL_320DPI:int = 12;
	mx_internal static const PADDING_RIGHT_240DPI:int = 4;
	mx_internal static const PADDING_VERTICAL_240DPI:int = 6;
	mx_internal static const PADDING_RIGHT_120DPI:int = 2;
	mx_internal static const PADDING_VERTICAL_120DPI:int = 3;
    mx_internal static const PADDING_RIGHT_DEFAULTDPI:int = 4;
    mx_internal static const PADDING_VERTICAL_DEFAULTDPI:int = 6;
    
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
    public function TextAreaVScrollBarThumbSkin()
    {
        super();
        
        // Depending on density set padding
        switch (applicationDPI)
        {
			case DPIClassification.DPI_640:
			{
				paddingRight = PADDING_RIGHT_640DPI;
				paddingVertical = PADDING_VERTICAL_640DPI;
				break;
			}
			case DPIClassification.DPI_480:
			{
				paddingRight = PADDING_RIGHT_480DPI;
				paddingVertical = PADDING_VERTICAL_480DPI;
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
			case DPIClassification.DPI_120:
			{
				paddingRight = PADDING_RIGHT_120DPI;
				paddingVertical = PADDING_VERTICAL_120DPI;
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
}
}