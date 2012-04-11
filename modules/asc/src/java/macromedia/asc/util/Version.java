/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package macromedia.asc.util;

// build version info

// build number counts 1-n for development builds, and restarts at 1-n for release builds

// the visible build code d for development, r for release candidate

public class Version {
    public static final String ASC_BUILD_CODE ="cyclone";

    public static final String ASC_VERSION_USER = "1.0";

    // Version codes
    // Major version, minor version, build number high order value, build number low order value
    public static final String ASC_VERSION_NUMBER = "1,0,0,100";
    public static final String ASC_VERSION_STRING = "1,0,0,100";
    public static final int ASC_MAJOR_VERSION = 1;
    public static final int ASC_MINOR_VERSION = 0;
    public static final int ASC_BUILD_NUMBER = 0;

    // Define Mac only resource change to 'vers' resource so that player installer will
    // replace previous player versions
    public static final int ASC_MAC_RESOURCE_MINOR_VERSION	= 0x00;
}

