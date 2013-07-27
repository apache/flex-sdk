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
##
## test_patch_by_email.sh gets email, finds patches, saves them to files 
## runs test_patch
##

rm /var/spool/mail/mustellarunner
fetchmail
if [ -f "/var/spool/mail/mustellarunner" ]
then
cd mustella/utilities/PatchExtractor/src
echo "launching patch extractor"
"$AIR_HOME/bin/adl" -runtime "$AIR_HOME/runtimes/air/win" PatchExtractor-app.xml -- c:/cygwin/var/spool/mail/mustellarunner
cd ../../../..
gotone=0
for file in *.patch
do
    git pull --rebase
    gotone=1
    break;
done
if [ gotone == 0 ] ; then
    echo "no patches"
    exit 2
fi

for file in *.patch
do
d=`dirname $file`
b=`basename $file .patch`
read replyAddr < $d/$b.reply
sh test_patch.sh $file $replyAddr
rm $file
rm $replyAddr
done
else
    echo "no messages"
fi
