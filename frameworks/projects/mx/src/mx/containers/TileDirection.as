
package mx.containers
{

/**
 *  The TileDirection class defines the constant values for the
 *  <code>direction</code> property of the Tile container.
 *
 *  @see mx.containers.Tile
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public final class TileDirection
{
	include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

    /**
	 *  Specifies that the children of the Tile container are laid out
	 *  horizontally; that is, starting with the first row.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const HORIZONTAL:String = "horizontal";
    
    /**
	 *  Specifies that the children of the Tile container are laid out
	 *  vertically; that is, starting with the first column.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const VERTICAL:String = "vertical";
}

}
