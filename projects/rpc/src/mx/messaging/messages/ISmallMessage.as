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

package mx.messaging.messages 
{

/**
 * A marker interface that is used to indicate that an IMessage has an
 * alternative smaller form for serialization.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion BlazeDS 4
 *  @productversion LCDS 3 
 */
public interface ISmallMessage extends IMessage
{
    //--------------------------------------------------------------------------
    //
    // Methods
    // 
    //--------------------------------------------------------------------------

    /**
     * This method must be implemented by subclasses that have a "small" form,
     * typically achieved through the use of
     * <code>flash.utils.IExternalizable</code>. If a small form is not
     * available this method should return null.
     *
     * @return Returns An alternative representation of an
     * flex.messaging.messages.IMessage so that the serialized form
     * is smaller than the regular message.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion BlazeDS 4
     *  @productversion LCDS 3 
     */
    function getSmallMessage():IMessage;
}

}