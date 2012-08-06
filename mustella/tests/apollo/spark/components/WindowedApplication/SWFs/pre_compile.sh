#!/bin/sh
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
echo "WindowedApplication/SWFs/pre_compile.sh: The SDK is $SDK_DIR"
echo "WindowedApplication/SWFs/pre_compile.sh: mxmlc version is " `$SDK_DIR/bin/mxmlc -version`

echo "Hello, clueless egg"


../../../../../../../../scripts/air_version_fixup.sh .


$SDK_DIR/bin/amxmlc -static-rsls assets/WindowedApplicationModule.mxml
$SDK_DIR/bin/mxmlc -static-rsls assets/ApplicationModule.mxml

cd assets

echo "Compiling css to swf..."
$SDK_DIR/bin/mxmlc -static-link-runtime-shared-libraries=true globalStyles.css
