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

# This script should be used to create an Apache Flex SDK that has the
# directory structure that the Adobe Flash Builder IDE expects.
#
# The Adobe AIR SDK and the Adobe Flash Player playerglobal.swc are integrated
# into the directory structure.  The paths in the framework configuration files are 
# modified to reflect this.  The AIR_HOME and PLAYERGLOBAL_HOME environment variables are 
# not required because the locations of these pieces are known.
#
# Usage: makeApacheFlexForFlashBuilder [sdk directory]
#

# Edit these constants if you would like to download from alternative locations.

# Apache Flex binary distribution
APACHE_FLEX_BIN_DISTRO_URL=http://people.apache.org/~cframpton/ApacheFlexRC/current/apache-flex-sdk-4.8.0-incubating-bin.zip

# Adobe AIR SDK Version 3.1
ADOBE_AIR_SDK_MAC_URL=http://airdownload.adobe.com/air/mac/download/3.1/AdobeAIRSDK.tbz2

# Adobe Flash Player Version 11.1
ADOBE_FLASHPLAYER_GLOBALPLAYER_SWC_URL=http://fpdownload.macromedia.com/get/flashplayer/updaters/11/playerglobal11_1.swc

# Adobe Flex SDK v4.6
ADOBE_FLEX_SDK_URL=http://fpdownload.adobe.com/pub/flex/sdk/builds/flex4.6/flex_sdk_4.6.0.23201B.zip

FLEX_HOME="$1"

if [ "$FLEX_HOME" = "" ] ; then
    echo "Usage: $0 [directory to build the Apache Flex SDK for Adobe Flash Builder]"
    exit 1;
fi

# make sure the directory for the Apache Flex SDK exists
mkdir -p "$FLEX_HOME"

# put the downloads here
tempDir="$FLEX_HOME"/temp
mkdir -p "$tempDir"

# the names of the tar/zip files
APACHE_FLEX_BIN_DISTRO_FILE=`basename "${APACHE_FLEX_BIN_DISTRO_URL}"`
ADOBE_AIR_SDK_MAC_FILE=`basename "${ADOBE_AIR_SDK_MAC_URL}"`
ADOBE_FLEX_SDK_FILE=`basename "${ADOBE_FLEX_SDK_URL}"`

function echo_adobe_flex_sdk_license()
{
        echo
        echo "Adobe Flex SDK License Agreement:"
        echo
        echo "All files contained in this Adobe Flex SDK download are subject to and governed by the"
        echo "Adobe Flex SDK License Agreement specified here:"
        echo "    http://www.adobe.com/products/eulas/pdfs/adobe_flex_software_development_kit-combined-20110916_0930.pdf," 
        echo "By downloading, modifying, distributing, using and/or accessing any files in this Adobe Flex SDK,"
        echo "you agree to the terms and conditions of the applicable end user license agreement."
        echo
        echo "In addition to the Adobe license terms, you also agree to be bound by the third-party terms specified here:"
        echo "    http://www.adobe.com/products/eula/third_party/."
        echo "Adobe recommends that you review these third-party terms."
        echo
}

function download_adobe_flex_sdk()
{
    if [ -z $adobeFlexSDKDownloaded ]
    then
        curl "$ADOBE_FLEX_SDK_URL" --output "$tempDir/$ADOBE_FLEX_SDK_FILE"
        mkdir -p "$tempDir"/flexSDK  
        tar xf "$tempDir/$ADOBE_FLEX_SDK_FILE" -C "$tempDir/flexSDK"
        
        # q is fast-read so it extracts the first file matched.
        tar xvqf "$tempDir/$ADOBE_FLEX_SDK_FILE" -C "$tempDir" license-adobesdk.htm
        
        adobeFlexSDKDownloaded=true
    fi
}

# Ask about optional integration with Adobe BlazeDS (Data Services)
echo
echo ===========================================================================
echo "Apache Flex can optionally integrate with Adobe BlazeDS."
echo
echo "This feature requires flex-messaging-common.jar from the Adobe Flex SDK."
echo "The Adobe SDK license agreement for Adobe Flex 4.6 applies to this jar."
echo "This license is not compatible with the Apache v2 license."
echo ===========================================================================
echo_adobe_flex_sdk_license
read -p "Do you want to install the BlazeDS support from the Adobe Flex SDK? (y/[n]) " ADOBE_BLAZEDS_RESP

