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

agreeLicense()
{
	echo
	echo Playerglobal.swc is part of the Adobe Flash Player and is licensed
	echo "under the the Flash Player end user license agreement (EULA)."
	echo
	echo The 10.2 and 10.3 Flash Player EULA is specified here:
	echo http://www.adobe.com/products/eulas/pdfs/PlatformClients_PC_WWEULA_Combined_20100108_1657.pdf
	echo
	echo The 11.X Flash Player EULA is specified here:
	echo http://www.adobe.com/products/eulas/pdfs/PlatformClients_PC_WWEULA-MULTI-20110809_1357.pdf
	echo
	echo In addition to the Adobe EULA license terms, you also agree to be bound by the third-party
	echo terms specified here:
	echo http://www.adobe.com/products/eula/third_party/
	echo
	echo Adobe recommends that you review all licensing terms.
	echo
	echo "Please type Y to agree to terms of the license >"
	
	read -n 1 accept
	echo
		
	if [[ "${accept}" = "Y" || "${accept}" = "y" ]]
	then
	   echo License accepted
	else
		exit 1;
	fi
}

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
            echo Downloading player global ${version}
            curl ${AdobeURL} > "${playerGlobalSWC}"
	fi
}

agreeLicense

# Note Adobe releases new versions of playerglobal.swf so if your checksum is wrong it may mean you just don't have the latest

downloadPlayerGlobal 10.2 d51dba4e5e6bb72faffd9803d021bd7d http://download.macromedia.com/get/flashplayer/installers/archive/playerglobal/playerglobal10_2.swc
downloadPlayerGlobal 10.3 8655be1b04af7109e46a0cb0d1be546e http://download.macromedia.com/get/flashplayer/installers/archive/playerglobal/playerglobal10_3.swc
downloadPlayerGlobal 11.0 09ff39b8a7d946a49992674aff873c2d http://download.macromedia.com/get/flashplayer/updaters/11/playerglobal11_0.swc
downloadPlayerGlobal 11.1 70fec4b0b786965dc7bc413b9ee807f0 http://download.macromedia.com/get/flashplayer/updaters/11/playerglobal11_1.swc
downloadPlayerGlobal 11.2 7aa7b0d9e57186d4d92c5932f94d8b80 http://download.macromedia.com/get/flashplayer/updaters/11/playerglobal11_2.swc
downloadPlayerGlobal 11.3 aaa2f1f31c7cdd6f5af2cda9ca63cd8f http://download.macromedia.com/get/flashplayer/updaters/11/playerglobal11_3.swc
downloadPlayerGlobal 11.4 f32d2e50d2bbfa1c1667425072a1b9ca http://download.macromedia.com/get/flashplayer/updaters/11/playerglobal11_4.swc
downloadPlayerGlobal 11.5 a1d9f6363aa1de5d07ca3002a2817da4 http://download.macromedia.com/get/flashplayer/updaters/11/playerglobal11_5.swc
downloadPlayerGlobal 11.6 fa2441bdb8c823bc284ce96ec2198f26 http://download.macromedia.com/get/flashplayer/updaters/11/playerglobal11_6.swc
downloadPlayerGlobal 11.7 78dae2a89297389079dc926852a2a9bc http://download.macromedia.com/get/flashplayer/updaters/11/playerglobal11_7.swc
downloadPlayerGlobal 11.8 cd0bead4aba52bc634df30d3e93196ba http://download.macromedia.com/get/flashplayer/updaters/11/playerglobal11_8.swc
downloadPlayerGlobal 11.9 463f60f1bf5006b37c48d49723c7c558 http://download.macromedia.com/get/flashplayer/updaters/11/playerglobal11_9.swc
downloadPlayerGlobal 12.0 1a7b05bb2c776de38197113e40667126 http://download.macromedia.com/get/flashplayer/updaters/12/playerglobal12_0.swc
downloadPlayerGlobal 13.0 07db042296350b04ae19e98f64a55ea1 http://download.macromedia.com/get/flashplayer/updaters/13/playerglobal13_0.swc
downloadPlayerGlobal 14.0 6858e63b1ff8373a1a3c1c60b36c9fc9 http://download.macromedia.com/get/flashplayer/updaters/14/playerglobal14_0.swc
downloadPlayerGlobal 15.0 4d17b14ef74dd23377a71a3fdbfda8ad http://download.macromedia.com/get/flashplayer/updaters/15/playerglobal15_0.swc
downloadPlayerGlobal 16.0 336be79e5b3ed665c98308241381aff3 http://download.macromedia.com/get/flashplayer/updaters/16/playerglobal16_0.swc
downloadPlayerGlobal 17.0 1a5e68003b5ce6af08f3841bdb2b96ee http://download.macromedia.com/get/flashplayer/updaters/17/playerglobal17_0.swc
downloadPlayerGlobal 17.0b 2bd048da880ab3b9516bdf1f263a3135 http://labsdownload.adobe.com/pub/labs/flashruntimes/flashplayer/flashplayer17_playerglobal.swc
