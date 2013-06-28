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

export SHELLOPTS
set -o igncr



# A method to be able to run various FP and AIR version is to override the env variables?
#export FLASHPLAYER_DEBUGGER=
#export AIR_HOME=



# CLEAN
rm -f local.properties



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
elif [ "$RUN_TYPE" == "air" ]
then
  TEST_COMMAND=-apollo
  TEST_SET=tests/apollo
elif [ "$RUN_TYPE" == "mobile" ]
then
  cat > local.properties <<END 
arget_os_name=android
android_sdk=C:/ApacheFlex/dependencies/AndroidSDK/adt-bundle-windows-x86_64-20130522/sdk
runtimeApk=${AIR_HOME}/runtimes/air/android/emulator/Runtime.apk
device_name=win
END

  TEST_COMMAND=-mobile
  TEST_SET=tests/mobile
fi



sh ./mini_run.sh $TEST_COMMAND $TEST_SET 

if [[ -s failures.txt ]]
then
  echo "Some tests failed: running '-failures'" 
  sh ./mini_run.sh $TEST_COMMAND -failures
  if [[ -s failures.txt ]]
  then
    echo "Some of tests failed, even after running '-failures'..."
    
    exit 1
  else
    echo "All tests passed after running '-failures'" 
  fi
else
  echo "All tests passed on first run" 
fi
