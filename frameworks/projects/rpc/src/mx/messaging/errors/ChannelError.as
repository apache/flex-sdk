
package mx.messaging.errors
{

/**
 *  This is the base class for any channel related errors.
 *  It allows for less granular catch code. 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion BlazeDS 4
 *  @productversion LCDS 3 
 */
public class ChannelError extends MessagingError
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    /**
	 *  Constructs a new instance of a ChannelError with the
	 *  specified message.
	 *
	 *  @param msg String that contains the message that describes the error.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion BlazeDS 4
     *  @productversion LCDS 3 
     */
    public function ChannelError(msg:String)
    {
        super(msg);
    }
}

}
