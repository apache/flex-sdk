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

/**
 * Represents a VirtualFile implementation backed by a String object.
 *
 * @author Clement Wong
 */
public class TextFile implements VirtualFile
{
	public TextFile(String text, String name, String parent, String mimeType)
	{
        this(text, name, name, parent, mimeType, System.currentTimeMillis());
	}

	public TextFile(String text, String name, String parent, String mimeType, long lastModified)
	{
		init(text, name, name, parent, mimeType, lastModified);
	}

	// This is for creating InlineComponent Source object
	public TextFile(String text, String name, String nameForReporting, String parent, String mimeType, long lastModified)
	{
        init(text, name, nameForReporting, parent, mimeType, lastModified);
	}

    private void init(String text, String name, String nameForReporting, String parent, String mimeType, long lastModified)
    {
	    this.text = text;
	    this.size = text == null ? 0 : text.length();
        this.name = name;
        this.nameForReporting = nameForReporting;
	    this.parent = parent;
        this.mimeType = mimeType;
        this.lastModified = lastModified;
    }

    private String text;
	private String name;
	private String nameForReporting;
	private String parent;
	private String mimeType;
	private long lastModified;
	private long size;

	public String getName()
	{
		return name;
	}

	public String getNameForReporting()
	{
		return nameForReporting;
	}

	public String getURL()
	{
		return "memory://" + name;
	}

	public String getParent()
	{
		return parent;
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
		return size;
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
		throw new UnsupportedOperationException();
	}

	public byte[] toByteArray() throws IOException
	{
		throw new UnsupportedOperationException();
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
	 * Signal the hosting environment that this instance is no longer used.
	 */
	public void close()
	{
		text = null;
	}

	public boolean equals(Object obj)
	{
		if (obj instanceof TextFile)
		{
			return (this == obj) || getName().equals(((TextFile) obj).getName());
		}
		else
		{
			return false;
		}
	}

	public int hashCode()
	{
		return getName().hashCode();
	}

	public boolean isTextBased()
	{
		return true;
	}
	
	public String toString()
	{
		return text;
	}
}

