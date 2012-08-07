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
package renderers
{
	import assets.*;
	
	import flash.events.Event;
	
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	
	import spark.components.IconItemRenderer;
	import spark.components.supportClasses.StyleableTextField;
	import spark.core.ContentCache;
	import spark.primitives.BitmapImage;
	
	use namespace mx_internal;
	
	/**
	 * An extremely simple subclass of LabelItemRenderer designed so Mustella tests
	 * can key off of specific events.
	 * 
	 * This uses a custom iconDisplayClass that fires an event when the icon of a 
	 * renderer is loaded and ready for assertion.
	 * 
	 * For example:
	 * 
	 * <RunCode code="application.navigator.activeView.list.itemRenderer = new ClassFactory(MIIR_scale)"
	 *     waitTarget="navigator.activeView.list" waitEvent="itemRenderer0IconReady" />
	 * 
	 * @see renderers.InstrumentedLabelItemRenderer for more documentation
	 */
	public class InstrumentedIconItemRenderer extends IconItemRenderer
	{
		
		public function InstrumentedIconItemRenderer():void
		{
			// use an instrumented subclass of BitmapImage
			iconDisplayClass = InstrumentedBitmapImage;
            
            // don't use any caching so tests are atomic
            // TODO: Is this dangerous to have mustella  + manual act differently here?
            if (!CONFIG::skaha)
                iconContentLoader = null;
		}
		
		/**
		 * @see renderers.InstrumentedLabelItemRenderer
		 */
		override public function set data(value:Object):void
		{
            super.data = value;
            // Only fire the notification event if the data isn't null because 
            // when the data is null we are in the old renderer.  
            // See http://bugs.adobe.com/jira/browse/SDK-29034
            if (data != null){
                var setDataEventString:String = "itemRenderer" + itemIndex + "SetData"; 
                owner.dispatchEvent(new Event(setDataEventString));
                trace(setDataEventString);
            }
		}
        
        /** Expose a way to get at the protected iconDisplay object*/
        public function getIconDisplay():BitmapImage
        {
            return iconDisplay;
        }
        
        /** Expose a way to get at the protected decoratorDisplay object*/
        public function getDecoratorDisplay():BitmapImage
        {
            return decoratorDisplay;
        }
        
        /** Expose a way to get at the protected labelDisplay object*/
        public function getLabelDisplay():StyleableTextField
        {
            return labelDisplay;
        }
        
        /** Expose a way to get at the protected messageDisplay object*/
        public function getMessageDisplay():StyleableTextField
        {
            return messageDisplay;
        }
	}
}