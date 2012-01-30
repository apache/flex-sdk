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

package mx.collections
{

/**
 *  @private
 * 
 *  The ItemWrapper class is a simple envelope for an item in a collection.
 *  Its purpose is to provide a way of distinguishing between duplicate items
 *  in a collection -- i.e., giving them unique IDs. It is used by data change
 *  effects for classes derived by ListBase. Distinguishing between duplicate
 *  elements is particularly important for data change effects because it is
 *  necessary to assign common item renderers to common items in a collection
 */
public class ItemWrapper
{
    include "../core/Version.as";
    
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructs an instance of the wrapper with the specified data.
	 * 
	 *  @param data The data element to be wrapped.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function ItemWrapper(data:Object)
	{
		super();
		this.data = data;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  The data item being wrapped.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */ 
    public var data:Object;

}


}