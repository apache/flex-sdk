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
	import spark.skins.wireframe.ButtonBarFirstButtonSkin; ButtonBarFirstButtonSkin;
	import spark.skins.wireframe.ButtonBarLastButtonSkin; ButtonBarLastButtonSkin;
	import spark.skins.wireframe.ButtonBarMiddleButtonSkin; ButtonBarMiddleButtonSkin;
	import spark.skins.wireframe.ButtonBarSkin; ButtonBarSkin;
	import spark.skins.wireframe.ButtonSkin; ButtonSkin;
	import spark.skins.wireframe.CheckBoxSkin; CheckBoxSkin;
    import spark.skins.wireframe.ComboBoxButtonSkin; ComboBoxButtonSkin;
    import spark.skins.wireframe.ComboBoxSkin; ComboBoxSkin;
	import spark.skins.wireframe.DefaultButtonSkin; DefaultButtonSkin;
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
	import spark.skins.wireframe.RadioButtonSkin; RadioButtonSkin;
	import spark.skins.wireframe.ScrollBarDownButtonSkin; ScrollBarDownButtonSkin;
	import spark.skins.wireframe.ScrollBarLeftButtonSkin; ScrollBarLeftButtonSkin;
	import spark.skins.wireframe.ScrollBarRightButtonSkin; ScrollBarRightButtonSkin;
	import spark.skins.wireframe.ScrollBarUpButtonSkin; ScrollBarUpButtonSkin;
	import spark.skins.wireframe.SpinnerDecrementButtonSkin; SpinnerDecrementButtonSkin;
	import spark.skins.wireframe.SpinnerIncrementButtonSkin; SpinnerIncrementButtonSkin;
	import spark.skins.wireframe.SpinnerSkin; SpinnerSkin;
	import spark.skins.wireframe.TextAreaSkin; TextAreaSkin;
	import spark.skins.wireframe.TextInputSkin; TextInputSkin;
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
}

}
