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

# autobuild for asc

export JAVA_HOME="c:/Program Files/Java/jdk1.5.0_09"
export ANT_HOME="c:/tools/apache-ant-1.6.5"
export PATH="/c/Program Files/Java/jdk1.5.0_09/bin:/c/tools/apache-ant-1.6.5/bin:$PATH"
FILEDROP=/w/builds/as

basedir=`pwd`

change=$1
test "$change" = "" && {
   changeset=`hg tip | grep "^changeset:" | awk ' {print $2}'`
   change=`echo $changeset | awk -F: '{print $1}'`
   changeid=`echo $changeset | awk -F: '{print $2}'`
}
echo $change | grep ":" > /dev/null
if [ "$?" = "0" ]
then
   origchange=$change
   change=`echo $origchange | awk -F: '{print $1}'`
   changeid=`echo $origchange | awk -F: '{print $2}'`
else
   changeid=`hg log $change | grep "^changeset:" | awk -F: '{print $2}'`
fi

echo "starting build change=$change $changeid"

test -f $basedir/../src/java/macromedia/asc/util/Version.java.backup && 
  rm -f $basedir/../src/java/macromedia/asc/util/Version.java.backup

cp $basedir/../src/java/macromedia/asc/util/Version.java $basedir/../src/java/macromedia/asc/util/Version.java.backup

sed --in-place "s/cyclone/$change $changeid/g" $basedir/../src/java/macromedia/asc/util/Version.java
sed --in-place "s/100/$change/g" $basedir/../src/java/macromedia/asc/util/Version.java

cd $basedir/java
ant clean main authoring
ret=$?
test "$?" = "0" || {
  echo "build failed (ant clean main authoring) returned $ret"
  exit 1
}

cp $basedir/../src/java/macromedia/asc/util/Version.java.backup $basedir/../src/java/macromedia/asc/util/Version.java

test -f $basedir/../lib/asc.jar || { 
  echo "asc.jar not built, failing"
  exit 1 
}
test -f $basedir/../lib/asc_authoring.jar || { 
  echo "asc_authoring.jar not build, failing"
  exit 1
}

echo "copying build..."

test -d $FILEDROP/$change || {
  mkdir -p $FILEDROP/$change
}
last=""
test -f $FILEDROP/lastbuild.txt && {
  last=`cat $FILEDROP/lastbuild.txt`
}
echo $change > $FILEDROP/lastbuild.txt
hg log -r $last:$change > $FILEDROP/$change/changelist.txt
cp $basedir/../lib/asc.jar $FILEDROP/$change
cp $basedir/../lib/asc_authoring.jar $FILEDROP/$change
cp $basedir/../bin/asc.exe $FILEDROP/$change
cp $basedir/../bin/ash.exe $FILEDROP/$change
cp $basedir/../bin/jvm.config $FILEDROP/$change
cp $basedir/../lib/asc.jar $FILEDROP/latest
cp $basedir/../lib/asc.jar /c/lib

echo "building global.abc shell.abc"
ant globalabc -Davm.core=c:/hg/js/tamarin-buildbot/core -Dglobal.dest=c:/lib/global.abc
cp /c/lib/global.abc $FILEDROP/$change

wget -q -O wget.txt "http://10.59.3.68/cgi-bin/updatebuild.pl?build=$change&os=windows&name=asc"

exit 0