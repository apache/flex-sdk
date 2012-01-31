////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package
{

internal class SparkClasses
{

/**
 *  @private
 *  This class is used to link additional classes into spark.swc
 *  beyond those that are found by dependecy analysis starting
 *  from the classes specified in manifest.xml.
 *  For example, Button does not have a reference to ButtonSkin,
 *  but ButtonSkin needs to be in framework.swc along with Button.
 */
import mx.controls.dataGridClasses.FTEDataGridItemRenderer; FTEDataGridItemRenderer;
import mx.controls.MXFTETextInput; MXFTETextInput;
import mx.core.UIFTETextField; UIFTETextField;
import spark.core.SpriteVisualElement; SpriteVisualElement;
import spark.skins.spark.ApplicationSkin; ApplicationSkin;
import spark.skins.spark.BorderSkin; BorderSkin;
import spark.skins.spark.ButtonSkin; ButtonSkin;
import spark.skins.spark.DefaultButtonSkin; DefaultButtonSkin;
import spark.skins.spark.ButtonBarSkin; ButtonBarSkin;
import spark.skins.spark.ButtonBarFirstButtonSkin; ButtonBarFirstButtonSkin;
import spark.skins.spark.ButtonBarMiddleButtonSkin; ButtonBarMiddleButtonSkin;
import spark.skins.spark.ButtonBarLastButtonSkin; ButtonBarLastButtonSkin;
import spark.skins.spark.CheckBoxSkin; CheckBoxSkin;
import spark.skins.spark.DefaultButtonSkin; DefaultButtonSkin;
import spark.skins.spark.DefaultComplexItemRenderer; DefaultComplexItemRenderer;
import spark.skins.spark.DefaultItemRenderer; DefaultItemRenderer;
import spark.skins.spark.DropDownListButtonSkin; DropDownListButtonSkin;
import spark.skins.spark.DropDownListSkin; DropDownListSkin;
import spark.skins.spark.ErrorSkin; ErrorSkin;
import spark.skins.spark.FocusSkin; FocusSkin;
import spark.skins.spark.HScrollBarSkin; HScrollBarSkin;
import spark.skins.spark.HScrollBarThumbSkin; HScrollBarThumbSkin;
import spark.skins.spark.HSliderSkin; HSliderSkin;
import spark.skins.spark.HSliderThumbSkin; HSliderThumbSkin;
import spark.skins.spark.HSliderTrackSkin; HSliderTrackSkin;
import spark.skins.spark.ListSkin; ListSkin;
import spark.skins.spark.mediaClasses.normal.MuteButtonSkin; MuteButtonSkin;
import spark.skins.spark.mediaClasses.normal.ScrubBarSkin; ScrubBarSkin;
import spark.skins.spark.mediaClasses.normal.VolumeBarSkin; VolumeBarSkin;
import spark.skins.spark.NumericStepperSkin; NumericStepperSkin;
import spark.skins.spark.PanelSkin; PanelSkin;
import spark.skins.spark.RadioButtonSkin; RadioButtonSkin;
import spark.skins.spark.ScrollBarUpButtonSkin; ScrollBarUpButtonSkin;
import spark.skins.spark.ScrollBarDownButtonSkin; ScrollBarDownButtonSkin;
import spark.skins.spark.ScrollBarLeftButtonSkin; ScrollBarLeftButtonSkin;
import spark.skins.spark.ScrollBarRightButtonSkin; ScrollBarRightButtonSkin;
import spark.skins.spark.ScrollerSkin; ScrollerSkin;
import spark.skins.spark.SkinnableContainerSkin; SkinnableContainerSkin;
import spark.skins.spark.SkinnableDataContainerSkin; SkinnableDataContainerSkin;
import spark.skins.spark.SpinnerDecrementButtonSkin; SpinnerDecrementButtonSkin;
import spark.skins.spark.SpinnerIncrementButtonSkin; SpinnerIncrementButtonSkin;
import spark.skins.spark.SpinnerSkin; SpinnerSkin;
import spark.skins.spark.TextAreaSkin; TextAreaSkin;
import spark.skins.spark.TextInputSkin; TextInputSkin;
import spark.skins.spark.ToggleButtonSkin; ToggleButtonSkin;
import spark.skins.spark.VideoPlayerSkin; VideoPlayerSkin;
import spark.skins.spark.VScrollBarSkin; VScrollBarSkin;
import spark.skins.spark.VScrollBarThumbSkin; VScrollBarThumbSkin;
import spark.skins.spark.VScrollBarTrackSkin; VScrollBarTrackSkin;
import spark.skins.spark.VSliderSkin; VSliderSkin;
import spark.skins.spark.VSliderThumbSkin; VSliderThumbSkin;
import spark.skins.spark.VSliderTrackSkin; VSliderTrackSkin;
import spark.utils.TextFlowUtil; TextFlowUtil;
}

}
