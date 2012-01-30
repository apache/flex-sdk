
package mx.core
{

/**
 *  The MXMLObjectAdapter class is a stub implementation
 *  of the IMXMLObject interface, so that you can implement
 *  the interface without defining all of the methods.
 *  All implementations are the equivalent of no-ops.
 *  If the method is supposed to return something, it is null, 0, or false.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class MXMLObjectAdapter implements IMXMLObject
{
	include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  Constructor.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
    public function MXMLObjectAdapter()
    {
		super();
	}

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function initialized(document:Object, id:String):void
	{
	}
}

}
