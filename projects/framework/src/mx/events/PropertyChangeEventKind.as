
package mx.events
{

/**
 *  The PropertyChangeEventKind class defines the constant values 
 *  for the <code>kind</code> property of the PropertyChangeEvent class.
 * 
 *  @see mx.events.PropertyChangeEvent
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public final class PropertyChangeEventKind
{
	include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

    /**
	 *  Indicates that the value of the property changed.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const UPDATE:String = "update";

    /**
	 *  Indicates that the property was deleted from the object.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const DELETE:String = "delete";
}

}
