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
 *  ActionScript-based skin for TextAreaVScrollBar components in mobile applications.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class TextAreaVScrollBarSkin extends VScrollBarSkin
{
    /**
     *  Constructor. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     * 
     */ 
    public function TextAreaVScrollBarSkin()
    {
        super();

        thumbSkinClass = TextAreaVScrollBarThumbSkin;
        var paddingRight:int;
        var paddingVertical:int;

        switch (applicationDPI)
        {
			case DPIClassification.DPI_640:
			{
				minWidth = 30;
				paddingRight = TextAreaVScrollBarThumbSkin.PADDING_RIGHT_640DPI;
				paddingVertical = TextAreaVScrollBarThumbSkin.PADDING_VERTICAL_640DPI;
				break;
			}
			case DPIClassification.DPI_480:
			{
				minWidth = 22;
				paddingRight = TextAreaVScrollBarThumbSkin.PADDING_RIGHT_480DPI;
				paddingVertical = TextAreaVScrollBarThumbSkin.PADDING_VERTICAL_480DPI;
				break;
			}
            case DPIClassification.DPI_320:
            {
                minWidth = 15;
                paddingRight = TextAreaVScrollBarThumbSkin.PADDING_RIGHT_320DPI;
                paddingVertical = TextAreaVScrollBarThumbSkin.PADDING_VERTICAL_320DPI;
                break;
            }
			case DPIClassification.DPI_240:
			{
				minWidth = 11;
				paddingRight = TextAreaVScrollBarThumbSkin.PADDING_RIGHT_240DPI;
				paddingVertical = TextAreaVScrollBarThumbSkin.PADDING_VERTICAL_240DPI;
				break;
			}
			case DPIClassification.DPI_120:
			{
				minWidth = 6;
				paddingRight = TextAreaVScrollBarThumbSkin.PADDING_RIGHT_120DPI;
				paddingVertical = TextAreaVScrollBarThumbSkin.PADDING_VERTICAL_120DPI;
				break;
			}
            default:
            {
                // default DPI_160
                minWidth = 9;
                paddingRight = TextAreaVScrollBarThumbSkin.PADDING_RIGHT_DEFAULTDPI;
                paddingVertical = TextAreaVScrollBarThumbSkin.PADDING_VERTICAL_DEFAULTDPI;
                break;
            }
        }
        
        // The minimum height is set such that, at it's smallest size, the thumb appears
        // as high as it is wide.
        minThumbHeight = (minWidth - paddingRight) + (paddingVertical * 2);  
    }
}
}