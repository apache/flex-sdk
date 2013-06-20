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

#export SHELLOPTS
#set -o igncr



# A method to be able to run various FP and AIR version is to override the env variables?
#export FLASHPLAYER_DEBUGGER=
#export AIR_HOME=



MAIN_FAILED=false
AIR_FAILED=false
MOBILE_FAILED=false



# CLEAN
rm -f local.properties



# MAIN
sh ./mini_run.sh -timeout=60000 -all

if [[ -s failures.txt ]]
then
  echo "Some 'main' tests failed: running '-failures'" 
  sh ./mini_run.sh -timeout=60000 -failures
  if [[ -s failures.txt ]]
  then
    MAIN_FAILED=true
  else
    echo "All 'main' tests passed after running '-failures'" 
  fi
else
  echo "All main tests passed on first run" 
fi



# AIR
sh ./mini_run.sh -apollo tests/apollo

if [[ -s failures.txt ]]
then
  echo "Some AIR tests failed: running '-apollo -failures'" 
  sh ./mini_run.sh -apollo -failures
  if [[ -s failures.txt ]]
  then
    AIR_FAILED=true
  else
    echo "All AIR tests passed after running '-apollo -failures'" 
  fi
else
  echo "All AIR tests passed on first run" 
fi



# MOBILE
cat > local.properties <<END 
target_os_name=android
android_sdk=C:/ApacheFlex/dependencies/AndroidSDK/adt-bundle-windows-x86_64-20130522/sdk
runtimeApk=${AIR_HOME}/runtimes/air/android/emulator/Runtime.apk
device_name=win
END

sh ./mini_run.sh -mobile tests/mobile

if [[ -s failures.txt ]]
then
  echo "Some mobile tests failed: running '-mobile -failures'" 
  sh ./mini_run.sh -mobile -failures
  if [[ -s failures.txt ]]
  then
    MOBILE_FAILED=true
  else
    echo "All mobile tests passed after running '-mobile -failures'" 
  fi
else
  echo "All mobile tests passed on first run" 
fi

rm -f local.properties



if [[ $MAIN_FAILED ]]
then
  echo "Some of the 'main' tests failed, even after running '-failures'..."
elif [[ $AIR_FAILED ]]
then
  echo "Some of the AIR tests failed, even after running '-apollo -failures'..."
elif [[ $MOBILE_FAILED ]]
then
  echo "Some of the mobile tests failed, even after running '-mobile -failures'..."
fi

# Make the Jenkins job fail if any tests failed:
if [[ $MAIN_FAILED || $AIR_FAILED || $MOBILE_FAILED ]]
then
  exit 1
fi
