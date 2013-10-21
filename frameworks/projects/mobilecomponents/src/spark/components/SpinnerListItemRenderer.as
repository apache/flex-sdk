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
package spark.components
{

import mx.core.DPIClassification;
import mx.core.mx_internal;
    
use namespace mx_internal;

/**
 *  The SpinnerListItemRenderer class defines the default item renderer
 *  for a SpinnerList control in the mobile theme.  
 *  This is a simple item renderer with a single text component.
 * 
 * @see spark.components.SpinnerList
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */ 
public class SpinnerListItemRenderer extends LabelItemRenderer
{
    /**
     *  Constructor.
     *        
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */ 
    public function SpinnerListItemRenderer()
    {
        super();
        
        switch (applicationDPI)
        {
			case DPIClassification.DPI_640:
			{
				minHeight = 40;
				break;
			}
			case DPIClassification.DPI_480:
			{
				minHeight = 30;
				break;
			}
            case DPIClassification.DPI_320:
            {
                minHeight = 20;
                break;
            }
			case DPIClassification.DPI_240:
			{
				minHeight = 15;
				break;
			}
			case DPIClassification.DPI_120:
			{
				minHeight = 8;
				break;
			}
            default: // default PPI160
            {
                minHeight = 10;
                break;
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // draw a transparent background for hit testing
        graphics.beginFill(0x000000, 0);
        graphics.lineStyle();
        graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
        graphics.endFill();
    }
}
}