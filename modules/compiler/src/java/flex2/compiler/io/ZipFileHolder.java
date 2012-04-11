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

package flex2.compiler.io;

import flex2.compiler.swc.zip.ZipFile;
import flex2.compiler.swc.zip.ZipEntry;

import java.io.IOException;

import flash.util.Trace;

/**
 * A helper class used by VirtualZipFile to open and hold a ZipFile
 * upon request.
 *
 * @author Brian Deitte
 */
public class ZipFileHolder
{
	private ZipFile file;
	private String path;

	public ZipFileHolder(ZipFile file, String path)
	{
		this.file = file;
		this.path = path;
	}

	public ZipFile getZipFile()
	{
		if (file == null)
		{
			try
			{
				file = new ZipFile(path);
			}
			catch (IOException ioe)
			{
				// this should never happen
				throw new RuntimeException("An unexpected error occured when accessing " + path, ioe);
			}
		}
		return file;
	}

	public ZipEntry getEntry(String name)
	{
		return getZipFile().getEntry(name);
	}

	public String getPath()
	{
		return path;
	}

	public void close()
	{
		if (file != null)
		{
			try
			{
				file.close();
			}
			catch(IOException ioe)
			{
				// normally ignore issues with close
				if (Trace.error)
				    ioe.printStackTrace();
			}
			file = null;
		}
	}
}
