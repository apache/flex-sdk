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
	import comps.*;
	import mx.controls.Button;
	import spark.components.Button;

	import spark.components.Group;
	import spark.components.VGroup;	
	import spark.components.HGroup;
	import mx.core.Container;
	import spark.components.SkinnableContainer;
	import mx.core.IVisualElementContainer;	
				
	public function testGenericVisualContainer(genericContentHolder:IVisualElementContainer):Boolean {
		
		// first figure out what this genericContentHolder actually is:
	
		var aGroup:Group 				= genericContentHolder as Group;
		var aVGroup:VGroup 				= genericContentHolder as VGroup;
		var aHGroup:HGroup 				= genericContentHolder as HGroup;
		var aFxContainer:SkinnableContainer 	= genericContentHolder as SkinnableContainer;
		var aContainer:Container 		= genericContentHolder as Container;
		
		//
		// check the parent and owner property of each element
		//
		
		for(var i:int = 0; i < genericContentHolder.numElements; i++){
			
			// get the owner and parent
			var tempOwner:* = genericContentHolder.getElementAt(i).owner;
			var tempParent:* = genericContentHolder.getElementAt(i).parent;
						
			if (	aGroup != null || 
					aVGroup != null || 
					aHGroup != null || 
					aContainer != null
				
					){
					
				// we're dealing with a Group or Halo Container component
			
				// TEST: check that the parent and owner are the same 
				if ((tempParent == genericContentHolder) && (tempOwner == genericContentHolder))
					continue; // pass
				
			}
			
			else if (aFxContainer != null){	
			
				// we're dealing with an FxContainer
				
				// TEST: check that parent and owner are different
				if ((tempParent == aFxContainer.contentGroup) && (tempOwner == aFxContainer))
					continue; // pass
				
			}
			
			// an element did not pass the test
			return false;
			
		}
		
		// all elements passed the test
		return true;
		
	}
		
	public function createButton(customLabel:String = 'Button'):mx.controls.Button {
		var btn:mx.controls.Button = new mx.controls.Button();
		btn.label = customLabel;
		return btn;
	}
	
	public function createFxButton(customLabel:String = 'FxButton'):spark.components.Button {
		var btn:spark.components.Button = new spark.components.Button();
		btn.label = customLabel;
		return btn;
	}
