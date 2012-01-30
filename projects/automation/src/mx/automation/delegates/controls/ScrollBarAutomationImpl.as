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
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.automation.Automation;
	import mx.automation.IAutomationObjectHelper;
	import mx.automation.delegates.core.UIComponentAutomationImpl;
	import mx.controls.scrollClasses.ScrollBar;
	import mx.core.mx_internal;
	import mx.events.ScrollEvent;
	import mx.events.ScrollEventDetail;
	
	use namespace mx_internal;
	
	[Mixin]
	/**
	 * 
	 *  Defines methods and properties required to perform instrumentation for the 
	 *  ScrollBar class.
	 * 
	 *  @see mx.controls.scrollClasses.ScrollBar 
	 *
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class ScrollBarAutomationImpl extends UIComponentAutomationImpl 
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
			Automation.registerDelegateClass(ScrollBar, ScrollBarAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 * @param obj ScrollBar object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function ScrollBarAutomationImpl(obj:ScrollBar)
		{
			super(obj);
			
			obj.addEventListener(ScrollEvent.SCROLL, scrollHandler, false, -1, true);
		}
		
		/**
		 *  @private
		 *  storage for the owner component
		 */
		protected function get scroll():ScrollBar
		{
			return uiComponent as ScrollBar;
		}
		
		/**
		 *  @private
		 */
		private var previousEvent:ScrollEvent;
		
		//----------------------------------
		//  automationValue
		//----------------------------------
		
		/**
		 *  @private
		 */
		override public function get automationValue():Array
		{
			return [ scroll.scrollPosition.toString() ];
		}
		
		/**
		 *  @private
		 *  Replays ScrollEvents.
		 *  ScrollEvents are replayed by simply setting the
		 *  <code>verticalScrollPosition</code> or
		 *  <code>horizontalScrollPosition</code> properties of the instance.
		 */
		override public function replayAutomatableEvent(interaction:Event):Boolean
		{
			if (interaction is ScrollEvent)
			{
				var scrollEvent:ScrollEvent = ScrollEvent(interaction);
				var targetObject:EventDispatcher = null;
				var mouseEvent:MouseEvent = new MouseEvent(MouseEvent.CLICK);
				if (scrollEvent.detail == scroll.lineMinusDetail)
					targetObject = scroll.upArrow;
				else if (scrollEvent.detail == scroll.linePlusDetail)
					targetObject = scroll.downArrow;
				else if (scrollEvent.detail == scroll.pageMinusDetail)
				{
					targetObject = uiComponent;
					mouseEvent.localX = 0;
					mouseEvent.localY = 0;
				}
				else if (scrollEvent.detail == scroll.pagePlusDetail)
				{
					targetObject = uiComponent;
					mouseEvent.localX = scroll.width;
					mouseEvent.localY = scroll.height;
				}
				else if (scrollEvent.detail == ScrollEventDetail.THUMB_POSITION)
				{
					targetObject = scroll.scrollThumb;
					scroll.scrollPosition = scrollEvent.position;
				}
				else if (scrollEvent.detail == ScrollEventDetail.AT_TOP ||
					scrollEvent.detail == ScrollEventDetail.AT_LEFT ||
					scrollEvent.detail == ScrollEventDetail.AT_RIGHT ||
					scrollEvent.detail == ScrollEventDetail.AT_BOTTOM)
				{
					targetObject = scroll.scrollThumb;
					scroll.scrollPosition = scrollEvent.position;
				}
				if (targetObject)
				{
					var help:IAutomationObjectHelper = Automation.automationObjectHelper;
					help.replayClick(targetObject, mouseEvent);
				}
				scroll.scrollPosition = scrollEvent.position;
				return true;
			}
			else
			{
				return super.replayAutomatableEvent(interaction);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private function scrollHandler(event:ScrollEvent):void
		{ 
			if (!previousEvent || previousEvent.delta != event.delta ||
				previousEvent.detail != event.detail ||
				previousEvent.direction != event.direction ||
				previousEvent.position != event.position ||
				previousEvent.type != event.type)
			{
				recordAutomatableEvent(event);
				previousEvent = event.clone() as ScrollEvent;
			}
		}
		
	}
}