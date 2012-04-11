////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

/** normalizeXML.as
/*   This script merely reads in an XML format file and writes it out again using the default E4X xml formating.  Run this
*     script on a source file to establish a baseline standard format before using the generateLocDiffs/integrateLocDiffs
*     scripts (else all the formating changes between the hand rolled file and the E4X formatted file will make diff comparisions difficult(
*
*      chris nuuja  6/25/06
*/

import avmplus.*
		
if (System.argv.length != 2)
{
	trace("Usage avmplus normalizeXML.abc -- originalFile normalizedFileName " );
}
else
{
	var origFile:String = System.argv[0];
	var outputFile:String = System.argv[1];
	
	var normFile:XML = XML(File.read(origFile));
	
	// output the result.
	var s:String = "<?xml version='1.0' encoding='utf-8' standalone='no' ?>\n";
	s += normFile.toXMLString()
	File.write(outputFile, s);
}