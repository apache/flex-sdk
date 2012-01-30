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

package mx.automation.delegates.advancedDataGrid
{
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import mx.automation.Automation;
	import mx.automation.IAutomationObject;
	import mx.automation.delegates.core.UIComponentAutomationImpl;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.controls.listClasses.ListBaseContentHolder;
	import mx.controls.listClasses.AdvancedListBaseContentHolder;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	
	[Mixin]
	/**
	 * 
	 *  Defines methods and properties required to perform instrumentation for the 
	 *  AdvancedListBaseContentHolder class.
	 * 
	 *  @see mx.controls.listClasses.AdvancedListBaseContentHolder 
	 *
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class AdvancedListBaseContentHolderAutomationImpl extends UIComponentAutomationImpl 
	{
		// include "../../../core/Version.as";
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Registers the delegate class for a component class with automation manager.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public static function init(root:DisplayObject):void
		{
			Automation.registerDelegateClass(AdvancedListBaseContentHolder, AdvancedListBaseContentHolderAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 * @param obj ListBaseContentHolder object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function AdvancedListBaseContentHolderAutomationImpl(obj:AdvancedListBaseContentHolder)
		{
			super(obj);
			
			obj.addEventListener(Event.ADDED, addedHandler, false, 0, true);
		}
		
		/**
		 *  @private
		 *  storage for the owner component
		 */
		protected function get listContent():AdvancedListBaseContentHolder
		{
			return uiComponent as AdvancedListBaseContentHolder;
		}
		
		/**
		 *  @private
		 *  The super handler makes the child a composite if the parent is already a composite.
		 *  We have overriden here to revert that.
		 */
		protected function addedHandler(event:Event):void 
		{
			if (event.target is IListItemRenderer)
			{
				var item:IListItemRenderer = event.target as IListItemRenderer;
				if (item.parent == listContent)
				{
					item.owner = listContent.getParentList();
					if (item is IAutomationObject)
						IAutomationObject(item).showInAutomationHierarchy = true;
					
				}
			}
		}
		
		/**
		 *  @private
		 */
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			//no recording required
		}
		
	}
	
}