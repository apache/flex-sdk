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
rm -f `find . -name "*.swc"`
rm -f `find . -name "*.swf"`

# Do this so that we don't hit not-a-bug number SDK-11855: 
#    Compc: Empty locale/{locale} directory has to be created in project's or framework's directory structure if specifying a locale.
# and don't create the locale/{locale} directory here in the SWFs directory or else the tests will fail if bug SDK-11860 gets fixed.
# We will use -library-path=$LIBRARY_PATH whenever there is a locale that is not en_US.
echo "Defining a library path to avoid changing your frameworks directory..."
LIBRARY_PATH="$SDK_DIR/frameworks/libs,$SDK_DIR/frameworks/libs/mx"

echo ""
echo "Compiling new SWC with commas..."
$SDK_DIR/bin/compc -library-path=$LIBRARY_PATH -locale=en_US,fr_FR,ja_JP -source-path=bundles/custom/{locale} -include-resource-bundles=bundle1,bundle2,bundle3 -output=enUS_frFR_jaJP_bundles123_commas.swc

echo "Compiling new SWC with spaces..."
$SDK_DIR/bin/compc -library-path=$LIBRARY_PATH -locale en_US fr_FR ja_JP -source-path bundles/custom/{locale} -include-resource-bundles bundle1 bundle2 bundle3 -output enUS_frFR_jaJP_bundles123_spaces.swc