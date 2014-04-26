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

package flex.tools.debugger.cli;

/**
 * 
 * An object that relates a CLI debugger catchpoint with the
 * actual Catch obtained from the Session
 * 
 * @author Mike Morearty
 */
public class CatchAction
{
	private final int m_id;
	private final String m_typeToCatch;

	/**
	 * @param typeToCatch
	 *            the type, e.g. "ReferenceError" or "com.example.MyError". If
	 *            typeToCatch is <code>null</code>, that means to halt on any
	 *            exception.
	 */
	public CatchAction(String typeToCatch)
	{
		m_typeToCatch = typeToCatch;
		m_id = BreakIdentifier.next();
	}

	public int getId()
	{
		return m_id;
	}

	/**
	 * Returns the type being caught, or <code>null</code> to catch all
	 * exceptions.
	 */
	public String getTypeToCatch()
	{
		return m_typeToCatch;
	}
}
