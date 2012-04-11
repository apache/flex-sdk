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

import flex2.compiler.common.SinglePathResolver;

import java.io.IOException;
import java.io.InputStream;

/**
 * Defines the API to by used by all virtual files.
 *
 * @author Clement Wong
 */
public interface VirtualFile extends SinglePathResolver
{
	/**
	 * Return name... It could be canonical path name, URL, etc. But it must be unique among all the files
	 * processed by the compiler...
	 *
	 * The compiler should not use this to get... e.g. parent path... There is no guarantee that this returns
	 * a pathname even though the underlying implementation deals with files...
	 */
	String getName();

	/**
	 * Return the name to be used when reporting errors or warnings.
	 */ 
	String getNameForReporting();

	/**
	 * Return an URL string of this file
	 */ 
	String getURL();

	// This is only temporary for asc...
	String getParent();

    boolean isDirectory();

    /**
	 * Return file size...
	 */
	long size();

	/**
	 * Return mime type
	 */
	String getMimeType();

	/**
	 * Return input stream...
	 */
	InputStream getInputStream() throws IOException;

	/**
	 * Return the entire content in byte[]
	 */
	byte[] toByteArray() throws IOException;

	/**
	 * Return true if it's text-based. toString() returns the text
	 */
	boolean isTextBased();

	/**
	 * Return last time the underlying source is modified.
	 */
	long getLastModified();

	/**
	 * Signal the hosting environment that this instance is no longer used.
	 */
	void close();

	/**
	 * Override equals(). Instances of VirtualFile can be used as keys.
	 */
	boolean equals(Object object);

	/**
	 * Override hashCode(). Instances of VirtualFile can be used as keys.
	 */
	int hashCode();
}
