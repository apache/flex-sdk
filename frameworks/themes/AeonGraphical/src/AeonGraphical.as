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
    
import flash.display.Sprite;

/**
 *  The main class for the AeonGraphical.swf that gets embedded in the CSS
 *  file.
 */
public class AeonGraphical extends Sprite
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
	public function AeonGraphical()
    {
		super();
    }

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
    private var assets:Array = [
        AccordionHeader_disabledSkin,
        AccordionHeader_downSkin,
        AccordionHeader_overSkin,
        AccordionHeader_upSkin,
        ApplicationBackground,
        BusyCursor,
        Button_disabledSkin,
        Button_downSkin,
        Button_overSkin,
        Button_upSkin,
        ButtonBar_buttonDisabledSkin,
        ButtonBar_buttonDownSkin,
        ButtonBar_buttonOverSkin,
        ButtonBar_buttonSelectedDisabledSkin,
        ButtonBar_buttonSelectedUpSkin,
        ButtonBar_buttonUpSkin,
        ButtonBar_firstDisabledSkin,
        ButtonBar_firstDownSkin,
        ButtonBar_firstOverSkin,
        ButtonBar_firstSelectedDisabledSkin,
        ButtonBar_firstSelectedUpSkin,
        ButtonBar_firstUpSkin,
        ButtonBar_lastDisabledSkin,
        ButtonBar_lastDownSkin,
        ButtonBar_lastOverSkin,
        ButtonBar_lastSelectedDisabledSkin,
        ButtonBar_lastSelectedUpSkin,
        ButtonBar_lastUpSkin,
        CheckBox_disabledIcon,
        CheckBox_downIcon,
        CheckBox_overIcon,
        CheckBox_selectedDisabledIcon,
        CheckBox_selectedDownIcon,
        CheckBox_selectedOverIcon,
        CheckBox_selectedUpIcon,
        CheckBox_upIcon,
        CloseButtonDisabled,
        CloseButtonDown,
        CloseButtonOver,
        CloseButtonUp,
        ComboBoxArrow_disabledSkin,
        ComboBoxArrow_downSkin,
        ComboBoxArrow_editableDisabledSkin,
        ComboBoxArrow_editableDownSkin,
        ComboBoxArrow_editableOverSkin,
        ComboBoxArrow_editableUpSkin,
        ComboBoxArrow_overSkin,
        ComboBoxArrow_upSkin,
        DataGrid_columnDropIndicatorSkin,
        DataGrid_columnResizeSkin,
        DataGrid_headerSeparatorSkin,
        DataGrid_sortArrowSkin,
        DataGrid_stretchCursor,
        DateChooser_nextMonthDisabledSkin,
        DateChooser_nextMonthDownSkin,
        DateChooser_nextMonthOverSkin,
        DateChooser_nextMonthUpSkin,
        DateChooser_nextYearDisabledSkin,
        DateChooser_nextYearDownSkin,
        DateChooser_nextYearOverSkin,
        DateChooser_nextYearUpSkin,
        DateChooser_prevMonthDisabledSkin,
        DateChooser_prevMonthDownSkin,
        DateChooser_prevMonthOverSkin,
        DateChooser_prevMonthUpSkin,
        DateChooser_prevYearDisabledSkin,
        DateChooser_prevYearDownSkin,
        DateChooser_prevYearOverSkin,
        DateChooser_prevYearUpSkin,
        DateChooser_rollOverIndicatorSkin,
        DateChooser_selectionIndicatorSkin,
        DateChooser_todayIndicatorSkin,
        DateField_disabledSkin,
        DateField_downSkin,
        DateField_overSkin,
        DateField_upSkin,
        DividedBox_dividerSkin,
        DividedBox_horizontalCursor,
        DividedBox_verticalCursor,
        DragManager_copyCursor,
        DragManager_defaultDragImageSkin,
        DragManager_linkCursor,
        DragManager_moveCursor,
        DragManager_rejectCursor,
        FormItem_indicatorSkin,
        HSliderHighlight_Skin,
        HSliderThumb_disabledSkin,
        HSliderThumb_downSkin,
        HSliderThumb_overSkin,
        HSliderThumb_upSkin,
        HSliderTrack_Skin,
        Loader_brokenImageSkin,
        Menu_branchDisabledIcon,
        Menu_branchIcon,
        Menu_checkDisabledIcon,
        Menu_checkIcon,
        Menu_radioDisabledIcon,
        Menu_radioIcon,
        Menu_separatorSkin,
        MenuBar_backgroundSkin,
        MenuBar_itemDownSkin,
        MenuBar_itemOverSkin,
        MenuBar_itemUpSkin,
        NumericStepperDownArrow_DisabledSkin,
        NumericStepperDownArrow_DownSkin,
        NumericStepperDownArrow_OverSkin,
        NumericStepperDownArrow_UpSkin,
        NumericStepperUpArrow_DisabledSkin,
        NumericStepperUpArrow_DownSkin,
        NumericStepperUpArrow_OverSkin,
        NumericStepperUpArrow_UpSkin,
        PanelTitleBackground,
        PopUpButton_DisabledSkin,
        PopUpButton_downSkin,
        PopUpButton_overSkin,
        PopUpButton_popUpDownSkin,
        PopUpButton_popUpOverSkin,
        PopUpButton_upSkin,
        ProgressBarSkin,
        ProgressIndeterminateSkin,
        ProgressTrackSkin,
        RadioButton_disabledIcon,
        RadioButton_downIcon,
        RadioButton_overIcon,
        RadioButtonSelected_disabledIcon,
        RadioButtonSelected_downIcon,
        RadioButtonSelected_overIcon,
        RadioButtonSelected_upIcon,
        RadioButtonIcon,
        ScrollArrowDown_disabledSkin,
        ScrollArrowDown_downSkin,
        ScrollArrowDown_overSkin,
        ScrollArrowDown_upSkin,
        ScrollArrowUp_disabledSkin,
        ScrollArrowUp_downSkin,
        ScrollArrowUp_overSkin,
        ScrollArrowUp_upSkin,
        ScrollBar_thumbIcon,
        ScrollThumb_downSkin,
        ScrollThumb_overSkin,
        ScrollThumb_upSkin,
        ScrollTrack_Skin,
        Tab_disabledSkin,
        Tab_downSkin,
        Tab_overSkin,
        Tab_upSkin,
        TabSelected_disabledSkin,
        TabSelected_upSkin,
        ToolTip_borderSkin,
        Tree_defaultLeafIcon,
        Tree_disclosureClosedIcon,
        Tree_disclosureOpenIcon,
        Tree_folderClosedIcon,
        Tree_folderOpenIcon,
		VSliderHighlight_Skin,
        VSliderThumb_disabledSkin,
        VSliderThumb_downSkin,
        VSliderThumb_overSkin,
        VSliderThumb_upSkin,
		VSliderTrack_Skin,
        panelBackground
    ];
}

}
