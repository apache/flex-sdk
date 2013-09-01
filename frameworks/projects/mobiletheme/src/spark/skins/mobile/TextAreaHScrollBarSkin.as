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
     *  The default skin class for the Spark TextAreaHScrollBar component in mobile
    *  applications.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
public class TextAreaHScrollBarSkin extends HScrollBarSkin
{
    /**
     *  Constructor.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    public function TextAreaHScrollBarSkin()
    {
        super();

        thumbSkinClass = TextAreaHScrollBarThumbSkin;
        var paddingBottom:int;
        var paddingHorizontal:int;

        switch (applicationDPI)
        {
			case DPIClassification.DPI_640:
			{
				minHeight = 30;
				paddingBottom = TextAreaHScrollBarThumbSkin.PADDING_BOTTOM_320DPI;
				paddingHorizontal = TextAreaHScrollBarThumbSkin.PADDING_HORIZONTAL_320DPI;
				break;
			}
			case DPIClassification.DPI_480:
			{
				minHeight = 22;
				paddingBottom = TextAreaHScrollBarThumbSkin.PADDING_BOTTOM_480DPI;
				paddingHorizontal = TextAreaHScrollBarThumbSkin.PADDING_HORIZONTAL_480DPI;
				break;
			}
            case DPIClassification.DPI_320:
            {
                minHeight = 15;
                paddingBottom = TextAreaHScrollBarThumbSkin.PADDING_BOTTOM_320DPI;
                paddingHorizontal = TextAreaHScrollBarThumbSkin.PADDING_HORIZONTAL_320DPI;
                break;
            }
			case DPIClassification.DPI_240:
			{
				minHeight = 11;
				paddingBottom = TextAreaHScrollBarThumbSkin.PADDING_BOTTOM_240DPI;
				paddingHorizontal = TextAreaHScrollBarThumbSkin.PADDING_HORIZONTAL_240DPI;
				break;
			}
			case DPIClassification.DPI_120:
			{
				minHeight = 11;
				paddingBottom = TextAreaHScrollBarThumbSkin.PADDING_BOTTOM_120DPI;
				paddingHorizontal = TextAreaHScrollBarThumbSkin.PADDING_HORIZONTAL_120DPI;
				break;
			}
            default:
            {
                // default DPI_160
                minHeight = 9;
                paddingBottom = TextAreaHScrollBarThumbSkin.PADDING_BOTTOM_DEFAULTDPI;
                paddingHorizontal = TextAreaHScrollBarThumbSkin.PADDING_HORIZONTAL_DEFAULTDPI;
                break;
            }
        }
        
        // The minimum width is set such that, at it's smallest size, the thumb appears
        // as wide as it is high.
        minThumbWidth = (minHeight - paddingBottom) + (paddingHorizontal * 2);   
    }
}
}