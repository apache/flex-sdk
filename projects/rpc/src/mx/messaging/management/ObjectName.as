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

package mx.messaging.management
{

import mx.utils.ObjectUtil;

[RemoteClass(alias='flex.management.jmx.ObjectName')]

/**
 * Client representation of the name for server-side management controls.
*  
*  @langversion 3.0
*  @playerversion Flash 9
*  @playerversion AIR 1.1
*  @productversion BlazeDS 4
*  @productversion LCDS 3 
*/
public class ObjectName 
{
    /**
     *  Creates a new instance of an empty ObjectName.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion BlazeDS 4
     *  @productversion LCDS 3 
     */
	public function ObjectName()
	{
		super();
	}

	/**
	 * The canonical form of the name; a string representation with 
	 * the properties sorted in lexical order.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion BlazeDS 4
	 *  @productversion LCDS 3 
	 */
	public var canonicalName:String;
	
	/**
	 * A string representation of the list of key properties, with the key properties sorted in lexical order.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion BlazeDS 4
	 *  @productversion LCDS 3 
	 */
	public var canonicalKeyPropertyListString:String;
	
	/**
	 * Indicates if the object name is a pattern.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion BlazeDS 4
	 *  @productversion LCDS 3 
	 */
	public var pattern:Boolean;
	
	/**
	 * Indicates if the object name is a pattern on the domain part.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion BlazeDS 4
	 *  @productversion LCDS 3 
	 */
	public var domainPattern:Boolean;
	
	/**
	 * Indicates if the object name is a pattern on the key properties.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion BlazeDS 4
	 *  @productversion LCDS 3 
	 */
	public var propertyPattern:Boolean;
	
	/**
	 * The domain part.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion BlazeDS 4
	 *  @productversion LCDS 3 
	 */
	public var domain:String;
	
	/**
	 * The key properties as an Object, keyed by property name.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion BlazeDS 4
	 *  @productversion LCDS 3 
	 */
	public var keyPropertyList:Object;
	
	/**
	 * A string representation of the list of key properties.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion BlazeDS 4
	 *  @productversion LCDS 3 
	 */
	public var keyPropertyListString:String;
	
	/**
	 * Returns the value associated with the specified property key.
	 *
	 * @param The property key.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion BlazeDS 4
	 *  @productversion LCDS 3 
	 */
	public function getKeyProperty(property:String):Object
	{
		if (keyPropertyList != null && keyPropertyList.hasOwnProperty(property))
		{
			return keyPropertyList[property];
		}
		return null;
	}
	
	/**
     *  This method will return a string representation of the object name.
     * 
     *  @return String representation of the object name.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion BlazeDS 4
     *  @productversion LCDS 3 
     */
	public function toString():String
    {
    	if (canonicalName)
    	{
    		return canonicalName;
    	}
    	else
    	{
	        return ObjectUtil.toString(this);
	    }
    }

}

}