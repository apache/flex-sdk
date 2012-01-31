/*************************************************************************
 * 
 * ADOBE CONFIDENTIAL
 * __________________
 * 
 *  [2002] - [2007] Adobe Systems Incorporated 
 *  All Rights Reserved.
 * 
 * NOTICE:  All information contained herein is, and remains
 * the property of Adobe Systems Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Adobe Systems Incorporated
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Adobe Systems Incorporated.
 */
package mx.messaging.errors
{

/**
 *  This error is thrown when a destination can't be accessed
 *  or is not valid.
 *  This error is thrown by the following methods/properties
 *  within the framework:
 *  <ul>
 *    <li><code>ServerConfig.getChannelSet()</code> if an invalid destination is specified.</li>
 *    <li><code>ServerConfig.getProperties()</code> if an invalid destination is specified.</li>
 *    <li><code>Channel.send()</code> if no destination is specified for the message to send.</li>
 *    <li><code>MessageAgent.destination</code> setter if the destination value is null or zero length.</li>
 *    <li><code>Producer.send()</code> if no destination is specified for the Producer or message to send.</li>
 *    <li><code>Consumer.subscribe()</code> if no destination is specified for the Consumer.</li>
 *  </ul>
 */
public class InvalidDestinationError extends ChannelError
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructs a new instance of an InvalidDestinationError with the specified message.
     *
     *  @param msg String that contains the message that describes this InvalidDestinationError.
     */
    public function InvalidDestinationError(msg:String)
    {
        super(msg);
    }
}

}