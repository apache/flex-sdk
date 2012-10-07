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


### multi process shellrunner

max=${NUMBER_OF_PROCESSORS:=1}
j=0
i=0

list=($MUSTELLA_SCRIPTS2)

len=${#list[*]}

while [ $i -lt $len ]
do


while [ $j -lt $max ]
do


dir=`dirname ${list[$i]} 2>/dev/null`
file=`basename ${list[$i]} 2>/dev/null`

cd $dir
ret=$?
if [ $ret != 0 ]
	then
	echo "Error, could not cd to $dir. Skipping $i"
	i=$((i+1))
	continue
fi


if [ "$file" != ""  ]
then
    if [ -f $file ]
    then
    	echo "next: $file $i"
    	./$file > ${file}.${i}.log 2>&1 &
    else
    	echo "skipping $file not found"
    fi
fi
	

j=$((j+1))
i=$((i+1))

done

j=`jobs -pr | wc -l`
# echo $maybe

while [ $j -ge $max ]
do

# echo "j is $j, sleeping 5"
sleep 5
j=`jobs -pr | wc -l`

done


done


## now we have to wait for them to be done

j=`jobs -pr | wc -l`
while [ $j -gt 0 ]
do
j=`jobs -pr | wc -l`

# echo "waiting for processes to finish, j is $j"

sleep 5


done

echo "done with pre compile step"

# jobs
