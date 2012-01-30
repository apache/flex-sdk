////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.core
{

import flash.events.IEventDispatcher;
    
/**
 *  An implementor of ISWFBridgeProvider provides a bridge
 *  to an application in a different security sandbox
 *  or to an application that was compiled with a different version
 *  of the Flex compiler and is running in a separate ApplicationDomain. 
 *  This interface lets a caller get a bridge to that application.
 *  Once the caller has the bridge, it can then dispatch events
 *  to the application.
 */ 
public interface ISWFBridgeProvider
{
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  sandboxBridge
    //----------------------------------
    
    /**
     *  A bridge to the application that is associated with the implementor of this 
     *  interface. The IEventDispatcher that can be used to send events to an 
     *  application in a different ApplicationDomain or a different sandbox.
     */
    function get swfBridge():IEventDispatcher;
    
    /**
     *  Tests if the child allows its parent to access its display objects or listen
     *  to messages that originate in the child.
     * 
     *  <code>true</code> if access if allowed; otherwise <code>false</code>.
     */  
    function get childAllowsParent():Boolean;
    
    /**
     *  Tests if the parent allows its child to access its display objects or listen
     *  to messages that originate in the parent.
     * 
     *  <code>true</code> if access if allowed; otherwise <code>false</code>.
     */  
    function get parentAllowsChild():Boolean;
}

}
