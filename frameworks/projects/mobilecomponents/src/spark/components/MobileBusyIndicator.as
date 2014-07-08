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

package components
{
	import flash.events.Event;
	import mx.core.IUIComponent;
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	import mx.states.State;
	import spark.components.supportClasses.SkinnableComponent;
	
	[SkinState("rotatingState")]
	[SkinState("notRotatingState")]
	
	public class MobileBusyIndicator extends SkinnableComponent
	{
		private var effectiveVisibility:Boolean = false;
		private var effectiveVisibilityChanged:Boolean = true;
		
		public function BusyIndicator()
		{
			super();
			// Listen to added to stage and removed from stage.
			// Start rotating when we are on the stage and stop
			// when we are removed from the stage.
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
			states = 	[
							new State({name:"notRotatingState"}),
							new State({name:"rotatingState"})
						];
		}
		
		override protected function getCurrentSkinState():String
		{
			return currentState;
		} 
		
		private function addedToStageHandler(event:Event):void
		{
			// Check our visibility here since we haven't added
			// visibility listeners yet.
			computeEffectiveVisibility();
			
			if (canRotate())
				currentState = "rotatingState";
			
			addVisibilityListeners();
			invalidateSkinState();
		}
		
		private function removedFromStageHandler(event:Event):void
		{
			currentState = "notRotatingState";
			
			removeVisibilityListeners();
			invalidateSkinState();
		}
		
		private function computeEffectiveVisibility():void
		{
			
			// Check our design layer first.
			if (designLayer && !designLayer.effectiveVisibility)
			{
				effectiveVisibility = false;
				return;
			}
			
			// Start out with true visibility and enablement
			// then loop up parent-chain to see if any of them are false.
			effectiveVisibility = true;
			var current:IVisualElement = this;
			
			while (current)
			{
				if (!current.visible)
				{
					if (!(current is IUIComponent) || !IUIComponent(current).isPopUp)
					{
						// Treat all pop ups as if they were visible. This is to 
						// fix a bug where the BusyIndicator does not spin when it 
						// is inside modal popup. The problem is in we do not get 
						// an event when the modal window is made visible in 
						// PopUpManagerImpl.fadeInEffectEndHandler(). When the modal
						// window is made visible, setVisible() is passed "true" so 
						// as to not send an event. When do get events when the 
						// non-modal windows are popped up. Only modal windows are
						// a problem.
						// The downside of this fix is BusyIndicator components that are
						// inside of hidden, non-modal, popup windows will paint themselves
						// on a timer.
						effectiveVisibility = false;
						break;                  
					}
				}
				
				current = current.parent as IVisualElement;
			}
		}
		
		/**
		 *  The BusyIndicator can be rotated if it is both on the display list and 
		 *  visible.
		 * 
		 *  @returns true if the BusyIndicator can be rotated, false otherwise.
		 */ 
		private function canRotate():Boolean
		{
			if (effectiveVisibility && stage != null)
				return true;
			
			return false;
		}
		
		
		/**
		 *  @private
		 *  Add event listeners for SHOW and HIDE on all the ancestors up the parent chain.
		 *  Adding weak event listeners just to be safe.
		 */
		private function addVisibilityListeners():void
		{
			var current:IVisualElement = this.parent as IVisualElement;
			while (current)
			{
				// add visibility listeners to the parent
				current.addEventListener(FlexEvent.HIDE, visibilityChangedHandler, false, 0, true);
				current.addEventListener(FlexEvent.SHOW, visibilityChangedHandler, false, 0, true);
				
				current = current.parent as IVisualElement;
			}
		}
		
		/**
		 *  @private
		 *  Remove event listeners for SHOW and HIDE on all the ancestors up the parent chain.
		 */
		private function removeVisibilityListeners():void
		{
			var current:IVisualElement = this;
			while (current)
			{
				current.removeEventListener(FlexEvent.HIDE, visibilityChangedHandler, false);
				current.removeEventListener(FlexEvent.SHOW, visibilityChangedHandler, false);
				
				current = current.parent as IVisualElement;
			}
		}
		
		/**
		 *  @private
		 *  Event call back whenever the visibility of us or one of our ancestors 
		 *  changes
		 */
		private function visibilityChangedHandler(event:FlexEvent):void
		{
			effectiveVisibilityChanged = true;
			invalidateProperties();
		}

		
	}
}