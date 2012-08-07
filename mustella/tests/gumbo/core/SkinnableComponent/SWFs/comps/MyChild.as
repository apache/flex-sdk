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

	public class MyChild extends MyComponent

	{

		/* Skin states*/

		// Any skin for this component must implement all these states

		// Child component of MyComponent has more states

		[SkinState("five")]
		[SkinState("six")]

		public function MyChild()

		{

			super();

		}

		

		/*****************************************************/

		/*Methods for helping determine and update skin state*/

		/*****************************************************/



		override protected function getCurrentSkinState():String{

			var curState:String = this.label;

			if (curState == 'one')

				return 'one';

			else if (curState == 'two')

				return 'two';

			else if (curState == 'three')

				return 'three';

			else if (curState == 'six')

				return 'six';

			else

				return 'six';

		}	



		override public function invalidateSkinState():void{

			super.invalidateSkinState();	

		}


	}

}
