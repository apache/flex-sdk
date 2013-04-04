@echo off
rem Licensed to the Apache Software Foundation (ASF) under one or more
rem contributor license agreements.  See the NOTICE file distributed with
rem this work for additional information regarding copyright ownership.
rem The ASF licenses this file to You under the Apache License, Version 2.0
rem (the "License"); you may not use this file except in compliance with
rem the License.  You may obtain a copy of the License at
rem
rem     http://www.apache.org/licenses/LICENSE-2.0
rem
rem Unless required by applicable law or agreed to in writing, software
rem distributed under the License is distributed on an "AS IS" BASIS,
rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
rem See the License for the specific language governing permissions and
rem limitations under the License.

echo Compiling %1
SET F=%1
SET FF=%F:\=/%
SET R=%F:.as=%
..\cpp\win32\release\ascap.exe -i %FF% > %FF%.cpp.out
echo CPP DONE
cp %R%.il %R%.cpp.il
cp %R%.abc %R%.cpp.abc
..\..\bin\asc.exe  -i %F% > %F%.java.out
echo JAVA DONE
cp %R%.il %R%.java.il
cp %R%.abc %R%.java.abc
echo DIFFING
diff -E -b -w -B %R%.cpp.il %R%.java.il > %R%.il.diff
diff -E -b -w -B %F%.cpp.out %F%.java.out > %F%.out.diff
diff --binary %R%.cpp.abc %R%.java.abc > %R%.abc.diff

