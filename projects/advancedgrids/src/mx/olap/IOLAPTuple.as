////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
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