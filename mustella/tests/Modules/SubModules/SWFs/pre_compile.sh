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

$SDK_DIR/bin/mxmlc -link-report=subMTLinkReport3.xml  SubModuleTest_basic3.mxml


cd assets

echo "Removing previously compiled files..."
rm -f `find . -name "*.swf"`

echo "Compiling components..."

$SDK_DIR/bin/mxmlc  -static-rsls=true  SimpleTitleWindow.mxml
$SDK_DIR/bin/mxmlc  -static-rsls=true  MyMXTitleWindow.mxml
$SDK_DIR/bin/mxmlc  -static-rsls=true  SimpleModule.as
$SDK_DIR/bin/mxmlc  -static-rsls=true  SubApp1.mxml
$SDK_DIR/bin/mxmlc  -static-rsls=true  SubApp2.mxml
$SDK_DIR/bin/mxmlc  -static-rsls=true  SubApp3.mxml
$SDK_DIR/bin/mxmlc  -static-rsls=true  SubApp4.mxml

echo "Compiling module SWFs..."
$SDK_DIR/bin/mxmlc  -static-rsls=true  SimpleModuleWithLabel.mxml
$SDK_DIR/bin/mxmlc  -static-rsls=true  SimpleASModuleTest.mxml
$SDK_DIR/bin/mxmlc  -static-rsls=true  TitleWindowModule.mxml
$SDK_DIR/bin/mxmlc  -static-rsls=true  MXTitleWindowModule.mxml
$SDK_DIR/bin/mxmlc  -static-rsls=true  ModuleLoadSubApp2.mxml
$SDK_DIR/bin/mxmlc  -static-rsls=true  ModuleLoadSubApp3.mxml
$SDK_DIR/bin/mxmlc  -static-rsls=true  Module1.mxml
$SDK_DIR/bin/mxmlc  -static-rsls=true  Module2.mxml
$SDK_DIR/bin/mxmlc  -static-rsls=true  Module3.mxml
$SDK_DIR/bin/mxmlc  -static-rsls=true  Module4.mxml
$SDK_DIR/bin/mxmlc  -static-rsls=true  Module5.mxml
$SDK_DIR/bin/mxmlc  -static-rsls=true  Module6.mxml
$SDK_DIR/bin/mxmlc -load-externs=../subMTLinkReport3.xml -static-rsls=true  ModuleLoadSubApp2.mxml
$SDK_DIR/bin/mxmlc -load-externs=../subMTLinkReport3.xml -static-rsls=true  ModuleLoadSubApp3.mxml



