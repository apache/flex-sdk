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
    import flash.ui.Keyboard;

    import mx.core.IFlexModuleFactory;
    import mx.core.IVisualElement;
    import mx.events.FlexEvent;
    import mx.styles.CSSStyleDeclaration;
    import mx.styles.IStyleManager2;
    import mx.styles.StyleManager;

    import spark.components.List;
    import spark.events.IndexChangeEvent;

    import avmplus.getQualifiedClassName;

    import spark.events.MenuEvent;
    import spark.skins.MenuBarSkin;

	/**
	 * Plain simple MenuBar class, based upon list.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10.1
	 *  @playerversion AIR 2.5
	 *  @productversion Flex 4.5
	 */
	[Event(name="selected", type="spark.events.MenuEvent")]
	[Event(name="checked", type="spark.events.MenuEvent")]
    /**
	 * Note : works with both Horizontal and Vertical Layouts
	 */
	/**
	 * @author Bogdan Dinu (http://www.badu.ro)
	 */
    public class MenuBar extends List
    {
		/**
		 * Constructor, we don't use virtual layout
		 */
		public function MenuBar()
		{
			super();
			useVirtualLayout = false;
		}
		/**
		 * Overriden because we don't want to dispatch change event directly, but forward it to MenuEvent
		 */
        override public function dispatchEvent(e:Event):Boolean
        {
            if (e.type == IndexChangeEvent.CHANGE && e is IndexChangeEvent && !(e is MenuEvent))
            {
                dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
                return true;
            }
            return super.dispatchEvent(e);
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
				(renderer as IListItemRenderer).listOwner = this;
			}
		}
		/**
		 * this gets called by child to restore focus to us or to change the selected index
		 */
		public function keyDownInChild(e:KeyboardEvent):void
		{
			keyDownHandler(e);
		}
		/**
		 * Key down handler for handling key navigation
		 */
		override protected function keyDownHandler(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.DOWN)
			{
				if (selectedIndex < 0)
				{
					selectedIndex = 0;
				}
			}
			else if (e.keyCode == Keyboard.UP)
			{
				if (selectedIndex >= 0)
				{
					selectedIndex = -1;
					setFocus();
				}
			}
			else
			{
				super.keyDownHandler(e);
			}
			//we are passing the focus to our child
			if (selectedIndex >= 0)
			{
				var item : MenuCoreItemRenderer = dataGroup.getElementAt(selectedIndex) as MenuCoreItemRenderer;
				if (item)
				{
					item.setFocus();
				}
			}
		}
    }
}
