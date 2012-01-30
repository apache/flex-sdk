////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.utils
{

import flash.utils.getTimer;

import mx.core.mx_internal;

[ExcludeClass]
    
/**
 *  @private
 *  The GetTimerUtil utility class is an all-static class
 *  with methods for grabbing the relative time from a Flex 
 *  application.  This class exists so tests can consistently 
 *  run with the same time values.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class GetTimerUtil
{
    //--------------------------------------------------------------------------
    //
    //  Class properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private static var _getTimerFunction:Function = flash.utils.getTimer;
    
    /**
     *  @private
     *  The function to use when calculate the current time.  By default, 
     *  this is <code>flash.utils.getTimer</code>.  When run in a testing 
     *  environment, one may change this function in order to get consistent
     *  results when running tests.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    mx_internal static function get getTimerFunction():Function
    {
        return _getTimerFunction;
    }
    
    /**
     *  @private
     */
    mx_internal static function set getTimerFunction(value:Function):void
    {
        _getTimerFunction = value;
    }
}
}