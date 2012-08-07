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
package classes
{
	import flash.events.Event;
	
	import mx.effects.*;
	import mx.events.EffectEvent;
	
	import spark.effects.Wipe;
	import spark.effects.WipeDirection;
	import spark.components.TabbedViewNavigator;
	
	
	public class MyTabbedViewNavigator extends TabbedViewNavigator
	{
		import spark.transitions.SlideViewTransition;
		
		private var wpin : Fade = new Fade();
		private var wpout : Fade = new Fade();
			
		public function MyTabbedViewNavigator()
		{
			super();
		}

		override protected function createTabBarShowEffect():IEffect {
			wpin.target = tabBar;
			wpin.alphaFrom = 0;
			wpin.alphaTo = 1;
			wpin.duration = 1500;
			
      tabBar.visible = true;
      tabBar.includeInLayout = true;

			wpin.addEventListener(EffectEvent.EFFECT_END, visibilityShowAnimation_completeHandler);
			
			return wpin;
		}
		
		override protected function createTabBarHideEffect():IEffect {
			wpout.target = tabBar;
			wpout.alphaFrom = 1;
			wpout.alphaTo = 0;
			wpout.duration = 1500;
			
			wpout.addEventListener(EffectEvent.EFFECT_END, visibilityHideAnimation_completeHandler);
			
			return wpout;
		}
		
		private function visibilityShowAnimation_completeHandler(event:EffectEvent):void {
		}
		
		private function visibilityHideAnimation_completeHandler(event:EffectEvent):void {
      tabBar.visible = false;
      tabBar.includeInLayout = false;
		}
	}
}