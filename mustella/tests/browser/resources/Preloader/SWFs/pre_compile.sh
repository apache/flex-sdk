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
cd Assets

echo ""
echo "Removing previously compiled files..."
rm -f `find . -name "*.swf"`

LIBRARY_PATH="$SDK_DIR/frameworks/libs"

echo ""
echo "Compiling new custom resource module SWFs..."
$SDK_DIR/bin/mxmlc -locale=en_US -source-path=resources/custom/{locale} -include-resource-bundles bundle1 -o resources/custom/enCustomResources_bundle1_001.swf
$SDK_DIR/bin/mxmlc -locale=en_US -source-path=resources/custom/{locale} -include-resource-bundles bundle2 -o resources/custom/enCustomResources_bundle2_001.swf
$SDK_DIR/bin/mxmlc -library-path=$LIBRARY_PATH -locale=fr_FR -source-path=resources/custom/{locale} -include-resource-bundles bundle1 -o resources/custom/frCustomResources_bundle1_001.swf
$SDK_DIR/bin/mxmlc -library-path=$LIBRARY_PATH -locale=en_US,fr_FR,ja_JP -source-path=resources/custom/{locale} -include-resource-bundles bundle1 bundle2 -o resources/custom/en_fr_jaCustomResources_bundles1_2_001.swf

echo ""
echo "Compiling new framework resource module SWFs..."
$SDK_DIR/bin/mxmlc -library-path=$LIBRARY_PATH -locale fr_FR -source-path=resources/framework/{locale} -include-resource-bundles collections containers controls core effects formatters logging SharedResources skins states styles validators -o resources/framework/frFrameworkResources.swf
$SDK_DIR/bin/mxmlc -library-path=$LIBRARY_PATH -locale de_DE -source-path=resources/framework/{locale} -include-resource-bundles collections containers controls core effects formatters logging SharedResources skins states styles validators -o resources/framework/deFrameworkResources.swf
$SDK_DIR/bin/mxmlc -library-path=$LIBRARY_PATH -locale ja_JP -source-path=resources/framework/{locale} -include-resource-bundles collections containers controls core effects formatters logging SharedResources skins states styles validators -o resources/framework/jaFrameworkResources.swf
