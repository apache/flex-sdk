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

Option Explicit

ExtractAll WScript.Arguments(0), WScript.Arguments(1)

Sub ExtractAll( ByVal myZipFile, ByVal myTargetDir )
' Function to extract all files from a compressed "folder"
' (ZIP, CAB, etc.) using the Shell Folders' CopyHere method
' (http://msdn2.microsoft.com/en-us/library/ms723207.aspx).
' All files and folders will be extracted from the ZIP file.
' A progress bar will be displayed.
'
' Arguments:
' myZipFile    [string]  the fully qualified path of the ZIP file
' myTargetDir  [string]  the fully qualified path of the (existing) destination folder
'
' Based on an article by Gerald Gibson Jr.:
' http://www.codeproject.com/csharp/decompresswinshellapics.asp
'
' Written by Rob van der Woude
' http://www.robvanderwoude.com

    Dim intOptions, objShell, objSource, objTarget

    ' Create the required Shell objects
    Set objShell = CreateObject( "Shell.Application" )

    ' Create a reference to the files and folders in the ZIP file
    Set objSource = objShell.NameSpace( myZipFile ).Items( )

    ' Create a reference to the target folder
    Set objTarget = objShell.NameSpace( myTargetDir )

    ' 16: Click "Yes to All" in any dialog box that is displayed.
    intOptions = 16

    ' UnZIP the files
    objTarget.CopyHere objSource, intOptions

    ' Release the objects
    Set objSource = Nothing
    Set objTarget = Nothing
    Set objShell  = Nothing
End Sub