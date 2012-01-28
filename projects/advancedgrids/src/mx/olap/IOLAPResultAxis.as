
package mx.olap
{
import mx.collections.IList;

/**
 *  The IOLAPResultAxis interface represents an axis of the result of an OLAP query.
 *
 *  @see mx.olap.OLAPQuery
 *  @see mx.olap.OLAPQueryAxis
 *  @see mx.olap.OLAPResultAxis
 *  @see mx.olap.IOLAPResult
 *  @see mx.olap.OLAPResult
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IOLAPResultAxis
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  positions
	//----------------------------------
	
    /**
     * A list of IOLAPAxisPosition instances, 
     * where each position represents a point along the axis. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get positions():IList; //of IPosition
}
}