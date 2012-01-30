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

/**
 *  Interface that must be implemented by objects
 *  registered with the History Manager. The methods in this interface are
 *  called by the HistoryManager when saving and loading the history state
 *  of the application.
 *
 *  <p>This interface is implemented by the Flex navigator containers 
 *  TabNavigator, Accordion, and ViewStack. It must be implemented by any other
 *  component that is registered with the HistoryManager.</p> 
 *
 *  @see mx.managers.HistoryManager
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IHistoryManagerClient
{
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  Saves the state of this object. 
	 *  The object contains name:value pairs for each property
	 *  to be saved with the state. 
	 *
	 *  <p>The History Manager collects the state information from all components
	 *  and encodes the information in a URL format. Most browsers have a length
	 *  limitation on URLs, so the state information returned should be as minimal
	 *  as possible.</p>
	 *
	 *  @example The following code saves the selected index from a List, and
	 *  a search string.
	 *  <pre>
	 *  public function saveState():Object
	 *  {
	 *  	var state:Object = {};
	 *
	 *  	state.selectedIndex = myList.selectedIndex;
	 *  	state.searchString = mySearchInput.text;
	 *
	 *  	return state;
	 *	}
	 *	</pre>
	 *
	 *  @return The state of this object.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function saveState():Object;
	
	/**
	 *  Loads the state of this object.
	 *  
	 *  @param state State of this object to load.
	 *  This will be null when loading the initial state of the application.
	 *
	 *  @example The following code loads the selected index and search string
	 *  from the saved state.
	 *  <pre>
	 *  public function loadState(state:Object):void
	 *  {
	 *  	// First, check to see if state is null. When the app is reset
	 *  	// back to its initial state, loadState() is passed null.
	 *  	if (state == null)
	 *  	{
	 *			myList.selectedIndex = -1;
	 *  		mySearchInput.text = "";
	 *  	}
	 *  	else
	 *  	{
	 *  		myList.selectedIndex = state.selectedIndex;
	 *  		mySearchInput.text = state.searchString;
	 *  	}
	 *  }
	 *  </pre>
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function loadState(state:Object):void;
	
	/**
	 *  Converts this object to a unique string. 
	 *  Implemented by UIComponent.
	 *
	 *  @return The unique identifier for this object.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function toString():String;
}

}
