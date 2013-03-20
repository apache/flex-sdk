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
	
	import mx.core.Singleton;
	
	/**
	 *  @private
	 *  The NavigatorBrowserManager is a Singleton manager that acts as
	 *  a proxy between the BrowserManager and INavigatorLayout instances
	 *  added to it.
	 * 
	 *  <p>It updates the <code>fragment</code> property of the IBrowserManager
	 *  when a registered INavigatorLayout changes its <code>selectedindex</code>,
	 *  and also sets the <code>selectedIndex</code> of registered INavigatorLayout instances
	 *  when the <code>fragment</code> property of the IBrowserManager changes.
	 *
	 *  @see spark.managers.INavigatorBrowserManager
	 *  @see spark.layouts.supportClasses.INavigatorLayout
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public class NavigatorBrowserManager
	{

		
		
		//--------------------------------------------------------------------------
		//
		//  Class Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  Linker dependency on implementation class.
		 */
		private static var implClassDependency:NavigatorBrowserManagerImpl;
		
		/**
		 *  @private
		 */
		private static var instance:INavigatorBrowserManager;
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Returns the sole instance of this Singleton class;
		 *  creates it if it does not already exist.
		 *
		 *  @return Returns the sole instance of this Singleton class;
		 *  creates it if it does not already exist.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public static function getInstance():INavigatorBrowserManager
		{
			if( !instance ) instance = INavigatorBrowserManager( Singleton.getInstance( "spark.managers::INavigatorBrowserManager" ) );
			return instance;
		}
	}
	
}
