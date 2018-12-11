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
 *  This class is used to link additional classes into framework.swc
 *  beyond those that are found by dependecy analysis starting
 *  from the classes specified in manifest.xml.
 *  For example, Button does not have a reference to ButtonSkin,
 *  but ButtonSkin needs to be in framework.swc along with Button.
 */
internal class FlatSparkSkinsClasses
{
	// skins
	import flatspark.skins.AlertSkin; AlertSkin;
    import flatspark.skins.ButtonSkin; ButtonSkin;
	import flatspark.skins.ButtonIconSkin; ButtonIconSkin;
	import flatspark.skins.CheckBoxSkin; CheckBoxSkin;
	import flatspark.skins.ComboBoxSkin; ComboBoxSkin;
	import flatspark.skins.ScrollerSkin; ScrollerSkin;
	import flatspark.skins.DropDownListSkin; DropDownListSkin;
	import flatspark.skins.PanelSkin; PanelSkin;
	import flatspark.skins.ProgressBarSkin; ProgressBarSkin;
	import flatspark.skins.RadioButtonSkin; RadioButtonSkin;
	import flatspark.skins.TextInputSkin; TextInputSkin;
	import flatspark.skins.TextInputIconSkin; TextInputIconSkin;
	import flatspark.skins.TitleWindowSkin; TitleWindowSkin;
	// Maintain alphabetical order
}

}

