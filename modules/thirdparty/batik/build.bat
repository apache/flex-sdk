@echo off
:: ----------------------------------------------------------------------------
:: Copyright 2000-2003 The Apache Software Foundation
:: 
::    Licensed under the Apache License, Version 2.0 (the "License");
::    you may not use this file except in compliance with the License.
::    You may obtain a copy of the License at
:: 
::        http://www.apache.org/licenses/LICENSE-2.0
:: 
::    Unless required by applicable law or agreed to in writing, software
::    distributed under the License is distributed on an "AS IS" BASIS,
::    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
::    See the License for the specific language governing permissions and
::    limitations under the License.
:: 
:: build.bat - Win32 Build Script for Apache Batik
::
:: $Id$
:: ----------------------------------------------------------------------------

:: ----- Verify and Set Required Environment Variables ------------------------

if not "%JAVA_HOME%" == "" goto gotJavaHome
echo You must set JAVA_HOME to point at your Java Development Kit installation
goto cleanup
:gotJavaHome

if not "%ANT_HOME%" == "" goto gotAntHome

:: ----- Set Up The Runtime Classpath -----------------------------------------


set CP=%JAVA_HOME%\lib\tools.jar;lib\build\ant_1_4_1.jar;.\lib\build\crimson-ant.jar;.\lib\build\jaxp.jar
 

:: ----- Execute The Requested Build ------------------------------------------

%JAVA_HOME%\bin\java.exe %ANT_OPTS% -classpath %CP% org.apache.tools.ant.Main -emacs -Dant.home=. %1 -Dargs="%2 %3 %4 %5 %6 %7 %8 %9"

:: ----- Cleanup the environment ----------------------------------------------

goto cleanup

:gotAntHome

call ant -Dargs="%2 %3 %4 %5 %6 %7 %8 %9" %1

goto cleanup

:cleanup
set CP=

