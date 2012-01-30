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

package mx.managers
{

import flash.display.DisplayObject;  
import flash.events.Event;
import flash.events.IEventDispatcher;  
import flash.geom.Rectangle;
import mx.core.ISWFBridgeGroup;  

/**
 *  The IMarshalSystemManager interface defines the methods and properties that classes must implement
 *  if they want to access, add, and remove bridges to other applications in a cross-versioned configuration.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public interface IMarshalSystemManager
{
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  swfBridgeGroup
    //----------------------------------

    /**
     *  Contains all the bridges to other applications
     *  that this application is connected to.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get swfBridgeGroup():ISWFBridgeGroup;
    function set swfBridgeGroup(value:ISWFBridgeGroup):void;
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /** 
     *  Adds a child bridge to the system manager.
     *  Each child bridge represents components in another sandbox
     *  or compiled with a different version of Flex.
     *
     *  @param bridge The bridge for the child.
     *
     *  @param owner The SWFLoader for the child.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function addChildBridge(bridge:IEventDispatcher, owner:DisplayObject):void;

    /** 
     *  Adds a child bridge to the system manager.
     *  Each child bridge represents components in another sandbox
     *  or compiled with a different version of Flex.
     *
     *  @param bridge The bridge for the child.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function removeChildBridge(bridge:IEventDispatcher):void;
    
    /**
     *  Dispatch a message to all parent and child applications in this SystemManager's SWF bridge group, regardless of
     *  whether they are in the same SecurityDomain or not. You can optionally exclude an application with this method's parameters.
     *
         *  @param event The event to dispatch.
         *  
         *  @param skip Specifies an IEventDispatcher that you do not want to dispatch a message to. This is typically used to skip the
         *  IEventDispatcher that originated the event.
     * 
         *  @param trackClones Whether to keep a reference to the events as they are dispatched.
         *  
         *  @param toOtherSystemManagers Whether to dispatch the event to other top-level SystemManagers in AIR.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function dispatchEventFromSWFBridges(event:Event, skip:IEventDispatcher = null, trackClones:Boolean = false, toOtherSystemManagers:Boolean = false):void

    /**
     *  Determines if the caller using this system manager
     *  should should communicate directly with other managers
     *  or if it should communicate with a bridge.
     * 
     *  @return <code>true</code> if the caller using this system manager
     *  should  communicate using sandbox bridges.
     *  If <code>false</code> the system manager may directly call
     *  other managers directly via references.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function useSWFBridge():Boolean;
    
    /** 
     *  Adds the specified child to the sandbox root in the layer requested.
     *
     *  @param layer The name of IChildList in SystemManager.
     *
     *  @param child The DisplayObject to add.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function addChildToSandboxRoot(layer:String, child:DisplayObject):void;

    /** 
     *  Removes the specified child from the sandbox root in the layer requested.
     *
     *  @param layer The name of IChildList in SystemManager.
     *
     *  @param child The DisplayObject to add.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function removeChildFromSandboxRoot(layer:String, child:DisplayObject):void;
    
    /**
     *  Tests if a display object is in a child application
     *  that is loaded in compatibility mode or in an untrusted sandbox.
     * 
     *  @param displayObject The DisplayObject to test.
     * 
     *  @return <code>true</code> if <code>displayObject</code>
     *  is in a child application that is loaded in compatibility mode
     *  or in an untrusted sandbox, and <code>false</code> otherwise.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function isDisplayObjectInABridgedApplication(
                        displayObject:DisplayObject):Boolean;
    
    /**
     * @private
     * 
     * Notify parent that a new window has been activated.
     * 
     * @param window window that was activated.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function dispatchActivatedWindowEvent(window:DisplayObject):void
}

}
