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
package skins
{
	import spark.skins.mobile.ToggleSwitchSkin;
	
	public class StyledToggleSwitchSkin extends ToggleSwitchSkin
	{
		public function StyledToggleSwitchSkin()
		{
			super();
			
			
			selectedLabel = "YES";
			unselectedLabel = "NO!!!!!!";
			
			layoutThumbWidth = 120;
			layoutThumbHeight = 80;
			layoutStrokeWeight = 10;
			layoutBorderSize = 20;
			layoutTextShadowOffset = -10
			layoutCornerEllipseSize = 30;	
			layoutInnerPadding = 20;
			layoutOuterPadding = 30;
			
			setStyle('accentColor', 0x009900);
			setStyle('chromeColor', 0x00ffff);
			setStyle('color', 0xffcc00);
			setStyle('textShadowColor', 0xff3300);
			setStyle('textShadowAlpha', 0.5);
			
			
		}
		
		
		
		
	}
}