
package mx.olap
{
/**
 *  The IOLAPCell interface represents a cell in an OLAPResult instance.
 *.
 *  @see mx.olap.OLAPCell
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IOLAPCell
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  value
	//----------------------------------
	
    /**
     * The raw value in the cell.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get value():Number;
    
    //----------------------------------
	//  formattedValue
	//----------------------------------
	
    /**
     *  The formatted value in the cell.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get formattedValue():String;
    
}
}