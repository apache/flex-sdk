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
 *  The IOLAPLevel interface represents a level within the OLAP schema of an OLAP cube,
 *  where a hierarchy of a dimension contains one or more levels.
 *.
 *  @see mx.olap.OLAPLevel 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IOLAPLevel extends IOLAPElement
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  child
	//----------------------------------
	
    /**
     *  The next child level in the hierarchy.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get child():IOLAPLevel;
    
    //----------------------------------
	//  depth
	//----------------------------------
	
    /**
     *  The depth of the level in the hierarchy of the dimension.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get depth():int;
    
    //----------------------------------
	//  hierarchy
	//----------------------------------
	
    /**
     *  The hierarchy of the dimension to which this level belongs.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get hierarchy():IOLAPHierarchy;
    
    //----------------------------------
	//  parent
	//----------------------------------
	
    /**
     *  The parent level of this level, or null if this level is not nested in another level.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get parent():IOLAPLevel;
    
    //----------------------------------
	//  members
	//----------------------------------
	
    /**
     *  The members of this level, as a list of IOLAPMember instances, 
     *  or null if a member is not found.
     *
     *  The list might represent remote data and therefore can throw 
     *  an ItemPendingError.
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get members():IList; //of IOLAPMembers
    
    //--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
    /**
     *  Returns the members with the given name within the hierarchy. 
     *
     *  @param name The name of the member.
     *
     *  @return A list of IOLAPMember instances representing the members, 
     *  or null if a member is not found.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    function findMember(name:String):IList;
}
}
