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
BEGIN { FS="," 

	MYLINE=""

	while ( (getline line < "local.properties") > 0) {
		if (index(line, "extra_includes") == 1) {
			MYLINE=	substr(line, index(line, "=")+1)
		}
	}

	## treat the entry as an array
	n = split(MYLINE, arr)

	for (z in arr)
		print "myline: "  arr[z]

}
{

reg=0;app=0;

if ( (reg=index($1, "sdk.mustella.excludes")) > 0 || (app=index($1, "apollo_only_excludes")) > 0) {

	# print "found reg or app in " $1 "reg:"reg" app:" app;

	## operate on this line
	# clip $1

	resultLine=""

	for (i=1;i<=NF;i++) {
		
		field=$i

		if (i==1)
			field = substr($i, index($i, "=")+1)


		## loop through our list of extra_includes for a match. 
		sawmatch=0;
		for (j in arr) {
			if (field==arr[j])  {
				sawmatch=1;
			}
		}

		if (!sawmatch)
			resultLine=sprintf("%s,%s", field, resultLine);


	}



}
}

END { 


	if (resultLine != "" && reg)
		print "sdk.mustella.excludes="resultLine
	if (resultLine != "" && app)
		print "apollo_only_excludes="resultLine

}

