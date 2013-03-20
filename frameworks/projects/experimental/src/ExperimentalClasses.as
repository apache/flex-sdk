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
	internal class ExperimentalClasses
	{
		/**
		 *  @private
		 *  This class is used to link additional classes into experimental.swc
		 *  beyond those that are found by dependecy analysis starting
		 *  from the classes specified in manifest.xml.
		 */
		import spark.components.Alert; Alert;
		import spark.components.CallOutPosition; CallOutPosition;
		import spark.components.ArrowDirection; ArrowDirection;
		import spark.components.itemRenderers.MenuBarItemRenderer; MenuBarItemRenderer;
		import spark.components.itemRenderers.MenuCoreItemRenderer; MenuCoreItemRenderer;
		import spark.components.itemRenderers.MenuItemRenderer; MenuItemRenderer;
		import spark.components.listClasses.IListItemRenderer; IListItemRenderer;
		import spark.components.supportClazzes.AnimationTarget; AnimationTarget;
		import spark.components.supportClasses.IDropDownContainer; IDropDownContainer;
		import spark.containers.supportClazzes.DeferredCreationPolicy; DeferredCreationPolicy;
		import spark.containers.Accordion; Accordion;
		import spark.events.ColorChangeEvent; ColorChangeEvent;
		import spark.events.MenuEvent; MenuEvent;
		import spark.layouts.supportClasses.AnimationNavigatorLayoutBase; AnimationNavigatorLayoutBase;
		import spark.layouts.supportClasses.DropLocation; DropLocation;
		import spark.layouts.supportClasses.INavigatorLayout; INavigatorLayout;
		import spark.layouts.supportClasses.LayoutAxis; LayoutAxis;
		import spark.layouts.supportClasses.LayoutBase; LayoutBase;
		import spark.layouts.supportClasses.NavigatorLayoutBase; NavigatorLayoutBase;
		import spark.layouts.supportClasses.PerspectiveAnimationNavigatorLayoutBase; PerspectiveAnimationNavigatorLayoutBase;
		import spark.layouts.supportClasses.PerspectiveNavigatorLayoutBase; PerspectiveNavigatorLayoutBase;
		import spark.managers.INavigatorBrowserManager; INavigatorBrowserManager;
		import spark.managers.NavigatorBrowserManager; NavigatorBrowserManager;
		import spark.managers.NavigatorBrowserManagerImpl; NavigatorBrowserManagerImpl;
		import spark.skins.AccordionSkin; AccordionSkin;
		import spark.skins.AlertSkin; AlertSkin;
		import spark.skins.ArrowDownToggleButtonSkin; ArrowDownToggleButtonSkin;
		import spark.skins.ArrowRightToggleButtonSkin; ArrowRightToggleButtonSkin;
		import spark.skins.BorderDataNavigatorSkin; BorderDataNavigatorSkin;
		import spark.skins.ColorPickerButtonSkin; ColorPickerButtonSkin;
		import spark.skins.ColorPickerSkin; ColorPickerSkin;
		import spark.skins.DataAccordionSkin; DataAccordionSkin;
		import spark.skins.DataNavigatorSkin; DataNavigatorSkin;
		import spark.skins.HNoTrackNoThumbScrollBarSkin; HNoTrackNoThumbScrollBarSkin;
		import spark.skins.InlineScrollerSkin; InlineScrollerSkin;
		import spark.skins.MenuBarSkin; MenuBarSkin;
		import spark.skins.MenuSkin; MenuSkin;
		import spark.skins.NavigatorSkin; NavigatorSkin;
		import spark.skins.ProgressBarSkin; ProgressBarSkin;
		import spark.skins.TabNavigatorSkin; TabNavigatorSkin;
		import spark.skins.VNoTrackNoThumbScrollBarSkin; VNoTrackNoThumbScrollBarSkin;
		import spark.skins.spark.CallOutSkin; CallOutSkin;
		import spark.supportClasses.INavigator; INavigator;
		import spark.utils.ColorPickerUtil; ColorPickerUtil;
	}
}
