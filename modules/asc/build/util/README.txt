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

The files in this directory are used to generate ErrorConstants.java and WarningConstants.java.

To build these files you need access to Tamarin.  Build documentation can be found at 
https://developer.mozilla.org/En/Tamarin/Tamarin_Build_Documentation.  In particular you need 
the files, avmshell and builtin.abc.

errorGen:
java -jar $FLEX_HOME/lib/asc.jar -import /path/to/builtin.abc errorGen.as /path/to/avmshell errorGen.abc. 

lintWarningGen:
java -jar $FLEX_HOME/lib/asc.jar -import /path/to/builtin.abc lintWarningGen.as /path/to/avmshell lintWarningGen.abc. 

The config file for errorGen is errorConfig.xml.
The config file for lintWarningGen is lintConfig.xml.
