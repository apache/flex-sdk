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
/*
 * This file provides ActionScript methods for testing the property.state syntax provided by MXML.
 * 
 * To test the includeIn/excludeFrom state operators, it looks like that has to be done in MXML
 * at compile time as the equivalent AS isn't really possible to recreate at runtime.
 *
 */

import mx.states.SetProperty;
import mx.states.State;
import mx.events.StateChangeEvent;
import mx.core.UIComponent;

/*
 * this object is just for replacing entries in the overrides array with useless information
 * rather than deleting those entries and dealing with null entries.
 */
public var garbageObject:Object;

/*
 * This method exposes an ActionScript interface to adding property changes to the new state syntax.
 * You must define the states via MXML before calling this method.
 *
 * Parameters:
 *   - stateName:int - name of the state to change
 *   - propertyChangeTarget:String - the id of the target object
 *   - propertyChangeName:String - name of property to change
 *   - propertyChangeValue:* - value to change the property to
 * Returns:
 *   - int: 1 on complete, -1 on error
 *		
 * Example Usage:
 * 
 * 1. Define the states and target in MXML:
 *  <states>
 *		<State name="state1" />
 *		<State name="state2" />
 *	</states>
 *
 *  <FxButton id="someButton" />
 *
 * 2. Call the reset method:
 *  resetStatePropertyChange();
 * 3. Call this method:
 *  addStatePropertyChange('state1', 'someButton', 'width', 50);
 *  addStatePropertyChange('state2', 'someButton', 'width', 500);
 * -----
 * Note that calling step2 and step3 would be equivalent to the following MXML:
 *  <FxButton id="someButton" width.state1="50" width.state2="500" />
 */ 
public function addStatePropertyChange(stateName:String, propertyChangeTarget:String, propertyChangeName:String, propertyChangeValue:*):int {
	
	var stateIndex:int = getIndexFromStateName(stateName);
	
	if (stateIndex == -1) // bad state name
		return -1;
	
	if(states[stateIndex].overrides.push(new mx.states.SetProperty().initializeFromObject({target: propertyChangeTarget, name: propertyChangeName, value: propertyChangeValue})) >= 0){
		return 1;
	} else {
		return -1;	
	}
}

/*
 *	Clears all the SetProperty overrides from each state.  
 *  Must be called before calling addStatePropertyChange()
 */
public function resetStatePropertyChange():Boolean {

	garbageObject = new Object();

	for(var i:int = 0; i < states.length; i++){
		for (var j:int = 0; j < states[i].overrides.length; j++) {
			if(states[i].overrides[j] is mx.states.SetProperty) {
				// replace it with garbage
				// TODO: some fancy reworking of this overrides array is probably more appropriate, but 
				// just assigning garbage mappings seems to work well so far.
				states[i].overrides[j] =  new mx.states.SetProperty().initializeFromObject({
					target: "garbageObject",
					name: "garbage",
					value: 0
				  });
			}
		}
	}
	return true;
}

/*
 * Any test case could start out in any state, depending on how the
 * previous test failed.  Therefore, we cannot switch to a state and
 * then wait, since we may already be in that state.
 *
 * Parameter: component - the component to reset state on, leave null for application
 */
public function resetStateTest(component:UIComponent = null):void {
	
	if(component == null){
		// change the state of the application
		
		// now go back to default state
		if(currentState == "defaultState"){
			dispatchEvent(new Event("manualResetComplete"));
		} else {
			addEventListener("currentStateChange", handleCurrentStateChange);
			currentState = "defaultState";   
		}
		
	} else {
		// change the state of the component
		
		// now go back to default state
		if(component.currentState == "defaultState"){
			dispatchEvent(new Event("manualResetComplete"));
		} else {
			addEventListener("currentStateChange", handleCurrentStateChange);
			component.currentState = "defaultState";   
		}
		
	}
}

/*
 * This is the listener for the resetStateTest() method above
 */
private function handleCurrentStateChange(e:StateChangeEvent):void{
	dispatchEvent(new Event("manualResetComplete"));
}

/*
 * Helper function to return the index of the state given its name
 */
private function getIndexFromStateName(stateName:String):int {
	for(var i:int = 0; i < states.length; i++){
		if (states[i].name == stateName)
			return i;
	}
	
	// didn't find a state with this name
	return -1;
}
