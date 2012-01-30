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
	
import flash.display.DisplayObject;
import flash.utils.Dictionary;
import flash.events.IEventDispatcher;
	
import mx.managers.ISystemManager;
	
/**
 *  A SWFBridgeGroup represents all of the sandbox bridges that an 
 *  application needs to communicate with its parent and children.
 */
public class SWFBridgeGroup implements ISWFBridgeGroup
{
	include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    /**
     *  Constructor.
     * 
     *  @param owner The DisplayObject that owns this group.
     *  This should be the SystemManager of an application.
     */
	public function SWFBridgeGroup(owner:ISystemManager)
	{
        super();

		_groupOwner = owner;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

    //----------------------------------
    //  groupOwner
    //----------------------------------
	
    /**
	 *  @private
     *  The DisplayObject that owns this group.
	 */
	private var _groupOwner:ISystemManager;
	
	/**
	 *  @private
	 *  Allows communication with children that are in different sandboxes.
	 *  The sandbox bridge is used as a hash to find the display object.
	 */
	private var _childBridges:Dictionary;
	
 	//--------------------------------------------------------------------------
	//
	//  Properties: ISWFBridgeGroup
	//
	//--------------------------------------------------------------------------

    //----------------------------------
    //  parentBridge
    //----------------------------------
	
    /**
     *  @private
     */
    private var _parentBridge:IEventDispatcher;
	
    /**
     *  Allows communication with the parent
     *  if the parent is in a different sandbox.
     *  May be <code>null</code> if the parent is in the same sandbox
     *  or this is the top-level root application.
     */
	public function get parentBridge():IEventDispatcher
	{
		return _parentBridge;
	}

    /**
     *  @private
     */	
	public function set parentBridge(bridge:IEventDispatcher):void
	{
		_parentBridge = bridge;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods: ISWFBridgeGroup
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  @inheritDoc
	 */
	public function addChildBridge(bridge:IEventDispatcher, bridgeProvider:ISWFBridgeProvider):void
	{
		if (!_childBridges)
			_childBridges = new Dictionary();

		_childBridges[bridge] = bridgeProvider;
	}

	/**
	 *  @inheritDoc
	 */
	public function removeChildBridge(bridge:IEventDispatcher):void
	{
		if (!_childBridges || !bridge)
			return;
		
		for (var iter:Object in _childBridges)
		{
			if (iter == bridge)
				delete _childBridges[iter];
		}
	}

	/**
	 *  @inheritDoc
	 */
	public function getChildBridgeProvider(bridge:IEventDispatcher):ISWFBridgeProvider
	{
		if (!_childBridges)
			return null;
			
		return ISWFBridgeProvider(_childBridges[bridge]);
	}
	
	/**
	 *  @inheritDoc
	 */
	public function getChildBridges():Array
	{
		var bridges:Array = [];
		
        for (var iter:Object in _childBridges)
		{
			bridges.push(iter);
		}	
		
		return bridges;
	}

	/**
	 *  @inheritDoc
	 */
	public function containsBridge(bridge:IEventDispatcher):Boolean
	{
		if (parentBridge && parentBridge == bridge)
			return true;
			
		for (var iter:Object in _childBridges)
		{
			if (bridge == iter)
				return true;	
		}
				
		return false;
	}
}

}
