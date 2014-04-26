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

import flash.tools.debugger.expression.NoSuchVariableException;

public class InternalProperty
{
	String m_key;
	Object m_value;

	public InternalProperty(String key, Object value)
	{
		m_key = key;
		m_value = value;
	}

	/* getters */
	public String getName()		{ return m_key; }
	@Override
	public String toString()	{ return (m_value == null) ? "null" : m_value.toString(); } //$NON-NLS-1$

	public String valueOf() throws NoSuchVariableException 
	{ 
		if (m_value == null) 
			throw new NoSuchVariableException(m_key);

		return toString();
	}

}
