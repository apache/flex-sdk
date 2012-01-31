////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.messaging.channels
{

/**
 *  The SecureStreamingHTTPChannel class is identical to the StreamingHTTPChannel
 *  class except that it uses a secure protocol, HTTPS, to send messages to an 
 *  HTTP endpoint.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion BlazeDS 4
 *  @productversion LCDS 3 
 */
public class SecureStreamingHTTPChannel extends StreamingHTTPChannel
{
    //--------------------------------------------------------------------------
    //
    // Constructor
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *
     *  @param id The id of this Channel.
     *  
     *  @param uri The uri for this Channel.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion BlazeDS 4
     *  @productversion LCDS 3 
     */
    public function SecureStreamingHTTPChannel(id:String = null, uri:String = null)
    {
        super(id, uri);
    }

    //--------------------------------------------------------------------------
    //
    // Properties
    // 
    //--------------------------------------------------------------------------

    /**
     *  Returns the protocol for this channel (https).
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion BlazeDS 4
     *  @productversion LCDS 3 
     */
    override public function get protocol():String
    {
        return "https";
    }
}

}
