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

package mx.skins.spark
{

import flash.display.Graphics;
import mx.skins.Border;
import mx.styles.StyleManager;
import mx.utils.ColorUtil;

/**
 *  The Spark skin for the indeterminate state of the MX ProgressBar component.
 *  
 *  @see mx.controls.ProgressBar
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ProgressIndeterminateSkin extends Border
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
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function ProgressIndeterminateSkin()
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
        return 195;
    }
    
    //----------------------------------
	//  measuredHeight
    //----------------------------------
    
    /**
     *  @private
     */        
    override public function get measuredHeight():Number
    {
        return 6;
    }
		
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
	private static var colors:Array = [0xCCCCCC, 0x808080];
	private static var alphas:Array = [0.85, 0.85];
	private static var ratios:Array = [0, 255];

    /**
     *  @private
     */        
	override protected function updateDisplayList(w:Number, h:Number):void
	{
		super.updateDisplayList(w, h);

		// User-defined styles
		var hatchInterval:Number = getStyle("indeterminateMoveInterval");
		
		if (isNaN(hatchInterval))
			hatchInterval = 28;

		var g:Graphics = graphics;
		
		g.clear();
		
		// Hatches
		for (var i:int = 0; i < w; i += hatchInterval)
		{
			g.beginGradientFill("linear", colors, alphas, ratios, 
								verticalGradientMatrix(i - 4, 2, 7, h - 4));
			g.moveTo(i, 2);
			g.lineTo(Math.min(i + 7, w), 2);
			g.lineTo(Math.min(i + 3, w), h - 2);
			g.lineTo(Math.max(i - 4, 0), h - 2);
			g.lineTo(i, 2);
			g.endFill();
			g.lineStyle(1, 0, 0.12);
			g.moveTo(i, 2);
			g.lineTo(Math.max(i - 4, 0), h - 2);
			g.moveTo(Math.min(i + 7, w), 2);
			g.lineTo(Math.min(i + 3, w), h - 2);
		}
	}
}

}
