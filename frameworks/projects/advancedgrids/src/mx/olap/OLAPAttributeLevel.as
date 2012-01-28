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

package mx.olap
{

import mx.core.mx_internal;
import mx.collections.IList;

use namespace mx_internal;

/**
 * @private
 */ 
public class OLAPAttributeLevel extends OLAPLevel implements IOLAPAttributeLevel
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
	/**
	 * Constructor
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function OLAPAttributeLevel(name:String)
	{
		super(name);
	}

    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    // dataField
    //----------------------------------
    
	override public function get dataField():String
	{
		return OLAPAttribute(hierarchy).dataField;
	}

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
	
	//----------------------------------
    // userLevel
    //----------------------------------
    
	private var _userLevel:IOLAPLevel;
	
	/**
	 * Any OLAPLevel defined by the user and associated with this OLAPAttributeLevel.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	mx_internal function get userLevel():IOLAPLevel
	{
		return _userLevel;
	}
	
	/**
	 * @private
	 */
	mx_internal function set userLevel(value:IOLAPLevel):void
	{
		_userLevel = value;
	}
	
	//----------------------------------
    // children
    //----------------------------------

    /**
     * A OLAPAttributeLevel has no children.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	public function get children():IList
	{
		//trace("Children in AttributeLevel called. Returning null***");
		return null;
	}
	
}
}