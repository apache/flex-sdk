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
	import flash.events.Event;
	
	import mx.core.DesignLayer;
	import mx.core.IUIComponent;
	import mx.core.IVisualElement;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	import mx.states.State;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	[SkinState("rotatingState")]
	[SkinState("notRotatingState")]

//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  The interval to delay, in milliseconds, between rotations of this
 *  component. Controls the speed at which this component spins. 
 * 
 *  @default 50
 * 
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 *   
 */ 
[Style(name="rotationInterval", type="Number", format="Time", inherit="no")]

/**
 *  Color of the spokes of the spinner.
 *   
 *  @default 0x000000
 * 
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */ 
[Style(name="symbolColor", type="uint", format="Color", inherit="yes", theme="spark,mobile")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("BusyIndicator.png")]

/**
 *  The BusyIndicator defines a component to display when a long-running 
 *  operation is in progress. 
 *  For Web, Desktop and iOS, a spinner with twelve spoke is drawn.  
 *  For Android, a circle is drawn that rotates.
 *  The color of the circle or spokes is controlled by the value of the <code>symbolColor</code> style.
 *  The transparency of this component can be modified using the <code>alpha</code> property,
 *  but the alpha value of each spoke cannot be modified.
 *
 *  <p>The following image shows the BusyIndicator at the bottom of the screen next 
 *  to the Submit button:</p>
 *
 * <p>
 *  <img src="../../images/bi_busy_indicator_bi.png" alt="Busy indicator" />
 * </p>
 * 
 *  <p>The speed at which this component spins is controlled by the <code>rotationInterval</code>
 *  style. The <code>rotationInterval</code> style sets the delay, in milliseconds, between
 *  rotations. Decrease the <code>rotationInterval</code> value to increase the speed of the spin.</p>
 * 
 *  <p>The BusyIndicator has the following default characteristics:</p>
 *  <table class="innertable">
 *     <tr><th>Characteristic</th><th>Description</th></tr>
 *     <tr><td>Default size</td><td>160 DPI: 36x36 pixels<br>
 *                                  120 DPI: 27x27 pixels<br>
 *                                  240 DPI: 54x54 pixels<br>
 *                                  320 DPI: 72x72 pixels<br>
 * 									480 DPI: 108x108 pixels<br>
 * 									640 DPI: 144x144 pixels<br></td></tr>
 *     <tr><td>Minimum size</td><td>20x20 pixels</td></tr>
 *     <tr><td>Maximum size</td><td>No limit</td></tr>
 *  </table>
 *  
 *  <p>The diameter of the BusyIndicator's spinner is the minimum of the width and
 *  height of the component. The diameter must be an even number, and is
 *  reduced by one if it is set to an odd number.</p>
 * 
 *  @mxml
 *  
 *  <p>The <code>&lt;s:BusyIndicator&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *  
 *  <pre>
 *  &lt;s:BusyIndicator
 *    <strong>Common Styles</strong>
 *    rotationInterval=50
 * 
 *    <strong>Spark Styles</strong>
 *    symbolColor="0x000000"
 *  
 *    <strong>Mobile Styles</strong>
 *    symbolColor="0x000000"
 *  &gt;
 *  </pre>
 *
 *  @includeExample examples/BusyIndicatorExample.mxml -noswf
 *  @includeExample examples/views/BusyIndicatorExampleHomeView.mxml -noswf
 * 
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */	
	public class BusyIndicator extends SkinnableComponent
	{
		private var effectiveVisibility:Boolean = false;
		private var effectiveVisibilityChanged:Boolean = true;
		
		public function BusyIndicator()
		{
			super();
			// Listen to added to stage and removed from stage.
			// Start rotating when we are on the stage and stop
			// when we are removed from the stage.
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler,false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler,false,0,true);
			states = 	[
				new State({name:"notRotatingState"}),
				new State({name:"rotatingState"})
			];
			mx_internal::skinDestructionPolicy = "auto";
		}
		
		override protected function commitProperties():void
		{
			if (effectiveVisibilityChanged)
			{
				// if visibility changed, re-compute them here
				computeEffectiveVisibility();
				
				if (canRotate())
				{
					currentState = "rotatingState";
				}
				else
				{
					currentState = "notRotatingState";
				}
				
				invalidateSkinState();
				effectiveVisibilityChanged = false;
			}
			super.commitProperties();
		}
		
		override protected function getCurrentSkinState():String
		{
			return currentState;
		}
		
		/**
		 *  @private
		 *  Override so we know when visibility is set. The initialized
		 *  property calls setVisible() with noEvent == true
		 *  so we wouldn't get a visibility event if we just listened
		 *  for events.
		 */
		override public function setVisible(value:Boolean,
											noEvent:Boolean = false):void
		{
			super.setVisible(value, noEvent);
			
			effectiveVisibilityChanged = true;
			invalidateProperties();
		}
		
		override public function set designLayer(value:DesignLayer):void
		{
			super.designLayer = value;
			
			effectiveVisibilityChanged = true;
			invalidateProperties();
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
			
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
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
		
		override protected function layer_PropertyChange(event:PropertyChangeEvent):void
		{
			super.layer_PropertyChange(event);
			
			if (event.property == "effectiveVisibility")
			{
				effectiveVisibilityChanged = true;
				invalidateProperties();
			}
		}
		
		
	}
}

