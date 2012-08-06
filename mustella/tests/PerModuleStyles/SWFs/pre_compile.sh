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
cd assets

echo "Removing previously compiled files..."
rm -f `find . -name "*.swf"`


echo "Compiling module SWFs..."


$SDK_DIR/bin/mxmlc -debug  ModuleAppThree.mxml
$SDK_DIR/bin/mxmlc -debug  ModuleAppFour.mxml
$SDK_DIR/bin/mxmlc -debug  ModuleAppSeven.mxml
$SDK_DIR/bin/mxmlc -debug  ModuleApp.mxml
$SDK_DIR/bin/mxmlc -debug  testStyles.css
$SDK_DIR/bin/mxmlc -debug  CSSDeclarationModule.mxml
$SDK_DIR/bin/mxmlc -debug  CSSDeclarationModule2.mxml
$SDK_DIR/bin/mxmlc -debug  ModifyCSSDeclarationModule.mxml
$SDK_DIR/bin/mxmlc -debug  -includes=mx.managers.systemClasses.MarshallingSupport MP_SubApp.mxml
$SDK_DIR/bin/mxmlc -debug  -includes=mx.managers.systemClasses.MarshallingSupport MP_SubApp_Untrusted.mxml
$SDK_DIR/bin/mxmlc -debug  SparkModule.mxml

 
$SDK_DIR/bin/mxmlc -debug  -theme=$SDK_DIR/frameworks/themes/Halo/halo.swc HaloModule.mxml

$SDK_DIR/bin/mxmlc -debug  StylesModule.mxml

$SDK_DIR/bin/mxmlc -debug  LoadStylesModule.mxml


$SDK_DIR/bin/mxmlc -debug  SwfLoaderAppThree.mxml

$SDK_DIR/bin/mxmlc -debug  LoadStylesSubApp.mxml

$SDK_DIR/bin/mxmlc -debug  SparkSubApp.mxml

$SDK_DIR/bin/mxmlc -debug  ViewStackModule.mxml
$SDK_DIR/bin/mxmlc -debug  FontsModule.mxml

$SDK_DIR/bin/mxmlc -debug  SparkImageMain.mxml
$SDK_DIR/bin/mxmlc -debug  SparkAlphaMain.mxml
$SDK_DIR/bin/mxmlc -debug  fontsSheet.css

$SDK_DIR/bin/mxmlc -debug  testSheet.css
$SDK_DIR/bin/mxmlc -debug  SkinModule.mxml
$SDK_DIR/bin/mxmlc -debug  SkinModule2.mxml
$SDK_DIR/bin/mxmlc -debug  ToolTipSubApp.mxml
$SDK_DIR/bin/mxmlc -debug  -sp+=../ SetStyleProblemSubApp.mxml