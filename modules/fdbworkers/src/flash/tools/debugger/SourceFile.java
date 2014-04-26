/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package flash.tools.debugger;

/**
 * A SourceFile contains information about a specific segment 
 * of ActionScript source code.  The source code could be
 * derived from a number of locations; an ActionScript file, a 
 * snip-it of code from a frame, compiler generated code, etc.
 */
public interface SourceFile
{
	/**
	 * Base path for this filename, without the package-name portion.  For
	 * example, if class mx.controls.Button.as was in
	 * C:\flex\sdk\frameworks\mx\controls\Button.as, then getBasePath()
	 * would return "C:\flex\sdk\frameworks" (note that the "mx\controls"
	 * part would NOT be returned).
	 * @return base path, or null
	 */
	public String getBasePath();

	/**
	 * Get the package name portion of the path for this file. For example, if
	 * class mx.controls.Button.as was in
	 * C:\flex\sdk\frameworks\mx\controls\Button.as, then getPackageName() would
	 * return "mx\controls".
	 * 
	 * @return package name, or "" (never null)
	 */
	public String getPackageName();

	/**
	 * File name of this SourceFile.  In the case of a disk-based SourceFile,
	 * this is the same as the filename with no path, e.g. 'myfile.as'
	 * @return filename, or "" (never null)
	 */
	public String getName();

	/**
	 * Full path and file name, if its exists, for this SourceFile.  For
	 * disk-based SourceFiles, this is equivalent to
	 *     <code>getBasePath + slash + getPackageName() + slash + getName()</code>
	 * where "slash" is a platform-specific slash character.
	 * @return path, never null
	 */
	public String getFullPath();

	/**
	 * Raw, unprocessed file name for this SourceFile.
	 * @since As of Version 2
	 */
	public String getRawName();

	/**
	 * Returns the number of source lines in the given file
	 * @return -1 indicates an error.  Call getError() to 
	 * obtain specific reason code.
	 */
	public int getLineCount();

	/**
	 * Return a unique identifier for this SourceFile. 
	 */
	public int getId();

	/**
	 * Obtains the textual content of the given line
	 * from within a source file.  
	 * Line numbers start at 1 and go to getLineCount().
	 * 
	 * @return the line of source of the file.  Any carriage
	 *		   return and/or line feed are stripped from the
	 *		   end of the string.
	 */
	public String getLine(int lineNum);

	/**
	 *---------------------------------------------------
	 * WARNING:  The functions below will return null
	 *			 and/or 0 values while 
	 *			 Session.fileMetaDataLoaded() is false.
	 *---------------------------------------------------
	 */

	/**
	 * Return the function name for a given line number, or <code>null</code>
	 * if not known or if the line matches more than one function.
     * @since Version 3.
	 */
	public String getFunctionNameForLine(Session s, int lineNum);

	/**
	 * Return the line number for the given function name
	 * if it doesn't exists -1 is returned
	 */
	public int getLineForFunctionName(Session s, String name);

	/**
	 * Get a list of all function names for this SourceFile
	 */
	public String[] getFunctionNames(Session s);

	/**
	 * Return the offset within the SWF for a given line 
	 * number.
	 */
	public int getOffsetForLine(int lineNum);
}
