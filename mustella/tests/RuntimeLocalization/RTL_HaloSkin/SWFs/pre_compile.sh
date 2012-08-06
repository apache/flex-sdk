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
# Prevent rerunning when debugging by setting this to 0.
DO_PRECOMPILE=1

if [ $DO_PRECOMPILE != "0" ]
then
    
    cd Assets
    
    echo "SDK: $SDK_DIR"
    
    echo ""
    echo "Removing previously compiled files..."
    # Be careful to not delete bundles/flex20's SWC, since that is a 2.0 SWC we need to keep around.
    rm -f `find . -name "*.swf"`
    rm -f `find bundles/custom -name "*.swc"`
    rm -f `find bundles/custom2 -name "*.swc"`
    rm -f `find bundles/framework -name "*.swc"`
    rm -f `find Modules -name "*.swc"`
    
    # Do this so that we don't hit not-a-bug number SDK-11855: 
    #    Compc: Empty locale/{locale} directory has to be created in project's or framework's directory structure if specifying a locale.
    # and don't create the locale/{locale} directory here in the SWFs directory or else the tests will fail if bug SDK-11860 gets fixed.
    # We will use -library-path=$LIBRARY_PATH whenever there is a locale that is not en_US.
    echo "Defining a library path to avoid changing your frameworks directory..."
    LIBRARY_PATH="$SDK_DIR/frameworks/libs,$SDK_DIR/frameworks/libs/mx"
    
    echo "Compiling new framework SWCs..."
    $SDK_DIR/bin/compc -library-path=$LIBRARY_PATH -source-path=bundles/framework/de_DE -locale de_DE -include-resource-bundles collections components containers controls core effects formatters logging SharedResources skins states styles validators -o bundles/framework/deResources.swc
    $SDK_DIR/bin/compc -source-path=bundles/framework/en_US -locale en_US -include-resource-bundles collections components containers controls core effects formatters logging SharedResources skins states styles validators -o bundles/framework/enResources.swc
    $SDK_DIR/bin/compc -library-path=$LIBRARY_PATH -source-path=bundles/framework/fr_FR -locale fr_FR -include-resource-bundles collections components containers controls core effects formatters layout logging SharedResources skins states styles validators -o bundles/framework/frResources.swc
    $SDK_DIR/bin/compc -library-path=$LIBRARY_PATH -source-path=bundles/framework/ja_JP -locale ja_JP -include-resource-bundles collections components containers controls core effects formatters layout logging SharedResources skins states styles validators -o bundles/framework/jaResources.swc
    $SDK_DIR/bin/compc -library-path=$LIBRARY_PATH -source-path=bundles/framework/qa_QA -locale qa_QA -include-resource-bundles collections components containers controls core effects formatters layout logging SharedResources skins states styles validators -o bundles/framework/qaResources.swc
    
    # echo ""
    # echo "Compiling new custom SWCs..."
    $SDK_DIR/bin/compc -library-path=$LIBRARY_PATH -source-path=bundles/custom/fr_FR -locale fr_FR -include-resource-bundles bundle1 bundle2 bundle3 bundle4 bundle5 -include-file locale/fr_FR/flag.gif bundles/custom/fr_FR/flag.gif -include-classes HaloColors MyCheckBoxIcon_fr_FR -o bundles/custom/frCustomResources.swc
    $SDK_DIR/bin/compc -library-path=$LIBRARY_PATH -source-path=bundles/custom/ja_JP -locale ja_JP -include-resource-bundles bundle1 bundle2 bundle3 bundle4 bundle5 -include-file locale/ja_JP/flag.gif bundles/custom/ja_JP/flag.gif -include-classes HaloColors MyCheckBoxIcon_ja_JP -o bundles/custom/jaCustomResources.swc
    $SDK_DIR/bin/compc -source-path=bundles/custom/en_US -locale en_US -include-resource-bundles bundle1 bundle2 bundle3 bundle4 bundle5 -include-file locale/en_US/flag.gif bundles/custom/en_US/flag.gif -include-classes HaloColors MyCheckBoxIcon_en_US -o bundles/custom/enCustomResources.swc
     
    # echo ""
    # echo "Compiling new resource module SWFs..."
    $SDK_DIR/bin/mxmlc -locale=en_US -source-path=bundles/custom/{locale} -include-resource-bundles bundle1 -o bundles/custom/resMod_enUS_bundle1_001.swf
    $SDK_DIR/bin/mxmlc -locale=en_US -source-path=bundles/custom2/{locale} -include-resource-bundles bundle1 -o bundles/custom2/resMod_enUS_bundle1_101.swf
    $SDK_DIR/bin/mxmlc -locale=en_US -source-path=bundles/custom/{locale} -include-resource-bundles bundle2 -o bundles/custom/resMod_enUS_bundle2.swf
    $SDK_DIR/bin/mxmlc -locale=en_US -source-path=bundles/custom/{locale} -include-resource-bundles bundle2 bundle3 -o bundles/custom/resMod_enUS_bundles2,3.swf
    $SDK_DIR/bin/mxmlc -locale=en_US -source-path=bundles/custom/{locale} -include-resource-bundles bundle1 bundle2 bundle3 -o bundles/custom/resMod_enUS_bundles1,2,3.swf
    $SDK_DIR/bin/mxmlc -library-path=$LIBRARY_PATH -locale=fr_FR -source-path=bundles/custom/{locale} -include-resource-bundles bundle2 -o bundles/custom/resMod_frFR_bundle2.swf
     
    $SDK_DIR/bin/mxmlc -library-path=$LIBRARY_PATH -locale=en_US,fr_FR,ja_JP -source-path=bundles/custom/{locale} -include-resource-bundles bundle1 -o bundles/custom/resMod_enUS,frFR,jaJP_bundle1.swf
    $SDK_DIR/bin/mxmlc -library-path=$LIBRARY_PATH -locale=en_US,fr_FR,ja_JP -source-path=bundles/custom/{locale} -include-resource-bundles bundle2 -o bundles/custom/resMod_enUS,frFR,jaJP_bundle2.swf
    $SDK_DIR/bin/mxmlc -library-path=$LIBRARY_PATH -locale=en_US,fr_FR,ja_JP -source-path=bundles/custom/{locale} -include-resource-bundles bundle2 bundle3 -o bundles/custom/resMod_enUS,frFR,jaJP_bundles2,3.swf
    $SDK_DIR/bin/mxmlc -library-path=$LIBRARY_PATH -locale=en_US,fr_FR,ja_JP -source-path=bundles/custom/{locale} -include-resource-bundles bundle1 bundle2 bundle3 -o bundles/custom/resMod_enUS,frFR,jaJP_bundles1,2,3.swf
    $SDK_DIR/bin/mxmlc -library-path=$LIBRARY_PATH -locale=ja_JP,fr_FR,de_DE -source-path=bundles/framework/{locale} -include-resource-bundles collections containers controls core effects formatters logging SharedResources skins states styles validators -o bundles/framework/resMod_framework_jaJP,frFR,deDE.swf
    $SDK_DIR/bin/mxmlc -locale=en_US -source-path=bundles/framework/{locale} -include-resource-bundles collections containers controls core effects formatters logging SharedResources skins states styles validators -o bundles/framework/resMod_framework_enUS.swf
    $SDK_DIR/bin/mxmlc -library-path=$LIBRARY_PATH -locale=ja_JP -source-path=bundles/framework/{locale} -include-resource-bundles collections containers controls core effects formatters logging SharedResources skins states styles validators -o bundles/framework/resMod_framework_jaJP.swf
     
    # This is a workaround to use until unloadResourceModule() is implemented.  We can't reload a bundle until we unload it, so just keep loading more.
    cp bundles/custom/resMod_enUS_bundle1_001.swf bundles/custom/resMod_enUS_bundle1_002.swf
    cp bundles/custom/resMod_enUS_bundle1_001.swf bundles/custom/resMod_enUS_bundle1_003.swf
    cp bundles/custom/resMod_enUS_bundle1_001.swf bundles/custom/resMod_enUS_bundle1_004.swf
    cp bundles/custom/resMod_enUS_bundle1_001.swf bundles/custom/resMod_enUS_bundle1_005.swf
    cp bundles/custom/resMod_enUS_bundle1_001.swf bundles/custom/resMod_enUS_bundle1_006.swf
    cp bundles/custom/resMod_enUS_bundle1_001.swf bundles/custom/resMod_enUS_bundle1_007.swf
    cp bundles/custom/resMod_enUS_bundle1_001.swf bundles/custom/resMod_enUS_bundle1_008.swf
    cp bundles/custom/resMod_enUS_bundle1_001.swf bundles/custom/resMod_enUS_bundle1_009.swf
    cp bundles/custom/resMod_enUS_bundle1_001.swf bundles/custom/resMod_enUS_bundle1_010.swf
    cp bundles/framework/resMod_framework_enUS.swf bundles/framework/resMod_framework_enUS_001.swf
    cp bundles/framework/resMod_framework_enUS.swf bundles/framework/resMod_framework_enUS_002.swf
    cp bundles/framework/resMod_framework_enUS.swf bundles/framework/resMod_framework_enUS_003.swf
    cp bundles/framework/resMod_framework_enUS.swf bundles/framework/resMod_framework_enUS_004.swf
    cp bundles/framework/resMod_framework_jaJP,frFR,deDE.swf bundles/framework/resMod_framework_jaJP,frFR,deDE_001.swf
    cp bundles/framework/resMod_framework_jaJP,frFR,deDE.swf bundles/framework/resMod_framework_jaJP,frFR,deDE_002.swf
    cp bundles/framework/resMod_framework_jaJP,frFR,deDE.swf bundles/framework/resMod_framework_jaJP,frFR,deDE_003.swf
     
    # echo ""
    # echo "Compiling modules (ModuleLoader modules, not resource modules)..."
    $SDK_DIR/bin/mxmlc -o Modules/module_framework_enUS.swf Modules/module_framework.mxml
    $SDK_DIR/bin/mxmlc -library-path=$LIBRARY_PATH -locale=ja_JP -library-path+=bundles/framework/jaResources.swc -o Modules/module_framework_jaJP.swf Modules/module_framework.mxml
    $SDK_DIR/bin/mxmlc -locale=en_US -source-path=bundles/custom/{locale} -o Modules/module_nonframework_enUS.swf Modules/module_nonframework.mxml
    $SDK_DIR/bin/mxmlc -library-path=$LIBRARY_PATH -locale=ja_JP -library-path+=bundles/framework/jaResources.swc -source-path=bundles/custom/{locale} -o Modules/module_nonframework_jaJP.swf Modules/module_nonframework.mxml
    
    # On Vista, we don't have permissions to any of the files we just created.
    chmod a+rwx `find . -name *.swf`
    chmod a+rwx `find . -name *.swc`
fi