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

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.net.URLConnection;

/**
 * A VirtualFile implemenation, which is backed by a file not on a
 * local disk.
 */
public class NetworkFile implements VirtualFile
{
	public NetworkFile(URL u) throws IOException
	{
		name = u.toExternalForm();
		conn = u.openConnection();
	}

	private String name;
	private URLConnection conn;

	/**
	 * Return name... It could be canonical path name, URL, etc. But it must be unique among all the files
	 * processed by the compiler...
	 *
	 * The compiler should not use this to get... e.g. parent path... There is no guarantee that this returns
	 * a pathname even though the underlying implementation deals with files...
	 */
	public String getName()
	{
		return name;
	}

	public String getNameForReporting()
	{
		return getName();
	}

	public String getURL()
	{
		return name;
	}

	public String getParent()
	{
		return null;
	}

    public boolean isDirectory()
    {
        return false;
    }

    /**
	 * Return file size...
	 */
	public long size()
	{
		return conn.getContentLength();
	}

	/**
	 * Return mime type
	 */
	public String getMimeType()
	{
		return conn.getContentType();
	}

	/**
	 * Return input stream...
	 */
	public InputStream getInputStream() throws IOException
	{
		return conn.getInputStream();
	}

	public byte[] toByteArray() throws IOException
	{
		throw new UnsupportedOperationException("toByteArray() not supported in " + this.getClass().getName());
	}
	
	/**
	 * Return last time the underlying source is modified.
	 */
	public long getLastModified()
	{
		return conn.getLastModified();
	}

	/**
	 * Return an instance of this interface which represents the specified relative path.
	 */
	public VirtualFile resolve(String relative)
	{
		return null;
	}

	/**
	 * Signal the hosting environment that this instance is no longer used.
	 */
	public void close()
	{
	}


	public boolean equals(Object obj)
	{
		if (obj instanceof NetworkFile)
		{
			return (this == obj) || name.equals(((NetworkFile) obj).name);
		}
		else
		{
			return false;
		}
	}

	public int hashCode()
	{
		return name.hashCode();
	}

	public boolean isTextBased()
	{
		return false;
	}
}
