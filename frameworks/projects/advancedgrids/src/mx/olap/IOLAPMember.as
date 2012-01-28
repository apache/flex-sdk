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