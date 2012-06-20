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

Quick Note:
-----------
The parser is a 'special' piece of the build tree - currently it doesn't
behave as everything else due to javacc and the package layout. 

1) The build script in this directory will take care of the simple case
when the parser is modified via Parser.jjt. It runs 'jjtree' on Parser.jjt
to make the AST nodes (which are then deleted later - more on this in a bit)
and creates Parser.jj for javacc.

2) Javacc is then run on Parser.jj to make Parser.java, which will be compiled
like any other piece of java source via build-velocity.sh (or whatever follows.)

3) In the event that something 'serious' changes, such as an AST node is created
or altered, it must be *manually* moved to the node subdirectory, and have it's
package declaration fixed.  This should be an extremely rare event at this point
and will change with javacc 2.0.

4) When committing changes, to aid readability to those watching the cvs commit 
messages, please commit Parser.jjt separately from the .jj and .java
files generated from .jjt. 

-gmj

