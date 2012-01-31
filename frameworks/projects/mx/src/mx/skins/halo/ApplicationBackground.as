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

import flash.display.Graphics;

import mx.core.FlexVersion;
import mx.skins.ProgrammaticSkin;
import mx.utils.ColorUtil;

/**
 *  The skin for application background gradient.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class ApplicationBackground extends ProgrammaticSkin
{
    include "../../core/Version.as";    
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor	 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function ApplicationBackground()
    {
        super();             
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
	//  measuredWidth
    //----------------------------------
    
    /**
     *  @private
     */    
    override public function get measuredWidth():Number
    {
        return 8;
    }
    
    //----------------------------------
	//  measuredHeight
    //----------------------------------
    
    /**
     *  @private
     */        
    override public function get measuredHeight():Number
    {
        return 8;
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

        var g:Graphics = graphics;
        var fillColors:Array = getStyle("backgroundGradientColors");
        var fillAlphas:Array = getStyle("backgroundGradientAlphas");

		if (!fillColors)
		{
			var bgColor:uint = getStyle("backgroundColor");
			
			if (isNaN(bgColor))
				bgColor = 0xFFFFFF;
			
			fillColors = [];

            fillColors[0] = ColorUtil.adjustBrightness(bgColor, 15);
            fillColors[1] = ColorUtil.adjustBrightness(bgColor, -25);
		}
		
		if (!fillAlphas)
			fillAlphas = [1, 1];
		
        g.clear();
        drawRoundRect(0, 0, w, h, 0, fillColors, fillAlphas, 
        			  verticalGradientMatrix(0, 0, w, h));
    }
}

}
