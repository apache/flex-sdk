
package mx.messaging.errors
{

import mx.messaging.messages.ErrorMessage;

/**
 *  This error indicates a problem serializing a message within a channel.
 *  It provides a fault property which corresponds to an ErrorMessage generated
 *  when this error is thrown.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion BlazeDS 4
 *  @productversion LCDS 3 
 */
public class MessageSerializationError extends MessagingError
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    /**
	 *  Constructs a new instance of the MessageSerializationError
	 *  with the specified message.
	 *
	 *  @param msg String that contains the message that describes the error.
	 *  @param fault Provides specific information about the fault that occured
	 *  and for which message.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion BlazeDS 4
     *  @productversion LCDS 3 
     */
    public function MessageSerializationError(msg:String, fault:ErrorMessage)
    {
        super(msg);
        this.fault = fault;
    }

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

    /**
     *  Provides specific information about the fault that occurred and for
     *  which message.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion BlazeDS 4
     *  @productversion LCDS 3 
     */
    public var fault:ErrorMessage;
}

}
