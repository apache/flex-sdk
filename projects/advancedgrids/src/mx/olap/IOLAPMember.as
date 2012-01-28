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
import mx.collections.IList;

/**
 *  The IOLAPMember interface represents a member of a level of an OLAP schema.
 *.
 *  @see mx.olap.OLAPMember 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IOLAPMember extends IOLAPElement
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  children
	//----------------------------------
	
    /**
     *  The children of this member, as a list of IOLAPMember instances.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get children():IList;
    
    //----------------------------------
	//  hierarchy
	//----------------------------------
	
    /**
     * The hierarchy to which this member belongs.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get hierarchy():IOLAPHierarchy
    
    //----------------------------------
	//  isAll
	//----------------------------------
	
    /**
     *  Returns <code>true</code> if this is the all member of a hierarchy.
     *
     *  @return <code>true</code> if this is the all member of a hierarchy.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    function get isAll():Boolean;
    
    //----------------------------------
	//  isMeasure
	//----------------------------------
	
    /**
     * Returns <code>true</code> if this member represents a measure of a dimension.
     *
     *  @return <code>true</code> if this member represents a measure of a dimension.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    function get isMeasure():Boolean;
    
    //----------------------------------
	//  level
	//----------------------------------
	
    /**
     * The level to which this member belongs.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get level():IOLAPLevel
    
    //----------------------------------
	//  parent
	//----------------------------------
	
    /**
     * The parent of this member.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get parent():IOLAPMember;
    
    //--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
    /**
     *  Returns a child of this member with the given name.
     *
     *  @param name The name of the member.
     *
     *  @return A list of IOLAPMember instances representing the member, 
     *  or null if a member is not found.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function findChildMember(name:String):IOLAPMember;
}
}