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
 *  The IOLAPTuple interface represents a tuple.
 *  You can use tuples to specify the elements 
 *  on a query axis as part of an OLAPSet instance.
 *
 *  @see mx.olap.OLAPSet
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IOLAPTuple
{
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
    /**
     *  Adds a new member to the tuple. 
     *
     *  @param element The member to add. 
     *  If <code>member</code> is a dimension or hierarchy, its default member
     *  is added. If <code>member</code> is an instance of IOLAPMember, 
     *  it is added directly.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function addMember(member:IOLAPElement):void

    /**
     *  Adds a list of members to the tuple. 
     *  This method can be called when many members need to be added to the tuple.
     *
     *  @param value The members to add, as a list of IOLAPMember instances. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function addMembers(value:IList):void;

    /**
     * The user added members of this tuple, as a list of IOLAPMember instances.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get explicitMembers():IList;
    
}

}