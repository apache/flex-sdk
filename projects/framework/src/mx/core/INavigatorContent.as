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
 *  The INavigatorContent interface defines the interface that a container must 
 *  implement to be used as the child of a navigator container, 
 *  such as the ViewStack, TabNavigator, and Accordion navigator containers.
 *
 *  @see mx.containers.Accordion
 *  @see mx.containers.TabNavigator
 *  @see mx.containers.ViewStack
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
     *  The text displayed by the navigator container for this container.
     *  For example, the text appears in the button area of an Accordion container
     *  and in the tab area of the TabNavigator container.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get label():String;

    [Bindable("iconChanged")]
    /**
     *  The icon displayed by the navigator container for this container.
     *  The icon appears in the button area of an Accordion container
     *  and in the tab area of the TabNavigator container.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get icon():Class;
}

}