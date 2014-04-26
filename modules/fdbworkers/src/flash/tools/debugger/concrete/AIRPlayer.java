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
import flash.tools.debugger.Player;

/**
 * @author Mike Morearty
 */
public class AIRPlayer implements Player
{
	File m_adl;

	/**
	 * @param adl
	 *            The path to adl (Mac/Linux) or adl.exe (Windows); may be null
	 */
	public AIRPlayer(File adl)
	{
		m_adl = adl;
	}

	/*
	 * @see flash.tools.debugger.Player#getType()
	 */
	public int getType()
	{
		return AIR;
	}

	/*
	 * @see flash.tools.debugger.Player#getPath()
	 */
	public File getPath()
	{
		return m_adl;
	}

	/*
	 * @see flash.tools.debugger.Player#getBrowser()
	 */
	public Browser getBrowser()
	{
		return null;
	}
}
