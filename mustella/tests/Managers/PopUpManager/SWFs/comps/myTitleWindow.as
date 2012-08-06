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
package comps {
import mx.controls.*;
import mx.containers.TitleWindow;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;

	public class myTitleWindow extends TitleWindow
	{
	   public function myTitleWindow() : void
	   {
          height=160;
		  width=180;
		  showCloseButton = true;

		  var btn1:Button = new Button();
		  btn1.label = "button 1";
		  addChild(btn1);

		  var date1:DateChooser = new DateChooser();
		  addChild(date1);
		  addEventListener("close", _close);
	   }

	   public function _close(event:CloseEvent) : void
	   {
		   PopUpManager.removePopUp(this);
	   }

	}
}
