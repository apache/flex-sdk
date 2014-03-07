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


if [ $# -ne 2 ]
then
    echo "Usage: deploy_release_candidate flex_version ([0-99].[0-99].[0-999]) release_candidate ([0-100])"
fi

FLEX_VERSION="$1"
CHECK=`echo "$FLEX_VERSION" | grep -q -E '[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,3}$'`

if [ $? -ne 0 ]
then
	echo "Apache Flex version needs to be in the form [0-99].[0-99].[0-999]"
	exit 1;
fi

RELEASE_CANDIDATE="$2"
CHECK=`echo "$RELEASE_CANDIDATE" | grep -q -E '[0-9]{1,2}'`

if [ $? -ne 0 ]
then
	echo "Apache Flex release candidate to be in the range 1-99"
	exit 1;
fi

# Assumes FLEX_DEV_AREA has been set up and point to SVN checked out dev area

VERSION_DIR="${FLEX_DEV_AREA}/sdk/${FLEX_VERSION}"
RC_DIR="${FLEX_DEV_AREA}/sdk/${FLEX_VERSION}/rc${RELEASE_CANDIDATE}"
BIN_DIR="${FLEX_DEV_AREA}/sdk/${FLEX_VERSION}/rc${RELEASE_CANDIDATE}/binaries"
DOC_DIR="${FLEX_DEV_AREA}/sdk/${FLEX_VERSION}/rc${RELEASE_CANDIDATE}/docs"

echo "RC directory is ${RC_DIR}"

if [ ! -d "${VERSION_DIR}" ]
then
	mkdir "${VERSION_DIR}"
fi

if [ ! -d "${RC_DIR}" ]
then
	mkdir "${RC_DIR}"
fi

if [ ! -d "${BIN_DIR}" ]
then
	mkdir "${BIN_DIR}"
fi

if [ ! -d "${DOC_DIR}" ]
then
	mkdir "${DOC_DIR}"
fi

cp README "${RC_DIR}"
cp RELEASE_NOTES "${RC_DIR}"
cp ./out/*-src.* "${RC_DIR}"
cp ./out/*-bin.* "${BIN_DIR}"
cp ./out/*-config.xml "${BIN_DIR}"
cp ./out/*-asdocs.* "${DOC_DIR}"



