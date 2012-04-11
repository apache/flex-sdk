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

package com.adobe.fxg.util;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;

/**
 * Implementations of ResourceResolver are used to locate and load resources,
 * such as embedded images, while processing an FXG DOM.
 */
public interface FXGResourceResolver
{
	
	/**
	 * Gets the root path.
	 * 
	 * @return the root path
	 */
	String getRootPath();
	
	/**
	 * Sets the root path.
	 * 
	 * @param dir the new root path
	 */
	void setRootPath(String dir);

	/**
	 * Resolve the path.
	 * 
	 * @param path the path
	 * 
	 * @return the resolved path string
	 */
	String resolve(String path);
	
	/**
	 * Open stream.
	 * 
	 * @param path the path
	 * 
	 * @return the input stream
	 * 
	 * @throws IOException Signals that an I/O exception has occurred.
	 */
	InputStream openStream(String path) throws IOException;

	/**
	 * Open stream.
	 * 
	 * @param url the url
	 * 
	 * @return the input stream
	 * 
	 * @throws IOException Signals that an I/O exception has occurred.
	 */
	InputStream openStream(URL url) throws IOException;
}
