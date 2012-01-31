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

package mx.rpc.soap
{


/**
 * A context for the result of a SOAP based Remote Procedure Call.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class SOAPResult
{
    /**
     * A collection of header objects. A SOAPDecoder can populate this array with
     * elements of type SOAPHeader, XML, or XMLDocument, based on the headerFormat
     * setting on the decoder.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var headers:Array;
    
    /**
     * Flag indicating if this result object represents a SOAP Fault message.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var isFault:Boolean;
    
    /**
     * Body of the SOAP result. A SOAPDecoder can populate this value based on the
     * resultFormat setting on the decoder.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var result:*;

    /**
     * Creates a new SOAPResult.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function SOAPResult()
    {
        super();
    }
}

}
