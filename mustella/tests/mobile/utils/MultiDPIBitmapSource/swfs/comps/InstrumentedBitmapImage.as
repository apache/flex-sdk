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
package comps
{
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	
	import spark.components.IItemRenderer;
	import spark.components.IconItemRenderer;
	import spark.primitives.BitmapImage;
	
	/**
	 * A very simple subclass of BitmapImage that fires an event when the
	 * icon is finished loading, whether that image is being loaded in or
	 * coming from a cache.
	 * 
	 * Designed for use in Mustella in a subclass of IconItemRenderer.  Set 
	 * the iconDisplayClass property in your renderers constructor to enable
	 * this functionality.
	 * 
	 * This fires an event of the form "itemRenderer0IconReady" against the
	 * owner of the item renderer.
	 */
	public class InstrumentedBitmapImage extends BitmapImage
	{
		public function InstrumentedBitmapImage()
		{
			super();
			// listen for when the image is changing
			addEventListener(FlexEvent.READY, fireIconReady);
		}
		
		/**
		 * Fire an event against the owner of the renderer
		 */
		private function fireIconReady(e:Event):void 
		{
			var parentItemRenderer:IconItemRenderer = parent as IconItemRenderer;
			var itemIndex:Number = parentItemRenderer.itemIndex;

			var iconReadyEventString:String = "itemRenderer" + itemIndex;
            
            if (source != parentItemRenderer.iconPlaceholder)
                iconReadyEventString += "IconReady";
            else
                iconReadyEventString += "IconPlaceholderReady";
            
			trace(iconReadyEventString);
			parentItemRenderer.owner.dispatchEvent(new Event(iconReadyEventString));
            
		}
	}
}