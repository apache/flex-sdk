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
RESOURCES="../../../../Assets/Locales/qa_QA"
BUNDLES="bundle1 bundle2 collections containers controls core effects formatters logging SharedResources skins states styles validators layout components sparkEffects"


$SDK_DIR/bin/compc -library-path=$SDK_DIR/frameworks/libs,$SDK_DIR/frameworks/libs/mx -source-path=$RESOURCES -locale qa_QA -include-resource-bundles $BUNDLES -include-classes HaloColors MyCheckBoxIcon_qa_QA -o qa_QA_Resources.swc
