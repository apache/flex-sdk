////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
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
internal class WireframeClasses
{
	import spark.skins.wireframe.ApplicationSkin; ApplicationSkin;
	import spark.skins.wireframe.ButtonBarFirstButtonSkin; spark.skins.wireframe.ButtonBarFirstButtonSkin;
	import spark.skins.wireframe.ButtonBarLastButtonSkin; spark.skins.wireframe.ButtonBarLastButtonSkin;
	import spark.skins.wireframe.ButtonBarMiddleButtonSkin; spark.skins.wireframe.ButtonBarMiddleButtonSkin;
	import spark.skins.wireframe.ButtonBarSkin; ButtonBarSkin;
	import spark.skins.wireframe.ButtonSkin; spark.skins.wireframe.ButtonSkin;
	import spark.skins.wireframe.CheckBoxSkin; spark.skins.wireframe.CheckBoxSkin;
    import spark.skins.wireframe.ComboBoxButtonSkin; ComboBoxButtonSkin;
    import spark.skins.wireframe.ComboBoxSkin; spark.skins.wireframe.ComboBoxSkin;
    import spark.skins.wireframe.DataGridSkin; DataGridSkin;
	import spark.skins.wireframe.DefaultButtonSkin; spark.skins.wireframe.DefaultButtonSkin;
	import spark.skins.wireframe.DropDownListButtonSkin; DropDownListButtonSkin;
	import spark.skins.wireframe.DropDownListSkin; DropDownListSkin;
	import spark.skins.wireframe.HScrollBarSkin; HScrollBarSkin;
	import spark.skins.wireframe.HScrollBarThumbSkin; HScrollBarThumbSkin;
	import spark.skins.wireframe.HScrollBarTrackSkin; HScrollBarTrackSkin;
	import spark.skins.wireframe.HSliderSkin; HSliderSkin;
	import spark.skins.wireframe.HSliderThumbSkin; HSliderThumbSkin;
	import spark.skins.wireframe.HSliderTrackSkin; HSliderTrackSkin;
	import spark.skins.wireframe.ListSkin; ListSkin;
	import spark.skins.wireframe.mediaClasses.MuteButtonSkin; MuteButtonSkin;
	import spark.skins.wireframe.mediaClasses.ScrubBarSkin; ScrubBarSkin;
	import spark.skins.wireframe.mediaClasses.VolumeBarSkin; VolumeBarSkin;
	import spark.skins.wireframe.NumericStepperSkin; NumericStepperSkin;
	import spark.skins.wireframe.PanelSkin; PanelSkin;
	import spark.skins.wireframe.RadioButtonSkin; spark.skins.wireframe.RadioButtonSkin;
	import spark.skins.wireframe.ScrollBarDownButtonSkin; spark.skins.wireframe.ScrollBarDownButtonSkin;
	import spark.skins.wireframe.ScrollBarLeftButtonSkin; ScrollBarLeftButtonSkin;
	import spark.skins.wireframe.ScrollBarRightButtonSkin; ScrollBarRightButtonSkin;
	import spark.skins.wireframe.ScrollBarUpButtonSkin; spark.skins.wireframe.ScrollBarUpButtonSkin;
	import spark.skins.wireframe.SpinnerDecrementButtonSkin; SpinnerDecrementButtonSkin;
	import spark.skins.wireframe.SpinnerIncrementButtonSkin; SpinnerIncrementButtonSkin;
	import spark.skins.wireframe.SpinnerSkin; SpinnerSkin;
	import spark.skins.wireframe.TabBarSkin; TabBarSkin;
	import spark.skins.wireframe.TabBarButtonSkin; TabBarButtonSkin;
	import spark.skins.wireframe.TextAreaSkin; spark.skins.wireframe.TextAreaSkin;
	import spark.skins.wireframe.TextInputSkin; spark.skins.wireframe.TextInputSkin;
	import spark.skins.wireframe.TitleWindowCloseButtonSkin; TitleWindowCloseButtonSkin;
	import spark.skins.wireframe.TitleWindowSkin; TitleWindowSkin;
	import spark.skins.wireframe.ToggleButtonSkin; ToggleButtonSkin;
	import spark.skins.wireframe.VideoPlayerSkin; VideoPlayerSkin;
	import spark.skins.wireframe.VScrollBarSkin; VScrollBarSkin;
	import spark.skins.wireframe.VScrollBarThumbSkin; VScrollBarThumbSkin;
	import spark.skins.wireframe.VScrollBarTrackSkin; VScrollBarTrackSkin;
	import spark.skins.wireframe.VSliderSkin; VSliderSkin;
	import spark.skins.wireframe.VSliderThumbSkin; VSliderThumbSkin;
	import spark.skins.wireframe.VSliderTrackSkin; VSliderTrackSkin;
	
