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

package mx.utils
{

import flash.events.IEventDispatcher;

import mx.sandbox.ISandboxBridgeGroup;
import mx.managers.ISystemManager;

/**
 *  Utilities for working with sandboxes.
 */
public class SandboxUtil
{
	include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  Tests if there is mutual trust between a SystemManager and its parent.
	 */ 
	public static function hasMutualTrustWithParent(sm:ISystemManager):Boolean
	{
		var sandboxBridgeGroup:ISandboxBridgeGroup = sm.sandboxBridgeGroup;
		
		if (sandboxBridgeGroup.parentBridge &&
			sandboxBridgeGroup.canAccessParentBridge() &&
		    sandboxBridgeGroup.accessibleFromParentBridge())
        {
			return true;
        }

		return false;
	}


	/**
	 *  Tests if there is mutual trust between a SystemManager
     *  and one of its bridged applications.
	 */ 
	public static function hasMutualTrustWithChild(
                                sm:ISystemManager,
                                bridge:IEventDispatcher):Boolean
	{
		var sandboxBridgeGroup:ISandboxBridgeGroup = sm.sandboxBridgeGroup;
		
		if (sandboxBridgeGroup.canAccessChildBridge(bridge) &&
		    sandboxBridgeGroup.accessibleFromChildBridge(bridge))
        {
			return true;
        }

		return false;
	}
}

}
