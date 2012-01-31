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
import mx.skins.Border;
import mx.utils.ColorUtil;

/**
 *  The skin for all the states of the next-year and previous-year
 *  buttons in a DateChooser.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class DateChooserYearArrowSkin extends Border
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
	public function DateChooserYearArrowSkin()
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
		return 6;
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
	
	/**
	 *  @private
	 */
	override protected function updateDisplayList(w:Number, h:Number):void
	{
		super.updateDisplayList(w, h);

		var themeColor:uint = getStyle("themeColor");
		
		var themeColorDrk1:Number =
			ColorUtil.adjustBrightness2(themeColor, -25);

		var arrowColor:uint = getStyle("iconColor");

		var g:Graphics = graphics;
	
		g.clear();
	
		switch (name)
		{
			case "prevYearUpSkin":
			case "nextYearUpSkin":
			{
				break;
			}

			case "prevYearOverSkin":
			case "nextYearOverSkin":
			{
				arrowColor = themeColor;
				break;
			}

			case "prevYearDownSkin":
			case "nextYearDownSkin":		
			{
				arrowColor = themeColorDrk1;
				break;
			}

			case "prevYearDisabledSkin":
			case "nextYearDisabledSkin":
			{
				arrowColor = getStyle("disabledIconColor");
				break;
			}
		}
		
		// Viewable Button area				
		g.beginFill(arrowColor);
		if (name.charAt(0) == "p")
		{
			g.moveTo(w / 2, h / 2 + 2);
			g.lineTo(w / 2 - 3, h / 2 - 2);
			g.lineTo(w / 2 + 3, h / 2 - 2);
			g.lineTo(w / 2, h / 2 + 2);
		}
		else
		{								
			g.moveTo(w / 2, h / 2 - 2);
			g.lineTo(w / 2 - 3, h / 2 + 2);
			g.lineTo(w / 2 + 3, h / 2 + 2);
			g.lineTo(w / 2, h / 2 - 2);
		}
		g.endFill();				
	}
}

}
