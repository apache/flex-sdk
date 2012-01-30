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
 *  applications this application may communicate with.
 *  This application may not share memory with, or may not have access to, 
 *  the other applications in the group, but uses the bridge
 *  to communicate with these applications.
 */  
public interface ISWFBridgeGroup
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
     *  @param bridgeProvider The display object that loaded the content
     *  represented by the bridge. Usually this is will an instance of SWFLoader.
     */
    function addChildBridge(bridge:IEventDispatcher, bridgeProvider:ISWFBridgeProvider):void;
    
    /**
     *  Removes the child bridge.
     * 
     *  @param bridge The bridge to remove.
     */
    function removeChildBridge(bridge:IEventDispatcher):void;
    
    /**
     *  Gets the owner of a bridge and also the DisplayObject
     *  that loaded the child.
     *  This method is useful when an event is received
     *  and the <code>event.target</code> is the bridge.
     *  The bridge can then be converted into the owning DisplayObject.
     *
     *  @param bridge Documentation is not currently available.
     * 
     *  @return The object that loaded the child. 
     */
    function getChildBridgeProvider(bridge:IEventDispatcher):ISWFBridgeProvider;

    /**
     *  Gets all of the child bridges in this group.
     * 
     *  @return An array of all the child bridges in this group.
     *  Each object in the array is of type <code>IEventDispatcher</code>
     */
    function getChildBridges():Array /* of IEventDispatcher */;
    
    /**
     *  Tests if the given bridge is one of the sandbox bridges in this group.
     * 
     *  @return <code>true</code> if the handle is found,
     *  and <code>false</code> otherwise.
     */
    function containsBridge(bridge:IEventDispatcher):Boolean;
}

}
