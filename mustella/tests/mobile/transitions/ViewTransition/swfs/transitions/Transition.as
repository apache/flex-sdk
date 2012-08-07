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
package transitions
{
	import spark.transitions.CrossFadeViewTransition;
	import spark.transitions.FlipViewTransition;
	import spark.transitions.SlideViewTransition;
	import spark.transitions.ViewTransitionBase;
	import spark.transitions.ZoomViewTransition;
	
	
	
	public class Transition extends ViewTransitionBase
	{
		public function Transition()
		{			
			 var base:ViewTransitionBase = new ViewTransitionBase();				
		}
		
		public function createFade():ViewTransitionBase{
			var crossfade:CrossFadeViewTransition = new CrossFadeViewTransition();
			return crossfade;	
		}
		
		public function createSlide():ViewTransitionBase {	
			  var slide:SlideViewTransition = new SlideViewTransition();
		return slide;
	}
		
		
		public function createFlip():ViewTransitionBase{
			 var flip:FlipViewTransition = new FlipViewTransition();
         return flip;
		}
		
		public function createZoom():ViewTransitionBase{
			 var zoom:ZoomViewTransition = new ZoomViewTransition();
			return zoom;
		}
}
}