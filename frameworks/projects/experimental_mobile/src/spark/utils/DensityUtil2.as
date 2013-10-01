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

import mx.core.FlexGlobals;
import mx.core.mx_internal;
import mx.managers.SystemManager;

import spark.components.Application;

public class DensityUtil2
{

    use namespace mx_internal;

    private static var _setApplicationDPI:Number = 0;

    /**  Calculates a scale factor to be used when element authored for  <code>sourceDPI</code>
     *   two algorithms: <br/>
     *   Application.applicationDPI has been set, which means scaling factor  occurs already, so additional scaling is required, return 1
     *  Application.applicationDPI has not been set, then return runTimeDPI / sourceDPI
     *  examples:
     *  runtimeDPI = 320 and sourceDPI = 160 and  applicationDPI not set  (ie=320) => 2
     *  runtimeDPI = 160 and sourceDPI = 160 and applicationDPI not set (ie=160)  => 1
     *  runtimeDPI = 160 and sourceDPI = 160 and applicationDPI = 160 => 1
     *  runtimeDPI = 320 and sourceDPI = 160 and applicationDPI = 160 => 1 (scaling occurs)
     * @param sourceDPI
     * @return  scale factor
     */

    public static function getPostDPIScale(sourceDPI:Number):Number
    {

        var appDPI:Number = getSetApplicationDPI();
        if (isNaN(appDPI))
        {
            // was not set,
            var runDPI:Number = FlexGlobals.topLevelApplication.runtimeDPI;
            return runDPI / sourceDPI;
        }
        else
            return 1.0; //  already scaled
    }


    public static function dpiScale(value:Number, sourceDPI:Number):Number
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
