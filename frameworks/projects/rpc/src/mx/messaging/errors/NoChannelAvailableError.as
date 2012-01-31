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
 *  This error is thrown when no Channel is available to send messages.
 *  This error is thrown by the following methods within the framework:
 *  <ul>
 *    <li><code>ChannelSet.send()</code> if the ChannelSet has no channels.</li>
 *  </ul>
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
     */
    public function NoChannelAvailableError(msg:String)
    {
        super(msg);
    }
}

}