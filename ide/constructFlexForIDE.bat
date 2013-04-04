@echo off
setlocal 

REM ################################################################################
REM ##
REM ##  Licensed to the Apache Software Foundation (ASF) under one or more
REM ##  contributor license agreements.  See the NOTICE file distributed with
REM ##  this work for additional information regarding copyright ownership.
REM ##  The ASF licenses this file to You under the Apache License, Version 2.0
REM ##  (the "License"); you may not use this file except in compliance with
REM ##  the License.  You may obtain a copy of the License at
REM ##
REM ##      http://www.apache.org/licenses/LICENSE-2.0
REM ##
REM ##  Unless required by applicable law or agreed to in writing, software
REM ##  distributed under the License is distributed on an "AS IS" BASIS,
REM ##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
REM ##  See the License for the specific language governing permissions and
REM ##  limitations under the License.
REM ##
REM ################################################################################

REM    This script should be used to create an Apache Flex SDK that has the directory
REM    structure that the an IDE that supports Flex, such as Adobe Flash Builder or
REM    JetBrains IntelliJ expects. 
REM 
REM    This script can be used with either an Apache Flex binary package or an Apache Flex 
REM    source package.  In either case you must unzip the package.  If you use the source 
REM    package you must build the binaries files before running this script.  See the 
REM    "Building the Source in the Source Distribution" section in the README at the root 
REM    for build instructions.
REM
REM    The Adobe AIR SDK and the Adobe Flash Player playerglobal.swc are 
REM    copied into the Apache Flex directory.  The paths in the framework 
REM    configuration files are modified to reflect this.  You do not need to set
REM    up any of the environment variables mentioned in the README because the locations 
REM    of all the software are known in this configuration.
REM
REM    OSMF, swobject, the Adobe embedded font support, and Adobe BlazeDS integration all
REM    come from the Adobe Flex 4.6 SDK.  You should be aware that these components have
REM    their own licenses that may or may not be compatible with the Apache v2 license.
REM    See the "Software Dependencies" section in the README for more license information.
REM
REM    The Adobe Flex 4.6 SDK is available here:
REM         http://www.adobe.com/devnet/flex/flex-sdk-download.html
REM
REM    Usage: constructFlexForIDE "Apache Flex dir" ["Adobe Flex 4.6 dir"]
REM
REM
REM     If the Adobe Flex SDK 4.6 directory is not specified this script will look for it
REM     in the following places:
REM
REM     %ProgramFiles%/Adobe/Adobe Flash Builder 4.5/sdks/4.6.0
REM     %ProgramFiles%/Adobe/Adobe Flash Builder 4.6/sdks/4.6.0
REM     %ProgramFiles%/Adobe/Adobe Flash Builder 4.7/sdks/4.6.0
REM         where %ProgramFiles% is the Windows environment variable which expands 
REM         correctly for 32-bit and 64-bit Windows

set param1=%~f1
set param2=%~f2

