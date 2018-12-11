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
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

/** @private
 * Helper class for computing device -dependent platform capabilities.
 * This class should not be used directly.
 */

public class PlatformMobileHelper
{
    /** Function to retrieve OS version string on Android devices, in X.Y.Z format.
     * On Android, Capabilities.os contains the Linux kernel version (such as Linux 3.4.34-1790463), not the Android version.
     * So the version information must be  retrieved from an internal file:   <code> /system/build.prop</code>
     * as <code>ro.build.version.release</code>  property value.
     *
     * @return the OS version as "X.Y.Z" string, or "" (empty string) if not found.
     *
     * @see mx.utils.Platform
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.13
     */
    public static function computeOSVersionForAndroid(): String
    {
        var version: String = "";

        var file: File = new File();
        var fs: FileStream = new FileStream();
        file.nativePath = "/system/build.prop";
        if (file.exists) {
            try {
                var osVersionMatch: Array;
                fs.open(file, FileMode.READ);
                var content: String = fs.readUTFBytes(file.size);
                osVersionMatch = content.match(/ro.build.version.release=([\d\.]+)/);
                if (osVersionMatch && osVersionMatch.length == 2)
                    version = osVersionMatch[1];
            }
            catch (e: Error) {
                // trace the error, and return empty string
                trace("Error while reading build.prop file:" + e.message);
            }
            finally {
                if (fs)
                    fs.close();
            }
        }
        return version;
    }
}
}
