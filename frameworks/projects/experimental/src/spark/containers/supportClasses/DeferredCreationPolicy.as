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
package spark.containers.supportClasses
{

    // for asdoc
    [Experimental]

/**
	 *  The DeferredCreationPolicy class defines the constant values
	 *  for the <code>creationPolicy</code> property of the DeferedGroup class.
	 *
	 *  @see spark.containers.DeferredGroup#creationPolicy
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public class DeferredCreationPolicy
	{
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Immediately create all descendants.
		 *
		 *  <p>Avoid using this <code>creationPolicy</code> because
		 *  it increases the startup time of your application.
		 *  There is usually no good reason to create components at startup
		 *  which the user cannot see.
		 *  If you are using this policy so that you can "push" data into
		 *  hidden components at startup, you should instead design your
		 *  application so that the data is stored in data variables
		 *  and components which are created later "pull" in this data,
		 *  via databinding or an <code>initialize</code> handler.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public static const ALL:String = "all";
		
		/**
		 *  Construct all decendants immediately but only inialize those
		 *  that are visible.
		 *  
		 *  <p>This is useful if you using the container as a dataProvider
		 *  to a MenuBar, as the MenuBar requires all the children to be created
		 *  to get the correct dataProvider to drive its content.</p>
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public static const CONSTRUCT:String = "construct";
		
		/**
		 *  Only construct the immediate descendants and initialize
		 *  those that are visible.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public static const VISIBLE:String = "visible";
		
		/**
		 *  Do not create any children.
		 *
		 *  <p>With this <code>creationPolicy</code>, it is the developer's
		 *  responsibility to programmatically create the children 
		 *  from the UIComponentDescriptors by calling
		 *  <code>createComponentsFromDescriptors()</code>
		 *  on the parent container.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public static const NONE:String = "none";
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function DeferredCreationPolicy()
		{
			
		}
	}
}