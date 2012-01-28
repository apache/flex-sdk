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
