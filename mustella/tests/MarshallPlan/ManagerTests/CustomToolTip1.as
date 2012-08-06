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
 import mx.containers.Panel;
 import mx.controls.Label;
 import mx.core.IToolTip;
 import mx.managers.ToolTipManager;

 public class CustomToolTip1 extends Panel implements IToolTip
 {
  private var _label:Label;
  
  public function CustomToolTip1()
  {
   super();
  }
  
  override protected function createChildren():void
  {
   super.createChildren();
   
   _label = new Label();
   addChild( _label );    
  }  

  override protected function commitProperties():void
  {
   super.commitProperties();   
   text = ToolTipManager.currentTarget[ "toolTip" ];
  }  
    
  public function get text() : String
  {
   return _label.text;
  }
  public function set text( value:String ) : void
  {
   _label.text = value;
  }
 }
}
