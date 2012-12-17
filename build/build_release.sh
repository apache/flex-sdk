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

# These commands should be executed in the root directory.
cd ..

# find the line with the format 'Last Changed Rev: 1354196', and remove 
# 'Last Changed Rev: ' from the beginning of the line
BUILD_NUMBER=`svn info | grep 'Last Changed Rev:' | sed 's/^Last Changed Rev: //'`
echo BUILD_NUMBER is $BUILD_NUMBER

# Tag the release build.  Can svn delete the tag if the build is bad or pulled.
TAG_NAME="apache-flex-sdk-4.8.0-RC1"
#svn copy -r $BUILD_NUMBER -m "Tagging build $BUILD_NUMBER." \
#   https://svn.apache.org/repos/asf/incubator/flex/trunk \
#  https://svn.apache.org/repos/asf/incubator/flex/tags/$TAG_NAME

# Do a release build.
#   Set the build number in flex-sdk-description.xml
#   Don't prompt for optional packages or acknowledgment of reciprocal licenses
ant -Dbuild.number=$BUILD_NUMBER -Dbuild.noprompt=release

# Build the asdoc package.
ant -Dbuild.number=$BUILD_NUMBER asdoc-package

# sign_and_hash.sh is an Apache tool.
# Creates detached ascii signatures and md5 hashes for each of the files in the
# current directory.
# Assumes that you have a pgp id and keypair set up and prompts for the 
# passphrase for each signature created.
#
cd out
../build/sign_and_hash.sh

