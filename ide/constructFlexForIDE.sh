#!/bin/sh -e

################################################################################
##
##  Licensed to the Apache Software Foundation (ASF) under one or more
##  contributor license agreements.  See the NOTICE file distributed with
##  this work for additional information regarding copyright ownership.
##  The ASF licenses this file to You under the Apache License, Version 2.0
##  (the "License"); you may not use this file except in compliance with
##  the License.  You may obtain a copy of the License at
##
##      http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.
##
################################################################################

#
# Usage: constructFlexForIDE "Apache Flex dir" ["Adobe Flex 4.6 dir"]
#
# This script should be used to create an Apache Flex SDK for Mac OSX that has the 
# directory structure that the an IDE that supports Flex, such as Adobe Flash Builder or
# JetBrains IntelliJ expects. 
# 
# This script can be used with either an Apache Flex binary package or an Apache Flex 
# source package.  In either case you must unzip the package.  If you use the source 
# package you must build the binaries files before running this script.  See the 
# "Building the Source in the Source Distribution" section in the README at the root 
# for build instructions.
#
# The Adobe AIR SDK for Mac and the Adobe Flash Player playerglobal.swc are copied into 
# the Apache Flex directory.  The paths in the framework configuration files 
# are modified to reflect this.  You do not need to set up any of the environment
# variables mentioned in the README because the locations of all the software are known 
# in this configuration.
#
# OSMF, swobject, the Adobe embedded font support, and Adobe BlazeDS integration all
# come from the Adobe Flex 4.6 SDK.  You should be aware that these components have
# their own licenses that may or may not be compatible with the Apache v2 license.
# See the "Software Dependencies" section in the README for more license information.
#
#  If the Adobe Flex SDK 4.6 directory is not specified this script will look for it
#  in the following places, and if not found, will prompt for the directory.
#
#  /Applications/Adobe Flash Builder 4.5/sdks/4.6.0
#  /Applications/Adobe Flash Builder 4.6/sdks/4.6.0
#  /Applications/Adobe Flash Builder 4.7/sdks/4.6.0
#
# The Adobe Flex 4.6 SDK is available here:
#      http://www.adobe.com/devnet/flex/flex-sdk-download.html

# copyFileOrDirectory from ADOBE_FLEX_SDK_DIR to IDE_SDK_DIR
#   param1 is file or directory to copy
copyFileOrDirectory()
{
    f="$1"
    
    echo Copying $f
    
    dir=`dirname "${IDE_SDK_DIR}/$f"`

    if [ -f "${ADOBE_FLEX_SDK_DIR}/$f" ] ; then
        mkdir -p "${dir}"
        cp -p "${ADOBE_FLEX_SDK_DIR}/$f" "${IDE_SDK_DIR}/$f"
    fi

    if [ -d "${ADOBE_FLEX_SDK_DIR}/$f" ] ; then
        rsync --archive --ignore-existing --force "${ADOBE_FLEX_SDK_DIR}/$f" "${dir}"
    fi
}

# Process the parameters.

IDE_SDK_DIR="$1"
if [ "${IDE_SDK_DIR}" = "" ] ; then
    echo Usage: $0 "Apache Flex dir" ["Adobe Flex SDK 4.6 dir"]
    exit 1;
fi

echo The Apache Flex directory for the IDE is "$IDE_SDK_DIR"

# If this is an Apache Flex dir then there should be a NOTICE file.

if [ ! -f "${IDE_SDK_DIR}/NOTICE" ]
then
    echo ${IDE_SDK_DIR} does not appear to be an Apache Flex distribution.
    exit 1;
fi

# Quick check to see if there are binaries in the Apache distribution.

if [ ! -f "${IDE_SDK_DIR}/lib/mxmlc.jar" ]
then
    echo ${IDE_SDK_DIR} does not appear to be a Apache Flex distribution with binaries.
    echo If this is a source distribution of Apache Flex you must build the binaries first.
    echo See the README.
    exit 1;
fi

# FlashBuilder requires the frameworks/rsls directory.

if [ ! -d "${IDE_SDK_DIR}/frameworks/rsls" ]
then
    echo ${IDE_SDK_DIR} does not appear to be a Apache Flex distribution with rsls.
    echo If this is a source distribution of Apache Flex you must first build the rsls.
    echo Build rsls via 'ant frameworks-rsls' in the Apache Flex directory.
    exit 1;
fi

if [ "$2" = "" ]
then
    #  Look for installed FlashBuilder versions 4.5, 4.6 and 4.7.
    if [ -d "/Applications/Adobe Flash Builder 4.5/sdks/4.6.0" ]
    then
        ADOBE_FLEX_SDK_DIR="/Applications/Adobe Flash Builder 4.5/sdks/4.6.0"
    elif [ -d "/Applications/Adobe Flash Builder 4.6/sdks/4.6.0" ]
    then
        ADOBE_FLEX_SDK_DIR="/Applications/Adobe Flash Builder 4.6/sdks/4.6.0"
    elif [ -d "/Applications/Adobe Flash Builder 4.7/sdks/4.6.0" ]
    then
        ADOBE_FLEX_SDK_DIR="/Applications/Adobe Flash Builder 4.7/sdks/4.6.0"
    else
        #  Couldn't find default Adobe Flex SDK so ask for it.
        while [ -z "$ADOBE_FLEX_SDK_DIR" ]
        do
            echo 'Enter directory of an Adobe Flex SDK 4.6: \c'
            read ADOBE_FLEX_SDK_DIR
        done
    fi
else
    ADOBE_FLEX_SDK_DIR="$2"
fi

echo The Adobe Flex directory is "${ADOBE_FLEX_SDK_DIR}"
echo

# Quick check to see if it is a Flex SDK.
if [ ! -f "${ADOBE_FLEX_SDK_DIR}/license-adobesdk.htm" ]
then
    echo ${ADOBE_FLEX_SDK_DIR} does not appear to be an Adobe Flex SDK
    exit 1;
fi

# Copy all the AIR SDK files to the IDE SDK.
# Copy files first, then directories.

echo Copying the AIR SDK files to directory "${IDE_SDK_DIR}"

files=(
    "AIR SDK license.pdf" 
    "AIR SDK Readme.txt" 
    bin/adl.exe 
    bin/adt.bat 
    frameworks/libs/air
    frameworks/libs/player/11.1
    frameworks/projects/air
    include
    install/android
    lib/adt.jar 
    lib/android
    lib/aot
    lib/nai
    lib/win
    runtimes
    samples/badge
    samples/descriptor-sample.xml
    samples/icons
    templates/air
    templates/extensions)
for file in "${files[@]}" 
do
    copyFileOrDirectory "$file"
done

# Copy all the third-party files from the Adobe Flex SDK to the IDE SDK.

echo
echo Copying the third-party files to directory "${IDE_SDK_DIR}"

files=(
    frameworks/libs/osmf.swc
    frameworks/libs/player/11.1
    frameworks/javascript/fabridge/samples/fabridge/swfobject
    lib/flex-messaging-common.jar
    lib/afe.jar
    lib/aglj40.jar
    lib/flex-fontkit.jar
    lib/rideau.jar
    templates/swfobject/swfobject.js)
for file in "${files[@]}" 
do
    copyFileOrDirectory $file
done

# Copy config files formatted for IDE to frameworks.
echo
echo Copying frameworks config files configured for use without environment variables
cp -p -v -f "$IDE_SDK_DIR"/ide/flashbuilder/config/*-config.xml "$IDE_SDK_DIR/frameworks"
