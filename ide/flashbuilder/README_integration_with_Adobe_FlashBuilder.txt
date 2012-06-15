<!--

  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

-->

Integrating Apache Flex SDK with Adobe Flash Builder
----------------------------------------------------

Adobe Flash Builder performs several checks on the Apache SDK to ensure compatibility of 
the SDK with Flash Builder.  

Verifying the validity of the Apache Flex SDK for Adobe FlashBuildder v4.7+
----------------------------------------------------------------------------

Flash Builder verifies the validity of the Apache Flex SDK by checking for the following:

* The following XML files and folders must be present in the root directory of the Flex SDK:
    flex-sdk-description.xml - <version> is Apache Flex 4.8.0 or higher
	templates

* The following XML files and folders must be present in the frameworks directory of the Flex SDK:
    flex-config.xml
	mxml-manifest.xml

* The following files and folders must be present in the frameworks folder of the Flex SDK:
	air-config.xml
	airmobile-config.xml
	spark-manifest.xml
	locale
	projects
	rsls
	libs\player
	libs\air

* The following JAR files must be present in the lib folder of the Flex SDK:
	flex-compiler-oem.jar
	mxmlc.jar
	adt.jar

* The following XML file must be present in ide/flashbuilder folder of the Flex SDK:
    flashbuilder-config.xml - <express-install-swf> tag required 
    
        <!-- Specifies the express install swf that will be used in the HTML file generated. -->
        <!-- The implied path is {flex-home}/templates/swfobject. -->
        <express-install-swf>expressInstall.swf</express-install-swf>
                      
        The other option that may be used is playerProductInstall.swf, which is an
        Adobe proprietary file.
	
Verifying the validity of the Apache Flex SDK for Adobe FlashBuildder v4.6
---------------------------------------------------------------------------

* The following XML files and folders must be present in the root directory of the Flex SDK:
    flex-sdk-description.xml - <version> cannot be less than 3.0.0 and it cannot be empty

* The following XML files and folders must be present in the frameworks directory of the Flex SDK:
    flex-config.xml
	mxml-manifest.xml

* The following JAR files must be present in the lib folder of the Flex SDK:
	flex-compiler-oem.jar
	mxmlc.jar
