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

package mx.automation.delegates.controls 
{
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.automation.Automation;
	import mx.automation.AutomationIDPart;
	import mx.automation.IAutomationManager; 
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationObjectHelper;
	import mx.automation.tabularData.MenuBarTabularData;
	import mx.automation.delegates.core.UIComponentAutomationImpl;
	import mx.controls.Menu;
	import mx.controls.MenuBar;
	import mx.controls.menuClasses.MenuBarItem;
	import mx.core.mx_internal;
	import mx.events.MenuEvent;
	import mx.automation.events.MenuShowEvent;
	import mx.controls.menuClasses.IMenuBarItemRenderer;
	import mx.core.EventPriority;
	import mx.core.UIComponent;
	
	use namespace mx_internal;
	
	[Mixin]
	
	/**
	 *  Defines methods and properties required to perform instrumentation for the 
	 *  MenuBar control.
	 * 
	 *  @see mx.controls.MenuBar 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class MenuBarAutomationImpl extends UIComponentAutomationImpl 
	{
		include "../../../core/Version.as";
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Registers the delegate class for a component class with automation manager.
		 *  
		 *  @param root The SystemManger of the application.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public static function init(root:DisplayObject):void
		{
			Automation.registerDelegateClass(MenuBar, MenuBarAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *
		 *  @param obj MenuBar object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function MenuBarAutomationImpl(obj:MenuBar)
		{
			super(obj);
			
			obj.addEventListener(MenuEvent.MENU_SHOW, menuShowHandler,
				false, 0, true);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  menuBar
		//----------------------------------
		
		/**
		 *  @private
		 *  storage for the owner component
		 */
		protected function get menuBar():MenuBar
		{
			return uiComponent as MenuBar;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override public function createAutomationIDPart(
			child:IAutomationObject):Object
		{
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			return help ? help.helpCreateIDPart(uiAutomationObject, child) : null;
		}
		
		/**
		 *  @private
		 */
		override public function createAutomationIDPartWithRequiredProperties(child:IAutomationObject, properties:Array):Object
		{
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			return help ? help.helpCreateIDPartWithRequiredProperties(uiAutomationObject, child,properties) : null;	
		}
		
		/**
		 *  @private
		 */
		override public function resolveAutomationIDPart(part:Object):Array
		{
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			return help ? help.helpResolveIDPart(uiAutomationObject, part) : null;
		}
		
		/**
		 *  @private
		 */
		override public function get numAutomationChildren():int
		{
			var itemCount:int = menuBar.menuBarItems.length;
			
			// add menus present
			var menuCount:int = 0;
			var n:int = menuBar.menus.length;
			for (var i:int = 0; i < n; ++i)
			{
				if (menuBar.menus[i])
					++menuCount;
			}
			
			return itemCount + menuCount;
		}
		
		/**
		 *  @private
		 */
		override public function getAutomationChildAt(index:int):IAutomationObject
		{
			if (index < menuBar.menuBarItems.length)
				return menuBar.menuBarItems[index] as IAutomationObject;
			
			var menuIndex:int = index - menuBar.menuBarItems.length;
			
			// count the menus present and match it with the index
			var menuCount:int = 0;
			var i:int;
			var n:int = menuBar.menus.length;
			for (i = 0; i < n; ++i)
			{   if (menuBar.menus[i])
			{
				if (menuCount == menuIndex)
					break;
				++menuCount;
			}
			}
			
			return menuBar.menus[i] as IAutomationObject;
		}
		
		
		/**
		 * @private
		 */
		override public function getAutomationChildren():Array
		{
			// get menuBarItems
			var childList:Array = new Array();
			var tempArray1:Array = menuBar.menuBarItems;
			var n:int = 0;
			var i:int = 0;
			if (tempArray1)
			{
				n = tempArray1.length;
				for(i = 0; i< n ; i++)
				{
					childList.push(tempArray1[i]);
				}
			}
			
			
			// get  menuBar.menus
			var tempArr:Array =  menuBar.menus;
			if(tempArr)
			{
				n  = tempArr.length;
				for (i= 0; i < n ; i++)
				{
					childList.push(tempArr[i] as  IAutomationObject);
				}
			}
			
			return childList;
		}
		
		/**
		 *  @private
		 */
		override public function get automationTabularData():Object
		{
			return new MenuBarTabularData(uiAutomationObject);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private function menuShowHandler(event:MenuEvent):void
		{
			// if menu is having a parent menu showing is recorded
			// by the parent. 
			if (event.menu.parentMenu)
				return;
			
			if (event.target == uiComponent)
			{
				var itemRenderer:IMenuBarItemRenderer;
				var menus:Array = menuBar.menus;
				
				var n:int = menus.length;
				for (var i:int = 0; i < n; ++i)
				{
					if (menus[i] == event.menu)
					{
						itemRenderer = menus[i].sourceMenuBarItem;
						break;
					}
				}
				
				if (itemRenderer)
				{   
					var msEvent:MenuShowEvent = new MenuShowEvent(MenuShowEvent.MENU_SHOW, itemRenderer);
					recordAutomatableEvent(msEvent);
				}
			}
		}
		
		/**
		 *  @private
		 *  Replays the event specified by the parameter if possible.
		 *
		 *  @param interaction The event to replay.
		 * 
		 *  @return Whether or not a replay was successful.
		 */
		override public function replayAutomatableEvent(interaction:Event):Boolean
		{
			if (interaction is MenuShowEvent)
			{
				var me:MenuShowEvent = MenuShowEvent(interaction);
				switch (interaction.type)
				{
					case MenuShowEvent.MENU_SHOW:
					{
						var menuBarItem:UIComponent = me.itemRenderer as UIComponent;
						menuBarItem.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER));
						if (menuBar.selectedIndex == -1)
						{
							menuBarItem.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
						}
						return true;
					}
				}
			}
			
			return super.replayAutomatableEvent(interaction);
		}
		
	}
	
}
