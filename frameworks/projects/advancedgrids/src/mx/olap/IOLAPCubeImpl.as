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
 *  @private
 */
public interface IOLAPCubeImpl
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  cube
	//----------------------------------
	
	/**
	 * Provide the cube on which the implementation would act upon.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function set cube(value:IOLAPCube):void;
	
	//----------------------------------
	//  queryProgress
	//----------------------------------
	
	/**
     * Returns the progress of cell computation in the query.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get queryProgress():int;
	
	//----------------------------------
	//  queryTotal
	//----------------------------------
	
    /**
     * Returns the total number of cells in the query.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	function get queryTotal():int;
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Function to be called to build the cube.
	 * Returns false to indicate that it needs to be called again to
	 * complete the cube. Returns true when cube is complete.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function buildCubeIteratively():Boolean;
	
    /**
     *  Aborts execution of the query.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function cancelQuery(q:IOLAPQuery):void;

    /**
     *  Aborts creation of the cube.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */	
	function cancelRefresh():void;

	/**
	 * Populates the 'result' object with the 'query' results.
	 * Returns true when the result has been fully computed.
	 * Returns false to indicate that execute needs to be called again.
	 * query and result arguments should be changed only after execute returns true
	 * or after calling cancelQuery.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function execute(query:IOLAPQuery, result:OLAPResult):Boolean;

	/**
	 *  refresh called from cube
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function refresh():void;		
}
}
