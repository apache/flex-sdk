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



# VERSIONS

VERSIONS_FILE="versions.txt"

# If a 'versions' file exists, load it
if [ -f $VERSIONS_FILE ];
then
   source $VERSIONS_FILE
fi

# Toggle between versions:
# 11.1 is the default version
# 11.7 is a much used version?
# 18 is the current "long term support" version
# 19 is the current "consumer" version
# Note: the previous release and current beta versions of AIR are both '4',
#       so to make the distinction, the beta version is '4.01' on the VM
if [ "$FLASH_VERSION" == "11.1" ]
then
  FLASH_VERSION=11.7
  AIR_VERSION=3.7
  AIR_SDK_DIR=3.7
elif [ "$FLASH_VERSION" == "11.7" ]
then
  FLASH_VERSION=18.0
  AIR_VERSION=18.0
  AIR_SDK_DIR=18.0
elif [ "$FLASH_VERSION" == "18.0" ]
then
  FLASH_VERSION=19.0
  AIR_VERSION=19.0
  AIR_SDK_DIR=19.0
else
  FLASH_VERSION=11.1
  AIR_VERSION=3.7
  AIR_SDK_DIR=3.7
fi

LOG=$LOG"- Set FLASH_VERSION to '$FLASH_VERSION' and AIR_VERSION to '$AIR_VERSION'"$'\n'



# LOCATIONS
export AIR_HOME="C:\\ApacheFlex\\dependencies\\AdobeAIRSDK\\$AIR_SDK_DIR"
LOG=$LOG"- Set AIR_HOME to '$AIR_HOME'"$'\n'

case "$FLASH_VERSION" in
  11.1)
    export FLASHPLAYER_DEBUGGER="C:\\ApacheFlex\\dependencies\\FlashPlayer_Debug\\flashplayer11_1r102_55_win_sa_debug_32bit.exe"
  ;;
  11.7)
    export FLASHPLAYER_DEBUGGER="C:\\ApacheFlex\\dependencies\\FlashPlayer_Debug\\flashplayer11_7r700_232_win_sa_debug.exe"
  ;;
  18.0)
    export FLASHPLAYER_DEBUGGER="C:\\ApacheFlex\\dependencies\\FlashPlayer_Debug\\flashplayer_18_sa_debug.exe"
  ;;
  19.0)
    export FLASHPLAYER_DEBUGGER="C:\\ApacheFlex\\dependencies\\FlashPlayer_Debug\\flashplayer_19_sa_debug.exe"
  ;;
  *)
    echo "No valid Flash Player Debugger variable value could be parsed."
    exit 1
  ;;
esac
LOG=$LOG"- Set FLASHPLAYER_DEBUGGER to '$FLASHPLAYER_DEBUGGER'"$'\n'



# RUN SETTINGS

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
  TEST_COMMAND=-mobile
  TEST_SET=tests/mobile
fi



# SETTINGS REPORT
START=$(date +"%m-%d-%Y %H:%M")
START_TIME=$(date +"%s")

cat <<END



============ JENKINS MUSTELLA SETTINGS REPORT ============

Date/Time: $START

Settings:
player.version = $FLASH_VERSION
air.version = $AIR_VERSION
FLASHPLAYER_DEBUGGER = $FLASHPLAYER_DEBUGGER
AIR_HOME = $AIR_HOME

Build: 
  type = $RUN_TYPE
  command = $TEST_COMMAND
  set = $TEST_SET

=====================================================



END



# Remove old 'local.properties' files
rm -f ../local.properties
rm -f local.properties

LOG=$LOG"- Cleaned up 'local.properties' files from previous runs"$'\n'



# To build the SDK using the values specified above, write both 'local.properties' files
cat > ../local.properties <<END 
playerglobal.version = $FLASH_VERSION
air.version = $AIR_VERSION
END

if [ "$RUN_TYPE" == "mobile" ]
then
  cat > local.properties <<END 
target_os_name=android
android_sdk=C:/ApacheFlex/dependencies/AndroidSDK/adt-bundle-windows-x86_64-20130522/sdk
runtimeApk=${AIR_HOME}/runtimes/air/android/emulator/Runtime.apk
device_name=win
END
fi

LOG=$LOG"- Created fresh 'local.properties' files with containing run specific values"$'\n'



# ANT
ant -f ../build.xml clean -Dbuild.noprompt=true
ant -f ../build.xml main -Dbuild.noprompt=true
ant -f ../build.xml other.locales -Dbuild.noprompt=true

LOG=$LOG"- Ran 'clean', 'main' and 'other.locales' ant targets to prepare the SDK for testing"$'\n'



# RUN
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



# RUN REPORT
END=$(date +"%m-%d-%Y %H:%M")
END_TIME=$(date +"%s")

DURATION=$(($END_TIME - $START_TIME))

DAYS=$(($DURATION / 60 / 60 / 24))
HOURS=$((($DURATION / 60 / 60) - ($DAYS * 24)))
MINUTES=$((($DURATION / 60) - (($DAYS * 24 + $HOURS) * 60)))
SECONDS=$((($DURATION) - ((($DAYS * 24 + $HOURS) * 60 + $MINUTES) * 60)))

DURATION_STR="$DAYS days $HOURS hours $MINUTES mins $SECONDS seconds"

cat <<END



============ JENKINS MUSTELLA RUN REPORT ============

Date/Time: $END

Run duration: $DURATION_STR

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



# write 'used' values to 'versions.txt' to allow 
cat > $VERSIONS_FILE <<END 
FLASH_VERSION=$FLASH_VERSION
AIR_VERSION=$AIR_VERSION
END



if ! $SUCCESS
then
  exit 1
fi
