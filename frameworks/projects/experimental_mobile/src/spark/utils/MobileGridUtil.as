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
package spark.utils
{

import mx.core.DPIClassification;
import mx.core.FlexGlobals;
import mx.managers.SystemManager;

import spark.components.Application;

/**
 * @private
 * Utility class for MobileGrid
 *
 *  @langversion 3.0
 *  @playerversion AIR 3.8
 *  @productversion Flex 4.11

 */

    // for asdoc
[Experimental]

public class MobileGridUtil
{

    private static var _setApplicationDPI:Number = 0;

    /**  returns the actual  value for  a value authored for  <code>sourceDPI</code>, taking into account any dpi scaling.
     *  <ul>
     *      <li> If Application.applicationDPI has been set, which means dpi scaling factor is already applied, return the original value.</li>
     *     <li> If Application.applicationDPI has not been set, then return scaled value runTimeDPI / sourceDPI   </li>
     *  </li>
     * @param sourceDPI
     * @return  scaled value
     */
    public static function dpiScale(value:Number, sourceDPI:Number = DPIClassification.DPI_160):Number
    {
        var appDPI:Number = getSetApplicationDPI();
        if (isNaN(appDPI))
        {
            var runDPI:Number = FlexGlobals.topLevelApplication.runtimeDPI;
            return value * runDPI / sourceDPI;
        }
        else
            return value; //  already scaled
    }

    /**
     *  returns the applicationDPI that was explicitly set in top level application , or NaN if none */
    private static function getSetApplicationDPI():Number
    {
        if (_setApplicationDPI == 0)
        {
            var application:Application = FlexGlobals.topLevelApplication as Application;
            var sm:SystemManager = application ? application.systemManager as SystemManager : null;
            _setApplicationDPI = sm ? sm.info()["applicationDPI"] : NaN;
        }
        return _setApplicationDPI;
    }

}
}