	import mx.skins.wireframe.AccordionHeaderSkin; AccordionHeaderSkin;
	import mx.skins.wireframe.BorderSkin; BorderSkin;
	import mx.skins.wireframe.ButtonBarFirstButtonSkin; mx.skins.wireframe.ButtonBarFirstButtonSkin;
	import mx.skins.wireframe.ButtonBarLastButtonSkin; mx.skins.wireframe.ButtonBarLastButtonSkin;
	import mx.skins.wireframe.ButtonBarMiddleButtonSkin; mx.skins.wireframe.ButtonBarMiddleButtonSkin;
	import mx.skins.wireframe.ButtonSkin; mx.skins.wireframe.ButtonSkin;
	import mx.skins.wireframe.CheckBoxSkin; mx.skins.wireframe.CheckBoxSkin;
	import mx.skins.wireframe.ColorPickerSkin; ColorPickerSkin;
	import mx.skins.wireframe.ComboBoxSkin; mx.skins.wireframe.ComboBoxSkin;
	import mx.skins.wireframe.ContainerBorderSkin; ContainerBorderSkin;
	import mx.skins.wireframe.ControlBarSkin; ControlBarSkin;
	import mx.skins.wireframe.DataGridHeaderBackgroundSkin; DataGridHeaderBackgroundSkin;
	import mx.skins.wireframe.DataGridHeaderSeparatorSkin; DataGridHeaderSeparatorSkin;
	import mx.skins.wireframe.DataGridSortArrow; DataGridSortArrow;
	import mx.skins.wireframe.DateChooserNextMonthSkin; DateChooserNextMonthSkin;
	import mx.skins.wireframe.DateChooserNextYearSkin; DateChooserNextYearSkin;
	import mx.skins.wireframe.DateChooserPrevMonthSkin; DateChooserPrevMonthSkin;
	import mx.skins.wireframe.DateChooserPrevYearSkin; DateChooserPrevYearSkin;
	import mx.skins.wireframe.DateChooserRollOverIndicatorSkin; DateChooserRollOverIndicatorSkin;
	import mx.skins.wireframe.DateChooserSelectionIndicatorSkin; DateChooserSelectionIndicatorSkin;
	import mx.skins.wireframe.DateChooserTodayIndicatorSkin; DateChooserTodayIndicatorSkin;
	import mx.skins.wireframe.DefaultButtonSkin; mx.skins.wireframe.DefaultButtonSkin;
	import mx.skins.wireframe.DividerSkin; DividerSkin;
	import mx.skins.wireframe.DropDownSkin; DropDownSkin;
	import mx.skins.wireframe.EditableComboBoxSkin; EditableComboBoxSkin;
	import mx.skins.wireframe.EmphasizedButtonSkin; EmphasizedButtonSkin;
	import mx.skins.wireframe.LinkButtonSkin; LinkButtonSkin;
	import mx.skins.wireframe.MenuArrow; MenuArrow;
	import mx.skins.wireframe.MenuArrowDisabled; MenuArrowDisabled;
	import mx.skins.wireframe.MenuBarItemSkin; MenuBarItemSkin;
	import mx.skins.wireframe.MenuBarSkin; MenuBarSkin;
	import mx.skins.wireframe.MenuCheck; MenuCheck;
	import mx.skins.wireframe.MenuCheckDisabled; MenuCheckDisabled;
	import mx.skins.wireframe.MenuRadio; MenuRadio;
	import mx.skins.wireframe.MenuRadioDisabled; MenuRadioDisabled;
	import mx.skins.wireframe.MenuSeparatorSkin; MenuSeparatorSkin;
	import mx.skins.wireframe.MenuSkin; MenuSkin;
	import mx.skins.wireframe.PanelBorderSkin; PanelBorderSkin;
	import mx.skins.wireframe.PopUpButtonSkin; PopUpButtonSkin;
	import mx.skins.wireframe.ProgressBarSkin; ProgressBarSkin;
	import mx.skins.wireframe.ProgressBarTrackSkin; ProgressBarTrackSkin;
	import mx.skins.wireframe.ProgressIndeterminateSkin; ProgressIndeterminateSkin;
	import mx.skins.wireframe.ProgressMaskSkin; ProgressMaskSkin;
	import mx.skins.wireframe.RadioButtonSkin; mx.skins.wireframe.RadioButtonSkin;
	import mx.skins.wireframe.ScrollBarDownButtonSkin; mx.skins.wireframe.ScrollBarDownButtonSkin;
	import mx.skins.wireframe.ScrollBarThumbSkin; ScrollBarThumbSkin;
	import mx.skins.wireframe.ScrollBarTrackSkin; ScrollBarTrackSkin;
	import mx.skins.wireframe.ScrollBarUpButtonSkin; mx.skins.wireframe.ScrollBarUpButtonSkin;
	import mx.skins.wireframe.SliderThumbSkin; SliderThumbSkin;
	import mx.skins.wireframe.SliderTrackHighlightSkin; SliderTrackHighlightSkin;
	import mx.skins.wireframe.SliderTrackSkin; SliderTrackSkin;
	import mx.skins.wireframe.StepperDecrButtonSkin; StepperDecrButtonSkin;
	import mx.skins.wireframe.StepperIncrButtonSkin; StepperIncrButtonSkin;
	import mx.skins.wireframe.TabSkin; TabSkin;
	import mx.skins.wireframe.TextAreaSkin; mx.skins.wireframe.TextAreaSkin;
	import mx.skins.wireframe.TextInputSkin; mx.skins.wireframe.TextInputSkin;
	import mx.skins.wireframe.TitleWindowCloseButtonDownSkin; TitleWindowCloseButtonDownSkin;
	import mx.skins.wireframe.TitleWindowCloseButtonOverSkin; TitleWindowCloseButtonOverSkin;
	import mx.skins.wireframe.TitleWindowCloseButtonUpSkin; TitleWindowCloseButtonUpSkin;
	import mx.skins.wireframe.ToolTipSkin; ToolTipSkin;
	import mx.skins.wireframe.WindowedApplicationSkin; WindowedApplicationSkin;
	import mx.skins.wireframe.windowChrome.CloseButtonSkin; CloseButtonSkin;
	import mx.skins.wireframe.windowChrome.MaximizeButtonSkin; MaximizeButtonSkin;
	import mx.skins.wireframe.windowChrome.MinimizeButtonSkin; MinimizeButtonSkin;
	import mx.skins.wireframe.windowChrome.RestoreButtonSkin; RestoreButtonSkin;
	import mx.skins.wireframe.windowChrome.StatusBarSkin; StatusBarSkin;
	import mx.skins.wireframe.windowChrome.TitleBarSkin; TitleBarSkin;


}

}
