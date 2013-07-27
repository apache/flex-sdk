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
package spark.components.supportClasses
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.core.mx_internal;
	
	import spark.components.supportClasses.DropDownController;
	//import spark.events.DropDownEvent;
	
	import spark.components.CallOutButton;
	
	use namespace mx_internal;
	
	public class CallOutDropDownController extends DropDownController
	{
		//private var openDropDowns:ArrayCollection;
		
		public function CallOutDropDownController()
		{
			super();
			
			//openDropDowns = new ArrayCollection();
			
			//this.addEventListener(DropDownEvent.OPEN, onOpenDropDown);
		}
		
		override mx_internal function systemManager_mouseDownHandler(event:Event):void
		{
			if((openButton as CallOutButton).subCallOut != null)
			{
				if( this.hitAreaAdditions)
				{
					if(this.hitAreaAdditions.indexOf((openButton as CallOutButton).subCallOut) == -1)
						this.hitAreaAdditions = Vector.<DisplayObject>( [ (openButton as CallOutButton).subCallOut ] ).concat( this.hitAreaAdditions );
				}
				else
				{
					this.hitAreaAdditions = Vector.<DisplayObject>( [ (openButton as CallOutButton).subCallOut ] );
				}
			}
			
			super.mx_internal::systemManager_mouseDownHandler(event);
		}
		/*
		private function onOpenDropDown(event:DropDownEvent):void
		{
			var test:String = "neu";
			
			openDropDowns.addItem({dropDownController:event.target});
		}
		
		override public function closeDropDown(commit:Boolean):void
		{
			var test:String = "neu";
		}
		*/
	}
}