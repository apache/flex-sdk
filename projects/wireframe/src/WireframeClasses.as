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
	import wireframe.FxButtonSkin; FxButtonSkin;
	import wireframe.FxCheckBoxSkin; FxCheckBoxSkin;
	import wireframe.FxDefaultComplexItemRenderer; FxDefaultComplexItemRenderer;
	import wireframe.FxDefaultItemRenderer; FxDefaultItemRenderer;
	import wireframe.FxHScrollBarSkin; FxHScrollBarSkin;
	import wireframe.FxHScrollBarThumbSkin; FxHScrollBarThumbSkin;
	import wireframe.FxHScrollBarTrackSkin; FxHScrollBarTrackSkin;
	import wireframe.FxHSliderSkin; FxHSliderSkin;
	import wireframe.FxHSliderThumbSkin; FxHSliderThumbSkin;
	import wireframe.FxHSliderTrackSkin; FxHSliderTrackSkin;
	import wireframe.FxListSkin; FxListSkin;
	import wireframe.FxNumericStepperSkin; FxNumericStepperSkin;
	import wireframe.FxRadioButtonSkin; FxRadioButtonSkin;
	import wireframe.FxScrollBarDownButtonSkin; FxScrollBarDownButtonSkin;
	import wireframe.FxScrollBarLeftButtonSkin; FxScrollBarLeftButtonSkin;
	import wireframe.FxScrollBarRightButtonSkin; FxScrollBarRightButtonSkin;
	import wireframe.FxScrollBarUpButtonSkin; FxScrollBarUpButtonSkin;
	import wireframe.FxSpinnerDecrButtonSkin; FxSpinnerDecrButtonSkin;
	import wireframe.FxSpinnerIncrButtonSkin; FxSpinnerIncrButtonSkin;
	import wireframe.FxSpinnerSkin; FxSpinnerSkin;
	import wireframe.FxTextAreaSkin; FxTextAreaSkin;
	import wireframe.FxTextInputSkin; FxTextInputSkin;
	import wireframe.FxToggleButtonSkin; FxToggleButtonSkin;
	import wireframe.FxVScrollBarSkin; FxVScrollBarSkin;
	import wireframe.FxVScrollBarThumbSkin; FxVScrollBarThumbSkin;
	import wireframe.FxVScrollBarTrackSkin; FxVScrollBarTrackSkin;
	import wireframe.FxVSliderSkin; FxVSliderSkin;
	import wireframe.FxVSliderThumbSkin; FxVSliderThumbSkin;
	import wireframe.FxVSliderTrackSkin; FxVSliderTrackSkin;
}

}
