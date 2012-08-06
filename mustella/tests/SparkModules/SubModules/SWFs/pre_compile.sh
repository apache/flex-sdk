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
rm -f `find . -name "subMTLinkReport*.xml"`
echo "***************************************"
echo ""
echo ""
echo ""
echo $SDK_DIR/bin
echo ""
echo ""
echo ""
echo "***************************************"
$SDK_DIR/bin/mxmlc SubModuleTest_basic3.mxml -link-report=subMTLinkReport3.xml
cd assets
echo "Removing previously compiled files..."
rm -f `find . -name "*.swf"`
echo "Compiling components..."
$SDK_DIR/bin/mxmlc SimpleTitleWindow.mxml -static-rsls=true
$SDK_DIR/bin/mxmlc SimpleModule.as -static-rsls=true
$SDK_DIR/bin/mxmlc SubApp1.mxml -static-rsls=true
$SDK_DIR/bin/mxmlc SubApp2.mxml -static-rsls=true
$SDK_DIR/bin/mxmlc SubApp3.mxml -static-rsls=true
$SDK_DIR/bin/mxmlc SubApp4.mxml -static-rsls=true
echo "Compiling module SWFs..."
$SDK_DIR/bin/mxmlc SimpleModuleWithLabel.mxml -static-rsls=true
$SDK_DIR/bin/mxmlc SimpleASModuleTest.mxml -static-rsls=true
$SDK_DIR/bin/mxmlc TitleWindowModule.mxml -static-rsls=true
$SDK_DIR/bin/mxmlc Module1.mxml -static-rsls=true
$SDK_DIR/bin/mxmlc Module2.mxml -static-rsls=true
$SDK_DIR/bin/mxmlc Module3.mxml -static-rsls=true
$SDK_DIR/bin/mxmlc Module4.mxml -static-rsls=true
$SDK_DIR/bin/mxmlc Module5.mxml -static-rsls=true
$SDK_DIR/bin/mxmlc Module6.mxml -static-rsls=true
$SDK_DIR/bin/mxmlc ModuleLoadSubApp2.mxml -load-externs=../subMTLinkReport3.xml
$SDK_DIR/bin/mxmlc ModuleLoadSubApp3.mxml -load-externs=../subMTLinkReport3.xml