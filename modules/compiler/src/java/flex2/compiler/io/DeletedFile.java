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

import flex2.compiler.util.MimeMappings;

/**
 * Represents a file, which has been deleted since the previous
 * compilation.
 *
 * @author Clement Wong
 */
public class DeletedFile implements VirtualFile
{
	public DeletedFile(String name)
	{
		this.name = name;
	}

	private String name;
	private String mimeType;
	         
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
		return null;
	}

	public String getParent()
	{
		return null;
	}

	public long size()
	{
		return 0;
	}

    public boolean isDirectory()
    {
        return false;
    }

    public String getMimeType()
	{
		if (mimeType == null)
		{
            mimeType = MimeMappings.getMimeType(getName());
		}
		return mimeType;
	}

	public InputStream getInputStream() throws IOException
	{
		return null;
	}

	public byte[] toByteArray() throws IOException
	{
		throw new UnsupportedOperationException("toByteArray() not supported in " + this.getClass().getName());
	}

	public long getLastModified()
	{
		return -1;
	}

	public void close()
	{
	}

	public boolean equals(Object obj)
	{
		if (obj instanceof DeletedFile)
		{
			return (this == obj) || getName().equals(((DeletedFile) obj).getName());
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

	public VirtualFile resolve(String relative)
	{
		return null;
	}

	public boolean isTextBased()
	{
		return false;
	}
}
