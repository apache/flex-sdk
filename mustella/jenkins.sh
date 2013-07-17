#!/bin/bash
################################################################################
##
##  Licensed to the Apache Software Foundation (ASF) under one or more
##  contributor license agreements.  See the NOTICE file distributed with
##  this work for additional information regarding copyright ownership.
##  The ASF licenses this file to You under the Apache License, Version 2.0
##  (the "License"); you may not use this file except in compliance with
##  the License.  You may obtain a copy of the License at
##
##    http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.
##
################################################################################
##
## Set env variables and run script. This file is meant as a utility for the 
## Jenkins jobs on a windows machine.
## 
## NOTE: this file MUST HAVE Unix style line endings!
##

LOG=""
SUCCES=true

PLATFORM=$(uname -s)
if [ "${PLATFORM:0:6}" == "CYGWIN" ]
then
  export SHELLOPTS
  set -o igncr
  LOG=$LOG"- Made Cygwin ignore carriage returns"$'\n'
fi



# CLEAN
rm -f ../local.properties
rm -f local.properties
LOG=$LOG"- Cleaned up 'local.properties' files from previous runs"$'\n'



# VERSIONS

VERSIONS_FILE="versions.txt"

# If a 'versions' file exists, load it
if [ -f $VERSIONS_FILE ];
then
   source $VERSIONS_FILE
fi

# toggle between versions
if [ "$FLASH_VERSION" == "11.1" ]
then
  FLASH_VERSION=11.7
  AIR_VERSION=3.7
elif [ "$FLASH_VERSION" == "11.7" ]
then
  FLASH_VERSION=11.8
  AIR_VERSION=3.8
else
  FLASH_VERSION=11.1
  AIR_VERSION=3.7
fi

# write toggled values to 'versions' file
cat > $VERSIONS_FILE <<END 
FLASH_VERSION=$FLASH_VERSION
AIR_VERSION=$AIR_VERSION
END

LOG=$LOG"- Set FLASH_VERSION to '$FLASH_VERSION' and AIR_VERSION to '$AIR_VERSION'"$'\n'



# LOCATIONS
#export AIR_HOME="/Users/erik/Documents/ApacheFlex/dependencies/AdobeAIRSDK"
export AIR_HOME="C:\\ApacheFlex\\dependencies\\AdobeAIRSDK\\$AIR_VERSION"
LOG=$LOG"- Set AIR_HOME to '$AIR_HOME'"$'\n'

case "$FLASH_VERSION" in
  11.1)
    #export FLASHPLAYER_DEBUGGER="/Applications/Flash Player Debugger.app/Contents/MacOS/Flash Player Debugger"
    export FLASHPLAYER_DEBUGGER="C:\\ApacheFlex\\dependencies\\FlashPlayer_Debug\\flashplayer11_1r102_55_win_sa_debug_32bit.exe"
  ;;
  11.7)
    export FLASHPLAYER_DEBUGGER="C:\\ApacheFlex\\dependencies\\FlashPlayer_Debug\\flashplayer11_7r700_232_win_sa_debug.exe"
  ;;
  11.8)
    export FLASHPLAYER_DEBUGGER="C:\\ApacheFlex\\dependencies\\FlashPlayer_Debug\\flashplayer11_8r800_94_win_sa_debug.exe"
  ;;
  *)
    echo "No valid Flash Player Debugger variable value could be parsed."
    exit 1
  ;;
esac
LOG=$LOG"- Set FLASHPLAYER_DEBUGGER to '$FLASHPLAYER_DEBUGGER'"$'\n'



# To build the SDK using the versions specified above, write '../local.properties'
cat > ../local.properties <<END 
playerglobal.version = $FLASH_VERSION
air.version = AIR_VERSION
END



# ANT
ant -f ../build.xml clean -Dbuild.noprompt=true
ant -f ../build.xml main -Dbuild.noprompt=true
ant -f ../build.xml other.locales -Dbuild.noprompt=true
LOG=$LOG"- Ran 'clean', 'main' and 'other.locales' ant targets to prepare the SDK for testing"$'\n'



# RUN

RUN_TYPE="main"
while [ "$1" != "" ]; do
  case $1 in
    -t | --type )           
      shift
      RUN_TYPE=$1
      ;;
    * )              
  esac
  shift
done

if [ "$RUN_TYPE" == "main" ]
then
  TEST_COMMAND=-timeout=60000
  TEST_SET=-all
  #TEST_SET=tests/components/Label
elif [ "$RUN_TYPE" == "air" ]
then
  TEST_COMMAND=-apollo
  TEST_SET=tests/apollo
elif [ "$RUN_TYPE" == "mobile" ]
then
  cat > local.properties <<END 
target_os_name=android
android_sdk=C:/ApacheFlex/dependencies/AndroidSDK/adt-bundle-windows-x86_64-20130522/sdk
runtimeApk=${AIR_HOME}/runtimes/air/android/emulator/Runtime.apk
device_name=win
END

  TEST_COMMAND=-mobile
  TEST_SET=tests/mobile
fi

sh ./mini_run.sh $TEST_COMMAND $TEST_SET 

LOG=$LOG"- Ran Mustella on the SDK with these parameters: '$TEST_COMMAND $TEST_SET'"$'\n'



# FAILURES
if [[ -s failures.txt ]]
then
  LOG=$LOG"- Some tests failed: running '-failures'"$'\n' 
  sh ./mini_run.sh $TEST_COMMAND -failures
  if [[ -s failures.txt ]]
  then
    LOG=$LOG"- Some of tests failed, even after running '-failures'..."$'\n'
    
    SUCCESS=false
  else
    LOG=$LOG"- All tests passed after running '-failures'"$'\n'
  fi
else
  LOG=$LOG"- All tests passed on the first run"$'\n'
fi



# REPORT
NOW=$(date +"%m-%d-%Y %H:%M")
cat <<END



============ JENKINS MUSTELLA RUN REPORT ============

Date and time: $NOW

Settings:
player.version = $FLASH_VERSION
air.version = $AIR_VERSION
FLASHPLAYER_DEBUGGER = $FLASHPLAYER_DEBUGGER
AIR_HOME = $AIR_HOME

Build: 
  type = $RUN_TYPE
  command = $TEST_COMMAND
  set = $TEST_SET

Log:
$LOG

=====================================================



END



if ! $SUCCESS
then
  exit 1
fi
