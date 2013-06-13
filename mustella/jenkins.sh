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
## Set env variables and run script. This file is meant as a utility for the 
## Jenkins jobs on a windows machine.
## 
## NOTE: this file MUST HAVE Unix style line endings!
##

export SHELLOPTS
set -o igncr

#sh ./mini_run.sh -timeout=60000 -all
#sh ./mini_run.sh -timeout=60000 -failures
sh ./mini_run.sh -timeout=60000 tests/itemRenderers

if [[ -s failures.txt ]] ; then
	echo "Some tests failed: running '-failures'" 
	sh ./mini_run.sh -timeout=60000 -failures
else
	echo "All tests passed on first run" 
fi ;