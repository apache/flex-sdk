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
# Usage: addAIRtoSDK AIRversion "Apache Flex directory"
#
# This script will download and add the specified version of AIR to an SDK and
# update it's configuration.

# Process the parameters.

AIR_VERSION="$1"
OS=`uname`

if [[ "${AIR_VERSION}" != "24.0"
  && "${AIR_VERSION}" != "23.0"  && "${AIR_VERSION}" != "22.0"  && "${AIR_VERSION}" != "21.0"
  &&  "${AIR_VERSION}" != "20.0"  && "${AIR_VERSION}" != "19.0"  && "${AIR_VERSION}" != "18.0"
  && "${AIR_VERSION}" != "17.0" && "${AIR_VERSION}" != "16.0" && "${AIR_VERSION}" != "15.0" 
  && "${AIR_VERSION}" != "14.0" && "${AIR_VERSION}" != "13.0" && "${AIR_VERSION}" != "4.0" 
  && "${AIR_VERSION}" != "3.9" && "${AIR_VERSION}" != "3.8" && "${AIR_VERSION}" != "3.7" 
  && "${AIR_VERSION}" != "3.6" && "${AIR_VERSION}" != "3.5" && "${AIR_VERSION}" != "3.4" 
  && "${AIR_VERSION}" != "3.3" && "${AIR_VERSION}" != "3.2" && "${AIR_VERSION}" != "3.1" 
  && "${AIR_VERSION}" != "3.0" && "${AIR_VERSION}" != "2.7" && "${AIR_VERSION}" != "2.6" ]]
then
	echo Unknown version ${AIR_VERISON} of AIR. Versions 2.6, 2.7, 3.0, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 4.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0,  23.0 and 24.0 are supported.
	exit 1;
fi

if [[ "${OS}" != "Darwin" && "${AIR_VERSION}" != "2.6" ]]
then
	echo "Only AIR version 2.6 is supported on Linux"
	exit 1;
fi

IDE_SDK_DIR="$2"

if [ "${IDE_SDK_DIR}" = "" ]
then
    echo Usage: $0 "AIR version" "Apache Flex directory"
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
	echo "Adobe AIR is licensed under the the Adobe AIR end user license agreement (EULA)."
	echo
	echo The Adobe AIR 3 EULA is specified here:
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


downloadAIR()
{  	version=$1
   	airTempDir="${IDE_SDK_DIR}/frameworks/temp"
	mkdir -p "${airTempDir}"

    if [[ "${OS}" == "Darwin" ]]
    then
        airDownload="https://airdownload.adobe.com/air/mac/download/${version}/AdobeAIRSDK.tbz2"
    else
        airDownload="https://airdownload.adobe.com/air/lin/download/${version}/AdobeAIRSDK.tbz2"
    fi

    if [[ "${AIR_VERSION}" == "24.0" ]]
    then
        airDownload="https://airdownload.adobe.com/air/mac/download/24.0/AdobeAIRSDK.dmg"
	echo Downloading AIR ${version}
	echo from ${airDownload}
	curl ${airDownload} > "${airTempDir}/air.dmg"
	
	echo Extracting into SDK 
	hdiutil attach -nobrowse "${airTempDir}"/air.dmg
	cp -fR "/Volumes/AIR SDK/" "${IDE_SDK_DIR}"
	umount "/Volumes/AIR SDK"
    else
	echo Downloading AIR ${version}
	echo from ${airDownload}
	curl ${airDownload} > "${airTempDir}/air.tbz2"
	
	echo Extracting into SDK  
	tar xf "${airTempDir}/air.tbz2" -C "${IDE_SDK_DIR}"
    fi

    rm -rf "${airTempDir}"	
}

agreeLicense

downloadAIR ${AIR_VERSION}

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
	airversion=$1
	configFile=$2
	
	echo Updating ${configFile}
	
	sed "s/AIR[0-9]\.[0-9]/AIR${airversion}/" < "${configFile}"  > "${configFile}.tmp"
	mv "${configFile}.tmp" "${configFile}"
}

configFiles=(
"${IDE_SDK_DIR}/frameworks/flex-config.xml"
"${IDE_SDK_DIR}/frameworks/air-config.xml"
"${IDE_SDK_DIR}/frameworks/airmobile-config.xml"
)

updatePlayerDescription "${AIR_VERSION}" "${IDE_SDK_DIR}/flex-sdk-description.xml"

