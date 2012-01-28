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
