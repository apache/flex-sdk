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

import flash.util.FileUtils;
import flash.util.Trace;
import flex2.compiler.util.MimeMappings;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;

/**
 * A VirtualFile implemenation, which is backed by a file on a local
 * disk.
 *
 * @author Clement Wong
 */
public class LocalFile implements VirtualFile
{

	public LocalFile(File f)
	{
		this.f = f;
	}

	private File f;
	private String name;
	private String mimeType;

	/**
	 * Return name... It could be canonical path name, URL, etc. But it must be unique among all the files
	 * processed by the compiler...
	 *
	 * The compiler should not use this to get... e.g. parent path... There is no guarantee that this returns
	 * a pathname even though the underlying implementation deals with files...
	 */
	public String getName()
	{
		if (name == null)
		{
			name = FileUtil.getCanonicalPath(f);
			f = FileUtil.openFile(name);
		}

		return name;
	}

	public String getNameForReporting()
	{
		return getName();
	}

	public String getURL()
	{
		try
		{
			return f.toURL().toExternalForm();
		}
		catch (MalformedURLException ex)
		{
			return null;
		}
	}

	// This is temporary...
	public String getParent()
	{
		return f.getParentFile().getAbsolutePath();
	}

	public boolean isDirectory()
	{
		return f.isDirectory();
	}

	/**
	 * Return file size...
	 */
	public long size()
	{
		return f.length();
	}

	/**
	 * Return mime type
	 */
	public String getMimeType()
	{
		if (mimeType == null)
		{
			mimeType = MimeMappings.getMimeType(getName());
		}
		return mimeType;
	}

	/**
	 * Return input stream...
	 */
	public InputStream getInputStream() throws IOException
	{
		return FileUtil.openStream(f);
	}

	public byte[] toByteArray() throws IOException
	{
		return null;
	}

	/**
	 * Return last time the underlying source is modified.
	 */
	public long getLastModified()
	{
		return f.lastModified();
	}

	/**
	 * Return an instance of this interface which represents the specified relative path.
	 */
	public VirtualFile resolve(String relativeStr)
	{
		File relativeFile = null;

		if (FileUtils.isDirectory(f))
		{
			relativeFile = FileUtil.openFile(f, relativeStr);
		}
		else if (FileUtils.isFile(f))
		{
			relativeFile = FileUtil.openFile(f.getParentFile(), relativeStr);
		}

		VirtualFile result = null;

		if (relativeFile != null && FileUtils.exists(relativeFile))
		{
			result = new LocalFile(relativeFile);
		}

		if ((result != null) && Trace.pathResolver)
		{
			Trace.trace("LocalFile.resolve: resolved " + relativeStr + " to " + result.getName());
		}

		return result;
	}

	/**
	 * Signal the hosting environment that this instance is no longer used.
	 */
	public void close()
	{
	}

	public boolean equals(Object obj)
	{
		boolean result = false;

		if (obj instanceof LocalFile)
		{
			result = (this == obj) || getName().equals(((LocalFile) obj).getName());
		}

		return result;
	}

	public int hashCode()
	{
		return getName().hashCode();
	}

	public boolean isTextBased()
	{
		return false;
	}

	public String toString()
	{
		return getName();
	}
}


