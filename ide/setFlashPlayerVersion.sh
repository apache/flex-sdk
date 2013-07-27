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
# Usage: setFlashPlayerVersion "Apache Flex directory" "Flash Player version" 
#
# This script will configure an Apache Flex SDK to use a minimum version of the FLash Player

# Process the parameters.

IDE_SDK_DIR="$1"
if [ "${IDE_SDK_DIR}" = "" ]
then
    echo Usage: $0 "Apache Flex directory"
    echo Or
    echo Usage: $0 "Apache Flex directory" "Flash Player version"  
    exit 1;
fi

echo The Apache Flex directory for the IDE is "$IDE_SDK_DIR"

FLASH_VERSION="$2"

askYesNo() {
	read -n 1 accept
	echo
		
    yesNo="N"
		
	if [[ "${accept}" = "Y" || "${accept}" = "y" ]]
	then
	   yesNo="Y"
	fi
}

determineVersion()
{
    echo
    echo "Do you want to use the latest version of the Flash Player?"
    askYesNo
    latest=$yesNo
    echo
    
    if [ $latest = "N" ]
    then
	    echo "Do you need to support all older versions of the Flash Player?"
	    askYesNo
	    legacy=$yesNo
	    echo
	else
	    legacy="N"
	fi
	
    echo "Do you want to create browser based applications?"
    askYesNo
    useBrowser=$yesNo
    echo
    echo "Do you want to create desktop applications?"
    askYesNo
    useDesktop=$yesNo
    echo
    echo "Do you want to create mobile applications?"
    askYesNo
    useMobile=$yesNo
	echo

	FLASH_VERSION="10.2"

    if [[ $legacy = "N" ]]
    then
       FLASH_VERSION="11.1"
    fi
    
    if [[ $useMobile = "Y" || $useDesktop != "Y" ]]
    then
        if [[ $useBrowser = "Y" ]]
        then 
            FLASH_VERSION="11.1"
        else
            FLASH_VERSION="11.8"
        fi
    fi
    
    if [ ${latest} = "Y" ]
    then
    	FLASH_VERSION="11.8"
    fi
    
    echo "Setting minimum Flash Player version to ${FLASH_VERSION}"
    echo
    echo
}

if [[ -z "${FLASH_VERSION}" ]]
then
	determineVersion
fi

if [[ "${FLASH_VERSION}" != "10.2" && "${FLASH_VERSION}" != "10.3"  && "${FLASH_VERSION}" != "11.0"  && "${FLASH_VERSION}" != "11.1" && "${FLASH_VERSION}" != "11.2" && "${FLASH_VERSION}" != "11.3" && "${FLASH_VERSION}" != "11.4" && "${FLASH_VERSION}" != "11.5" && "${FLASH_VERSION}" != "11.6" && "${FLASH_VERSION}" != "11.7" && "${FLASH_VERSION}" != "11.8" ]]
then
	echo Unknown version ${FLASH_VERSION} of Flash Player. Versions 10.2, 10.3, 11.0, 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7 and 11.8 are supported.
	exit 1;
fi

# If this is an Apache Flex dir then there should be a NOTICE file.

if [ ! -f "${IDE_SDK_DIR}/NOTICE" ]
then
    echo ${IDE_SDK_DIR} does not appear to be an Apache Flex distribution.
    exit 1;
fi

echo Checking player globals
echo
./checkAllPlayerGlobals.sh "$IDE_SDK_DIR"

if [[ $useMobile = "Y" || $useDesktop = "Y" ]] 
then
	echo Installing AIR
	echo

    if [[ $FLASH_VERSION = "11.8" ]]
    then
        ./addAIRtoSDK.sh 3.8 "$IDE_SDK_DIR"
    fi
    
    if [[ $FLASH_VERSION = "11.1" ]]
    then
        ./addAIRtoSDK.sh 3.1 "$IDE_SDK_DIR"
    fi
fi

# update config file

updatePlayerVersion() {
	playerversion=$1
	configFile=$2
	
	sed "s/<target-player>[0-9][0-9]\.[0-9]<\/target-player>/<target-player>${playerversion}<\/target-player>/" < "${configFile}"  > "${configFile}.tmp"
	mv "${configFile}.tmp" "${configFile}"
}

updateSWFVersion() {
	swfversion=$1
	configFile=$2
	
	sed "s/<swf-version>[0-9][0-9]<\/swf-version>/<swf-version>${swfversion}<\/swf-version>/" < "${configFile}"  > "${configFile}.tmp"
	mv "${configFile}.tmp" "${configFile}"
}

updatePlayerDescription() {
	playerversion=$1
	configFile=$2
	
	echo Updating ${configFile}
	
	sed "s/FP[0-9][0-9]\.[0-9]/FP${playerversion}/" < "${configFile}"  > "${configFile}.tmp"
	mv "${configFile}.tmp" "${configFile}"
}

configFiles=(
"${IDE_SDK_DIR}/frameworks/flex-config.xml"
"${IDE_SDK_DIR}/frameworks/air-config.xml"
"${IDE_SDK_DIR}/frameworks/airmobile-config.xml"
)

updatePlayerDescription "${FLASH_VERSION}" "${IDE_SDK_DIR}/flex-sdk-description.xml"

for configFile in "${configFiles[@]}"
do
	echo Updating ${configFile}
	
	updatePlayerVersion "${FLASH_VERSION}" "${configFile}"

	if [ ${FLASH_VERSION} = "11.8" ]
	then
		updateSWFVersion 21 "${configFile}"
	fi
			
	if [ ${FLASH_VERSION} = "11.7" ]
	then
		updateSWFVersion 20 "${configFile}"
	fi
	
	if [ ${FLASH_VERSION} = "11.6" ]
	then
		updateSWFVersion 19 "${configFile}"
	fi
	
	if [ ${FLASH_VERSION} = "11.5" ]
	then
		updateSWFVersion 18 "${configFile}"
	fi
	
	if [ ${FLASH_VERSION} = "11.4" ]
	then
		updateSWFVersion 17 "${configFile}"
	fi

	if [ ${FLASH_VERSION} = "11.3" ]
	then
		updateSWFVersion 16 "${configFile}"
	fi
	
	if [ ${FLASH_VERSION} = "11.2" ]
	then
		updateSWFVersion 15 "${configFile}"
	fi
	
	if [ ${FLASH_VERSION} = "11.1" ]
	then
		updateSWFVersion 14 "${configFile}"
	fi
	
    if [ ${FLASH_VERSION} = "11.0" ]
	then
		updateSWFVersion 13 "${configFile}"
	fi
	
	if [ ${FLASH_VERSION} = "10.3" ]
	then
		updateSWFVersion 12 "${configFile}"
	fi
	
	if [ ${FLASH_VERSION} = "10.2" ]
	then
		updatePlayerVersion 10.2 "${configFile}"
		updateSWFVersion 11 "${configFile}"
	fi
done


