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

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * Represents a VirtualFile implementation, which is backed by a byte[].
 * 
 * @author Clement Wong
 */
public class InMemoryFile implements VirtualFile
{
	public InMemoryFile(InputStream stream, long size, String name, String mimeType, long lastModified)
		throws IOException
    {
        this(FileUtils.toByteArray(stream, (int) size), name, mimeType, lastModified);
    }

	public InMemoryFile(InputStream stream, String name, String mimeType, long lastModified)
    {
        this(FileUtils.toByteArray(stream), name, mimeType, lastModified);
    }

	public InMemoryFile(byte[] data, String name, String mimeType, long lastModified)
	{
		this.bytes = data;
		this.name = name;
		this.mimeType = mimeType;
	    this.lastModified = lastModified;
	}

    private byte[] bytes;
	private String name;
	private String mimeType;
	private long lastModified;

	public String getName()
	{
		return name;
	}

	public String getNameForReporting()
	{
		return name;
	}

	public String getURL()
	{
		return "memory://" + name;
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
		return bytes.length;
	}

	/**
	 * Return mime type
	 */
	public String getMimeType()
	{
		return mimeType;
	}

	/**
	 * Return input stream...
	 */
	public InputStream getInputStream() throws IOException
	{
		return new ByteArrayInputStream(bytes);
	}

	public byte[] toByteArray() throws IOException
	{
		return bytes;
	}

	/**
	 * Return last time the underlying source is modified.
	 */
	public long getLastModified()
	{
		return lastModified;
	}

    /**
	 * Return an instance of this interface which represents the specified relative path.
	 */
	public VirtualFile resolve(String relative)
	{
		return null;
	}

	/**
	 * Nulls out "bytes".
	 */
	public void close()
	{
        bytes = null;
	}

	public boolean equals(Object object)
	{
        boolean result = false;

		if (object instanceof InMemoryFile)
		{
            if (this == object)
            {
                result = true;
            }
            else
            {
                InMemoryFile otherInMemoryFile = (InMemoryFile) object;

                if (name.equals(otherInMemoryFile.name) &&
                    lastModified == otherInMemoryFile.lastModified &&
                    bytes.length == otherInMemoryFile.bytes.length)
                {
                    result = true;
                }
            }
		}

        return result;
	}

	public int hashCode()
	{
		return (int) (name.hashCode() + lastModified + bytes.length);
	}

	public boolean isTextBased()
	{
		return false;
	}

    public String toString()
    {
        return name;
    }
}
