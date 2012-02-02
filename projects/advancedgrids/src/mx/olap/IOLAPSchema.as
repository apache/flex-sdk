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
 *  The IOLAPSchema interface represents the OLAP schema.
 *
 *  @see mx.olap.OLAPSchema 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IOLAPSchema
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  cubes
	//----------------------------------
	
	/**
     *  All the cubes known by this schema, as a list of IOLAPCube instances.
     *
     *  The returned list might represent remote data and therefore can throw 
     *  an ItemPendingError.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get cubes():IList;// (of IOLAPCube)
    
    //--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
     /**
     *  Creates an OLAP cube from the schema.
     *
     *  @param name The name of the cube.
     *
     *  @return The IOLAPCube instance.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function createCube(name:String):IOLAPCube;

     /**
     *  Returns a cube specified by name.
     *
     *  @param name The name of the cube.
     *
     *  @return The IOLAPCube instance, or null if one is not found.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getCube(name:String):IOLAPCube;
}
}