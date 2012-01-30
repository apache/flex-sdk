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
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public interface INavigatorContent extends IDeferredContentOwner, IToolTipManagerClient
{
    [Bindable("labelChanged")]
    /**
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get label():String;

    [Bindable("iconChanged")]
    /**
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get icon():Class;
}

}