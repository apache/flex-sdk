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
cp -p -v "$FLEX_HOME"/ide/flashbuilder/flashbuilder-config.xml "$FLEX_HOME"

# remove the zipped kits
rm -rf "$tempDir"