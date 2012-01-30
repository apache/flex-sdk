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

package mx.core
{
import flash.events.IEventDispatcher;

/**
 *  Documentation is not currently available.
 */
public interface IVisualContainer
{
    /**
     *  @copy mx.components.Group#numItems
     */
    function get numItems():int;
    
    /**
     *  @copy mx.components.Group#getItemAt
     */
    function getItemAt(index:int):Object;
    
    /**
     *  @copy mx.components.Group#getItemIndex
     */
    function getItemIndex(item:Object):int
}

}
