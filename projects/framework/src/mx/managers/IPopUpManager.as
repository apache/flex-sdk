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

package mx.managers
{

import flash.display.DisplayObject;
import mx.core.IFlexDisplayObject;
import mx.core.IFlexModuleFactory;

[ExcludeClass]

/**
 *  @private
 */
public interface IPopUpManager
{
	function createPopUp(parent:DisplayObject,
			className:Class,
			modal:Boolean = false,
			childList:String = null,
            moduleFactory:IFlexModuleFactory = null):IFlexDisplayObject;
	function addPopUp(window:IFlexDisplayObject,
			parent:DisplayObject,
			modal:Boolean = false,
			childList:String = null,
            moduleFactory:IFlexModuleFactory = null):void;
	function centerPopUp(popUp:IFlexDisplayObject):void;
	function removePopUp(popUp:IFlexDisplayObject):void;
	function bringToFront(popUp:IFlexDisplayObject):void;
}

}

