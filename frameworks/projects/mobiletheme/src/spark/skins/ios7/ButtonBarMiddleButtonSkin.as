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

package spark.skins.ios7
{
	
	import spark.skins.ios7.assets.ButtonBarMiddleButton_up;
	
	/**
	 *  Android 4.x specific Button skin for middle Buttons in a ButtonBar.
	 * 
	 *  @see spark.components.ButtonBar#middleButton
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.5 
	 *  @productversion Flex 4.5
	 */
	public class ButtonBarMiddleButtonSkin extends IOS7ButtonBarButtonSkinBase
	{
		
		/**
		 *  Constructor.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5 
		 *  @productversion Flex 4.5
		 */
		public function ButtonBarMiddleButtonSkin()
		{
			super();
			
			upBorderSkin = spark.skins.ios7.assets.ButtonBarMiddleButton_up
			downBorderSkin = spark.skins.ios7.assets.ButtonBarMiddleButton_down;
			selectedBorderSkin = spark.skins.ios7.assets.ButtonBarMiddleButton_down;
			selectedDownBorderSkin = spark.skins.ios7.assets.ButtonBarMiddleButton_up;
		}
		
	}
}