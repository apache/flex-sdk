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

' Note: this script could be improved with the addition of error handling

' Download and optionally unzip a binary.
'
' arg1 is the URL of the binary to download
' arg2 is the local path for the binary file
' [arg3] if specified, is the target dir to unzip arg2

DownloadBinary WScript.Arguments(0), WScript.Arguments(1)

If WScript.Arguments.Count = 3 Then
    Unzip WScript.Arguments(1), WScript.Arguments(2)
End If

'
' Windows doesn't have a builtin HTTP GET.
' HTTP Get the URL specified with sBinURL to the local file specified by sBinFilePath
'
Function DownloadBinary(sBinURL, sBinFilePath)

    ' Fetch the file
    Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")
    
    objXMLHTTP.open "GET", sBinURL, false
    objXMLHTTP.send()
    
    'wait until the data has downloaded successfully
	do until objXMLHTTP.Status = 200 :  wcript.sleep(1000) :  loop

    If objXMLHTTP.Status = 200 Then
        Set objStream = CreateObject("ADODB.Stream")
        
        objStream.Open
        
        ' Type is binary.
        objStream.Type = 1
        
        objStream.Write objXMLHTTP.ResponseBody
        objStream.Position = 0
    
        ' 2: Overwrite the binary if it already exists.
        objStream.savetofile sBinFilePath, 2
        objStream.Close
        
        Set objStream = Nothing
    End if
    
    Set objXMLHTTP = Nothing

End Function
 
'
' Windows doesn't have a built in unzip command so unzip a zip file with vbScript.
' sZipFilePath is the absolute path to the zip file
' sDestinationDir is the existing target directory
'
Function Unzip(sZipFilePath, sDestinationDir)
    Dim objshell
    
    ' Create Shell.Application so we can use the CopyHere method    
    Set objshell = CreateObject("Shell.Application")
        
    ' Use CopyHere to extract files
    ' Note the options do not work on Windows XP when manipulating a zip file. 
    '  4: Do not display a progress dialog box.
    ' 16: Click "Yes to All" in any dialog box that is displayed.   
    objshell.NameSpace(sDestinationDir).CopyHere objshell.NameSpace(sZipFilePath).Items, 16
    
    Set objshell = Nothing
End Function
