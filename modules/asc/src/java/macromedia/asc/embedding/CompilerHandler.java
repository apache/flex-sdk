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

import java.io.InputStream;
import java.io.PrintStream;

import macromedia.asc.parser.InputBuffer;
import macromedia.asc.parser.PackageDefinitionNode;
import macromedia.asc.util.ByteList;
import macromedia.asc.util.ObjectList;

/**
 * Extend CompilerHandler and override error to get custom error notification
 */
public class CompilerHandler
{
	public PrintStream err = System.err;

    public void warning(final String filename, int ln, int col, String msg, String source, int code) {

          warning(filename, ln, col, msg, source);

    }



    public void error(final String filename, int ln, int col, String msg, String source, int code) {

          error(filename, ln, col, msg, source);

    }

    // C: line and column numbers are 1-based.
	public void error(final String filename, int ln, int col, String msg, String source /* ,int code CN: Uncomment when Flex/Flash are ready for the new paramenter */)
	{
		int size;
		if (col > 70) {
			// Position of error
			size = col + 10;

		} else if (source.length() > 70) {
			// Total line length
			size = 70;

		} else {
			size = source.length();
		}

		if (size < source.length()) {
			source = source.substring(0, size) + "...";
		}

		err.println();
		/* CN: Uncomment when Flex/Flash are ready for the new paramenter *
        if (code > 0)
            err.print("Error #" + code +": ");
        else
            err.print("Warning #" + (-code) + ": ");
        */
        err.println(msg);

		// only print position info if ln is a real val (e.g. -1 is used so only 'msg' is printed)
		if(ln >= 0) {
			err.println("   " + filename + ", Ln " + ln + ", Col " + col + ": ");
		}

		if (source.length() > 0) {
			err.println("   " + source);
			err.println("   " + InputBuffer.getLinePointer(col));
		}
	}

     public void warning(final String filename, int ln, int col, String msg, String source)
	{
		// just pipe it into error... no one uses this interface anyway, and it's the same plain formatting
        //  cn: use a negative code to indicate a warning instead of an error.
		error(filename,ln,col,msg,source /* ,-code */);
	}


	public String findPackage(String name)
	{
		return "";
	}

	public ObjectList<PackageDefinitionNode> loadPackages(String filename)
	{
		return new ObjectList<PackageDefinitionNode>();
	}

    public void importFile(final String filename) {}
	public void exit(int exitCode) {}

	/*
	 * jkamerer stubbed from c++
	 */
	public boolean writeBytes(String filename, ByteList bytes)
	{
		return false;
	}

	/**
	 * Allows toolchains to lookup file includes.
	 */
	public FileInclude findFileInclude(String parentPath, String filespec)
	{
		return null;

		/*
		filespec = filespec.replace('/', File.separatorChar);

		String fixed_filespec = null;

		File inc_file = new File(filespec);
		if( inc_file.isAbsolute() )
		{
		    // absolute path
		    fixed_filespec = inc_file.getAbsolutePath();
		}
		else
		{
		    // must be a relative path
		    fixed_filespec = (parentPath==null?"":parentPath) + File.separator + filespec;
		}

		try
		{
			InputStream in = new BufferedInputStream(new FileInputStream(fixed_filespec));
			FileInclude incl = new FileInclude();
			incl.in = in;
			incl.fixed_filespec = fixed_filespec;
			incl.parentPath = fixed_filespec.substring(0, fixed_filespec.lastIndexOf(File.separator));

			return incl;
		}
		catch (FileNotFoundException ex)
		{
			return null;
		}
		*/
	}

	
	/**
	 * C: The error() and warning() reporting system use error codes.
	 *    But the error2() and warning2() reporting system uses message object types.
	 */
	public void warning2(final String filename, int ln, int col, Object msg, String source)
	{
		warning(filename, ln, col, msg.toString(), source);
	}

	public void error2(final String filename, int ln, int col, Object msg, String source)
	{
		error(filename, ln, col, msg.toString(), source);
	}


	public static class FileInclude
	{
		public InputStream in;
		public String text;
		public String fixed_filespec; // full name
		public String parentPath; // parent path name
	}
}
