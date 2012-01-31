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

package mx.skins.halo
{

import mx.skins.Border;

/**
 *  The skin for the border of a SwatchPanel. 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class SwatchPanelSkin extends Border
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
	 *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */    
    public function SwatchPanelSkin()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */    
	override protected function updateDisplayList(w:Number, h:Number):void
    {
		super.updateDisplayList(w, h);

        if (name == "swatchPanelBorder")
        {
            var backgroundColor:uint = getStyle("backgroundColor");
				// used for darker color in the gradient

            var borderColor:uint = getStyle("borderColor");
				// used for outer border top

            var highlightColor:uint = getStyle("highlightColor");
				// used for white edge
				// and also for lighter color in the gradient

            var shadowColor:uint = getStyle("shadowColor");
				// used for outer border bottom

            var x:Number = 0;
            var y:Number = 0;
            
			graphics.clear();

			// outer border top
            drawRoundRect(
				x, y, w, h, 0,
				borderColor, 1);

 			// outer border bottom
            drawRoundRect(
				x + 1, y + 1, w - 1, h - 1, 0,
				shadowColor, 1);

			// white edge
            drawRoundRect(
				x + 1, y + 1, w - 2, h - 2, 0,
				highlightColor, 1);

			// gradient fill
            drawRoundRect(
				x + 2, y + 2, w - 4, h - 4, 0,
				[ backgroundColor, highlightColor ], 1,
				verticalGradientMatrix(x + 2, y + 2, w - 4, h - 4));
        }
    }
}

}
