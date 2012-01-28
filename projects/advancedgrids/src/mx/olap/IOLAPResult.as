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
 *  The IOLAPResult interface represents the result of a query on an OLAP cube.
 *
 *  @see mx.olap.OLAPQuery
 *  @see mx.olap.OLAPQueryAxis
 *  @see mx.olap.IOLAPResultAxis
 *  @see mx.olap.OLAPResultAxis
 *  @see mx.olap.OLAPResult
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IOLAPResult
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  axes
	//----------------------------------
	
    /**
     * An Array of IOLAPResultAxis instances that represent all the axes of the query.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get axes():Array; // (of IAxis);
    
    //----------------------------------
	//  query
	//----------------------------------
	
    /**
     *  The query whose result is represented by this object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get query():IOLAPQuery;
    
    //--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
    /**
     *  Returns an axis of the query result.
     *
     *  @param axisOrdinal Specify <code>OLAPQuery.COLUMN AXIS</code> for a column axis, 
     *  <code>OLAPQuery.ROW_AXIS</code> for a row axis, 
     *  and <code>OLAPQuery.SLICER_AXIS</code> for a slicer axis.
     *
     *  @return The IOLAPQueryAxis instance.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getAxis(axisOrdinal:int):IOLAPResultAxis;
    
    /**
     *  Returns a cell at the specified location in the query result.
     *
     *  @param x The column of the query result.
     *
     *  @param y The row of the query result.
     *
     *  @return An IOLAPCell instance representing the cell.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getCell(x:int, y:int):IOLAPCell;
}
}