////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.core
{
import mx.managers.IToolTipManagerClient;

/**
 *  NavigatorContent is an IDeferredContentOwner with label and icon properties
 *  that dispatch notifications when those properties change
 */
public interface INavigatorContent extends IDeferredContentOwner, IToolTipManagerClient
{
    [Bindable("labelChanged")]
	function get label():String;

    [Bindable("iconChanged")]
	function get icon():Class;
}

}