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

package com.adobe.viewsource
{

import flash.display.InteractiveObject;
import flash.events.ContextMenuEvent;
import flash.events.Event;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;

/**
 *  The ViewSource class adds support for the 
 *  "View Source" context menu item.
 *  If you set the <code>viewSourceURL</code> property of the application container
 *  to the URL of your source code, 
 *  the user can view the source code by selecting the 
 *  "View Source" context menu item.
 *
 *  @see spark.components.Application#viewSourceURL
 *  @see mx.core.Application#viewSourceURL
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class ViewSource
{
	/**
	 *  Adds a "View Source" context menu item
	 *  to the context menu of the given object.
	 *  Creates a context menu if none exists.
	 *
	 *  @param obj The object to attach the context menu item to.
	 *
	 *  @param url The URL of the source viewer that the "View Source"
	 *  item should open in the browser.
	 *
	 *  @param hideBuiltIns Optional, defaults to true.
	 *  If true, and no existing context menu is attached
	 *  to the given item, then when we create the context menu,
	 *  we hide all the hideable built-in menu items.
	 */
	public static function addMenuItem(obj:InteractiveObject, url:String,
									   hideBuiltIns:Boolean = true):void
	{
		if (obj.contextMenu == null)
		{
			obj.contextMenu = new ContextMenu();
			if (hideBuiltIns)
				obj.contextMenu.hideBuiltInItems();
		}
	
		var item:ContextMenuItem = new ContextMenuItem("View Source");
		
		item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, 
			function(event:ContextMenuEvent):void
			{
				if (event.target == item)
					navigateToURL(new URLRequest(url), "_blank");
			}
		);
		
		obj.contextMenu.customItems.push(item);
	}
}
	
}