:getApacheFlexDir
REM     Remove all quotes (%param1:"=%) and replace with outer quotes
set IDE_SDK_DIR="%param1:"=%"

if not [%IDE_SDK_DIR%] == [] goto gotApacheFlexDir
echo Usage: %0 "Apache Flex dir" ["Adobe Flex SDK 4.6 dir"]
goto :eof

:gotApacheFlexDir
echo The Apache Flex directory for the IDE is %IDE_SDK_DIR%

REM
REM     If this is an Apache Flex dir then there should be a NOTICE file.
REM
:checkApacheFlexDir
if exist %IDE_SDK_DIR%\NOTICE goto checkApacheFlexBinaries
echo %IDE_SDK_DIR% does not appear to be an Apache Flex distribution.
goto :eof

REM
REM     Quick check to see if there are binaries in the Apache distribution.
REM
:checkApacheFlexBinaries
if exist %IDE_SDK_DIR%\lib\mxmlc.jar goto getAdobeFlexDir
echo %IDE_SDK_DIR% does not appear to be a Apache Flex distribution with binaries.
echo If this is a source distribution of Apache Flex you must build the binaries first.
echo See the README.
goto :eof

:getAdobeFlexDir
if not [%param2%] == [] (
    set ADOBE_FLEX_SDK_DIR="%param2:"=%"
    goto gotAdobeFlexSDK
)

REM
REM     Look for FlashBuilder versions 4.5, 4.6 and 4.7.
REM
set ADOBE_FLEX_SDK_DIR=
for %%V in (4.5 4.6 4.7) do ( 
    if exist "%ProgramFiles%\Adobe\Adobe Flash Builder %%V\sdks\4.6.0" (
        set ADOBE_FLEX_SDK_DIR="%ProgramFiles%\Adobe\Adobe Flash Builder %%V\sdks\4.6.0"
        goto gotAdobeFlexSDK
    )
)

REM
REM     Couldn't find default Adobe Flex SDK so ask for it.
REM
echo Enter directory of an Adobe Flex SDK 4.6:
set /p ADOBE_FLEX_SDK_DIR=

:gotAdobeFlexSDK
echo The Adobe Flex directory is %ADOBE_FLEX_SDK_DIR%
echo.

REM
REM     Quick check to see if it is a Flex SDK.
REM
:checkAdobeFlexSDK
if exist %ADOBE_FLEX_SDK_DIR%\license-adobesdk.htm goto copyAdobeAIRSDK
echo %ADOBE_FLEX_SDK_DIR% does not appear to be an Adobe Flex SDK
goto :eof


REM
REM     Copy all the AIR SDK files to the IDE SDK.
REM     Copy files first, then directories with (/s).
REM
:copyAdobeAIRSDK
echo Copying the AIR SDK files to %IDE_SDK_DIR%

for %%G in (
    "AIR SDK license.pdf"
    "AIR SDK Readme.txt"
    bin\adl.exe
    bin\adt.bat
    lib\adt.jar
    samples\descriptor-sample.xml) do (
    
    if exist %ADOBE_FLEX_SDK_DIR%\%%G (
        copy /y %ADOBE_FLEX_SDK_DIR%\%%G %IDE_SDK_DIR%\%%G
    )
)

for %%G in (
    frameworks\libs\air
    frameworks\projects\air
    include
    install\android
    lib\android
    lib\aot
    lib\nai
    lib\win
    runtimes\air\android
    runtimes\air\mac
    runtimes\air\win
    runtimes\air-captive\mac
    runtimes\air-captive\win
    samples\badge
    samples\icons
    templates\air
    templates\extensions) do (
    
    if exist %ADOBE_FLEX_SDK_DIR%\%%G (
        REM    Make the directory so it won't prompt for file or directory.
        if not exist %IDE_SDK_DIR%\%%G mkdir %IDE_SDK_DIR%\%%G
        xcopy /q /y /e /i /c /r %ADOBE_FLEX_SDK_DIR%\%%G %IDE_SDK_DIR%\%%G
        if %errorlevel% NEQ 0 GOTO errorExit
    )
)

REM
REM     Copy all the third-party files from the Adobe Flex SDK to the IDE SDK.
REM
echo Copying the third-party files to %IDE_SDK_DIR%

for %%G in (
    frameworks\libs\player\11.1
    frameworks\javascript\fabridge\samples\fabridge\swfobject
    runtimes\player\11.1\lnx
    runtimes\player\11.1\mac
    runtimes\player\11.1\win) do (
    
    if not exist %IDE_SDK_DIR%\%%G mkdir %IDE_SDK_DIR%\%%G
    if %errorlevel% NEQ 0 GOTO errorExit
)

for %%G in (
    frameworks\libs\osmf.swc
    frameworks\libs\player\11.1\playerglobal.swc
    frameworks\javascript\FABridge\samples\fabridge\swfobject\swfobject.js
    lib\flex-messaging-common.jar
    lib\afe.jar
    lib\aglj40.jar
    lib\flex-fontkit.jar
    lib\rideau.jar
    templates\swfobject\swfobject.js
    runtimes\player\11.1\lnx
    runtimes\player\11.1\mac
    runtimes\player\11.1\win) do (
    
    copy /y %ADOBE_FLEX_SDK_DIR%\%%G %IDE_SDK_DIR%\%%G
)

REM
REM     Copy config files formatted for IDE to frameworks.
REM
echo Copying frameworks config files configured for use without environment variables
copy /y %IDE_SDK_DIR%\ide\flashbuilder\config\*-config.xml %IDE_SDK_DIR%\frameworks

goto :eof

:errorExit
REM echo Exiting: error %errorlevel%
exit /b %errorlevel%