for configFile in "${configFiles[@]}"
do
	echo Updating ${configFile}
	
	# 24.0 needs FP 24 and swf version 35
	if [ ${AIR_VERSION} = "23.0" ]
	then
		updatePlayerVersion 24.0 "${configFile}"
		updateSWFVersion 35 "${configFile}"
	fi

	# 23.0 needs FP 23 and swf version 34
	if [ ${AIR_VERSION} = "23.0" ]
	then
		updatePlayerVersion 23.0 "${configFile}"
		updateSWFVersion 34 "${configFile}"
	fi

	# 22.0 needs FP 22 and swf version 33
	if [ ${AIR_VERSION} = "22.0" ]
	then
		updatePlayerVersion 22.0 "${configFile}"
		updateSWFVersion 33 "${configFile}"
	fi

	# 21.0 needs FP 21 and swf version 32
	if [ ${AIR_VERSION} = "21.0" ]
	then
		updatePlayerVersion 21.0 "${configFile}"
		updateSWFVersion 32 "${configFile}"
	fi

	# 20.0 needs FP 20 and swf version 31
	if [ ${AIR_VERSION} = "20.0" ]
	then
		updatePlayerVersion 20.0 "${configFile}"
		updateSWFVersion 31 "${configFile}"
	fi
	
	# 19.0 needs FP 19 and swf version 30
	if [ ${AIR_VERSION} = "19.0" ]
	then
		updatePlayerVersion 19.0 "${configFile}"
		updateSWFVersion 30 "${configFile}"
	fi

	# 18.0 needs FP 18 and swf version 29
	if [ ${AIR_VERSION} = "18.0" ]
	then
		updatePlayerVersion 18.0 "${configFile}"
		updateSWFVersion 29 "${configFile}"
	fi	
	
	# 17.0 needs FP 17 and swf version 28
	if [ ${AIR_VERSION} = "17.0" ]
	then
		updatePlayerVersion 17.0 "${configFile}"
		updateSWFVersion 28 "${configFile}"
	fi	
	
	# 16.0 needs FP 16 and swf version 27
	if [ ${AIR_VERSION} = "16.0" ]
	then
		updatePlayerVersion 16.0 "${configFile}"
		updateSWFVersion 27 "${configFile}"
	fi	
	
	# 15.0 needs FP 15 and swf version 26
	if [ ${AIR_VERSION} = "15.0" ]
	then
		updatePlayerVersion 15.0 "${configFile}"
		updateSWFVersion 26 "${configFile}"
	fi	

	# 14.0 needs FP 14 and swf version 25
	if [ ${AIR_VERSION} = "14.0" ]
	then
		updatePlayerVersion 14.0 "${configFile}"
		updateSWFVersion 25 "${configFile}"
	fi	
	
	# 13.0 needs FP 13 and swf version 24
	if [ ${AIR_VERSION} = "13.0" ]
	then
		updatePlayerVersion 13.0 "${configFile}"
		updateSWFVersion 24 "${configFile}"
	fi	
	
	# 4.0 needs FP 12 and swf version 23
	if [ ${AIR_VERSION} = "4.0" ]
	then
		updatePlayerVersion 12.0 "${configFile}"
		updateSWFVersion 23 "${configFile}"
	fi	
		
	# 3.8 needs FP 11.9 and swf version 22
	if [ ${AIR_VERSION} = "3.9" ]
	then
		updatePlayerVersion 11.9 "${configFile}"
		updateSWFVersion 22 "${configFile}"
	fi	
		
	# 3.8 needs FP 11.8 and swf version 21
	if [ ${AIR_VERSION} = "3.8" ]
	then
		updatePlayerVersion 11.8 "${configFile}"
		updateSWFVersion 21 "${configFile}"
	fi	

	# 3.7 needs FP 11.7 and swf version 20
	if [ ${AIR_VERSION} = "3.7" ]
	then
		updatePlayerVersion 11.7 "${configFile}"
		updateSWFVersion 20 "${configFile}"
	fi	
	
	# 3.6 needs FP 11.6 and swf version 19
	if [ ${AIR_VERSION} = "3.6" ]
	then
		updatePlayerVersion 11.6 "${configFile}"
		updateSWFVersion 19 "${configFile}"
	fi

	# 3.5 needs FP 11.5 and swf version 18
	if [ ${AIR_VERSION} = "3.5" ]
	then
		updatePlayerVersion 11.5 "${configFile}"
		updateSWFVersion 18 "${configFile}"
	fi
	
	# 3.4 needs FP 11.4 and swf version 17
	if [ ${AIR_VERSION} = "3.4" ]
	then
		updatePlayerVersion 11.4 "${configFile}"
		updateSWFVersion 17 "${configFile}"
	fi
	
	# 3.3 needs FP 11.3 and swf version 16
	if [ ${AIR_VERSION} = "3.3" ]
	then
		updatePlayerVersion 11.3 "${configFile}"
		updateSWFVersion 16 "${configFile}"
	fi
		
	# 3.2 needs FP 11.2 and swf version 15
	if [ ${AIR_VERSION} = "3.2" ]
	then
		updatePlayerVersion 11.2 "${configFile}"
		updateSWFVersion 15 "${configFile}"
	fi
	
	# 3.1 needs FP 11.1 and swf version 14
	if [ ${AIR_VERSION} = "3.1" ]
	then
		updatePlayerVersion 11.1 "${configFile}"
		updateSWFVersion 14 "${configFile}"
	fi
	
	# 3.0 needs FP 11.0 and swf version 13
	if [ ${AIR_VERSION} = "3.0" ]
	then
		updatePlayerVersion 11.0 "${configFile}"
		updateSWFVersion 13 "${configFile}"
	fi
	
	# 2.7 needs FP 10.3 and swf version 12
	if [ ${AIR_VERSION} = "2.7" ]
	then
		updatePlayerVersion 10.3 "${configFile}"
		updateSWFVersion 12 "${configFile}"
	fi
	
	# 2.6 needs FP 10.2 and swf version 11
	if [ ${AIR_VERSION} = "2.6" ]
	then
		updatePlayerVersion 10.2 "${configFile}"
		updateSWFVersion 11 "${configFile}"
	fi
done


