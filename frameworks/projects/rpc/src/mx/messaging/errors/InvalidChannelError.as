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
 *  This error is thrown when a Channel can't be accessed
 *  or is not valid for the current destination.
 *  This error is thrown by the following methods/properties
 *  within the framework:
 *  <ul>
 *    <li><code>ServerConfig.getChannel()</code> if the channel
 *    can't be found based on channel id.</li>
 *  </ul>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion BlazeDS 4
 *  @productversion LCDS 3 
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion BlazeDS 4
     *  @productversion LCDS 3 
     */
    public function InvalidChannelError(msg:String)
    {
        super(msg);
    }
}

}
