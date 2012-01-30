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
 *
 *  @eventType mx.events.IndexChangedEvent.CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="change")]

/**
 *  ISelectableList is an interface that indicates that the
 *  implementor is a IList that supports a selectedIndex
 *  property that should be mirrored by a listening object
 *  like a ButtonBar
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public interface ISelectableList extends IList
{
    /**
     *  The selectedIndex property that indicates the 
     *  index of a selected IList item.
     */
	function set selectedIndex(value:int):void;
	function get selectedIndex():int;
}

}
