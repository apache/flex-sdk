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
..\cpp\win32\release\ascap.exe -p3 %1 > %1.cpp.out
move %1.p3 %1.cpp.p3
c:\j2sdk1.5.0\bin\java -ea -DAVMPLUS -DAS2 -classpath  ../../lib/asc.jar macromedia.asc.embedding.Compiler -p3 %1 2> %1.java.out
move %1.p3 %1.java.p3
diff -E -b -w -B %1.cpp.p3 %1.java.p3 > %1.p3.diff
diff -E -b -w -B %1.cpp.out %1.java.out > %1.out.diff

