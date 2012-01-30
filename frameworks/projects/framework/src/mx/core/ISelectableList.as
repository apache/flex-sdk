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
 *  Dispatched when the <code>selectedIndex</code> property changes.
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
 *  Dispatched when the <code>selectedIndex</code> property changes.
 *
 *  @eventType mx.events.FlexEvent.VALUE_COMMIT
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="valueCommit")]

/**
 *  The ISelectableList interface indicates that the
 *  implementor is an IList element that supports a <code>selectedIndex</code>
 *  property.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public interface ISelectableList extends IList
{
    /**
     *  The index of the selected IList item.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function set selectedIndex(value:int):void;
    function get selectedIndex():int;
}

}
