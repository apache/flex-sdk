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

import java.io.InputStream;

/**
 * A callback interface which should be implemented by the client debugger
 * (such as fdb), to locate source files.
 * 
 * This is only necessary if the client debugger wants the DJAPI to "own"
 * the source code.  Zorn, for example, will probably *not* want to
 * implement this interface, because Eclipse itself will load the source
 * files from disk.
 */
public interface SourceLocator
{
	/**
	 * Callback from DJAPI to the debugger, to find a source file.
	 * Returns null if it can't find the file.
	 */
    public InputStream locateSource(String path, String pkg, String name);

	/**
	 * Returns a number which indicates how many times this SourceLocator's
	 * search algorithm has been changed since it was created.  For example,
	 * if a SourceLocator allows the user to change the list of directories
	 * that are searched, then each time the user changes that list of
	 * directories, the return value from getChangeCount() should change.
	 * 
	 * The DJAPI uses this in order to figure out if it should try again
	 * to look for a source file that it had previously been unable to
	 * find.
	 */
	public int getChangeCount();
}
