
package mx.controls.listClasses
{

/**
 *  Values for the <code>direction</code> property of the TileList component.
 *
 *  @see mx.controls.listClasses.TileBase#direction
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public final class TileBaseDirection
{
	include "../../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

	/**
	 *  Arrange children horizontally.
	 *  For controls, such as TileList, that arrange children in
	 *  two dimensions, arrange the children by filling up a row 
	 *  before going on to the next row.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const HORIZONTAL:String = "horizontal";
	
	/**
	 *  Arrange chidren vertically.
	 *  For controls, such as TileList, that arrange children in
	 *  two dimensions, arrange the children by filling up a column
	 *  before going on to the next column.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const VERTICAL:String = "vertical";
}

}
