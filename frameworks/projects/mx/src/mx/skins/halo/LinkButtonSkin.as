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

import mx.core.EdgeMetrics;
import mx.skins.Border;

/**
 *  The skin for all the states of a LinkButton.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class LinkButtonSkin extends Border
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
	public function LinkButtonSkin()
	{
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  borderMetrics
	//----------------------------------

	/**
	 *  @private
	 */
	override public function get borderMetrics():EdgeMetrics
	{		
		return EdgeMetrics.EMPTY;
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

		var cornerRadius:Number = getStyle("cornerRadius");
		var rollOverColor:uint = getStyle("rollOverColor");
		var selectionColor:uint = getStyle("selectionColor");

		graphics.clear();
														
		switch (name)
		{			
			case "upSkin":
			{
				// Draw invisible shape so we have a hit area.
				drawRoundRect(
					0, 0, w, h, cornerRadius,
					0, 0);
				break;
			}
			
			case "overSkin":
			{
				drawRoundRect(
					0, 0, w, h, cornerRadius,
					rollOverColor, 1);
				break;
			}
			
			case "downSkin":
			{
				drawRoundRect(
					0, 0, w, h, cornerRadius,
					selectionColor, 1);
				break;
			}

			case "disabledSkin":
			{
				// Draw invisible shape so we have a hit area.
				drawRoundRect(
					0, 0, w, h, cornerRadius,
					0, 0);
				break;
			}
		}
	}
}

}