# Ask about optional integration with the Adobe Embedded Font Support.
echo
echo ===========================================================================        
echo "Apache Flex can optionally integrate with Adobe's embedded font support."
echo
echo "This feature requires a few font jars from the Adobe Flex SDK."
echo "The Adobe SDK license agreement for Adobe Flex 4.6 applies to these jars."
echo "This license is not compatible with the Apache v2 license."
echo ===========================================================================
echo_adobe_flex_sdk_license
read -p "Do you want to install the embedded font support from the Adobe Flex SDK? (y/[n]) " ADOBE_FONT_RESP
echo

# Now do the optional integration, if requested.
if [ "$ADOBE_BLAZEDS_RESP" = "y" ]; then
    download_adobe_flex_sdk
    
    mkdir -p "$FLEX_HOME/lib/external/optional"    
    tar xvqf "$tempDir/$ADOBE_FLEX_SDK_FILE" -C "$FLEX_HOME/lib/external/optional" --strip-components 1 lib/flex-messaging-common.jar
    cp -v "$tempDir/license-adobesdk.htm" "$FLEX_HOME/lib/external/optional/flex-messaging-common-LICENSE.htm"
fi

if [ "$ADOBE_FONT_RESP" = "y" ]; then
    download_adobe_flex_sdk

    mkdir -p "$FLEX_HOME/lib/external/optional"
    
    tar xvqf "$tempDir/$ADOBE_FLEX_SDK_FILE" -C "$FLEX_HOME/lib/external/optional" --strip-components 1  lib/afe.jar
    tar xvqf "$tempDir/$ADOBE_FLEX_SDK_FILE" -C "$FLEX_HOME/lib/external/optional" --strip-components 1 lib/aglj40.jar
    tar xvqf "$tempDir/$ADOBE_FLEX_SDK_FILE" -C "$FLEX_HOME/lib/external/optional" --strip-components 1 lib/flex-fontkit.jar
    tar xvqf "$tempDir/$ADOBE_FLEX_SDK_FILE" -C "$FLEX_HOME/lib/external/optional" --strip-components 1 lib/rideau.jar
    
    cp -v "$tempDir/license-adobesdk.htm" "$FLEX_HOME/lib/external/optional/afe-LICENSE.htm"
    cp -v "$tempDir/license-adobesdk.htm" "$FLEX_HOME/lib/external/optional/aglj40-LICENSE.htm"
    cp -v "$tempDir/license-adobesdk.htm" "$FLEX_HOME/lib/external/optional/flex-fontkit-LICENSE.htm"
    cp -v "$tempDir/license-adobesdk.htm" "$FLEX_HOME/lib/external/optional/rideau.jar-LICENSE.htm"
fi

# download the Apache Flex SDK
echo "Downloading the Apache Flex SDK from $APACHE_FLEX_BIN_DISTRO_URL"
curl "$APACHE_FLEX_BIN_DISTRO_URL" --output "$tempDir/$APACHE_FLEX_BIN_DISTRO_FILE"
tar xf "$tempDir/$APACHE_FLEX_BIN_DISTRO_FILE" -C "$FLEX_HOME"

# download the AIR SDK for Mac
echo "Downloading the Adobe AIR SDK for Mac from $ADOBE_AIR_SDK_MAC_URL"
curl "$ADOBE_AIR_SDK_MAC_URL" --output "$tempDir/$ADOBE_AIR_SDK_MAC_FILE"
tar xf "$tempDir/$ADOBE_AIR_SDK_MAC_FILE" -C "$FLEX_HOME"

# download playerglobal.swc
echo "Downloading Adobe Flash Player playerglobal.swc from $ADOBE_FLASHPLAYER_GLOBALPLAYER_SWC_URL"
mkdir -p "$FLEX_HOME/frameworks/libs/player/11.1"
curl "$ADOBE_FLASHPLAYER_GLOBALPLAYER_SWC_URL" --output "$FLEX_HOME/frameworks/libs/player/11.1/playerglobal.swc" --silent

# copy the config files formatted for Flash Builder to frameworks 
echo "Installing the frameworks config files configured for use with Adobe Flash Builder"
cp -p -v "$FLEX_HOME"/ide/flashbuilder/config/*-config.xml "$FLEX_HOME/frameworks"

# remove the zipped kits
rm -rf "$tempDir"