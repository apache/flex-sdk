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
package spark.components
{
    import spark.components.listClasses.IListItemRenderer;
    import spark.components.itemRenderers.*;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.utils.getQualifiedClassName;

	import mx.core.IFlexModuleFactory;
	import mx.core.IVisualElement;
	import mx.events.FlexMouseEvent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.IStyleManager2;
	import mx.styles.StyleManager;

	import spark.components.IItemRenderer;
	import spark.components.List;
	import spark.events.IndexChangeEvent;

	import spark.events.MenuEvent;
	import spark.skins.MenuSkin;

	/**
	 * Plain simple Menu class, based upon list.
	 * It is used as standalone and in combination with MenuBar
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10.1
	 *  @playerversion AIR 2.5
	 *  @productversion Flex 4.5
	 */
	[Event(name="selected", type="spark.events.MenuEvent")]
	[Event(name="checked", type="spark.events.MenuEvent")]
	/**
	 *  @langversion 3.0
	 *  @playerversion Flash 10.1
	 *  @playerversion AIR 2.5
	 *  @productversion Flex 4.5
	 */
	/**
	 * @author Bogdan Dinu (http://www.badu.ro)
	 */
	public class Menu extends List
	{
		protected var _storedSelectedIndex : int = -1;
		protected var _ignoreFocus : Boolean;
		protected var _openedItem : MenuCoreItemRenderer;
		/**
		 * Constructor
		 *
		 * We never use virtual layout, since it's not needed
		 * requireSelection is set to false in order to allow checkable items to be checked
		 * If you remove requireSelection the checkable items will work, but
		 * the menu will close immediately after clicking that item
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function Menu()
		{
			super();
			useVirtualLayout = false;
			requireSelection = false;
		}
		/**

		 **/
		protected var _parentMenu : List;
		public function get parentMenu():List
		{
			return _parentMenu;
		}
		public function set parentMenu(value:List):void
		{
			_parentMenu = value;
		}
		/**
		 * Sets for every item renderer the instance of this,
		 * so we can dispatch events and access properties like labelField
		 */
		override public function updateRenderer(renderer:IVisualElement, itemIndex:int, data:Object):void
		{
			super.updateRenderer(renderer, itemIndex, data);
			if (renderer is IListItemRenderer)
			{
				(renderer as IListItemRenderer).listOwner =  this;
			}
		}
		/**
		 * From keyboard navigation, called by a child to pass over focus and close popup on opened item
		 */
		public function keyDownInChild(e:KeyboardEvent):void
		{
			if (parentMenu is Menu)
			{
				_openedItem.popup.displayPopUp = false;
			}
			closeSelectedItemRenderer();
			_ignoreFocus = true;
			setFocus();
		}
		/**
		 * From keyboard navigation, checks if submenu is present
		 */
		protected function get selectedItemRendererShouldOpen():Boolean
		{
			if (selectedIndex < 0) return false;
			return (dataGroup.getElementAt(selectedIndex) as MenuCoreItemRenderer).dataProvider.length > 0;
		}
		/**
		 * From keyboard navigation, when we need to close a submenu and cleanup
		 */
		protected function closeSelectedItemRenderer():void
		{
			_openedItem.selected = false;
			_openedItem.setHovered ( false );
			_openedItem = null;
		}
		/**
		 * From keyboard navigation, when we are entitled to open a submenu
		 */
		protected function openAndFocusSelectedItemRenderer():void
		{
			var item : MenuCoreItemRenderer = dataGroup.getElementAt(selectedIndex) as MenuCoreItemRenderer;
			if (item)
			{
				_openedItem = item;
				item.selected = false;
				item.setHovered ( true );
			}
		}
		/**
		 * From keyboard navigation, when submenu closes and parents need focus
		 */
		protected function closeAndFocusParent(e:KeyboardEvent):void
		{
			parentMenu.setFocus();
			if (parentMenu is MenuBar)
			{
				(parentMenu as MenuBar).keyDownInChild(e);
			}
			else if (parentMenu is Menu)
			{
				(parentMenu as Menu).keyDownInChild(e);
			}
		}
		/**
		 * From keyboard navigation, we check if it's necessary to open a submenu
		 */
		public function openIfNecessary():void
		{
			if (selectedItemRendererShouldOpen)
			{
				if (!_openedItem)
				{
					openAndFocusSelectedItemRenderer();
				}
			}
		}
		/**
		 * Handle navigation, up and down arrow keys and enter or space selects
		 * Escape key, closes menu
		 *
		 * Doesn't work very very well, probably the focus manager is sometimes
		 * too slow for Spark components.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		override protected function keyDownHandler(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case Keyboard.RIGHT:
					selectedIndex = _storedSelectedIndex;
					if (_openedItem)
					{
						_openedItem.subMenu.selectedIndex = 0;
						_openedItem.subMenu.setFocus();
						(_openedItem.subMenu as Menu).openIfNecessary();
					}
					else	if (selectedItemRendererShouldOpen)
					{
						if (!_openedItem)
						{
							openAndFocusSelectedItemRenderer();
						}
					}
					else
					{
						if (parentMenu is MenuBar)
						{
							closeAndFocusParent(e);
						}
					}
					break;
				case Keyboard.LEFT:
					closeAndFocusParent(e);
					break;
				case Keyboard.UP:
					selectedIndex = _storedSelectedIndex;
					if (_openedItem)
					{
						closeSelectedItemRenderer();
					}
					if (selectedIndex > 0)
					{
						do
						{
							selectedIndex--;
						} while (dataProvider.getItemAt(selectedIndex).@separator.toString() == "true");
					}
					_storedSelectedIndex = selectedIndex;
					if (selectedItemRendererShouldOpen)
					{
						if (!_openedItem)
						{
							openAndFocusSelectedItemRenderer();
						}
					}
					break;
				case Keyboard.DOWN:
					selectedIndex = _storedSelectedIndex;
					if (_openedItem)
					{
						closeSelectedItemRenderer();
					}
					if (selectedIndex < dataProvider.length - 1)
					{
						do
						{
							selectedIndex++;
						} while (dataProvider.getItemAt(selectedIndex).@separator.toString() == "true");
					}
					_storedSelectedIndex = selectedIndex;
					if (selectedItemRendererShouldOpen)
					{
						if (!_openedItem)
						{
							openAndFocusSelectedItemRenderer();
						}
					}
					break;
				case Keyboard.ESCAPE:
					dispatchEvent(new FlexMouseEvent(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, false, false, 0, 0, null, false, false, false, false, 0));
					break;
				case Keyboard.ENTER:
				case Keyboard.SPACE:
					if (selectedItem.@isCheckable.toString() == 'true')
					{
						if (dataProvider.getItemAt(selectedIndex).@isChecked == 'true')
						{
							dataProvider.getItemAt(selectedIndex).@isChecked = 'false';
						}
						else
						{
							dataProvider.getItemAt(selectedIndex).@isChecked = 'true';
						}
						dispatchEvent(new MenuEvent(MenuEvent.CHECKED, false, false, this, dataProvider.getItemAt(selectedIndex)));
					}
					else
					{
						dispatchEvent(new MenuEvent(MenuEvent.SELECTED, false, false,  this, selectedItem));
					}
					break;
				default:
					super.keyDownHandler(e);
					break;
			}
		}
		/**
		 * Overriden to implement checkable behavior.
		 * If an item is checkable, we alter data and dispatch the event
		 * If not, we just using the super method
		 */
		override protected function item_mouseDownHandler(event:MouseEvent):void
		{
			var canCallSuper : Boolean = true;
			if (event.currentTarget is IItemRenderer)
			{
				var itemRendererTarget : IItemRenderer = (event.currentTarget as IItemRenderer);

				if (itemRendererTarget.data.@isCheckable.toString() == 'true')
				{
					canCallSuper = false;
					if (itemRendererTarget.data.@isChecked == 'true')
					{
						itemRendererTarget.data.@isChecked = 'false';
					}
					else
					{
						itemRendererTarget.data.@isChecked  = 'true';
					}
					dispatchEvent(new MenuEvent(MenuEvent.CHECKED, false, false, this, itemRendererTarget.data));
				}
			}
			if (canCallSuper)
			{
				super.item_mouseDownHandler(event);
			}
		}
		/**
		 * We are supposed to dispatch MenuEvent instead of IndexChangeEvent
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		override public function dispatchEvent(e:Event):Boolean
		{
			if (!(e is MenuEvent))
			{
				if (e is IndexChangeEvent)
				{
					if (selectedItem)
					{
						if (selectedItem.@separator.toString() == "true")
						{
							selectedIndex = -1;
							return true;
						}
						if (selectedItem.children().length() > 0)
						{
							selectedIndex = -1;
							return true;
						}
						if (e.type == IndexChangeEvent.CHANGE)
						{
							return super.dispatchEvent(new MenuEvent(MenuEvent.SELECTED, e.bubbles, true, this, selectedItem));
						}
					}
				}
			}
			return super.dispatchEvent(e);
		}
	}
}
