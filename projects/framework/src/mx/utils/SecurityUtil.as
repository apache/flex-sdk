////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.utils
{

import mx.sandbox.ISandboxBridgeGroup;
import mx.managers.ISystemManager2;


/**
 * Utilities for working with sandboxes.
 */
public class SandboxUtil
{
	public function SandboxUtil()
	{
	}

	/**
	 * Test if there is mutual trust between a SystemManager and its parent.
	 */ 
	public static function mutualTrustWithParent(sm:ISystemManager2):Boolean
	{
		var sandboxBridgeGroup:ISandboxBridgeGroup = sm.sandboxBridgeGroup;
		
		if (sandboxBridgeGroup.parentBridge &&
			sandboxBridgeGroup.canAccessParentBridge() &&
		    sandboxBridgeGroup.accessibleFromParentBridge())
			return true;

		return false;
	}

}
}