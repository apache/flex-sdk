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
package spark.containers
{
	import mx.core.IVisualElement;

	import spark.components.Group;
	/**
	*  @langversion 3.0
	*  @playerversion Flash 10.1
	*  @playerversion AIR 2.5
	*  @productversion Flex 4.5
	*/
	/**
	 * @author Bogdan Dinu (http://www.badu.ro)
	 */
	public class Divider extends Group
	{
		/**
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		private var _upOrRightNeighbour : IVisualElement;
		public function get upOrRightNeighbour():IVisualElement
		{
			return _upOrRightNeighbour;
		}

		public function set upOrRightNeighbour(value:IVisualElement):void
		{
			_upOrRightNeighbour = value;
		}
		/**
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		private var _downOrLeftNeighbour : IVisualElement;
		public function get downOrLeftNeighbour():IVisualElement
		{
			return _downOrLeftNeighbour;
		}

		public function set downOrLeftNeighbour(value:IVisualElement):void
		{
			_downOrLeftNeighbour = value;
		}
		/**
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function Divider()
		{
			super();
		}
	}
}
