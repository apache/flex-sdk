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
    echo "Usage: deploy_candidate flex_version ([0-99].[0-99].[0-999]) release_candidate ([0-100])"
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

# Assumes FLEX_DEV_AREA has been set up and point to SVN dev area
# Assumes FLEX_REL_AREA has been set up and point to SVN release area

RC_DIR="${FLEX_DEV_AREA}/sdk/${FLEX_VERSION}/rc${RELEASE_CANDIDATE}"
RC_BIN_DIR="${FLEX_DEV_AREA}/sdk/${FLEX_VERSION}/rc${RELEASE_CANDIDATE}/binaries"
RC_DOC_DIR="${FLEX_DEV_AREA}/sdk/${FLEX_VERSION}/rc${RELEASE_CANDIDATE}/docs"

REL_VERSION_DIR="${FLEX_REL_AREA}/${FLEX_VERSION}"
REL_DIR="${FLEX_REL_AREA}/${FLEX_VERSION}"
REL_BIN_DIR="${FLEX_REL_AREA}/${FLEX_VERSION}/binaries"
REL_DOC_DIR="${FLEX_REL_AREA}/${FLEX_VERSION}/docs"

echo "RC directory is ${RC_DIR}"
echo "Release directory is ${REL_DIR}"

if [ ! -d "${REL_VERSION_DIR}" ]
then
	mkdir "${REL_VERSION_DIR}"
fi

if [ ! -d "${REL_BIN_DIR}" ]
then
	mkdir "${REL_BIN_DIR}"
fi

if [ ! -d "${REL_DOC_DIR}" ]
then
	mkdir "${REL_DOC_DIR}"
fi

cp "${RC_DIR}"/README "${REL_DIR}"
cp "${RC_DIR}"/RELEASE_NOTES "${REL_DIR}"
cp "${RC_DIR}"/*-src.* "${REL_DIR}"
cp "${RC_BIN_DIR}"/*-bin.* "${REL_BIN_DIR}"
cp "${RC_BIN_DIR}"/*-config.xml "${REL_BIN_DIR}"
cp "${RC_DOC_DIR}"/*-asdocs.* "${REL_DOC_DIR}"



