////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */ 
public interface ISWFBridgeProvider
{
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  swfBridge
    //----------------------------------
    
    /**
     *  A bridge to the application that is associated with the implementor of this 
     *  interface. The IEventDispatcher that can be used to send events to an 
     *  application in a different ApplicationDomain or a different sandbox.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get swfBridge():IEventDispatcher;
    
    /**
     *  Tests if the child allows its parent to access its display objects or listen
     *  to messages that originate in the child.
     * 
     *  <code>true</code> if access if allowed; otherwise <code>false</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */  
    function get childAllowsParent():Boolean;
    
    /**
     *  Tests if the parent allows its child to access its display objects or listen
     *  to messages that originate in the parent.
     * 
     *  <code>true</code> if access if allowed; otherwise <code>false</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */  
    function get parentAllowsChild():Boolean;
}

}
