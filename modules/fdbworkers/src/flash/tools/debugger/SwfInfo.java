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
 * The SwfInfo object contains information relating to
 * a particular swf file that was loaded by the Player.
 * Each SWF file contains a list of actionscript source
 * files from which execution is performed.
 * 
 * It is important to note 2 or more SWF files may contain
 * multiple copies of the same source code.  From the 
 * Player's perspective and the API perspective these
 * copies are unique and it is up to the user of the 
 * API to detect these 'duplicate' files and either
 * filter them from the user and/or present an
 * appropriate disambiguous representation of 
 * the file names.  Also internally they are treated
 * as two distinct files and thus breakpoints 
 * will most likely need to be set on both files
 * independently.
 */
public interface SwfInfo
{
	/**
	 * The full path of the SWF.
	 */
	public String getPath();

	/**
	 * The URL for the SWF.  Includes any options
	 * at the end of the URL. For example ?debug=true
	 */
	public String getUrl();

	/**
	 * The size of this SWF in bytes
	 */
	public int getSwfSize();

	/**
	 * The size of the debug SWD file, if any
	 * This may also be zero if the SWD load is in progress
	 * @throws InProgressException if the SWD has not yet been loaded
	 */
	public int getSwdSize(Session s) throws InProgressException;

	/**
	 * Indication that this SWF, which was previously loaded into
	 * the Player, is now currently unloaded.  All breakpoints
	 * set on any of the files contained within this SWF will
	 * be inactive.  These breakpoints will still exist in the 
	 * list returned by Session.getBreakpointList()
	 */
	public boolean isUnloaded();
	
	/**
	 * Indicates whether the contents of the SWF file
	 * have been completely processed.
	 * Completely processed means that calls to getSwdSize
	 * and other calls that may throw an InProgressException will
	 * not throw this exception.  Additionally the function
	 * and offset related calls within SourceFile will return
	 * non-null values once this call returns true.
	 * @since Version 2
	 */
	public boolean isProcessingComplete();

	/**
	 * Number of source files in this SWF.
	 * May be zero if no debug 
	 * @throws InProgressException if the SWD has not yet been loaded
	 */
	public int getSourceCount(Session s) throws InProgressException;

	/**
	 * List of source files that are contained within 
	 * this SWF.
	 * @throws InProgressException if the SWD has not yet been loaded
	 * @since Version 2
	 */
	public SourceFile[] getSourceList(Session s) throws InProgressException;

	/**
	 * Returns true if the given source file is contained 
	 * within this SWF. 
	 * @since Version 2
	 */
	public boolean containsSource(SourceFile f);
	
	/**
	 * Return the worker ID to which this SWF belongs.
	 */
	public int getIsolateId();
}
