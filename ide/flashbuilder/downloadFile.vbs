'################################################################################
'##
'##  Licensed to the Apache Software Foundation (ASF) under one or more
'##  contributor license agreements.  See the NOTICE file distributed with
'##  this work for additional information regarding copyright ownership.
'##  The ASF licenses this file to You under the Apache License, Version 2.0
'##  (the "License"); you may not use this file except in compliance with
'##  the License.  You may obtain a copy of the License at
'##
'##      http://www.apache.org/licenses/LICENSE-2.0
'##
'##  Unless required by applicable law or agreed to in writing, software
'##  distributed under the License is distributed on an "AS IS" BASIS,
'##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
'##  See the License for the specific language governing permissions and
'##  limitations under the License.
'##
'################################################################################

' Written by Rob van der Woude
' http://www.robvanderwoude.com

function downloadFile(sFileURL, sLocation)
 
	'create xmlhttp object
	Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")
 
	'get the remote file
	objXMLHTTP.open "GET", sFileURL, false
 
	'send the request
	objXMLHTTP.send()
 
	'wait until the data has downloaded successfully
	do until objXMLHTTP.Status = 200 :  wcript.sleep(1000) :  loop
 
	'if the data has downloaded sucessfully
	If objXMLHTTP.Status = 200 Then
 
        'create binary stream object
		Set objADOStream = CreateObject("ADODB.Stream")
		objADOStream.Open
 
        'adTypeBinary
		objADOStream.Type = 1
		objADOStream.Write objXMLHTTP.ResponseBody
 
        'Set the stream position to the start
		objADOStream.Position = 0    
 
	    'create file system object to allow the script to check for an existing file
	    Set objFSO = Createobject("Scripting.FileSystemObject")
 
	    'check if the file exists, if it exists then delete it
		If objFSO.Fileexists(sLocation) Then objFSO.DeleteFile sLocation
 
	    'destroy file system object
		Set objFSO = Nothing
 
	    'save the ado stream to a file
		objADOStream.SaveToFile sLocation
 
	    'close the ado stream
		objADOStream.Close
 
		'destroy the ado stream object
		Set objADOStream = Nothing
 
	'end object downloaded successfully
	End if
 
	'destroy xml http object
	Set objXMLHTTP = Nothing
 
End function
 
downloadFile WScript.Arguments(0), WScript.Arguments(1)