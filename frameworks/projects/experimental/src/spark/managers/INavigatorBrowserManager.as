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
package spark.managers
{
	import spark.layouts.supportClasses.INavigatorLayout;

	/**
	 *  The interface that the shared instance of the NavigtorBrowserManager
	 *  implements, which is accessed with the <code>NavigtorBrowserManager.getInstance()</code> method.
	 * 
	 *  @see spark.managers.NavigtorBrowserManager
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public interface INavigatorBrowserManager
	{
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  fragmentField
		//----------------------------------
		
		/**
		 *  The portion of current URL after the '#' as it appears 
		 *  in the browser address bar, or the default fragment
		 *  used in setup() if there is nothing after the '#'.  
		 *  Use setFragment to change this value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		function get fragmentField():String
		/**
		 *  @private
		 */
		function set fragmentField( value:String ):void
		
		
		//----------------------------------
		//  fragmentFunction
		//----------------------------------
		
		/**
		 *  The portion of current URL after the '#' as it appears 
		 *  in the browser address bar, or the default fragment
		 *  used in setup() if there is nothing after the '#'.  
		 *  Use setFragment to change this value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		function get fragmentFunction():Function
		/**
		 *  @private
		 */
		function set fragmentFunction( value:Function ):void
			
			
			
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Registers a layout so that it can be managed.
		 *  
		 *  @param value The INavigatorLayout to be registered.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		function registerLayout( value:INavigatorLayout ):void
		
		/**
		 *  Unregisters a layout so that it is no longer managed.
		 *  
		 *  @param value The INavigatorLayout to be unregistered.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		function unRegisterLayout( value:INavigatorLayout ):void
	}
}