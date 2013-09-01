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

/**
 *  Additional skin class for the Spark ActionBar component for use with a
 *  ViewNavigator inside a Callout component.
 * 
 *  Uses a transparent background instead of a gradient fill.
 *  
 *  @see spark.skins.mobile.ActionBarSkin
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */
public class CalloutActionBarSkin extends ActionBarSkin
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    public function CalloutActionBarSkin()
    {
        super();
        
        // remove default background
        borderClass = null;
        
        // shorten ActionBar height visual paddingTop comes from CalloutSkin
        switch (applicationDPI)
        {
			case DPIClassification.DPI_640:
			{
				layoutContentGroupHeight = 108;
				break;
			}
			case DPIClassification.DPI_480:
			{
				layoutContentGroupHeight = 84;
				break;
			}
            case DPIClassification.DPI_320:
            {
                layoutContentGroupHeight = 54;
                break;
            }
			case DPIClassification.DPI_240:
			{
				layoutContentGroupHeight = 42;
				break;
			}
			case DPIClassification.DPI_120:
			{
				layoutContentGroupHeight = 21;
				break;
			}
            default:
            {
                // default DPI_160
                layoutContentGroupHeight = 28;
                break;
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // do not draw chromeColor
    }
}
}