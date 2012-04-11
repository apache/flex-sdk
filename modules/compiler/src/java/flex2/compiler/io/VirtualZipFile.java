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
import java.io.ByteArrayInputStream;

import flash.util.FileUtils;
import flex2.compiler.swc.zip.ZipEntry;
import flex2.compiler.util.MimeMappings;

/**
 * Represents a VirtualFile implementation, which is backed by a SwcLazyReadArchive.
 *
 * @author Brian Deitte
 * @author Paul Reilly
 */
public class VirtualZipFile implements VirtualFile
{
	private String mimeType;
	private String name;
	private String nameInZip;
	private byte[] bytes;
	private ZipFileHolder zipFile;

	public VirtualZipFile(ZipFileHolder zipFileHolder, String mimeType, String name, String nameInZip)
	{
		this.zipFile = zipFileHolder;
		this.mimeType = mimeType;
		this.name = name;
		this.nameInZip = nameInZip;
	}

    /**
     * Nulls out "bytes", but does not close the zipFile, because it's
     * potentially shared by other VirtualZipFile and we want to avoid
     * opening and closing it numerous times during a compilation.
     */
	public void close()
	{
        bytes = null;
	}

	public InputStream getInputStream() throws IOException
	{
		return new ByteArrayInputStream(toByteArray());
	}

	/**
	 * The bytes are only loaded as they are needed.
	 */
	public byte[] toByteArray() throws IOException
	{
		if (bytes == null)
		{
            try
            {
                readBytes();
            }
            catch (IOException ioException)
            {
                // ignore the first time around.  It's most likely
                // caused by an invalid handle.
            }
		    
		    // with lazy swc loading, bytes are read only when
		    // required.  if we do an incremental compile with a
		    // change that requires some new dependency to be read
		    // from the swc, bytes could be zero due to invalid
		    // handle.
		    if ((bytes == null) || (bytes.length == 0))
		    {
		        // refresh the swc file handle (only once)
		        zipFile.close();

                // swc handle should be refreshed now.  If an
                // exception is thrown here, don't swallow it.
                readBytes();
		}
		}

		return bytes;
	}

    /**
     * Fills in "bytes" from the zipFile entry, specified by "nameInZip".
     */
    private void readBytes() throws IOException
    {
        InputStream stream = null;

        try
        {
            ZipEntry zipEntry = zipFile.getEntry(nameInZip);
            stream = zipFile.getZipFile().getInputStream(zipEntry);
            bytes = FileUtils.toByteArray(stream);
        }
        finally
        {
            if (stream != null)
            {
                try
                {
                    stream.close();
                }
                catch (IOException ioException)
                {
                    // ignore
                }
            }
        }
    }

	public long getLastModified()
	{
        ZipEntry zipEntry = zipFile.getEntry(nameInZip);
        return zipEntry.getTime();
	}

	public String getMimeType()
	{
		return mimeType;
	}

	public String getName()
	{
		return name;
	}

	public String getNameForReporting()
	{
		return getName();
	}

	public String getParent()
	{
		return zipFile.getPath();
	}

    public boolean isDirectory()
    {
        return false;
    }

    public String getURL()
	{
        return "jar:file://" + getName().replaceAll("\\$", "!/");
	}

	public long size()
	{
        ZipEntry zipEntry = zipFile.getEntry(nameInZip);
        return zipEntry.getSize();
	}

	public VirtualFile resolve(String relative)
	{
        int separator = nameInZip.lastIndexOf("/");

        if (separator != -1)
        {
            relative = FileUtils.addPathComponents(nameInZip.substring(0, separator), relative, '/');
        }

        ZipEntry zipEntry = zipFile.getEntry(relative);
        VirtualFile result = null;

        if (zipEntry != null)
        {
            String name = zipEntry.getName();
            result = new VirtualZipFile(zipFile, MimeMappings.getMimeType(zipEntry.getName()),
                                        zipFile.getPath() + "$" + name, name);
        }

        return result;
	}

	public boolean equals(Object obj)
	{
		return obj == this;
	}

    public int hashCode()
    {
        return getName().hashCode();
    }

	public boolean isTextBased()
	{
		return false;
	}
}
