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
package spark.supportClasses
{
	import mx.core.IDeferredContentOwner;
	import mx.core.ISelectableList;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	
	import spark.components.supportClasses.GroupBase;
	
	import spark.layouts.supportClasses.INavigatorLayout;

// for asdoc
[Experimental]

public interface INavigator extends ISelectableList, IVisualElement
	{
		
		function get layout():INavigatorLayout;
		function set layout( value:INavigatorLayout ):void
	}
}