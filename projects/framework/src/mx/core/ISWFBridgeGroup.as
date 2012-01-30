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

import flash.display.DisplayObject;
import flash.events.IEventDispatcher;

/**
 *  A sandbox bridge group is a group of bridges that represent
 *  applications that this application can communicate with.
 *  This application can not share memory with, or can not have access to, 
 *  the other applications in the group, but uses the bridge
 *  to communicate with these applications.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */  
public interface ISWFBridgeGroup extends IEventDispatcher
{
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  parentBridge
    //----------------------------------

    /**
     *  The bridge that is used to communicate
     *  with this group's parent application.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get parentBridge():IEventDispatcher;
    
    /**
     *  @private
     */
    function set parentBridge(bridge:IEventDispatcher):void;
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Adds a new bridge to the pod.
     * 
     *  @param bridge The bridge to communicate with the child content.
     * 
     *  @param bridgeProvider The DisplayObject that loaded the content
     *  represented by the bridge. Usually this is will be an instance of the SWFLoader class.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function addChildBridge(bridge:IEventDispatcher, bridgeProvider:ISWFBridgeProvider):void;
    
    /**
     *  Removes the child bridge.
     * 
     *  @param bridge The bridge to remove.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function removeChildBridge(bridge:IEventDispatcher):void;
    
    /**
     *  Gets the owner of a bridge and also the DisplayObject
     *  that loaded the child.
     *  This method is useful when an event is received
     *  and the <code>event.target</code> is the bridge.
     *  The bridge can then be converted into the owning DisplayObject.
     *
     *  @param bridge The target bridge.
     * 
     *  @return The object that loaded the child. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getChildBridgeProvider(bridge:IEventDispatcher):ISWFBridgeProvider;

    /**
     *  Gets all of the child bridges in this group.
     * 
     *  @return An array of all the child bridges in this group.
     *  Each object in the array is of type <code>IEventDispatcher</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getChildBridges():Array /* of IEventDispatcher */;
    
    /**
     *  Tests if the given bridge is one of the sandbox bridges in this group.
     *  
     *  @param bridge The bridge to test.
     * 
     *  @return <code>true</code> if the handle is found; otherwise <code>false</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function containsBridge(bridge:IEventDispatcher):Boolean;
}

}
