////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.automation.delegates.controls 
{
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem; 
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.automation.Automation;
	import mx.automation.AutomationConstants;
	import mx.automation.IAutomationManager;
	import mx.automation.IAutomationObject;
	import mx.automation.events.AutomationFlexNativeMenuEvent;
	import mx.controls.FlexNativeMenu;
	import mx.core.mx_internal;
	import mx.events.FlexNativeMenuEvent;
	
	use namespace mx_internal;
	
	[Mixin]
	/**
	 * 
	 *  Defines methods and properties required to perform instrumentation for the 
	 *  Flex Native Menu.
	 * 
	 *  @see mx.controls.FlexNativeMenu 
	 *
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	public class FlexNativeMenuAutomationImpl  extends EventDispatcher
		implements IAutomationObject 
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
		 *  @productversion Flex 4
		 */
		public static function init(root:DisplayObject):void
		{
			Automation.registerDelegateClass(FlexNativeMenu, FlexNativeMenuAutomationImpl);
		}   
		
		/**
		 *  Constructor.
		 *  @param obj FlexNativeMenu object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function FlexNativeMenuAutomationImpl(obj:FlexNativeMenu)
		{
			super();
			menu = obj;
			obj.addEventListener(FlexNativeMenuEvent.ITEM_CLICK, itemClickHandler);
			obj.addEventListener(FlexNativeMenuEvent.MENU_SHOW, menuShowHandler);
		}
		
		//--------------------------------------------------------------------------
		//
		// Properties
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//---------------------------------
		//  automationEnabled
		//---------------------------------
		
		/**
		 *  @private
		 */
		public function get automationEnabled():Boolean
		{
			return true;
		}
		
		//---------------------------------
		//  automationOwner
		//---------------------------------
		
		/**
		 *  @private
		 */
		public function get automationOwner():DisplayObjectContainer
		{
			return null;
		}
		
		//---------------------------------
		//  automationParent
		//---------------------------------
		
		/**
		 *  @private
		 */
		public function get automationParent():DisplayObjectContainer
		{
			return null;
		}
		
		//---------------------------------
		//  automationVisible
		//---------------------------------
		
		/**
		 *  @private
		 */
		public function get automationVisible():Boolean
		{
			return true;
		}
		
		//---------------------------------
		// automationDelegate
		//---------------------------------
		
		/**
		 *  @private
		 */
		public function set automationDelegate(value:Object):void
		{
			Automation.automationDebugTracer.traceMessage("FlexNativeMenuAutomationImpl", "set automationDelegate()", 
				AutomationConstants.invalidDelegateMethodCall);
		}
		
		/**
		 *  @private
		 */
		public function get automationDelegate():Object
		{
			Automation.automationDebugTracer.traceMessage("FlexNativeMenuAutomationImpl", "get automationDelegate()", 
				AutomationConstants.invalidDelegateMethodCall);
			return this;
		}
		
		//----------------------------------
		//  automationName
		//----------------------------------
		/**
		 * @private
		 */
		private var _automationName:String = "";  
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function get automationName():String
		{
			return _automationName;
		}
		
		/**
		 *  @private
		 */
		public function set automationName(value:String):void
		{
			_automationName = value;
		}
		
		//----------------------------------
		//  automationTabularData
		//----------------------------------
		
		/**
		 *  @private
		 */
		public function get automationTabularData():Object
		{
			return null;    
		}
		
		//----------------------------------
		//  automationValue
		//----------------------------------
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function get automationValue():Array
		{
			return [ automationName ];
		}
		
		//----------------------------------
		//  menu
		//----------------------------------
		/**
		 *  @private
		 */
		protected var _menu:FlexNativeMenu;
		
		/**
		 *  Returns the component instance associated with this delegate instance.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function get menu():FlexNativeMenu
		{
			return _menu;
		}
		
		/**
		 *  @private
		 */
		public function set menu(obj:FlexNativeMenu):void
		{
			_menu = obj as FlexNativeMenu;
		}
		
		//----------------------------------
		//  numAutomationChildren
		//----------------------------------
		
		/**
		 *  @private
		 */
		public function get numAutomationChildren():int
		{
			return 0;
		}
		
		//----------------------------------
		//  owner
		//----------------------------------
		/**
		 *  @private
		 */
		public function get owner():DisplayObjectContainer
		{
			return (menu as IAutomationObject).automationOwner;
		}
		
		
		//----------------------------------
		//  showInAutomationHierarchy
		//----------------------------------
		/**
		 *  @private
		 */
		public function get showInAutomationHierarchy():Boolean
		{
			Automation.automationDebugTracer.traceMessage("FlexNativeMenuAutomationImpl", "get showInAutomationHierarchy()", 
				AutomationConstants.invalidDelegateMethodCall);
			return true;
		}
		
		/**
		 *  @private
		 */
		public function set showInAutomationHierarchy(value:Boolean):void
		{
			Automation.automationDebugTracer.traceMessage("FlexNativeMenuAutomationImpl", "set showInAutomationHierarchy()", 
				AutomationConstants.invalidDelegateMethodCall);
			if(menu is IAutomationObject)
				IAutomationObject(menu).showInAutomationHierarchy = value;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  Replays interactions on the FlexNativeMenu.
		 *  Dispatches Event.SELECT on the NativeMenuItem
		 *  if the interaction is selection
		 *  Dispatches Event.DISPLAYING on the NativeMenu
		 *  if the interaction is open
		 *
		 *  @param event ReplayableClickEvent to replay.
		 */
		public function replayAutomatableEvent(event:Event):Boolean
		{
			var menuEvent:AutomationFlexNativeMenuEvent = event as AutomationFlexNativeMenuEvent;
			if (!menuEvent)
				return false;
			var args:String = menuEvent.args;
			
			// separate these to indivual menu items
			var menuNames:Array = args.split(" ::-:: ");
			
			var count:int = menuNames.length;
			var index:int = 0;
			var menuObj:NativeMenu = menu.nativeMenu;
			
			if (event.type == AutomationFlexNativeMenuEvent.ITEM_CLICK)
			{
				if (args.length != 0)
				{
					// get the last NativeMenu
					while ((menuObj) && (index < count-1))
					{
						menuObj = getNativeMenuByName(menuObj, menuNames[index]);
						index ++;
					} 
					
					// we got the last menuObj.
					// we need the menu item with the required name and its index
					if (menuObj)
					{
						var name:String = menuNames[menuNames.length-1];
						
						// get the menu items of th last menu
						var menuItems:Array = menuObj.items;
						var count1:int = menuItems.length;
						var index1:int = 0;
						var menuFound:Boolean = false;
						while ((!menuFound) && (index1 < count1))
						{
							if((menuItems[index1] as NativeMenuItem).label == name)
								menuFound = true;
								
							else	
								index1 ++;	
						}
						
						//create the SELECT event and dispatch the event on the menuitem
						if (menuFound)
						{
							var requiredMenuItem:NativeMenuItem = menuItems[index1] as NativeMenuItem;
							var requiredMenu:NativeMenu = menuObj;
							requiredMenuItem.dispatchEvent(new Event(flash.events.Event.SELECT));
							return true;						
						}
					}	
				}
			}
			else if(event.type == AutomationFlexNativeMenuEvent.MENU_SHOW)
			{
				if (args.length != 0)
				{
					while ((menuObj) && (index < count))
					{
						menuObj = getNativeMenuByName(menuObj, menuNames[index]);
						index ++;
					} 
					
					// we got the last menuObj. Dispatch DISPLAYING event on this menu
					if (menuObj)
					{
						menuObj.dispatchEvent(new Event(Event.DISPLAYING));
						return true;
					}
				}
			}
			return false;
		}
		
		private function getNativeMenuByName(menuObj:NativeMenu, name:String):NativeMenu
		{
			var menuItems:Array = menuObj.items;
			var count:int = menuItems.length;
			var index:int = 0;
			var menuFound:Boolean = false;
			while ((!menuFound) && (index < count))
			{
				if ((menuItems[index] as NativeMenuItem).label == name)
					menuFound = true;
					
				else	
					index ++;	
			}
			
			if (menuFound)
				return (menuItems[index] as NativeMenuItem).submenu;
			else
				return null;
		}
		
		private function getCompleteLabel(obj:NativeMenu):String
		{
			// we get the native menu , and the menu item. 
			// to replay we need the complete information about the heirarchy of the item, 
			// till the current selected menu item
			var completeLabel:String = getMenuLabel(obj);
			var parentObj:NativeMenu = obj.parent;
			
			while ((parentObj)&&(parentObj.parent))
			{
				completeLabel = 	getMenuLabel(parentObj) + " ::-:: " +completeLabel;
				parentObj = parentObj.parent;
			}
			
			return completeLabel;
		}
		
		private function getMenuLabel(item:NativeMenu):String
		{
			// nativemenu does not have the label. the menu item corresponding to that has the label.
			// so we need to get the menu item corresponding to this menu.
			
			var parentMenu:NativeMenu = item.parent;
			if (!parentMenu)
				return "";
			var items:Array = parentMenu.items;
			var count:int = items.length;
			var index:int = 0;
			var menuFound:Boolean = false;
			var menuLabel:String = "";
			while ((!menuFound) && (index < count))
			{
				if ((items[index] as NativeMenuItem).submenu == item)
				{
					menuFound = true;
					menuLabel = (items[index] as NativeMenuItem).label;
				}
				index ++;
			}
			
			return menuLabel;
		}
		
		/**
		 *  @private
		 */
		public function createAutomationIDPart(child:IAutomationObject):Object
		{
			return null;
		}
		
		public function createAutomationIDPartWithRequiredProperties(child:IAutomationObject, properties:Array):Object
		{
			return null;
		}
		
		/**
		 *  @private
		 */
		public function resolveAutomationIDPart(criteria:Object):Array
		{
			return [];
		}    
		
		/**
		 *  @private
		 */
		public function getAutomationChildAt(index:int):IAutomationObject
		{
			return null;
		}
		
		/**
		 *  @private
		 */
		public function getAutomationChildren():Array
		{
			return null;
		}   
		
		//-------------------------------------------------------------------------------------------
		//
		//    Event Handlers
		//
		//-------------------------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		protected function itemClickHandler(event:FlexNativeMenuEvent):void 
		{
			var am:IAutomationManager = Automation.automationManager;
			if (am && am.recording)
			{
				var automatedEvent:AutomationFlexNativeMenuEvent = new AutomationFlexNativeMenuEvent(AutomationFlexNativeMenuEvent.ITEM_CLICK);
				var obj:NativeMenu = event.nativeMenu;
				automatedEvent.args = getCompleteLabel(obj) + " ::-:: " + event.label;
				am.recordAutomatableEvent(menu as IAutomationObject, automatedEvent, false);
			}
		}
		
		/**
		 *  @private
		 */
		protected function menuShowHandler(event:FlexNativeMenuEvent):void 
		{
			var am:IAutomationManager = Automation.automationManager;
			if (am && am.recording)
			{
				var automatedEvent:AutomationFlexNativeMenuEvent = new AutomationFlexNativeMenuEvent(AutomationFlexNativeMenuEvent.MENU_SHOW);
				var obj:NativeMenu = event.nativeMenu;
				automatedEvent.args = getCompleteLabel(obj);
				am.recordAutomatableEvent(menu as IAutomationObject, automatedEvent, false);
			}
		}
	}
	
}