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

package mx.rpc
{

/**
 *  This interface provides the contract for any service
 *  that needs to respond to remote or asynchronous calls.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IResponder
{
	/**
	 *  This method is called by a service when the return value
	 *  has been received. 
	 *  While <code>data</code> is typed as Object, it is often
     *  (but not always) an mx.rpc.events.ResultEvent object.
         *
     *  @param data Contains the information returned from the request.
	 */
	function result(data:Object):void;
	
	/**
	 *  This method is called by a service when an error has been received.
	 *  While <code>info</code> is typed as Object it is often
     *  (but not always) an mx.rpc.events.FaultEvent object.
         *
     *  @param info Contains the information about the error that 
     *  occured.
	 */
	function fault(info:Object):void;
}

}
