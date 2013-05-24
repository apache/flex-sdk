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

## rm /var/spool/mail/mustellarunner
fetchmail
cd mustella/utilities/PatchExtractor/src
"$AIR_HOME/bin/adl" -runtime "$AIR_HOME/runtimes/air/win" PatchExtractor-app.xml -- c:/cygwin/var/spool/mail/mustellarunner
rc=$?
if [[ $rc != 0 ]] ; then
    cd ../../../..
    exit $rc
fi
cd ../../../..
git pull --rebase

for file in *.patch
do
d = dirname $file
b = basename $file .patch
r = $d/$.reply 
read replyAddr < $r
echo "Testing In Progress" >mailbody.txt
mutt -s "Patch Received" $replyAddr <mailbody.txt
sh test_patch $file
done
