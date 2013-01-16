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
# Usage: checkAllPlayerGlobals "Apache Flex dir"
#
# This script should be used to check all versions of playerglobal.swc in an
# Apache Flex SDK for Mac OSX
# If a player global is missing to it will be downloaded form the Adobe site.

# Process the parameters.

IDE_SDK_DIR="$1"
if [ "${IDE_SDK_DIR}" = "" ] ; then
    echo Usage: $0 "Apache Flex directory"
    exit 1;
fi

echo The Apache Flex directory for the IDE is "$IDE_SDK_DIR"

# If this is an Apache Flex dir then there should be a NOTICE file.

if [ ! -f "${IDE_SDK_DIR}/NOTICE" ]
then
    echo ${IDE_SDK_DIR} does not appear to be an Apache Flex distribution.
    exit 1;
fi

downloadPlayerGlobal()
{
	version=$1
    playerGlobalDir="${IDE_SDK_DIR}/frameworks/libs/player/${version}"
    playerGlobalSWC="${playerGlobalDir}/playerglobal.swc"
    MD5check=$2
    AdobeURL=$3
    
	mkdir -p "${playerGlobalDir}"
	if [ ! -f "${playerGlobalSWC}" ]
	then
	    echo Downloading player global ${version}
	    curl ${AdobeURL} > "${playerGlobalSWC}"
	else
		echo Player global ${version} exists
	fi
	
	MD5hash=`md5 -q "${playerGlobalSWC}"`
	
	if [ ${MD5check} == ${MD5hash} ]
	then
		echo MD5 hash correct
	else
		echo MD5 hash incorrect
	fi
	
}

downloadPlayerGlobal 10.2 aa7d785dd5715626201f5e30fc1deb51 http://fpdownload.macromedia.com/get/flashplayer/installers/archive/playerglobal/playerglobal10_2.swc
downloadPlayerGlobal 10.3 6092b3d4e2784212d174ca10904412bd http://fpdownload.macromedia.com/get/flashplayer/installers/archive/playerglobal/playerglobal10_3.swc
downloadPlayerGlobal 11.0 5f5a291f02105cd83fb582b76646e603 http://fpdownload.macromedia.com/get/flashplayer/updaters/11/playerglobal11_0.swc
downloadPlayerGlobal 11.1 e3a0e0e8c703ae5b1847b8ac25bbdc5f http://fpdownload.macromedia.com/get/flashplayer/updaters/11/playerglobal11_1.swc
downloadPlayerGlobal 11.2 c544a069518897880e0d732457b6fdeb http://fpdownload.macromedia.com/get/flashplayer/updaters/11/playerglobal11_2.swc
downloadPlayerGlobal 11.3 e2a9ee439d9660feaf756aa05e7e6412 http://fpdownload.macromedia.com/get/flashplayer/updaters/11/playerglobal11_3.swc
downloadPlayerGlobal 11.4 e15587856cdb5e21fa1acb6b0610a032 http://fpdownload.macromedia.com/get/flashplayer/updaters/11/playerglobal11_4.swc
downloadPlayerGlobal 11.5 54bb87668ae9d6b6e61cc61fd487b6a0 http://fpdownload.macromedia.com/get/flashplayer/updaters/11/playerglobal11_5.swc

