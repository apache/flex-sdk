/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package flash.tools.debugger;

import java.io.File;

/**
 * Describes a web browser.
 * 
 * @author mmorearty
 */
public interface Browser
{
	/**
	 * Indicates an unknown browser type.
	 * 
	 * @see #getType()
	 */
	public static final int UNKNOWN = 0;

	/**
	 * Indicates Internet Explorer.
	 * 
	 * @see #getType()
	 */
	public static final int INTERNET_EXPLORER = 1;

	/**
	 * Indicates Netscape Navigator.
	 * 
	 * @see #getType()
	 */
	public static final int NETSCAPE_NAVIGATOR = 2;

	/**
	 * Indicates Opera.
	 * 
	 * @see #getType()
	 */
	public static final int OPERA = 3;

	/**
	 * Indicates the Mozilla browser, but <i>not</i> Firefox.
	 * 
	 * @see #getType()
	 */
	public static final int MOZILLA = 4;

	/**
	 * Indicates Firefox.
	 * 
	 * @see #getType()
	 */
	public static final int MOZILLA_FIREFOX = 5;

	/**
	 * Returns what type of Player this is, e.g. <code>INTERNET_EXPLORER</code>, etc.
	 */
	public int getType();

	/**
	 * Returns the path to the web browser executable -- e.g. the path to
	 * IExplore.exe, Firefox.exe, etc. (Filenames are obviously
	 * platform-specific.)
	 */
	public File getPath();
}
