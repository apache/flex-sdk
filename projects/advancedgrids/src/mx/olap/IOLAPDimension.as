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
import mx.collections.ICollectionView;
import mx.collections.IList;

/**
 *  The IOLAPDimension interface represents a dimension in an IOLAPCube instance.
 *.
 *  @see mx.olap.OLAPDimension 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IOLAPDimension extends IOLAPElement
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  attributes
	//----------------------------------
	
    /**
     *  The attributes of this dimension, as a list of OLAPAttribute instances.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get attributes():IList;
    
    //----------------------------------
	//  cube
	//----------------------------------
	
    /**
     *  The cube to which this dimension belongs.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get cube():IOLAPCube;  
    
    //----------------------------------
	//  defaultMember
	//----------------------------------
	
    /**
     *  The default member of this dimension.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get defaultMember():IOLAPMember;
    
    //----------------------------------
	//  hierarchies
	//----------------------------------
	
    /**
     *  All the hierarchies for this dimension, as a list of IOLAPHierarchy instances.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get hierarchies():IList; // of IOLAPHierarchy
    
    //----------------------------------
	//  members
	//----------------------------------
	
    /**
     *  Returns all the members of this dimension, as a list of IOLAPMember instances. 
     *
     *  The returned list might represent remote data and therefore can throw 
     *  an ItemPendingError.
     *
     *  @param name The name of the hierarchy.
     *
     *  @return An IOLAPHierarchy instance representing the hierarchy, 
     *  or null if a hierarchy is not found.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get members():IList;
    
    //----------------------------------
	//  isMeasure
	//----------------------------------
	
    /**
     * Contains <code>true</code> if this is the measures dimension,
     * which holds all the measure members.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get isMeasure():Boolean;
    
    //--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
    /**
     *  Returns the attribute with the given name within the dimension. 
     *
     *  @param name The name of the attribute.
     *
     *  @return An IOLAPAttribute instance representing the attribute, 
     *  or null if an attribute is not found.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function findAttribute(name:String):IOLAPAttribute
    
    /**
     *  Returns the hierarchy with the given name within the dimension. 
     *
     *  @param name The name of the hierarchy.
     *
     *  @return An IOLAPHierarchy instance representing the hierarchy, 
     *  or null if a hierarchy is not found.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function findHierarchy(name:String):IOLAPHierarchy;
    
    /**
     *  Returns the member with the given name within the dimension. 
     *
     *  @param name The name of the member.
     *
     *  @return An IOLAPMember instance representing the member, 
     *  or null if a member is not found.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function findMember(name:String):IOLAPMember;
}
}
