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
/**
 *  The IOLAPQueryAxis interface represents an axis of an OLAP query.
 *
 *  @see mx.olap.OLAPQuery
 *  @see mx.olap.OLAPQueryAxis
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IOLAPQueryAxis
{	   
    //--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  tuples
	//----------------------------------
	
    /**
     *  All the tuples added to the query axis, as an Array of IOLAPTuple instances. 
     *  This Array includes tuples added by the <code>addMember()</code> 
     *  and <code>addSet()</code> methods.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get tuples():Array;
    
    //----------------------------------
	//  sets
	//----------------------------------
	
    /**
     *  All the sets of the query axis, as an Array of IOLAPSet instances. 
     *  This Array includes sets added by the <code>addMember()</code> 
     *  and <code>addTuple()</code> methods.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get sets():Array;
    
    //--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
    /**
     *  Adds a set to the query axis. 
     *  The set define the members and tuples that provide the information for the query axis.
     *
     *  @param s The set to add to the query.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function addSet(s:IOLAPSet):void;
    
    /**
     *  Adds a tuple to the query axis. 
     *  The tuple is automatically converted to an IOLPASet instance.
     *
     *  @param t The tuple to add to the query.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function addTuple(t:IOLAPTuple):void;
    
    /**
     *  Adds a single member to the query axis. 
     *  The member is automatically converted to an IOLPASet instance.
     *  This method is useful when adding a member to a slicer axis.
     *
     *  @param s The member to add to the query.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function addMember(s:IOLAPMember):void;
}
}
