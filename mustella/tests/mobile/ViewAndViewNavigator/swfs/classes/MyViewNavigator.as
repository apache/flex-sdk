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
	import mx.effects.Fade;
	import mx.effects.IEffect;
	
	import mx.events.EffectEvent;
	
	import spark.components.ViewNavigator;
	
	public class MyViewNavigator extends ViewNavigator
	{
		public function MyViewNavigator()
		{
			super();
		}
		
		override protected function createActionBarShowEffect():IEffect {
			var wp : Fade = new Fade();
			wp.target = actionBar;
			wp.alphaFrom = 0;
			wp.alphaTo = 1;
			wp.duration = 1500;
			
      actionBar.visible = true;
      actionBar.includeInLayout = true;

			wp.addEventListener(EffectEvent.EFFECT_END, visibilityShowAnimation_completeHandler);

			return wp;
		}
		
		override protected function createActionBarHideEffect():IEffect {
			var wp : Fade = new Fade();
			wp.target = actionBar;
			wp.alphaFrom = 1;
			wp.alphaTo = 0;
			wp.duration = 1500;
			
			wp.addEventListener(EffectEvent.EFFECT_END, visibilityHideAnimation_completeHandler);
			
			return wp;
		}
		
		private function visibilityShowAnimation_completeHandler(event:EffectEvent):void {
		}
		
		private function visibilityHideAnimation_completeHandler(event:EffectEvent):void {
      actionBar.visible = false;
      actionBar.includeInLayout = false;
		}
	}
}