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

package flex2.tools.oem;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;

import flash.util.FileUtils;
import flex2.compiler.io.FileUtil;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.util.MimeMappings;

/**
 * The <code>VirtualLocalFile</code> class represents a source file in memory. Each <code>VirtualLocalFile</code> instance
 * is given a parent that corresponds to a valid directory in the filesystem. Path
 * resolution is done as if <code>VirtualLocalFile</code> instances represented real files in the filesystem.
 * 
 * <p>
 * You can not create an instance of the <code>VirtualLocalFile</code> class directly. You must 
 * use the <code>VirtualLocalFileSystem</code> class to create them.
 * 
 * @see flex2.tools.oem.VirtualLocalFileSystem 
 * @version 2.0.1
 * @author Clement Wong
 */
public class VirtualLocalFile implements VirtualFile
{
    /**
     * Constructs a <code>VirtualLocalFile</code> object. You cannnot use this constructor directly. 
     * You must use the <code>VirtualLocalFileSystem.create()</code> to create <code>VirtualLocalFile</code> instances.
     * 
     * @param name A canonical path.
     * @param mimeType The MIME type.
     * @param text Source code.
     * @param parent The parent directory of this <code>VirtualLocalFile</code> object.
     * @param lastModified The last modified time.
     * @param fs An instance of the <code>VirtualLocalFileSystem</code> class.
     */
    VirtualLocalFile(String name, String text, File parent, long lastModified, VirtualLocalFileSystem fs)
    {
        this.name = name;
        this.text = text;
        this.parent = FileUtil.getCanonicalFile(parent);
        this.lastModified = lastModified;
        this.fs = fs;

        assert FileUtils.isDirectory(this.parent);
    }

    String text;
    private File parent;
    private String name;
    private String mimeType;
    long lastModified;
    private VirtualLocalFileSystem fs;

    /**
     * Gets the name of this <code>VirtualLocalFile</code> object. This is sually a canonical path.
     * 
     * @return The name of this <code>VirtualLocalFile</code> object.
     */
    public String getName()
    {
        return name;
    }

    /**
     * Gets the name of this <code>VirtualLocalFile</code> for error reporting. This is usually a canonical path.
     * 
     * @return The name used when reporting warnings and errors.
     * 
     * @see #getName()
     */
    public String getNameForReporting()
    {
        return getName();
    }

    /**
     * Throws an <code>UnsupportedOperationException</code> exception.
     */
    public String getURL()
    {
        throw new UnsupportedOperationException();
    }

    /**
     * Gets the parent directory path of this <code>VirtualLocalFile</code> object.
     * 
     * @return The parent's canonical path.
     */
    public String getParent()
    {
        return FileUtil.getCanonicalPath(parent);
    }
    
    /**
     * Returns <code>true</code> if this <code>VirtualLocalFile</code> object is a directory. This method always returns <code>false</code>.
     * 
     * @return <code>false</code>.
     */
    public boolean isDirectory()
    {
        return false;
    }

    /**
     * Returns the length of the text in this <code>VirtualLocalFile</code> object.
     * 
     * @return The length of the text.
     */
    public long size()
    {
        return text == null ? 0 : text.length();
    }

    /**
     * Returns The MIME type of this <code>VirtualLocalFile</code> object.
     * 
     * @return The MIME type.
     */
    public String getMimeType()
    {
        if (mimeType == null)
        {
            mimeType = MimeMappings.getMimeType(name);
        }
        return mimeType;
    }

    /**
     * Returns the text in this <code>VirtualLocalFile</code> object in an <code>InputStream</code>.
     * The text is converted into a byte stream based on <code>UTF-8</code> encoding.
     * 
     * @return An <code>InputStream</code>.
     * 
     * @throws IOException Thrown when an I/O error occurs.
     */
    public InputStream getInputStream() throws IOException
    {
        return new ByteArrayInputStream(text == null ? new byte[0] : text.getBytes("UTF-8"));
    }

    /**
     * Returns the text in this <code>VirtualLocalFile</code> object in an <code>byte[]</code>.
     */
    public byte[] toByteArray() throws IOException
    {
        return text == null ? new byte[0] : text.getBytes("UTF-8");
    }

    /**
     * Gets the last modified time of this <code>VirtualLocalFile</code> object.
     * 
     * @return The last modified time.
     */
    public long getLastModified()
    {
        return lastModified;
    }

    /**
     * Resolves the specified relative path to a <code>VirtualFile</code> instance.
     * 
     * @param relativeStr The relative path to be resolved.
     * 
     * @return If successful, a <code>VirtualFile</code> for <code>relativeStr</code>.
     */
    public VirtualFile resolve(String relativeStr)
    {
        return fs.resolve(this, relativeStr);
    }

    /**
     * Closes this <code>VirtualLocalFile</code> object. This method does nothing.
     */
    public void close()
    {
    }

    /**
     * Compares this object with the specified object.
     * 
     * @param obj An Object.
     * 
     * @return <code>true</code> if <code>obj == this</code>.
     */
    public boolean equals(Object obj)
    {
        if (obj instanceof VirtualLocalFile)
        {
            return (this == obj) || getName().equals(((VirtualLocalFile) obj).getName());
        }
        else
        {
            return false;
        }
    }

    /**
     * Returns the hash code of this <code>VirtualLocalFile</code> object.
     * 
     * @return The hashCode.
     */
    public int hashCode()
    {
        return getName().hashCode();
    }

    /**
     * Returns <code>true</code> if the content of this <code>VirtualLocalFile</code> object is text based.
     * This method always returns <code>true</code>.
     * 
     * @return <code>true</code>.
     */
    public boolean isTextBased()
    {
        return true;
    }
    
    public String toString()
    {
        return text;
    }
}


