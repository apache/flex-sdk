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
cd ../SWFs/assets


echo "Compiling DragManager sub application SWFs..."
$SDK_DIR/bin/mxmlc -includes=mx.managers.systemClasses.MarshallingSupport -source-path=$MUSTELLA_DIR/as3/src/mustella -includes=UnitTester -theme=$SDK_DIR/frameworks/themes/Halo/halo.swc MP_DragManager_Events.mxml
$SDK_DIR/bin/mxmlc -includes=mx.managers.systemClasses.MarshallingSupport -source-path=$MUSTELLA_DIR/as3/src/mustella -includes=UnitTester -theme=$SDK_DIR/frameworks/themes/Halo/halo.swc DragMXMLComp.mxml

if (! [ -e DragMXMLComp_remote.swf ])
then
   $SDK_DIR/bin/mxmlc -includes=mx.managers.systemClasses.MarshallingSupport -source-path=$MUSTELLA_DIR/as3/src/mustella -includes=UnitTester -theme=$SDK_DIR/frameworks/themes/Halo/halo.swc DragMXMLComp.mxml
fi

if (! [ -e MP_DragManager_Remote.swf ])
then
   $SDK_DIR/bin/mxmlc -includes=mx.managers.systemClasses.MarshallingSupport -source-path=$MUSTELLA_DIR/as3/src/mustella -includes=UnitTester -theme=$SDK_DIR/frameworks/themes/Halo/halo.swc MP_DragManager_Events.mxml
fi
