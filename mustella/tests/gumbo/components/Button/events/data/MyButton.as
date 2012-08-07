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
﻿package data{

import mx.controls.*;

import mx.core.*;

import flash.events.*;

import mx.managers.IFocusManagerComponent;



	public class MyButton extends Button 

	{

	   public function MyButton()

	   {

		  height=60;

		  width=80;

		  toggle=true;

		  this.addEventListener("click", change_color);

	   }



	   public function change_color(event:MouseEvent):void 

	   {

		  this.setStyle("themeColor", 0xFF0000);

       }

	}



}
