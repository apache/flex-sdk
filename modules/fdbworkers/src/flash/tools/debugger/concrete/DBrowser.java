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

package flash.tools.debugger.concrete;

import java.io.File;

import flash.tools.debugger.Browser;

/**
 * @author mmorearty
 */
public class DBrowser implements Browser
{
	private File m_path;
	private int m_type;

	public DBrowser(File exepath)
	{
		m_path = exepath;
		String exename = exepath.getName().toLowerCase();
		if (exename.equals("iexplore.exe")) //$NON-NLS-1$
			m_type = INTERNET_EXPLORER;
		else if (exename.equals("mozilla.exe")) //$NON-NLS-1$
			m_type = MOZILLA;
		else if (exename.equals("firefox.exe")) //$NON-NLS-1$
			m_type = MOZILLA_FIREFOX;
		else if (exename.equals("opera.exe")) //$NON-NLS-1$
			m_type = OPERA;
		else if (exename.equals("netscape.exe")) //$NON-NLS-1$
			m_type = NETSCAPE_NAVIGATOR;
		else
			m_type = UNKNOWN;
	}

	/*
	 * @see flash.tools.debugger.Browser#getType()
	 */
	public int getType()
	{
		return m_type;
	}

	/*
	 * @see flash.tools.debugger.Browser#getPath()
	 */
	public File getPath()
	{
		return m_path;
	}
}
