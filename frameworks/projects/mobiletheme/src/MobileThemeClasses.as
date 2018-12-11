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
	
	internal class MobileThemeClasses
	{
		
		/**
		 *  @private
		 *  This class is used to link additional classes into mobile.swc
		 *  beyond those that are found by dependecy analysis starting
		 *  from the classes specified in manifest.xml.
		 */
		import spark.skins.mobile.ActionBarSkin; spark.skins.mobile.ActionBarSkin;
		import spark.skins.mobile.BeveledActionButtonSkin; spark.skins.mobile.BeveledActionButtonSkin;
		import spark.skins.mobile.BeveledBackButtonSkin; spark.skins.mobile.BeveledBackButtonSkin;
		import spark.skins.mobile.BusyIndicatorSkin; spark.skins.mobile.BusyIndicatorSkin;
		import spark.skins.mobile.ButtonBarSkin; spark.skins.mobile.ButtonBarSkin;
		import spark.skins.mobile.ButtonSkin; spark.skins.mobile.ButtonSkin;
		import spark.skins.mobile.CalloutSkin; spark.skins.mobile.CalloutSkin;
		import spark.skins.mobile.supportClasses.CalloutArrow;  spark.skins.mobile.supportClasses.CalloutArrow;
		import spark.skins.mobile.CalloutActionBarSkin; spark.skins.mobile.CalloutActionBarSkin;
		import spark.skins.mobile.CalloutViewNavigatorSkin; spark.skins.mobile.CalloutViewNavigatorSkin;
		import spark.skins.mobile.CheckBoxSkin; spark.skins.mobile.CheckBoxSkin;
		import spark.skins.mobile.DefaultBeveledActionButtonSkin; spark.skins.mobile.DefaultBeveledActionButtonSkin;
		import spark.skins.mobile.DefaultBeveledBackButtonSkin; spark.skins.mobile.DefaultBeveledBackButtonSkin;
		import spark.skins.mobile.DefaultButtonSkin; spark.skins.mobile.DefaultButtonSkin;
		import spark.skins.mobile.DefaultTransparentActionButtonSkin; spark.skins.mobile.DefaultTransparentActionButtonSkin;
		import spark.skins.mobile.DefaultTransparentNavigationButtonSkin; spark.skins.mobile.DefaultTransparentNavigationButtonSkin;
		import spark.skins.mobile.DateSpinnerSkin; spark.skins.mobile.DateSpinnerSkin;
		import spark.skins.mobile.HScrollBarSkin; spark.skins.mobile.HScrollBarSkin;
		import spark.skins.mobile.HSliderSkin; spark.skins.mobile.HSliderSkin;
		import spark.skins.mobile.ImageSkin; spark.skins.mobile.ImageSkin;
		import spark.skins.mobile.ListSkin; spark.skins.mobile.ListSkin;
		import spark.skins.mobile.RadioButtonSkin; spark.skins.mobile.RadioButtonSkin;
		import spark.skins.mobile.SpinnerListContainerSkin; spark.skins.mobile.SpinnerListContainerSkin;
		import spark.skins.mobile.SpinnerListScrollerSkin; spark.skins.mobile.SpinnerListScrollerSkin;
		import spark.skins.mobile.SpinnerListSkin; spark.skins.mobile.SpinnerListSkin;
		import spark.skins.mobile.SkinnableContainerSkin; spark.skins.mobile.SkinnableContainerSkin;
		import spark.skins.mobile.SplitViewNavigatorSkin; spark.skins.mobile.SplitViewNavigatorSkin;
		import spark.skins.mobile.StageTextAreaSkin; spark.skins.mobile.StageTextAreaSkin;
		import spark.skins.mobile.StageTextInputSkin; spark.skins.mobile.StageTextInputSkin;
		import spark.skins.mobile.ScrollingStageTextInputSkin; spark.skins.mobile.ScrollingStageTextInputSkin;
		import spark.skins.mobile.ScrollingStageTextAreaSkin; spark.skins.mobile.ScrollingStageTextAreaSkin
		import spark.skins.mobile.TabbedViewNavigatorApplicationSkin; spark.skins.mobile.TabbedViewNavigatorApplicationSkin;
		import spark.skins.mobile.TabbedViewNavigatorSkin; spark.skins.mobile.TabbedViewNavigatorSkin;
		import spark.skins.mobile.TabbedViewNavigatorTabBarSkin; spark.skins.mobile.TabbedViewNavigatorTabBarSkin;
		import spark.skins.mobile.TextAreaSkin; spark.skins.mobile.TextAreaSkin;
		import spark.skins.mobile.TextAreaHScrollBarSkin; spark.skins.mobile.TextAreaHScrollBarSkin;
		import spark.skins.mobile.TextAreaVScrollBarSkin; spark.skins.mobile.TextAreaVScrollBarSkin;
		import spark.skins.mobile.TextInputSkin; spark.skins.mobile.TextInputSkin;
		import spark.skins.mobile.ToggleSwitchSkin; spark.skins.mobile.ToggleSwitchSkin;
		import spark.skins.mobile.TransparentActionButtonSkin; spark.skins.mobile.TransparentActionButtonSkin;
		import spark.skins.mobile.TransparentNavigationButtonSkin; spark.skins.mobile.TransparentNavigationButtonSkin;
		import spark.skins.mobile.ViewMenuItemSkin; spark.skins.mobile.ViewMenuItemSkin;
		import spark.skins.mobile.ViewMenuSkin; spark.skins.mobile.ViewMenuSkin;
		import spark.skins.mobile.ViewNavigatorApplicationSkin; spark.skins.mobile.ViewNavigatorApplicationSkin;
		import spark.skins.mobile.ViewNavigatorSkin; spark.skins.mobile.ViewNavigatorSkin;
		import spark.skins.mobile.VScrollBarSkin; spark.skins.mobile.VScrollBarSkin;
		
		//Android skins
		import spark.skins.android4.ActionBarSkin; spark.skins.android4.ActionBarSkin;
		import spark.skins.android4.BusyIndicatorSkin; spark.skins.android4.BusyIndicatorSkin;
		import spark.skins.android4.ButtonBarFirstButtonSkin; spark.skins.android4.ButtonBarFirstButtonSkin;
		import spark.skins.android4.ButtonBarMiddleButtonSkin; spark.skins.android4.ButtonBarMiddleButtonSkin;
		import spark.skins.android4.ButtonBarSkin; spark.skins.android4.ButtonBarSkin;
		import spark.skins.android4.ButtonSkin; spark.skins.android4.ButtonSkin;
		import spark.skins.android4.CalloutSkin; spark.skins.android4.CalloutSkin;
		import spark.skins.android4.CheckBoxSkin; spark.skins.android4.CheckBoxSkin;
		import spark.skins.android4.HScrollBarSkin; spark.skins.android4.HScrollBarSkin;
		import spark.skins.android4.HScrollBarThumbSkin; spark.skins.android4.HScrollBarThumbSkin;
		import spark.skins.android4.HSliderSkin; spark.skins.android4.HSliderSkin;
		import spark.skins.android4.HSliderThumbSkin; spark.skins.android4.HSliderThumbSkin;
		import spark.skins.android4.HSliderTrackSkin; spark.skins.android4.HSliderTrackSkin;
		import spark.skins.android4.RadioButtonSkin; spark.skins.android4.RadioButtonSkin;
		import spark.skins.android4.SpinnerListContainerSkin; spark.skins.android4.SpinnerListContainerSkin;
		import spark.skins.android4.SpinnerListScrollerSkin; spark.skins.android4.SpinnerListScrollerSkin;
		import spark.skins.android4.SpinnerListSkin; spark.skins.android4.SpinnerListSkin;
		import spark.skins.android4.StageTextAreaSkin; spark.skins.android4.StageTextAreaSkin;
		import spark.skins.android4.StageTextInputSkin; spark.skins.android4.StageTextInputSkin;
		import spark.skins.android4.TabbedViewNavigatorTabBarSkin; spark.skins.android4.TabbedViewNavigatorTabBarSkin;
		import spark.skins.android4.TextAreaSkin; spark.skins.android4.TextAreaSkin;
		import spark.skins.android4.TextInputSkin; spark.skins.android4.TextInputSkin;
		import spark.skins.android4.ToggleSwitchSkin; spark.skins.android4.ToggleSwitchSkin;
		import spark.skins.android4.TransparentActionButtonSkin; spark.skins.android4.TransparentActionButtonSkin;
		import spark.skins.android4.TransparentNavigationButtonSkin; spark.skins.android4.TransparentNavigationButtonSkin;
		import spark.skins.android4.ViewMenuItemSkin; spark.skins.android4.ViewMenuItemSkin;
		import spark.skins.android4.ViewMenuSkin; spark.skins.android4.ViewMenuSkin;
		import spark.skins.android4.VScrollBarSkin; spark.skins.android4.VScrollBarSkin;
		import spark.skins.android4.VScrollBarThumbSkin; spark.skins.android4.VScrollBarThumbSkin;
		import spark.skins.android4.supportClasses.CalloutArrow; spark.skins.android4.supportClasses.CalloutArrow;
		
		//iOS7+ skins
		import spark.skins.ios7.ActionBarSkin; spark.skins.ios7.ActionBarSkin;
		import spark.skins.ios7.BusyIndicatorSkin; spark.skins.ios7.BusyIndicatorSkin;
		import spark.skins.ios7.ButtonBarFirstButtonSkin; spark.skins.ios7.ButtonBarFirstButtonSkin;
		import spark.skins.ios7.ButtonBarMiddleButtonSkin; spark.skins.ios7.ButtonBarMiddleButtonSkin;
		import spark.skins.ios7.ButtonBarSkin; spark.skins.ios7.ButtonBarSkin;
		import spark.skins.ios7.ButtonSkin; spark.skins.ios7.ButtonSkin;
		import spark.skins.ios7.CalloutSkin; spark.skins.ios7.CalloutSkin;
		import spark.skins.ios7.CalloutActionBarSkin; spark.skins.ios7.CalloutActionBarSkin;
		import spark.skins.ios7.CalloutViewNavigatorSkin; spark.skins.ios7.CalloutViewNavigatorSkin;
		import spark.skins.ios7.CheckBoxSkin; spark.skins.ios7.CheckBoxSkin;
		import spark.skins.ios7.HScrollBarSkin; spark.skins.ios7.HScrollBarSkin;
		import spark.skins.ios7.HScrollBarThumbSkin; spark.skins.ios7.HScrollBarThumbSkin;
		import spark.skins.ios7.HSliderSkin; spark.skins.ios7.HSliderSkin;
		import spark.skins.ios7.HSliderThumbSkin; spark.skins.ios7.HSliderThumbSkin;
		import spark.skins.ios7.HSliderTrackSkin; spark.skins.ios7.HSliderTrackSkin;
		import spark.skins.ios7.RadioButtonSkin; spark.skins.ios7.RadioButtonSkin;
		import spark.skins.ios7.SpinnerListContainerSkin; spark.skins.ios7.SpinnerListContainerSkin;
		import spark.skins.ios7.SpinnerListScrollerSkin; spark.skins.ios7.SpinnerListScrollerSkin;
		import spark.skins.ios7.SpinnerListSkin; spark.skins.ios7.SpinnerListSkin;
		import spark.skins.ios7.StageTextAreaSkin; spark.skins.ios7.StageTextAreaSkin;
		import spark.skins.ios7.StageTextInputSkin; spark.skins.ios7.StageTextInputSkin;
		import spark.skins.ios7.TabbedViewNavigatorTabBarSkin; spark.skins.ios7.TabbedViewNavigatorTabBarSkin;
		import spark.skins.ios7.TextAreaSkin; spark.skins.ios7.TextAreaSkin;
		import spark.skins.ios7.TextInputSkin; spark.skins.ios7.TextInputSkin;
		import spark.skins.ios7.ToggleSwitchSkin; spark.skins.ios7.ToggleSwitchSkin;
		import spark.skins.ios7.TransparentActionButtonSkin; spark.skins.ios7.TransparentActionButtonSkin;
		import spark.skins.ios7.TransparentNavigationButtonSkin; spark.skins.ios7.TransparentNavigationButtonSkin;
		import spark.skins.ios7.ViewMenuItemSkin; spark.skins.ios7.ViewMenuItemSkin;
		import spark.skins.ios7.ViewMenuSkin; spark.skins.ios7.ViewMenuSkin;
		import spark.skins.ios7.VScrollBarSkin; spark.skins.ios7.VScrollBarSkin;
		import spark.skins.ios7.VScrollBarThumbSkin; spark.skins.ios7.VScrollBarThumbSkin;
		import spark.skins.ios7.supportClasses.CalloutArrow; spark.skins.ios7.supportClasses.CalloutArrow;
		
	}
}
