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
 *  Utilities for working with security-related issues.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
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
	 *  Tests if there is mutual trust between the parent and child of the specified bridge.
	 * 
	 *  @param bp The provider of the bridge that connects the two applications.
	 * 
	 *  @return <code>true</code> if there is mutual trust; otherwise <code>false</code>.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */ 
	public static function hasMutualTrustBetweenParentAndChild(bp:ISWFBridgeProvider):Boolean
	{
        if (bp && bp.childAllowsParent && bp.parentAllowsChild)
            return true;
            
		return false;
	}
}

}
