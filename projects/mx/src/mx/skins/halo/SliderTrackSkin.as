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

import flash.display.GradientType;
import mx.skins.Border;
import mx.styles.StyleManager;
import mx.utils.ColorUtil;

/**
 *  The skin for the track in a Slider.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class SliderTrackSkin extends Border 
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
	public function SliderTrackSkin()
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
		return 200;
	}

	//----------------------------------
	//  measuredHeight
	//----------------------------------

	/**
	 *  @private
	 */
	override public function get measuredHeight():Number
	{
		return 4;
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

		// User-defined styles.
		var borderColor:Number = getStyle("borderColor");
		var fillAlphas:Array = getStyle("fillAlphas");
		var fillColors:Array = getStyle("trackColors") as Array;
        styleManager.getColorNames(fillColors);
		
		// Derivative styles.
		var borderColorDrk:Number =
			ColorUtil.adjustBrightness2(borderColor, -50);
		
		graphics.clear();
		
		drawRoundRect(0,0,w,h,0,0,0); // Draw a transparent rect to fill the entire space
		
		drawRoundRect(
			1, 0, w, h - 1, 1.5,
			borderColorDrk, 1, null,
			GradientType.LINEAR, null,
			{ x: 2, y: 1, w: w - 2, h: 1, r: 0 });

		drawRoundRect(
			2, 1, w - 2, h - 2, 1,
			borderColor, 1, null,
			GradientType.LINEAR, null,
			{ x: 2, y: 1, w: w - 2, h: 1, r: 0 });
		
		drawRoundRect(
			2, 1, w - 2, 1, 0,
			fillColors, Math.max(fillAlphas[1] - 0.3, 0),
			horizontalGradientMatrix(2, 1, w - 2, 1));
	}
}

}
