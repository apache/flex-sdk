#!/bin/bash
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


(set -o igncr) 2>/dev/null && set -o igncr; # comment is needed

export JAVA_HOME="c:/Program Files/Java/jdk1.5.0_09"
export ANT_HOME="c:/tools/apache-ant-1.6.5"
export PATH="/c/Program Files/Java/jdk1.5.0_09/bin:/c/tools/apache-ant-1.6.5/bin:$PATH"
FILEDROP=/w/builds/as

basedir=`pwd`

export ASC=c:/lib/asc.jar
export GLOBALABC=c:/lib/global.abc
export AVM=c:/lib/avmshell.exe
avmshellversion=`$AVM | head -1 | awk '{ print $5 }'`
ascversion=`java -jar $ASC | head -2 | tail -1 | awk '{ printf("%s %s",$4,$5) }'`
echo "avm-version $avmshellversion"
echo "asc-version $ascversion"
cd /c/hg/js/tamarin-buildbot/test
./rebuildtests.py .
./runtests.py .
