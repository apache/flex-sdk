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

import flash.localization.LocalizationManager;
import flash.tools.debugger.concrete.PlayerSessionManager;

/**
 * Entry point for access to the general API.  A debugger uses this
 * class to gain access to a SessionManager from which debugging
 * sessions may be controlled or initiated.
 */
public class Bootstrap
{
	static SessionManager m_mgr = null;
	private static LocalizationManager m_localizationManager;

	static
	{
        // set up for localizing messages
        m_localizationManager = new LocalizationManager();
        m_localizationManager.addLocalizer( new DebuggerLocalizer("flash.tools.debugger.djapi.") ); //$NON-NLS-1$
	}

	private Bootstrap () {}

	public static SessionManager sessionManager()
	{
		if (m_mgr == null)
			m_mgr = new PlayerSessionManager();
		return m_mgr;
	}

	static LocalizationManager getLocalizationManager()
	{
		return m_localizationManager;
	}
}
