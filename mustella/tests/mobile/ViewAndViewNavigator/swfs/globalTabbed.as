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

import mx.core.FlexGlobals;
import spark.components.TabbedViewNavigator;
import spark.events.IndexChangeEvent;
import mx.events.FlexEvent;
import spark.events.ElementExistenceEvent;
import spark.components.ViewNavigator;

public function resetApp():void {
	trace('resetApp - - -');
	if(tabbedNavigator.selectedIndex == 0) {
		trace('a1 - - -');
		onFirstTabComplete(null);
	} else {
		trace('b2 - - -');
		tabbedNavigator.selectedIndex = 0;
		tabbedNavigator.addEventListener(IndexChangeEvent.CHANGE, onFirstTabComplete)
	}
}

public function onFirstTabComplete(e:IndexChangeEvent):void {
	tabbedNavigator.removeEventListener(IndexChangeEvent.CHANGE, onFirstTabComplete)
	doPopAll();
}

public function onResetComplete(e:Event):void {
	trace('onResetComplete ----');
	tabbedNavigator.removeEventListener("viewChangeComplete", onResetComplete)
	tabbedNavigator.dispatchEvent(new Event("myEvent"));
}

public function doPopAll():void{
	
	//trace('doPopAll - - - ' + ViewNavigator(navigator.selectedNavigator).length);
	if(tabbedNavigator == null || tabbedNavigator.selectedNavigator == null || ViewNavigator(tabbedNavigator.selectedNavigator).length == 0) {
		trace('a ----');
		onResetComplete(null);
	} else {	
		trace('b ----');
		ViewNavigator(tabbedNavigator.selectedNavigator).addEventListener("viewChangeComplete", onResetComplete)
		ViewNavigator(tabbedNavigator.selectedNavigator).popAll();
	}

}
