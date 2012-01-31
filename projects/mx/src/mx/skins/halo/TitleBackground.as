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
import flash.display.Graphics;
import mx.skins.ProgrammaticSkin;
import mx.styles.StyleManager;
import mx.utils.ColorUtil;

/**
 *  The skin for a title bar area of a Panel.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class TitleBackground extends ProgrammaticSkin
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
	public function TitleBackground()
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

		var borderAlpha:Number = getStyle("borderAlpha");
		var cornerRadius:Number = getStyle("cornerRadius");
		var highlightAlphas:Array = getStyle("highlightAlphas");
		var headerColors:Array = getStyle("headerColors");
		var showChrome:Boolean = headerColors != null;
        styleManager.getColorNames(headerColors);
		
		var colorDark:Number = ColorUtil.adjustBrightness2(
			headerColors ? headerColors[1] : 0xFFFFFF, -20);
				
		var g:Graphics = graphics;
		
		g.clear();
		
		if (h < 3)
			return;
		
		// Only draw the background if headerColors are defined.
		if (showChrome) 
		{
			g.lineStyle(0, colorDark, borderAlpha);
			g.moveTo(0, h);
			g.lineTo(w, h);
			g.lineStyle(0, 0, 0); 

			// surface
			drawRoundRect(
				0, 0, w, h,
				{ tl: cornerRadius, tr: cornerRadius, bl: 0, br: 0 },
				headerColors, borderAlpha,
				verticalGradientMatrix(0, 0, w, h));

			// highlight
			drawRoundRect(
				0, 0, w, h / 2,
				{ tl: cornerRadius, tr: cornerRadius, bl: 0, br: 0 },
				[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
				verticalGradientMatrix(0, 0, w, h / 2));

				// edge
			drawRoundRect(
				0, 0, w, h,
				{ tl: cornerRadius, tr: cornerRadius, bl: 0, br: 0 },
				0xFFFFFF, highlightAlphas[0], null,
				GradientType.LINEAR, null, 
				{ x: 0, y: 1, w: w, h: h - 1,
				  r: { tl: cornerRadius, tr: cornerRadius, bl: 0, br: 0 } });

		}
		
		
	}	
}

}
