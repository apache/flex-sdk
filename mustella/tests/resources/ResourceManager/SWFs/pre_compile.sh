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
rm -f `find . -name "*.swc"`

# Do this so that we don't hit not-a-bug number SDK-11855: 
#    Compc: Empty locale/{locale} directory has to be created in project's or framework's directory structure if specifying a locale.
# and don't create the locale/{locale} directory here in the SWFs directory or else the tests will fail if bug SDK-11860 gets fixed.
# We will use -library-path=$LIBRARY_PATH whenever there is a locale that is not en_US.
echo "Defining a library path to avoid changing your frameworks directory..."
LIBRARY_PATH="$SDK_DIR/frameworks/libs"

echo "Compiling new resource module SWFs..."
$SDK_DIR/bin/mxmlc -library-path=$LIBRARY_PATH -locale=ja_JP,fr_FR,de_DE -source-path=bundles/framework/{locale} -include-resource-bundles collections containers controls core effects formatters logging SharedResources skins states styles validators components layout sparkEffects -o bundles/framework/resMod_framework_jaJP,frFR,deDE.swf

cp bundles/framework/resMod_framework_jaJP,frFR,deDE.swf bundles/framework/resMod_framework_jaJP,frFR,deDE_02.swf

echo "Compiling resource module SWFs for event testing..."
$SDK_DIR/bin/mxmlc -locale=en_US -source-path=bundles/framework/{locale} -include-resource-bundles collections -o bundles/framework/resMod_events_001.swf
cp bundles/framework/resMod_events_001.swf bundles/framework/resMod_events_002.swf
cp bundles/framework/resMod_events_001.swf bundles/framework/resMod_events_003.swf

echo "Compiling resource module SWFs for loadResourceModule..."
$SDK_DIR/bin/mxmlc -locale=en_US -static-rsls=true -source-path=bundles/custom/{locale} -include-resource-bundles bundle1 -o bundles/custom/resMod_loadResourceModule_enUS_bundle1_001.swf
cp bundles/custom/resMod_loadResourceModule_enUS_bundle1_001.swf bundles/custom/resMod_loadResourceModule_enUS_bundle1_002.swf
cp bundles/custom/resMod_loadResourceModule_enUS_bundle1_001.swf bundles/custom/resMod_loadResourceModule_enUS_bundle1_003.swf
cp bundles/custom/resMod_loadResourceModule_enUS_bundle1_001.swf bundles/custom/resMod_loadResourceModule_enUS_bundle1_004.swf
$SDK_DIR/bin/mxmlc -locale=en_US -static-rsls=true -source-path=bundles/custom2/{locale} -include-resource-bundles bundle1 -o bundles/custom2/resMod_loadResourceModule_enUS_bundle1_005.swf
cp bundles/custom/resMod_loadResourceModule_enUS_bundle1_001.swf bundles/custom/resMod_loadResourceModule_enUS_bundle1_006.swf
cp bundles/custom/resMod_loadResourceModule_enUS_bundle1_001.swf bundles/custom/resMod_loadResourceModule_enUS_bundle1_007.swf

$SDK_DIR/bin/mxmlc -locale=en_US -source-path=bundles/custom/{locale} -include-resource-bundles bundle2 -o bundles/custom/resMod_loadResourceModule_enUS_bundle2.swf
$SDK_DIR/bin/mxmlc -locale=en_US -source-path=bundles/custom/{locale} -include-resource-bundles bundle1 bundle2 bundle3 -o bundles/custom/resMod_loadResourceModule_enUS_bundles1,2,3_001.swf
cp bundles/custom/resMod_loadResourceModule_enUS_bundles1,2,3_001.swf bundles/custom/resMod_loadResourceModule_enUS_bundles1,2,3_002.swf
$SDK_DIR/bin/mxmlc -library-path=$LIBRARY_PATH -static-rsls=true -locale=fr_FR -source-path bundles/custom/{locale} bundles/framework/{locale} -include-resource-bundles bundle2 collections containers controls core effects formatters logging SharedResources skins states styles validators components layout sparkEffects -o bundles/custom/resMod_loadResourceModule_frFR_bundle2.swf
$SDK_DIR/bin/mxmlc -locale=en_US,fr_FR,ja_JP -static-rsls=true -source-path=bundles/custom/{locale} -include-resource-bundles bundle1 bundle2 bundle3 -o bundles/custom/resMod_loadResourceModule_enUS,frFR,jaJP_bundles1,2,3.swf
$SDK_DIR/bin/mxmlc -library-path=$LIBRARY_PATH -locale=ja_JP -static-rsls=true -source-path=bundles/framework/{locale} -include-resource-bundles collections containers controls core effects formatters logging SharedResources skins states styles validators components layout sparkEffects -o bundles/framework/resMod_loadResourceModule_jaJP_framework.swf

$SDK_DIR/bin/mxmlc -library-path=$LIBRARY_PATH -locale=ja_JP,fr_FR,de_DE -source-path=bundles/framework/{locale} -include-resource-bundles collections containers controls core effects formatters logging SharedResources skins states styles validators components layout sparkEffects -o bundles/framework/resMod_loadResourceModule_jaJP,frFR,deDE_framework_001.swf
cp bundles/framework/resMod_loadResourceModule_jaJP,frFR,deDE_framework_001.swf bundles/framework/resMod_loadResourceModule_jaJP,frFR,deDE_framework_002.swf
cp bundles/framework/resMod_loadResourceModule_jaJP,frFR,deDE_framework_001.swf bundles/framework/resMod_loadResourceModule_jaJP,frFR,deDE_framework_003.swf

# On Vista, we don't have permissions to any of the files we just created.
cd ..
chmod a+rwx `find . -name *.swf`