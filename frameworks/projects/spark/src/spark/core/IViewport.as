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

package flex.intf
{
import flash.events.IEventDispatcher;

public interface IViewport extends IEventDispatcher
{
    function get width():Number;
    function get height():Number;
    
    function get contentWidth():Number;
    function get contentHeight():Number;

    function get verticalScrollPosition():Number;
    function set verticalScrollPosition(value:Number):void;
    
    function get horizontalScrollPosition():Number;
    function set horizontalScrollPosition(value:Number):void;
    
    function verticalScrollPositionDelta(unit:uint):Number
    function horizontalScrollPositionDelta(unit:uint):Number
    
    function get clipContent():Boolean;
    function set clipContent(value:Boolean):void;    
}

}
