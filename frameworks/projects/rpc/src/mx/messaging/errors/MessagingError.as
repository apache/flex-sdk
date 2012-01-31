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
 *  This is the base class for any messaging related error.
 *  It allows for less granular catch code.
 */
public class MessagingError extends Error
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    /**
	 *  Constructs a new instance of a MessagingError with the
	 *  specified message.
	 *
	 *  @param msg String that contains the message that describes the error.
     */
    public function MessagingError(msg:String)
    {
        super(msg);
    }
    
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
    
    /**
     *  Returns the string "[MessagingError]" by default, and includes the message property if defined.
     * 
     *  @return String representation of the MessagingError.
     */
    public function toString():String
    {
        var value:String = "[MessagingError";
        if (message != null)
            value += " message='" + message + "']";
        else
            value += "]";
        return value;
    }
}

}
