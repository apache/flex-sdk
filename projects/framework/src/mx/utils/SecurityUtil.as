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

import mx.core.ISWFBridgeProvider;

/**
 *  Utilities for working with security issues.
 */
public class SecurityUtil
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
	public static function hasMutualTrustBetweenParentAndChild(bp:ISWFBridgeProvider):Boolean
	{
        if (bp && bp.childAllowsParent && bp.parentAllowsChild)
            return true;
            
		return false;
	}
}

}
