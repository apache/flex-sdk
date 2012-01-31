
package mx.messaging.errors
{

/**
 *  This error is thrown when no Channel is available to send messages.
 *  This error is thrown by the following methods within the framework:
 *  <ul>
 *    <li><code>ChannelSet.send()</code> if the ChannelSet has no channels.</li>
 *  </ul>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion BlazeDS 4
 *  @productversion LCDS 3 
 */
public class NoChannelAvailableError extends MessagingError
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructs a new instance of the NoChannelAvailableError with the specified message.
     *
     *  @param msg String that contains the message that describes this NoChannelAvailableError.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion BlazeDS 4
     *  @productversion LCDS 3 
     */
    public function NoChannelAvailableError(msg:String)
    {
        super(msg);
    }
}

}
