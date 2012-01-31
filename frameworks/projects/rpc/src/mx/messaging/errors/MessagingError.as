////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.messaging.errors
{

/**
 *  This is the base class for any messaging related error.
 *  It allows for less granular catch code.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion BlazeDS 4
 *  @productversion LCDS 3 
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion BlazeDS 4
     *  @productversion LCDS 3 
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion BlazeDS 4
     *  @productversion LCDS 3 
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
