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

package mx.core
{

/**
 *  The ITransientDeferredInstance interface extends IDeferredInstance and adds 
 *  the ability for the user to reset the deferred instance factory to its
 *  initial state (usually this implies releasing any known references to the
 *  component, such as the setting the owning document property that refers to
 *  the instance to null).
 *
 *  This additional capability is leveraged by the AddItems states override when
 *  the desired behavior is to destroy a state-specific element when a state
 *  no longer applies.
 * 
 *  The Flex compiler uses the same automatic coercion rules as with
 *  IDeferredInstance.
 * 
 *  @see mx.states.AddItems
 *  @see mx.core.IDeferredInstance
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public interface ITransientDeferredInstance extends IDeferredInstance
{
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Resets the state of our factory to its initial state, clearing any
     *  references to the cached instance.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function reset():void;
}

}