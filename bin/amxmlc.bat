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

rem
rem amxmlc.bat script for Windows.
rem This simply executes mxmlc.jar in the same directory,
rem inserting the option +configname=air, which makes
rem mxmlc use air-config.xml instead of flex-config.xml.
rem On Unix, amxmlc is used instead.
rem

rem
rem Either the AIR_HOME environment variable must be set or
rem or the env.AIR_HOME property must be set in %FLEX_HOME%\env.properties.
rem If both are set the property takes precedence.
rem

if "%FLEX_HOME%"=="" set FLEX_HOME=%~dp0\..

java -Xmx384m -Dsun.io.useCanonCaches=false -jar "%FLEX_HOME%\lib\mxmlc.jar" +configname=air +flexlib="%FLEX_HOME%\frameworks" %*
