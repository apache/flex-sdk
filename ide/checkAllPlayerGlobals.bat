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

REM #
REM # Usage: checkAllPlayerGlobals "Apache Flex dir"
REM #
REM # This script should be used to check all versions of playerglobal.swc in an
REM # Apache Flex SDK for Windows
REM # If a playerglobal.swc is missing it will be downloaded form the Adobe site.

REM # Process the parameters.

set param1=%~f1

:getApacheFlexDir
REM     Remove all quotes (%param1:"=%) and replace with outer quotes
if defined param1 set IDE_SDK_DIR="%param1:"=%"

if defined param1 (
	if exist %IDE_SDK_DIR% goto gotApacheFlexDir
)
echo Apache Flex directory not specified, or invalid directory path
echo Usage: %0 "Apache Flex directory"
goto :eof

:gotApacheFlexDir
echo The Apache Flex directory for the IDE is %IDE_SDK_DIR%

REM
REM     If this is an Apache Flex dir then there should be a NOTICE file.
REM
:checkApacheFlexDir
if exist %IDE_SDK_DIR%\NOTICE goto checkPlayerGlobals
echo %IDE_SDK_DIR% does not appear to be an Apache Flex distribution.
goto :eof


:agreeLicense
	echo.
	echo Playerglobal.swc is part of the Adobe Flash Player and is licensed
	echo "under the the Flash Player end user license agreement (EULA)."
	echo.
	echo The 10.2 and 10.3 Flash Player EULA is specified here:
	echo http://www.adobe.com/products/eulas/pdfs/PlatformClients_PC_WWEULA_Combined_20100108_1657.pdf
	echo.
	echo The 11.X Flash Player EULA is specified here:
	echo http://www.adobe.com/products/eulas/pdfs/PlatformClients_PC_WWEULA-MULTI-20110809_1357.pdf
	echo.
	echo In addition to the Adobe EULA license terms, you also agree to be bound by the third-party
	echo terms specified here:
	echo http://www.adobe.com/products/eula/third_party/
	echo.
	echo Adobe recommends that you review all licensing terms.
	echo.
	set /p accept=Please type Y to agree to terms of the license :
	echo.
	set accepted=
	if "%accept%" == "Y" set accepted=true
	if "%accept%" == "y" set accepted=true
	if not defined accepted exit
	echo License accepted
	exit /b
	
:downloadPlayerGlobal
    set version=%1
    set playerGlobalDir=%IDE_SDK_DIR%\frameworks\libs\player\%version%
    set playerGlobalSWC=%playerGlobalDir%\playerglobal.swc
    set MD5check=%2
    set AdobeURL=%3
 
	if not exist %playerGlobalDir% mkdir %playerGlobalDir%
	if not exist %playerGlobalSWC% (
		echo.
		echo Downloading player global %version%
		pushd %~dp0
		cscript //B //nologo winDownloadPlayerGlobal.vbs %AdobeURL% %playerGlobalSWC%
	) else (
		echo Player global %version% exists
		exit /b
	)
	
	
	echo md5 checksum verification is not yet implemented for the download at
	echo %playerGlobalSWC%
	echo please verify with a md5 check tool, the md5 hash should be:
	echo %MD5check%

	exit /b
	
	

:checkPlayerGlobals
call :agreeLicense

rem # Note Adobe releases new versions of playerglobal.swf so if your checksum is wrong it may mean you just don't have the latest

call :downloadPlayerGlobal 10.2 aa7d785dd5715626201f5e30fc1deb51 http://download.macromedia.com/get/flashplayer/installers/archive/playerglobal/playerglobal10_2.swc
call :downloadPlayerGlobal 10.3 6092b3d4e2784212d174ca10904412bd http://download.macromedia.com/get/flashplayer/installers/archive/playerglobal/playerglobal10_3.swc
call :downloadPlayerGlobal 11.0 5f5a291f02105cd83fb582b76646e603 http://download.macromedia.com/get/flashplayer/updaters/11/playerglobal11_0.swc
call :downloadPlayerGlobal 11.1 e3a0e0e8c703ae5b1847b8ac25bbdc5f http://download.macromedia.com/get/flashplayer/updaters/11/playerglobal11_1.swc
call :downloadPlayerGlobal 11.2 c544a069518897880e0d732457b6fdeb http://download.macromedia.com/get/flashplayer/updaters/11/playerglobal11_2.swc
call :downloadPlayerGlobal 11.3 e2a9ee439d9660feaf756aa05e7e6412 http://download.macromedia.com/get/flashplayer/updaters/11/playerglobal11_3.swc
call :downloadPlayerGlobal 11.4 e15587856cdb5e21fa1acb6b0610a032 http://download.macromedia.com/get/flashplayer/updaters/11/playerglobal11_4.swc
call :downloadPlayerGlobal 11.5 00384b24157442c59ca5d625ecfd11a2 http://download.macromedia.com/get/flashplayer/updaters/11/playerglobal11_5.swc
call :downloadPlayerGlobal 11.6 1b841a0a26ada3e5da26eb70c32ab263 http://download.macromedia.com/get/flashplayer/updaters/11/playerglobal11_6.swc
call :downloadPlayerGlobal 11.7 12656571c57b2ad641838e5695a00e27 http://download.macromedia.com/get/flashplayer/updaters/11/playerglobal11_7.swc
call :downloadPlayerGlobal 11.8 20ce9ae3b2ddd4a5ff3fe65c0a7f1139 http://download.macromedia.com/get/flashplayer/updaters/11/playerglobal11_8.swc
call :downloadPlayerGlobal 11.9 4cac2727e7b7e741075581f47c35f3af http://download.macromedia.com/get/flashplayer/updaters/11/playerglobal11_9.swc
call :downloadPlayerGlobal 12.0 4db4e934f39f774ba68fcd9a79654971 http://download.macromedia.com/get/flashplayer/updaters/12/playerglobal12_0.swc
call :downloadPlayerGlobal 13.0 7f9bfe038f00e97bc44abf52bb5b1260 http://download.macromedia.com/get/flashplayer/updaters/13/playerglobal13_0.swc
call :downloadPlayerGlobal 14.0 2465d2fcf0d985ed10231b43f61c3024 http://download.macromedia.com/get/flashplayer/updaters/14/playerglobal14_0.swc



