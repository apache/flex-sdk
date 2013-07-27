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
package spark.layouts.supportClasses
{
	import flash.events.IEventDispatcher;
	
	import mx.core.ISelectableList;
	import mx.core.IVisualElement;

	/**
	 *  The INavigatorLayout interface indicates that the implementor
	 * 	is an LayoutBase that supports a <code>selectedIndex</code> property.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public interface INavigatorLayout extends IEventDispatcher
	{
		
		function get selectedElement():IVisualElement;
		
		//----------------------------------
		//  selectedIndex
		//----------------------------------
		
		/**
		 *  The index of the selected INavigatorLayout item.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		function get selectedIndex():int;
		/**
		 *  @private
		 */
		function set selectedIndex( value:int ):void;
		
		
		//----------------------------------
		//  useVirtualLayout
		//----------------------------------
		
		/**
		 *  Comment.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		function get useVirtualLayout():Boolean
		/**
		 *  @private
		 */
		function set useVirtualLayout( value:Boolean ):void
			
			
		//----------------------------------
		//  firstIndexInView
		//----------------------------------
		
		/**
		 *  Comment.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		function get firstIndexInView():int
			
			
		//----------------------------------
		//  lastIndexInView
		//----------------------------------
		
		/**
		 *  Comment.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		function get lastIndexInView():int

	}
}