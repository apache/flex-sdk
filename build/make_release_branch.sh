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


# This script release branch for the next Apache Flex version

if [ $# -ne 1 ]
then
    echo Usage: make_release_branch [0-100].[0-100].[0-1000]
fi

FLEX_VERSION="$1"
CHECK=`echo "$FLEX_VERSION" | grep -q -E '[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,3}$'`

if [ $? -ne 0 ]
then
	echo "Apache Flex version needs to be in the form [0-100].[0-100].[0-1000]"
	exit 1;
fi

echo "Creating branch for Apache Flex Version ${FLEX_VERSION}"

git push -u origin develop:release${FLEX_VERSION}

cd ..
mkdir "ApacheFlex${FLEX_VERSION}"
cd "ApacheFlex${FLEX_VERSION}"
git clone https://git-wip-us.apache.org/repos/asf/flex-sdk.git .
git checkout release${FLEX_VERSION}
git tag -a apache-flex-sdk-${FLEX_VERSION}RC1 -m \'"Apache Flex ${FLEX_VERSION} RC1"\'
git push --tags