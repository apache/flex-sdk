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

import avmplus.*

if (System.argv.length != 3)
	trace("Usage locDiff fileOne.xml fileTwo.xml output.xml " );
else
{
	var oldFile:XML = XML(File.read(System.argv[0]));
	var newFile:XML = XML(File.read(System.argv[1]));
	var diffableXML:XML = <diffs></diffs>;
	
	//var elements:XMLList = oldFile.descendants("error");
	if (newFile.warnings == undefined)
	{
		for each (var w:XML in newFile..error)
		{
			delete w.description;
			var w2:XMLList = oldFile..error.(@id == w.@id);
			delete w2.description;
			if (w2 == undefined)
			{
				diffableXML.New += <New id={w.@id} label={w.@label}>{String(w)}</New>
			}
			else if (String(w2) != String(w))
			{
				diffableXML.changed += <changed id={w.@id} label={w.@label}>{String(w)}<originalText>{String(w2)}</originalText></changed>
			}
		}
	}
	else
	{
		for each (var w:XML in newFile.warnings.warning)
		{
			delete w.description;
			var w2:XMLList = oldFile.warnings..warning.(@id == w.@id);
			delete w2.description;
			if (w2 == undefined)
			{
				diffableXML.New += <New id={w.@id} label={w.@label}>{String(w)}</New>
			}
			else if (String(w2) != String(w))
			{
				diffableXML.changed += <changed id={w.@id} label={w.@label}>{String(w)}<originalText>{String(w2)}</originalText></changed>
			}
		}
	}
	
	var s:String = "<?xml version='1.0' encoding='utf-8' standalone='no' ?>\n";
	s += diffableXML.toXMLString()
	File.write(System.argv[2], s);
}