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

package
{

/**
 *  @private
 *  In some projects, this class is used to link additional classes
 *  into the SWC beyond those that are found by dependency analysis
 *  starting from the classes specified in manifest.xml.
 *  This project has no manifest file (because there are no MXML tags
 *  corresponding to any classes in it) so all the classes linked into
 *  the SWC are found by a dependency analysis starting from the classes
 *  listed here.
 */
internal class ArcadeClasses
{

	import arcade.skins.ApplicationSkin; ApplicationSkin;
	import arcade.skins.BorderSkin; BorderSkin;
	import arcade.skins.ButtonBarFirstButtonSkin; ButtonBarFirstButtonSkin;
	import arcade.skins.ButtonBarLastButtonSkin; ButtonBarLastButtonSkin;
	import arcade.skins.ButtonBarMiddleButtonSkin; ButtonBarMiddleButtonSkin;
	import arcade.skins.ButtonBarSkin; ButtonBarSkin;
	import arcade.skins.ButtonSkin; ButtonSkin;
	import arcade.skins.CheckBoxSkin; CheckBoxSkin;
	import arcade.skins.ComboBoxButtonSkin; ComboBoxButtonSkin;
	import arcade.skins.ComboBoxSkin; ComboBoxSkin;
	import arcade.skins.ComboBoxTextInputSkin; ComboBoxTextInputSkin;
	import arcade.skins.DefaultButtonSkin; DefaultButtonSkin;
	import arcade.skins.DefaultComplexItemRenderer; DefaultComplexItemRenderer;
	import arcade.skins.DefaultItemRenderer; DefaultItemRenderer;
	import arcade.skins.DropDownListButtonSkin; DropDownListButtonSkin;
	import arcade.skins.DropDownListSkin; DropDownListSkin;
	import arcade.skins.ErrorSkin; ErrorSkin;
	import arcade.skins.FocusSkin; FocusSkin;
	import arcade.skins.HScrollBarSkin; HScrollBarSkin;
	import arcade.skins.HScrollBarThumbSkin; HScrollBarThumbSkin;
	import arcade.skins.HScrollBarTrackSkin; HScrollBarTrackSkin;
	import arcade.skins.HSliderSkin; HSliderSkin;
	import arcade.skins.HSliderThumbSkin; HSliderThumbSkin;
	import arcade.skins.HSliderTrackSkin; HSliderTrackSkin;
	import arcade.skins.ListSkin; ListSkin;
	import arcade.skins.NumericStepperSkin; NumericStepperSkin;
	import arcade.skins.NumericStepperTextInputSkin; NumericStepperTextInputSkin;
	import arcade.skins.PanelSkin; PanelSkin;
	import arcade.skins.RadioButtonSkin; RadioButtonSkin;
	import arcade.skins.ScrollBarDownButtonSkin; ScrollBarDownButtonSkin;
	import arcade.skins.ScrollBarLeftButtonSkin; ScrollBarLeftButtonSkin;
	import arcade.skins.ScrollBarRightButtonSkin; ScrollBarRightButtonSkin;
	import arcade.skins.ScrollBarUpButtonSkin; ScrollBarUpButtonSkin;
	import arcade.skins.ScrollerSkin; ScrollerSkin;
	import arcade.skins.SkinnableContainerSkin; SkinnableContainerSkin;
	import arcade.skins.SkinnableDataContainerSkin; SkinnableDataContainerSkin;
	import arcade.skins.SpinnerDecrButtonSkin; SpinnerDecrButtonSkin;
	import arcade.skins.SpinnerIncrButtonSkin; SpinnerIncrButtonSkin;
	import arcade.skins.SpinnerSkin; SpinnerSkin;
	import arcade.skins.TabBarButtonSkin; TabBarButtonSkin;
	import arcade.skins.TabBarSkin; TabBarSkin;
	import arcade.skins.TextAreaBorderSkin; TextAreaBorderSkin;
	import arcade.skins.TextAreaSkin; TextAreaSkin;
	import arcade.skins.TextInputBorderSkin; TextInputBorderSkin;
	import arcade.skins.TextInputSkin; TextInputSkin;
	import arcade.skins.TitleWindowCloseButtonSkin; TitleWindowCloseButtonSkin;
	import arcade.skins.TitleWindowSkin; TitleWindowSkin;
	import arcade.skins.ToggleButtonSkin; ToggleButtonSkin;
	import arcade.skins.VScrollBarSkin; VScrollBarSkin;
	import arcade.skins.VScrollBarThumbSkin; VScrollBarThumbSkin;
	import arcade.skins.VScrollBarTrackSkin; VScrollBarTrackSkin;
	import arcade.skins.VSliderSkin; VSliderSkin;
	import arcade.skins.VSliderThumbSkin; VSliderThumbSkin;
	import arcade.skins.VSliderTrackSkin; VSliderTrackSkin;
	//don't have graphics for VideoPlayerSkin
	//import arcade.skins.VideoPlayerSkin; VideoPlayerSkin;

}

}