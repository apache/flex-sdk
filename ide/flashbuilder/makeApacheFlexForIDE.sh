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
# directory structure that the Adobe Flash Builder IDE expects.  If this is a
# source package, you must build the binaries and the RSLs first.  See the README at the 
# root for instructions.
#
# The Adobe AIR SDK and the Adobe Flash Player playerglobal.swc are integrated
# into the new directory structure.  The paths in the framework configuration files are 
# modified to reflect this.  The AIR_HOME and PLAYERGLOBAL_HOME environment variables are 
# not required because the locations of these pieces are known.
#
# Usage: makeApacheFlexForIDE [new directory to build integrated SDK]
#

# Edit these constants if you would like to download from alternative locations.

# Apache Flex binary distribution
APACHE_FLEX_BIN_DIR="$( cd $( dirname -- "$0" ) > /dev/null ; pwd )"/../..

# Adobe AIR SDK Version 3.8
ADOBE_AIR_SDK_MAC_URL=http://airdownload.adobe.com/air/mac/download/3.8/AdobeAIRSDK.tbz2

# Adobe Flash Player Version 11.1
ADOBE_FLASHPLAYER_GLOBALPLAYER_SWC_URL=http://fpdownload.macromedia.com/get/flashplayer/updaters/11/playerglobal11_1.swc

# Adobe Flex SDK v4.6
ADOBE_FLEX_SDK_URL=http://fpdownload.adobe.com/pub/flex/sdk/builds/flex4.6/flex_sdk_4.6.0.23201B.zip

FLEX_HOME="$1"

if [ "$FLEX_HOME" = "" ] ; then
    echo "Usage: $0 [new directory to build the Apache Flex SDK for Adobe Flash Builder]"
    exit 1;
fi

# quick check to see if the binaries are there
if [ ! -f "${APACHE_FLEX_BIN_DIR}/lib/mxmlc.jar" ]
then
    echo You must build the binaries for this SDK first.  See the README at the root.
    exit 1;
fi

# quick check to see if the RSLs are there
if [ ! -d "${APACHE_FLEX_BIN_DIR}/frameworks/rsls" ]
then
    echo You must build the RSLs for this SDK first.  See the README at the root.
    exit 1;
fi

# make sure the directory for the Apache Flex SDK exists
mkdir -p "$FLEX_HOME"

# the names of the tar/zip files
ADOBE_AIR_SDK_MAC_FILE=`basename "${ADOBE_AIR_SDK_MAC_URL}"`
ADOBE_FLEX_SDK_FILE=`basename "${ADOBE_FLEX_SDK_URL}"`

echo
echo "This script will construct an Adobe Flex SDK for an IDE in '$FLEX_HOME'"
echo "You will need to answer questions throughout this process."
echo

# download the Apache Flex SDK
echo "Copying the Apache Flex SDK from '$APACHE_FLEX_BIN_DIR' to '$FLEX_HOME'"
rsync -a --exclude=*/.svn* \
    --exclude="$APACHE_FLEX_BIN_DIR"/in --exclude="$APACHE_FLEX_BIN_DIR"/out \
    --exclude="$APACHE_FLEX_BIN_DIR"/temp "$APACHE_FLEX_BIN_DIR"/* "$FLEX_HOME"

# the third-party downloads, including the optional components
ant -f "$FLEX_HOME"/frameworks/downloads.xml

# put the downloads here
tempDir="$FLEX_HOME"/temp
mkdir -p "$tempDir"

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

# remove the stagging directory for downloaded software
rm -rf "$FLEX_HOME/in"
