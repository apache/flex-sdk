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

import mx.messaging.messages.ErrorMessage;

/**
 *  This error indicates a problem serializing a message within a channel.
 *  It provides a fault property which corresponds to an ErrorMessage generated
 *  when this error is thrown.
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
     */
    public var fault:ErrorMessage;
}

}