/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package macromedia.asc.embedding;

import java.io.File;

import macromedia.asc.parser.PackageDefinitionNode;
import macromedia.asc.util.ObjectList;

/**
 * This class exists so that errors and warnings can be output in a system/environment
 * agnostic way and diffed on any system. I.e. filenames and special formatting are dropped.
 * 
 * Filenames are stripped to just the file itself, paths are dropped.
 * 
 * This can still break sanities if an error message is changed, so the regressions
 * would need to be updated.
 */
public class SanityCompilerHandler extends CompilerHandler
{
	public void error(final String filename, int ln, int col, String msg, String source, int code)
	{
		// TODO Path resolution
		final File f = new File(filename);
		// msg is just a numeric code and arguments when the -sanity switch is used
		// it's weird, but errors send off-by-one ln/col and warnings send off-by-one cols only
		System.err.println("ERROR:   file = " + f.getName().trim() + "(" + ln + ":" + col + ")");
		System.err.println("         mesg = " + msg.trim());
		System.err.println("         srce = " + source.trim());
	}

	public void warning(final String filename, int ln, int col, String msg, String source, int code)
	{
		// TODO Path resolution
		final File f = new File(filename);
		// msg is just a numeric code and arguments when the -sanity switch is used
		System.err.println("WARNING: file = " + f.getName().trim() + "(" + ln + ":" + col + ")");
		System.err.println("         mesg = " + msg.trim());
		System.err.println("         srce = " + source.trim());
	}

	public ObjectList<PackageDefinitionNode> loadPackages(String filename) {
		return new ObjectList<PackageDefinitionNode>();
	}
	public String findPackage(String name) { return ""; }
    public void importFile(final String filename) {}
	public void exit(int exitCode) {}
}
