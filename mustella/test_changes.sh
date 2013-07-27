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
## test_changes.sh - runs mini_run.sh -changes and runs mini_run-failures if
## there are failures
##

numlines=0
if [ -s changes.txt ]
then
sh ./mini_run.sh $MINI_RUN_TIMEOUT $MINI_RUN_LOCALHOST -changes
if [ -s failures.txt ]
then
cp results.txt results.bak
sh ./mini_run.sh $MINI_RUN_TIMEOUT $MINI_RUN_LOCALHOST -failures
cat results.bak results.txt >results.all
cp results.all results.txt
rm results.bak
rm results.all
fi
else
        if [ $# -lt 1 ]
        then
    	    echo "no changes.txt or nothing in it"
        else
            mutt -s "No Tests Found" $1 <$2
        fi
	exit
fi
if [ -s failures.txt ]
then
    numlines=`wc -l failures.txt | awk {'print $1'}`
    if [ $# -lt 1 ]
    then
        echo "$numlines tests failed"
    else
        mutt -s "$numlines tests failed" $1 <failures.txt
    fi
else
    numlines=`wc -l results.txt | awk {'print $1'}`
	let "numlines = $numlines - 19"
    if [ $# -lt 1 ]
    then
        echo "$numlines tests passed"
    else
         mutt -s "$numlines tests passed" $1 <results.txt
    fi
fi
