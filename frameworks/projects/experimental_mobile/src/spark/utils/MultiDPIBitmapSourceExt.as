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
import mx.utils.DensityUtil;

public class MultiDPIBitmapSourceExt extends MultiDPIBitmapSource
{

    /**
     *  Select one of the sourceXXXdpi properties based on the given DPI.  This
     *  function handles the fallback to different sourceXXXdpi properties
     *  if the given one is null.
     *  The strategy is to try to choose the next highest
     *  property if it is not null, then return a lower property if not null, then
     *  just return null.
     *  If desiredDPI is NaN or 0, return the sourceXXXdpi for the  runtime DPI .
     *
     *  @param The desired DPI.
     *
     *  @return One of the sourceXXXdpi properties based on the desired DPI.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.6
     *  @productversion Flex 4.5
     */

    override public function getSource(desiredDPI:Number):Object
    {
        if (isNaN(desiredDPI) || (desiredDPI == 0))
        {
            var app:Object = FlexGlobals.topLevelApplication;
            var dpi:Number;
            if ("runtimeDPI" in app)
                dpi = app["runtimeDPI"];
            else
                dpi = DensityUtil.getRuntimeDPI();
            return getSource(dpi);
        }
        else
            return super.getSource(desiredDPI);
    }

    //TODO mamsellem move this code to parent class, updates any callers, and remove this class

}
}
