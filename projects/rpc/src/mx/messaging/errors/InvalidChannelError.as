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
 *  This error is thrown when a Channel can't be accessed
 *  or is not valid for the current destination.
 *  This error is thrown by the following methods/properties
 *  within the framework:
 *  <ul>
 *    <li><code>ServerConfig.getChannel()</code> if the channel
 *    can't be found based on channel id.</li>
 *  </ul>
 */
public class InvalidChannelError extends ChannelError
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructs a new instance of an InvalidChannelError with the specified message.
     *
     *  @param msg String that contains the message that describes this InvalidChannelError.
     */
    public function InvalidChannelError(msg:String)
    {
        super(msg);
    }
}

}
