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
echo "SDK: $SDK_DIR"
echo "Running tests/gumbo/components/Application/SWFs/pre_compile.sh"

rm assets/BasicApplication.swf
rm assets/BasicApplication2.swf
rm assets/BasicApplication4.swf
rm assets/CustomApplication1.swf

$SDK_DIR/bin/mxmlc -static-link-runtime-shared-libraries=true assets/BasicApplication.mxml
$SDK_DIR/bin/mxmlc -static-link-runtime-shared-libraries=true assets/BasicApplication2.mxml
$SDK_DIR/bin/mxmlc -static-link-runtime-shared-libraries=true assets/BasicApplication4.mxml
$SDK_DIR/bin/mxmlc -static-link-runtime-shared-libraries=true assets/CustomApplication1.mxml
