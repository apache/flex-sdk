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

# Do a release build.
#   Set the build number in flex-sdk-description.xml
#   Don't prompt for optional packages or acknowledgment of reciprocal licenses
ant -Dbuild.noprompt= release

# Build the asdoc package.
ant asdoc-package

# sign_and_hash.sh is an Apache tool.
# Creates detached ascii signatures and md5 hashes for each of the files in the
# current directory.
# Assumes that you have a pgp id and keypair set up and prompts for the 
# passphrase for each signature created.
#
cd out
../build/sign_and_hash.sh

