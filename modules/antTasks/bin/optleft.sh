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
##      http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.
##
################################################################################

# Set this variable to the location of flexBuild in the local client

flexBuildHome="/c/perforceDepot/depot/skunkworks/seliopou/flexBuild"

srcDir="$flexBuildHome/src"
sedFile="$flexBuildHome/bin/options.sed"

willNotImplement=3
# -dump-config
# -help
# -version

multipleMatches=2
# -externs  matches -load-externs
# -debug    matches -debug-password

options=`mxmlc -help advanced | sed -f $sedFile`

# Compute the number of options mxmlc accepts

optCount=`echo "$options" | wc -l`

# Compute the number of options that are present in the source directory

completeCount=`echo "$options" | xargs -I {} grep -R {} $srcDir | grep "new OptionSpec" | wc -l`

echo $(($optCount-$willNotImplement-$multipleMatches-$completeCount))
