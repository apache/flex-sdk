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



# Main
#sh ./mini_run.sh -timeout=60000 -all

#if [[ -s failures.txt ]] ; then
#  echo "Some tests failed: running '-failures'" 
#  sh ./mini_run.sh -timeout=60000 -failures
#else
#  echo "All main tests passed on first run" 
#fi ;



# AIR
sh ./mini_run.sh -apollo tests/apollo

if [[ -s failures.txt ]] ; then
  echo "Some AIR tests failed: running '-failures'" 
  sh ./mini_run.sh -failures
else
  echo "All AIR tests passed on first run" 
fi ;



# Mobile
rm -f local.properties
cat > local.properties <<END 
target_os_name=android
android_sdk=C:/ApacheFlex/dependencies/AndroidSDK/adt-bundle-windows-x86_64-20130522/sdk
runtimeApk=${AIR_HOME}/runtimes/air/android/emulator/Runtime.apk
device_name=win
END

#sh ./mini_run.sh -mobile tests/mobile

#if [[ -s failures.txt ]] ; then
#  echo "Some mobile tests failed: running '-failures'" 
#  sh ./mini_run.sh -failures
#else
#  echo "All mobile tests passed on first run" 
#fi ;
