@echo off

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

REM     This script should be used to create an Apache Flex SDK that has the
REM     directory structure that the Adobe Flash Player IDE expects.
REM
REM     The Adobe AIR SDK and the Adobe Flash Player playerglobal.swc are integrated
REM     into the directory structure.  The paths in the framework configuration files are 
REM     modified to reflect this.  The AIR_HOME and PLAYERGLOBAL_HOME environment 
REM     variables are not required because the locations of these pieces are known.
REM
REM     Usage: makeApacheFlexForFlashBuilder [sdk directory]
REM

REM     Edit these constants if you would like to download from alternative locations.
REM
REM     Apache Flex binary distribution
REM
set APACHE_FLEX_BIN_DISTRO_FILE=apache-flex-sdk-4.8.0-incubating-bin.zip
set APACHE_FLEX_BIN_DISTRO_URL=http://people.apache.org/~cframpton/ApacheFlexRC/current/%APACHE_FLEX_BIN_DISTRO_FILE%

REM
REM     Adobe AIR SDK Version 3.1
REM
set ADOBE_AIR_SDK_WIN_FILE=AdobeAIRSDK.zip
set ADOBE_AIR_SDK_WIN_URL=http://airdownload.adobe.com/air/win/download/3.1/%ADOBE_AIR_SDK_WIN_FILE%

REM
REM     Adobe Flash Player Version 11.1
REM
set ADOBE_FB_GLOBALPLAYER_SWC_URL=http://fpdownload.macromedia.com/get/flashplayer/updaters/11/playerglobal11_1.swc

if not [%1] == [] goto gotDir
echo Usage: %0 [directory for Apache Flex SDK for Adobe Flash Builder]
goto :eof

REM
REM     Set FLEX_HOME to the fully qualified path to %1.
REM     Make sure the directory for the Apache Flex SDK exists.
REM
:gotDir
set FLEX_HOME=%~f1
if not exist "%FLEX_HOME%" mkdir "%FLEX_HOME%"

REM
REM     Put the downloads here.
REM
set tempDir=%FLEX_HOME%\temp
if not exist "%tempDir%" mkdir "%tempDir%"

REM
REM     See if jar.exe is in the PATH.   If so we can use it to uncompress the zip files
REM     since it is much faster than the vbs script.
REM
for %%X in (jar.exe) do (set hasJarExe=%%~$PATH:X)

REM
REM     Download Apache Flex SDK.
REM
echo Downloading Apache Flex SDK from "%APACHE_FLEX_BIN_DISTRO_URL%" to "%tempDir%\%APACHE_FLEX_BIN_DISTRO_FILE%"
PowerShell -Command "& {(new-object System.Net.WebClient).DownloadFile('%APACHE_FLEX_BIN_DISTRO_URL%', '%tempDir%\%APACHE_FLEX_BIN_DISTRO_FILE%')}"
if %errorlevel% neq 0 goto errorExit

echo Uncompressing Apache Flex SDK to "%FLEX_HOME%"
if defined hasJarExe (
    pushd "%FLEX_HOME%" & jar xf "%tempDir%\%APACHE_FLEX_BIN_DISTRO_FILE%" & popd
) else (
    PowerShell -Command "& {$zipPackage=(new-object -com shell.application).NameSpace('%tempDir%\%APACHE_FLEX_BIN_DISTRO_FILE%'); $destinationFolder=(new-object -com shell.application).NameSpace('%FLEX_HOME%'); $destinationFolder.CopyHere($zipPackage.Items(),20)}"
    if %errorlevel% neq 0 goto errorExit
)

REM
REM     Download AIR Runtime Kit for Windows
REM
echo Downloading Adobe AIR Runtime Kit for Windows from "%ADOBE_AIR_SDK_WIN_URL%" to "%tempDir%\%ADOBE_AIR_SDK_WIN_FILE%"
PowerShell -Command "& {(new-object System.Net.WebClient).DownloadFile('%ADOBE_AIR_SDK_WIN_URL%', '%tempDir%\%ADOBE_AIR_SDK_WIN_FILE%')}"
if %errorlevel% neq 0 goto errorExit

echo Uncompressing Adobe AIR Runtime Kit for Windows from "%tempDir%\%ADOBE_AIR_SDK_WIN_FILE%" to "%FLEX_HOME%"
if defined hasJarExe (
    pushd "%FLEX_HOME%" & jar xf "%tempDir%\%ADOBE_AIR_SDK_WIN_FILE%" & popd
) else (
    PowerShell -Command "& {$zipPackage=(new-object -com shell.application).NameSpace('%tempDir%\%ADOBE_AIR_SDK_WIN_FILE%'); $destinationFolder=(new-object -com shell.application).NameSpace('%FLEX_HOME%'); $destinationFolder.CopyHere($zipPackage.Items(),20)}"
    if %errorlevel% neq 0 goto errorExit
)

REM
REM     Download playerglobal.swc
REM
set FB_GLOBALPLAYER_DIR=%FLEX_HOME%\frameworks\libs\player\11.1
if not exist "%FB_GLOBALPLAYER_DIR%" mkdir "%FB_GLOBALPLAYER_DIR%"

echo Downloading Adobe Flash Player playerglobal.swc from "%ADOBE_FB_GLOBALPLAYER_SWC_URL%" to "%FB_GLOBALPLAYER_DIR%\playerglobal.swc"
PowerShell -Command "& {(new-object System.Net.WebClient).DownloadFile('%ADOBE_FB_GLOBALPLAYER_SWC_URL%', '%FB_GLOBALPLAYER_DIR%\playerglobal.swc')}"
if %errorlevel% neq 0 goto errorExit

REM
REM     Copy config files formatted for Flash Builder to frameworks.
REM
echo Installing frameworks config files configured for use with Adobe Flash Builder
copy /y "%FLEX_HOME%"\ide\flashbuilder\config\*-config.xml "%FLEX_HOME%\frameworks"
if %errorlevel% neq 0 goto errorExit

REM
REM         Remove zipped kits.
REM
rmdir /s /q "%tempDir%"

goto :eof

:errorExit
echo Exiting: error %errorlevel%
exit /b %errorlevel%