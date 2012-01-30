////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package mx.utils
{

import flash.utils.getTimer;

import mx.core.mx_internal;

use namespace mx_internal;

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
    mx_internal static var fakeTimeValue:* = undefined;
    
    /**
     *  @private
     *  The function to use when calculating the current time.  
     *  
     *  <p>When run in a testing 
     *  environment, one may change this function in order to get consistent
     *  results when running tests by modifying fakeTimeValue.  
     *  If fakeTimeValue is undefined, <code>flash.utils.getTimer()</code> is 
     *  used.  Otherwise, fakeTimeValue is returned.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    mx_internal static function getTimer():int
    {
        if (fakeTimeValue !== undefined)
            return fakeTimeValue;
        
        return flash.utils.getTimer();
    }
}
}