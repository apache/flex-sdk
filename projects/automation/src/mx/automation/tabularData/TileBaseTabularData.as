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
package mx.automation.tabularData
{
	
	import mx.automation.AutomationManager;
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationTabularData;
	import mx.collections.CursorBookmark;
	import mx.collections.errors.ItemPendingError;
	import mx.controls.listClasses.TileBase;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.core.mx_internal;
	use namespace mx_internal;
	
	/**
	 *  @private
	 */
	public class TileBaseTabularData extends ListBaseTabularData
	{
		
		private var list:TileBase;
		
		/**
		 *  Constructor
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function TileBaseTabularData(l:TileBase)
		{
			super(l);
			
			list = l;
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		override public function getAutomationValueForData(data:Object):Array
		{
			var item:IListItemRenderer = list.getListVisibleData()[list.getItemUID(data)];
			
			if (item == null)
			{
				item = list.getMeasuringRenderer(data);
				list.setupRendererFromData(item, data);
			}
			
			var delegate:IAutomationObject = (item as IAutomationObject);
			return [ delegate.automationValue.join(" | ") ];
		}
	}
}
