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
import mx.collections.IList;

/**
 *  Dispatched when the selectedIndex property changes.
 *  This may be dispatched as well as a CHANGE event, but
 *  INavigatable listeners need to be sure that a CHANGE
 *  event really does mean that selectedIndex changed
 *  and not that some other key property of the INavigatable
 *  changed.
 *
 *  @eventType mx.events.FlexEvent.NAVIGATION_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="navigationChange")]

/**
 *  INavigatable is an interface that indicates that the
 *  implementor is a Navigator and supports a selectedIndex
 *  property that should be mirrored by a listening object
 *  like a ButtonBar
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public interface INavigatable extends IList
{
    /**
     *  The selectedIndex property that selects which
     *  child the Navigator is viewing.
     */
	function set selectedIndex(value:int):void;
	function get selectedIndex():int;
}

}
