////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2006-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
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
