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
import mx.collections.ICollectionView;
import mx.collections.IList;

/**
 *  The IOLAPHierarchy interface represents a user-defined hierarchy 
 *  in a dimension of an OLAP schema.
 *.
 *  @see mx.olap.OLAPHierarchy 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IOLAPHierarchy extends IOLAPElement
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  allMemberName
	//----------------------------------
	
    /**
     *  The name of the all member of the hierarchy.
     * 
     *  @default "(All)"
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get allMemberName():String;
    
    //----------------------------------
	//  children
	//----------------------------------
	
    /**
     *  The children of the all member, as a list of IOLAPMember instances.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get children():IList; //of IOLAPMembers
    
    //----------------------------------
	//  defaultMember
	//----------------------------------
	
    /**
     *  The default member of the hierarchy. 
     *  The default member is used if the hierarchy 
     *  is used where a member is expected.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get defaultMember():IOLAPMember;
    
    //----------------------------------
	//  hasAll
	//----------------------------------
	
    /**
     *  Specifies whether the hierarchy has an all member, <code>true</code>, 
     *  or not, <code>false</code>. If <code>true</code>, the all member name
     *  is as specified by the <code>allMemberName</code> property. 
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get hasAll():Boolean;
    
    //----------------------------------
	//  levels
	//----------------------------------
	
    /**
     *  All the levels of this hierarchy, as a list of IOLAPLevel instances.
     *
     *  The returned list might represent remote data and therefore can throw 
     *  an ItemPendingError.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get levels():IList; //of IOLAPLevels
    
    //----------------------------------
	//  members
	//----------------------------------
	
    /**
     *  All members of all the levels that belong to this hierarchy, 
     *  as a list of IOLAPMember instances.
     *
     *  The returned list might represent remote data and therefore can throw 
     *  an ItemPendingError.
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
     *  Returns the level with the given name within the hierarchy. 
     *
     *  @param name The name of the level.
     *
     *  @return An IOLAPLevel instance representing the level, 
     *  or null if a level is not found.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function findLevel(name:String):IOLAPLevel;
    
    /**
     *  Returns the member with the given name within the hierarchy. 
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
