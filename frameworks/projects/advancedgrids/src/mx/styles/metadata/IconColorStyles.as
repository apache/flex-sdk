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

/**
 *  The color for the icon in a skin. 
 *  For example, this style is used by the CheckBoxIcon skin class 
 *  to draw the check mark for a CheckBox control, 
 *  by the ComboBoxSkin class to draw the down arrow of the ComboBox control, 
 *  and by the DateChooserMonthArrowSkin skin class to draw the month arrow 
 *  for the DateChooser control. 
 * 
 *  The default value depends on the component class;
 *  if it is not overridden by the class, the default value is <code>0x111111</code>.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="iconColor", type="uint", format="Color", inherit="yes")]

/**
 *  The color for the icon in a disabled skin. 
 *  For example, this style is used by the CheckBoxIcon skin class 
 *  to draw the check mark for a disabled CheckBox control, 
 *  by the ComboBoxSkin class to draw the down arrow of a disabled ComboBox control, 
 *  and by the DateChooserMonthArrowSkin skin class to draw the month arrow 
 *  for a disabled DateChooser control. 
 * 
 *  The default value depends on the component class;
 *  if it is not overridden by the class, the default value is <code>0x999999</code>.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="disabledIconColor", type="uint", format="Color", inherit="yes")]