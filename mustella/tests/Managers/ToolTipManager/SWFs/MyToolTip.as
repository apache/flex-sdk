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
  import mx.core.UITextField; 
  import mx.skins.halo.ToolTipBorder; 
  import mx.controls.ToolTip; 
  public class MyToolTip extends ToolTipBorder 
  { 


   	override protected function updateDisplayList(unscaledWidth:Number, 
 	unscaledHeight:Number):void
 	{ 
    	     var toolTip:ToolTip = (this.parent as ToolTip); 
    	     var textField:UITextField = toolTip.getChildAt(1) as UITextField; 
             textField.htmlText = textField.text; 
             var calHeight:Number = textField.height; 
             calHeight += textField.y*2; 
             calHeight += textField.getStyle("paddingTop"); 
             calHeight += textField.getStyle("paddingBottom"); 
             var calWidth:Number = textField.textWidth; 
             calWidth += textField.x*2; 
             calWidth += textField.getStyle("paddingLeft"); 
             calWidth += textField.getStyle("paddingRight"); 
             super.updateDisplayList(calWidth, calHeight); 
	} 

   } 
 } 


